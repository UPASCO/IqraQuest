import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/game/application/game_controller.dart';
import 'package:iqraquest/features/game/domain/game_engine.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/services/game_save_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/theme/app_team.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A game closed at any instant of the placement turn — mid-drag, on a
/// bonus square, before the drop — resumes at a playable point with
/// everything earned still earned and the sixteen squares exactly where
/// they were.
Future<GameController> _controller(LocalStorageService storage) async {
  final repo = QuestionRepository();
  final pool = await repo.loadAll('en');
  final controller = GameController(
    engine: const GameEngine(),
    questionRepository: repo,
    saveService: GameSaveService(storage),
    progressService: ProgressService(storage),
    random: Random(3),
    animate: false,
  );
  controller.configure(pool: pool, isPremium: true);
  return controller;
}

GameState _base({TurnPhase phase = TurnPhase.selectingGait, List<BonusTile>? tiles}) {
  final now = DateTime(2026, 1, 1);
  return GameState(
    gameId: 'resume',
    gameMode: GameMode.family,
    gameVariant: GameVariant.classic,
    circuitId: CircuitId.oasisRoute,
    players: [
      Player(
        id: 'p0',
        name: 'A',
        team: AppTeam.emerald,
        horses: const [HorseState(position: TrackPosition(3)), HorseState()],
      ),
      Player(
        id: 'p1',
        name: 'B',
        team: AppTeam.saphir,
        horses: const [HorseState(position: TrackPosition(20)), HorseState()],
      ),
    ],
    currentPlayerIndex: 0,
    turnPhase: phase,
    askedQuestionIds: const {'q_seen'},
    bonusTiles: tiles ?? const [BonusTile(trackIndex: 5, value: 10)],
    bonusSeed: 99,
    startedAt: now,
    updatedAt: now,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('closed on a bonus square: the bonus rides on resume', () async {
    final storage = await LocalStorageService.create();
    const engine = GameEngine();
    var s = engine.drawCard(_base(), const MovementChoice(2));
    s = engine.applyAnswer(s, correct: true, questionId: 'q1');
    s = engine.openPlacement(s);
    s = engine.placeHorse(s, 0);
    expect(s.pendingBonus?.value, 10);
    await GameSaveService(storage).save(s);

    final controller = await _controller(storage);
    expect(controller.loadSaved(), isTrue);
    final after = controller.state!.gameState;
    expect(after.players[0].horses[0].position, const TrackPosition(15));
    expect(after.bonusTiles, s.bonusTiles);
    // Headless, the ride settles at once and the turn is handed over.
    expect(after.currentPlayerIndex, 1);
    expect(after.turnPhase, TurnPhase.selectingGait);
  });

  test('closed before the drop: the placement is still open', () async {
    final storage = await LocalStorageService.create();
    const engine = GameEngine();
    var s = engine.drawCard(_base(), const MovementChoice(4));
    s = engine.applyAnswer(s, correct: true, questionId: 'q1');
    s = engine.openPlacement(s);
    await GameSaveService(storage).save(s);

    final controller = await _controller(storage);
    expect(controller.loadSaved(), isTrue);
    expect(controller.state!.gameState.turnPhase, TurnPhase.choosingHorse);
    expect(controller.state!.gameState.drawnCard?.steps, 4);
    expect(controller.legalMoves.map((m) => m.horseIndex), [0]);
    expect(controller.placeHorse(0), isTrue);
    expect(
      controller.state!.gameState.players[0].horses[0].position,
      const TrackPosition(7),
    );
  });

  test('closed on the verdict of a right answer: resumes at the placement', () async {
    final storage = await LocalStorageService.create();
    const engine = GameEngine();
    var s = engine.drawCard(_base(), const MovementChoice(4));
    s = engine.applyAnswer(s, correct: true, questionId: 'q1');
    await GameSaveService(storage).save(s);

    final controller = await _controller(storage);
    expect(controller.loadSaved(), isTrue);
    expect(controller.state!.gameState.turnPhase, TurnPhase.choosingHorse);
  });

  test('closed on an unanswered question: a fresh card, nothing owed', () async {
    final storage = await LocalStorageService.create();
    const engine = GameEngine();
    final s = engine.drawCard(_base(), const MovementChoice(6));
    await GameSaveService(storage).save(s);

    final controller = await _controller(storage);
    expect(controller.loadSaved(), isTrue);
    final after = controller.state!.gameState;
    expect(after.turnPhase, TurnPhase.selectingGait);
    expect(after.drawnCard, isNull);
    expect(after.extraTurn, isFalse);
    expect(after.currentPlayerIndex, 0);
  });

  test('a resumed game never re-asks what it already asked', () async {
    final storage = await LocalStorageService.create();
    await GameSaveService(storage).save(_base());
    final controller = await _controller(storage);
    expect(controller.loadSaved(), isTrue);
    final seen = <String>{'q_seen'};
    for (var i = 0; i < 10; i++) {
      controller.drawCard();
      final q = controller.state!.currentQuestion!;
      expect(seen.add(q.id), isTrue, reason: '${q.id} was already asked');
      controller.answerQuestion(q.correctAnswerIndex);
      controller.continueAfterFeedback();
      if (controller.state!.gameState.turnPhase == TurnPhase.choosingHorse) {
        controller.placeHorse(controller.legalMoves.first.horseIndex);
      } else if (controller.state!.gameState.turnPhase == TurnPhase.noMove) {
        controller.continueAfterFeedback();
      }
      if (controller.state!.gameState.turnPhase == TurnPhase.gameOver) break;
    }
  });

  test('a save from the previous turn order restarts its turn at the deck, squares dealt', () async {
    final storage = await LocalStorageService.create();
    // Schema 2 had no bonus squares and meant "choosingHorse" as the
    // choice *before* the question: the positions are kept, the turn
    // simply starts again.
    final json = _base(phase: TurnPhase.choosingHorse, tiles: const []).toJson()
      ..['schemaVersion'] = 2
      ..['drawnCard'] = 5
      ..remove('bonusTiles')
      ..remove('bonusSeed');
    await storage.setJson('iqraquest.save.currentGame.v1', json);

    final controller = await _controller(storage);
    expect(controller.loadSaved(), isTrue);
    final after = controller.state!.gameState;
    expect(after.turnPhase, TurnPhase.selectingGait);
    expect(after.drawnCard, isNull);
    expect(after.players[0].horses[0].position, const TrackPosition(3));
    expect(after.bonusTiles.length, 16, reason: 'an old save gets its squares');
  });
}
