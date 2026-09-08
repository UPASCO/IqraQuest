import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/classroom_state.dart';
import 'classroom_gateway.dart';

/// The classroom, over the wire.
///
/// Everything goes through the four functions in
/// `server/supabase/migrations/`: the anon key can call those and nothing
/// else, because every table refuses it outright. So a code copied off a
/// whiteboard reaches exactly one classroom and reads exactly what a
/// projector may show — no participant list of another school, no answer
/// of another child.
///
/// The room is polled rather than subscribed to. A lesson is a handful of
/// state changes over twenty minutes, `board_state` is one cheap read,
/// and a poll is the thing that keeps working through a school network
/// that drops a websocket every few minutes.
class SupabaseClassroomGateway implements ClassroomGateway {
  SupabaseClassroomGateway({
    required this.url,
    required this.anonKey,
    http.Client? client,
    this.pollInterval = const Duration(seconds: 2),
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  final String url;
  final String anonKey;
  final Duration pollInterval;

  final http.Client _client;
  final bool _ownsClient;

  final Map<String, _RoomWatch> _watches = {};

  @override
  Future<ClassroomSeat> join({
    required String code,
    required String nickname,
  }) async {
    final json = await _rpc('join_session', {
      'p_code': code,
      'p_nickname': nickname,
    });
    return ClassroomSeat.fromJson(
      json,
      code: code.trim().toUpperCase(),
      nickname: nickname.trim(),
    );
  }

  @override
  Future<ClassroomAnswerOutcome> answer({
    required String code,
    required String token,
    required int questionIndex,
    required int choice,
  }) async {
    final json = await _rpc('submit_answer', {
      'p_code': code,
      'p_token': token,
      'p_question_index': questionIndex,
      'p_choice': choice,
    });
    return ClassroomAnswerOutcome(correct: json['correct'] == true);
  }

  @override
  Future<ClassroomState> boardState(String code) async {
    final json = await _rpc('board_state', {'p_code': code});
    return ClassroomState.fromJson(json);
  }

  @override
  Stream<ClassroomState> watch(String code) {
    final key = code.trim().toUpperCase();
    final watch = _watches.putIfAbsent(
      key,
      () => _RoomWatch(
        read: () => boardState(key),
        interval: pollInterval,
        onDone: () => _watches.remove(key),
      ),
    );
    return watch.stream;
  }

  @override
  Future<void> dispose() async {
    for (final watch in _watches.values.toList()) {
      await watch.close();
    }
    _watches.clear();
    if (_ownsClient) _client.close();
  }

  /// Calls one of the session functions and unwraps what it returns.
  ///
  /// The functions answer `{"error": "..."}` rather than raising, so that
  /// a wrong code tells a child what to do and tells an outsider nothing
  /// about which codes exist.
  Future<Map<String, dynamic>> _rpc(
    String function,
    Map<String, dynamic> body,
  ) async {
    late final http.Response response;
    try {
      response = await _client.post(
        Uri.parse('$url/rest/v1/rpc/$function'),
        headers: {
          'apikey': anonKey,
          'Authorization': 'Bearer $anonKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
    } catch (_) {
      throw const ClassroomException(ClassroomError.unreachable);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ClassroomException(ClassroomError.unreachable);
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const ClassroomException(ClassroomError.unreachable);
    }
    final error = decoded['error'];
    if (error is String) throw ClassroomException(_errorOf(error));
    return decoded;
  }

  static ClassroomError _errorOf(String code) => switch (code) {
    'unknown_code' => ClassroomError.unknownCode,
    'session_over' => ClassroomError.sessionOver,
    'session_full' => ClassroomError.sessionFull,
    'empty_nickname' => ClassroomError.emptyNickname,
    'unknown_participant' => ClassroomError.unknownParticipant,
    'not_open' => ClassroomError.notOpen,
    'too_late' => ClassroomError.tooLate,
    _ => ClassroomError.unreachable,
  };
}

/// One polled room, shared by everything on this device that watches it.
///
/// It reads while somebody is listening and stops when the last of them
/// leaves — a pupil's phone in a pocket must not keep a school network
/// busy for a lesson that ended.
class _RoomWatch {
  _RoomWatch({
    required this.read,
    required this.interval,
    required this.onDone,
  }) {
    _controller = StreamController<ClassroomState>.broadcast(
      onListen: _start,
      onCancel: _stopIfIdle,
    );
  }

  final Future<ClassroomState> Function() read;
  final Duration interval;
  final void Function() onDone;

  late final StreamController<ClassroomState> _controller;
  Timer? _timer;
  String? _last;
  bool _reading = false;

  Stream<ClassroomState> get stream => _controller.stream;

  void _start() {
    _timer ??= Timer.periodic(interval, (_) => unawaited(_tick()));
    unawaited(_tick());
  }

  Future<void> _tick() async {
    // A slow answer must not queue another read behind it: a school
    // network that takes three seconds would otherwise pile up.
    if (_reading || _controller.isClosed) return;
    _reading = true;
    try {
      final state = await read();
      final encoded = jsonEncode(state.toJson());
      // Only real changes travel: the board redraws when the room moves,
      // not twice a second for nothing.
      if (encoded != _last && !_controller.isClosed) {
        _last = encoded;
        _controller.add(state);
      }
    } catch (e) {
      if (!_controller.isClosed) _controller.addError(e);
    } finally {
      _reading = false;
    }
  }

  void _stopIfIdle() {
    if (_controller.hasListener) return;
    _timer?.cancel();
    _timer = null;
    _last = null;
  }

  Future<void> close() async {
    _timer?.cancel();
    _timer = null;
    onDone();
    await _controller.close();
  }
}
