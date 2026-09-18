@Tags(['manual'])
library;

// Visual QA for the UI/UX review: every screen, in five conditions —
// light phone, dark phone, a 16:9 phone at normal and at large text,
// and the 320-point floor phone (phones are portrait-only) — written to
// build/screenshots/audit_<variant>_<screen>.png for a human to look at.
//
// Opt-in, unlike the other `manual` helper: it renders sixty-odd
// screens and the run does not always exit cleanly after the last one,
// so it stays out of the default suite and out of CI.
//
//   UX_AUDIT=1 flutter test --tags=manual test/manual_ux_audit_test.dart
//
// The board, the results and the riders' screen stall when they follow
// other captures in one run; capture them on their own, per variant:
//
//   UX_AUDIT=1 UX_AUDIT_SOLO=1 flutter test --tags=manual \
//     --plain-name "<variant> game" test/manual_ux_audit_test.dart
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
import 'package:iqraquest/features/game/application/game_controller.dart';
import 'package:iqraquest/features/players/presentation/player_setup_args.dart';
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
import 'package:iqraquest/widgets/question_card.dart';
import 'package:iqraquest/widgets/question_card_draw.dart';
import 'package:iqraquest/widgets/celebration_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Variant {
  const _Variant(this.name, this.size, this.scale, this.theme);
  final String name;
  final Size size;
  final double scale;
  final ThemeMode theme;
}

const _variants = [
  _Variant('light', Size(390, 844), 1.0, ThemeMode.light),
  _Variant('dark', Size(390, 844), 1.0, ThemeMode.dark),
  _Variant('small_big_text', Size(375, 667), 1.3, ThemeMode.light),
  _Variant('small', Size(375, 667), 1.0, ThemeMode.light),
  _Variant('floor', Size(320, 568), 1.0, ThemeMode.light),
];

