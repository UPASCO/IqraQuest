import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/game/domain/game_engine.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/services/board_effect_service.dart';
import 'package:iqraquest/services/movement_choice_service.dart';
import 'package:iqraquest/theme/app_team.dart';

/// Spec §20 — the rules that must hold for the gait mechanic that replaced
/// the dice. Every assertion here is about determinism: what a player
/// chooses is what happens, and nothing on the board rolls anything.

const _teams = [
  AppTeam.emerald,
  AppTeam.saphir,
  AppTeam.grenat,
  AppTeam.safran,
];

GameState buildGame({
  int playerCount = 2,
  GameVariant variant = GameVariant.classic,
  CircuitId circuitId = CircuitId.oasisRoute,
  TurnPhase phase = TurnPhase.selectingGait,
  PlayerProfile profile = PlayerProfile.intermediate,
}) {
  final players = List.generate(
    playerCount,
    (i) => Player(
      id: 'p$i',
      name: 'Player $i',
      team: _teams[i],
      profile: profile,
      horses: List.generate(variant.horsesPerPlayer, (_) => const HorseState()),
    ),
  );
  final now = DateTime(2026, 1, 1);
  return GameState(
    gameId: 'g1',
    gameMode: GameMode.family,
    gameVariant: variant,
    circuitId: circuitId,
    players: players,
    currentPlayerIndex: 0,
    turnPhase: phase,
    askedQuestionIds: const {},
    startedAt: now,
    updatedAt: now,
  );
}

GameState withHorse(
  GameState state, {
  int player = 0,
  int horse = 0,
  PawnPosition? at,
  bool? shield,
  bool? awaitingJourneyQuestion,
}) {
  final players = [...state.players];
  final p = players[player];
  final horses = [...p.horses];
  horses[horse] = horses[horse].copyWith(
    position: at,
    hasShield: shield,
    awaitingJourneyQuestion: awaitingJourneyQuestion,
  );
  players[player] = p.copyWith(horses: horses);
  return state.copyWith(players: players);
}

/// One complete turn beat: draw the card, answer its question and — on a
/// right answer — set [horse] down on its destination, riding any bonus
/// square it stopped on. A horse that cannot ride the card (the stable
/// gate shut on anything but a 6) simply stays: the engine never moves
/// what the rules would not let a player move.
GameState play(
  GameEngine engine,
  GameState state, {
  int horse = 0,
  required int steps,
  required bool correct,
  required String questionId,
}) {
  var next = engine.drawCard(state, MovementChoice(steps));
  next = engine.applyAnswer(next, correct: correct, questionId: questionId);
  if (!correct) return next;
  next = engine.openPlacement(next);
  if (next.turnPhase != TurnPhase.choosingHorse) return next;
  next = engine.placeHorse(next, horse);
  return engine.applyPendingBonus(next);
}

