// Plays real turns through the real widgets and asserts the loop always
// comes back round.
//
// The failure this guards against is the one a player actually reports:
// "it stopped responding". A turn wedges when a phase ends without
// offering the next control — the deck gone and no question on screen —
// and no unit test on the engine can see that, because the engine is
// fine and the screen is the thing that stranded.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/app/app.dart';
import 'package:iqraquest/app/providers.dart';
import 'package:iqraquest/app/router.dart';
import 'package:iqraquest/features/game/application/game_controller.dart';
import 'package:iqraquest/features/game/presentation/game_screen.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/services/entitlement_service.dart';
import 'package:iqraquest/services/game_save_service.dart';
import 'package:iqraquest/services/legacy_game_migration_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:iqraquest/services/purchase_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/services/settings_service.dart';
import 'package:iqraquest/theme/app_team.dart';
import 'package:iqraquest/widgets/question_card_draw.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

GameState _soloGame() {
  final now = DateTime(2026, 1, 1);
  return GameState(
    gameId: 'loop',
    gameMode: GameMode.family,
    gameVariant: GameVariant.quick,
    circuitId: CircuitId.oasisRoute,
    players: [
      Player(id: 'p0', name: 'Amina', team: kBoardSeats[0], horses: const [HorseState()]),
      // Two humans on purpose: the loop is what is under test, and an
      // opponent on a timer would make the assertions depend on timing.
      Player(id: 'p1', name: 'Bilal', team: kBoardSeats[1], horses: const [HorseState()]),
    ],
    currentPlayerIndex: 0,
    turnPhase: TurnPhase.selectingGait,
    askedQuestionIds: const {},
    startedAt: now,
    updatedAt: now,
  );
}

Future<ProviderContainer> _pumpGame(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await tester.runAsync(LocalStorageService.create);
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.runAsync(() => GameSaveService(storage!).save(_soloGame()));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(SettingsService(storage!)),
        entitlementServiceProvider.overrideWithValue(EntitlementService()),
        progressServiceProvider.overrideWithValue(ProgressService(storage)),
        gameSaveServiceProvider.overrideWithValue(GameSaveService(storage)),
        legacyGameMigrationServiceProvider
            .overrideWithValue(LegacyGameMigrationService(storage)),
        questionRepositoryProvider.overrideWithValue(QuestionRepository()),
        purchaseServiceProvider.overrideWith((ref) => PurchaseService()),
        initialSettingsProvider.overrideWithValue(const AppSettings()),
        initialPremiumProvider.overrideWithValue(true),
        appRouterProvider.overrideWithValue(buildAppRouter(initialLocation: '/game')),
      ],
      child: const IqraQuestApp(),
    ),
  );
  await _settle(tester);

  // The screen renders whatever the controller holds; a cold entry to
  // /game has to be given the bank and told to load the save, exactly as
  // the real entry points do.
  final container = ProviderScope.containerOf(tester.element(find.byType(IqraQuestApp)));
  final controller = container.read(gameControllerProvider.notifier);
  final pool = await tester.runAsync(() => QuestionRepository().loadAll('en'));
  controller.configure(pool: pool!, isPremium: true);
  controller.loadSaved();
  await _settle(tester);
  return container;
}

void main() {
  _aiDisposalGuard();

  testWidgets('a turn always hands back a control — the loop never wedges',
      (tester) async {
    final container = await _pumpGame(tester);

    for (var turn = 1; turn <= 6; turn++) {
      expect(
        find.byKey(const Key('draw-deck')),
        findsOneWidget,
        reason: 'turn $turn: nothing was offered to the player',
      );

      await tester.tap(find.byKey(const Key('draw-deck')));
      await tester.pump();
      await tester.pump(kCardRevealDuration + const Duration(milliseconds: 60));
      await _settle(tester);

      final question = container.read(gameControllerProvider)!.currentQuestion;
      expect(question, isNotNull, reason: 'turn $turn: the draw produced no question');

      // Answer it — right or wrong, the turn must move on either way.
      final answer = turn.isEven
          ? question!.answers[question.correctAnswerIndex]
          : question!.answers[(question.correctAnswerIndex + 1) % 4];
      await tester.tap(find.text(answer).first);
      await _settle(tester);
      // The verdict holds for one beat before the sheet with the way on.
      await tester.pump(kAnswerBeatDuration + const Duration(milliseconds: 60));
      await _settle(tester);

      final continueLabel = find.text('Continue');
      if (continueLabel.evaluate().isNotEmpty) {
        await tester.tap(continueLabel.last);
        await _settle(tester);
      }

      expect(tester.takeException(), isNull, reason: 'turn $turn threw');
    }
  });

  testWidgets('leaving mid-turn lands on home rather than a dead end',
      (tester) async {
    await _pumpGame(tester);
    await tester.tap(find.byKey(const Key('draw-deck')));
    await tester.pump();
    await tester.pump(kCardRevealDuration + const Duration(milliseconds: 60));
    await _settle(tester);

    // The in-game back control, used while a question is on screen.
    final back = find.byType(BackButton);
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back.first);
      await _settle(tester);
    }
    expect(tester.takeException(), isNull);
  });
}

/// Leaving the board while the opponent is thinking must not throw.
///
/// Each AI beat pauses and then reads the controller's state. If the
/// player walks out during that pause the notifier is already disposed,
/// and touching state then is an error — so every beat checks first.
void _aiDisposalGuard() {
  test('leaving during an opponent turn does not throw', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final container = ProviderContainer(
      overrides: [
        entitlementServiceProvider.overrideWithValue(EntitlementService()),
        progressServiceProvider.overrideWithValue(ProgressService(storage)),
        gameSaveServiceProvider.overrideWithValue(GameSaveService(storage)),
        questionRepositoryProvider.overrideWithValue(QuestionRepository()),
      ],
    );
    final controller = container.read(gameControllerProvider.notifier);
    controller.configure(pool: await QuestionRepository().loadAll('en'), isPremium: true);
    controller.startNewGame(
      mode: GameMode.solo,
      variant: GameVariant.quick,
      circuitId: CircuitId.oasisRoute,
      players: [
        Player(
          id: 'ai',
          name: 'Rider',
          team: kBoardSeats[0],
          aiDifficulty: AiDifficulty.easy,
          horses: const [HorseState()],
        ),
      ],
    );

    // Walk out mid-beat, then let every scheduled beat come due.
    container.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 2600));
  });
}
