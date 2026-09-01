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
import 'package:iqraquest/widgets/question_card_draw.dart';
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

Future<ProviderContainer> _pumpApp(
  WidgetTester tester,
  String initialLocation, {
  Future<void> Function(LocalStorageService storage)? seed,
}) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await tester.runAsync(LocalStorageService.create);
  if (seed != null) await tester.runAsync(() => seed(storage!));
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
  // Bitmap illustrations decode on a real event loop; without this they
  // capture as gray placeholders.
  final ctx = tester.element(find.byType(IqraQuestApp));
  await tester.runAsync(() async {
    for (final asset in const [
      'assets/board/scene_oasis.webp',
      'assets/board/horses/horse_emerald.webp',
      'assets/board/horses/horse_saphir.webp',
      'assets/board/horses/horse_grenat.webp',
      'assets/board/horses/horse_safran.webp',
      'assets/images/region_dawn.webp',
      'assets/images/region_oasis.webp',
      'assets/images/region_mountains.webp',
      'assets/images/chest_glow.webp',
      'assets/images/oasis_falls.webp',
      'assets/images/oasis_arrival.webp',
      'assets/images/world_band.webp',
    ]) {
      await precacheImage(AssetImage(asset), ctx);
    }
  });
  await _settle(tester);
  return ProviderScope.containerOf(tester.element(find.byType(IqraQuestApp)));
}

Player _human(String id, String name, AppTeam team, {int horseCount = 2}) => Player(
  id: id,
  name: name,
  team: team,
  horses: [for (var i = 0; i < horseCount; i++) const HorseState()],
);


