// The rules a classroom session must keep, written against the same
// contract the SQL enforces (server/supabase/migrations/0001_classroom.sql).
// When one of these two changes, the other has to follow — and this file
// is what says so out loud.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/classroom/data/classroom_gateway.dart';
import 'package:iqraquest/features/classroom/data/fake_classroom_gateway.dart';
import 'package:iqraquest/features/classroom/domain/classroom_state.dart';
import 'package:iqraquest/features/classroom/domain/shuffle_seed.dart';

const _lesson = ['faith_001', 'faith_002', 'faith_003'];

FakeClassroomGateway _room({DateTime Function()? clock}) =>
    FakeClassroomGateway(random: Random(7), clock: clock);

void main() {
  test('a code is six characters a child cannot misread', () {
    final room = _room();
    final code = room.openSession(lessonId: 'piliers', questionIds: _lesson);

    expect(code, hasLength(6));
    expect(
      RegExp(r'^[ABCDEFGHJKMNPQRSTWXYZ2345678]{6}$').hasMatch(code),
      isTrue,
      reason: 'no O/0, no I/1/L, no U/V — it is copied off a whiteboard',
    );
  });

  test('joining needs only a code and a first name', () async {
    final room = _room();
    final code = room.openSession(lessonId: 'piliers', questionIds: _lesson);

    final seat = await room.join(code: code, nickname: '  Amina  ');

    expect(seat.nickname, 'Amina', reason: 'trimmed, as the server does');
    expect(seat.code, code);
    expect(seat.token, isNotEmpty, reason: 'the seat survives a dropped wifi');
    expect(seat.team, 0);
  });

  test('the code is not case-sensitive: it is read off a board', () async {
    final room = _room();
    final code = room.openSession(lessonId: 'piliers', questionIds: _lesson);

    final seat = await room.join(code: code.toLowerCase(), nickname: 'Yusuf');
    expect(seat.code, code);
  });

  test('an unknown code says only that, and a blank name is refused', () async {
    final room = _room();
    room.openSession(lessonId: 'piliers', questionIds: _lesson);

    await expectLater(
      room.join(code: 'ZZZZZZ', nickname: 'Amina'),
      throwsA(
        isA<ClassroomException>().having(
          (e) => e.error,
          'error',
          ClassroomError.unknownCode,
        ),
      ),
    );
    final code = room.openSession(lessonId: 'p2', questionIds: _lesson);
    await expectLater(
      room.join(code: code, nickname: '   '),
      throwsA(
        isA<ClassroomException>().having(
          (e) => e.error,
          'error',
          ClassroomError.emptyNickname,
        ),
      ),
    );
  });

  test('pupils fill the teams evenly, so the horses line up', () async {
    final room = _room();
    final code = room.openSession(
      lessonId: 'piliers',
      questionIds: _lesson,
      teamCount: 3,
    );

    final teams = <int>[];
    for (final name in ['A', 'B', 'C', 'D', 'E', 'F', 'G']) {
      teams.add((await room.join(code: code, nickname: name)).team);
    }

    expect(teams, [0, 1, 2, 0, 1, 2, 0]);
    final state = await room.boardState(code);
    expect(state.headCountOf(0), 3);
    expect(state.headCountOf(1), 2);
    expect(state.headCountOf(2), 2);
  });

  test('nothing can be answered until the teacher opens a question', () async {
    final room = _room();
    final code = room.openSession(lessonId: 'piliers', questionIds: _lesson);
    final seat = await room.join(code: code, nickname: 'Amina');

    await expectLater(
      room.answer(
        code: code,
        token: seat.token,
        questionIndex: 0,
        choice: 0,
      ),
      throwsA(
        isA<ClassroomException>().having(
          (e) => e.error,
          'error',
          ClassroomError.notOpen,
        ),
      ),
    );

    room.ask(code);
    final outcome = await room.answer(
      code: code,
      token: seat.token,
      questionIndex: 0,
      choice: 0,
    );
    expect(outcome.correct, isTrue);
  });

  test('an answer sent twice over a bad wifi counts once', () async {
    final room = _room();
    final code = room.openSession(lessonId: 'piliers', questionIds: _lesson);
    final seat = await room.join(code: code, nickname: 'Amina');
    room.ask(code);

    await room.answer(code: code, token: seat.token, questionIndex: 0, choice: 0);
    // The same tap, resent — and then a different one, which must not
    // let the pupil change their mind either.
    final again = await room.answer(
      code: code,
      token: seat.token,
      questionIndex: 0,
      choice: 2,
    );

    expect(again.correct, isTrue, reason: 'the first answer stands');
    final state = await room.boardState(code);
    expect(state.answeredCurrent, 1);
    expect(state.squaresOf(0), 1);
  });

  test('every correct answer moves the team one square', () async {
    final room = _room();
    final code = room.openSession(
      lessonId: 'piliers',
      questionIds: _lesson,
      teamCount: 2,
    );
    final a = await room.join(code: code, nickname: 'Amina'); // team 0
    final b = await room.join(code: code, nickname: 'Yusuf'); // team 1
    final c = await room.join(code: code, nickname: 'Sara'); // team 0

    room.ask(code);
    await room.answer(code: code, token: a.token, questionIndex: 0, choice: 0);
    await room.answer(code: code, token: c.token, questionIndex: 0, choice: 0);
    await room.answer(code: code, token: b.token, questionIndex: 0, choice: 3);

    final state = await room.boardState(code);
    expect(
      state.squaresOf(0),
      2,
      reason: 'two right answers in the team, two squares',
    );
    expect(state.squaresOf(1), 0);
    expect(state.standings, [0, 1]);
  });

  test('a revealed question is closed, and the next one opens', () async {
    final room = _room();
    final code = room.openSession(lessonId: 'piliers', questionIds: _lesson);
    final seat = await room.join(code: code, nickname: 'Amina');

    room.ask(code);
    room.reveal(code);
    await expectLater(
      room.answer(code: code, token: seat.token, questionIndex: 0, choice: 0),
      throwsA(
        isA<ClassroomException>().having(
          (e) => e.error,
          'error',
          ClassroomError.notOpen,
        ),
      ),
    );

    room.ask(code);
    final state = await room.boardState(code);
    expect(state.currentIndex, 1);
    expect(state.phase, ClassroomPhase.asking);
    expect(state.currentQuestionId, 'faith_002');
    expect(
      (await room.answer(
        code: code,
        token: seat.token,
        questionIndex: 1,
        choice: 0,
      )).correct,
      isTrue,
    );
  });

  test('revealing the last card ends the session', () async {
    final room = _room();
    final code = room.openSession(lessonId: 'piliers', questionIds: _lesson);

    for (var i = 0; i < _lesson.length; i++) {
      room.ask(code);
      room.reveal(code);
    }
    room.ask(code);

    final state = await room.boardState(code);
    expect(state.phase, ClassroomPhase.over);
    expect(state.currentQuestionId, isNull);
  });

  test('an answer after the timer is refused, with two seconds of grace', () async {
    var now = DateTime(2026, 9, 8, 10);
    final room = _room(clock: () => now);
    final code = room.openSession(
      lessonId: 'piliers',
      questionIds: _lesson,
      secondsPerQuestion: 20,
    );
    final seat = await room.join(code: code, nickname: 'Amina');
    room.ask(code);

    now = now.add(const Duration(seconds: 21));
    expect(
      (await room.answer(
        code: code,
        token: seat.token,
        questionIndex: 0,
        choice: 0,
      )).correct,
      isTrue,
      reason: 'a second over is a slow school network, not a cheat',
    );

    final other = await room.join(code: code, nickname: 'Yusuf');
    now = now.add(const Duration(seconds: 5));
    await expectLater(
      room.answer(code: code, token: other.token, questionIndex: 0, choice: 0),
      throwsA(
        isA<ClassroomException>().having(
          (e) => e.error,
          'error',
          ClassroomError.tooLate,
        ),
      ),
    );
  });

  test('the team mode puts no name against a score', () async {
    final room = _room();
    final code = room.openSession(lessonId: 'piliers', questionIds: _lesson);
    final seat = await room.join(code: code, nickname: 'Amina');
    room.ask(code);
    await room.answer(code: code, token: seat.token, questionIndex: 0, choice: 0);

    final state = await room.boardState(code);
    expect(state.scoring, ClassroomScoring.teams);
    expect(
      state.pupilScores,
      isEmpty,
      reason: 'a wall that ranks children was not asked for',
    );
  });

  test('the individual mode ranks every pupil, best first', () async {
    final room = _room();
    final code = room.openSession(
      lessonId: 'piliers',
      questionIds: _lesson,
      teamCount: 2,
      scoring: ClassroomScoring.individual,
    );
    final a = await room.join(code: code, nickname: 'Amina');
    final b = await room.join(code: code, nickname: 'Yusuf');

    room.ask(code);
    await room.answer(code: code, token: a.token, questionIndex: 0, choice: 0);
    await room.answer(code: code, token: b.token, questionIndex: 0, choice: 2);
    room.reveal(code);
    room.ask(code);
    await room.answer(code: code, token: b.token, questionIndex: 1, choice: 0);
    await room.answer(code: code, token: a.token, questionIndex: 1, choice: 0);

    final state = await room.boardState(code);
    expect(state.scoring, ClassroomScoring.individual);
    expect(
      [for (final p in state.pupilScores) '${p.nickname}:${p.correct}'],
      ['Amina:2', 'Yusuf:1'],
    );
    // The teams keep their squares too: a class can be ranked and still
    // see the horses move.
    expect(state.squaresOf(a.team), 2);
    expect(
      ClassroomState.fromJson(state.toJson()).pupilScores.first.nickname,
      'Amina',
      reason: 'the ranking survives the trip through the server',
    );
  });

  test('the board counts how many answered, never who or what', () async {
    final room = _room();
    final code = room.openSession(
      lessonId: 'piliers',
      questionIds: _lesson,
      teamCount: 2,
    );
    final a = await room.join(code: code, nickname: 'Amina');
    await room.join(code: code, nickname: 'Yusuf');
    room.ask(code);
    await room.answer(code: code, token: a.token, questionIndex: 0, choice: 3);

    final state = await room.boardState(code);
    expect(state.answeredCurrent, 1);
    // Nothing in what the projector receives ties a name to an answer.
    final json = state.toJson().toString();
    expect(json.contains('choice'), isFalse);
    expect(
      RegExp(r'Amina[^}]*correct').hasMatch(json),
      isFalse,
      reason: 'a projector faces the whole class',
    );
  });

  test('the room counts each card, so the board can close on the hard ones', () async {
    final room = _room();
    final code = room.openSession(
      lessonId: 'piliers',
      questionIds: _lesson,
      teamCount: 2,
    );
    final a = await room.join(code: code, nickname: 'Amina');
    final b = await room.join(code: code, nickname: 'Yusuf');

    // First card: one right, one wrong. Second: both right.
    room.ask(code);
    await room.answer(code: code, token: a.token, questionIndex: 0, choice: 0);
    await room.answer(code: code, token: b.token, questionIndex: 0, choice: 2);
    room.reveal(code);
    room.ask(code);
    await room.answer(code: code, token: a.token, questionIndex: 1, choice: 0);
    await room.answer(code: code, token: b.token, questionIndex: 1, choice: 0);

    final state = await room.boardState(code);
    expect(state.answersByQuestion[0], 2);
    expect(state.correctByQuestion[0], 1);
    expect(state.successOf(0), 0.5);
    expect(state.successOf(1), 1);
    expect(
      state.successOf(2),
      isNull,
      reason: 'a card the class never reached says nothing about the class',
    );
    expect(
      state.hardestQuestions(),
      [0],
      reason: 'the half-missed card, and not the one everyone got right',
    );
    // Counts only: nothing here ties a child to an answer.
    final json = state.toJson().toString();
    expect(json.contains('Amina'), isTrue, reason: 'the lobby names, no more');
    expect(RegExp(r'Amina[^}]*correct').hasMatch(json), isFalse);
  });

  test('closing a session forgets everyone in it', () async {
    final room = _room();
    final code = room.openSession(lessonId: 'piliers', questionIds: _lesson);
    final seat = await room.join(code: code, nickname: 'Amina');
    room.ask(code);
    await room.answer(code: code, token: seat.token, questionIndex: 0, choice: 0);

    room.close(code);

    await expectLater(
      room.boardState(code),
      throwsA(
        isA<ClassroomException>().having(
          (e) => e.error,
          'error',
          ClassroomError.unknownCode,
        ),
      ),
    );
  });

  test('a pupil who dropped comes back with the seat and the score', () async {
    final room = _room();
    final code = room.openSession(lessonId: 'piliers', questionIds: _lesson);
    final seat = await room.join(code: code, nickname: 'Amina');
    room.ask(code);
    await room.answer(code: code, token: seat.token, questionIndex: 0, choice: 0);

    // The device restarts and restores its seat from local storage.
    final restored = ClassroomSeat.restore(seat.toJson());
    room.reveal(code);
    room.ask(code);
    final outcome = await room.answer(
      code: code,
      token: restored.token,
      questionIndex: 1,
      choice: 0,
    );

    expect(outcome.correct, isTrue);
    expect((await room.boardState(code)).squaresOf(seat.team), 2);
  });

  test('the board pushes every change to whoever is watching', () async {
    final room = _room();
    final code = room.openSession(lessonId: 'piliers', questionIds: _lesson);
    final seen = <ClassroomPhase>[];
    final sub = room.watch(code).listen((s) => seen.add(s.phase));

    await Future<void>.delayed(Duration.zero);
    room.ask(code);
    room.reveal(code);
    await Future<void>.delayed(Duration.zero);

    expect(
      seen,
      containsAllInOrder([
        ClassroomPhase.lobby,
        ClassroomPhase.asking,
        ClassroomPhase.revealing,
      ]),
    );
    await sub.cancel();
    await room.dispose();
  });

  test('the timer left is read from the server stamp', () {
    final asked = DateTime(2026, 9, 8, 10);
    final state = ClassroomState(
      sessionId: 's',
      code: 'ABCDEF',
      lessonId: 'piliers',
      boardLanguage: 'fr',
      teamCount: 2,
      questionIds: _lesson,
      phase: ClassroomPhase.asking,
      currentIndex: 0,
      participants: const [],
      squaresByTeam: const {},
      answeredCurrent: 0,
      askedAt: asked,
      secondsPerQuestion: 30,
    );

    expect(
      state.remaining(now: asked.add(const Duration(seconds: 10))),
      const Duration(seconds: 20),
    );
    expect(
      state.remaining(now: asked.add(const Duration(seconds: 40))),
      Duration.zero,
      reason: 'a countdown never goes negative on a wall',
    );
    expect(
      state.copyWith(phase: ClassroomPhase.revealing).remaining(now: asked),
      isNull,
    );
  });

  test('the answers land in the same order after a restart, never a new one', () {
    // The wall and the phone both draw their order from this seed. It
    // has to be the same seed in a fresh process, or a page refresh
    // would move the answers under a class mid-question.
    final again = stableSeed(['s_1', 'tok', 2]);
    expect(stableSeed(['s_1', 'tok', 2]), again);
    expect(stableSeed(['s_1', 'tok', 3]), isNot(again));
    expect(stableSeed(['s_2', 'tok', 2]), isNot(again));
    expect(
      stableSeed(['s_1', 'tok', 2]),
      474034994,
      reason: 'a value written down: if this changes, so does every '
          'board mid-lesson',
    );
  });

  test('the right answer does not always sit first on the wall', () {
    // The bank keeps the correct answer at index 0. If the shuffle were
    // weak, a class would learn to read the first line instead of the
    // question.
    final firsts = <int>{};
    for (var index = 0; index < 40; index++) {
      final order = [0, 1, 2, 3]..shuffle(Random(stableSeed(['s_1', index])));
      firsts.add(order.indexOf(0));
    }
    expect(firsts.length, 4, reason: 'the right answer visits every slot');
  });

  test('the state survives the round trip the server sends it through', () {
    final room = _room();
    final code = room.openSession(lessonId: 'piliers', questionIds: _lesson);
    room.ask(code);

    return room.boardState(code).then((state) {
      final restored = ClassroomState.fromJson(state.toJson());
      expect(restored.code, state.code);
      expect(restored.phase, state.phase);
      expect(restored.questionIds, state.questionIds);
      expect(restored.secondsPerQuestion, state.secondsPerQuestion);
      expect(restored.askedAt, isNotNull);
    });
  });
}
