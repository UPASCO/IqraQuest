import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/teacher_gateway.dart';
import '../domain/classroom_state.dart';
import '../domain/lesson.dart';

/// Where the console is in a teacher's afternoon.
enum ConsoleStage {
  /// Still working out whether this browser is signed in.
  loading,

  /// Nobody is signed in: the address field.
  signedOut,

  /// The link has been sent and is waiting in an inbox.
  linkSent,

  /// Signed in, but nothing was bought on this address.
  noLicence,

  /// L'inscription est faite ; la confirmation par e-mail est attendue.
  awaitingConfirmation,

  /// Les cinq parties offertes sont consommées. L'espace reste ouvert —
  /// historique, abonnement — mais la prochaine séance demande une
  /// licence.
  quotaExhausted,

  /// L'abonnement est fini. Distinct de [noLicence], et il faut que ça
  /// le reste : une école qui a payé l'an dernier n'a pas à lire
  /// « aucune licence » comme si elle n'avait jamais rien acheté. Elle
  /// voit son espace, son historique, et de quoi renouveler.
  expired,

  /// Signed in with a licence: pick a lesson and open a room.
  ready,

  /// A room is open, and this console sets its pace.
  running,
}

@immutable
class ConsoleState {
  const ConsoleState({
    this.stage = ConsoleStage.loading,
    this.email,
    this.licence,
    this.account,
    this.reports,
    this.activeSessions,
    this.sessionId,
    this.code,
    this.error,
    this.errorLimit,
    this.busy = false,
    this.linkType,
  });

  final ConsoleStage stage;
  final String? email;
  final Licence? licence;

  /// L'abonnement tel que le serveur le voit. Null tant qu'on ne l'a pas
  /// demandé.
  final Account? account;

  /// Les séances passées. Null tant que l'enseignant n'a pas ouvert
  /// l'historique — on ne va pas chercher un an de bilans pour afficher
  /// un bouton.
  final List<SessionReport>? reports;

  /// Les appareils qui jouent, quand l'enseignant les a demandés.
  final List<ActiveSession>? activeSessions;

  /// The open room, once there is one.
  final String? sessionId;
  final String? code;

  final TeacherError? error;

  /// How many rooms the licence may run at once, when that is the error.
  final int? errorLimit;

  /// A call is in flight: the buttons wait rather than firing twice.
  final bool busy;

  /// `recovery` ou `magiclink` quand la visite a commencé par un lien de
  /// courrier : l'école est entrée sans mot de passe, et la console lui
  /// en propose un.
  final String? linkType;

  ConsoleState copyWith({
    ConsoleStage? stage,
    Object? email = _unset,
    Object? licence = _unset,
    Object? account = _unset,
    Object? reports = _unset,
    Object? activeSessions = _unset,
    Object? sessionId = _unset,
    Object? code = _unset,
    Object? error = _unset,
    Object? errorLimit = _unset,
    bool? busy,
    Object? linkType = _unset,
  }) => ConsoleState(
    stage: stage ?? this.stage,
    email: identical(email, _unset) ? this.email : email as String?,
    licence: identical(licence, _unset) ? this.licence : licence as Licence?,
    account: identical(account, _unset) ? this.account : account as Account?,
    reports: identical(reports, _unset)
        ? this.reports
        : reports as List<SessionReport>?,
    activeSessions: identical(activeSessions, _unset)
        ? this.activeSessions
        : activeSessions as List<ActiveSession>?,
    sessionId: identical(sessionId, _unset)
        ? this.sessionId
        : sessionId as String?,
    code: identical(code, _unset) ? this.code : code as String?,
    error: identical(error, _unset) ? this.error : error as TeacherError?,
    errorLimit: identical(errorLimit, _unset)
        ? this.errorLimit
        : errorLimit as int?,
    busy: busy ?? this.busy,
    linkType: identical(linkType, _unset) ? this.linkType : linkType as String?,
  );
}

const Object _unset = Object();

/// The teacher's half of a classroom session: sign in, open a room, and
/// set the pace of the lesson.
///
/// Everything here is one gesture at a time, and every one of them can
/// fail on a school network — so each says what happened rather than
/// leaving a teacher pressing a button in front of a class.
class TeacherConsoleController extends StateNotifier<ConsoleState> {
  TeacherConsoleController(
    this.gateway, {
    String? deviceId,
    Random? random,
    this.heartbeatEvery = const Duration(seconds: 60),
    this.checkoutPollEvery = const Duration(seconds: 2),
  }) : _random = random ?? Random.secure(),
       deviceId = deviceId ?? _newId(random ?? Random.secure()),
       super(const ConsoleState());

