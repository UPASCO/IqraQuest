import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:iqraquest/app/app.dart';
import 'package:iqraquest/app/providers.dart';
import 'package:iqraquest/app/router.dart';
import 'package:iqraquest/l10n/generated/app_localizations_en.dart';
import 'package:iqraquest/services/entitlement_service.dart';
import 'package:iqraquest/services/game_save_service.dart';
import 'package:iqraquest/services/legacy_game_migration_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:iqraquest/services/purchase_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Navigation cases: every hub route opens, the play flow reaches the
/// board, and leaving a game preserves the save behind it.
final en = AppLocalizationsEn();

Future<GoRouter> pumpApp(WidgetTester tester, LocalStorageService storage) async {
  final router = buildAppRouter(initialLocation: '/home');
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(SettingsService(storage)),
        entitlementServiceProvider.overrideWithValue(EntitlementService()),
        progressServiceProvider.overrideWithValue(ProgressService(storage)),
        gameSaveServiceProvider.overrideWithValue(GameSaveService(storage)),
        legacyGameMigrationServiceProvider.overrideWithValue(LegacyGameMigrationService(storage)),
        questionRepositoryProvider.overrideWithValue(QuestionRepository()),
        purchaseServiceProvider.overrideWithValue(PurchaseService()),
        initialSettingsProvider.overrideWithValue(const AppSettings()),
        initialPremiumProvider.overrideWithValue(false),
        appRouterProvider.overrideWithValue(router),
      ],
      child: const IqraQuestApp(),
    ),
  );
  await settle(tester);
  return router;
}

/// Not pumpAndSettle: some screens keep idle animations running forever.
Future<void> settle(WidgetTester tester, [int frames = 8]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Asset loads started under one test's fake-async zone stay cached
    // as forever-pending futures and would hang the next test's loads.
    rootBundle.clear();
  });

  testWidgets('the home shelf opens daily challenge and progress, and back returns home',
      (tester) async {
    final storage = await LocalStorageService.create();
    await pumpApp(tester, storage);

    await tester.tap(find.text(en.dailyChallenge));
    await settle(tester);
    expect(find.text(en.dailyChallenge), findsWidgets);

    await tester.pageBack();
    await settle(tester);
    expect(find.text(en.appTagline), findsOneWidget, reason: 'back lands on home');

    await tester.tap(find.text(en.progress));
    await settle(tester);
    expect(find.text(en.progress), findsWidgets);

    await tester.pageBack();
    await settle(tester);
    expect(find.text(en.appTagline), findsOneWidget);
  });

  testWidgets('settings, premium and tutorial routes all open and render', (tester) async {
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
    expect(find.text(en.appTagline), findsOneWidget);
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
    expect(SettingsService(storage).load().soundEnabled, isFalse,
        reason: 'the choice survives an app restart');
  });

  testWidgets('solo flow reaches the board and leaving preserves the save', (tester) async {
    final storage = await LocalStorageService.create();
    final router = await pumpApp(tester, storage);

    await tester.tap(find.text(en.soloMode).first);
    await settle(tester);
    expect(find.text(en.chooseCircuit), findsOneWidget, reason: 'mode selection opens');

    // The Continue CTA (bottom of the scrolling form) leads into setup.
    await tester.scrollUntilVisible(
      find.byType(ElevatedButton),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byType(ElevatedButton));
    await settle(tester);
    await tester.scrollUntilVisible(
      find.text(en.startGame),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(en.startGame), findsOneWidget, reason: 'player setup opens');

    // Starting a game loads the question bank from the asset bundle:
    // real async I/O, so interleave real waits with frame pumps until
    // the board appears.
    await tester.runAsync(() async {
      await tester.tap(find.text(en.startGame));
      for (var i = 0; i < 40; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
        if (find.text(en.drawCard).evaluate().isNotEmpty) break;
      }
    });
    await settle(tester);
    expect(find.text(en.drawCard), findsOneWidget, reason: 'the game board opens');

    // A game in progress is saved from its very first phase.
    expect(GameSaveService(storage).load(), isNotNull);

    router.go('/home');
    await settle(tester);
    expect(find.text(en.continueGame.toUpperCase()), findsOneWidget,
        reason: 'home offers to resume the journey left behind');
  });
}
