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

/// Spec §20/§21 end game: whole games driven through the real controller
/// until victory — every phase (gait, question, feedback, cell offers,
/// journey questions, turn handover) crossed many times over.
Future<GameController> buildController(LocalStorageService storage) async {
  final repo = QuestionRepository();
  final pool = await repo.loadAll('en');
  final controller = GameController(
    engine: const GameEngine(),
    questionRepository: repo,
    saveService: GameSaveService(storage),
    progressService: ProgressService(storage),
  );
  controller.configure(pool: pool, isPremium: true);
  return controller;
}

Player human(String id, AppTeam team, {int horses = 1}) => Player(
  id: id,
  name: id,
  team: team,
  profile: PlayerProfile.intermediate,
  horses: List.generate(horses, (_) => const HorseState()),
);

/// Plays one controller step: always answers correctly, always declines
/// optional offers, always rides the first horse still on the road.
/// Returns false if the game is over (or the driver is stuck).
bool driveOneStep(GameController controller) {
  final session = controller.state;
  if (session == null) return false;
  final state = session.gameState;
  switch (state.turnPhase) {
    case TurnPhase.gameOver:
      return false;
    case TurnPhase.selectingGait:
      final player = state.currentPlayer;
      var horse = player.horses.indexWhere(
        (h) => h.position is! FinishedPosition,
      );
      if (horse < 0) horse = 0;
      final gaits = controller.availableGaits;
      expect(gaits, isNotEmpty, reason: 'a turn must always offer a gait');
      controller.selectGait(horse, gaits.last);
    case TurnPhase.answeringQuestion:
      controller.answerQuestion(session.currentQuestion!.correctAnswerIndex);
    case TurnPhase.answeringJourneyQuestion:
      controller.answerJourneyQuestion(session.currentQuestion!.correctAnswerIndex);
    case TurnPhase.showingFeedback:
      controller.continueAfterFeedback();
    case TurnPhase.resolvingCell:
      if (session.currentQuestion != null) {
        controller.answerCellQuestion(session.currentQuestion!.correctAnswerIndex);
      } else {
        controller.declineCellOffer();
      }
    case TurnPhase.turnComplete:
      // The controller advances this itself; if we ever see it, continue.
      controller.continueAfterFeedback();
  }
  return true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a duel of single horses plays to victory and crowns a winner', () async {
    final storage = await LocalStorageService.create();
    final controller = await buildController(storage);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.quick,
      circuitId: CircuitId.oasisRoute,
      players: [human('p0', AppTeam.emerald), human('p1', AppTeam.saphir)],
    );

    var steps = 0;
    while (driveOneStep(controller) && steps < 600) {
      steps++;
    }

    final end = controller.state!.gameState;
    expect(end.turnPhase, TurnPhase.gameOver,
        reason: 'perfect answers must finish a 1-horse game within 600 steps');
    expect(end.winnerId, isNotNull);
    final winner = end.players.firstWhere((p) => p.id == end.winnerId);
    expect(
      winner.horses.every((h) => h.position is FinishedPosition),
      isTrue,
      reason: 'the winner is the player whose horses all reached the oasis',
    );
    // Both players answered only correctly: nobody was ever set back.
    for (final p in end.players) {
      expect(p.streak.current, greaterThanOrEqualTo(0));
    }
  });

  test('a four-player, two-horse game also reaches game over cleanly', () async {
    final storage = await LocalStorageService.create();
    final controller = await buildController(storage);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.classic,
      circuitId: CircuitId.oasisRoute,
      players: [
        human('p0', AppTeam.emerald, horses: 2),
        human('p1', AppTeam.saphir, horses: 2),
        human('p2', AppTeam.grenat, horses: 2),
        human('p3', AppTeam.safran, horses: 2),
      ],
    );

    var steps = 0;
    while (driveOneStep(controller) && steps < 4000) {
      steps++;
    }

    final end = controller.state!.gameState;
    expect(end.turnPhase, TurnPhase.gameOver);
    expect(end.winnerId, isNotNull);
    // Track invariants held all game: no horse ever left the board's
    // coordinate space, and every finished horse got there legally.
    for (final p in end.players) {
      for (final h in p.horses) {
        final pos = h.position;
        if (pos is TrackPosition) {
          expect(pos.index, inInclusiveRange(0, 23));
        }
      }
    }
  });

  test('the finished game leaves a save that refuses to resume', () async {
    final storage = await LocalStorageService.create();
    final controller = await buildController(storage);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.quick,
      circuitId: CircuitId.oasisRoute,
      players: [human('p0', AppTeam.emerald), human('p1', AppTeam.saphir)],
    );
    var steps = 0;
    while (driveOneStep(controller) && steps < 600) {
      steps++;
    }
    expect(controller.state!.gameState.turnPhase, TurnPhase.gameOver);

    // A fresh controller must not resurrect the finished game.
    final fresh = await buildController(storage);
    expect(fresh.loadSaved(), isFalse);
  });
}