/// Opens a turn: tap the deck, then let the card finish turning over
/// before the question sheet is expected on screen.
Future<void> _drawCard(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('draw-deck')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120));
  // The draw has to be seen: the card turns over and states its value
  // before the question sheet covers the board.
  expect(
    find.byType(DrawnCardReveal),
    findsOneWidget,
    reason: 'the card reveal must play, not be skipped',
  );
  await tester.pump(kCardRevealDuration + const Duration(milliseconds: 60));
  await _settle(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Widget tests render the placeholder "Ahem" font unless the real
    // fonts are loaded — and a visual QA of block glyphs is worthless.
    final bytes = File('assets/fonts/NotoSans-Regular.ttf').readAsBytesSync();
    final loader = FontLoader('NotoSans')..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
    final naskh = File('assets/fonts/NotoNaskhArabic-Regular.ttf').readAsBytesSync();
    final naskhLoader = FontLoader('NotoNaskhArabic')
      ..addFont(Future.value(ByteData.view(naskh.buffer)));
    await naskhLoader.load();
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

  GameState midJourneySave() {
    final now = DateTime(2026, 1, 1);
    return GameState(
      gameId: 'seed',
      gameMode: GameMode.solo,
      gameVariant: GameVariant.classic,
      circuitId: CircuitId.oasisRoute,
      players: [
        _human('p0', 'Amina', AppTeam.emerald).copyWith(
          horses: const [
            HorseState(position: TrackPosition(17)),
            HorseState(position: TrackPosition(5)),
          ],
          streak: const KnowledgeStreak(current: 4, best: 6),
        ),
        _human('p1', 'Yusuf', AppTeam.saphir),
      ],
      currentPlayerIndex: 0,
      turnPhase: TurnPhase.selectingGait,
      askedQuestionIds: const {},
      startedAt: now,
      updatedAt: now,
    );
  }

  testWidgets('home screen (mid-journey hub)', (tester) async {
    await _pumpApp(
      tester,
      '/home',
      seed: (storage) async {
        await GameSaveService(storage).save(midJourneySave());
        final progress = ProgressService(storage);
        for (var i = 0; i < 23; i++) {
          await progress.recordAnswer(correct: true, category: QuestionCategory.quran);
        }
        await progress.recordGameEnd(won: true);
      },
    );
    await _capture(tester, 'screen_home');
  });

  testWidgets('mode selection', (tester) async {
    await _pumpApp(tester, '/mode-selection');
    await _capture(tester, 'screen_mode_selection');
  });

  testWidgets('fertile valley region (greatRide)', (tester) async {
    final container = await _pumpApp(tester, '/game');
    final controller = container.read(gameControllerProvider.notifier);
    final pool = await tester.runAsync(() => QuestionRepository().loadAll('en'));
    controller.configure(pool: pool!, isPremium: true);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.classic,
      circuitId: CircuitId.greatRide,
      players: [
        _human('p0', 'Amina', AppTeam.emerald),
        _human('p1', 'Yusuf', AppTeam.saphir),
        _human('p2', 'Zaynab', AppTeam.grenat),
        _human('p3', 'Khalid', AppTeam.safran),
      ],
    );
    // Ride each team a little way out so all four camps AND horses on
    // the trail are visible: the "4-player board" proof capture.
    final state = container.read(gameControllerProvider)!.gameState;
    final players = [...state.players];
    for (var t = 0; t < 4; t++) {
      final entry = state.circuit.entryIndexForTeam(t);
      players[t] = players[t].copyWith(
        horses: [
          HorseState(position: TrackPosition((entry + 2 + t * 2) % state.circuit.trackLength)),
          const HorseState(),
        ],
      );
    }
    await tester.runAsync(
      () => container.read(gameSaveServiceProvider).save(state.copyWith(players: players)),
    );
    controller.loadSaved();
    await _settle(tester);
    await _capture(tester, 'screen_game_region_fertile');
  });

  testWidgets('chest offer on the solar trail (caravanTrail)', (tester) async {
    final container = await _pumpApp(tester, '/game');
    final controller = container.read(gameControllerProvider.notifier);
    final pool = await tester.runAsync(() => QuestionRepository().loadAll('en'));
    controller.configure(pool: pool!, isPremium: true);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.classic,
      circuitId: CircuitId.caravanTrail,
      players: [_human('p0', 'Amina', AppTeam.emerald), _human('p1', 'Yusuf', AppTeam.saphir)],
    );
    final state = container.read(gameControllerProvider)!.gameState;
    final players = [...state.players];
    players[0] = players[0].copyWith(
      horses: const [
        HorseState(position: TrackPosition(2)),
        HorseState(),
      ],
    );
    await tester.runAsync(
      () => container.read(gameSaveServiceProvider).save(state.copyWith(players: players)),
    );
    controller.loadSaved();
    await _settle(tester);

    await _drawCard(tester);
    final q = container.read(gameControllerProvider)!.currentQuestion;
    if (q != null) {
      await tester.tap(find.text(q.answers[q.correctAnswerIndex]).first);
      await _settle(tester);
      await tester.tap(find.text('Continue').last);
      await _settle(tester);
      await _capture(tester, 'screen_game_chest');
    }
  });

  testWidgets('VISUAL GATE: the oasis diorama, 4 stables, 4 horses each', (tester) async {
    final container = await _pumpApp(tester, '/game');
    final controller = container.read(gameControllerProvider.notifier);
    final pool = await tester.runAsync(() => QuestionRepository().loadAll('en'));
    controller.configure(pool: pool!, isPremium: true);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.classic,
      circuitId: CircuitId.oasisRoute,
      players: [
        _human('p0', 'Amina', AppTeam.emerald, horseCount: 4),
        _human('p1', 'Yusuf', AppTeam.saphir, horseCount: 4),
        _human('p2', 'Zaynab', AppTeam.grenat, horseCount: 4),
        _human('p3', 'Khalid', AppTeam.safran, horseCount: 4),
      ],
    );
    // Mid-race: every stable has horses out riding, one already on its
    // final lane — the "petits chevaux" structure must be readable.
    final state = container.read(gameControllerProvider)!.gameState;
    final players = [...state.players];
    players[0] = players[0].copyWith(
      horses: const [
        HorseState(position: TrackPosition(1)),
        HorseState(position: TrackPosition(3)),
        HorseState(),
        HorseState(),
      ],
    );
    players[1] = players[1].copyWith(
      horses: const [
        HorseState(position: TrackPosition(8), hasShield: true),
        HorseState(position: FinalLanePosition(2)),
        HorseState(),
        HorseState(),
      ],
    );
    players[2] = players[2].copyWith(
      horses: const [
        HorseState(position: TrackPosition(14)),
        HorseState(),
        HorseState(),
        HorseState(),
      ],
    );
    players[3] = players[3].copyWith(
      horses: const [
        HorseState(position: TrackPosition(20)),
        HorseState(position: TrackPosition(22)),
        HorseState(),
        HorseState(),
      ],
    );
    await tester.runAsync(
      () => container.read(gameSaveServiceProvider).save(state.copyWith(players: players)),
    );
    controller.loadSaved();
    await _settle(tester);
    await _capture(tester, 'screen_gate_board');

    // Draw the turn's card: the value it turns over is the distance,
    // and the destination beacon appears on the board itself.
    await _drawCard(tester);
    await _capture(tester, 'screen_gate_preview');
    final q = container.read(gameControllerProvider)!.currentQuestion;
    if (q != null) {
      await tester.tap(find.text(q.answers[q.correctAnswerIndex]).first);
      await _settle(tester);
      await tester.tap(find.text('Continue').last);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 110));
      await _capture(tester, 'screen_gate_moving');
      await _settle(tester);
    }
  });

  testWidgets('results: arrival at the oasis', (tester) async {
    final container = await _pumpApp(tester, '/results');
    final controller = container.read(gameControllerProvider.notifier);
    final pool = await tester.runAsync(() => QuestionRepository().loadAll('en'));
    controller.configure(pool: pool!, isPremium: true);
    // No winnerId set: the results screen then presents the first player,
    // which is exactly what the capture needs.
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.classic,
      circuitId: CircuitId.oasisRoute,
      players: [_human('p0', 'Amina', AppTeam.emerald), _human('p1', 'Yusuf', AppTeam.saphir)],
    );
    await _settle(tester);
    await _capture(tester, 'screen_results');
  });

  testWidgets('game: card draw, question, cell offer', (tester) async {
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

    // Tap through the real UI (not the controller) so screen-local
    // state — the reveal that holds the question back — is exercised.
    await _drawCard(tester);
    await _capture(tester, 'screen_game_question');

    final question = container.read(gameControllerProvider)!.currentQuestion;
    if (question != null) {
      await tester.tap(find.text(question.answers[question.correctAnswerIndex]).first);
      await _settle(tester);
      await _capture(tester, 'screen_game_feedback');

      // Continue: the horse now actually rides — catch it mid-hop.
      await tester.tap(find.text('Continue').last);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 130));
      await _capture(tester, 'screen_game_moving');
      await _settle(tester);
      if (find.text('Trot').evaluate().isNotEmpty) {
        await tester.tap(find.text('Trot'));
        await _settle(tester);
        await _drawCard(tester);
        final q2 = container.read(gameControllerProvider)!.currentQuestion;
        if (q2 != null) {
          final wrong = (q2.correctAnswerIndex + 1) % q2.answers.length;
          await tester.tap(find.text(q2.answers[wrong]).first);
          await _settle(tester);
          await _capture(tester, 'screen_game_wrong');
        }
      }
    }
  });
}
