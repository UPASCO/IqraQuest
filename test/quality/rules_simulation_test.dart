// Whole games, played to the end through the real engine, with the rules
// checked on **every single turn**.
//
// A unit test proves one rule on one board. This proves they hold
// together: hundreds of complete races, every legal move inspected before
// it is played and every position inspected after, so a rule that is
// right on its own but wrong in company (a bonus chain that walks a horse
// past the oasis, a capture that pays nothing, two of a colour sharing a
// square) fails here rather than on somebody's phone.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/game/domain/game_engine.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/theme/app_team.dart';

const _teams = [AppTeam.emerald, AppTeam.saphir, AppTeam.grenat, AppTeam.safran];
const _engine = GameEngine();

GameState _newGame({
  required int players,
  required GameVariant variant,
  required CircuitId circuit,
  required int seed,
}) {
  final now = DateTime(2026, 1, 1);
  var state = GameState(
    gameId: 'rules_$seed',
    gameMode: GameMode.family,
    gameVariant: variant,
    circuitId: circuit,
    players: [
      for (var i = 0; i < players; i++)
        Player(
          id: 'p$i',
          name: 'P$i',
          team: _teams[i],
          horses: List.generate(
            variant.horsesPerPlayer,
            (_) => const HorseState(),
          ),
        ),
    ],
    currentPlayerIndex: 0,
    turnPhase: TurnPhase.selectingGait,
    askedQuestionIds: const {},
    bonusSeed: seed,
    startedAt: now,
    updatedAt: now,
  );
  state = _engine.ensureBonusLayout(state);
  return state.copyWith(
    players: _engine.openingLineUp(state.players, state.circuit),
  );
}

/// What one simulated race saw, so the suite can also say the rules were
/// actually exercised rather than merely never broken.
class Tally {
  int draws = 0;
  int captures = 0;
  int captureBonuses = 0;
  int bonusRides = 0;
  int chainsOfTwoOrMore = 0;
  int arrivals = 0;
  int blockedByExactCount = 0;
  int longestChain = 0;
}

/// Every rule that must be true of a board, whatever just happened to it.
void _checkBoard(GameState state, String where) {
  final circuit = state.circuit;
  for (var p = 0; p < state.players.length; p++) {
    final horses = state.players[p].horses;
    for (var h = 0; h < horses.length; h++) {
      final position = horses[h].position;
      // No horse is ever past the end of its own journey.
      final progress = circuit.progressOf(position, p);
      if (progress != null) {
        expect(
          progress,
          lessThanOrEqualTo(circuit.journeyLength),
          reason: '$where: p$p h$h stands beyond the finish',
        );
      }
      if (position is FinalLanePosition) {
        expect(position.step, inInclusiveRange(1, circuit.finalLaneLength));
      }
      if (position is TrackPosition) {
        expect(position.index, inInclusiveRange(0, circuit.trackLength - 1));
      }
      // Two of a colour never share a square on the course. The stable
      // holds them all, and the centre takes every arrival.
      if (position is TrackPosition || position is FinalLanePosition) {
        for (var o = h + 1; o < horses.length; o++) {
          expect(
            horses[o].position == position,
            isFalse,
            reason: '$where: p$p has two horses on $position',
          );
        }
      }
    }
  }
}

