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
  noQuestions,
  unknownSession,

  /// The room is not in a state where this gesture means anything —
  /// revealing an answer nobody was asked, for instance.
  notNow,
  invalidEmail,

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

  bool get isValid => expiresAt.isAfter(DateTime.now());
}

/// Où en est l'abonnement d'une école.
enum AccountState {
  /// Connecté, mais rien n'a jamais été acheté sur cette adresse.
  noLicence,
  active,

  /// L'échéance est passée. Rien n'est perdu — l'historique reste, la
  /// console s'ouvre — mais aucune séance ne s'ouvre plus.
  expired,
}

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
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    state: switch (json['state']) {
      'active' => AccountState.active,
      'expired' => AccountState.expired,
      _ => AccountState.noLicence,
    },
    email: json['email'] as String? ?? '',
    planLabel: json['planLabel'] as String? ?? '',
    rooms: (json['rooms'] as num?)?.toInt() ?? 1,
    roomsInUse: (json['roomsInUse'] as num?)?.toInt() ?? 0,
    expiresAt: DateTime.tryParse('${json['expiresAt']}')?.toLocal(),
    daysLeft: (json['daysLeft'] as num?)?.toInt() ?? 0,
    subscribed: json['subscribed'] == true,
    schoolName: (json['schoolName'] as String?)?.trim(),
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

  bool get locked => state != AccountState.active;

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

/// The three gestures that run a lesson.
enum TeacherAction { ask, reveal, close }

/// The teacher's side of a classroom: sign in, open a room, set the pace.
///
/// It is deliberately separate from [ClassroomGateway]: a pupil's device
/// can do none of this, and the console is the only thing that holds a
/// signed-in identity anywhere in IqraQuest.
abstract class TeacherGateway {
  /// Sends the sign-in link. There is no password anywhere in this
  /// system — the address that paid is the address that gets in.
  Future<void> sendMagicLink(String email);

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
  });

  Future<void> advance(String sessionId, TeacherAction action);

  Future<void> signOut();
}
