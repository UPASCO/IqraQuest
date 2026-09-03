// What a table decides before the first card: how long the race is, and
// whether the parcours carries bonus squares at all.
//
// Both were invisible before. Three formats were offered under names
// ("rapide", "classique", "famille") of which two played exactly the
// same race, and the bonus squares were simply always there. These tests
// hold the two choices to what they promise — on the screen where they
// are made, and in the game they produce.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/app/app.dart';
import 'package:iqraquest/app/providers.dart';
import 'package:iqraquest/app/router.dart';
import 'package:iqraquest/features/game/application/game_controller.dart';
import 'package:iqraquest/features/game/domain/game_engine.dart';
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

final _en = AppLocalizationsEn();

Future<void> _settle(WidgetTester tester, [int frames = 8]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _pumpSetup(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await tester.runAsync(LocalStorageService.create);
  // A tall viewport: the setup screen is a lazy ListView, and a section
  // below the fold is not built at all, so it could not be found.
  tester.view.physicalSize = const Size(420, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
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
          buildAppRouter(initialLocation: '/mode-selection'),
        ),
      ],
      child: const IqraQuestApp(),
    ),
  );
  await _settle(tester);
}

Future<GameController> _controller(LocalStorageService storage) async {
  final repo = QuestionRepository();
  final pool = await repo.loadAll('en');
  final controller = GameController(
    engine: const GameEngine(),
    questionRepository: repo,
    saveService: GameSaveService(storage),
    progressService: ProgressService(storage),
    random: Random(7),
    animate: false,
  );
  controller.configure(pool: pool, isPremium: true);
  return controller;
}

List<Player> _riders() => [
  for (var i = 0; i < 2; i++)
    Player(
      id: 'p$i',
      name: 'P$i',
      team: kBoardSeats[i],
      horses: const [HorseState(), HorseState(), HorseState(), HorseState()],
    ),
];

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    rootBundle.clear();
  });

  testWidgets('the three formats are told apart by the horses they ask for', (
    tester,
  ) async {
    await _pumpSetup(tester);

    // One card per format, and each says its own win condition — the
    // whole point of the section.
    for (final variant in GameVariantX.choosable) {
      final card = find.byKey(ValueKey('format-${variant.name}'));
      expect(card, findsOneWidget, reason: '${variant.name} is not offered');
      await tester.ensureVisible(card);
      expect(
        find.descendant(
          of: card,
          matching: find.text(_en.horsesToMecca(variant.horsesToWin)),
        ),
        findsOneWidget,
        reason: '${variant.name} does not say how many horses it wants',
      );
    }

    // And the three conditions are genuinely different numbers.
    expect(find.text(_en.horsesToMecca(1)), findsOneWidget);
    expect(find.text(_en.horsesToMecca(2)), findsOneWidget);
    expect(find.text(_en.horsesToMecca(4)), findsOneWidget);
  });

  testWidgets('the bonus squares can be switched off before the race', (
    tester,
  ) async {
    await _pumpSetup(tester);
    final toggle = find.byKey(const Key('bonus-switch'));
    expect(toggle, findsOneWidget);
    await tester.ensureVisible(toggle);

    // On by default, and it says what the squares give.
    expect(find.text(_en.bonusSquaresOn), findsOneWidget);
    expect(find.text(_en.bonusSquaresOff), findsNothing);

    await tester.tap(find.descendant(of: toggle, matching: find.byType(Switch)));
    await _settle(tester);

    // Off, and it says what the ride becomes.
    expect(find.text(_en.bonusSquaresOff), findsOneWidget);
    expect(find.text(_en.bonusSquaresOn), findsNothing);
  });

  test('a game started without bonuses carries no bonus square at all', () async {
    final storage = await LocalStorageService.create();
    final controller = await _controller(storage);

    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.duo,
      circuitId: CircuitId.greatRide,
      players: _riders(),
      bonusesEnabled: false,
    );
    final state = controller.state!.gameState;
    expect(state.bonusesEnabled, isFalse);
    expect(state.bonusTiles, isEmpty);
    expect(state.gameVariant.horsesToWin, 2);

    // And the choice survives a save: resuming must not deal a layout
    // the table said no to.
    final restored = GameState.fromJson(state.toJson());
    expect(restored.bonusesEnabled, isFalse);
    expect(const GameEngine().ensureBonusLayout(restored).bonusTiles, isEmpty);

    controller.dispose();
  });

  test('a game started with bonuses gets its sixteen squares', () async {
    final storage = await LocalStorageService.create();
    final controller = await _controller(storage);

    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.quick,
      circuitId: CircuitId.greatRide,
      players: _riders(),
    );
    final state = controller.state!.gameState;
    expect(state.bonusesEnabled, isTrue);
    expect(state.bonusTiles.length, 16);

    controller.dispose();
  });

  test('a game saved before the option existed still rides with bonuses', () {
    // Old saves carry no such key; silently turning their bonuses off
    // would change a race already in progress.
    final json = {
      'schemaVersion': 3,
      'gameId': 'old',
      'gameMode': 'family',
      'gameVariant': 'classic',
      'circuitId': 'oasisRoute',
      'players': <dynamic>[],
      'currentPlayerIndex': 0,
      'turnPhase': 'selectingGait',
      'askedQuestionIds': <String>[],
      'startedAt': DateTime(2026).toIso8601String(),
      'updatedAt': DateTime(2026).toIso8601String(),
    };
    expect(GameState.fromJson(json).bonusesEnabled, isTrue);
  });
}
