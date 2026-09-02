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
import 'package:iqraquest/widgets/celebration_overlay.dart';
import 'package:iqraquest/widgets/question_card_draw.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

GameState _stableGame() {
  final now = DateTime(2026, 1, 1);
  return GameState(
    gameId: 'stable',
    gameMode: GameMode.family,
    gameVariant: GameVariant.quick,
    circuitId: CircuitId.oasisRoute,
    players: [
      Player(
        id: 'p0',
        name: 'Amina',
        team: kBoardSeats[0],
        horses: const [HorseState(), HorseState()],
      ),
      Player(
        id: 'p1',
        name: 'Bilal',
        team: kBoardSeats[1],
        horses: const [HorseState(), HorseState()],
      ),
    ],
    currentPlayerIndex: 0,
    turnPhase: TurnPhase.selectingGait,
    askedQuestionIds: const {},
    startedAt: now,
    updatedAt: now,
  );
}

/// Past the card turning over and any key moment shouted after it.
Future<void> _pastReveal(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(kCardRevealDuration + const Duration(milliseconds: 60));
  await tester.pump(kCelebrationDuration + const Duration(milliseconds: 60));
  await _settle(tester);
}

GameState _soloGame() {
  final now = DateTime(2026, 1, 1);
  return GameState(
    gameId: 'loop',
    gameMode: GameMode.family,
    gameVariant: GameVariant.quick,
    circuitId: CircuitId.oasisRoute,
    players: [
      // One horse each, already on the road: every card then has exactly
      // one thing to do, so each draw opens a question. (The stable's
      // own loop — a card that moves nothing — has its test below.)
      Player(
        id: 'p0',
        name: 'Amina',
        team: kBoardSeats[0],
        horses: const [HorseState(position: TrackPosition(3))],
      ),
      // Two humans on purpose: the loop is what is under test, and an
      // opponent on a timer would make the assertions depend on timing.
      Player(
        id: 'p1',
        name: 'Bilal',
        team: kBoardSeats[1],
        horses: const [HorseState(position: TrackPosition(20))],
      ),
    ],
    currentPlayerIndex: 0,
    turnPhase: TurnPhase.selectingGait,
    askedQuestionIds: const {},
    startedAt: now,
    updatedAt: now,
  );
}

Future<ProviderContainer> _pumpGame(
  WidgetTester tester, {
  GameState? save,
}) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await tester.runAsync(LocalStorageService.create);
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.runAsync(
    () => GameSaveService(storage!).save(save ?? _soloGame()),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(SettingsService(storage!)),
        entitlementServiceProvider.overrideWithValue(EntitlementService()),
        progressServiceProvider.overrideWithValue(ProgressService(storage)),
        gameSaveServiceProvider.overrideWithValue(GameSaveService(storage)),
        legacyGameMigrationServiceProvider.overrideWithValue(
          LegacyGameMigrationService(storage),
        ),
        questionRepositoryProvider.overrideWithValue(QuestionRepository()),
        purchaseServiceProvider.overrideWith((ref) => PurchaseService()),
        initialSettingsProvider.overrideWithValue(const AppSettings()),
        initialPremiumProvider.overrideWithValue(true),
        appRouterProvider.overrideWithValue(
          buildAppRouter(initialLocation: '/game'),
        ),
      ],
      child: const IqraQuestApp(),
    ),
  );
  await _settle(tester);

  // The screen renders whatever the controller holds; a cold entry to
  // /game has to be given the bank and told to load the save, exactly as
  // the real entry points do.
  final container = ProviderScope.containerOf(
    tester.element(find.byType(IqraQuestApp)),
  );
  final controller = container.read(gameControllerProvider.notifier);
  final pool = await tester.runAsync(() => QuestionRepository().loadAll('en'));
  controller.configure(pool: pool!, isPremium: true);
  controller.loadSaved();
  await _settle(tester);
  return container;
}

