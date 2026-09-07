import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:iqraquest/app/app.dart';
import 'package:iqraquest/app/providers.dart';
import 'package:iqraquest/app/router.dart';
import 'package:iqraquest/features/game/application/game_controller.dart';
import 'package:iqraquest/l10n/generated/app_localizations_en.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

/// Every way into a game and every way out of one, walked in both
/// directions: the hub routes, the setup flow and its back buttons, the
/// board's own exits, the results, the cold entries — and the shelf of
/// named saves, which is one more way onto the board.
final en = AppLocalizationsEn();

Future<GoRouter> pumpApp(
  WidgetTester tester,
  LocalStorageService storage, {
  String initialLocation = '/home',
  // Premium by default: the named saves, two of the three courses and
  // the mixed level are Premium, and most of these walks go through
  // them. The free edition has its own test below.
  bool premium = true,
}) async {
  // A phone, so the board menu fits its sheet and a tap reaches every row.
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = buildAppRouter(initialLocation: initialLocation);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(SettingsService(storage)),
        entitlementServiceProvider.overrideWithValue(_MemoryEntitlements()),
        progressServiceProvider.overrideWithValue(ProgressService(storage)),
        gameSaveServiceProvider.overrideWithValue(GameSaveService(storage)),
        legacyGameMigrationServiceProvider.overrideWithValue(
          LegacyGameMigrationService(storage),
        ),
        questionRepositoryProvider.overrideWithValue(QuestionRepository()),
        // Lazily: constructing the store client reaches for the billing
        // channel, which no test has, and the error would land in
        // whichever test happens to be running.
        purchaseServiceProvider.overrideWith((ref) => PurchaseService()),
        initialSettingsProvider.overrideWithValue(const AppSettings()),
        initialPremiumProvider.overrideWithValue(premium),
        appRouterProvider.overrideWithValue(router),
      ],
      child: const IqraQuestApp(),
    ),
  );
  await settle(tester);
  return router;
}

/// Not pumpAndSettle: some screens keep idle animations running forever.
/// Long enough for a page transition to finish (800 ms on Android), so
/// a screen left behind is offstage by the time it is looked for.
Future<void> settle(WidgetTester tester, [int frames = 10]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The entitlement in memory. The real one writes to secure storage,
/// whose channel answers nothing under a widget test: a grant fired
/// there never lands, and "the tester switch opens everything" could
/// never be walked. Everything else about the flow is the real thing.
class _MemoryEntitlements implements EntitlementService {
  bool _premium = false;

  @override
  Future<bool> isPremium() async => _premium;

  @override
  Future<void> grantPremium() async => _premium = true;

  @override
  Future<void> revokePremium() async => _premium = false;
}

/// The phone's own back: the gesture or the button the app never draws.
Future<void> systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await settle(tester);
}

/// Real asset I/O (the question bank) sits behind [action]: interleave
/// real waits with frames until [until] shows up.
Future<void> runUntil(
  WidgetTester tester,
  Future<void> Function() action,
  Finder until,
) async {
  await tester.runAsync(() async {
    await action();
    for (var i = 0; i < 60; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();
      if (until.evaluate().isNotEmpty) break;
    }
  });
  await settle(tester);
}

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(IqraQuestApp)));

List<Player> riders([List<String> names = const ['Amina', 'Yusuf']]) => [
  for (var i = 0; i < names.length; i++)
    Player(
      id: 'human_$i',
      name: names[i],
      team: kBoardSeats[i],
      horses: const [HorseState(), HorseState(), HorseState(), HorseState()],
    ),
];

/// Puts a two-rider game on the board the way the riders' screen does,
/// without the screens: the exits are what these tests are about.
Future<void> putGameOnBoard(WidgetTester tester, GoRouter router) async {
  final container = containerOf(tester);
  // A screen visited earlier may have started an asset load inside the
  // test's fake-async zone — the Premium screen counts the bank — and
  // such a load never completes: it is cached as a pending future that
  // would hang the real load below for ever. Dropping the cache and
  // reading the bank directly keeps this helper independent of whatever
  // the walk went through before it.
  rootBundle.clear();
  final pool = await tester.runAsync(() => QuestionRepository().loadAll('en'));
  final controller = container.read(gameControllerProvider.notifier);
  controller.configure(pool: pool!, isPremium: false);
  controller.startNewGame(
    mode: GameMode.family,
    variant: GameVariant.classic,
    circuitId: CircuitId.oasisRoute,
    players: riders(),
  );
  router.go('/game');
  await settle(tester);
  expect(board, findsOneWidget, reason: 'the board opens');
}

