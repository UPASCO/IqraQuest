import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/game/domain/game_engine.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/theme/app_team.dart';

/// The placement turn and the bonus squares, through the pure engine:
/// the drop is the move, a bonus fires once per turn, and nothing ever
/// moves by itself.
GameState game({
  List<BonusTile> tiles = const [],
  GameVariant variant = GameVariant.classic,
  CircuitId circuit = CircuitId.oasisRoute,
}) {
  final now = DateTime(2026, 1, 1);
  return GameState(
    gameId: 'g_place',
    gameMode: GameMode.family,
    gameVariant: variant,
    circuitId: circuit,
    players: [
      Player(
        id: 'p0',
        name: 'A',
        team: AppTeam.emerald,
        horses: List.generate(variant.horsesPerPlayer, (_) => const HorseState()),
      ),
      Player(
        id: 'p1',
        name: 'B',
        team: AppTeam.saphir,
        horses: List.generate(variant.horsesPerPlayer, (_) => const HorseState()),
      ),
    ],
    currentPlayerIndex: 0,
    turnPhase: TurnPhase.selectingGait,
    askedQuestionIds: const {},
    bonusTiles: tiles,
    bonusSeed: 1,
    startedAt: now,
    updatedAt: now,
  );
}

GameState at(GameState s, {int player = 0, int horse = 0, required PawnPosition pos}) {
  final players = [...s.players];
  final horses = [...players[player].horses];
  horses[horse] = horses[horse].copyWith(position: pos);
  players[player] = players[player].copyWith(horses: horses);
  return s.copyWith(players: players);
}

/// Draw, answer right, open the placement.
GameState won(GameEngine engine, GameState s, int card) {
  var next = engine.drawCard(s, MovementChoice(card));
  next = engine.applyAnswer(next, correct: true, questionId: 'q$card');
  return engine.openPlacement(next);
}