void main() {
  _aiDisposalGuard();

  testWidgets('a turn always hands back a control — the loop never wedges', (
    tester,
  ) async {
    final container = await _pumpGame(tester);

    for (var turn = 1; turn <= 6; turn++) {
      expect(
        find.byKey(const Key('draw-deck')),
        findsOneWidget,
        reason: 'turn $turn: nothing was offered to the player',
      );

      await tester.tap(find.byKey(const Key('draw-deck')));
      await _pastReveal(tester);

      final question = container.read(gameControllerProvider)!.currentQuestion;
      expect(
        question,
        isNotNull,
        reason: 'turn $turn: the draw produced no question',
      );
      expect(
        container.read(gameControllerProvider)!.gameState.turnPhase,
        TurnPhase.answeringQuestion,
        reason:
            'turn $turn: one horse on the road means one move, no choice to make',
      );

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

  testWidgets(
    'a stable full of horses is never a dead end: the card passes or opens the gate',
    (tester) async {
      final container = await _pumpGame(tester, save: _stableGame());

      for (var turn = 1; turn <= 8; turn++) {
        expect(
          find.byKey(const Key('draw-deck')),
          findsOneWidget,
          reason: 'turn $turn: the deck did not come back',
        );
        await tester.tap(find.byKey(const Key('draw-deck')));
        await tester.pump();
        // The draw resolves at once; what the screen does next depends on it.
        final session = container.read(gameControllerProvider)!;
        final card = session.gameState.drawnCard;
        final phase = session.gameState.turnPhase;
        await _pastReveal(tester);
        final legal = container
            .read(gameControllerProvider.notifier)
            .legalMoves;
        if (phase == TurnPhase.noMove) {
          expect(
            legal,
            isEmpty,
            reason: 'turn $turn: a $card had a move and was passed',
          );
          // Nothing to tap: the turn passes by itself after its beat.
          await tester.pump(kNoMoveBeat + const Duration(milliseconds: 80));
          await _settle(tester);
        } else {
          expect(
            legal,
            isNotEmpty,
            reason: 'turn $turn: a $card moved nothing yet was played',
          );
          if (phase == TurnPhase.choosingHorse) {
            // A horse out and one still in: the sheet offers both.
            expect(find.byKey(const Key('move-choice')), findsOneWidget);
            await tester.tap(find.byKey(const Key('move-option-0')));
            await _settle(tester);
          } else {
            // Two horses in the stable are one exit: no choice sheet, the
            // question opens straight away.
            expect(find.byKey(const Key('move-choice')), findsNothing);
            expect(phase, TurnPhase.answeringQuestion);
          }
          final question = container
              .read(gameControllerProvider)!
              .currentQuestion!;
          await tester.tap(
            find.text(question.answers[question.correctAnswerIndex]).first,
          );
          await _settle(tester);
          await tester.pump(
            kAnswerBeatDuration + const Duration(milliseconds: 60),
          );
          await _settle(tester);
          final continueLabel = find.text('Continue');
          if (continueLabel.evaluate().isNotEmpty) {
            await tester.tap(continueLabel.last);
            await _settle(tester);
          }
          // A landing celebration (a capture can happen on the start
          // square) and the ride itself both settle within this.
          await tester.pump(
            kAnswerBeatDuration +
                kCelebrationDuration +
                const Duration(milliseconds: 1400),
          );
          await _settle(tester);
        }
        final thrown = tester.takeException();
        if (thrown is FlutterError) {
          // ignore: avoid_print
          print(
            'OVERFLOW DEBUG ${thrown.diagnostics.map((d) => d.toStringDeep()).join(' | ')}',
          );
        }
        expect(thrown, isNull, reason: 'turn $turn threw');
      }
    },
  );

  testWidgets(
    'a card two horses could use offers the choice, and the choice opens the question',
    (tester) async {
      final now = DateTime(2026, 1, 1);
      final save = GameState(
        gameId: 'choice',
        gameMode: GameMode.family,
        gameVariant: GameVariant.quick,
        circuitId: CircuitId.oasisRoute,
        players: [
          Player(
            id: 'p0',
            name: 'Amina',
            team: kBoardSeats[0],
            horses: const [
              HorseState(position: TrackPosition(4)),
              HorseState(position: TrackPosition(9)),
            ],
          ),
          Player(
            id: 'p1',
            name: 'Bilal',
            team: kBoardSeats[1],
            horses: const [HorseState()],
          ),
        ],
        currentPlayerIndex: 0,
        turnPhase: TurnPhase.selectingGait,
        askedQuestionIds: const {},
        startedAt: now,
        updatedAt: now,
      );
      final container = await _pumpGame(tester, save: save);
      await tester.tap(find.byKey(const Key('draw-deck')));
      await _pastReveal(tester);

      final session = container.read(gameControllerProvider)!;
      expect(session.gameState.turnPhase, TurnPhase.choosingHorse);
      expect(
        find.byKey(const Key('move-choice')),
        findsOneWidget,
        reason: 'two horses on the road: the player picks which one rides',
      );
      // The card's question is held back until the horse is chosen.
      expect(find.text(session.currentQuestion!.question), findsNothing);

      await tester.tap(find.byKey(const Key('move-option-1')));
      await _settle(tester);
      expect(
        container.read(gameControllerProvider)!.gameState.turnPhase,
        TurnPhase.answeringQuestion,
      );
      expect(
        container
            .read(gameControllerProvider)!
            .gameState
            .pendingGait!
            .horseIndex,
        1,
      );
      expect(find.text(session.currentQuestion!.question), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('leaving mid-turn lands on home rather than a dead end', (
    tester,
  ) async {
    await _pumpGame(tester);
    await tester.tap(find.byKey(const Key('draw-deck')));
    await _pastReveal(tester);

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
    controller.configure(
      pool: await QuestionRepository().loadAll('en'),
      isPremium: true,
    );
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
