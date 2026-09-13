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
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now {
    _licence = licence;
    _email = signedInAs?.trim();
  }

  /// Combien d'appareils jouent à cet instant — ceux dont le bail court.
  int get aliveSessions =>
      lastSeen.values.where((t) => _now().difference(t) < lease).length;

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

  /// Le dernier signe de vie de chaque séance ouverte, et le bail au-delà
  /// duquel une place se libère — les mêmes cinq minutes que le SQL.
  final Map<String, DateTime> lastSeen = {};
  static const Duration lease = Duration(minutes: 5);
  final DateTime Function() _now;

  /// La même demande rejouée rend la même séance : clé de rejeu → id.
  final Map<String, String> _byRequest = {};

  /// Les comptes créés par inscription, adresse → confirmé ?
  final Map<String, bool> signedUp = {};

  /// Ce que le serveur enregistre au fil des gestes, pour qu'un test
  /// puisse relire ce qui a été demandé à Stripe.
  int checkoutsCreated = 0;
  int portalsCreated = 0;
  bool deleted = false;

  /// L'abonnement a été résilié au moment de la suppression.
  bool subscriptionCancelled = false;

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
    // Un compte inscrit mais non confirmé n'entre pas : c'est ce que
    // GoTrue fait, et ce que my_licence() exige — en le disant.
    if (signedUp[clean.toLowerCase()] == false) {
      throw const TeacherException(TeacherError.emailNotConfirmed);
    }
    completeSignIn(clean);
  }

  /// Les courriers de confirmation renvoyés.
  final List<String> resent = [];

  @override
  Future<void> resendConfirmation(String email) async {
    resent.add(email.trim());
  }

  /// Ce qu'un test veut simuler comme début de visite.
  String? linkType;

  @override
  String? get lastLinkType => linkType;

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    String? schoolName,
  }) async {
    final clean = email.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s.]+\.[^@\s]+$').hasMatch(clean)) {
      throw const TeacherException(TeacherError.invalidEmail);
    }
    if (password.length < 6) {
      throw const TeacherException(TeacherError.weakPassword);
    }
    final key = clean.toLowerCase();
    if (passwords.containsKey(key) || signedUp.containsKey(key)) {
      throw const TeacherException(TeacherError.emailTaken);
    }
    passwords[key] = password;
    signedUp[key] = false;
    // Le serveur donne ses cinq parties au compte neuf — sauf si une
    // licence existe déjà à cette adresse (l'école a payé avant).
    _licence ??= Licence(
      id: 'l_$key',
      email: clean,
      plan: 'decouverte',
      concurrentSessions: 2,
      expiresAt: _now().add(const Duration(days: 36500)),
      freeGames: 5,
      schoolName: schoolName?.trim(),
    );
    return true;
  }

  /// Ce que ferait le clic sur le lien de confirmation.
  void confirm(String email) => signedUp[email.trim().toLowerCase()] = true;

  @override
  Future<void> updatePassword(String newPassword) async {
    if (!isSignedIn) throw const TeacherException(TeacherError.notSignedIn);
    if (newPassword.length < 6) {
      throw const TeacherException(TeacherError.weakPassword);
    }
    passwords[_email!.toLowerCase()] = newPassword;
  }

  @override
  Future<void> heartbeat(String sessionId) async {
    if (!isSignedIn) throw const TeacherException(TeacherError.notSignedIn);
    if (!codeOf.containsKey(sessionId)) {
      throw const TeacherException(TeacherError.unknownSession);
    }
    lastSeen[sessionId] = _now();
  }

  @override
  Future<List<ActiveSession>> sessions() async {
    if (!isSignedIn) throw const TeacherException(TeacherError.notSignedIn);
    return [
      for (final e in codeOf.entries)
        ActiveSession(
          sessionId: e.key,
          code: e.value,
          lessonId: '',
          openedAt: lastSeen[e.key] ?? _now(),
          lastSeenAt: lastSeen[e.key] ?? _now(),
          alive: _now().difference(lastSeen[e.key] ?? _now()) < lease,
        ),
    ];
  }

  @override
  Future<void> deleteAccount() async {
    if (!isSignedIn) throw const TeacherException(TeacherError.notSignedIn);
    // La fonction Edge résilie d'abord chez Stripe ; ici, on le note.
    if (_licence != null && _licence!.status != 'none') {
      subscriptionCancelled = true;
    }
    deleted = true;
    _licence = null;
    codeOf.clear();
    lastSeen.clear();
    await signOut();
  }

  @override
  Future<Uri?> checkoutUrl() async {
    if (!isSignedIn) throw const TeacherException(TeacherError.notSignedIn);
    checkoutsCreated += 1;
    return Uri.parse('https://checkout.stripe.test/session/$checkoutsCreated');
  }

  @override
  Future<Uri?> portalUrl() async {
    if (!isSignedIn) throw const TeacherException(TeacherError.notSignedIn);
    if (_licence?.status == 'none') return null;
    portalsCreated += 1;
    return Uri.parse('https://billing.stripe.test/portal/$portalsCreated');
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
    final left = l.expiresAt.difference(_now());
    final blocker = !l.isValid
        ? StartBlocker.expired
        : l.quotaExhausted
        ? StartBlocker.quota
        : aliveSessions >= l.concurrentSessions
        ? StartBlocker.sessions
        : StartBlocker.none;
    return Account(
      state: !l.isValid
          ? AccountState.expired
          : l.quotaExhausted
          ? AccountState.quotaExhausted
          : AccountState.active,
      canStart: blocker == StartBlocker.none,
      blocker: blocker,
      email: l.email,
      planLabel: l.plan,
      rooms: l.concurrentSessions,
      roomsInUse: aliveSessions,
      expiresAt: l.expiresAt,
      daysLeft: left.isNegative ? 0 : (left.inSeconds / 86400).ceil(),
      subscribed: l.status != 'none',
      status: l.status,
      free: l.freeGames != null,
      freeGames: l.freeGames,
      freeGamesUsed: l.freeGamesUsed,
      hasCustomer: l.status != 'none',
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
    String? requestId,
    String? deviceId,
  }) async {
    if (!isSignedIn) throw const TeacherException(TeacherError.notSignedIn);
    final licence = _licence;
    if (licence == null) throw const TeacherException(TeacherError.noLicence);
    // Même ordre que open_session en SQL : rejeu, échéance, quota, bail.
    if (requestId != null && _byRequest.containsKey(requestId)) {
      final id = _byRequest[requestId]!;
      return (sessionId: id, code: codeOf[id]!);
    }
    if (!licence.isValid) {
      throw const TeacherException(TeacherError.licenceExpired);
    }
    if (licence.quotaExhausted) {
      throw TeacherException(
        TeacherError.quotaExhausted,
        limit: licence.freeGames,
      );
    }
    if (aliveSessions >= licence.concurrentSessions) {
      throw TeacherException(
        TeacherError.tooManySessions,
        limit: licence.concurrentSessions,
      );
    }
    if (questionIds.isEmpty) {
      throw const TeacherException(TeacherError.noQuestions);
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
    lastSeen[sessionId] = _now();
    if (requestId != null) _byRequest[requestId] = sessionId;
    if (licence.freeGames != null) {
      _licence = Licence(
        id: licence.id,
        email: licence.email,
        plan: licence.plan,
        concurrentSessions: licence.concurrentSessions,
        expiresAt: licence.expiresAt,
        schoolName: licence.schoolName,
        freeGames: licence.freeGames,
        freeGamesUsed: licence.freeGamesUsed + 1,
        status: licence.status,
      );
    }
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
        lastSeen.remove(sessionId);
    }
  }

  @override
  Future<void> signOut() async {
    _email = null;
    codeOf.clear();
    lastSeen.clear();
  }
}
