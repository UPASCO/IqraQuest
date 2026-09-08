import 'dart:async';
import 'dart:math';

import '../domain/classroom_state.dart';
import 'classroom_gateway.dart';

/// A whole classroom in memory, playing the same rules as the server.
///
/// It exists so the pupil's screen, the projected board and their tests
/// can be built and run before any Supabase project exists — and so
/// they keep running afterwards, in tests, without a network. The rules
/// enforced here are the ones written in
/// `server/supabase/migrations/0001_classroom.sql`; when one changes
/// there, it changes here, and the tests below are what notice.
class FakeClassroomGateway implements ClassroomGateway {
  FakeClassroomGateway({Random? random, DateTime Function()? clock})
    : _random = random ?? Random(),
      _now = clock ?? DateTime.now;

  final Random _random;
  final DateTime Function() _now;

  final Map<String, _Session> _sessions = {};
  final Map<String, StreamController<ClassroomState>> _watchers = {};

  // ---- The teacher's side, for tests and the development harness ----

  /// Opens a session and returns its code.
  String openSession({
    required String lessonId,
    required List<String> questionIds,
    int teamCount = 3,
    String boardLanguage = 'fr',
    int secondsPerQuestion = 0,
    ClassroomScoring scoring = ClassroomScoring.teams,
  }) {
    final code = _newCode();
    _sessions[code] = _Session(
      id: 's_${_random.nextInt(1 << 32)}',
      code: code,
      lessonId: lessonId,
      questionIds: List.unmodifiable(questionIds),
      teamCount: teamCount.clamp(2, 4),
      boardLanguage: boardLanguage,
      secondsPerQuestion: secondsPerQuestion.clamp(0, 180),
      scoring: scoring,
    );
    return code;
  }

  /// Opens the next question, or ends the session after the last one.
  void ask(String code) {
    final s = _require(code);
    switch (s.phase) {
      case ClassroomPhase.lobby:
        s.phase = ClassroomPhase.asking;
        s.currentIndex = 0;
        s.askedAt = _now();
      case ClassroomPhase.revealing:
        if (s.currentIndex + 1 >= s.questionIds.length) {
          s.phase = ClassroomPhase.over;
        } else {
          s.currentIndex += 1;
          s.phase = ClassroomPhase.asking;
          s.askedAt = _now();
        }
      case ClassroomPhase.asking:
      case ClassroomPhase.over:
        return;
    }
    _publish(s);
  }

  void reveal(String code) {
    final s = _require(code);
    if (s.phase != ClassroomPhase.asking) return;
    s.phase = ClassroomPhase.revealing;
    _publish(s);
  }

  /// Ends the session and forgets everyone in it, as the server does.
  ///
  /// The room stays, marked over, so the pupils' screens show the end of
  /// the lesson instead of "no class reachable"; it is the participants
  /// and their answers that go immediately, because they are the part
  /// that held names. `purge_old_sessions` removes the rest within two
  /// days — which has no equivalent here, and needs none.
  void close(String code) {
    final s = _sessions[_normalize(code)];
    if (s == null) return;
    s.phase = ClassroomPhase.over;
    s.participants.clear();
    s.answers.clear();
    _publish(s);
  }

  /// How many pupils answered a given question correctly — the teacher's
  /// report, in the only shape it is kept: counted, never named.
  int correctCount(String code, int questionIndex) {
    final s = _require(code);
    return s.answers.values
        .where((a) => a.questionIndex == questionIndex && a.correct)
        .length;
  }

  // ---- The pupils' side: the gateway proper ----

  @override
  Future<ClassroomSeat> join({
    required String code,
    required String nickname,
  }) async {
    final s = _sessions[_normalize(code)];
    if (s == null) throw const ClassroomException(ClassroomError.unknownCode);
    if (s.phase == ClassroomPhase.over) {
      throw const ClassroomException(ClassroomError.sessionOver);
    }
    final clean = nickname.trim();
    if (clean.isEmpty) {
      throw const ClassroomException(ClassroomError.emptyNickname);
    }
    if (s.participants.length >= 60) {
      throw const ClassroomException(ClassroomError.sessionFull);
    }

    // The smallest team, so the horses line up evenly.
    final counts = <int, int>{for (var t = 0; t < s.teamCount; t++) t: 0};
    for (final p in s.participants.values) {
      counts[p.team] = (counts[p.team] ?? 0) + 1;
    }
    var team = 0;
    for (var t = 1; t < s.teamCount; t++) {
      if (counts[t]! < counts[team]!) team = t;
    }

    final token = 't_${_random.nextInt(1 << 32)}_${s.participants.length}';
    s.participants[token] = _Participant(
      id: 'p_${s.participants.length}',
      nickname: clean,
      team: team,
    );
    _publish(s);

    return ClassroomSeat(
      sessionId: s.id,
      code: s.code,
      participantId: s.participants[token]!.id,
      token: token,
      nickname: clean,
      team: team,
    );
  }

  @override
  Future<ClassroomAnswerOutcome> answer({
    required String code,
    required String token,
    required int questionIndex,
    required int choice,
  }) async {
    final s = _sessions[_normalize(code)];
    if (s == null) throw const ClassroomException(ClassroomError.unknownCode);
    final p = s.participants[token];
    if (p == null) {
      throw const ClassroomException(ClassroomError.unknownParticipant);
    }
    if (s.phase != ClassroomPhase.asking || questionIndex != s.currentIndex) {
      throw const ClassroomException(ClassroomError.notOpen);
    }
    if (s.secondsPerQuestion > 0 && s.askedAt != null) {
      final deadline = s.askedAt!.add(
        Duration(seconds: s.secondsPerQuestion + 2),
      );
      if (_now().isAfter(deadline)) {
        throw const ClassroomException(ClassroomError.tooLate);
      }
    }

    // The bank keeps the right answer at index 0; the app shuffles what
    // it shows, and sends back where the tapped answer came from.
    final correct = choice == 0;
    // First answer stands: a retry over a bad wifi must not count twice,
    // and must not let a pupil change their mind.
    s.answers.putIfAbsent(
      '$token#$questionIndex',
      () => _Answer(
        token: token,
        team: p.team,
        questionIndex: questionIndex,
        correct: correct,
      ),
    );
    _publish(s);
    return ClassroomAnswerOutcome(
      correct: s.answers['$token#$questionIndex']!.correct,
    );
  }