Future<void> _capture(WidgetTester tester, String name) async {
  final boundary =
      find.byType(RepaintBoundary).evaluate().first.renderObject!
          as RenderRepaintBoundary;
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
  _Variant v,
  String initialLocation, {
  Future<void> Function(LocalStorageService storage)? seed,
  bool premium = false,
}) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await tester.runAsync(LocalStorageService.create);
  if (seed != null) await tester.runAsync(() => seed(storage!));
  tester.view.physicalSize = v.size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = v.scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final scope = ProviderScope(
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
      initialSettingsProvider.overrideWithValue(
        AppSettings(themeMode: v.theme),
      ),
      initialPremiumProvider.overrideWithValue(premium),
      appRouterProvider.overrideWithValue(
        buildAppRouter(initialLocation: initialLocation),
      ),
    ],
    child: const RepaintBoundary(child: IqraQuestApp()),
  );
  await tester.pumpWidget(scope);
  await _settle(tester);
  final ctx = tester.element(find.byType(IqraQuestApp));
  await tester.runAsync(() async {
    for (final asset in const [
      'assets/board/cross_board.webp',
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

Player _human(String id, String name, AppTeam team, {int horseCount = 2}) =>
    Player(
      id: id,
      name: name,
      team: team,
      horses: [for (var i = 0; i < horseCount; i++) const HorseState()],
    );

GameState _midJourneySave() {
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

Future<void> _drawCard(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('draw-deck')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120));
  await tester.pump(kCardRevealDuration + const Duration(milliseconds: 60));
  await tester.pump(kCelebrationDuration + const Duration(milliseconds: 60));
  await _settle(tester);
  if (find.byKey(const Key('move-choice')).evaluate().isNotEmpty) {
    await tester.tap(find.byKey(const Key('move-option-0')));
    await _settle(tester);
  }
}

final bool _optedIn = Platform.environment['UX_AUDIT'] == '1';
final bool _solo = Platform.environment['UX_AUDIT_SOLO'] == '1';

void main() {
  if (!_optedIn) {
    test('UX audit captures (opt in with UX_AUDIT=1)', () {}, skip: true);
    return;
  }
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final bytes = File('assets/fonts/NotoSans-Regular.ttf').readAsBytesSync();
    final loader = FontLoader('NotoSans')
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
    final naskh = File('assets/fonts/NotoNaskhArabic-Regular.ttf')
        .readAsBytesSync();
    final naskhLoader = FontLoader('NotoNaskhArabic')
      ..addFont(Future.value(ByteData.view(naskh.buffer)));
    await naskhLoader.load();
    for (final root in const ['/home/user/flutter', '/home/user/flutter-sdk']) {
      final iconFont = File(
        '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
      );
      if (iconFont.existsSync()) {
        final icons = FontLoader('MaterialIcons')
          ..addFont(
            Future.value(ByteData.view(iconFont.readAsBytesSync().buffer)),
          );
        await icons.load();
        break;
      }
    }
  });

  for (final v in _variants) {
    group(v.name, () {
      testWidgets('home', (tester) async {
        await _pumpApp(
          tester,
          v,
          '/home',
          seed: (storage) async {
            await GameSaveService(storage).save(_midJourneySave());
            final progress = ProgressService(storage);
            for (var i = 0; i < 23; i++) {
              await progress.recordAnswer(
                correct: true,
                category: QuestionCategory.quran,
              );
            }
            await progress.recordGameEnd(won: true);
          },
        );
        await _capture(tester, 'audit_${v.name}_home');
      });

      for (final route in const [
        '/onboarding',
        '/mode-selection',
        '/settings',
        '/progress',
        '/daily-challenge',
        '/tutorial',
      ]) {
        testWidgets(route, (tester) async {
          await _pumpApp(tester, v, route);
          await _capture(
            tester,
            'audit_${v.name}_${route.substring(1).replaceAll('-', '_')}',
          );
        });
      }

      // Run on its own, like the board (see below).
      testWidgets('player setup', skip: !_solo, (tester) async {
        final container = await _pumpApp(tester, v, '/mode-selection');
        container
            .read(appRouterProvider)
            .go(
              '/player-setup',
              extra: const PlayerSetupArgs(
                mode: GameMode.family,
                variant: GameVariant.classic,
                circuitId: CircuitId.oasisRoute,
              ),
            );
        await _settle(tester);
        await _capture(tester, 'audit_${v.name}_player_setup');
      });

      // Run on its own, like the board (see below).
      testWidgets('results', skip: !_solo, (tester) async {
        final container = await _pumpApp(tester, v, '/results');
        final controller = container.read(gameControllerProvider.notifier);
        final pool = await tester.runAsync(
          () => QuestionRepository().loadAll('en'),
        );
        controller.configure(pool: pool!, isPremium: false);
        controller.startNewGame(
          mode: GameMode.family,
          variant: GameVariant.classic,
          circuitId: CircuitId.oasisRoute,
          players: [
            _human('p0', 'Amina', AppTeam.emerald),
            _human('p1', 'Yusuf', AppTeam.saphir),
          ],
        );
        await _settle(tester);
        await _capture(tester, 'audit_${v.name}_results');
      });

      testWidgets('game: gait, question, feedback', (tester) async {
        final container = await _pumpApp(tester, v, '/game');
        final controller = container.read(gameControllerProvider.notifier);
        final pool = await tester.runAsync(
          () => QuestionRepository().loadAll('en'),
        );
        controller.configure(pool: pool!, isPremium: false);
        controller.startNewGame(
          mode: GameMode.family,
          variant: GameVariant.classic,
          circuitId: CircuitId.oasisRoute,
          players: [
            _human('p0', 'Amina', AppTeam.emerald),
            _human('p1', 'Yusuf', AppTeam.saphir),
          ],
        );
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
          () => container
              .read(gameSaveServiceProvider)
              .save(state.copyWith(players: players)),
        );
        controller.loadSaved();
        await _settle(tester);
        await _capture(tester, 'audit_${v.name}_game_gait');
        await _drawCard(tester);
        await _capture(tester, 'audit_${v.name}_game_question');
        final question = container
            .read(gameControllerProvider)!
            .currentQuestion;
        if (question != null) {
          final tile = find.descendant(
            of: find.byType(QuestionCard),
            matching: find.text(question.answers[question.correctAnswerIndex]),
          );
          await tester.ensureVisible(tile.first);
          await tester.tap(tile.first);
          await _settle(tester);
          await _capture(tester, 'audit_${v.name}_game_feedback');
        }
      });
    });
  }

  // The two Premium popups a free player meets, for the marketing
  // review. Each on its own (UX_AUDIT_SOLO=1): they drive the board.
  group('premium popups', () {
    final v = _variants.first;

    testWidgets('free-limit popup', skip: !_solo, (tester) async {
      // A race the 50-draw limit stopped: the results screen opens on
      // the popup. The state has to exist before the screen's first
      // frame, so the app opens on home and is sent to the results.
      // (resumeFrom refuses a finished game, so the session is set.)
      final container = await _pumpApp(tester, v, '/home');
      final controller = container.read(gameControllerProvider.notifier);
      final pool = await tester.runAsync(
        () => QuestionRepository().loadAll('en'),
      );
      controller.configure(pool: pool!, isPremium: false);
      controller.startNewGame(
        mode: GameMode.family,
        variant: GameVariant.classic,
        circuitId: CircuitId.oasisRoute,
        players: [
          _human('p0', 'Amina', AppTeam.emerald),
          _human('p1', 'Yusuf', AppTeam.saphir),
        ],
      );
      final over = controller.state!.gameState.copyWith(
        turnPhase: TurnPhase.gameOver,
        endedByDrawLimit: true,
        drawCount: GameState.freeDrawLimit,
      );
      // ignore: invalid_use_of_protected_member
      controller.state = GameSession(gameState: over);
      container.read(appRouterProvider).go('/results');
      await _settle(tester);
      expect(find.byKey(const Key('free-limit-popup')), findsOneWidget);
      await _capture(tester, 'premium_free_limit_popup');
    });

    testWidgets('free-tour popup', skip: !_solo, (tester) async {
      // Every free card already seen on this device: the first draw of
      // the next game says the tour is done and offers the whole bank.
      final pool = await tester.runAsync(
        () => QuestionRepository().loadAll('en'),
      );
      final freeIds = [
        for (final q in pool!)
          if (q.isFree) q.id,
      ];
      final container = await _pumpApp(
        tester,
        v,
        '/game',
        seed: (storage) => ProgressService(storage).markSeen(freeIds),
      );
      final controller = container.read(gameControllerProvider.notifier);
      controller.configure(pool: pool, isPremium: false);
      controller.startNewGame(
        mode: GameMode.family,
        variant: GameVariant.classic,
        circuitId: CircuitId.oasisRoute,
        players: [
          _human('p0', 'Amina', AppTeam.emerald),
          _human('p1', 'Yusuf', AppTeam.saphir),
        ],
      );
      await _settle(tester);
      await _drawCard(tester);
      expect(find.byKey(const Key('free-tour-popup')), findsOneWidget);
      await _capture(tester, 'premium_free_tour_popup');
    });
  });

  // Last, on its own: the Premium screen wakes the billing plugin, whose
  // missing platform channel throws and leaves the binding in a state
  // that can stall the next runAsync. Nothing runs after it.
  group('premium', () {
    for (final v in _variants) {
      testWidgets(v.name, (tester) async {
        await _pumpApp(tester, v, '/premium');
        await _capture(tester, 'audit_${v.name}_premium');
      });
    }
  });
}
