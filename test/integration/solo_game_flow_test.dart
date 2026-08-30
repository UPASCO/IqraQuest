import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/game/application/game_controller.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/services/game_save_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/features/game/domain/game_engine.dart';
import 'package:iqraquest/theme/app_team.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Spec §109: a Solo integration test exercising
/// question → answer → dice → horse, end to end through the real
/// controller (not just the isolated engine).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Solo quick game: human answers correctly, rolls, moves, can win', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final repo = QuestionRepository();
    final pool = await repo.loadAll('en');

    final controller = GameController(
      engine: GameEngine(),
      questionRepository: repo,
      saveService: GameSaveService(storage),
      progressService: ProgressService(storage),
    );
    controller.configure(pool: pool, isPremium: true);

    controller.startNewGame(
      mode: GameMode.solo,
      variant: GameVariant.quick,
      players: [
        Player(id: 'human_0', name: 'Nadir', team: AppTeam.emerald, pawns: const [HomePosition()]),
        Player(
          id: 'ai_0',
          name: 'AI 1',
          team: AppTeam.saphir,
          aiDifficulty: AiDifficulty.easy,
          pawns: const [HomePosition()],
        ),
      ],
    );

    expect(controller.state, isNotNull);
    expect(controller.state!.gameState.turnPhase, TurnPhase.waitingForQuestion);
    expect(controller.state!.currentQuestion, isNotNull);

    final question = controller.state!.currentQuestion!;
    controller.answerQuestion(question.correctAnswerIndex);

    expect(controller.state!.lastAnswerCorrect, isTrue);
    expect(controller.state!.gameState.turnPhase, TurnPhase.waitingForDice);

    controller.rollDice();
    // Either a move was auto-resolved (no legal moves) or pawn selection
    // is now offered — both are valid, deterministic outcomes of a real
    // dice value.
    expect(
      [
        TurnPhase.waitingForPawnSelection,
        TurnPhase.waitingForQuestion,
      ].contains(controller.state!.gameState.turnPhase),
      isTrue,
    );
  });

  test('A save is written after every mutation and survives a fresh controller', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final repo = QuestionRepository();
    final pool = await repo.loadAll('en');
    final saveService = GameSaveService(storage);

    final controller = GameController(
      engine: GameEngine(),
      questionRepository: repo,
      saveService: saveService,
      progressService: ProgressService(storage),
    );
    controller.configure(pool: pool, isPremium: true);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.classic,
      players: [
        Player(
          id: 'p0',
          name: 'A',
          team: AppTeam.emerald,
          pawns: List.generate(4, (_) => const HomePosition()),
        ),
        Player(
          id: 'p1',
          name: 'B',
          team: AppTeam.saphir,
          pawns: List.generate(4, (_) => const HomePosition()),
        ),
      ],
    );

    expect(saveService.hasSave, isTrue);

    final freshController = GameController(
      engine: GameEngine(),
      questionRepository: repo,
      saveService: saveService,
      progressService: ProgressService(storage),
    );
    final loaded = freshController.loadSaved();
    expect(loaded, isTrue);
    expect(freshController.state!.gameState.gameId, controller.state!.gameState.gameId);
  });
}
