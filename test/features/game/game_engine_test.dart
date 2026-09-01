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

const _teams = [AppTeam.emerald, AppTeam.saphir, AppTeam.grenat, AppTeam.safran];

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

/// One complete "choose a gait, answer the question" beat.
GameState play(
  GameEngine engine,
  GameState state, {
  int horse = 0,
  required int steps,
  required bool correct,
  required String questionId,
  bool useGrandGallop = false,
}) {
  final committed = engine.commitGait(
    state,
    horse,
    MovementChoice(steps),
    useGrandGallop: useGrandGallop,
  );
  return engine.applyAnswer(committed, correct: correct, questionId: questionId);
}

void main() {
  const engine = GameEngine();

  group('No randomness anywhere in progression', () {
    test('the engine source contains no random number generator', () {
      // The strongest possible form of "aucun déplacement n'est généré
      // aléatoirement": the rules file cannot even reach for a Random.
      final source = File('lib/features/game/domain/game_engine.dart').readAsStringSync();
      expect(source, isNot(contains('Random')));
      expect(source, isNot(contains('dart:math')));
    });

    test('no dice API survives anywhere in the library', () {
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        // The migration service must still be able to *describe* the old
        // dice-based save format it detects; that is the one exception.
        if (entity.path.endsWith('legacy_game_migration_service.dart')) continue;
        if (entity.path.contains('l10n/generated')) continue;
        final source = entity.readAsStringSync();
        for (final banned in const ['rollDice', 'DiceWidget', 'lastDiceValue', 'waitingForDice']) {
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
      expect(engine.availableGaits(state.currentPlayer).map((c) => c.steps), [1, 2, 3, 4, 5, 6]);
    });

    test('difficulty follows the chosen gait, never a draw', () {
      expect(const MovementChoice(1).difficulty, QuestionDifficulty.easy);
      expect(const MovementChoice(2).difficulty, QuestionDifficulty.easy);
      expect(const MovementChoice(3).difficulty, QuestionDifficulty.medium);
      expect(const MovementChoice(4).difficulty, QuestionDifficulty.medium);
      expect(const MovementChoice(5).difficulty, QuestionDifficulty.hard);
      expect(const MovementChoice(6).difficulty, QuestionDifficulty.hard);
    });

    test('knowledge points scale with the risk taken', () {
      expect(const MovementChoice(1).knowledgePoints, 1);
      expect(const MovementChoice(4).knowledgePoints, 2);
      expect(const MovementChoice(6).knowledgePoints, 3);
    });

    test('a value can come up again immediately, exactly as a die repeats', () {
      // The distance now comes from drawing a question card, not from
      // the player picking a gait, so nothing is ever spent. A deck that
      // refused a value it had just produced would not be a die.
      var state = buildGame();
      state = play(engine, state, steps: 4, correct: true, questionId: 'q1');
      expect(engine.availableGaits(state.currentPlayer).map((c) => c.steps), [1, 2, 3, 4, 5, 6]);

      final again = engine.commitGait(state, 0, const MovementChoice(4));
      expect(again.pendingGait?.choice.steps, 4);
      expect(again.turnPhase, TurnPhase.answeringQuestion);
    });

    test('a wrong answer costs the move, not the value', () {
      var state = buildGame();
      state = play(engine, state, steps: 6, correct: false, questionId: 'q1');
      expect(engine.availableGaits(state.currentPlayer).map((c) => c.steps), [1, 2, 3, 4, 5, 6]);
    });
  });

  group('Answering decides movement', () {
    test('a correct answer advances exactly the chosen number of squares', () {
      var state = buildGame();
      // Leaving the stable costs the move itself: gait 1 lands on the entry.
      state = play(engine, state, steps: 1, correct: true, questionId: 'q1');
      expect(state.players[0].horses[0].position, const TrackPosition(0));

      state = engine.endTurn(state);
      state = engine.endTurn(state); // back to player 0
      state = play(engine, state, steps: 4, correct: true, questionId: 'q2');
      expect(state.players[0].horses[0].position, const TrackPosition(4));
      expect(state.lastMoveOutcome, MoveOutcome.moved);
    });

    test('no 6 is needed to leave the stable', () {
      var state = buildGame();
      state = play(engine, state, steps: 2, correct: true, questionId: 'q1');
      expect(state.players[0].horses[0].position, const TrackPosition(1));
    });

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
      final after = play(engine, state, steps: 3, correct: true, questionId: 'q1');
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
      final after = play(engine, state, steps: 4, correct: true, questionId: 'q1');
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

    test('an Oasis square protects the horse standing on it', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(10));
      state = withHorse(state, player: 1, at: const TrackPosition(11));
      expect(Circuit.oasisRoute.effectAt(11), CellEffect.oasis);
      expect(Circuit.oasisRoute.isSafe(11), isTrue);
      state = play(engine, state, steps: 1, correct: true, questionId: 'q1');
      expect(state.players[1].horses[0].position, const TrackPosition(11));
      expect(state.lastMoveOutcome, MoveOutcome.moved);
    });

    test('a knowledge shield absorbs one capture and is then spent', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(0));
      state = withHorse(state, player: 1, at: const TrackPosition(1), shield: true);
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
        state = play(engine, state, steps: steps, correct: true, questionId: 'q$steps');
      }
      expect(state.players[0].streak.current, 5);
      expect(state.players[0].rewards.hasGrandGallop, isTrue);
    });

    test('the Grand Galop adds exactly 2 squares and is spent once', () {
      var state = buildGame();
      state = withHorse(state, at: const TrackPosition(1));
      final players = [...state.players];
      players[0] = players[0].copyWith(rewards: players[0].rewards.copyWith(hasGrandGallop: true));
      state = state.copyWith(players: players);

      state = play(engine, state, steps: 3, correct: true, questionId: 'q1', useGrandGallop: true);
      expect(state.players[0].horses[0].position, const TrackPosition(6));
      expect(state.players[0].rewards.hasGrandGallop, isFalse);
    });

    test('ten correct answers in a row unlock a mastery badge', () {
      var state = buildGame();
      var asked = 0;
      for (var cycle = 0; cycle < 2; cycle++) {
        for (var steps = 1; steps <= 5; steps++) {
          state = play(engine, state, steps: steps, correct: true, questionId: 'q${asked++}');
        }
        // Spend the sixth gait too, so the cycle refills cleanly.
        state = play(engine, state, steps: 6, correct: true, questionId: 'q${asked++}');
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
      expect(state.players[0].horses[0].hasShield, isTrue, reason: 'rewards are never revoked');
    });

    test('knowledge points accumulate by the risk actually taken', () {
      var state = buildGame();
      state = play(engine, state, steps: 1, correct: true, questionId: 'q1'); // +1
      state = play(engine, state, steps: 3, correct: true, questionId: 'q2'); // +2
      state = play(engine, state, steps: 6, correct: true, questionId: 'q3'); // +3
      expect(state.players[0].rewards.knowledgePoints, 6);
    });
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
              reason: 'circuit ${circuit.id.name} square $i differs in quadrant $quadrant',
            );
          }
        }
      }
    });

    test('no starting corner is advantaged: every team meets the same sequence', () {
      for (final circuit in Circuit.all) {
        final reference = [
          for (var step = 0; step < circuit.trackLength; step++)
            circuit.effectAt((circuit.entryIndexForTeam(0) + step) % circuit.trackLength),
        ];
        for (var team = 1; team < 4; team++) {
          final seen = [
            for (var step = 0; step < circuit.trackLength; step++)
              circuit.effectAt((circuit.entryIndexForTeam(team) + step) % circuit.trackLength),
          ];
          expect(seen, reference, reason: 'circuit ${circuit.id.name}, team $team');
        }
      }
    });

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

      final won = engine.resolveChallenge(state, correct: true, questionId: 'b1');
      expect(won.players[0].horses[0].position, const TrackPosition(8));
      expect(won.lastMoveOutcome, MoveOutcome.bonusEarned);

      final lost = engine.resolveChallenge(state, correct: false, questionId: 'b1');
      expect(lost.players[0].horses[0].position, const TrackPosition(6));
      expect(lost.lastMoveOutcome, MoveOutcome.bonusMissed);
    });

    test('a failed Raccourci leaves the horse exactly where it stood', () {
      var state = buildGame(circuitId: CircuitId.greatRide);
      state = withHorse(state, at: const TrackPosition(4));
      state = play(engine, state, steps: 2, correct: true, questionId: 'q1');
      expect(state.landedEffect, CellEffect.shortcut);
      final missed = engine.resolveShortcut(state, correct: false, questionId: 'b1', horseIndex: 0);
      expect(missed.players[0].horses[0].position, const TrackPosition(6));
    });

    test('a Relais hands the earned squares to another of your own horses', () {
      var state = buildGame(circuitId: CircuitId.caravanTrail);
      state = withHorse(state, horse: 0, at: const TrackPosition(7));
      state = withHorse(state, horse: 1, at: const TrackPosition(2));
      final relayed = engine.resolveRelay(state, fromHorseIndex: 0, toHorseIndex: 1, steps: 3);
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
      expect(tie.players.every((p) => p.horses.every((h) => !h.hasShield)), isTrue);
    });

    test('Duel and Relais never offer a decision this release cannot resolve', () {
      // Their interactive flows have no UI yet, so the squares apply
      // silently whatever the table setup — the engine rules above stay
      // tested and ready for when the screens ship.
      expect(effects.isAvailableFor(CellEffect.duel, playerCount: 1, horseCount: 2), isFalse);
      expect(effects.isAvailableFor(CellEffect.duel, playerCount: 2, horseCount: 2), isFalse);
      expect(effects.isAvailableFor(CellEffect.relay, playerCount: 2, horseCount: 1), isFalse);
      expect(effects.isAvailableFor(CellEffect.relay, playerCount: 2, horseCount: 2), isFalse);
      expect(effects.isAvailableFor(CellEffect.challenge, playerCount: 2, horseCount: 1), isTrue);
      expect(effects.isAvailableFor(CellEffect.shortcut, playerCount: 2, horseCount: 1), isTrue);
    });

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
    test('overshooting the finish is allowed', () {
      var state = buildGame(variant: GameVariant.quick);
      state = withHorse(state, at: const FinalLanePosition(3));
      state = play(engine, state, steps: 6, correct: true, questionId: 'q1');
      expect(state.players[0].horses[0].position, isA<FinishedPosition>());
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
      state = withHorse(state, at: const FinishedPosition(), awaitingJourneyQuestion: true);
      state = engine.answerJourneyQuestion(state, correct: false, questionId: 'j1', horseIndex: 0);
      expect(state.players[0].horses[0].position, isA<FinishedPosition>());
      expect(state.players[0].horses[0].awaitingJourneyQuestion, isTrue);
      expect(state.winnerId, isNull);
    });

    test('answering the journey question makes the arrival official and wins', () {
      var state = buildGame(variant: GameVariant.quick);
      state = withHorse(state, at: const FinishedPosition(), awaitingJourneyQuestion: true);
      state = engine.answerJourneyQuestion(state, correct: true, questionId: 'j1', horseIndex: 0);
      expect(state.players[0].horses[0].hasArrived, isTrue);
      expect(state.winnerId, 'p0');
      expect(state.turnPhase, TurnPhase.gameOver);
    });

    test('every horse must arrive in the classic format', () {
      var state = buildGame();
      state = withHorse(state, horse: 0, at: const FinishedPosition());
      state = withHorse(state, horse: 1, at: const TrackPosition(4));
      expect(state.players[0].hasArrivedCompletely, isFalse);
      expect(engine.endTurn(state).turnPhase, isNot(TurnPhase.gameOver));
    });
  });

  group('Turn hand-off', () {
    test('the turn passes to the next player and clears the turn state', () {
      var state = buildGame();
      state = play(engine, state, steps: 2, correct: true, questionId: 'q1');
      final next = engine.endTurn(state);
      expect(next.currentPlayerIndex, 1);
      expect(next.turnPhase, TurnPhase.selectingGait);
      expect(next.pendingGait, isNull);
      expect(next.pendingCellEffect, isNull);
      expect(next.lastAnswerCorrect, isNull);
      expect(next.justUnlocked, isEmpty);
    });

    test('committing a gait waits for the question before anything moves', () {
      final state = buildGame();
      final committed = engine.commitGait(state, 0, const MovementChoice(5));
      expect(committed.turnPhase, TurnPhase.answeringQuestion);
      expect(committed.pendingGait?.choice.steps, 5);
      expect(committed.players[0].horses[0].position, const HomePosition());
    });
  });

  group('Playing together across ages', () {
    const service = MovementChoiceService();

    test('the gait to difficulty mapping is adjusted per profile, not the distance', () {
      const bold = MovementChoice(6);
      expect(service.difficultyFor(bold, PlayerProfile.child), QuestionDifficulty.medium);
      expect(service.difficultyFor(bold, PlayerProfile.intermediate), QuestionDifficulty.hard);
      expect(service.difficultyFor(bold, PlayerProfile.advanced), QuestionDifficulty.hard);
      // Whatever the profile, six squares are still six squares.
      expect(bold.steps, 6);
    });

    test('a child is asked to confirm a bold gait', () {
      expect(PlayerProfile.child.confirmsRiskyGaits, isTrue);
      expect(PlayerProfile.intermediate.confirmsRiskyGaits, isFalse);
      expect(const MovementChoice(5).needsConfirmationForChildren, isTrue);
      expect(const MovementChoice(4).needsConfirmationForChildren, isFalse);
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
          expect(circuit.positionAt(circuit.journeyLength, team), isA<FinishedPosition>());
          expect(circuit.progressOf(const HomePosition(), team), isNull);
        }
      }
    });

    test('the journey enters the track at the team entry square', () {
      const circuit = Circuit.oasisRoute;
      expect(circuit.positionAt(0, 0), const TrackPosition(0));
      expect(circuit.positionAt(0, 1), TrackPosition(circuit.squaresPerQuadrant));
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
      expect(restored.players[0].horses.first.position, state.players[0].horses.first.position);
      expect(restored.players[0].profile, state.players[0].profile);
    });

    test('the save format is stamped with the gait-engine schema version', () {
      expect(buildGame().toJson()['schemaVersion'], GameState.schemaVersion);
      expect(GameState.schemaVersion, greaterThan(1));
    });
  });
}
