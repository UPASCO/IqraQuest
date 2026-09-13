import 'package:flutter/foundation.dart';

import '../domain/classroom_state.dart';

/// What can stop a teacher, said in terms they can act on.
enum TeacherError {
  /// The magic link has expired, or this browser was never signed in.
  notSignedIn,

  /// Signed in, but no licence is attached to this address yet.
  noLicence,
  licenceExpired,

  /// The licence already runs as many rooms at once as it paid for.
  tooManySessions,

  /// Les parties offertes sont toutes consommées : la suivante demande
  /// une licence. C'est le serveur qui compte, jamais l'appareil.
  quotaExhausted,

  /// L'adresse porte déjà un compte : on ne s'inscrit pas deux fois.
  emailTaken,

  /// Le mot de passe choisi est trop court pour Supabase (six caractères).
  weakPassword,
  noQuestions,
  unknownSession,

  /// The room is not in a state where this gesture means anything —
  /// revealing an answer nobody was asked, for instance.
  notNow,
  invalidEmail,

  /// L'adresse ou le mot de passe ne correspond à rien. Un seul cas pour
  /// les deux : dire « cette adresse existe, mais pas ce mot de passe »
  /// renseigne quiconque cherche à savoir quelles écoles sont clientes.
  badCredentials,

  /// Le service d'e-mail a refusé d'en envoyer un de plus pour l'instant.
  /// Distinct de [unreachable] : le serveur répond très bien, c'est
  /// l'envoi qui est plafonné — et un enseignant qui lit « le serveur ne
  /// répond pas » cherche au mauvais endroit.
  tooManyLinks,
  unreachable,
}

class TeacherException implements Exception {
  const TeacherException(this.error, {this.limit});

  final TeacherError error;

  /// How many rooms the licence may run at once, when that is what
  /// stopped the teacher.
  final int? limit;

  @override
  String toString() => 'TeacherException($error)';
}

/// What was bought, reduced to what the console has to know.
@immutable
class Licence {
  const Licence({
    required this.id,
    required this.email,
    required this.plan,
    required this.concurrentSessions,
    required this.expiresAt,
    this.schoolName,
    this.freeGamesUsed = 0,
    this.status = 'none',
    this.freeGames,
  });

  factory Licence.fromJson(Map<String, dynamic> json) => Licence(
    id: json['id'] as String,
    email: json['email'] as String? ?? '',
    plan: json['plan'] as String? ?? 'classe',
    concurrentSessions: (json['concurrent_sessions'] as num?)?.toInt() ?? 1,
    expiresAt:
        DateTime.tryParse('${json['expires_at']}')?.toLocal() ??
        DateTime.now(),
    schoolName: (json['school_name'] as String?)?.trim(),
    freeGamesUsed: (json['free_games_used'] as num?)?.toInt() ?? 0,
    status: json['status'] as String? ?? 'none',
  );

  final String id;
  final String email;

  /// `essai`, `classe` or `ecole` — the three the schema allows.
  final String plan;
  final int concurrentSessions;
  final DateTime expiresAt;

  /// The school as it calls itself. Absent on a licence bought by a
  /// single teacher for their own class.
  final String? schoolName;

  /// Parties ouvertes sur le quota offert, et la taille de ce quota.
  /// [freeGames] null = licence payée, sans limite.
  final int freeGamesUsed;
  final int? freeGames;

  /// Statut Stripe tel que le webhook l'a vu en dernier ; `none` sans
  /// abonnement.
  final String status;

  bool get isValid =>
      expiresAt.isAfter(DateTime.now()) &&
      status != 'unpaid' &&
      status != 'incomplete_expired';

  bool get quotaExhausted => freeGames != null && freeGamesUsed >= freeGames!;
}

/// Où en est l'abonnement d'une école.
enum AccountState {
  /// Connecté, mais rien n'a jamais été acheté sur cette adresse.
  noLicence,
  active,

  /// Les parties offertes sont consommées : il faut une licence.
  quotaExhausted,

  /// L'échéance est passée. Rien n'est perdu — l'historique reste, la
  /// console s'ouvre — mais aucune séance ne s'ouvre plus.
  expired,
}

/// Ce qui empêche, à cet instant, d'ouvrir une séance. Jugé par le
/// serveur avec les mêmes règles que l'ouverture elle-même.
enum StartBlocker { none, expired, quota, sessions }