/// Plays one whole race, checking the rules as it goes.
Tally _race(GameState start, Random random, {double accuracy = 0.7}) {
  final tally = Tally();
  var state = start;
  var guard = 0;

  while (state.turnPhase != TurnPhase.gameOver && guard++ < 6000) {
    _checkBoard(state, 'turn $guard');

    // A journey question owed from an earlier turn.
    for (final h in _engine.horsesAwaitingJourneyQuestion(state.currentPlayer)) {
      state = _engine.answerJourneyQuestion(
        state,
        correct: random.nextDouble() < accuracy,
        questionId: 'j$guard',
        horseIndex: h,
      );
      break;
    }
    if (state.turnPhase == TurnPhase.gameOver) break;

    final card = MovementChoice(1 + random.nextInt(6));
    state = _engine.drawCard(state, card);
    tally.draws++;
    state = _engine.applyAnswer(
      state,
      correct: random.nextDouble() < accuracy,
      questionId: 'q$guard',
    );

    if (state.lastAnswerCorrect == true) {
      final teamIndex = state.currentPlayerIndex;
      final circuit = state.circuit;
      final before = state.currentPlayer.horses;
      final moves = _engine.legalMoves(state, card);

      // Every offered move rides *exactly* the card, and never overshoots.
      for (final m in moves) {
        final from = circuit.progressOf(before[m.horseIndex].position, teamIndex);
        final to = circuit.progressOf(m.destination, teamIndex);
        expect(to, isNotNull);
        if (m.exitsStable) {
          expect(from, isNull, reason: 'only a stabled horse exits');
          expect(to, 0, reason: 'the exit lands on the start square');
        } else {
          final steps = card.steps + (m.usesGrandGallop ? 2 : 0);
          expect(
            to,
            from! + steps,
            reason: 'a $card must move exactly its own squares',
          );
        }
        expect(
          to,
          lessThanOrEqualTo(circuit.journeyLength),
          reason: 'no move may carry a horse past the finish',
        );
        expect(m.reachesFinish, to == circuit.journeyLength);
      }
      // A horse in the lane that the card would overshoot is simply not
      // offered — that is the exact count, seen from the other side.
      for (var h = 0; h < before.length; h++) {
        final from = circuit.progressOf(before[h].position, teamIndex);
        if (from == null || before[h].isFinished) continue;
        if (from + card.steps > circuit.journeyLength) {
          expect(
            moves.where((m) => m.horseIndex == h),
            isEmpty,
            reason: 'a $card overshoots from $from and must not be offered',
          );
          tally.blockedByExactCount++;
        }
      }

      state = _engine.openPlacement(state);
      if (state.turnPhase == TurnPhase.choosingHorse) {
        // Play like a sensible family player.
        var best = moves.first;
        var bestScore = -1.0;
        for (final m in moves) {
          var score = 0.0;
          if (m.reachesFinish) score += 100;
          if (m.capturesOpponent) score += 60;
          if (m.bonusValue != null) score += 30 + m.bonusValue!;
          if (m.exitsStable) score += 20;
          score += (circuit.progressOf(m.destination, teamIndex) ?? 0) * 0.1;
          if (score > bestScore) {
            bestScore = score;
            best = m;
          }
        }
        state = _engine.placeHorse(state, best.horseIndex);
        _checkBoard(state, 'after the drop on turn $guard');

        // Sending an opponent home always pays its bond of twenty.
        if (state.lastMoveOutcome == MoveOutcome.captured) {
          tally.captures++;
          expect(
            state.pendingBonus?.fromCapture,
            isTrue,
            reason: 'a capture pays $kCaptureBonus',
          );
          expect(state.pendingBonus?.value, kCaptureBonus);
          tally.captureBonuses++;
        }

        // Ride out the whole chain.
        var chain = 0;
        final firedBefore = <int>{};
        while (state.pendingBonus != null) {
          final bonus = state.pendingBonus!;
          if (!bonus.fromCapture) {
            expect(
              firedBefore.add(bonus.trackIndex),
              isTrue,
              reason: 'square ${bonus.trackIndex} fired twice in one turn',
            );
          }
          final wasCaptured = state.lastMoveOutcome == MoveOutcome.captured;
          state = _engine.applyPendingBonus(state);
          chain++;
          tally.bonusRides++;
          expect(chain, lessThan(24), reason: 'a bonus chain must end');
          _checkBoard(state, 'after a bonus ride on turn $guard');
          if (!wasCaptured && state.lastMoveOutcome == MoveOutcome.captured) {
            tally.captures++;
            tally.captureBonuses++;
            expect(state.pendingBonus?.fromCapture, isTrue);
          }
        }
        if (chain >= 2) tally.chainsOfTwoOrMore++;
        if (chain > tally.longestChain) tally.longestChain = chain;

        state = _engine.completeMove(state);
        for (final h in _engine.horsesAwaitingJourneyQuestion(
          state.currentPlayer,
        )) {
          tally.arrivals++;
          state = _engine.answerJourneyQuestion(
            state,
            correct: random.nextDouble() < accuracy,
            questionId: 'j$guard',
            horseIndex: h,
          );
          break;
        }
        if (state.pendingCellEffect != null) {
          state = _engine.declineCellOffer(state);
        }
      }
    }
    if (state.turnPhase != TurnPhase.gameOver) {
      state = _engine.endTurn(state);
      // A new turn starts with a clean slate of spent squares.
      expect(state.firedBonusTracks, isEmpty);
      expect(state.pendingBonus, isNull);
    }
  }

  expect(
    state.turnPhase,
    TurnPhase.gameOver,
    reason: 'the race never finished — the loop wedged',
  );
  expect(state.winnerId, isNotNull);
  return tally;
}

