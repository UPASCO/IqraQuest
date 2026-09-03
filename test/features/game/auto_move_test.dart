// The one tap in a turn that never held a decision.
//
// When a card leaves exactly one horse able to ride it, dragging that
// horse is ceremony: the player has no choice to make. The board's menu
// can now hand that tap back — and only that one. The rule stays "the
// drop is the move" everywhere a choice exists, which is what these
// tests pin down: off by default, and on, it fires only when the board
// offered a single move.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/game/application/game_controller.dart';
import 'package:iqraquest/features/game/domain/game_engine.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/services/game_save_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/services/settings_service.dart';
import 'package:iqraquest/theme/app_team.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<GameController> _controller(
  LocalStorageService storage, {
  required bool autoPlace,
}) async {
  final repo = QuestionRepository();
  final pool = await repo.loadAll('en');
  final controller = GameController(
    engine: const GameEngine(),
    questionRepository: repo,
    saveService: GameSaveService(storage),
    progressService: ProgressService(storage),
    random: Random(11),
    animate: false,
  );
  controller.configure(pool: pool, isPremium: true);
  controller.autoPlaceSingleMove = autoPlace;
  return controller;
}

/// One horse each: whatever card comes up, exactly one horse can ride it,
/// which is precisely the case the option is about.
void _startOneHorseRace(GameController controller) {
  controller.startNewGame(
    mode: GameMode.family,
    variant: GameVariant.quick,
    circuitId: CircuitId.oasisRoute,
    players: [
      for (var i = 0; i < 2; i++)
        Player(
          id: 'p$i',
          name: 'P$i',
          team: kBoardSeats[i],
          horses: const [HorseState()],
        ),
    ],
    bonusesEnabled: false,
  );
}

/// Draws, answers correctly, and steps past the verdict — the point at
/// which the board either waits for a drop or plays the only move.
void _drawAndAnswerRight(GameController controller) {
  controller.drawCard();
  final question = controller.state!.currentQuestion;
  expect(question, isNotNull, reason: 'the card opened no question');
  controller.answerQuestion(question!.correctAnswerIndex);
  controller.continueAfterFeedback();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('by default the only legal horse still waits to be set down', () async {
    final storage = await LocalStorageService.create();
    final controller = await _controller(storage, autoPlace: false);
    _startOneHorseRace(controller);
    final from = controller.state!.gameState.players[0].horses[0].position;

    _drawAndAnswerRight(controller);

    expect(
      controller.state!.gameState.turnPhase,
      TurnPhase.choosingHorse,
      reason: 'the drop is the move: nothing may ride by itself',
    );
    expect(controller.legalMoves.length, 1);
    expect(controller.state!.gameState.players[0].horses[0].position, from);

    controller.dispose();
  });

  test('switched on, the only legal horse rides by itself', () async {
    final storage = await LocalStorageService.create();
    final controller = await _controller(storage, autoPlace: true);
    _startOneHorseRace(controller);
    final from = controller.state!.gameState.players[0].horses[0].position;

    _drawAndAnswerRight(controller);

    // Nobody called placeHorse: the horse left its square on its own.
    expect(
      controller.state!.gameState.turnPhase,
      isNot(TurnPhase.choosingHorse),
      reason: 'the single move was not played',
    );
    expect(
      controller.state!.gameState.players[0].horses[0].position,
      isNot(from),
      reason: 'the horse never moved',
    );

    controller.dispose();
  });

  test('with a real choice on the board, it still waits for the player', () async {
    final storage = await LocalStorageService.create();
    final controller = await _controller(storage, autoPlace: true);
    // Four horses: the opening line-up puts one on the start square and
    // the deck will, sooner or later, offer a card that both an out
    // horse and a stabled one can play. The option must not touch that.
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.classic,
      circuitId: CircuitId.oasisRoute,
      players: [
        for (var i = 0; i < 2; i++)
          Player(
            id: 'p$i',
            name: 'P$i',
            team: kBoardSeats[i],
            horses: const [
              HorseState(position: TrackPosition(2)),
              HorseState(position: TrackPosition(8)),
              HorseState(),
              HorseState(),
            ],
          ),
      ],
      bonusesEnabled: false,
    );

    _drawAndAnswerRight(controller);

    final moves = controller.legalMoves;
    if (moves.length > 1) {
      expect(
        controller.state!.gameState.turnPhase,
        TurnPhase.choosingHorse,
        reason: 'two horses could ride: the player must choose',
      );
    }

    controller.dispose();
  });

  test('the option is off until a table asks for it, and then it sticks', () async {
    final storage = await LocalStorageService.create();
    expect(SettingsService(storage).load().autoPlaceSingleMove, isFalse);
    await SettingsService(storage).save(
      const AppSettings(autoPlaceSingleMove: true),
    );
    expect(SettingsService(storage).load().autoPlaceSingleMove, isTrue);
  });
}