  final TeacherGateway gateway;
  final Random _random;

  /// Cet appareil, aux yeux de la licence. Un identifiant opaque, jamais
  /// un nom de machine.
  final String deviceId;

  /// Le battement de vie d'une séance ouverte : le serveur libère la place
  /// d'un appareil qu'il n'a plus entendu depuis cinq minutes, et c'est
  /// ce battement qui dit « je suis encore là ».
  final Duration heartbeatEvery;
  Timer? _heartbeat;

  /// Au retour de la caisse Stripe, le webhook qui active la licence peut
  /// arriver quelques secondes après le navigateur. Plutôt que d'afficher
  /// « cinq parties utilisées » à quelqu'un qui vient de payer, la console
  /// redemande son compte à ce rythme, quelques fois, jusqu'à le voir
  /// actif.
  final Duration checkoutPollEvery;
  static const int checkoutPolls = 5;

  static String _newId(Random random) => List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();

  /// Une clé de rejeu au format UUID v4, pour que la même ouverture
  /// renvoyée deux fois par le réseau ne consomme qu'un crédit.
  String _newRequestId() {
    final b = List<int>.generate(16, (_) => _random.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }

  @override
  void dispose() {
    _heartbeat?.cancel();
    super.dispose();
  }

  /// Picks up the tokens a magic link just delivered, or the ones this
  /// browser kept, and asks what licence they carry.
  ///
  /// [afterCheckout] is set when the page was reached through Stripe's
  /// success URL: the licence is then re-read a few times, because the
  /// webhook that activates it may land after the redirect.
  Future<void> start({String? fragment, bool afterCheckout = false}) async {
    try {
      final signedIn = await gateway.restore(fragment: fragment);
      if (!signedIn) {
        state = state.copyWith(stage: ConsoleStage.signedOut);
        return;
      }
      state = state.copyWith(
        email: gateway.email,
        linkType: gateway.lastLinkType,
      );
      await refreshLicence();
      if (afterCheckout) await _awaitActivation();
    } on TeacherException catch (e) {
      state = state.copyWith(stage: ConsoleStage.signedOut, error: e.error);
    } catch (_) {
      state = state.copyWith(
        stage: ConsoleStage.signedOut,
        error: TeacherError.unreachable,
      );
    }
  }

  /// La connexion de tous les jours : une adresse, un mot de passe, et
  /// rien qui dépende d'une boîte de réception.
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(busy: true, error: null);
    try {
      await gateway.signInWithPassword(email: email, password: password);
      state = state.copyWith(email: gateway.email ?? email.trim());
      await refreshLicence();
    } on TeacherException catch (e) {
      // Adresse pas encore confirmée : on mène à l'écran qui sait
      // renvoyer le courrier, plutôt qu'à un message rouge.
      if (e.error == TeacherError.emailNotConfirmed) {
        state = state.copyWith(
          stage: ConsoleStage.awaitingConfirmation,
          email: email.trim(),
          error: e.error,
          busy: false,
        );
        return;
      }
      state = state.copyWith(error: e.error, busy: false);
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
  }

  Future<void> sendLink(String email) async {
    state = state.copyWith(busy: true, error: null);
    try {
      await gateway.sendMagicLink(email);
      state = state.copyWith(
        stage: ConsoleStage.linkSent,
        email: email.trim(),
        busy: false,
      );
    } on TeacherException catch (e) {
      state = state.copyWith(error: e.error, busy: false);
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
  }

  /// Va chercher les séances passées, une fois, à la demande.
  Future<void> loadReports() async {
    state = state.copyWith(busy: true, error: null);
    try {
      final reports = await gateway.reports(limit: 50);
      state = state.copyWith(reports: reports, busy: false);
    } on TeacherException catch (e) {
      state = state.copyWith(error: e.error, busy: false);
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
  }

  /// Redemande le compte jusqu'à ce que l'abonnement soit actif, ou que
  /// la patience soit épuisée. Le dernier état lu reste affiché : si le
  /// webhook n'est jamais arrivé, l'école voit son compte tel qu'il est,
  /// et « Actualiser » reste à portée de main.
  Future<void> _awaitActivation() async {
    for (var i = 0; i < checkoutPolls; i++) {
      final account = state.account;
      if (account != null && account.subscribed && !account.free) return;
      await Future<void>.delayed(checkoutPollEvery);
      if (!mounted) return;
      await refreshLicence();
    }
  }

  /// Asks again what this address is entitled to — the button a teacher
  /// presses on coming back from the payment page.
  Future<void> refreshLicence() async {
    state = state.copyWith(busy: true, error: null);
    try {
      final licence = await gateway.licence();
      final account = await gateway.account();
      // Trois issues, pas deux. « Rien acheté » et « abonnement fini »
      // se ressemblaient dans le code et ne se ressemblent pas du tout
      // pour l'école : l'une doit lire une offre, l'autre un
      // renouvellement — et garder son historique sous les yeux.
      state = state.copyWith(
        stage: switch (account.state) {
          AccountState.active => ConsoleStage.ready,
          AccountState.quotaExhausted => ConsoleStage.quotaExhausted,
          AccountState.expired => ConsoleStage.expired,
          AccountState.noLicence => ConsoleStage.noLicence,
        },
        licence: licence,
        account: account,
        email: gateway.email ?? state.email,
        busy: false,
      );
    } on TeacherException catch (e) {
      state = state.copyWith(
        stage: e.error == TeacherError.notSignedIn
            ? ConsoleStage.signedOut
            : state.stage,
        error: e.error,
        busy: false,
      );
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
  }

  /// Opens the room for one lesson.
  ///
  /// [cardCount] cuts the lesson short for a half-period; [shuffle]
  /// draws the cards in a fresh order, so the same class playing the
  /// same lesson next week does not answer from memory of the order.
  /// Both are decided here rather than on the server: the room only
  /// ever receives a list of card ids.
  Future<void> openSession({
    required Lesson lesson,
    int teamCount = 3,
    String boardLanguage = 'fr',
    int secondsPerQuestion = 0,
    bool keepIndividualScores = false,
    ClassroomScoring scoring = ClassroomScoring.teams,
    int? cardCount,
    bool shuffle = false,
    Random? random,
  }) async {
    state = state.copyWith(busy: true, error: null);
    try {
      final cards = [...lesson.questionIds];
      if (shuffle) cards.shuffle(random ?? Random());
      final chosen = cardCount == null || cardCount >= cards.length
          ? cards
          : cards.take(cardCount).toList();
      final opened = await gateway.openSession(
        lessonId: lesson.id,
        questionIds: chosen,
        teamCount: teamCount,
        boardLanguage: boardLanguage,
        secondsPerQuestion: secondsPerQuestion,
        keepIndividualScores: keepIndividualScores,
        scoring: scoring,
        requestId: _newRequestId(),
        deviceId: deviceId,
      );
      state = state.copyWith(
        stage: ConsoleStage.running,
        sessionId: opened.sessionId,
        code: opened.code,
        busy: false,
      );
      _startHeartbeat(opened.sessionId);
    } on TeacherException catch (e) {
      state = state.copyWith(error: e.error, errorLimit: e.limit, busy: false);
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
  }

  Future<void> ask() => _advance(TeacherAction.ask);

  Future<void> reveal() => _advance(TeacherAction.reveal);

  /// Ends the lesson: the report is written and the children's names go
  /// with the session. The console lands back on the lesson list.
  Future<void> endSession() async {
    _heartbeat?.cancel();
    await _advance(TeacherAction.close);
    if (state.error != null) return;
    state = state.copyWith(sessionId: null, code: null);
    // Le quota a pu tomber à zéro avec cette séance : on redemande au
    // serveur où l'on en est plutôt que de le deviner.
    await refreshLicence();
  }

  void _startHeartbeat(String sessionId) {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(heartbeatEvery, (_) async {
      if (state.sessionId != sessionId) return;
      try {
        await gateway.heartbeat(sessionId);
      } catch (_) {
        // Une coupure réseau courte ne doit pas casser la séance : le
        // prochain battement reprendra, et le bail tient cinq minutes.
      }
    });
  }

  /// Un battement envoyé à la main — ce que fait un test, ou un retour
  /// de veille de l'appareil.
  Future<void> heartbeatNow() async {
    final id = state.sessionId;
    if (id == null) return;
    try {
      await gateway.heartbeat(id);
    } catch (_) {}
  }

  /// Créer un compte. Selon le réglage du serveur, l'enseignant est entré
  /// tout de suite ou attend un e-mail de confirmation.
  Future<void> signUp(
    String email,
    String password, {
    String? schoolName,
  }) async {
    state = state.copyWith(busy: true, error: null);
    try {
      final needsConfirmation = await gateway.signUp(
        email: email,
        password: password,
        schoolName: schoolName,
      );
      if (needsConfirmation) {
        state = state.copyWith(
          stage: ConsoleStage.awaitingConfirmation,
          email: email.trim(),
          busy: false,
        );
        return;
      }
      state = state.copyWith(email: gateway.email ?? email.trim());
      await refreshLicence();
    } on TeacherException catch (e) {
      state = state.copyWith(error: e.error, busy: false);
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
  }

  /// Le courrier de confirmation, une seconde fois.
  Future<void> resendConfirmation() async {
    final email = state.email;
    if (email == null) return;
    state = state.copyWith(busy: true, error: null);
    try {
      await gateway.resendConfirmation(email);
      state = state.copyWith(busy: false);
    } on TeacherException catch (e) {
      state = state.copyWith(error: e.error, busy: false);
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
  }

  /// Le lien a été lu, le mot de passe est posé : la mention s'efface.
  void clearLinkType() => state = state.copyWith(linkType: null);

  Future<bool> updatePassword(String newPassword) async {
    state = state.copyWith(busy: true, error: null);
    try {
      await gateway.updatePassword(newPassword);
      state = state.copyWith(busy: false);
      return true;
    } on TeacherException catch (e) {
      state = state.copyWith(error: e.error, busy: false);
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
    return false;
  }

  /// Les appareils qui jouent sur la licence, à la demande.
  Future<void> loadSessions() async {
    state = state.copyWith(busy: true, error: null);
    try {
      final sessions = await gateway.sessions();
      state = state.copyWith(activeSessions: sessions, busy: false);
    } on TeacherException catch (e) {
      state = state.copyWith(error: e.error, busy: false);
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
  }

  /// Fermer la séance d'un autre appareil — libérer une place quand la
  /// limite est atteinte.
  Future<void> revokeSession(String sessionId) async {
    state = state.copyWith(busy: true, error: null);
    try {
      await gateway.advance(sessionId, TeacherAction.close);
      final sessions = await gateway.sessions();
      final account = await gateway.account();
      state = state.copyWith(
        activeSessions: sessions,
        account: account,
        busy: false,
      );
    } on TeacherException catch (e) {
      state = state.copyWith(error: e.error, busy: false);
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
  }

  /// L'adresse de paiement, fabriquée par le serveur. Null si le paiement
  /// en ligne n'est pas ouvert.
  Future<Uri?> checkoutUrl() async {
    try {
      return await gateway.checkoutUrl();
    } on TeacherException catch (e) {
      state = state.copyWith(error: e.error);
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable);
    }
    return null;
  }

  Future<Uri?> portalUrl() async {
    try {
      return await gateway.portalUrl();
    } on TeacherException catch (e) {
      state = state.copyWith(error: e.error);
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable);
    }
    return null;
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(busy: true, error: null);
    try {
      _heartbeat?.cancel();
      await gateway.deleteAccount();
      state = const ConsoleState(stage: ConsoleStage.signedOut);
    } on TeacherException catch (e) {
      state = state.copyWith(error: e.error, busy: false);
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
  }

  Future<void> _advance(TeacherAction action) async {
    final sessionId = state.sessionId;
    if (sessionId == null) return;
    state = state.copyWith(busy: true, error: null);
    try {
      await gateway.advance(sessionId, action);
      state = state.copyWith(busy: false);
    } on TeacherException catch (e) {
      state = state.copyWith(error: e.error, busy: false);
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
  }

  Future<void> signOut() async {
    _heartbeat?.cancel();
    await gateway.signOut();
    state = const ConsoleState(stage: ConsoleStage.signedOut);
  }

  void clearError() => state = state.copyWith(error: null, errorLimit: null);
}

/// The console's line to the server. Overridden in `main()`; left as the
/// in-memory fake when no Supabase project is configured, so the console
/// can be walked end to end without one.
final teacherGatewayProvider = Provider<TeacherGateway>(
  (ref) => throw UnimplementedError('Override in main()'),
);

final teacherConsoleProvider =
    StateNotifierProvider<TeacherConsoleController, ConsoleState>(
      (ref) => TeacherConsoleController(ref.watch(teacherGatewayProvider)),
    );
