import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/game/application/game_controller.dart';
import 'package:iqraquest/features/game/domain/game_engine.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/services/game_save_service.dart';
import 'package:iqraquest/services/legacy_game_migration_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/theme/app_team.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The whole turn — draw → answer → win the squares → set a horse down —
/// exercised end to end through the real controller, not just the
/// isolated engine. Headless: the controller does not wait for the
/// board's animations here.
Future<GameController> buildController(
  LocalStorageService storage, {
  bool isPremium = true,
  int seed = 7,
  bool animate = false,
}) async {
  final repo = QuestionRepository();
  final pool = await repo.loadAll('en');
  final controller = GameController(
    engine: const GameEngine(),
    questionRepository: repo,
    saveService: GameSaveService(storage),
    progressService: ProgressService(storage),
    random: Random(seed),
    animate: animate,
  );
  controller.configure(pool: pool, isPremium: isPremium);
  return controller;
}

Player human(
  String id,
  AppTeam team, {
  int horses = 1,
  PlayerProfile profile = PlayerProfile.intermediate,
}) => Player(
  id: id,
  name: id,
  team: team,
  profile: profile,
  horses: List.generate(horses, (_) => const HorseState()),
);

/// After the verdict: continue, and if the squares can be placed, set the
/// first legal horse down — exactly what a player would do.
void finishTurn(GameController controller) {
  controller.continueAfterFeedback();
  final s = controller.state!;
  if (s.gameState.turnPhase == TurnPhase.choosingHorse) {
    controller.placeHorse(controller.legalMoves.first.horseIndex);
  }
  if (controller.state!.gameState.turnPhase == TurnPhase.noMove) {
    controller.continueAfterFeedback();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a family game starts at the deck, with nothing asked and nothing moved', () async {
    final storage = await LocalStorageService.create();
    final controller = await buildController(storage);

    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.quick,
      circuitId: CircuitId.oasisRoute,
      players: [human('p0', AppTeam.emerald), human('p1', AppTeam.saphir)],
    );

    final session = controller.state!;
    expect(session.gameState.turnPhase, TurnPhase.selectingGait);
    expect(session.currentQuestion, isNull);
    expect(controller.legalMoves, isEmpty, reason: 'no card, no move');
    expect(
      session.gameState.players[0].horses.first.position,
      const HomePosition(),
    );
    // The sixteen bonus squares are dealt with the game.
    expect(session.gameState.bonusTiles.length, 16);
    expect(session.gameState.bonusSeed, isNot(0));
  });

  test(
    'every question is at the rider\'s own level, whatever the card',
    () async {
      final storage = await LocalStorageService.create();
      final controller = await buildController(storage);
      controller.startNewGame(
        mode: GameMode.family,
        variant: GameVariant.quick,
        circuitId: CircuitId.oasisRoute,
        players: [
          human('p0', AppTeam.emerald, profile: PlayerProfile.easy),
          human('p1', AppTeam.saphir, profile: PlayerProfile.expert),
        ],
      );

      controller.drawCard();
      expect(
        controller.state!.gameState.turnPhase,
        TurnPhase.answeringQuestion,
      );
      final first = controller.state!.currentQuestion!;
      expect(
        first.difficulty,
        QuestionDifficulty.easy,
        reason: 'an easy rider gets an easy question whatever the card',
      );

      // The draw locks the turn: the question cannot be re-dealt once
      // it is on screen.
      controller.drawCard();
      expect(controller.state!.currentQuestion!.id, first.id);

      // Play through until the expert's turn: every card of the child
      // is easy, every card of the expert is hard.
      for (var turn = 0; turn < 12; turn++) {
        final s = controller.state!;
        if (s.gameState.turnPhase == TurnPhase.selectingGait) {
          controller.drawCard();
        }
        final q = controller.state!.currentQuestion!;
        final rider = controller.state!.gameState.currentPlayer;
        expect(
          q.difficulty,
          rider.profile == PlayerProfile.easy
              ? QuestionDifficulty.easy
              : QuestionDifficulty.hard,
          reason: '${rider.id} drew a ${q.difficulty} question',
        );
        controller.answerQuestion(q.correctAnswerIndex);
        finishTurn(controller);
      }
    },
  );

  test(
    'a right answer opens the placement; the drop rides exactly to the promised square',
    () async {
      final storage = await LocalStorageService.create();
      final controller = await buildController(storage);
      controller.startNewGame(
        mode: GameMode.family,
        variant: GameVariant.quick,
        circuitId: CircuitId.oasisRoute,
        players: [human('p0', AppTeam.emerald), human('p1', AppTeam.saphir)],
      );

      var placements = 0;
      for (var turn = 0; turn < 30 && placements < 3; turn++) {
        controller.drawCard();
        final before = controller.state!.gameState;
        final question = controller.state!.currentQuestion!;
        controller.answerQuestion(question.correctAnswerIndex);
        // Right — and still nothing has moved.
        expect(controller.state!.gameState.lastAnswerCorrect, isTrue);
        for (var p = 0; p < 2; p++) {
          expect(
            controller.state!.gameState.players[p].horses.first.position,
            before.players[p].horses.first.position,
            reason: 'turn $turn: a horse moved before the player placed it',
          );
        }
        controller.continueAfterFeedback();
        final s = controller.state!.gameState;
        if (s.turnPhase == TurnPhase.choosingHorse) {
          final move = controller.moveFor(0)!;
          expect(controller.placeHorse(0), isTrue);
          final horse = controller.state!.gameState.players[s.currentPlayerIndex].horses.first;
          if (move.bonusValue == null) {
            expect(horse.position, move.destination, reason: 'turn $turn');
          } else {
            // Headless, the bonus square it stopped on has already been
            // ridden: the horse is past the promised square, by the bonus.
            final circuit = s.circuit;
            final promised = circuit.progressOf(move.destination, s.currentPlayerIndex)!;
            final actual = circuit.progressOf(horse.position, s.currentPlayerIndex)!;
            expect(actual, greaterThan(promised), reason: 'turn $turn: bonus not ridden');
          }
          placements++;
        } else {
          expect(s.turnPhase, TurnPhase.noMove);
          controller.continueAfterFeedback();
        }
        expect(controller.state!.gameState.turnPhase, TurnPhase.selectingGait);
      }
      expect(placements, greaterThan(0));
    },
  );

  test('a wrong answer holds the horse and hands the turn on', () async {
    final storage = await LocalStorageService.create();
    final controller = await buildController(storage);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.quick,
      circuitId: CircuitId.oasisRoute,
      players: [human('p0', AppTeam.emerald), human('p1', AppTeam.saphir)],
    );

    controller.drawCard();
    final drawn = controller.state!.gameState.drawnCard!;
    final question = controller.state!.currentQuestion!;
    controller.answerQuestion(
      (question.correctAnswerIndex + 1) % question.answers.length,
    );

    expect(
      controller.state!.gameState.players[0].horses.first.position,
      const HomePosition(),
    );
    expect(controller.state!.gameState.lastAnswerCorrect, isFalse);

    controller.continueAfterFeedback();
    // A 6 replays even when the answer was wrong; anything else hands on.
    expect(
      controller.state!.gameState.currentPlayerIndex,
      drawn.grantsExtraTurn ? 0 : 1,
    );
    expect(controller.state!.gameState.turnPhase, TurnPhase.selectingGait);
  });

  test('the same question is never asked twice in one game', () async {
    final storage = await LocalStorageService.create();
    final controller = await buildController(storage);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.quick,
      circuitId: CircuitId.oasisRoute,
      players: [human('p0', AppTeam.emerald), human('p1', AppTeam.saphir)],
    );

    final seen = <String>{};
    for (var turn = 0; turn < 40; turn++) {
      if (controller.state!.gameState.turnPhase != TurnPhase.selectingGait) {
        break;
      }
      controller.drawCard();
      final question = controller.state!.currentQuestion;
      if (question == null) break; // bank exhausted — play continues anyway
      expect(
        seen.add(question.id),
        isTrue,
        reason: 'question ${question.id} repeated',
      );
      controller.answerQuestion(question.correctAnswerIndex);
      finishTurn(controller);
    }
    // A quick race with bonus squares can be over in a score of cards.
    expect(seen.length, greaterThan(10));
  });

  test(
    'a game is saved after every mutation and resumes identically',
    () async {
      final storage = await LocalStorageService.create();
      final saveService = GameSaveService(storage);
      final controller = await buildController(storage);

      controller.startNewGame(
        mode: GameMode.family,
        variant: GameVariant.classic,
        circuitId: CircuitId.caravanTrail,
        players: [
          human('p0', AppTeam.emerald, horses: 2),
          human('p1', AppTeam.saphir, horses: 2),
        ],
      );
      expect(saveService.hasSave, isTrue);

      controller.drawCard();
      controller.answerQuestion(
        controller.state!.currentQuestion!.correctAnswerIndex,
      );

      final before = controller.state!.gameState;
      final resumed = await buildController(storage);
      expect(resumed.loadSaved(), isTrue);
      final after = resumed.state!.gameState;

      expect(after.gameId, before.gameId);
      expect(after.circuitId, CircuitId.caravanTrail);
      expect(
        after.players[0].horses[0].position,
        before.players[0].horses[0].position,
      );
      expect(after.players[0].streak, before.players[0].streak);
      expect(after.askedQuestionIds, before.askedQuestionIds);
      expect(after.bonusTiles, before.bonusTiles, reason: 'the squares never move');
      // A right answer resumes at its placement (or the pass a 1 earns).
      expect(
        after.turnPhase,
        anyOf(TurnPhase.choosingHorse, TurnPhase.noMove),
      );
    },
  );

  test(
    'a save from the dice engine is detected and archived, never destroyed',
    () async {
      SharedPreferences.setMockInitialValues({
        // A v1 save: no schemaVersion, and dice state the gait engine cannot read.
        'iqraquest.save.currentGame.v1':
            '{"gameId":"old","turnPhase":"waitingForDice","lastDiceValue":6}',
      });
      final storage = await LocalStorageService.create();
      final migration = LegacyGameMigrationService(storage);

      expect(migration.inspect(), SaveCompatibility.legacy);
      expect(migration.hasSeenRaceRulesNotice, isFalse);

      await migration.archiveLegacySave();
      expect(migration.inspect(), SaveCompatibility.none);
      // The old game is moved aside, not deleted — user data is never lost.
      final archive = storage.getJson('iqraquest.save.legacyGame.archive');
      expect(archive, isNotNull);
      expect((archive!['save'] as Map)['gameId'], 'old');
      expect(archive['reason'], 'raceRulesUpdated');

      await migration.markRaceRulesNoticeSeen();
      expect(migration.hasSeenRaceRulesNotice, isTrue);
    },
  );

  test(
    'a save written by this engine resumes without any migration prompt',
    () async {
      final storage = await LocalStorageService.create();
      final controller = await buildController(storage);
      controller.startNewGame(
        mode: GameMode.solo,
        variant: GameVariant.quick,
        circuitId: CircuitId.oasisRoute,
        players: [human('p0', AppTeam.emerald), human('p1', AppTeam.saphir)],
      );
      expect(
        LegacyGameMigrationService(storage).inspect(),
        SaveCompatibility.current,
      );
    },
  );

  test('progress, badges and premium live outside the game save', () async {
    final storage = await LocalStorageService.create();
    final progress = ProgressService(storage);
    await progress.recordAnswer(
      correct: true,
      category: QuestionCategory.quran,
    );

    final controller = await buildController(storage);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.quick,
      circuitId: CircuitId.oasisRoute,
      players: [human('p0', AppTeam.emerald), human('p1', AppTeam.saphir)],
    );
    // Archiving an incompatible race must not touch anything else.
    await LegacyGameMigrationService(storage).archiveLegacySave();
    expect(progress.load().questionsAnswered, greaterThan(0));
  });

  group('Free edition and Premium', () {
    test('the free edition can reach every free question', () async {
      final repo = QuestionRepository();
      final pool = await repo.loadAll('en');
      final free = pool.where((q) => q.isFree).toList();
      expect(free, isNotEmpty);

      final asked = <String>{};
      while (true) {
        final question = repo.pickQuestion(
          pool: pool,
          askedQuestionIds: asked,
          isPremium: false,
        );
        if (question == null) break;
        expect(
          question.isFree,
          isTrue,
          reason: 'free edition drew a premium question',
        );
        asked.add(question.id);
      }
      expect(asked.length, free.length);
      expect(
        repo.isFreeBankExhausted(pool: pool, askedQuestionIds: asked),
        isTrue,
      );
    });

    test('Premium opens the whole bank without changing any rule', () async {
      final repo = QuestionRepository();
      final pool = await repo.loadAll('en');
      final premium = repo.pickQuestion(
        pool: pool,
        askedQuestionIds: const {},
        isPremium: true,
      );
      expect(premium, isNotNull);
      // Buying nothing but content: no gait, distance or bonus differs.
      expect(MovementChoice.all.length, 6);
    });

    test(
      'an exhausted free bank never blocks or paywalls a turn mid-game',
      () async {
        final storage = await LocalStorageService.create();
        final repo = QuestionRepository();
        final pool = await repo.loadAll('en');
        final controller = GameController(
          engine: const GameEngine(),
          questionRepository: repo,
          saveService: GameSaveService(storage),
          progressService: ProgressService(storage),
          animate: false,
        );
        // An empty pool is the extreme case of an exhausted bank.
        controller.configure(pool: const [], isPremium: false);
        controller.startNewGame(
          mode: GameMode.family,
          variant: GameVariant.quick,
          circuitId: CircuitId.oasisRoute,
          players: [human('p0', AppTeam.emerald), human('p1', AppTeam.saphir)],
        );

        controller.drawCard();
        final state = controller.state!.gameState;
        expect(state.freeBankExhausted, isTrue);
        // The turn goes straight to the placement: the player still
        // chooses, and the move still happens — play is never interrupted.
        expect(state.turnPhase, TurnPhase.choosingHorse);
        expect(controller.placeHorse(0), isTrue);
        expect(
          controller.state!.gameState.players[0].horses.first.position,
          const TrackPosition(0),
        );
        expect(pool, isNotEmpty); // the shipped bank itself is not empty
      },
    );
  });
}
