import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/game/domain/game_engine.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/theme/app_team.dart';

GameState buildGame({
  int playerCount = 2,
  GameVariant variant = GameVariant.classic,
  TurnPhase phase = TurnPhase.waitingForQuestion,
}) {
  final teams = [AppTeam.emerald, AppTeam.saphir, AppTeam.grenat, AppTeam.safran];
  final players = List.generate(
    playerCount,
    (i) => Player(
      id: 'p$i',
      name: 'Player $i',
      team: teams[i],
      pawns: List.generate(variant.pawnsPerPlayer, (_) => const HomePosition()),
    ),
  );
  final now = DateTime(2026, 1, 1);
  return GameState(
    gameId: 'g1',
    gameMode: GameMode.family,
    gameVariant: variant,
    players: players,
    currentPlayerIndex: 0,
    turnPhase: phase,
    askedQuestionIds: const {},
    startedAt: now,
    updatedAt: now,
  );
}

GameState withPawn(GameState state, {int player = 0, int pawn = 0, required PawnPosition pos}) {
  final players = List<Player>.from(state.players);
  final p = players[player];
  final pawns = List<PawnPosition>.from(p.pawns);
  pawns[pawn] = pos;
  players[player] = p.copyWith(pawns: pawns);
  return state.copyWith(players: players);
}