  @override
  Future<ClassroomState> boardState(String code) async {
    final s = _sessions[_normalize(code)];
    if (s == null) throw const ClassroomException(ClassroomError.unknownCode);
    return s.snapshot();
  }

  @override
  Stream<ClassroomState> watch(String code) {
    final key = _normalize(code);
    final controller = _watchers.putIfAbsent(
      key,
      () => StreamController<ClassroomState>.broadcast(),
    );
    final s = _sessions[key];
    if (s != null) {
      scheduleMicrotask(() {
        if (!controller.isClosed) controller.add(s.snapshot());
      });
    }
    return controller.stream;
  }

  @override
  Future<void> dispose() async {
    for (final c in _watchers.values) {
      await c.close();
    }
    _watchers.clear();
  }

  // ---- Plumbing ----

  _Session _require(String code) {
    final s = _sessions[_normalize(code)];
    if (s == null) throw const ClassroomException(ClassroomError.unknownCode);
    return s;
  }

  void _publish(_Session s) {
    final controller = _watchers[s.code];
    if (controller != null && !controller.isClosed) {
      controller.add(s.snapshot());
    }
  }

  static String _normalize(String code) => code.trim().toUpperCase();

  /// The same alphabet as the server: nothing a child can misread off a
  /// whiteboard.
  String _newCode() {
    const alphabet = 'ABCDEFGHJKMNPQRSTWXYZ2345678';
    String draw() => List.generate(
      6,
      (_) => alphabet[_random.nextInt(alphabet.length)],
    ).join();
    var code = draw();
    while (_sessions.containsKey(code)) {
      code = draw();
    }
    return code;
  }
}

class _Session {
  _Session({
    required this.id,
    required this.code,
    required this.lessonId,
    required this.questionIds,
    required this.teamCount,
    required this.boardLanguage,
    required this.secondsPerQuestion,
    required this.scoring,
  });

  final String id;
  final String code;
  final String lessonId;
  final List<String> questionIds;
  final int teamCount;
  final String boardLanguage;
  final int secondsPerQuestion;
  final ClassroomScoring scoring;

  ClassroomPhase phase = ClassroomPhase.lobby;
  int currentIndex = 0;
  DateTime? askedAt;

  final Map<String, _Participant> participants = {};
  final Map<String, _Answer> answers = {};

  ClassroomState snapshot() {
    final squares = <int, int>{for (var t = 0; t < teamCount; t++) t: 0};
    for (final a in answers.values) {
      if (a.correct) squares[a.team] = (squares[a.team] ?? 0) + 1;
    }
    return ClassroomState(
      sessionId: id,
      code: code,
      lessonId: lessonId,
      boardLanguage: boardLanguage,
      teamCount: teamCount,
      questionIds: questionIds,
      phase: phase,
      currentIndex: currentIndex,
      participants: [
        for (final p in participants.values)
          ClassroomParticipant(nickname: p.nickname, team: p.team),
      ],
      squaresByTeam: squares,
      answeredCurrent: answers.values
          .where((a) => a.questionIndex == currentIndex)
          .length,
      answersByQuestion: {
        for (var i = 0; i < questionIds.length; i++)
          if (answers.values.any((a) => a.questionIndex == i))
            i: answers.values.where((a) => a.questionIndex == i).length,
      },
      correctByQuestion: {
        for (var i = 0; i < questionIds.length; i++)
          if (answers.values.any((a) => a.questionIndex == i))
            i: answers.values
                .where((a) => a.questionIndex == i && a.correct)
                .length,
      },
      askedAt: askedAt,
      secondsPerQuestion: secondsPerQuestion,
      scoring: scoring,
      // Named scores travel only when the teacher asked for them: in
      // the team mode the wall carries no name against a score at all.
      pupilScores: scoring == ClassroomScoring.individual
          ? _pupilScores()
          : const [],
    );
  }

  /// Every pupil's running score, best first, ties in joining order so
  /// the wall does not reshuffle between two identical frames.
  List<ClassroomPupilScore> _pupilScores() {
    final scores = <ClassroomPupilScore>[];
    for (final entry in participants.entries) {
      scores.add(
        ClassroomPupilScore(
          nickname: entry.value.nickname,
          team: entry.value.team,
          correct: answers.values
              .where((a) => a.token == entry.key && a.correct)
              .length,
        ),
      );
    }
    final order = [for (final p in participants.values) p.nickname];
    scores.sort((a, b) {
      final byScore = b.correct.compareTo(a.correct);
      return byScore != 0
          ? byScore
          : order.indexOf(a.nickname).compareTo(order.indexOf(b.nickname));
    });
    return scores;
  }
}

class _Participant {
  _Participant({required this.id, required this.nickname, required this.team});

  final String id;
  final String nickname;
  final int team;
}

class _Answer {
  _Answer({
    required this.token,
    required this.team,
    required this.questionIndex,
    required this.correct,
  });

  final String token;
  final int team;
  final int questionIndex;
  final bool correct;
}
