import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/app/app.dart';
import 'package:iqraquest/app/providers.dart';
import 'package:iqraquest/app/router.dart';
import 'package:iqraquest/services/entitlement_service.dart';
import 'package:iqraquest/services/game_save_service.dart';
import 'package:iqraquest/services/legacy_game_migration_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:iqraquest/services/purchase_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpApp(WidgetTester tester, LocalStorageService storage) async {
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
        appRouterProvider.overrideWithValue(buildAppRouter(initialLocation: '/home')),
      ],
      child: const IqraQuestApp(),
    ),
  );
  // Not pumpAndSettle: the home screen's idle horse animation repeats
  // forever by design (spec §24), so it never "settles".
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('App boots to the home screen without crashing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    await pumpApp(tester, storage);
    expect(find.text('IqraQuest'), findsWidgets);
  });

  testWidgets('A save from the dice engine is explained once, not lost', (tester) async {
    SharedPreferences.setMockInitialValues({
      'iqraquest.save.currentGame.v1':
          '{"gameId":"old","turnPhase":"waitingForDice","lastDiceValue":4}',
    });
    final storage = await LocalStorageService.create();
    await pumpApp(tester, storage);

    final migration = LegacyGameMigrationService(storage);
    expect(migration.inspect(), SaveCompatibility.none, reason: 'archived, not resumable');
    expect(storage.getJson('iqraquest.save.legacyGame.archive'), isNotNull);
    expect(migration.hasSeenRaceRulesNotice, isTrue);
    // The notice is shown in the player's language, and offers a fresh race.
    expect(find.text('The race rules have been improved'), findsOneWidget);
    expect(find.text('Start a new race'), findsOneWidget);
  });
}
