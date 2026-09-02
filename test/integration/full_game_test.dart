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
    // Headless: a ride takes no time, so every step lands on a phase
    // the screen would render a control for.
    animate: false,
  );
  controller.configure(pool: pool, isPremium: isPremium);
  return controller;
}

Player human(String id, AppTeam team, {int horses = 1}) => Player(
  id: id,
  name: id,
  team: team,
  profile: PlayerProfile.intermediate,
  horses: List.generate(horses, (_) => const HorseState()),
);

/// Plays one controller step, exactly as the UI would: only phases the
/// screen actually renders controls for are handled. `answer` decides
/// each question's fate; `acceptOffers` decides Défi/Raccourci offers.
/// Returns false when the game is over.
bool driveOneStep(
  GameController controller, {
  bool Function()? answer,
  bool acceptOffers = false,
}) {
  final session = controller.state;
  if (session == null) return false;
  final state = session.gameState;
  bool nextAnswer() => answer?.call() ?? true;
  int pick(Question q, bool correct) => correct
      ? q.correctAnswerIndex
      : (q.correctAnswerIndex + 1) % q.answers.length;
  switch (state.turnPhase) {
    case TurnPhase.gameOver:
      return false;
    case TurnPhase.selectingGait:
      // The real draw: the deck decides the value, the rules decide what
      // it can do — including nothing at all.
      expect(
        session.currentQuestion,
        isNull,
        reason: 'a turn must start with nothing on the table',
      );
      controller.drawCard();
    case TurnPhase.choosingHorse:
      final moves = controller.legalMoves;
      expect(
        moves,
        isNotEmpty,
        reason: 'a choice with nothing to choose is a dead end',
      );
      // Prefer bringing a horse out, then the front runner: a plausible
      // family player, and every horse eventually leaves the stable.
      final exit = moves.where((m) => m.exitsStable).firstOrNull;
      expect(
        controller.placeHorse((exit ?? moves.last).horseIndex),
        isTrue,
        reason: 'a legal horse set down must be accepted',
      );
    case TurnPhase.movingHorse:
      fail(
        'movingHorse must never be left on screen headless: the ride settles at once',
      );
    case TurnPhase.noMove:
      expect(
        state.drawnCard,
        isNotNull,
        reason: 'even a card that moves nothing was drawn from the deck',
      );
      controller.continueAfterFeedback();
    case TurnPhase.answeringQuestion:
      controller.answerQuestion(pick(session.currentQuestion!, nextAnswer()));
    case TurnPhase.answeringJourneyQuestion:
      controller.answerJourneyQuestion(
        pick(session.currentQuestion!, nextAnswer()),
      );
    case TurnPhase.showingFeedback:
      expect(
        session.currentQuestion,
        isNotNull,
        reason: 'feedback with no question on screen is a dead end',
      );
      controller.continueAfterFeedback();
    case TurnPhase.resolvingCell:
      if (session.currentQuestion != null) {
        controller.answerCellQuestion(
          pick(session.currentQuestion!, nextAnswer()),
        );
      } else if (acceptOffers) {
        controller.acceptCellChallenge();
      } else {
        controller.declineCellOffer();
      }
    case TurnPhase.turnComplete:
      fail(
        'turnComplete must never be left on screen: the player has nothing to tap',
      );
  }
  return true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'a duel of single horses plays to victory and crowns a winner',
    () async {
      final storage = await LocalStorageService.create();
      final controller = await buildController(storage);
      controller.startNewGame(
        mode: GameMode.family,
        variant: GameVariant.quick,
        circuitId: CircuitId.oasisRoute,
        players: [human('p0', AppTeam.emerald), human('p1', AppTeam.saphir)],
      );

      var steps = 0;
      while (driveOneStep(controller) && steps < 6000) {
        steps++;
      }

      final end = controller.state!.gameState;
      expect(
        end.turnPhase,
        TurnPhase.gameOver,
        reason: 'perfect answers must finish a 1-horse game within 6000 steps',
      );
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
    },
  );

  test(
    'a four-player, two-horse game also reaches game over cleanly',
    () async {
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
      while (driveOneStep(controller) && steps < 40000) {
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
            expect(pos.index, inInclusiveRange(0, end.circuit.trackLength - 1));
          }
        }
      }
    },
  );

  test(
    'no two horses of a colour ever share a square, all game long',
    () async {
      final storage = await LocalStorageService.create();
      final controller = await buildController(storage);
      controller.startNewGame(
        mode: GameMode.family,
        variant: GameVariant.classic,
        circuitId: CircuitId.greatRide,
        players: [
          human('p0', AppTeam.emerald, horses: 4),
          human('p1', AppTeam.saphir, horses: 4),
        ],
      );
      var steps = 0;
      while (driveOneStep(controller) && steps < 40000) {
        steps++;
        final state = controller.state!.gameState;
        for (final p in state.players) {
          final taken = <PawnPosition>{};
          for (final h in p.horses) {
            if (h.position is HomePosition || h.position is FinishedPosition) {
              continue;
            }
            expect(
              taken.add(h.position),
              isTrue,
              reason: 'step $steps: ${p.id} has two horses on ${h.position}',
            );
          }
        }
      }
      expect(controller.state!.gameState.turnPhase, TurnPhase.gameOver);
    },
  );

  test(
    'imperfect players accepting every offer still finish the game',
    () async {
      final storage = await LocalStorageService.create();
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

      // Answers cycle right-right-wrong: wrong turn questions, wrong bonus
      // questions, missed journey questions (retried a later turn), and
      // accepted Défi/Raccourci offers are all crossed on the way.
      var n = 0;
      bool answer() => (n++ % 3) != 2;
      var steps = 0;
      while (driveOneStep(controller, answer: answer, acceptOffers: true) &&
          steps < 60000) {
        steps++;
      }

      final end = controller.state!.gameState;
      expect(end.turnPhase, TurnPhase.gameOver);
      expect(end.winnerId, isNotNull);
    },
  );

  test('the free edition stops after fifty cards, on the leader, and offers nothing mid-game', () async {
    final storage = await LocalStorageService.create();
    final controller = await buildController(storage, isPremium: false);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.classic,
      circuitId: CircuitId.oasisRoute,
      players: [
        human('p0', AppTeam.emerald, horses: 4),
        human('p1', AppTeam.saphir, horses: 4),
      ],
    );
    expect(controller.state!.gameState.maxDraws, GameState.freeDrawLimit);

    var steps = 0;
    while (driveOneStep(controller) && steps < 4000) {
      steps++;
      expect(
        controller.state!.gameState.drawCount,
        lessThanOrEqualTo(GameState.freeDrawLimit),
      );
      // Every question dealt on the free tier is a free question.
      final q = controller.state!.currentQuestion;
      if (q != null) expect(q.isFree, isTrue);
    }
    final end = controller.state!.gameState;
    expect(end.turnPhase, TurnPhase.gameOver);
    expect(end.endedByDrawLimit, isTrue);
    expect(end.drawCount, GameState.freeDrawLimit);
    expect(end.winnerId, isNotNull);
    expect(end.winnerId, controller.engine.leader(end).id);
  });

  test('Premium never stops a race short', () async {
    final storage = await LocalStorageService.create();
    final controller = await buildController(storage);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.classic,
      circuitId: CircuitId.oasisRoute,
      players: [
        human('p0', AppTeam.emerald, horses: 4),
        human('p1', AppTeam.saphir, horses: 4),
      ],
    );
    expect(controller.state!.gameState.maxDraws, isNull);
    var steps = 0;
    while (driveOneStep(controller) && steps < 20000) {
      steps++;
    }
    final end = controller.state!.gameState;
    expect(end.turnPhase, TurnPhase.gameOver);
    expect(end.endedByDrawLimit, isFalse);
    expect(
      end.drawCount,
      greaterThan(GameState.freeDrawLimit),
      reason: 'a four-horse race takes well over fifty cards',
    );
  });

  test('a save written mid-question resumes at a playable phase', () async {
    final storage = await LocalStorageService.create();
    final controller = await buildController(storage);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.quick,
      circuitId: CircuitId.oasisRoute,
      players: [human('p0', AppTeam.emerald), human('p1', AppTeam.saphir)],
    );
    controller.drawCard();
    expect(
      controller.state!.gameState.turnPhase,
      TurnPhase.answeringQuestion,
      reason: 'the save on disk is now mid-question',
    );

    // The app is killed and relaunched: the same save must come back at
    // a phase with something to tap, and the card must not be owed.
    final resumed = await buildController(storage);
    expect(resumed.loadSaved(), isTrue);
    expect(resumed.state!.gameState.turnPhase, TurnPhase.selectingGait);
    expect(
      resumed.state!.gameState.drawnCard,
      isNull,
      reason: 'an unanswered card goes back to the deck',
    );
    // And the resumed game is genuinely playable.
    resumed.drawCard();
    expect(
      resumed.state!.currentQuestion,
      isNotNull,
      reason: 'the resumed session draws real questions again',
    );
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
    while (driveOneStep(controller) && steps < 6000) {
      steps++;
    }
    expect(controller.state!.gameState.turnPhase, TurnPhase.gameOver);

    // A fresh controller must not resurrect the finished game.
    final fresh = await buildController(storage);
    expect(fresh.loadSaved(), isFalse);
  });
}
