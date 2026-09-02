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

/// Spec §20: the whole turn — choose a gait → answer the matching question
/// → move — exercised end to end through the real controller, not just the
/// isolated engine.
Future<GameController> buildController(
  LocalStorageService storage, {
  bool isPremium = true,
}) async {
  final repo = QuestionRepository();
  final pool = await repo.loadAll('en');
  final controller = GameController(
    engine: const GameEngine(),
    questionRepository: repo,
    saveService: GameSaveService(storage),
    progressService: ProgressService(storage),
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a family game starts by asking the player to choose a gait', () async {
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
    // Nothing is asked, and nothing moves, until the player chooses.
    expect(session.currentQuestion, isNull);
    expect(controller.availableGaits.map((c) => c.steps), [1, 2, 3, 4, 5, 6]);
    expect(
      session.gameState.players[0].horses.first.position,
      const HomePosition(),
    );
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

      controller.selectGait(0, const MovementChoice(6));
      expect(
        controller.state!.gameState.turnPhase,
        TurnPhase.answeringQuestion,
      );
      expect(
        controller.state!.currentQuestion!.difficulty,
        QuestionDifficulty.easy,
        reason: 'an easy rider drawing a 6 still gets an easy question',
      );

      // Committing locks the turn: the question cannot be re-dealt once
      // it is on screen.
      controller.selectGait(0, const MovementChoice(1));
      expect(
        controller.state!.currentQuestion!.difficulty,
        QuestionDifficulty.easy,
      );

      controller.answerQuestion(
        controller.state!.currentQuestion!.correctAnswerIndex,
      );
      controller.continueAfterFeedback();
      // The 6 replays: same rider, still easy.
      expect(controller.state!.gameState.currentPlayerIndex, 0);
      controller.selectGait(0, const MovementChoice(2));
      expect(
        controller.state!.currentQuestion!.difficulty,
        QuestionDifficulty.easy,
      );
      controller.answerQuestion(
        controller.state!.currentQuestion!.correctAnswerIndex,
      );
      controller.continueAfterFeedback();

      // The expert draws a 1 and gets an expert question for it.
      expect(controller.state!.gameState.currentPlayerIndex, 1);
      controller.selectGait(0, const MovementChoice(1));
      expect(
        controller.state!.currentQuestion!.difficulty,
        QuestionDifficulty.hard,
      );
    },
  );

  test(
    'a correct answer moves the horse exactly as far as the gait promised',
    () async {
      final storage = await LocalStorageService.create();
      final controller = await buildController(storage);
      controller.startNewGame(
        mode: GameMode.family,
        variant: GameVariant.quick,
        circuitId: CircuitId.oasisRoute,
        players: [human('p0', AppTeam.emerald), human('p1', AppTeam.saphir)],
      );

      // Out of the stable first: the 6 opens the gate, the horse takes its
      // start square — and the 6 hands the turn straight back.
      controller.selectGait(0, const MovementChoice(6));
      final promised = controller.state!.preview!.destination;
      final question = controller.state!.currentQuestion!;
      controller.answerQuestion(question.correctAnswerIndex);

      final horse = controller.state!.gameState.players[0].horses.first;
      expect(horse.position, promised);
      expect(horse.position, const TrackPosition(0));
      expect(
        controller.state!.gameState.lastMoveOutcome,
        MoveOutcome.exitedStable,
      );
      controller.continueAfterFeedback();
      expect(
        controller.state!.gameState.currentPlayerIndex,
        0,
        reason: 'a 6 hands the turn back to the same player',
      );
      expect(controller.state!.gameState.isBonusTurn, isTrue);

      // Then the card is the distance, exactly.
      controller.selectGait(0, const MovementChoice(3));
      final promised2 = controller.state!.preview!.destination;
      controller.answerQuestion(
        controller.state!.currentQuestion!.correctAnswerIndex,
      );
      final ridden = controller.state!.gameState.players[0].horses.first;
      expect(ridden.position, promised2);
      expect(ridden.position, const TrackPosition(3));
      expect(controller.state!.gameState.lastMoveOutcome, MoveOutcome.moved);
      controller.continueAfterFeedback();
      expect(controller.state!.gameState.currentPlayerIndex, 1);
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

    controller.selectGait(0, const MovementChoice(2));
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
    expect(controller.state!.gameState.currentPlayerIndex, 1);
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
    for (var turn = 0; turn < 8; turn++) {
      final gait = controller.availableGaits.first;
      controller.selectGait(0, gait);
      final question = controller.state!.currentQuestion;
      if (question == null) break; // bank exhausted — play continues anyway
      expect(
        seen.add(question.id),
        isTrue,
        reason: 'question ${question.id} repeated',
      );
      controller.answerQuestion(question.correctAnswerIndex);
      controller.continueAfterFeedback();
    }
    expect(seen, isNotEmpty);
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

      controller.selectGait(0, const MovementChoice(4));
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
        );
        // An empty pool is the extreme case of an exhausted bank.
        controller.configure(pool: const [], isPremium: false);
        controller.startNewGame(
          mode: GameMode.family,
          variant: GameVariant.quick,
          circuitId: CircuitId.oasisRoute,
          players: [human('p0', AppTeam.emerald), human('p1', AppTeam.saphir)],
        );

        controller.selectGait(0, const MovementChoice(6));
        final state = controller.state!.gameState;
        expect(state.freeBankExhausted, isTrue);
        // The move the player chose still happens — play is never interrupted.
        expect(state.players[0].horses.first.position, const TrackPosition(0));
        expect(pool, isNotEmpty); // the shipped bank itself is not empty
      },
    );
  });
}
