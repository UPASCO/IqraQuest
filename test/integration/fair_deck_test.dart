import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/theme/app_team.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'solo_game_flow_test.dart' show buildController, human;

/// The deck is the die. Everyone draws from it the same way — a child
/// draws the same values as an adult and gets a question they can read;
/// the opponent draws the same values as the player and never picks its
/// own.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a child draws the full range of values but is asked easy questions', () async {
    final storage = await LocalStorageService.create();
    final controller = await buildController(storage);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.quick,
      circuitId: CircuitId.oasisRoute,
      players: [
        human('kid', AppTeam.emerald, profile: PlayerProfile.easy),
        human('dad', AppTeam.saphir, profile: PlayerProfile.expert),
      ],
    );

    final values = <int>{};
    for (var i = 0; i < 40; i++) {
      final s = controller.state!;
      if (s.gameState.turnPhase == TurnPhase.gameOver) break;
      controller.drawCard();
      final drawn = controller.state!.gameState.pendingGait;
      final q = controller.state!.currentQuestion;
      if (drawn == null || q == null) {
        // A card that opened nothing (no 6 for a stabled horse): the
        // turn passes.
        controller.continueAfterFeedback();
        continue;
      }
      final player = controller.state!.gameState.currentPlayer;
      if (player.id == 'kid') {
        values.add(drawn.choice.steps);
        expect(
          q.difficulty,
          QuestionDifficulty.easy,
          reason:
              'a child drew a ${drawn.choice.steps} and got a ${q.difficulty} question',
        );
      } else {
        expect(
          q.difficulty,
          QuestionDifficulty.hard,
          reason:
              'the expert drew a ${drawn.choice.steps} and got a ${q.difficulty} question',
        );
      }
      controller.answerQuestion(q.correctAnswerIndex);
      if (controller.state!.gameState.turnPhase == TurnPhase.showingFeedback) {
        controller.continueAfterFeedback();
      }
    }
    // The card's value is not capped for the child: the pace stays fair.
    expect(
      values.length,
      greaterThan(2),
      reason: 'child only ever drew $values',
    );
  });

  test(
    'the opponent draws from the deck rather than choosing its value',
    () async {
      final storage = await LocalStorageService.create();
      final controller = await buildController(storage);
      controller.startNewGame(
        mode: GameMode.solo,
        variant: GameVariant.quick,
        circuitId: CircuitId.oasisRoute,
        players: [
          Player(
            id: 'ai',
            name: 'Rider',
            team: kBoardSeats[0],
            aiDifficulty: AiDifficulty.hard,
            horses: const [HorseState()],
          ),
        ],
      );
      // The first beat of the AI turn reveals its card.
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      final drawn = controller.state!.gameState.drawnCard;
      expect(drawn, isNotNull);
      // Any value 1..6 is legal; a hard AI choosing its own value would
      // always take a 6 to open its stable.
      expect(drawn!.steps, inInclusiveRange(1, 6));
      // Let the remaining beats run out before the controller goes away.
      await Future<void>.delayed(const Duration(milliseconds: 3000));
      controller.dispose();
    },
  );

  test('race again keeps the riders and resets the board', () async {
    final storage = await LocalStorageService.create();
    final controller = await buildController(storage);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.quick,
      circuitId: CircuitId.oasisRoute,
      players: [
        human('Amina', AppTeam.emerald, profile: PlayerProfile.easy),
        human('Bilal', AppTeam.saphir),
      ],
    );
    // Play one correct turn so there is state to wipe: a 6 opens the
    // gate, so the card is sure to be played rather than passed.
    controller.selectGait(0, const MovementChoice(6));
    final q = controller.state!.currentQuestion!;
    controller.answerQuestion(q.correctAnswerIndex);
    final before = controller.state!.gameState;
    expect(before.players.first.rewards.knowledgePoints, greaterThan(0));

    expect(controller.restartSameSetup(), isTrue);
    final after = controller.state!.gameState;
    expect(after.gameId, isNot(before.gameId));
    expect(after.turnPhase, TurnPhase.selectingGait);
    expect(after.players.map((p) => p.name), ['Amina', 'Bilal']);
    expect(after.players.first.profile, PlayerProfile.easy);
    for (final p in after.players) {
      expect(p.rewards.knowledgePoints, 0);
      expect(p.streak.current, 0);
      expect(p.horses.every((h) => h.position is HomePosition), isTrue);
    }
  });
}
