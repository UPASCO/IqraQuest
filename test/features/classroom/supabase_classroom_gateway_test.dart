// The wire between a pupil's phone and the classroom. What is checked
// here is the contract with server/supabase/migrations/0001_classroom.sql:
// which function is called, with which arguments, and what each answer
// means to a child looking at the screen.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iqraquest/features/classroom/data/classroom_gateway.dart';
import 'package:iqraquest/features/classroom/data/supabase_classroom_gateway.dart';
import 'package:iqraquest/features/classroom/domain/classroom_state.dart';

const _url = 'https://example.supabase.co';
const _anon = 'anon-key';

Map<String, dynamic> _room({
  String phase = 'lobby',
  int currentIndex = 0,
  int answered = 0,
}) => {
  'sessionId': 's1',
  'code': 'G4KEPW',
  'lessonId': 'lesson_prophets_beginner_01',
  'boardLanguage': 'fr',
  'teamCount': 2,
  'questionIds': ['prophets_001', 'prophets_002'],
  'phase': phase,
  'currentIndex': currentIndex,
  'participants': [
    {'nickname': 'Amina', 'team': 0},
  ],
  'squaresByTeam': {'0': 1, '1': 0},
  'answeredCurrent': answered,
  'answersByQuestion': {'0': answered},
  'correctByQuestion': {'0': answered},
  'secondsPerQuestion': 0,
};

/// A server that records what it was asked, and answers what it is told.
({
  SupabaseClassroomGateway gateway,
  List<({String function, Map<String, dynamic> body})> calls,
})
serverThat(
  Map<String, dynamic> Function(String function) reply, {
  int status = 200,
}) {
  final calls = <({String function, Map<String, dynamic> body})>[];
  final client = MockClient((request) async {
    final function = request.url.pathSegments.last;
    calls.add((
      function: function,
      body: jsonDecode(request.body) as Map<String, dynamic>,
    ));
    expect(request.headers['apikey'], _anon);
    expect(request.headers['Authorization'], 'Bearer $_anon');
    return http.Response(
      jsonEncode(reply(function)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
  return (
    gateway: SupabaseClassroomGateway(
      url: _url,
      anonKey: _anon,
      client: client,
      pollInterval: const Duration(milliseconds: 20),
    ),
    calls: calls,
  );
}

void main() {
  test('joining calls join_session with the code and the first name', () async {
    final server = serverThat(
      (_) => {
        'sessionId': 's1',
        'participantId': 'p1',
        'token': 'tok-1',
        'team': 1,
        'teamCount': 2,
        'lessonId': 'l1',
        'phase': 'lobby',
        'currentIndex': 0,
        'questionCount': 2,
      },
    );

    final seat = await server.gateway.join(code: 'g4kepw', nickname: ' Amina ');

    expect(server.calls.single.function, 'join_session');
    expect(server.calls.single.body, {
      'p_code': 'g4kepw',
      'p_nickname': ' Amina ',
    });
    expect(seat.token, 'tok-1');
    expect(seat.team, 1);
    expect(
      seat.code,
      'G4KEPW',
      reason: 'the seat is kept the way the server writes codes',
    );
    expect(seat.nickname, 'Amina');
  });

  test('an answer sends the bank index, and the room decides', () async {
    final server = serverThat((_) => {'recorded': true, 'correct': true});

    final outcome = await server.gateway.answer(
      code: 'G4KEPW',
      token: 'tok-1',
      questionIndex: 2,
      choice: 0,
    );

    expect(server.calls.single.function, 'submit_answer');
    expect(server.calls.single.body, {
      'p_code': 'G4KEPW',
      'p_token': 'tok-1',
      'p_question_index': 2,
      'p_choice': 0,
    });
    expect(outcome.correct, isTrue);
  });

  test('every error the functions return becomes one a child can read', () async {
    for (final entry in {
      'unknown_code': ClassroomError.unknownCode,
      'session_over': ClassroomError.sessionOver,
      'session_full': ClassroomError.sessionFull,
      'empty_nickname': ClassroomError.emptyNickname,
      'unknown_participant': ClassroomError.unknownParticipant,
      'not_open': ClassroomError.notOpen,
      'too_late': ClassroomError.tooLate,
      'something_new': ClassroomError.unreachable,
    }.entries) {
      final server = serverThat((_) => {'error': entry.key});
      await expectLater(
        server.gateway.join(code: 'G4KEPW', nickname: 'Amina'),
        throwsA(
          isA<ClassroomException>().having((e) => e.error, entry.key, entry.value),
        ),
      );
    }
  });

  test('a server that answers with an error code is simply unreachable', () async {
    final server = serverThat((_) => {'ok': true}, status: 500);

    await expectLater(
      server.gateway.boardState('G4KEPW'),
      throwsA(
        isA<ClassroomException>().having(
          (e) => e.error,
          'error',
          ClassroomError.unreachable,
        ),
      ),
    );
  });

  test('a network that is not there does not crash the screen', () async {
    final gateway = SupabaseClassroomGateway(
      url: _url,
      anonKey: _anon,
      client: MockClient((_) => throw const SocketFailure()),
    );

    await expectLater(
      gateway.boardState('G4KEPW'),
      throwsA(
        isA<ClassroomException>().having(
          (e) => e.error,
          'error',
          ClassroomError.unreachable,
        ),
      ),
    );
  });

  test('the board state comes back whole', () async {
    final server = serverThat((_) => _room(phase: 'asking', answered: 1));

    final state = await server.gateway.boardState('G4KEPW');

    expect(server.calls.single.function, 'board_state');
    expect(state.phase, ClassroomPhase.asking);
    expect(state.currentQuestionId, 'prophets_001');
    expect(state.squaresOf(0), 1);
    expect(state.answeredCurrent, 1);
    expect(state.participants.single.nickname, 'Amina');
  });

  test('watching polls, and only real changes travel', () async {
    var phase = 'lobby';
    final server = serverThat((_) => _room(phase: phase));

    final seen = <ClassroomPhase>[];
    final sub = server.gateway.watch('G4KEPW').listen((s) => seen.add(s.phase));
    await Future<void>.delayed(const Duration(milliseconds: 70));
    phase = 'asking';
    await Future<void>.delayed(const Duration(milliseconds: 70));

    expect(seen, [ClassroomPhase.lobby, ClassroomPhase.asking]);
    expect(
      server.calls.length,
      greaterThan(2),
      reason: 'it polled more often than it emitted',
    );
    await sub.cancel();

    // Nobody is listening any more: a phone in a pocket must not keep
    // the school network busy for a lesson that ended.
    final afterCancel = server.calls.length;
    await Future<void>.delayed(const Duration(milliseconds: 70));
    expect(server.calls.length, afterCancel);
    await server.gateway.dispose();
  });

  test('two watchers of one room share a single poll', () async {
    final server = serverThat((_) => _room());

    final a = server.gateway.watch('G4KEPW').listen((_) {});
    final b = server.gateway.watch('g4kepw').listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 70));
    final calls = server.calls.length;

    await a.cancel();
    await b.cancel();
    await Future<void>.delayed(const Duration(milliseconds: 70));
    expect(server.calls.length, calls);
    await server.gateway.dispose();
  });
}

class SocketFailure implements Exception {
  const SocketFailure();
}