void main() {
  final configs =
      <({String name, int players, GameVariant variant, CircuitId circuit})>[
        (
          name: '2 riders, quick',
          players: 2,
          variant: GameVariant.quick,
          circuit: CircuitId.oasisRoute,
        ),
        (
          name: '4 riders, quick',
          players: 4,
          variant: GameVariant.quick,
          circuit: CircuitId.caravanTrail,
        ),
        (
          name: '2 riders, classic',
          players: 2,
          variant: GameVariant.classic,
          circuit: CircuitId.greatRide,
        ),
        (
          name: '4 riders, classic',
          players: 4,
          variant: GameVariant.classic,
          circuit: CircuitId.oasisRoute,
        ),
      ];

  test('the rules hold over hundreds of complete races', () {
    final total = Tally();
    var races = 0;
    for (final c in configs) {
      for (var g = 0; g < 40; g++) {
        final t = _race(
          _newGame(
            players: c.players,
            variant: c.variant,
            circuit: c.circuit,
            seed: g,
          ),
          Random(4200 + g),
          // A whole range of tables, from a struggling reader to an
          // expert: the rules must hold at every pace.
          accuracy: 0.45 + (g % 5) * 0.12,
        );
        races++;
        total.draws += t.draws;
        total.captures += t.captures;
        total.captureBonuses += t.captureBonuses;
        total.bonusRides += t.bonusRides;
        total.chainsOfTwoOrMore += t.chainsOfTwoOrMore;
        total.arrivals += t.arrivals;
        total.blockedByExactCount += t.blockedByExactCount;
        if (t.longestChain > total.longestChain) {
          total.longestChain = t.longestChain;
        }
      }
    }

    // The rules were not merely unbroken — they were exercised.
    expect(total.captures, greaterThan(100), reason: 'no captures happened');
    expect(
      total.captureBonuses,
      total.captures,
      reason: 'every capture must pay its bond',
    );
    expect(total.bonusRides, greaterThan(500));
    expect(
      total.chainsOfTwoOrMore,
      greaterThan(50),
      reason: 'bonuses never chained: the chain is untested',
    );
    expect(
      total.blockedByExactCount,
      greaterThan(100),
      reason: 'the exact count never bit: the final lane is untested',
    );
    expect(total.arrivals, greaterThan(100));

    // ignore: avoid_print
    print(
      '\n$races races, ${total.draws} cards: '
      '${total.captures} captures (each paying $kCaptureBonus), '
      '${total.bonusRides} bonus rides, '
      '${total.chainsOfTwoOrMore} chains of 2+ (longest ${total.longestChain}), '
      '${total.arrivals} arrivals, '
      '${total.blockedExactLabel}\n',
    );
  });
}

extension on Tally {
  String get blockedExactLabel =>
      '$blockedByExactCount cards refused by the exact count';
}