void main() {
  const engine = GameEngine();

  group('The opening line-up', () {
    test('every rider starts with its first horse on its own start square', () {
      const engine = GameEngine();
      final s = game();
      final opened = s.copyWith(
        players: engine.openingLineUp(s.players, s.circuit),
      );
      for (var p = 0; p < opened.players.length; p++) {
        final horses = opened.players[p].horses;
        expect(
          horses.first.position,
          TrackPosition(s.circuit.entryIndexForTeam(p)),
          reason: 'rider \$p opens on its own start square',
        );
        expect(
          horses.skip(1).every((h) => h.position is HomePosition),
          isTrue,
          reason: 'only the first horse is out',
        );
      }
    });

    test('the first card can already ride it — no 6 to wait for', () {
      const engine = GameEngine();
      var s = game();
      s = s.copyWith(players: engine.openingLineUp(s.players, s.circuit));
      for (var value = 1; value <= 6; value++) {
        final moves = engine.legalMoves(s, MovementChoice(value));
        expect(
          moves.any((m) => m.horseIndex == 0 && !m.exitsStable),
          isTrue,
          reason: 'a \$value must be playable from the very first card',
        );
      }
      // The other three still need their 6 — and, by the classic rule,
      // a free start square: the horse that opens the game stands on it,
      // so the gate stays shut until it rides off. One move clears it.
      expect(engine.legalMoves(s, const MovementChoice(3)).length, 1);
      expect(
        engine.legalMoves(s, const MovementChoice(6)).where((m) => m.exitsStable),
        isEmpty,
        reason: 'your own horse on the start square keeps the gate shut',
      );
      final moved = at(s, horse: 0, pos: const TrackPosition(4));
      expect(
        engine
            .legalMoves(moved, const MovementChoice(6))
            .where((m) => m.exitsStable)
            .length,
        3,
        reason: 'the gate opens again once the start square is free',
      );
    });
  });

  group('Placement', () {
    test('a right answer opens the choice; every legal horse is offered with its destination', () {
      var s = game();
      s = at(s, horse: 0, pos: const TrackPosition(3));
      s = at(s, horse: 1, pos: const TrackPosition(10));
      s = won(engine, s, 4);
      expect(s.turnPhase, TurnPhase.choosingHorse);
      final moves = engine.legalMoves(s, s.drawnCard!);
      expect(moves.map((m) => m.horseIndex), [0, 1]);
      expect(moves[0].destination, const TrackPosition(7));
      expect(moves[1].destination, const TrackPosition(14));
      // Nothing has moved.
      expect(s.players[0].horses[0].position, const TrackPosition(3));
      expect(s.players[0].horses[1].position, const TrackPosition(10));
    });

    test('even a single legal horse waits for the player', () {
      var s = game();
      s = at(s, horse: 0, pos: const TrackPosition(3));
      s = won(engine, s, 2);
      expect(engine.legalMoves(s, s.drawnCard!).length, 1);
      expect(s.turnPhase, TurnPhase.choosingHorse, reason: 'no automatic move');
      expect(s.players[0].horses[0].position, const TrackPosition(3));
    });

    test('the drop is the move: no state waits for a confirmation', () {
      var s = game();
      s = at(s, horse: 0, pos: const TrackPosition(3));
      s = won(engine, s, 2);
      s = engine.placeHorse(s, 0);
      expect(s.turnPhase, TurnPhase.movingHorse);
      expect(s.players[0].horses[0].position, const TrackPosition(5));
      expect(s.lastMoveOutcome, MoveOutcome.moved);
      // A second placement in the same turn is refused.
      expect(identical(engine.placeHorse(s, 1), s), isTrue);
      s = engine.completeMove(s);
      expect(s.turnPhase, TurnPhase.turnComplete);
    });

    test('a wrong answer moves nothing and opens no placement', () {
      var s = game();
      s = at(s, horse: 0, pos: const TrackPosition(3));
      s = engine.drawCard(s, const MovementChoice(4));
      s = engine.applyAnswer(s, correct: false, questionId: 'q');
      expect(s.turnPhase, TurnPhase.showingFeedback);
      expect(s.lastMoveOutcome, MoveOutcome.stayed);
      expect(s.players[0].horses[0].position, const TrackPosition(3));
      expect(identical(engine.placeHorse(s, 0), s), isTrue);
    });

    test('the shield of a fresh streak goes to the horse set down', () {
      var s = game();
      s = at(s, horse: 0, pos: const TrackPosition(3));
      s = at(s, horse: 1, pos: const TrackPosition(20));
      final players = [...s.players];
      players[0] = players[0].copyWith(streak: const KnowledgeStreak(current: 2, best: 2));
      s = s.copyWith(players: players);
      s = won(engine, s, 2);
      expect(s.justUnlocked, contains(StreakReward.shield));
      expect(s.players[0].horses.any((h) => h.hasShield), isFalse);
      s = engine.placeHorse(s, 1);
      expect(s.players[0].horses[1].hasShield, isTrue);
      expect(s.players[0].horses[0].hasShield, isFalse);
    });
  });

  group('Bonus squares', () {
    const tiles = [
      BonusTile(trackIndex: 5, value: 5),
      BonusTile(trackIndex: 10, value: 10),
      BonusTile(trackIndex: 30, value: 20),
    ];

    test('the offered move says which bonus it would stop on', () {
      var s = game(tiles: tiles);
      s = at(s, horse: 0, pos: const TrackPosition(3));
      s = won(engine, s, 2);
      final move = engine.legalMoves(s, s.drawnCard!).single;
      expect(move.destination, const TrackPosition(5));
      expect(move.bonusValue, 5);
    });

    test('stopping exactly on a bonus square rides on by its value, in a second step', () {
      var s = game(tiles: tiles);
      s = at(s, horse: 0, pos: const TrackPosition(3));
      s = won(engine, s, 2);
      s = engine.placeHorse(s, 0);
      // Step one: the horse is on the square, the bonus is pending.
      expect(s.players[0].horses[0].position, const TrackPosition(5));
      expect(s.pendingBonus?.value, 5);
      expect(s.pendingBonus?.horseIndex, 0);
      expect(s.pendingBonus?.trackIndex, 5);
      expect(s.bonusUsedThisTurn, isFalse);
      // Step two: the ride.
      s = engine.applyPendingBonus(s);
      expect(s.players[0].horses[0].position, const TrackPosition(10));
      expect(s.pendingBonus, isNull);
      expect(s.bonusUsedThisTurn, isTrue);
      expect(s.lastBonusValue, 5);
    });

    test('at most one bonus per turn: a bonus ride never chains', () {
      var s = game(tiles: tiles);
      s = at(s, horse: 0, pos: const TrackPosition(3));
      s = won(engine, s, 2);
      s = engine.placeHorse(s, 0);
      s = engine.applyPendingBonus(s);
      // The +5 ride landed exactly on the +10 square…
      expect(s.players[0].horses[0].position, const TrackPosition(10));
      expect(s.bonusAt(10), isNotNull);
      // …and it does not fire.
      expect(s.pendingBonus, isNull);
      expect(identical(engine.applyPendingBonus(s), s), isTrue);
    });

    test('passing over a bonus square does nothing', () {
      var s = game(tiles: tiles);
      s = at(s, horse: 0, pos: const TrackPosition(3));
      s = won(engine, s, 4);
      s = engine.placeHorse(s, 0);
      expect(s.players[0].horses[0].position, const TrackPosition(7));
      expect(s.pendingBonus, isNull);
    });

    test('a bonus square stays on the board for the rest of the game', () {
      var s = game(tiles: tiles);
      s = at(s, horse: 0, pos: const TrackPosition(3));
      s = won(engine, s, 2);
      s = engine.applyPendingBonus(engine.placeHorse(s, 0));
      s = engine.endTurn(s);
      expect(s.bonusTiles, tiles);
      expect(s.bonusUsedThisTurn, isFalse);
      expect(s.lastBonusValue, isNull);
      // The other player can take the very same square next.
      s = at(s, player: 1, horse: 0, pos: const TrackPosition(3));
      s = won(engine, s, 2);
      expect(engine.legalMoves(s, s.drawnCard!).single.bonusValue, 5);
    });

    test('a bonus ride obeys the board: it captures what it lands on', () {
      var s = game(tiles: tiles);
      s = at(s, horse: 0, pos: const TrackPosition(3));
      s = at(s, player: 1, horse: 0, pos: const TrackPosition(10));
      s = won(engine, s, 2);
      s = engine.applyPendingBonus(engine.placeHorse(s, 0));
      expect(s.players[0].horses[0].position, const TrackPosition(10));
      expect(s.players[1].horses[0].position, const HomePosition());
      expect(s.lastMoveOutcome, MoveOutcome.captured);
    });

    test('a bonus ride can carry a horse home: the arrival owes its question', () {
      var s = game(tiles: const [BonusTile(trackIndex: 50, value: 20)], variant: GameVariant.quick);
      s = at(s, horse: 0, pos: const TrackPosition(48));
      s = won(engine, s, 2);
      s = engine.applyPendingBonus(engine.placeHorse(s, 0));
      expect(s.players[0].horses[0].position, isA<FinishedPosition>());
      expect(s.players[0].horses[0].awaitingJourneyQuestion, isTrue);
      expect(s.lastMoveOutcome, MoveOutcome.reachedFinish);
    });

    test('a horse coming out of the stable never lands on a bonus (start squares carry none)', () {
      var s = game(tiles: tiles);
      s = won(engine, s, 6);
      final exits = engine.legalMoves(s, s.drawnCard!);
      expect(exits.every((m) => m.bonusValue == null), isTrue);
    });

    test('the pending bonus survives a save and resumes mid-ride', () {
      var s = game(tiles: tiles);
      s = at(s, horse: 0, pos: const TrackPosition(3));
      s = won(engine, s, 2);
      s = engine.placeHorse(s, 0);
      final restored = GameState.fromJson(s.toJson());
      expect(restored.pendingBonus?.value, 5);
      expect(restored.turnPhase, TurnPhase.movingHorse);
      final resumed = engine.applyPendingBonus(restored);
      expect(resumed.players[0].horses[0].position, const TrackPosition(10));
    });
  });
}
