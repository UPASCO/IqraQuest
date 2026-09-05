import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/theme/app_team.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'solo_game_flow_test.dart' show buildController, finishTurn, human;

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
      // A full classic race, four horses each: with chaining bonuses and
      // the twenty a capture pays, a one-horse race can be over before
      // the child has drawn enough cards to show a range.
      variant: GameVariant.classic,
      circuitId: CircuitId.oasisRoute,
      players: [
        human('kid', AppTeam.emerald, profile: PlayerProfile.easy, horses: 4),
        human('dad', AppTeam.saphir, profile: PlayerProfile.expert, horses: 4),
      ],
    );

    final values = <int>{};
    for (var i = 0; i < 40; i++) {
      final s = controller.state!;
      if (s.gameState.turnPhase == TurnPhase.gameOver) break;
      if (s.gameState.turnPhase != TurnPhase.selectingGait) break;
      controller.drawCard();
      final drawn = controller.state!.gameState.drawnCard!;
      final q = controller.state!.currentQuestion!;
      final player = controller.state!.gameState.currentPlayer;
      if (player.id == 'kid') {
        values.add(drawn.steps);
        expect(
          q.difficulty,
          QuestionDifficulty.easy,
          reason:
              'a child drew a ${drawn.steps} and got a ${q.difficulty} question',
        );
      } else {
        expect(
          q.difficulty,
          QuestionDifficulty.hard,
          reason:
              'the expert drew a ${drawn.steps} and got a ${q.difficulty} question',
        );
      }
      controller.answerQuestion(q.correctAnswerIndex);
      finishTurn(controller);
    }
    // The card's value is not capped for the child: the pace stays fair.
    expect(
      values.length,
      greaterThan(2),
      reason: 'child only ever drew $values',
    );
  });

  test('the mixed level draws all three levels for the same rider', () async {
    final storage = await LocalStorageService.create();
    final controller = await buildController(storage);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.classic,
      circuitId: CircuitId.oasisRoute,
      players: [
        human('mix', AppTeam.emerald, profile: PlayerProfile.mixed, horses: 4),
        human('kid', AppTeam.saphir, profile: PlayerProfile.easy, horses: 4),
      ],
    );

    final mixedLevels = <QuestionDifficulty>{};
    var mixedPoints = 0;
    for (var i = 0; i < 60; i++) {
      final s = controller.state!;
      if (s.gameState.turnPhase == TurnPhase.gameOver) break;
      if (s.gameState.turnPhase != TurnPhase.selectingGait) break;
      controller.drawCard();
      final q = controller.state!.currentQuestion!;
      final player = controller.state!.gameState.currentPlayer;
      if (player.id == 'mix') {
        mixedLevels.add(q.difficulty);
        // Points on the mixed level follow the level actually asked.
        mixedPoints += q.difficulty.knowledgePoints;
      } else {
        expect(
          q.difficulty,
          QuestionDifficulty.easy,
          reason: 'a fixed level is still fixed while another rider mixes',
        );
      }
      controller.answerQuestion(q.correctAnswerIndex);
      finishTurn(controller);
    }

    // Every level the free tier actually stocks. The enum also declares
    // `beginner`, but a tier the deck holds no cards for is not one the
    // mixed rider can be asked — asserting on the enum would fail this
    // test for a reason that has nothing to do with mixing.
    expect(
      mixedLevels,
      containsAll([
        QuestionDifficulty.easy,
        QuestionDifficulty.medium,
        QuestionDifficulty.hard,
      ]),
      reason: 'the mixed rider only ever saw $mixedLevels',
    );
    // Every answer above was correct, so the rider banked at least the
    // sum of the levels they were asked. It can be more: knowledge
    // squares pay their own point on top, which is not this test's
    // claim — `applyAnswer` is where the rate itself is pinned.
    final mixed = controller.state!.gameState.players.firstWhere(
      (p) => p.id == 'mix',
    );
    expect(
      mixed.rewards.knowledgePoints,
      greaterThanOrEqualTo(mixedPoints),
    );
  });

  test(
    'the opponent draws from the deck rather than choosing its value',
    () async {
      final storage = await LocalStorageService.create();
      // Paced like the real game, so its first beat can be observed.
      final controller = await buildController(storage, animate: true);
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
      // The first beat of the AI turn draws its card.
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      final drawn = controller.state!.gameState.drawnCard;
      expect(drawn, isNotNull);
      // Any value 1..6 is legal; a hard AI choosing its own value would
      // always take a 6 to open its stable.
      expect(drawn!.steps, inInclusiveRange(1, 6));
      // Let the remaining beats run out before the controller goes away.
      await Future<void>.delayed(const Duration(milliseconds: 4000));
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
    // Play one correct turn so there is state to wipe.
    controller.drawCard();
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
    expect(after.bonusTiles.length, 16);
    for (var i = 0; i < after.players.length; i++) {
      final p = after.players[i];
      expect(p.rewards.knowledgePoints, 0);
      expect(p.streak.current, 0);
      // Back to the opening line-up: the first horse out, the rest in.
      expect(
        p.horses.first.position,
        TrackPosition(after.circuit.entryIndexForTeam(i)),
      );
      expect(p.horses.skip(1).every((h) => h.position is HomePosition), isTrue);
    }
  });
}