void main() {
  const engine = GameEngine();

  group('No randomness anywhere in progression', () {
    test('the engine source contains no random number generator', () {
      // The strongest possible form of "aucun déplacement n'est généré
      // aléatoirement": the rules file cannot even reach for a Random.
      final source = File('lib/features/game/domain/game_engine.dart')
          .readAsStringSync();
      expect(source, isNot(contains('Random')));
      expect(source, isNot(contains('dart:math')));
    });

    test('no dice API survives anywhere in the library', () {
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        // The migration service must still be able to *describe* the old
        // dice-based save format it detects; that is the one exception.
        if (entity.path.endsWith('legacy_game_migration_service.dart')) {
          continue;
        }
        if (entity.path.contains('l10n/generated')) continue;
        final source = entity.readAsStringSync();
        for (final banned in const [
          'rollDice',
          'DiceWidget',
          'lastDiceValue',
          'waitingForDice',
        ]) {
          if (source.contains(banned)) offenders.add('${entity.path}: $banned');
        }
      }
      expect(offenders, isEmpty, reason: 'Dice API remnants: $offenders');
    });

    test('replaying the same choices yields byte-identical positions', () {
      GameState run() {
        var state = buildGame();
        state = play(engine, state, steps: 3, correct: true, questionId: 'q1');
        state = engine.endTurn(state);
        state = play(engine, state, steps: 5, correct: true, questionId: 'q2');
        state = engine.endTurn(state);
        state = play(engine, state, steps: 2, correct: false, questionId: 'q3');
        return state;
      }

      final a = run();
      final b = run();
      for (var p = 0; p < a.players.length; p++) {
        expect(
          a.players[p].horses.map((h) => h.position).toList(),
          b.players[p].horses.map((h) => h.position).toList(),
        );
        expect(a.players[p].streak, b.players[p].streak);
      }
    });
  });

  group('Gaits: the player chooses both distance and difficulty', () {
    test('all six gaits 1..6 exist and are offered at the start', () {
      final state = buildGame();
      expect(engine.availableGaits(state.currentPlayer).map((c) => c.steps), [
        1,
        2,
        3,
        4,
        5,
        6,
      ]);
    });

    test('the question level is the rider\'s, never the card\'s', () {
      const service = MovementChoiceService();
      for (final card in MovementChoice.all) {
        expect(
          service.difficultyFor(card, PlayerProfile.easy),
          QuestionDifficulty.easy,
        );
        expect(
          service.difficultyFor(card, PlayerProfile.intermediate),
          QuestionDifficulty.medium,
        );
        expect(
          service.difficultyFor(card, PlayerProfile.expert),
          QuestionDifficulty.hard,
        );
      }
    });

    test('knowledge points scale with the level played', () {
      // A fixed level always scores its own, whatever level the card
      // happened to be drawn at.
      expect(PlayerProfile.easy.knowledgePointsFor(null), 1);
      expect(PlayerProfile.intermediate.knowledgePointsFor(null), 2);
      expect(PlayerProfile.expert.knowledgePointsFor(null), 3);
      expect(
        PlayerProfile.easy.knowledgePointsFor(QuestionDifficulty.hard),
        1,
        reason: 'an easy rider never scores an expert answer',
      );
    });

    test('applyAnswer pays a mixed rider by the level it asked', () {
      var state = buildGame(profile: PlayerProfile.mixed);
      state = engine.drawCard(state, const MovementChoice(3));
      state = engine.applyAnswer(
        state,
        correct: true,
        questionId: 'q-hard',
        askedLevel: QuestionDifficulty.hard,
      );
      expect(state.players[0].rewards.knowledgePoints, 3);

      // A fixed level ignores the level asked and scores its own.
      var fixed = buildGame(profile: PlayerProfile.easy);
      fixed = engine.drawCard(fixed, const MovementChoice(3));
      fixed = engine.applyAnswer(
        fixed,
        correct: true,
        questionId: 'q-hard',
        askedLevel: QuestionDifficulty.hard,
      );
      expect(fixed.players[0].rewards.knowledgePoints, 1);
    });

    test('the mixed level scores the level the card actually asked', () {
      expect(PlayerProfile.mixed.difficulty, isNull);
      expect(PlayerProfile.mixed.isMixed, isTrue);
      expect(
        PlayerProfile.mixed.knowledgePointsFor(QuestionDifficulty.easy),
        1,
      );
      expect(
        PlayerProfile.mixed.knowledgePointsFor(QuestionDifficulty.medium),
        2,
      );
      expect(
        PlayerProfile.mixed.knowledgePointsFor(QuestionDifficulty.hard),
        3,
      );
    });

    test('a value can come up again immediately, exactly as a die repeats', () {
      // The distance now comes from drawing a question card, not from
      // the player picking a gait, so nothing is ever spent. A deck that
      // refused a value it had just produced would not be a die.
      var state = buildGame();
      state = play(engine, state, steps: 4, correct: true, questionId: 'q1');
      expect(engine.availableGaits(state.currentPlayer).map((c) => c.steps), [
        1,
        2,
        3,
        4,
        5,
        6,
      ]);

      final again = engine.drawCard(state, const MovementChoice(4));
      expect(again.drawnCard?.steps, 4);
      expect(again.turnPhase, TurnPhase.answeringQuestion);
    });

    test('a wrong answer costs the move, not the value', () {
      var state = buildGame();
      state = play(engine, state, steps: 6, correct: false, questionId: 'q1');
      expect(engine.availableGaits(state.currentPlayer).map((c) => c.steps), [
        1,
        2,
        3,
        4,
        5,
        6,
      ]);
    });
  });

  group('Answering decides movement', () {
    test('a correct answer advances exactly the chosen number of squares', () {
      var state = buildGame();
      // Leaving the stable costs the move itself: the 6 lands on the entry.
      state = play(engine, state, steps: 6, correct: true, questionId: 'q1');
      expect(state.players[0].horses[0].position, const TrackPosition(0));

      state = engine.endTurn(state); // the 6 replays: still player 0
      expect(state.currentPlayerIndex, 0);
      state = play(engine, state, steps: 4, correct: true, questionId: 'q2');
      expect(state.players[0].horses[0].position, const TrackPosition(4));
      expect(state.lastMoveOutcome, MoveOutcome.moved);
    });

    test(
      'a horse leaving the stable lands on its start square, whatever the card',
      () {
        var state = buildGame();
        state = play(engine, state, steps: 6, correct: true, questionId: 'q1');
        expect(state.players[0].horses[0].position, const TrackPosition(0));
        expect(state.lastMoveOutcome, MoveOutcome.exitedStable);
      },
    );

    test('a wrong answer leaves the horse exactly where it stood', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(7));
      state = play(engine, state, steps: 5, correct: false, questionId: 'q1');
      expect(state.players[0].horses[0].position, const TrackPosition(7));
      expect(state.lastMoveOutcome, MoveOutcome.stayed);
      expect(state.lastAnswerCorrect, isFalse);
    });

    test('a wrong answer is never a setback', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(3), shield: true);
      final before = state.players[0];
      state = play(engine, state, steps: 6, correct: false, questionId: 'q1');
      final after = state.players[0];
      expect(after.horses[0].position, before.horses[0].position);
      expect(after.horses[0].hasShield, isTrue);
      expect(after.rewards.knowledgePoints, before.rewards.knowledgePoints);
    });

    test('questions are never repeated within a game', () {
      var state = buildGame();
      state = play(engine, state, steps: 1, correct: true, questionId: 'q1');
      state = engine.endTurn(state);
      state = play(engine, state, steps: 2, correct: false, questionId: 'q2');
      expect(state.askedQuestionIds, {'q1', 'q2'});
    });
  });

  group('Preview: nothing is ever a surprise', () {
    test('the preview destination is exactly where the horse lands', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(2));
      final preview = engine.previewGait(state, 0, const MovementChoice(3));
      final after = play(
        engine,
        state,
        steps: 3,
        correct: true,
        questionId: 'q1',
      );
      expect(after.players[0].horses[0].position, preview.destination);
    });

    test('the preview announces the square effect that actually applies', () {
      var state = buildGame();
      // Oasis Route quadrant (14 squares): 0 oasis, 4 knowledge,
      // 8 wisdom, 11 oasis.
      state = withHorse(state, at: const TrackPosition(0));
      final preview = engine.previewGait(state, 0, const MovementChoice(4));
      expect(preview.destination, const TrackPosition(4));
      expect(preview.effect, CellEffect.knowledge);
      final after = play(
        engine,
        state,
        steps: 4,
        correct: true,
        questionId: 'q1',
      );
      expect(after.landedEffect, preview.effect);
    });

    test('the preview warns about a capture before the player commits', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(0));
      state = withHorse(state, player: 1, at: const TrackPosition(1));
      final preview = engine.previewGait(state, 0, const MovementChoice(1));
      expect(preview.capturesOpponent, isTrue);
    });
  });

  group('Capture and shields', () {
    test('landing on an opponent sends it calmly back to the stable', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(0));
      state = withHorse(state, player: 1, at: const TrackPosition(1));
      state = play(engine, state, steps: 1, correct: true, questionId: 'q1');
      expect(state.players[1].horses[0].position, const HomePosition());
      expect(state.lastMoveOutcome, MoveOutcome.captured);
    });

    test('an Oasis square protects the horse standing on it, and says so', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(10));
      state = withHorse(state, player: 1, at: const TrackPosition(11));
      expect(Circuit.oasisRoute.effectAt(11), CellEffect.oasis);
      expect(Circuit.oasisRoute.isSafe(11), isTrue);
      state = play(engine, state, steps: 1, correct: true, questionId: 'q1');
      expect(state.players[1].horses[0].position, const TrackPosition(11));
      // Not `moved`: two horses share the square and the table has to be
      // told why nobody went home, or the shelter reads as a capture
      // that silently failed.
      expect(state.lastMoveOutcome, MoveOutcome.shelteredByOasis);
    });

    test('an ordinary landing on an empty square is still just a move', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(10));
      expect(Circuit.oasisRoute.isSafe(11), isTrue);
      state = play(engine, state, steps: 1, correct: true, questionId: 'q1');
      // The same Oasis, with nobody on it: nothing to shelter.
      expect(state.lastMoveOutcome, MoveOutcome.moved);
    });

    test('a capture made on a bonus ride still pays its twenty', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(0));
      state = withHorse(state, player: 1, at: const TrackPosition(1));
      state = engine.drawCard(state, const MovementChoice(1));
      state = engine.applyAnswer(state, correct: true, questionId: 'q1');
      state = engine.openPlacement(state);
      state = engine.placeHorse(state, 0);
      expect(state.lastMoveOutcome, MoveOutcome.captured);
      expect(state.pendingBonus?.value, kCaptureBonus);

      // A second opponent horse exactly twenty squares along, on a
      // square that does not shelter it: riding the first capture's
      // twenty lands on it and must pay a second twenty.
      state = withHorse(
        state,
        player: 1,
        horse: 1,
        at: const TrackPosition(21),
      );
      expect(Circuit.oasisRoute.isSafe(21), isFalse);
      final ridden = engine.applyPendingBonus(state);
      expect(ridden.players[1].horses[1].position, const HomePosition());
      expect(ridden.lastMoveOutcome, MoveOutcome.captured);
      expect(ridden.pendingBonus?.value, kCaptureBonus);
      expect(ridden.pendingBonus?.fromCapture, isTrue);
    });

    test('a bonus ride onto a sheltered horse says the Oasis held', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(0));
      state = withHorse(state, player: 1, at: const TrackPosition(1));
      state = engine.drawCard(state, const MovementChoice(1));
      state = engine.applyAnswer(state, correct: true, questionId: 'q1');
      state = engine.openPlacement(state);
      state = engine.placeHorse(state, 0);
      // The twenty it just earned would land on square 21; park an
      // opponent on the Oasis at 24 and ride a shorter, plain bonus.
      expect(Circuit.oasisRoute.isSafe(24), isTrue);
      state = withHorse(
        state,
        player: 1,
        horse: 1,
        at: const TrackPosition(24),
      );
      state = state.copyWith(
        pendingBonus: PendingBonus(
          horseIndex: 0,
          trackIndex: 1,
          value: 23,
          fromCapture: true,
        ),
      );
      final ridden = engine.applyPendingBonus(state);
      expect(ridden.players[1].horses[1].position, const TrackPosition(24));
      expect(ridden.lastMoveOutcome, MoveOutcome.shelteredByOasis);
    });

    test('a knowledge shield absorbs one capture and is then spent', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(0));
      state = withHorse(
        state,
        player: 1,
        at: const TrackPosition(1),
        shield: true,
      );
      state = play(engine, state, steps: 1, correct: true, questionId: 'q1');
      expect(state.players[1].horses[0].position, const TrackPosition(1));
      expect(state.players[1].horses[0].hasShield, isFalse);
      expect(state.lastMoveOutcome, MoveOutcome.blockedByShield);
    });

    test('the private final lane can never be captured on', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(50));
      state = withHorse(state, player: 1, at: const FinalLanePosition(1));
      final preview = engine.previewGait(state, 0, const MovementChoice(3));
      expect(preview.destination, isA<FinalLanePosition>());
      expect(preview.capturesOpponent, isFalse);
    });
  });

  group('Knowledge streak: bonuses come only from knowing', () {
    test('three correct answers in a row grant a shield', () {
      var state = buildGame();
      state = play(engine, state, steps: 1, correct: true, questionId: 'q1');
      state = play(engine, state, steps: 2, correct: true, questionId: 'q2');
      expect(state.players[0].horses[0].hasShield, isFalse);
      state = play(engine, state, steps: 3, correct: true, questionId: 'q3');
      expect(state.players[0].streak.current, 3);
      expect(state.justUnlocked, contains(StreakReward.shield));
      expect(state.players[0].horses[0].hasShield, isTrue);
    });

    test('five correct answers in a row grant the Grand Galop', () {
      var state = buildGame();
      for (var steps = 1; steps <= 5; steps++) {
        state = play(
          engine,
          state,
          steps: steps,
          correct: true,
          questionId: 'q$steps',
        );
      }
      expect(state.players[0].streak.current, 5);
      expect(state.players[0].rewards.hasGrandGallop, isTrue);
    });

    test('the Grand Galop adds exactly 2 squares, only to arrive, and is spent once', () {
      var state = buildGame(variant: GameVariant.quick);
      final players = [...state.players];
      players[0] = players[0].copyWith(
        rewards: players[0].rewards.copyWith(hasGrandGallop: true),
      );
      state = state.copyWith(players: players);

      // On the open road the two squares would change nothing: the
      // Galop is kept.
      var road = withHorse(state, at: const TrackPosition(1));
      expect(engine.legalMoves(road, const MovementChoice(3)).single.usesGrandGallop, isFalse);
      road = play(engine, road, steps: 3, correct: true, questionId: 'q1');
      expect(road.players[0].horses[0].position, const TrackPosition(4));
      expect(road.players[0].rewards.hasGrandGallop, isTrue);

      // Two short of the finish, the Galop turns the ride into an arrival
      // — and is spent. Under the exact count the two squares have to
      // land it exactly: from here that is a 2 plus the Galop.
      var lane = withHorse(state, at: const FinalLanePosition(2));
      final move = engine.legalMoves(lane, const MovementChoice(2)).single;
      expect(move.usesGrandGallop, isTrue);
      expect(move.reachesFinish, isTrue);
      lane = play(engine, lane, steps: 2, correct: true, questionId: 'q1');
      expect(lane.players[0].horses[0].position, isA<FinishedPosition>());
      expect(lane.players[0].rewards.hasGrandGallop, isFalse);
    });

    test('ten correct answers in a row unlock a mastery badge', () {
      var state = buildGame();
      var asked = 0;
      for (var cycle = 0; cycle < 2; cycle++) {
        for (var steps = 1; steps <= 5; steps++) {
          state = play(
            engine,
            state,
            steps: steps,
            correct: true,
            questionId: 'q${asked++}',
          );
        }
        // Spend the sixth gait too, so the cycle refills cleanly.
        state = play(
          engine,
          state,
          steps: 6,
          correct: true,
          questionId: 'q${asked++}',
        );
      }
      expect(state.players[0].streak.current, greaterThanOrEqualTo(10));
      expect(state.players[0].streak.best, greaterThanOrEqualTo(10));
    });

    test('a wrong answer resets the run but never takes a reward back', () {
      var state = buildGame();
      state = play(engine, state, steps: 1, correct: true, questionId: 'q1');
      state = play(engine, state, steps: 2, correct: true, questionId: 'q2');
      state = play(engine, state, steps: 3, correct: true, questionId: 'q3');
      expect(state.players[0].horses[0].hasShield, isTrue);

      state = play(engine, state, steps: 4, correct: false, questionId: 'q4');
      expect(state.players[0].streak.current, 0);
      expect(state.players[0].streak.best, 3);
      expect(
        state.players[0].horses[0].hasShield,
        isTrue,
        reason: 'rewards are never revoked',
      );
    });

    test(
      'knowledge points accumulate by the level played, whatever the card',
      () {
        var state = buildGame(profile: PlayerProfile.expert);
        state = play(
          engine,
          state,
          steps: 6,
          correct: true,
          questionId: 'q1',
        ); // +3
        state = play(
          engine,
          state,
          steps: 1,
          correct: true,
          questionId: 'q2',
        ); // +3
        state = play(
          engine,
          state,
          steps: 3,
          correct: false,
          questionId: 'q3',
        ); // +0
        expect(state.players[0].rewards.knowledgePoints, 6);
        var easy = buildGame(profile: PlayerProfile.easy);
        easy = play(engine, easy, steps: 6, correct: true, questionId: 'q1');
        expect(easy.players[0].rewards.knowledgePoints, 1);
      },
    );
  });

  group('Special squares apply exactly what they announce', () {
    const effects = BoardEffectService();

    test('every quadrant of a circuit carries the identical layout', () {
      for (final circuit in Circuit.all) {
        for (var i = 0; i < circuit.squaresPerQuadrant; i++) {
          final expected = circuit.effectAt(i);
          for (var quadrant = 1; quadrant < 4; quadrant++) {
            expect(
              circuit.effectAt(i + quadrant * circuit.squaresPerQuadrant),
              expected,
              reason:
                  'circuit ${circuit.id.name} square $i differs in quadrant $quadrant',
            );
          }
        }
      }
    });

    test(
      'no starting corner is advantaged: every team meets the same sequence',
      () {
        for (final circuit in Circuit.all) {
          final reference = [
            for (var step = 0; step < circuit.trackLength; step++)
              circuit.effectAt(
                (circuit.entryIndexForTeam(0) + step) % circuit.trackLength,
              ),
          ];
          for (var team = 1; team < 4; team++) {
            final seen = [
              for (var step = 0; step < circuit.trackLength; step++)
                circuit.effectAt(
                  (circuit.entryIndexForTeam(team) + step) %
                      circuit.trackLength,
                ),
            ];
            expect(
              seen,
              reference,
              reason: 'circuit ${circuit.id.name}, team $team',
            );
          }
        }
      },
    );

    test('a Connaissance square grants its point and nothing random', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(0));
      state = play(engine, state, steps: 4, correct: true, questionId: 'q1');
      expect(state.landedEffect, CellEffect.knowledge);
      expect(effects.bonusPointsFor(CellEffect.knowledge), 1);
      expect(effects.isInteractive(CellEffect.knowledge), isFalse);
    });

    test('a Défi adds exactly 2 squares when won and nothing when lost', () {
      var state = buildGame(circuitId: CircuitId.caravanTrail);
      state = withHorse(state, at: const TrackPosition(4));
      state = play(engine, state, steps: 2, correct: true, questionId: 'q1');
      expect(state.landedEffect, CellEffect.challenge);
      expect(state.pendingCellEffect, CellEffect.challenge);

      final won = engine.resolveChallenge(
        state,
        correct: true,
        questionId: 'b1',
      );
      expect(won.players[0].horses[0].position, const TrackPosition(8));
      expect(won.lastMoveOutcome, MoveOutcome.bonusEarned);

      final lost = engine.resolveChallenge(
        state,
        correct: false,
        questionId: 'b1',
      );
      expect(lost.players[0].horses[0].position, const TrackPosition(6));
      expect(lost.lastMoveOutcome, MoveOutcome.bonusMissed);

      // Both verdicts stop on the feedback phase, exactly as the turn's
      // own question and the journey question do. A missed bonus used to
      // go straight back to the board with no word that it had been
      // missed and no correction to read.
      expect(won.turnPhase, TurnPhase.showingFeedback);
      expect(won.lastAnswerCorrect, isTrue);
      expect(lost.turnPhase, TurnPhase.showingFeedback);
      expect(lost.lastAnswerCorrect, isFalse);
    });

    test('a failed Raccourci leaves the horse exactly where it stood', () {
      var state = buildGame(circuitId: CircuitId.greatRide);
      state = withHorse(state, at: const TrackPosition(4));
      state = play(engine, state, steps: 2, correct: true, questionId: 'q1');
      expect(state.landedEffect, CellEffect.shortcut);
      final missed = engine.resolveShortcut(
        state,
        correct: false,
        questionId: 'b1',
        horseIndex: 0,
      );
      expect(missed.players[0].horses[0].position, const TrackPosition(6));
      expect(missed.turnPhase, TurnPhase.showingFeedback);
      expect(missed.lastAnswerCorrect, isFalse);
      expect(missed.lastMoveOutcome, MoveOutcome.bonusMissed);
    });

    test('a Relais hands the earned squares to another of your own horses', () {
      var state = buildGame(circuitId: CircuitId.caravanTrail);
      state = withHorse(state, horse: 0, at: const TrackPosition(7));
      state = withHorse(state, horse: 1, at: const TrackPosition(2));
      final relayed = engine.resolveRelay(
        state,
        fromHorseIndex: 0,
        toHorseIndex: 1,
        steps: 3,
      );
      expect(relayed.players[0].horses[0].position, const TrackPosition(4));
      expect(relayed.players[0].horses[1].position, const TrackPosition(5));
    });

    test('a Duel is decided by knowledge and grants only a shield', () {
      final state = buildGame(circuitId: CircuitId.greatRide);
      final challengerWins = engine.resolveDuel(
        state,
        challengerCorrect: true,
        opponentCorrect: false,
        opponentIndex: 1,
        challengerHorseIndex: 0,
      );
      expect(challengerWins.players[0].horses[0].hasShield, isTrue);
      expect(challengerWins.players[1].horses.any((h) => h.hasShield), isFalse);

      final tie = engine.resolveDuel(
        state,
        challengerCorrect: true,
        opponentCorrect: true,
        opponentIndex: 1,
        challengerHorseIndex: 0,
      );
      expect(
        tie.players.every((p) => p.horses.every((h) => !h.hasShield)),
        isTrue,
      );
    });

    test(
      'Duel and Relais never offer a decision this release cannot resolve',
      () {
        // Their interactive flows have no UI yet, so the squares apply
        // silently whatever the table setup — the engine rules above stay
        // tested and ready for when the screens ship.
        expect(
          effects.isAvailableFor(
            CellEffect.duel,
            playerCount: 1,
            horseCount: 2,
          ),
          isFalse,
        );
        expect(
          effects.isAvailableFor(
            CellEffect.duel,
            playerCount: 2,
            horseCount: 2,
          ),
          isFalse,
        );
        expect(
          effects.isAvailableFor(
            CellEffect.relay,
            playerCount: 2,
            horseCount: 1,
          ),
          isFalse,
        );
        expect(
          effects.isAvailableFor(
            CellEffect.relay,
            playerCount: 2,
            horseCount: 2,
          ),
          isFalse,
        );
        expect(
          effects.isAvailableFor(
            CellEffect.challenge,
            playerCount: 2,
            horseCount: 1,
          ),
          isTrue,
        );
        expect(
          effects.isAvailableFor(
            CellEffect.shortcut,
            playerCount: 2,
            horseCount: 1,
          ),
          isTrue,
        );
      },
    );

    test('a Sagesse square carries no gameplay advantage at all', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(6));
      state = play(engine, state, steps: 2, correct: true, questionId: 'q1');
      expect(state.landedEffect, CellEffect.wisdom);
      expect(effects.bonusPointsFor(CellEffect.wisdom), 0);
      expect(effects.isInteractive(CellEffect.wisdom), isFalse);
    });
  });

  group('Arrival', () {
    test('the finish is reached on an exact count, never by overshooting', () {
      // Three squares from the oasis: only a 3 arrives.
      final start = withHorse(
        buildGame(variant: GameVariant.quick),
        at: const FinalLanePosition(3),
      );
      for (final steps in [4, 5, 6]) {
        expect(
          engine
              .legalMoves(start, MovementChoice(steps))
              .where((m) => m.horseIndex == 0),
          isEmpty,
          reason: 'a \$steps overshoots the finish and moves nothing',
        );
        final tried = play(
          engine,
          start,
          steps: steps,
          correct: true,
          questionId: 'q\$steps',
        );
        // A 6 still opens the stable — what must not happen is the horse
        // in the lane being carried past the oasis.
        expect(tried.players[0].horses[0].position, const FinalLanePosition(3));
      }
      final arrived = play(
        engine,
        start,
        steps: 3,
        correct: true,
        questionId: 'q3',
      );
      expect(arrived.players[0].horses[0].position, isA<FinishedPosition>());
    });

    test('reaching the finish owes a Question du voyage before it counts', () {
      var state = buildGame(variant: GameVariant.quick);
      state = withHorse(state, at: const FinalLanePosition(5));
      state = play(engine, state, steps: 1, correct: true, questionId: 'q1');
      final horse = state.players[0].horses[0];
      expect(horse.isFinished, isTrue);
      expect(horse.awaitingJourneyQuestion, isTrue);
      expect(horse.hasArrived, isFalse);
      expect(state.players[0].hasArrivedCompletely, isFalse);
      expect(engine.horsesAwaitingJourneyQuestion(state.players[0]), [0]);
    });

    test('a missed journey question never pushes the horse back', () {
      var state = buildGame(variant: GameVariant.quick);
      state = withHorse(
        state,
        at: const FinishedPosition(),
        awaitingJourneyQuestion: true,
      );
      state = engine.answerJourneyQuestion(
        state,
        correct: false,
        questionId: 'j1',
        horseIndex: 0,
      );
      expect(state.players[0].horses[0].position, isA<FinishedPosition>());
      expect(state.players[0].horses[0].awaitingJourneyQuestion, isTrue);
      expect(state.winnerId, isNull);
    });

    test(
      'answering the journey question makes the arrival official and wins',
      () {
        var state = buildGame(variant: GameVariant.classic);
        // The other three are already home dry; this one is the last.
        for (var h = 1; h < 4; h++) {
          state = withHorse(state, horse: h, at: const FinishedPosition());
        }
        state = withHorse(
          state,
          at: const FinishedPosition(),
          awaitingJourneyQuestion: true,
        );
        state = engine.answerJourneyQuestion(
          state,
          correct: true,
          questionId: 'j1',
          horseIndex: 0,
        );
        expect(state.players[0].horses[0].hasArrived, isTrue);
        expect(state.winnerId, 'p0');
        expect(state.turnPhase, TurnPhase.gameOver);
      },
    );

    test('four horses in every stable; the classic game is won when all four arrive', () {
      for (final v in GameVariant.values) {
        expect(v.horsesPerPlayer, 4, reason: v.name);
      }
      expect(GameVariant.classic.horsesToWin, 4);
      expect(GameVariant.family.horsesToWin, 4);
      var state = buildGame();
      for (var h = 0; h < 3; h++) {
        state = withHorse(state, horse: h, at: const FinishedPosition());
      }
      expect(engine.hasWon(state, state.players[0]), isFalse);
      expect(engine.endTurn(state).turnPhase, isNot(TurnPhase.gameOver));
      state = withHorse(state, horse: 3, at: const FinishedPosition());
      expect(engine.hasWon(state, state.players[0]), isTrue);
      expect(engine.endTurn(state).winnerId, 'p0');
    });

    test('a quick race is won by the first horse home', () {
      expect(GameVariant.quick.horsesToWin, 1);
      var state = buildGame(variant: GameVariant.quick);
      expect(state.players[0].horses.length, 4);
      state = withHorse(state, at: const FinishedPosition(), awaitingJourneyQuestion: true);
      expect(engine.hasWon(state, state.players[0]), isFalse,
          reason: 'the journey question is still owed');
      state = engine.answerJourneyQuestion(state, correct: true, questionId: 'j1', horseIndex: 0);
      expect(state.turnPhase, TurnPhase.gameOver);
      expect(state.winnerId, 'p0');
    });

    test('the exact count is named when a card overshoots the finish', () {
      // "My horse is three squares from Mecca, I drew a 6, and nothing
      // happened" is the refusal that reads as a bug. The board can now
      // say the number the horse is waiting for.
      var state = buildGame();
      final circuit = state.circuit;
      // Three from the finish, and a card that would carry it past.
      state = withHorse(
        state,
        at: circuit.positionAt(circuit.journeyLength - 3, 0),
      );
      // A 5, not a 6: a 6 would open the stable and there would be a
      // legal move after all — the refusal has to be the count alone.
      state = engine.drawCard(state, const MovementChoice(5));
      state = engine.applyAnswer(state, correct: true, questionId: 'q1');
      expect(engine.legalMoves(state, const MovementChoice(5)), isEmpty);
      expect(engine.exactCountAwaited(state), 3);

      // The card that fits is not a refusal at all.
      var fits = buildGame();
      fits = withHorse(fits, at: circuit.positionAt(circuit.journeyLength - 3, 0));
      fits = engine.drawCard(fits, const MovementChoice(3));
      fits = engine.applyAnswer(fits, correct: true, questionId: 'q2');
      expect(engine.legalMoves(fits, const MovementChoice(3)), isNotEmpty);
      expect(engine.exactCountAwaited(fits), isNull);

      // A stable full of horses is a different refusal, and must not
      // borrow this explanation.
      var stabled = buildGame();
      stabled = engine.drawCard(stabled, const MovementChoice(3));
      stabled = engine.applyAnswer(stabled, correct: true, questionId: 'q3');
      expect(engine.exactCountAwaited(stabled), isNull);
    });

    test('the closest horse to Mecca is the one the count is quoted for', () {
      var state = buildGame();
      final circuit = state.circuit;
      state = withHorse(
        state,
        horse: 0,
        at: circuit.positionAt(circuit.journeyLength - 4, 0),
      );
      state = withHorse(
        state,
        horse: 1,
        at: circuit.positionAt(circuit.journeyLength - 2, 0),
      );
      state = engine.drawCard(state, const MovementChoice(5));
      state = engine.applyAnswer(state, correct: true, questionId: 'q1');
      expect(
        engine.exactCountAwaited(state),
        2,
        reason: 'the horse nearest the finish is the one being waited on',
      );
    });

    test('a duo race is won by the second horse home, not the first', () {
      expect(GameVariant.duo.horsesToWin, 2);
      var state = buildGame(variant: GameVariant.duo);
      state = withHorse(state, horse: 0, at: const FinishedPosition());
      expect(
        engine.hasWon(state, state.players[0]),
        isFalse,
        reason: 'one home is a quick race, not a duo',
      );
      expect(engine.endTurn(state).turnPhase, isNot(TurnPhase.gameOver));
      state = withHorse(state, horse: 1, at: const FinishedPosition());
      expect(engine.hasWon(state, state.players[0]), isTrue);
      expect(engine.endTurn(state).winnerId, 'p0');
      // And the other two never had to leave the stable.
      expect(state.players[0].horses[2].isHome, isTrue);
      expect(state.players[0].horses[3].isHome, isTrue);
    });

    test('the three offered formats ask for one, two and four horses', () {
      expect(
        GameVariantX.choosable.map((v) => v.horsesToWin).toList(),
        [1, 2, 4],
        reason: 'the picker must offer three genuinely different races',
      );
      expect(
        GameVariantX.choosable.contains(GameVariant.family),
        isFalse,
        reason: 'family played exactly like classic and is no longer offered',
      );
    });

    test('every horse must arrive in the classic format', () {
      var state = buildGame();
      state = withHorse(state, horse: 0, at: const FinishedPosition());
      state = withHorse(state, horse: 1, at: const TrackPosition(4));
      expect(state.players[0].hasArrivedCompletely, isFalse);
      expect(engine.endTurn(state).turnPhase, isNot(TurnPhase.gameOver));
    });
  });

  group('The classic stable rules', () {
    test('four horses wait in every stable of a classic game', () {
      final state = buildGame();
      for (final p in state.players) {
        expect(p.horses.length, 4);
        expect(p.horses.every((h) => h.isHome), isTrue);
      }
    });

    test('only a 6 opens the gate', () {
      final state = buildGame();
      for (final value in [1, 2, 3, 4, 5]) {
        expect(
          engine.legalMoves(state, MovementChoice(value)),
          isEmpty,
          reason: 'card $value',
        );
        expect(MovementChoice(value).opensStable, isFalse);
      }
      final moves = engine.legalMoves(state, const MovementChoice(6));
      expect(
        moves.length,
        4,
        reason: 'every stabled horse may come out on a 6',
      );
      expect(moves.every((m) => m.exitsStable), isTrue);
      expect(
        moves.every((m) => m.destination == const TrackPosition(0)),
        isTrue,
      );
    });

    test('a horse on the course rides the card; a horse in the stable needs the gate', () {
      var state = buildGame();
      state = withHorse(state, horse: 0, at: const TrackPosition(3));
      final three = engine.legalMoves(state, const MovementChoice(3));
      expect(three.map((m) => m.horseIndex), [0]);
      expect(three.single.destination, const TrackPosition(6));

      final six = engine.legalMoves(state, const MovementChoice(6));
      expect(six.where((m) => m.exitsStable).length, 3);
      expect(
        six.where((m) => !m.exitsStable).single.destination,
        const TrackPosition(9),
      );
    });

    test('two of your own horses never share a square', () {
      var state = buildGame();
      state = withHorse(state, horse: 0, at: const TrackPosition(2));
      state = withHorse(state, horse: 1, at: const TrackPosition(5));
      final moves = engine.legalMoves(state, const MovementChoice(3));
      // Horse 0 would land on horse 1: not offered. Horse 1 rides on.
      expect(moves.map((m) => m.horseIndex), [1]);
    });

    test('your own horse on the start square keeps the gate shut', () {
      var state = buildGame();
      state = withHorse(state, horse: 0, at: const TrackPosition(0));
      final moves = engine.legalMoves(state, const MovementChoice(6));
      expect(moves.any((m) => m.exitsStable), isFalse);
      expect(moves.single.horseIndex, 0);
    });

    test('a horse coming out captures on its start square, oasis or not', () {
      var state = buildGame();
      expect(
        Circuit.oasisRoute.isSafe(0),
        isTrue,
        reason: 'the start square is an oasis',
      );
      state = withHorse(state, player: 1, at: const TrackPosition(0));
      final exit = engine.legalMoves(state, const MovementChoice(6)).first;
      expect(exit.exitsStable, isTrue);
      expect(exit.capturesOpponent, isTrue);
      state = play(engine, state, steps: 6, correct: true, questionId: 'q1');
      expect(state.players[1].horses[0].position, const HomePosition());
      expect(state.lastMoveOutcome, MoveOutcome.captured);
    });

    test(
      'a card that can move nothing passes the turn, and keeps the 6 replay',
      () {
        var state = buildGame();
        state = engine.drawCard(state, const MovementChoice(3));
        expect(state.turnPhase, TurnPhase.answeringQuestion);
        state = engine.applyAnswer(state, correct: true, questionId: 'q1');
        state = engine.openPlacement(state);
        expect(state.turnPhase, TurnPhase.noMove);
        expect(state.lastMoveOutcome, MoveOutcome.noLegalMove);
        expect(state.drawnCard, const MovementChoice(3));
        final next = engine.endTurn(state);
        expect(next.currentPlayerIndex, 1);
        expect(next.drawnCard, isNull);

        var blocked = buildGame();
        blocked = withHorse(blocked, horse: 0, at: const TrackPosition(0));
        blocked = engine.drawCard(blocked, const MovementChoice(6));
        blocked = engine.applyAnswer(blocked, correct: true, questionId: 'q1');
        blocked = engine.openPlacement(blocked);
        expect(blocked.turnPhase, TurnPhase.choosingHorse);
        expect(blocked.extraTurn, isTrue);
      },
    );

    test('a 6 lets the same player draw again, right or wrong', () {
      var state = buildGame();
      state = play(engine, state, steps: 6, correct: false, questionId: 'q1');
      expect(
        state.extraTurn,
        isTrue,
        reason: 'the replay is earned by the draw',
      );
      state = engine.endTurn(state);
      expect(state.currentPlayerIndex, 0);
      expect(state.isBonusTurn, isTrue);
      expect(state.extraTurn, isFalse);
      expect(state.turnPhase, TurnPhase.selectingGait);

      state = play(engine, state, steps: 2, correct: true, questionId: 'q2');
      state = engine.endTurn(state);
      expect(state.currentPlayerIndex, 1);
      expect(state.isBonusTurn, isFalse);
    });

    test('any other card rides without a replay', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(2));
      state = play(engine, state, steps: 5, correct: true, questionId: 'q1');
      expect(state.players[0].horses[0].position, const TrackPosition(7));
      expect(state.extraTurn, isFalse);
      expect(engine.endTurn(state).currentPlayerIndex, 1);
    });

    test('the card on the table and the replay survive a save', () {
      var state = buildGame();
      state = engine.drawCard(state, const MovementChoice(6));
      state = engine.applyAnswer(state, correct: true, questionId: 'q1');
      state = engine.openPlacement(state);
      final restored = GameState.fromJson(state.toJson());
      expect(restored.drawnCard, const MovementChoice(6));
      expect(restored.extraTurn, isTrue);
      expect(restored.turnPhase, TurnPhase.choosingHorse);
      final placed = GameState.fromJson(engine.placeHorse(state, 2).toJson());
      expect(placed.movedHorseIndex, 2);
      expect(placed.players[0].horses[2].position, const TrackPosition(0));
      final replay = GameState.fromJson(engine.endTurn(state).toJson());
      expect(replay.isBonusTurn, isTrue);
    });
  });

  group('The free edition\'s finish line', () {
    test(
      'the fiftieth card ends the race on the leader; Premium runs to Mecca',
      () {
        expect(GameState.freeDrawLimit, 50);
        var free = buildGame().copyWith(maxDraws: GameState.freeDrawLimit);
        free = withHorse(free, player: 1, at: const TrackPosition(20));
        free = free.copyWith(drawCount: GameState.freeDrawLimit - 1);
        free = engine.drawCard(free, const MovementChoice(3));
        expect(free.drawCount, GameState.freeDrawLimit);
        // The last card is played out (here: nothing could move), then the
        // race stops on whoever is ahead.
        final over = engine.endTurn(free);
        expect(over.turnPhase, TurnPhase.gameOver);
        expect(over.endedByDrawLimit, isTrue);
        expect(over.winnerId, 'p1', reason: 'player 1 has ridden the farthest');

        var premium = buildGame();
        premium = premium.copyWith(drawCount: 400);
        premium = engine.drawCard(premium, const MovementChoice(3));
        expect(engine.endTurn(premium).turnPhase, isNot(TurnPhase.gameOver));
      },
    );

    test(
      'the leader is decided by arrivals, then distance, then knowledge',
      () {
        var state = buildGame();
        state = withHorse(
          state,
          player: 0,
          horse: 0,
          at: const FinishedPosition(),
        );
        state = withHorse(
          state,
          player: 1,
          horse: 0,
          at: const TrackPosition(30),
        );
        state = withHorse(
          state,
          player: 1,
          horse: 1,
          at: const TrackPosition(35),
        );
        expect(
          engine.leader(state).id,
          'p0',
          reason: 'an arrival beats any distance',
        );

        var tie = buildGame();
        final players = [...tie.players];
        players[1] = players[1].copyWith(
          rewards: players[1].rewards.copyWith(knowledgePoints: 4),
        );
        tie = tie.copyWith(players: players);
        expect(
          engine.leader(tie).id,
          'p1',
          reason: 'all in the stable: knowledge decides',
        );
      },
    );

    test('the draw counter and the limit survive a save', () {
      var state = buildGame().copyWith(maxDraws: 50, drawCount: 12);
      state = engine.drawCard(state, const MovementChoice(6));
      final restored = GameState.fromJson(state.toJson());
      expect(restored.drawCount, 13);
      expect(restored.maxDraws, 50);
      expect(restored.endedByDrawLimit, isFalse);
    });
  });

  group('Turn hand-off', () {
    test('the turn passes to the next player and clears the turn state', () {
      var state = buildGame();
      state = play(engine, state, steps: 2, correct: true, questionId: 'q1');
      final next = engine.endTurn(state);
      expect(next.currentPlayerIndex, 1);
      expect(next.turnPhase, TurnPhase.selectingGait);
      expect(next.movedHorseIndex, isNull);
      expect(next.pendingBonus, isNull);
      expect(next.bonusUsedThisTurn, isFalse);
      expect(next.pendingCellEffect, isNull);
      expect(next.lastAnswerCorrect, isNull);
      expect(next.justUnlocked, isEmpty);
    });

    test('nothing moves until the player has set a horse down', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(3));
      state = engine.drawCard(state, const MovementChoice(5));
      expect(state.turnPhase, TurnPhase.answeringQuestion);
      expect(state.drawnCard?.steps, 5);
      expect(state.players[0].horses[0].position, const TrackPosition(3));

      // A right answer wins the squares — and still moves nothing.
      state = engine.applyAnswer(state, correct: true, questionId: 'q1');
      expect(state.turnPhase, TurnPhase.showingFeedback);
      expect(state.players[0].horses[0].position, const TrackPosition(3));
      state = engine.openPlacement(state);
      expect(state.turnPhase, TurnPhase.choosingHorse);
      expect(state.players[0].horses[0].position, const TrackPosition(3));

      // Only the drop rides.
      state = engine.placeHorse(state, 0);
      expect(state.turnPhase, TurnPhase.movingHorse);
      expect(state.players[0].horses[0].position, const TrackPosition(8));
      expect(state.movedHorseIndex, 0);
    });

    test('a horse the card cannot move is refused, state untouched', () {
      var state = buildGame();
      state = withHorse(state, horse: 0, at: const TrackPosition(3));
      state = engine.drawCard(state, const MovementChoice(2));
      state = engine.applyAnswer(state, correct: true, questionId: 'q1');
      state = engine.openPlacement(state);
      // Horse 1 is in the stable and a 2 does not open the gate.
      expect(identical(engine.placeHorse(state, 1), state), isTrue);
      // And nothing can be placed outside the placement phase.
      final early = engine.drawCard(buildGame(), const MovementChoice(6));
      expect(identical(engine.placeHorse(early, 0), early), isTrue);
    });
  });

  group('Playing together across ages', () {
    const service = MovementChoiceService();

    test('four levels, chosen up front, and the card never changes them', () {
      expect(PlayerProfile.values, [
        PlayerProfile.easy,
        PlayerProfile.intermediate,
        PlayerProfile.expert,
        PlayerProfile.mixed,
      ]);
      const bold = MovementChoice(6);
      expect(
        service.difficultyFor(bold, PlayerProfile.easy),
        QuestionDifficulty.easy,
      );
      expect(
        service.difficultyFor(bold, PlayerProfile.expert),
        QuestionDifficulty.hard,
      );
      // Whatever the level, six squares are still six squares.
      expect(bold.steps, 6);
      // The easy level is the children's level.
      expect(PlayerProfile.easy.isChildMode, isTrue);
      expect(PlayerProfile.expert.isChildMode, isFalse);
    });

    test('older save level names still fold onto the levels shipped', () {
      expect(PlayerProfileX.parse('child'), PlayerProfile.easy);
      expect(PlayerProfileX.parse('discovery'), PlayerProfile.easy);
      expect(PlayerProfileX.parse('advanced'), PlayerProfile.expert);
      expect(PlayerProfileX.parse('intermediate'), PlayerProfile.intermediate);
      expect(PlayerProfileX.parse('mixed'), PlayerProfile.mixed);
      expect(PlayerProfileX.parse(null), PlayerProfile.intermediate);
    });

    test('the mixed level fixes no tier, so every draw picks its own', () {
      const bold = MovementChoice(6);
      expect(service.difficultyFor(bold, PlayerProfile.mixed), isNull);
      expect(service.journeyDifficultyFor(PlayerProfile.mixed), isNull);
      // A bonus square is "one level up" — there is no level up from
      // mixed, so it stays mixed and keeps its full range.
      expect(service.bonusDifficultyFor(PlayerProfile.mixed), isNull);
      // The mixed level is not the children's level.
      expect(PlayerProfile.mixed.isChildMode, isFalse);
    });

    test('the bonus question is one level up, capped; the journey question is the rider\'s', () {
      expect(
        service.bonusDifficultyFor(PlayerProfile.easy),
        QuestionDifficulty.medium,
      );
      expect(
        service.bonusDifficultyFor(PlayerProfile.expert),
        QuestionDifficulty.hard,
      );
      expect(
        service.journeyDifficultyFor(PlayerProfile.easy),
        QuestionDifficulty.easy,
      );
    });

    test('the journey question is never a difficulty spike', () {
      for (final profile in PlayerProfile.values) {
        expect(
          service.journeyDifficultyFor(profile),
          service.difficultyFor(const MovementChoice(3), profile),
        );
      }
    });
  });

  group('Circuit journey geometry (drives the board animation)', () {
    test('positionAt and progressOf are inverse for every square', () {
      for (final circuit in Circuit.all) {
        for (var team = 0; team < 4; team++) {
          for (var p = 0; p < circuit.journeyLength; p++) {
            final pos = circuit.positionAt(p, team);
            expect(
              circuit.progressOf(pos, team),
              p,
              reason: '${circuit.id.name} team $team progress $p',
            );
          }
          expect(
            circuit.positionAt(circuit.journeyLength, team),
            isA<FinishedPosition>(),
          );
          expect(circuit.progressOf(const HomePosition(), team), isNull);
        }
      }
    });

    test('the journey enters the track at the team entry square', () {
      const circuit = Circuit.oasisRoute;
      expect(circuit.positionAt(0, 0), const TrackPosition(0));
      expect(
        circuit.positionAt(0, 1),
        TrackPosition(circuit.squaresPerQuadrant),
      );
    });
  });

  group('Saving and resuming', () {
    test('a game round-trips through JSON without losing gait state', () {
      var state = buildGame();
      state = play(engine, state, steps: 3, correct: true, questionId: 'q1');
      state = engine.endTurn(state);

      final restored = GameState.fromJson(state.toJson());
      expect(restored.gameId, state.gameId);
      expect(restored.circuitId, state.circuitId);
      expect(restored.currentPlayerIndex, state.currentPlayerIndex);
      expect(restored.turnPhase, state.turnPhase);
      expect(restored.askedQuestionIds, state.askedQuestionIds);
      expect(restored.players[0].streak, state.players[0].streak);
      expect(
        restored.players[0].horses.first.position,
        state.players[0].horses.first.position,
      );
      expect(restored.players[0].profile, state.players[0].profile);
    });

    test('the save format is stamped with the gait-engine schema version', () {
      expect(buildGame().toJson()['schemaVersion'], GameState.schemaVersion);
      expect(GameState.schemaVersion, greaterThan(1));
    });
  });
}
