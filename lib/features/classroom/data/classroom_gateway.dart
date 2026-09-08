import '../domain/classroom_state.dart';

/// Why a classroom call did not go through.
///
/// Every one of these is something a child or a teacher can be told in
/// one sentence, because every one of them will happen in a real room:
/// a code copied wrong off the board, a wifi that dropped during the
/// answer, a session the teacher already closed.
enum ClassroomError {
  /// No open session under that code. Also what a made-up code gets:
  /// the server never says whether some other code would have worked.
  unknownCode,

  /// The session ended while this device was away.
  sessionOver,

  /// The room is full — a code that travelled further than the room.
  sessionFull,

  emptyNickname,

  /// This device's seat is not in this session any more; it must join
  /// again.
  unknownParticipant,

  /// Nothing is open to answer: the question was revealed, or the class
  /// has moved on.
  notOpen,

  /// The timer ran out before the answer arrived.
  tooLate,

  /// The network, or a server that answered something unexpected.
  unreachable,
}

class ClassroomException implements Exception {
  const ClassroomException(this.error, [this.detail]);

  final ClassroomError error;
  final String? detail;

  @override
  String toString() =>
      'ClassroomException(${error.name}${detail == null ? '' : ': $detail'})';
}

/// What a pupil's device learns from answering: whether it was right,
/// which the board will not say out loud.
class ClassroomAnswerOutcome {
  const ClassroomAnswerOutcome({required this.correct});

  final bool correct;
}

/// The three things a pupil's device may ask of the classroom, and
/// nothing else.
///
/// The real implementation talks to Supabase; [FakeClassroomGateway]
/// plays the same rules in memory, which is what the screens and their
/// tests run against. Keeping the surface this narrow is deliberate: it
/// is the entire attack surface of the only server IqraQuest has.
abstract class ClassroomGateway {
  /// Takes a seat under a first name. Throws [ClassroomException].
  Future<ClassroomSeat> join({required String code, required String nickname});

  /// Answers the open question. [choice] is the answer's index in the
  /// bank's own order — the app shuffles what it shows, so the device
  /// sends back where the tapped answer came from, and the server
  /// decides whether it was right.
  Future<ClassroomAnswerOutcome> answer({
    required String code,
    required String token,
    required int questionIndex,
    required int choice,
  });

  /// The room as it stands. Used by the projected board, and by a pupil
  /// coming back after a drop.
  Future<ClassroomState> boardState(String code);

  /// The room as it changes. Implementations may push or poll; callers
  /// must not care.
  Stream<ClassroomState> watch(String code);

  /// Lets go of whatever the stream holds.
  Future<void> dispose();
}
