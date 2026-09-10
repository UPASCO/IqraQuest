import '../domain/classroom_state.dart';
import 'teacher_gateway.dart';
import 'fake_classroom_gateway.dart';

/// A teacher's console with no server behind it.
///
/// It drives the same in-memory room the pupils' fake talks to, so the
/// whole lesson — sign in, open, ask, reveal, close — can be played and
/// tested end to end without a Supabase project, and demonstrated in a
/// build that has none.
class FakeTeacherGateway implements TeacherGateway {
  FakeTeacherGateway({
    required this.room,
    Licence? licence,
    String? signedInAs,
    this.signInOnSend = false,
  }) {
    _licence = licence;
    _email = signedInAs?.trim();
  }

  final FakeClassroomGateway room;

  /// Whether sending a link signs the teacher straight in. True in a
  /// serverless build, false in tests that walk the inbox step.
  final bool signInOnSend;

  Licence? _licence;
  String? _email;

  /// Every address a link was sent to, in order — what a test reads to
  /// know the console did send one.
  final List<String> linksSent = [];

  /// The rooms this console opened, by session id.
  final Map<String, String> codeOf = {};

  @override
  bool get isSignedIn => _email != null;

  @override
  String? get email => _email;

  /// Stands in for the teacher clicking the link in their inbox.
  void completeSignIn(String address) => _email = address.trim();

  /// Stands in for Stripe creating the licence on the paying address.
  void grant(Licence licence) => _licence = licence;

  /// There is no inbox in a room with no server, so sending the link
  /// also signs the teacher in: a build with no Supabase project can be
  /// walked from end to end, and a build with one never uses this class.
  @override
  Future<void> sendMagicLink(String address) async {
    final clean = address.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s.]+\.[^@\s]+$').hasMatch(clean)) {
      throw const TeacherException(TeacherError.invalidEmail);
    }
    linksSent.add(clean);
    if (signInOnSend) completeSignIn(clean);
  }

  /// Les mots de passe que cette salle connaît, par adresse. Vide par
  /// défaut : un test qui veut la connexion par mot de passe le dit.
  final Map<String, String> passwords = {};

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final clean = email.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s.]+\.[^@\s]+$').hasMatch(clean)) {
      throw const TeacherException(TeacherError.invalidEmail);
    }
    if (passwords[clean.toLowerCase()] != password) {
      throw const TeacherException(TeacherError.badCredentials);
    }
    completeSignIn(clean);
  }

  @override
  Future<bool> restore({String? fragment}) async => isSignedIn;

  @override
  Future<Licence?> licence() async {
    if (!isSignedIn) throw const TeacherException(TeacherError.notSignedIn);
    return _licence;
  }

  @override
  Future<Account> account() async {
    if (!isSignedIn) throw const TeacherException(TeacherError.notSignedIn);
    final l = _licence;
    if (l == null) {
      return const Account(
        state: AccountState.noLicence,
        email: '',
        planLabel: '',
        rooms: 0,
        roomsInUse: 0,
        expiresAt: null,
        daysLeft: 0,
        subscribed: false,
      );
    }
    final left = l.expiresAt.difference(DateTime.now());
    return Account(
      state: l.isValid ? AccountState.active : AccountState.expired,
      email: l.email,
      planLabel: l.plan,
      rooms: l.concurrentSessions,
      roomsInUse: codeOf.length,
      expiresAt: l.expiresAt,
      daysLeft: left.isNegative ? 0 : (left.inSeconds / 86400).ceil(),
      subscribed: false,
      schoolName: l.schoolName,
    );
  }

  @override
  Future<List<SessionReport>> reports({int limit = 50}) async {
    if (!isSignedIn) throw const TeacherException(TeacherError.notSignedIn);
    if (_licence == null) throw const TeacherException(TeacherError.noLicence);
    return room.reports.take(limit).toList();
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
    if (!isSignedIn) throw const TeacherException(TeacherError.notSignedIn);
    final licence = _licence;
    if (licence == null) throw const TeacherException(TeacherError.noLicence);
    if (!licence.isValid) {
      throw const TeacherException(TeacherError.licenceExpired);
    }
    if (questionIds.isEmpty) {
      throw const TeacherException(TeacherError.noQuestions);
    }
    if (codeOf.length >= licence.concurrentSessions) {
      throw TeacherException(
        TeacherError.tooManySessions,
        limit: licence.concurrentSessions,
      );
    }

    final code = room.openSession(
      lessonId: lessonId,
      questionIds: questionIds,
      teamCount: teamCount,
      boardLanguage: boardLanguage,
      secondsPerQuestion: secondsPerQuestion,
      scoring: scoring,
    );
    final sessionId = 's_${codeOf.length}_$code';
    codeOf[sessionId] = code;
    return (sessionId: sessionId, code: code);
  }

  @override
  Future<void> advance(String sessionId, TeacherAction action) async {
    final code = codeOf[sessionId];
    if (code == null) {
      throw const TeacherException(TeacherError.unknownSession);
    }
    switch (action) {
      case TeacherAction.ask:
        room.ask(code);
      case TeacherAction.reveal:
        room.reveal(code);
      case TeacherAction.close:
        room.close(code);
        codeOf.remove(sessionId);
    }
  }

  @override
  Future<void> signOut() async {
    _email = null;
    codeOf.clear();
  }
}
