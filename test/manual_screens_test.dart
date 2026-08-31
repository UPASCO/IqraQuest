@Tags(['manual'])
library;

// Visual-QA: renders the app's real screens at phone size to
// build/screenshots/screen_*.png so the UI can be reviewed as images.
// Fast (runAsync captures) and side-effect free outside build/.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/app/app.dart';
import 'package:iqraquest/app/providers.dart';
import 'package:iqraquest/app/router.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/services/entitlement_service.dart';
import 'package:iqraquest/services/game_save_service.dart';
import 'package:iqraquest/services/legacy_game_migration_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:iqraquest/services/purchase_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/services/settings_service.dart';
import 'package:iqraquest/features/game/application/game_controller.dart';
import 'package:iqraquest/theme/app_team.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _phone = Size(390, 844);

Future<void> _capture(WidgetTester tester, String name) async {
  final boundary =
      find.byType(RepaintBoundary).evaluate().first.renderObject! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final dir = Directory('build/screenshots')..createSync(recursive: true);
    File('${dir.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<ProviderContainer> _pumpApp(WidgetTester tester, String initialLocation) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await tester.runAsync(LocalStorageService.create);
  tester.view.physicalSize = _phone;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final scope = ProviderScope(
    overrides: [
      settingsServiceProvider.overrideWithValue(SettingsService(storage!)),
      entitlementServiceProvider.overrideWithValue(EntitlementService()),
      progressServiceProvider.overrideWithValue(ProgressService(storage)),
      gameSaveServiceProvider.overrideWithValue(GameSaveService(storage)),
      legacyGameMigrationServiceProvider.overrideWithValue(LegacyGameMigrationService(storage)),
      questionRepositoryProvider.overrideWithValue(QuestionRepository()),
      // Lazily, so the billing platform channel (absent in tests) is
      // only touched if a screen actually watches it.
      purchaseServiceProvider.overrideWith((ref) => PurchaseService()),
      initialSettingsProvider.overrideWithValue(const AppSettings()),
      initialPremiumProvider.overrideWithValue(true),
      appRouterProvider.overrideWithValue(buildAppRouter(initialLocation: initialLocation)),
    ],
    child: const RepaintBoundary(child: IqraQuestApp()),
  );
  await tester.pumpWidget(scope);
  await _settle(tester);
  return ProviderScope.containerOf(tester.element(find.byType(IqraQuestApp)));
}

Player _human(String id, String name, AppTeam team) =>
    Player(id: id, name: name, team: team, horses: const [HorseState(), HorseState()]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Widget tests render the placeholder "Ahem" font unless the real
    // fonts are loaded — and a visual QA of block glyphs is worthless.
    final bytes = File('assets/fonts/NotoSans-Regular.ttf').readAsBytesSync();
    final loader = FontLoader('NotoSans')..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
    // Material icons otherwise render as tofu boxes in widget tests.
    final iconFont = File(
      '/home/user/flutter-sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (iconFont.existsSync()) {
      final icons = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.view(iconFont.readAsBytesSync().buffer)));
      await icons.load();
    }
  });

  testWidgets('home screen', (tester) async {
    await _pumpApp(tester, '/home');
    await _capture(tester, 'screen_home');
  });

  testWidgets('mode selection', (tester) async {
    await _pumpApp(tester, '/mode-selection');
    await _capture(tester, 'screen_mode_selection');
  });

  testWidgets('game: gait selection, question, cell offer', (tester) async {
    final container = await _pumpApp(tester, '/game');
    final controller = container.read(gameControllerProvider.notifier);
    final pool = await tester.runAsync(() => QuestionRepository().loadAll('en'));
    controller.configure(pool: pool!, isPremium: true);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.classic,
      circuitId: CircuitId.oasisRoute,
      players: [_human('p0', 'Amina', AppTeam.emerald), _human('p1', 'Yusuf', AppTeam.saphir)],
    );
    // Some progress on the board so it doesn't look empty: mutate the
    // state and round-trip it through the save, which the controller can
    // reload.
    final state = container.read(gameControllerProvider)!.gameState;
    final players = [...state.players];
    players[0] = players[0].copyWith(
      horses: [
        const HorseState(position: TrackPosition(2)),
        const HorseState(position: HomePosition()),
      ],
      streak: const KnowledgeStreak(current: 2, best: 4),
    );
    players[1] = players[1].copyWith(
      horses: [
        const HorseState(position: TrackPosition(8), hasShield: true),
        const HorseState(position: FinalLanePosition(1)),
      ],
    );
    await tester.runAsync(
      () => container.read(gameSaveServiceProvider).save(state.copyWith(players: players)),
    );
    controller.loadSaved();
    await _settle(tester);
    await _capture(tester, 'screen_game_gait');

    // Tap through the real UI (not the controller) so screen-local state
    // like the chosen gait — which drives the reward chip — is exercised.
    await tester.tap(find.text('3 squares'));
    await _settle(tester);
    await _capture(tester, 'screen_game_question');

    final question = container.read(gameControllerProvider)!.currentQuestion;
    if (question != null) {
      await tester.tap(find.text(question.answers[question.correctAnswerIndex]).first);
      await _settle(tester);
      await _capture(tester, 'screen_game_feedback');
    }
  });
}
