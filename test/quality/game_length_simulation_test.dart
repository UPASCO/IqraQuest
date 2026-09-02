// The bonus squares exist to make games shorter and more exciting. This
// is the measurement behind that promise: whole games simulated through
// the real engine, with and without the sixteen squares, so the +5/+10/
// +20 distribution can be judged in draws rather than in hopes.
//
// Run with `flutter test test/quality/game_length_simulation_test.dart -r expanded`
// to read the table.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/game/domain/game_engine.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/theme/app_team.dart';

const _teams = [AppTeam.emerald, AppTeam.saphir, AppTeam.grenat, AppTeam.safran];

GameState _game({
  required int players,
  required GameVariant variant,
  required CircuitId circuit,
  required int seed,
  required bool bonuses,
}) {
  final now = DateTime(2026, 1, 1);
  var state = GameState(
    gameId: 'sim_$seed',
    gameMode: GameMode.family,
    gameVariant: variant,
    circuitId: circuit,
    players: [
      for (var i = 0; i < players; i++)
        Player(
          id: 'p$i',
          name: 'P$i',
          team: _teams[i],
          horses: List.generate(variant.horsesPerPlayer, (_) => const HorseState()),
        ),
    ],
    currentPlayerIndex: 0,
    turnPhase: TurnPhase.selectingGait,
    askedQuestionIds: const {},
    startedAt: now,
    updatedAt: now,
  );
  if (bonuses) state = const GameEngine().ensureBonusLayout(state);
  return state;
}

/// One whole game. Every rider answers right with probability
/// [accuracy] and places like a sensible family player: an arrival, a
/// capture, a bonus square, then the horse farthest along. Returns the
/// number of cards drawn.
int _simulate(GameState start, Random random, {double accuracy = 0.7}) {
  const engine = GameEngine();
  var state = start;
  var guard = 0;
  while (state.turnPhase != TurnPhase.gameOver && guard++ < 5000) {
    // A journey question owed from a previous turn.
    for (final h in engine.horsesAwaitingJourneyQuestion(state.currentPlayer)) {
      state = engine.answerJourneyQuestion(
        state,
        correct: random.nextDouble() < accuracy,
        questionId: 'j$guard',
        horseIndex: h,
      );
      if (state.turnPhase == TurnPhase.gameOver) return state.drawCount;
      break;
    }
    state = engine.drawCard(state, MovementChoice(1 + random.nextInt(6)));
    state = engine.applyAnswer(
      state,
      correct: random.nextDouble() < accuracy,
      questionId: 'q$guard',
    );
    if (state.lastAnswerCorrect == true) {
      state = engine.openPlacement(state);
      if (state.turnPhase == TurnPhase.choosingHorse) {
        final moves = engine.legalMoves(state, state.drawnCard!);
        LegalMove best = moves.first;
        var bestScore = -1.0;
        for (final m in moves) {
          var score = 0.0;
          if (m.reachesFinish) score += 100;
          if (m.capturesOpponent) score += 60;
          if (m.bonusValue != null) score += 30 + m.bonusValue!;
          if (m.exitsStable) score += 20;
          final p = state.circuit.progressOf(m.destination, state.currentPlayerIndex) ?? 0;
          score += p * 0.1;
          if (score > bestScore) {
            bestScore = score;
            best = m;
          }
        }
        state = engine.placeHorse(state, best.horseIndex);
        state = engine.applyPendingBonus(state);
        state = engine.completeMove(state);
        for (final h in engine.horsesAwaitingJourneyQuestion(state.currentPlayer)) {
          state = engine.answerJourneyQuestion(
            state,
            correct: random.nextDouble() < accuracy,
            questionId: 'j$guard',
            horseIndex: h,
          );
          break;
        }
        // Interactive squares: declined — they are optional and rare.
        if (state.pendingCellEffect != null) state = engine.declineCellOffer(state);
      }
    }
    if (state.turnPhase != TurnPhase.gameOver) state = engine.endTurn(state);
  }
  return state.drawCount;
}

({double mean, int median, int p90}) _stats(List<int> xs) {
  final sorted = [...xs]..sort();
  final mean = sorted.fold<int>(0, (a, b) => a + b) / sorted.length;
  return (
    mean: mean,
    median: sorted[sorted.length ~/ 2],
    p90: sorted[(sorted.length * 0.9).floor().clamp(0, sorted.length - 1)],
  );
}

void main() {
  const games = 120;
  final configs = <({String name, int players, GameVariant variant, CircuitId circuit})>[
    (name: '2 riders, quick (1 horse home)', players: 2, variant: GameVariant.quick, circuit: CircuitId.oasisRoute),
    (name: '2 riders, classic (4 horses)', players: 2, variant: GameVariant.classic, circuit: CircuitId.oasisRoute),
    (name: '4 riders, quick', players: 4, variant: GameVariant.quick, circuit: CircuitId.caravanTrail),
    (name: '4 riders, classic', players: 4, variant: GameVariant.classic, circuit: CircuitId.greatRide),
  ];

  test('bonus squares shorten every format, without deciding it', () {
    final lines = <String>[];
    for (final c in configs) {
      final without = <int>[];
      final with_ = <int>[];
      for (var g = 0; g < games; g++) {
        without.add(_simulate(
          _game(players: c.players, variant: c.variant, circuit: c.circuit, seed: g, bonuses: false),
          Random(1000 + g),
        ));
        with_.add(_simulate(
          _game(players: c.players, variant: c.variant, circuit: c.circuit, seed: g, bonuses: true),
          Random(1000 + g),
        ));
      }
      final a = _stats(without);
      final b = _stats(with_);
      final gain = 1 - b.mean / a.mean;
      lines.add(
        '${c.name.padRight(34)} draws without: mean ${a.mean.toStringAsFixed(0)} '
        '(median ${a.median}, p90 ${a.p90}) | with bonuses: mean ${b.mean.toStringAsFixed(0)} '
        '(median ${b.median}, p90 ${b.p90}) | -${(gain * 100).toStringAsFixed(0)}%',
      );
      // Shorter — clearly — but still a race: a bonus layout must not
      // halve a game into a lottery.
      expect(gain, greaterThan(0.08), reason: '${c.name}: bonuses did not shorten the game');
      expect(gain, lessThan(0.5), reason: '${c.name}: bonuses dominate the race');
    }
    // ignore: avoid_print
    print('\nGame length (cards drawn, $games games each, 70% accuracy)\n${lines.join('\n')}\n');
  });

  test('a two-rider quick race with bonuses fits a family evening', () {
    final draws = <int>[];
    for (var g = 0; g < games; g++) {
      draws.add(_simulate(
        _game(players: 2, variant: GameVariant.quick, circuit: CircuitId.oasisRoute, seed: g, bonuses: true),
        Random(7000 + g),
      ));
    }
    final s = _stats(draws);
    // Fifty cards is the free edition's whole race: the median quick
    // game should fit inside it, and even a slow one stay near it.
    expect(s.median, lessThanOrEqualTo(GameState.freeDrawLimit));
    expect(s.p90, lessThan(GameState.freeDrawLimit * 2));
  });
}