/// L'espace client d'une école : ce qu'elle a acheté, ce qu'il lui
/// reste, et ce qui l'empêche éventuellement d'ouvrir une salle.
///
/// Tout vient du serveur, y compris [daysLeft] et l'état lui-même : une
/// échéance jugée sur l'horloge d'un navigateur se contourne en changeant
/// la date du portable.
@immutable
class Account {
  const Account({
    required this.state,
    required this.email,
    required this.planLabel,
    required this.rooms,
    required this.roomsInUse,
    required this.expiresAt,
    required this.daysLeft,
    required this.subscribed,
    this.schoolName,
    this.canStart = false,
    this.blocker = StartBlocker.none,
    this.free = false,
    this.freeGames,
    this.freeGamesUsed = 0,
    this.status = 'none',
    this.cancelAtPeriodEnd = false,
    this.hasCustomer = false,
    this.firstName,
    this.lastName,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    state: switch (json['state']) {
      'active' => AccountState.active,
      'expired' => AccountState.expired,
      'quota_exhausted' => AccountState.quotaExhausted,
      _ => AccountState.noLicence,
    },
    canStart: json['canStart'] == true,
    blocker: switch (json['blocker']) {
      'expired' => StartBlocker.expired,
      'quota' => StartBlocker.quota,
      'sessions' => StartBlocker.sessions,
      _ => StartBlocker.none,
    },
    email: json['email'] as String? ?? '',
    planLabel: json['planLabel'] as String? ?? '',
    rooms: (json['rooms'] as num?)?.toInt() ?? 1,
    roomsInUse: (json['roomsInUse'] as num?)?.toInt() ?? 0,
    expiresAt: DateTime.tryParse('${json['expiresAt']}')?.toLocal(),
    daysLeft: (json['daysLeft'] as num?)?.toInt() ?? 0,
    subscribed: json['subscribed'] == true,
    schoolName: (json['schoolName'] as String?)?.trim(),
    free: json['free'] == true,
    freeGames: (json['freeGames'] as num?)?.toInt(),
    freeGamesUsed: (json['freeGamesUsed'] as num?)?.toInt() ?? 0,
    status: json['status'] as String? ?? 'none',
    cancelAtPeriodEnd: json['cancelAtPeriodEnd'] == true,
    hasCustomer: json['hasCustomer'] == true,
    firstName: (json['firstName'] as String?)?.trim(),
    lastName: (json['lastName'] as String?)?.trim(),
  );

  final AccountState state;
  final String email;
  final String planLabel;

  /// Combien de salles l'abonnement ouvre en même temps, et combien
  /// tournent à cet instant.
  final int rooms;
  final int roomsInUse;

  final DateTime? expiresAt;
  final int daysLeft;

  /// Vrai si un abonnement Stripe est rattaché : l'échéance se
  /// prolongera d'elle-même. Faux pour une licence posée à la main ou un
  /// paiement unique — celle-là, il faudra la renouveler.
  final bool subscribed;
  final String? schoolName;

  /// Le verdict du serveur : peut-on ouvrir une séance maintenant, et
  /// sinon pourquoi. Le bouton « Lancer une partie » ne promet que ça.
  final bool canStart;
  final StartBlocker blocker;

  /// Compte découverte : [freeGames] parties offertes, [freeGamesUsed]
  /// consommées.
  final bool free;
  final int? freeGames;
  final int freeGamesUsed;
  int get freeGamesLeft =>
      freeGames == null ? 0 : (freeGames! - freeGamesUsed).clamp(0, freeGames!);

  /// Statut Stripe brut, et si le renouvellement a été annulé — la
  /// licence court alors jusqu'à l'échéance, puis s'arrête.
  final String status;
  final bool cancelAtPeriodEnd;
  bool get paymentFailed => status == 'past_due' || status == 'unpaid';

  /// Un client Stripe existe : le portail de gestion a quelqu'un à
  /// montrer.
  final bool hasCustomer;
  final String? firstName;
  final String? lastName;

  bool get locked => state == AccountState.expired;

  /// Assez proche de la fin pour qu'on le dise sans attendre. Un
  /// trimestre scolaire dure douze semaines : prévenir un mois avant
  /// laisse le temps d'un bon de commande.
  bool get endingSoon => state == AccountState.active && daysLeft <= 30;
}

/// Ce qu'une séance a laissé derrière elle.
///
/// Les prénoms ne sont là que si l'enseignant avait choisi le classement
/// individuel, et ils s'effacent au bout de quatre-vingt-dix jours
/// (migration 0003) : un rapport plus ancien garde son bilan par
/// question, et plus personne dedans.
@immutable
class SessionReport {
  const SessionReport({
    required this.id,
    required this.code,
    required this.lessonId,
    required this.playedAt,
    required this.pupils,
    required this.perQuestion,
    this.perPupil,
  });

