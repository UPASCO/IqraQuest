import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../services/local_storage_service.dart';
import '../domain/classroom_state.dart';
import 'teacher_gateway.dart';

/// The teacher's console, over the wire.
///
/// Sign-in is a link sent to the address that paid — no password exists
/// anywhere in this system, and nothing but that address identifies a
/// teacher. Everything after that goes through the four functions in
/// `0002_classroom_teacher.sql`, each of which checks the licence before
/// it does anything: the console never touches a table.
class SupabaseTeacherGateway implements TeacherGateway {
  SupabaseTeacherGateway({
    required this.url,
    required this.anonKey,
    required this.storage,
    this.redirectTo,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String url;
  final String anonKey;
  final LocalStorageService storage;

  /// Where the magic link comes back to — the console's own address.
  final String? redirectTo;

  final http.Client _client;

  static const _sessionKey = 'iqraquest.teacher.session.v1';

  String? _accessToken;
  String? _refreshToken;
  String? _email;

  @override
  bool get isSignedIn => _accessToken != null;

  @override
  String? get email => _email;

  @override
  Future<void> sendMagicLink(String address) async {
    final clean = address.trim();
    if (!_looksLikeEmail(clean)) {
      throw const TeacherException(TeacherError.invalidEmail);
    }
    // Le retour se déclare dans l'URL, pas dans le corps : GoTrue lit
    // `?redirect_to=`. Passé en `options.email_redirect_to`, il était
    // ignoré, et le lien ramenait sur la Site URL — donc sur une console
    // qui ne voyait jamais ses jetons.
    final path = redirectTo == null || redirectTo!.isEmpty
        ? '/auth/v1/otp'
        : '/auth/v1/otp?redirect_to=${Uri.encodeComponent(redirectTo!)}';
    final response = await _post(
      path,
      body: {'email': clean, 'create_user': true},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const TeacherException(TeacherError.unreachable);
    }
  }

  /// Reads the tokens a magic link leaves in the address bar, then falls
  /// back to the ones this browser kept from last time.
  @override
  Future<bool> restore({String? fragment}) async {
    final fromLink = sessionFromFragment(fragment ?? Uri.base.fragment);
    if (fromLink != null) {
      await _remember(fromLink);
      return true;
    }
    final kept = storage.getJson(_sessionKey);
    if (kept == null) return false;
    _accessToken = kept['access_token'] as String?;
    _refreshToken = kept['refresh_token'] as String?;
    _email = kept['email'] as String?;
    if (_refreshToken == null) return false;
    // The kept token is probably stale — an hour is the usual life of
    // one — so trade the refresh token for a fresh pair straight away.
    return _refresh();
  }

  Future<bool> _refresh() async {
    final response = await _post(
      '/auth/v1/token?grant_type=refresh_token',
      body: {'refresh_token': _refreshToken},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      await signOut();
      return false;
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    await _remember(
      TeacherLinkSession(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String? ?? _refreshToken!,
        email: (json['user'] as Map?)?['email'] as String? ?? _email,
      ),
    );
    return true;
  }

  Future<void> _remember(TeacherLinkSession session) async {
    _accessToken = session.accessToken;
    _refreshToken = session.refreshToken;
    _email = session.email ?? _email;
    await storage.setJson(_sessionKey, {
      'access_token': _accessToken,
      'refresh_token': _refreshToken,
      if (_email != null) 'email': _email,
    });
  }

  @override
  Future<Licence?> licence() async {
    final json = await _rpc('my_licence', const {});
    if (json == null || json['id'] == null) return null;
    return Licence.fromJson(json);
  }

  @override
  Future<({String sessionId, String code})> openSession({
    required String lessonId,
    required List<String> questionIds,
    int teamCount = 3,
    String boardLanguage = 'fr',
    int secondsPerQuestion = 0,
    bool keepIndividualScores = false,
    ClassroomScoring scoring = ClassroomScoring.teams,
  }) async {
    final json = await _rpc('open_session', {
      'p_lesson_id': lessonId,
      'p_question_ids': questionIds,
      'p_team_count': teamCount,
      'p_board_language': boardLanguage,
      'p_seconds_per_question': secondsPerQuestion,
      'p_keep_individual_scores': keepIndividualScores,
      'p_scoring_mode': scoring.name,
    });
    return (
      sessionId: json!['sessionId'] as String,
      code: json['code'] as String,
    );
  }

  @override
  Future<void> advance(String sessionId, TeacherAction action) async {
    await _rpc('advance_session', {
      'p_session_id': sessionId,
      'p_action': action.name,
    });
  }

  @override
  Future<void> signOut() async {
    _accessToken = null;
    _refreshToken = null;
    _email = null;
    await storage.remove(_sessionKey);
  }

  // ---- Plumbing ----

  Future<http.Response> _post(
    String path, {
    required Map<String, dynamic> body,
    String? bearer,
  }) async {
    try {
      return await _client.post(
        Uri.parse('$url$path'),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer ${bearer ?? anonKey}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
    } catch (_) {
      throw const TeacherException(TeacherError.unreachable);
    }
  }

  /// Calls one of the teacher functions, once as it is and once more
  /// with a fresh token if the first attempt was turned away — an
  /// expired hour must not throw a teacher out mid-lesson.
  Future<Map<String, dynamic>?> _rpc(
    String function,
    Map<String, dynamic> body, {
    bool retry = true,
  }) async {
    if (_accessToken == null) {
      throw const TeacherException(TeacherError.notSignedIn);
    }
    final response = await _post(
      '/rest/v1/rpc/$function',
      body: body,
      bearer: _accessToken,
    );
    if (response.statusCode == 401 && retry) {
      if (await _refresh()) {
        return _rpc(function, body, retry: false);
      }
      throw const TeacherException(TeacherError.notSignedIn);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const TeacherException(TeacherError.unreachable);
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded == null) return null;
    if (decoded is! Map<String, dynamic>) {
      throw const TeacherException(TeacherError.unreachable);
    }
    final error = decoded['error'];
    if (error is String) {
      throw TeacherException(
        _errorOf(error),
        limit: (decoded['limit'] as num?)?.toInt(),
      );
    }
    return decoded;
  }

  static TeacherError _errorOf(String code) => switch (code) {
    'no_licence' => TeacherError.noLicence,
    'licence_expired' => TeacherError.licenceExpired,
    'too_many_sessions' => TeacherError.tooManySessions,
    'no_questions' => TeacherError.noQuestions,
    'unknown_session' => TeacherError.unknownSession,
    'not_now' => TeacherError.notNow,
    _ => TeacherError.unreachable,
  };

  static bool _looksLikeEmail(String value) =>
      RegExp(r'^[^@\s]+@[^@\s.]+\.[^@\s]+$').hasMatch(value);
}

/// What a magic link leaves behind in the address bar.
///
/// Supabase returns the pair in the URL fragment, which never reaches a
/// server — not ours, not anyone's log. Parsed here rather than in the
/// screen so it can be tested without a browser.
TeacherLinkSession? sessionFromFragment(String fragment) {
  if (fragment.isEmpty) return null;
  // Two shapes reach this. Supabase's own is a bare
  // `access_token=...&refresh_token=...`. The hash-routed build gets
  // `/teacher?access_token=...` instead, because `web/teacher-callback.html`
  // hands the pair over that way — still inside the fragment, so it
  // never travels to any server, ours included.
  final question = fragment.indexOf('?');
  final query = question >= 0 ? fragment.substring(question + 1) : fragment;
  final values = Uri.splitQueryString(query);
  final access = values['access_token'];
  final refresh = values['refresh_token'];
  if (access == null || access.isEmpty || refresh == null) return null;
  return TeacherLinkSession(accessToken: access, refreshToken: refresh);
}

class TeacherLinkSession {
  const TeacherLinkSession({
    required this.accessToken,
    required this.refreshToken,
    this.email,
  });

  final String accessToken;
  final String refreshToken;
  final String? email;
}
