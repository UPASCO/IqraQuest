import 'package:flutter/foundation.dart';

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
  });

  factory Licence.fromJson(Map<String, dynamic> json) => Licence(
    id: json['id'] as String,
    email: json['email'] as String? ?? '',
    plan: json['plan'] as String? ?? 'classe',
    concurrentSessions: (json['concurrent_sessions'] as num?)?.toInt() ?? 1,
    expiresAt:
        DateTime.tryParse('${json['expires_at']}')?.toLocal() ??
        DateTime.now(),
  );

  final String id;
  final String email;

  /// `essai`, `classe` or `ecole` — the three the schema allows.
  final String plan;
  final int concurrentSessions;
  final DateTime expiresAt;

  bool get isValid => expiresAt.isAfter(DateTime.now());
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

  Future<({String sessionId, String code})> openSession({
    required String lessonId,
    required List<String> questionIds,
    int teamCount,
    String boardLanguage,
    int secondsPerQuestion,
    bool keepIndividualScores,
  });

  Future<void> advance(String sessionId, TeacherAction action);

  Future<void> signOut();
}