  factory SessionReport.fromJson(Map<String, dynamic> json) => SessionReport(
    id: json['id'] as String? ?? '',
    code: json['code'] as String? ?? '',
    lessonId: json['lessonId'] as String? ?? '',
    playedAt: DateTime.tryParse('${json['playedAt']}')?.toLocal() ??
        DateTime.now(),
    pupils: (json['pupils'] as num?)?.toInt() ?? 0,
    perQuestion: [
      for (final row in (json['perQuestion'] as List? ?? const []))
        ReportQuestion.fromJson(Map<String, dynamic>.from(row as Map)),
    ],
    perPupil: json['perPupil'] == null
        ? null
        : [
            for (final row in (json['perPupil'] as List))
              ReportPupil.fromJson(Map<String, dynamic>.from(row as Map)),
          ],
  );

  final String id;
  final String code;
  final String lessonId;
  final DateTime playedAt;
  final int pupils;
  final List<ReportQuestion> perQuestion;

  /// Null quand la séance comptait par équipes, ou quand les
  /// quatre-vingt-dix jours sont passés.
  final List<ReportPupil>? perPupil;

  int get answered => perQuestion.fold(0, (n, q) => n + q.answered);
  int get correct => perQuestion.fold(0, (n, q) => n + q.correct);

  /// La part de bonnes réponses de la classe entière, entre 0 et 1.
  /// Null quand personne n'a répondu : une séance ouverte puis fermée
  /// sans élève n'a pas « 0 % de réussite », elle n'a pas de résultat.
  double? get success => answered == 0 ? null : correct / answered;

  /// Les cartes que la classe a le moins réussies, les moins bien
  /// d'abord. Une question que personne n'a vue n'en fait pas partie.
  List<ReportQuestion> get hardest {
    final seen = [for (final q in perQuestion) if (q.answered > 0) q]
      ..sort((a, b) => a.success!.compareTo(b.success!));
    return seen;
  }
}

@immutable
class ReportQuestion {
  const ReportQuestion({
    required this.index,
    required this.questionId,
    required this.correct,
    required this.answered,
  });

  factory ReportQuestion.fromJson(Map<String, dynamic> json) => ReportQuestion(
    index: (json['index'] as num?)?.toInt() ?? 0,
    questionId: json['questionId'] as String? ?? '',
    correct: (json['correct'] as num?)?.toInt() ?? 0,
    answered: (json['answered'] as num?)?.toInt() ?? 0,
  );

  final int index;
  final String questionId;
  final int correct;
  final int answered;

  double? get success => answered == 0 ? null : correct / answered;
}

@immutable
class ReportPupil {
  const ReportPupil({
    required this.nickname,
    required this.team,
    required this.correct,
  });

  factory ReportPupil.fromJson(Map<String, dynamic> json) => ReportPupil(
    nickname: json['nickname'] as String? ?? '',
    team: (json['team'] as num?)?.toInt() ?? 0,
    correct: (json['correct'] as num?)?.toInt() ?? 0,
  );

  final String nickname;
  final int team;
  final int correct;

  /// La note sur [outOf], arrondie au demi-point — ce qu'un enseignant
  /// recopie dans son cahier.
  ///
  /// Le dénominateur est le nombre de cartes de la séance, pas le nombre
  /// de réponses envoyées : un élève arrivé en retard a manqué des
  /// cartes, et sa note doit le dire plutôt que de le récompenser.
  double? mark({required int cards, int outOf = 20}) {
    if (cards <= 0) return null;
    final raw = correct / cards * outOf;
    return (raw * 2).round() / 2;
  }
}

/// Un appareil qui joue : une séance ouverte, et son dernier signe de vie.
@immutable
class ActiveSession {
  const ActiveSession({
    required this.sessionId,
    required this.code,
    required this.lessonId,
    required this.openedAt,
    required this.lastSeenAt,
    required this.alive,
    this.deviceId,
  });