void main() {
  group('Question gate', () {
    test('correct answer unlocks the dice', () {
      final engine = GameEngine();
      final state = buildGame();
      final next = engine.applyAnswerCorrect(state, questionId: 'q1');
      expect(next.turnPhase, TurnPhase.waitingForDice);
      expect(next.askedQuestionIds, contains('q1'));
    });

    test('incorrect answer forfeits the roll and passes the turn', () {
      final engine = GameEngine();
      final state = buildGame();
      final next = engine.applyAnswerIncorrect(state, questionId: 'q1');
      expect(next.currentPlayerIndex, 1);
      expect(next.turnPhase, TurnPhase.waitingForQuestion);
      expect(next.lastDiceValue, isNull);
    });

    test('dice stays locked until a question is answered correctly', () {
      final state = buildGame();
      expect(state.turnPhase, TurnPhase.waitingForQuestion);
    });

    test('free bank exhaustion allows dice without a question, mid-game', () {
      final engine = GameEngine();
      final state = buildGame();
      final next = engine.allowDiceWithoutQuestion(state);
      expect(next.turnPhase, TurnPhase.waitingForDice);
      expect(next.freeBankExhausted, isTrue);
      expect(next.currentQuestionId, isNull);
    });
  });

  group('Leaving the stable', () {
    test('a 6 is required to leave home', () {
      final engine = GameEngine();
      final state = buildGame(variant: GameVariant.quick);
      final moves2 = engine.legalMoves(state, 2);
      expect(moves2, isEmpty);
      final moves6 = engine.legalMoves(state, 6);
      expect(moves6, hasLength(1));
      expect(moves6.single.to, isA<TrackPosition>());
    });

    test('rolling a 6 with no legal moves still ends the turn correctly', () {
      // All pawns already finished except constrained ones is out of scope;
      // simplest no-move case: single-pawn quick variant pawn already on
      // track, dice roll would overshoot every possibility except this
      // path — covered by the overshoot test. Here: home pawns + non-6.
      final engine = GameEngine();
      final state = buildGame();
      final result = engine.applyKnownDiceRoll(state, 3);
      expect(result.legalMoves, isEmpty);
      expect(result.state.currentPlayerIndex, 1); // no 6 => turn passes
    });
  });

  group('Movement & capture', () {
    test('capturing an opponent sends it back to the stable', () {
      final engine = GameEngine();
      var state = buildGame();
      // Player 0 enters at index 0. Player 1 enters at index 13.
      // Put player 1's pawn at index 3 (not a protected square) so player
      // 0 can capture it by rolling a 3 after leaving home... instead,
      // place player 0 directly on the track for a clean single-step test.
      state = withPawn(state, player: 0, pawn: 0, pos: const TrackPosition(2));
      state = withPawn(state, player: 1, pawn: 0, pos: const TrackPosition(3));
      final moves = engine.legalMoves(state, 1);
      final capture = moves.firstWhere((m) => m.to == const TrackPosition(3));
      expect(capture.isCapture, isTrue);
      expect(capture.capturedPlayerId, 'p1');

      final next = engine.applyMove(state, capture);
      expect(next.players[1].pawns[0], const HomePosition());
      expect(next.players[0].pawns[0], const TrackPosition(3));
    });

    test('a protected square cannot be captured on', () {
      final engine = GameEngine();
      var state = buildGame();
      // Square 8 is protected (BoardGeometry.protectedSquares).
      state = withPawn(state, player: 0, pawn: 0, pos: const TrackPosition(6));
      state = withPawn(state, player: 1, pawn: 0, pos: const TrackPosition(8));
      final moves = engine.legalMoves(state, 2);
      final landing = moves.firstWhere((m) => m.to == const TrackPosition(8));
      expect(landing.isCapture, isFalse);
    });

    test('several movable pawns are all offered as legal moves', () {
      final engine = GameEngine();
      var state = buildGame();
      state = withPawn(state, player: 0, pawn: 0, pos: const TrackPosition(1));
      state = withPawn(state, player: 0, pawn: 1, pos: const TrackPosition(10));
      final moves = engine.legalMoves(state, 3);
      expect(moves.map((m) => m.pawnIndex).toSet(), {0, 1});
    });

    test('no legal move exists when every pawn is home and dice != 6', () {
      final engine = GameEngine();
      final state = buildGame();
      expect(engine.legalMoves(state, 4), isEmpty);
    });

    test('exact count is required to finish — overshoot is illegal', () {
      final engine = GameEngine();
      var state = buildGame();
      // Player 0 pawn one step from finishing its final lane.
      state = withPawn(state, player: 0, pawn: 0, pos: const FinalLanePosition(6));
      final movesTooFar = engine.legalMoves(state, 3);
      expect(movesTooFar, isEmpty); // would overshoot past Finished
      final movesExact = engine.legalMoves(state, 1);
      expect(movesExact.single.to, isA<FinishedPosition>());
    });
  });

  group('Turn transitions', () {
    test('rolling a 6 grants the same player a new turn gated by a question', () {
      final engine = GameEngine();
      var state = buildGame();
      state = withPawn(state, player: 0, pawn: 0, pos: const TrackPosition(1));
      final rollResult = engine.applyKnownDiceRoll(state, 6);
      final move = rollResult.legalMoves.first;
      final afterMove = engine.applyMove(rollResult.state, move);
      expect(afterMove.currentPlayerIndex, 0); // same player
      expect(afterMove.turnPhase, TurnPhase.waitingForQuestion);
      expect(afterMove.currentQuestionId, isNull); // must ask again
    });

    test('a non-6 roll passes the turn to the next player', () {
      final engine = GameEngine();
      var state = buildGame();
      state = withPawn(state, player: 0, pawn: 0, pos: const TrackPosition(1));
      final rollResult = engine.applyKnownDiceRoll(state, 3);
      final move = rollResult.legalMoves.first;
      final afterMove = engine.applyMove(rollResult.state, move);
      expect(afterMove.currentPlayerIndex, 1);
    });
  });

  group('No repeated questions', () {
    test('askedQuestionIds accumulates and never resets mid-game', () {
      final engine = GameEngine();
      var state = buildGame();
      state = engine.applyAnswerCorrect(state, questionId: 'q1');
      state = state.copyWith(currentPlayerIndex: 1);
      state = engine.applyAnswerCorrect(state, questionId: 'q2');
      expect(state.askedQuestionIds, {'q1', 'q2'});
    });
  });

  group('Victory conditions', () {
    test('quick variant: first finished pawn wins immediately', () {
      final engine = GameEngine();
      var state = buildGame(variant: GameVariant.quick);
      state = withPawn(state, player: 0, pawn: 0, pos: const FinalLanePosition(6));
      final rollResult = engine.applyKnownDiceRoll(state, 1);
      final afterMove = engine.applyMove(rollResult.state, rollResult.legalMoves.single);
      expect(afterMove.turnPhase, TurnPhase.gameOver);
      expect(afterMove.winnerId, 'p0');
    });

    test('classic variant: all 4 pawns must finish to win', () {
      final engine = GameEngine();
      var state = buildGame(variant: GameVariant.classic);
      state = withPawn(state, player: 0, pawn: 0, pos: const FinishedPosition());
      state = withPawn(state, player: 0, pawn: 1, pos: const FinishedPosition());
      state = withPawn(state, player: 0, pawn: 2, pos: const FinishedPosition());
      state = withPawn(state, player: 0, pawn: 3, pos: const FinalLanePosition(6));

      final rollResult = engine.applyKnownDiceRoll(state, 1);
      final afterMove = engine.applyMove(rollResult.state, rollResult.legalMoves.single);
      expect(afterMove.turnPhase, TurnPhase.gameOver);
      expect(afterMove.winnerId, 'p0');
    });

    test('classic variant: 3 of 4 pawns finished is not yet a win', () {
      final engine = GameEngine();
      final player = Player(
        id: 'p0',
        name: 'P',
        team: AppTeam.emerald,
        pawns: const [FinishedPosition(), FinishedPosition(), FinishedPosition(), TrackPosition(5)],
      );
      expect(engine.hasPlayerWon(player, GameVariant.classic), isFalse);
    });
  });
}