/// A game to put on the shelf directly, as an earlier evening left it.
GameState keptGame({String id = 'kept'}) {
  final now = DateTime(2026, 9, 1, 20, 15);
  return GameState(
    gameId: id,
    gameMode: GameMode.family,
    gameVariant: GameVariant.duo,
    circuitId: CircuitId.caravanTrail,
    players: [
      for (final p in riders(const ['Papa', 'Sara']))
        p.copyWith(horses: const [HorseState(), HorseState()]),
    ],
    currentPlayerIndex: 0,
    turnPhase: TurnPhase.selectingGait,
    askedQuestionIds: const {},
    startedAt: now,
    updatedAt: now,
  );
}

String currentGameId(WidgetTester tester) =>
    containerOf(tester).read(gameControllerProvider)!.gameState.gameId;

final board = find.text(en.drawCard);
final home = find.text(en.appTagline);
final setup = find.text(en.newGameTitle);
final ridersScreen = find.text(en.startGame);

Finder cancelButton(WidgetTester tester) => find.widgetWithText(
  TextButton,
  MaterialLocalizations.of(
    tester.element(find.byType(AlertDialog)),
  ).cancelButtonLabel,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Asset loads started under one test's fake-async zone stay cached
    // as forever-pending futures and would hang the next test's loads.
    rootBundle.clear();
  });

  testWidgets(
    'the home shelf opens daily challenge and progress, and back returns home',
    (tester) async {
      final storage = await LocalStorageService.create();
      await pumpApp(tester, storage);

      await tester.tap(find.text(en.dailyChallenge));
      await settle(tester);
      expect(find.text(en.dailyChallenge), findsWidgets);

      await tester.pageBack();
      await settle(tester);
      expect(home, findsOneWidget, reason: 'back lands on home');

      await tester.tap(find.text(en.progress));
      await settle(tester);
      expect(find.text(en.progress), findsWidgets);

      await tester.pageBack();
      await settle(tester);
      expect(home, findsOneWidget);
    },
  );

  testWidgets('settings, premium and tutorial routes all open and render', (
    tester,
  ) async {
    final storage = await LocalStorageService.create();
    final router = await pumpApp(tester, storage);

    router.push('/settings');
    await settle(tester);
    expect(find.text(en.soundEffects), findsOneWidget);
    expect(find.text(en.reduceMotion), findsOneWidget);

    router.push('/premium');
    await settle(tester);
    // The price must come from the store, never be hardcoded: the screen
    // renders without any purchase backend in tests.
    expect(tester.takeException(), isNull);

    router.push('/tutorial');
    await settle(tester);
    expect(tester.takeException(), isNull);

    router.go('/home');
    await settle(tester);
    expect(home, findsOneWidget);
  });

  testWidgets('toggling the sound setting persists it', (tester) async {
    final storage = await LocalStorageService.create();
    final router = await pumpApp(tester, storage);

    router.push('/settings');
    await settle(tester);

    final tile = find.widgetWithText(SwitchListTile, en.soundEffects);
    expect(tester.widget<SwitchListTile>(tile).value, isTrue);
    await tester.tap(tile);
    await settle(tester);
    expect(tester.widget<SwitchListTile>(tile).value, isFalse);
    expect(
      SettingsService(storage).load().soundEnabled,
      isFalse,
      reason: 'the choice survives an app restart',
    );
  });

  testWidgets('solo flow reaches the board and leaving preserves the save', (
    tester,
  ) async {
    final storage = await LocalStorageService.create();
    final router = await pumpApp(tester, storage);

    await tester.tap(find.text(en.soloMode).first);
    await settle(tester);
    expect(setup, findsOneWidget, reason: 'mode selection opens');

    // The Continue CTA is pinned under the form, so it needs no scroll.
    await tester.tap(find.byType(ElevatedButton));
    await settle(tester);
    expect(ridersScreen, findsOneWidget, reason: 'player setup opens');

    // Starting a game loads the question bank from the asset bundle:
    // real async I/O, so interleave real waits with frame pumps until
    // the board appears.
    await runUntil(tester, () => tester.tap(ridersScreen), board);
    expect(board, findsOneWidget, reason: 'the game board opens');

    // A game in progress is saved from its very first phase.
    expect(GameSaveService(storage).load(), isNotNull);

    router.go('/home');
    await settle(tester);
    expect(
      find.text(en.continueGame.toUpperCase()),
      findsOneWidget,
      reason: 'home offers to resume the journey left behind',
    );
  });

  // ---- The audit: every link in and out, both directions ----------------

  testWidgets('the home shelf lights Solo, the default door', (tester) async {
    final storage = await LocalStorageService.create();
    await pumpApp(tester, storage);

    RoundedRectangleBorder shapeOf(String key) => tester
            .widget<Material>(
              find
                  .descendant(
                    of: find.byKey(Key(key)),
                    matching: find.byType(Material),
                  )
                  .first,
            )
            .shape!
        as RoundedRectangleBorder;

    expect(
      shapeOf('shelf-solo').side.color,
      const Color(0xFFE3B354),
      reason: 'Solo is rimmed in gold',
    );
    expect(shapeOf('shelf-solo').side.width, greaterThan(1));
    expect(
      shapeOf('shelf-family').side,
      BorderSide.none,
      reason: 'the other doors stay quiet',
    );
  });

  testWidgets(
    'setup: Family preselects two riders, and both backs return home',
    (tester) async {
      final storage = await LocalStorageService.create();
      await pumpApp(tester, storage);
      final semantics = tester.ensureSemantics();

      await tester.tap(find.byKey(const Key('shelf-family')));
      await settle(tester);
      expect(setup, findsOneWidget);
      expect(
        tester.getSemantics(find.byKey(const Key('players-2'))),
        isSemantics(isSelected: true),
        reason: 'Family means two riders until the table says otherwise',
      );

      await tester.pageBack();
      await settle(tester);
      expect(home, findsOneWidget, reason: 'the app bar back returns home');

      await tester.tap(find.byKey(const Key('shelf-solo')));
      await settle(tester);
      expect(setup, findsOneWidget);
      expect(
        tester.getSemantics(find.byKey(const Key('players-1'))),
        isSemantics(isSelected: true),
      );

      await systemBack(tester);
      expect(home, findsOneWidget, reason: 'the phone back returns home');
      semantics.dispose();
    },
  );

  testWidgets('riders: back keeps the setup choices, then home', (
    tester,
  ) async {
    final storage = await LocalStorageService.create();
    await pumpApp(tester, storage);
    final semantics = tester.ensureSemantics();

    await tester.tap(find.byKey(const Key('shelf-solo')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('format-quick')));
    await settle(tester);
    await tester.tap(find.byType(ElevatedButton));
    await settle(tester);
    expect(ridersScreen, findsOneWidget);

    // The riders' own glass back button.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await settle(tester);
    expect(setup, findsOneWidget, reason: 'back returns to the setup');
    expect(
      tester.getSemantics(find.byKey(const ValueKey('format-quick'))),
      isSemantics(isSelected: true),
      reason: 'the choices made are still made',
    );

    await tester.tap(find.byType(ElevatedButton));
    await settle(tester);
    await systemBack(tester);
    expect(setup, findsOneWidget, reason: 'the phone back does the same');

    await systemBack(tester);
    expect(home, findsOneWidget);
    semantics.dispose();
  });

  testWidgets(
    'board: the back button, the phone back and the menu all lead home '
    'and keep the game to continue',
    (tester) async {
      final storage = await LocalStorageService.create();
      final router = await pumpApp(tester, storage);
      await putGameOnBoard(tester, router);
      final gameId = currentGameId(tester);
      final continueCta = find.text(en.continueGame.toUpperCase());

      await tester.tap(find.byKey(const Key('board-back')));
      await settle(tester);
      expect(home, findsOneWidget);
      expect(continueCta, findsOneWidget, reason: 'the game waits on home');

      await runUntil(tester, () => tester.tap(continueCta), board);
      expect(board, findsOneWidget, reason: 'Continue rejoins the board');
      expect(currentGameId(tester), gameId, reason: 'the same game');

      await systemBack(tester);
      expect(home, findsOneWidget, reason: 'the phone back leaves the board');
      expect(continueCta, findsOneWidget);

      await runUntil(tester, () => tester.tap(continueCta), board);
      await tester.tap(find.byKey(const Key('board-menu')));
      await settle(tester);
      await tester.ensureVisible(find.byKey(const Key('menu-home')));
      await tester.tap(find.byKey(const Key('menu-home')));
      await settle(tester);
      expect(home, findsOneWidget, reason: 'the menu leaves the board');
      expect(continueCta, findsOneWidget);
      expect(GameSaveService(storage).load()!.gameId, gameId);
    },
  );

  testWidgets('board: the rules open over the game and come back to it', (
    tester,
  ) async {
    final storage = await LocalStorageService.create();
    final router = await pumpApp(tester, storage);
    await putGameOnBoard(tester, router);

    await tester.tap(find.byKey(const Key('rules-shortcut')));
    await settle(tester);
    expect(find.text(en.rulesTitle), findsWidgets, reason: 'the rules open');
    // The rules quote "Draw a card" themselves: the board's own controls
    // are what must be gone.
    expect(
      find.byKey(const Key('board-menu')),
      findsNothing,
      reason: 'over the board, not beside it',
    );

    await tester.pageBack();
    await settle(tester);
    expect(board, findsOneWidget, reason: 'back is the board again');

    await tester.tap(find.byKey(const Key('board-menu')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('menu-rules')));
    await settle(tester);
    expect(find.text(en.rulesTitle), findsWidgets);
    await systemBack(tester);
    expect(board, findsOneWidget, reason: 'the phone back closes the rules');
  });

  testWidgets('board: restart asks once and deals a fresh race', (
    tester,
  ) async {
    final storage = await LocalStorageService.create();
    final router = await pumpApp(tester, storage);
    await putGameOnBoard(tester, router);
    final before = currentGameId(tester);

    await tester.tap(find.byKey(const Key('board-menu')));
    await settle(tester);
    await tester.ensureVisible(find.byKey(const Key('menu-restart')));
    await tester.tap(find.byKey(const Key('menu-restart')));
    await settle(tester);
    expect(find.text(en.restartRaceConfirm), findsOneWidget);

    await tester.tap(cancelButton(tester));
    await settle(tester);
    expect(currentGameId(tester), before, reason: 'cancel changes nothing');

    await tester.tap(find.byKey(const Key('menu-restart')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('menu-restart-confirm')));
    await settle(tester);
    expect(board, findsOneWidget, reason: 'the table stays on the board');
    expect(currentGameId(tester), isNot(before), reason: 'a new race');
    expect(GameSaveService(storage).load()!.gameId, currentGameId(tester));
  });

  testWidgets(
    'results: race again returns to the board; home and the phone back go home',
    (tester) async {
      final storage = await LocalStorageService.create();
      final router = await pumpApp(tester, storage);
      await putGameOnBoard(tester, router);
      final before = currentGameId(tester);

      router.go('/results');
      await settle(tester);
      await tester.tap(find.byKey(const Key('race-again')));
      await settle(tester);
      expect(board, findsOneWidget, reason: 'again! is one tap');
      expect(currentGameId(tester), isNot(before));

      router.go('/results');
      await settle(tester);
      await tester.tap(find.text(en.backToHome));
      await settle(tester);
      expect(home, findsOneWidget);

      router.go('/results');
      await settle(tester);
      await systemBack(tester);
      expect(home, findsOneWidget, reason: 'the results never trap the back');
    },
  );

  testWidgets(
    'cold entries: the board without a game and the riders without a '
    'setup both offer the way home',
    (tester) async {
      final storage = await LocalStorageService.create();
      final router = await pumpApp(tester, storage, initialLocation: '/game');
      expect(board, findsNothing);
      await tester.tap(find.text(en.backToHome));
      await settle(tester);
      expect(home, findsOneWidget);

      router.go('/player-setup');
      await settle(tester);
      expect(setup, findsOneWidget, reason: 'sent back to the start');
      expect(ridersScreen, findsNothing);
      await tester.tap(find.byKey(const Key('setup-home')));
      await settle(tester);
      expect(home, findsOneWidget, reason: 'and never stranded there');
    },
  );

  testWidgets('settings open the rules and come back, then home', (
    tester,
  ) async {
    final storage = await LocalStorageService.create();
    final router = await pumpApp(tester, storage);

    router.push('/settings');
    await settle(tester);
    await tester.ensureVisible(find.text(en.howToPlay));
    await tester.tap(find.text(en.howToPlay));
    await settle(tester);
    expect(find.text(en.rulesTitle), findsWidgets);

    await tester.pageBack();
    await settle(tester);
    expect(find.text(en.soundEffects), findsOneWidget);
    await tester.pageBack();
    await settle(tester);
    expect(home, findsOneWidget);
  });

  // ---- Named saves: one more way onto the board -------------------------

  testWidgets(
    'save from the board menu: the riders name it, saving again replaces',
    (tester) async {
      final storage = await LocalStorageService.create();
      final router = await pumpApp(tester, storage);
      await putGameOnBoard(tester, router);
      final shelf = GameSaveService(storage).named;

      await tester.tap(find.byKey(const Key('board-menu')));
      await settle(tester);
      await tester.ensureVisible(find.byKey(const Key('menu-save')));
      await tester.tap(find.byKey(const Key('menu-save')));
      await settle(tester);
      expect(find.byKey(const Key('save-game-name')), findsOneWidget);
      expect(
        find.text('Amina, Yusuf'),
        findsOneWidget,
        reason: 'the riders are the proposed name',
      );

      await tester.tap(find.byKey(const Key('save-game-confirm')));
      await settle(tester);
      expect(find.text(en.gameSavedAs('Amina, Yusuf')), findsOneWidget);
      expect(board, findsOneWidget, reason: 'saving does not leave the game');
      expect(shelf.list().map((s) => s.name), ['Amina, Yusuf']);
      expect(shelf.list().single.gameId, currentGameId(tester));

      // Kept again: the same game under the same name is one row.
      await tester.tap(find.byKey(const Key('board-menu')));
      await settle(tester);
      await tester.ensureVisible(find.byKey(const Key('menu-save')));
      await tester.tap(find.byKey(const Key('menu-save')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('save-game-confirm')));
      await settle(tester);
      expect(shelf.list(), hasLength(1));
    },
  );

  testWidgets(
    'load from the setup: an empty shelf explains, a kept game takes the board',
    (tester) async {
      final storage = await LocalStorageService.create();
      await pumpApp(tester, storage);
      final shelf = GameSaveService(storage).named;

      await tester.tap(find.byKey(const Key('shelf-solo')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('load-game')));
      await settle(tester);
      expect(find.byKey(const Key('no-saved-games')), findsOneWidget);
      // The hint draws the menu glyph as an icon, so its text is in two
      // spans around it.
      expect(
        find.textContaining(en.noSavedGamesHint.split('≡').last),
        findsOneWidget,
      );
      await tester.tapAt(const Offset(20, 20)); // the barrier
      await settle(tester);
      expect(setup, findsOneWidget, reason: 'dismissed, still setting up');

      final kept = (await shelf.save(keptGame(), name: 'Soirée'))!;
      await tester.tap(find.byKey(const Key('load-game')));
      await settle(tester);
      final row = find.byKey(Key('save-${kept.id}'));
      expect(row, findsOneWidget);
      expect(find.text('Soirée'), findsOneWidget);
      expect(find.textContaining('Papa, Sara'), findsOneWidget);

      await runUntil(tester, () => tester.tap(row), board);
      expect(board, findsOneWidget, reason: 'the kept game is on the board');
      expect(currentGameId(tester), 'kept');
      expect(
        GameSaveService(storage).load()!.gameId,
        'kept',
        reason: 'and it is now the game home continues',
      );
    },
  );

  testWidgets(
    'a game in progress is not replaced in silence: Start asks, and '
    'keeping it puts it on the shelf',
    (tester) async {
      final storage = await LocalStorageService.create();
      final router = await pumpApp(tester, storage);
      await putGameOnBoard(tester, router);
      final inProgress = currentGameId(tester);
      final shelf = GameSaveService(storage).named;

      router.go('/home');
      await settle(tester);
      await tester.tap(find.byKey(const Key('shelf-solo')));
      await settle(tester);
      await tester.tap(find.byType(ElevatedButton));
      await settle(tester);
      await tester.tap(ridersScreen);
      await settle(tester);
      expect(find.text(en.gameInProgressTitle), findsOneWidget);

      await tester.tap(cancelButton(tester));
      await settle(tester);
      expect(ridersScreen, findsOneWidget, reason: 'cancel: nothing happened');
      expect(GameSaveService(storage).load()!.gameId, inProgress);

      await tester.tap(ridersScreen);
      await settle(tester);
      await tester.tap(find.byKey(const Key('keep-game')));
      await settle(tester);
      expect(find.byKey(const Key('save-game-name')), findsOneWidget);
      await runUntil(
        tester,
        () => tester.tap(find.byKey(const Key('save-game-confirm'))),
        board,
      );
      expect(board, findsOneWidget, reason: 'the new race starts');
      expect(currentGameId(tester), isNot(inProgress));
      expect(shelf.list().single.gameId, inProgress, reason: 'kept');
      expect(shelf.list().single.name, 'Amina, Yusuf');
    },
  );

  testWidgets('a game in progress can be replaced without keeping it', (
    tester,
  ) async {
    final storage = await LocalStorageService.create();
    final router = await pumpApp(tester, storage);
    await putGameOnBoard(tester, router);
    final inProgress = currentGameId(tester);

    router.go('/home');
    await settle(tester);
    await tester.tap(find.byKey(const Key('shelf-family')));
    await settle(tester);
    await tester.tap(find.byType(ElevatedButton));
    await settle(tester);
    await tester.tap(ridersScreen);
    await settle(tester);
    await runUntil(
      tester,
      () => tester.tap(find.byKey(const Key('replace-game'))),
      board,
    );
    expect(board, findsOneWidget);
    expect(currentGameId(tester), isNot(inProgress));
    expect(GameSaveService(storage).named.list(), isEmpty);
  });

  testWidgets(
    'a kept game asks nothing on the way out, and loading over another asks too',
    (tester) async {
      final storage = await LocalStorageService.create();
      final router = await pumpApp(tester, storage);
      final shelf = GameSaveService(storage).named;
      final kept = (await shelf.save(keptGame(), name: 'Soirée'))!;

      await putGameOnBoard(tester, router);
      final inProgress = currentGameId(tester);
      router.go('/home');
      await settle(tester);
      await tester.tap(find.byKey(const Key('shelf-solo')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('load-game')));
      await settle(tester);
      await tester.tap(find.byKey(Key('save-${kept.id}')));
      await settle(tester);
      expect(
        find.text(en.gameInProgressTitle),
        findsOneWidget,
        reason: 'loading replaces the game in progress: it is asked',
      );
      await runUntil(
        tester,
        () => tester.tap(find.byKey(const Key('replace-game'))),
        board,
      );
      expect(currentGameId(tester), 'kept');
      expect(currentGameId(tester), isNot(inProgress));

      // The loaded game is on the shelf exactly as it stands: starting
      // another asks nothing.
      router.go('/home');
      await settle(tester);
      await tester.tap(find.byKey(const Key('shelf-solo')));
      await settle(tester);
      await tester.tap(find.byType(ElevatedButton));
      await settle(tester);
      await runUntil(tester, () => tester.tap(ridersScreen), board);
      expect(find.text(en.gameInProgressTitle), findsNothing);
      expect(board, findsOneWidget);
      expect(currentGameId(tester), isNot('kept'));
    },
  );

  testWidgets('deleting a save asks, then the shelf is empty again', (
    tester,
  ) async {
    final storage = await LocalStorageService.create();
    await pumpApp(tester, storage);
    final shelf = GameSaveService(storage).named;
    final kept = (await shelf.save(keptGame(), name: 'Soirée'))!;

    await tester.tap(find.byKey(const Key('shelf-solo')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('load-game')));
    await settle(tester);
    await tester.tap(find.byKey(Key('delete-save-${kept.id}')));
    await settle(tester);
    expect(find.text(en.deleteSaveConfirm('Soirée')), findsOneWidget);

    await tester.tap(cancelButton(tester));
    await settle(tester);
    expect(find.byKey(Key('save-${kept.id}')), findsOneWidget);

    await tester.tap(find.byKey(Key('delete-save-${kept.id}')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('delete-save-confirm')));
    await settle(tester);
    expect(find.byKey(const Key('no-saved-games')), findsOneWidget);
    expect(shelf.list(), isEmpty);
    expect(find.text(en.loadGame), findsOneWidget, reason: 'the sheet stays');
  });

  // ---- Premium: locked on a free device, sold from every locked place --

  final premiumScreen = find.text(en.premiumTitle);

  testWidgets(
    'free edition: the courses, the mixed level, the saves and Load are '
    'locked and every one of them opens the Premium screen',
    (tester) async {
      final storage = await LocalStorageService.create();
      final router = await pumpApp(tester, storage, premium: false);

      // The banner under the journey card.
      expect(find.byKey(const Key('premium-banner')), findsOneWidget);
      await tester.tap(find.byKey(const Key('premium-banner')));
      await settle(tester);
      expect(premiumScreen, findsOneWidget);
      await tester.pageBack();
      await settle(tester);

      // The two eventful courses.
      await tester.tap(find.byKey(const Key('shelf-solo')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('circuit-caravanTrail')));
      await settle(tester);
      expect(premiumScreen, findsOneWidget, reason: 'a locked course sells');
      await tester.pageBack();
      await settle(tester);
      await tester.tap(find.byKey(const Key('circuit-greatRide')));
      await settle(tester);
      expect(premiumScreen, findsOneWidget);
      await tester.pageBack();
      await settle(tester);

      // Load.
      await tester.tap(find.byKey(const Key('load-game')));
      await settle(tester);
      expect(premiumScreen, findsOneWidget, reason: 'Load sells');
      expect(find.byKey(const Key('no-saved-games')), findsNothing);
      await tester.pageBack();
      await settle(tester);

      // The mixed level on the riders' screen.
      await tester.tap(find.byType(ElevatedButton));
      await settle(tester);
      await tester.tap(find.byKey(const Key('level-mixed')));
      await settle(tester);
      expect(premiumScreen, findsOneWidget, reason: 'the mixed level sells');
      await tester.pageBack();
      await settle(tester);
      expect(
        find.byKey(const Key('level-mixed-hint')),
        findsNothing,
        reason: 'the level was not chosen',
      );

      // The save button on the board, and the menu's entry.
      await putGameOnBoard(tester, router);
      await tester.tap(find.byKey(const Key('board-save')));
      await settle(tester);
      expect(premiumScreen, findsOneWidget, reason: 'the HUD save sells');
      await tester.pageBack();
      await settle(tester);
      expect(board, findsOneWidget);
      await tester.tap(find.byKey(const Key('board-menu')));
      await settle(tester);
      await tester.ensureVisible(find.byKey(const Key('menu-save')));
      await tester.tap(find.byKey(const Key('menu-save')));
      await settle(tester);
      expect(premiumScreen, findsOneWidget, reason: 'the menu save sells');
      expect(GameSaveService(storage).named.list(), isEmpty);

      // And the settings row.
      router.go('/settings');
      await settle(tester);
      expect(find.byKey(const Key('settings-premium')), findsOneWidget);
      expect(find.text(en.premiumBannerTitle), findsOneWidget);
    },
  );

  testWidgets('the tester unlock opens everything at once', (tester) async {
    final storage = await LocalStorageService.create();
    await pumpApp(tester, storage, premium: false);
    final semantics = tester.ensureSemantics();

    // Exactly what the tester switch does: grant the entitlement while
    // the app is running, and every locked thing must open at once.
    await containerOf(tester).read(premiumControllerProvider.notifier).grant();
    await settle(tester);
    expect(find.byKey(const Key('premium-banner')), findsNothing);

    await tester.tap(find.byKey(const Key('shelf-solo')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('circuit-caravanTrail')));
    await settle(tester);
    expect(premiumScreen, findsNothing);
    expect(
      tester.getSemantics(find.byKey(const Key('circuit-caravanTrail'))),
      isSemantics(isSelected: true),
    );
    await tester.tap(find.byKey(const Key('load-game')));
    await settle(tester);
    expect(find.byKey(const Key('no-saved-games')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets(
    'a free race stopped by the draw limit: the popup offers Premium once',
    (tester) async {
      final storage = await LocalStorageService.create();
      final router = await pumpApp(tester, storage, premium: false);
      await putGameOnBoard(tester, router);
      final controller = containerOf(tester).read(gameControllerProvider.notifier);
      final over = controller.state!.gameState.copyWith(
        turnPhase: TurnPhase.gameOver,
        endedByDrawLimit: true,
        drawCount: GameState.freeDrawLimit,
      );
      // ignore: invalid_use_of_protected_member
      controller.state = GameSession(gameState: over);

      router.go('/results');
      await settle(tester);
      expect(find.byKey(const Key('free-limit-popup')), findsOneWidget);
      expect(
        find.text(en.freeLimitPopupBody(GameState.freeDrawLimit)),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('free-limit-unlock')));
      await settle(tester);
      expect(premiumScreen, findsOneWidget);
      await tester.pageBack();
      await settle(tester);
      expect(find.byKey(const Key('free-limit-popup')), findsNothing);
      expect(find.byKey(const Key('race-again')), findsOneWidget);
    },
  );
}