  factory ActiveSession.fromJson(Map<String, dynamic> json) => ActiveSession(
    sessionId: json['sessionId'] as String? ?? '',
    code: json['code'] as String? ?? '',
    lessonId: json['lessonId'] as String? ?? '',
    deviceId: json['deviceId'] as String?,
    openedAt: DateTime.tryParse('${json['openedAt']}')?.toLocal() ??
        DateTime.now(),
    lastSeenAt: DateTime.tryParse('${json['lastSeenAt']}')?.toLocal() ??
        DateTime.now(),
    alive: json['alive'] == true,
  );

  final String sessionId;
  final String code;
  final String lessonId;
  final String? deviceId;
  final DateTime openedAt;
  final DateTime lastSeenAt;

  /// Vrai tant que l'appareil bat ; faux au-delà du bail, et la place est
  /// alors libre même si la séance n'a pas été fermée.
  final bool alive;
}

/// The three gestures that run a lesson.
enum TeacherAction { ask, reveal, close }

/// The teacher's side of a classroom: sign in, open a room, set the pace.
///
/// It is deliberately separate from [ClassroomGateway]: a pupil's device
/// can do none of this, and the console is the only thing that holds a
/// signed-in identity anywhere in IqraQuest.
abstract class TeacherGateway {
  /// La porte de tous les jours : une adresse, un mot de passe.
  ///
  /// Aucun e-mail n'intervient — c'est le point. Un enseignant devant sa
  /// classe ne doit dépendre ni d'une boîte de réception, ni d'un
  /// service d'envoi, ni du filtre anti-spam de son établissement.
  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

  /// Le lien de connexion, qui reste la porte de secours : c'est par lui
  /// qu'on retrouve un mot de passe oublié. Il demande, lui, un service
  /// d'e-mail qui fonctionne.
  Future<void> sendMagicLink(String email);

  /// Créer un compte. Gratuit, et il donne cinq parties. Rend vrai si
  /// une confirmation par e-mail est attendue avant de pouvoir entrer.
  Future<bool> signUp({required String email, required String password});

  /// Changer son mot de passe — le geste qui suit un lien de secours.
  Future<void> updatePassword(String newPassword);

  /// Signe de vie d'une séance ouverte, toutes les soixante secondes.
  Future<void> heartbeat(String sessionId);

  /// Les appareils qui jouent sur cette licence.
  Future<List<ActiveSession>> sessions();

  /// Supprimer le compte : profil, licence, séances et bilans. Les
  /// factures restent chez Stripe.
  Future<void> deleteAccount();

  /// L'adresse de paiement Stripe pour cette licence, créée par le
  /// serveur — le prix vit là-bas. Null si le paiement en ligne n'est pas
  /// configuré.
  Future<Uri?> checkoutUrl();

  /// Le portail Stripe où l'école gère son abonnement : moyen de
  /// paiement, factures, résiliation. Null sans client Stripe.
  Future<Uri?> portalUrl();

  /// Picks up a session: the tokens a magic link just dropped in the
  /// address bar, or the ones this browser already kept. Returns whether
  /// a teacher is signed in afterwards.
  ///
  /// [fragment] is what the address bar carries, passed in rather than
  /// read here so the whole flow can be tested without a browser.
  Future<bool> restore({String? fragment});

  bool get isSignedIn;

  /// The signed-in address, for the console to show whose licence this is.
  String? get email;

  /// The licence attached to the signed-in address, claiming it on the
  /// first sign-in after a purchase. Null when nothing was bought.
  Future<Licence?> licence();

  /// L'abonnement tel que l'école le lit : palier, salles, échéance,
  /// jours restants. Le serveur en est seul juge.
  Future<Account> account();

  /// Les séances passées, la plus récente d'abord.
  Future<List<SessionReport>> reports({int limit});

  Future<({String sessionId, String code})> openSession({
    required String lessonId,
    required List<String> questionIds,
    int teamCount,
    String boardLanguage,
    int secondsPerQuestion,
    bool keepIndividualScores,
    ClassroomScoring scoring,

    /// Clé de rejeu : la même demande renvoyée deux fois rend la même
    /// séance et ne consomme qu'un crédit.
    String? requestId,
    String? deviceId,
  });

  Future<void> advance(String sessionId, TeacherAction action);

  Future<void> signOut();
}
