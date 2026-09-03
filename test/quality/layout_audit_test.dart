// A layout regression net: renders every screen at the smallest and
// largest phones the app supports, at normal AND accessibility text
// sizes, and fails on any overflow.
//
// This is the class of bug that only shows up on someone else's phone —
// a label that fits in French at 100% and blows its row in German at
// 130%. Catching it here is much cheaper than catching it in review.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/app/app.dart';
import 'package:iqraquest/app/providers.dart';
import 'package:iqraquest/app/router.dart';
import 'package:iqraquest/features/game/application/game_controller.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/services/entitlement_service.dart';
import 'package:iqraquest/services/game_save_service.dart';
import 'package:iqraquest/services/legacy_game_migration_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:iqraquest/services/purchase_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/services/settings_service.dart';
import 'package:iqraquest/services/game_save_service.dart' show GameSaveService;
import 'package:iqraquest/theme/app_team.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The narrowest and the widest phones the app is built for. The small
/// one is where things collide; the large one is where they strand.
const _small = Size(320, 568); // iPhone SE 1st gen — the floor
const _large = Size(430, 932); // iPhone Pro Max — the ceiling

/// And the tablets, in both orientations. A phone layout dropped onto an
/// iPad does not overflow — it strands: the composition huddles at the
/// top of a screen twice its height, and turning the device sideways
/// asks the same question of a layout that has only ever been tall.
const _tabletPortrait = Size(834, 1194); // iPad Pro 11"
const _tabletLandscape = Size(1194, 834);
const _bigTabletLandscape = Size(1366, 1024); // iPad Pro 13"

/// Android is not iOS with different corners: its phones are taller for
/// their width, its tablets are wider for their height, and the same
/// layout has to hold on both. These are the shapes Play's device
/// catalogue is actually full of, in dp.
const _androidPhone = Size(360, 780); // a common 20:9 Android phone
const _androidTablet = Size(800, 1280);
const _androidTabletLandscape = Size(1280, 800);

const _routes = <String>[
  '/onboarding',
  '/home',
  '/mode-selection',
  '/settings',
  '/premium',
  '/progress',
  '/daily-challenge',
  '/tutorial',
];

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<void> _pump(
  WidgetTester tester,
  String route, {
  required Size size,
  required double textScale,
  GameState? save,
  String? languageCode,
}) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await tester.runAsync(LocalStorageService.create);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  if (save != null) {
    await tester.runAsync(() => GameSaveService(storage!).save(save));
  }

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
        initialSettingsProvider.overrideWithValue(
          AppSettings(languageCode: languageCode),
        ),
        initialPremiumProvider.overrideWithValue(true),
        appRouterProvider.overrideWithValue(
          buildAppRouter(initialLocation: route),
        ),
      ],
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: const IqraQuestApp(),
      ),
    ),
  );
  await _settle(tester);
}

/// The results board reads the live session, not a save: start one with
/// four long-named riders so the podium rows are the ones that wrap.
Future<void> _startGameForResults(WidgetTester tester) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(IqraQuestApp)),
  );
  // A screen rendered by an earlier test may have started loading the
  // same asset inside its fake-async zone; rootBundle caches that
  // never-completing future by key and a real await on it hangs forever.
  rootBundle.clear();
  final pool = await tester.runAsync(() => QuestionRepository().loadAll('en'));
  final controller = container.read(gameControllerProvider.notifier);
  controller.configure(pool: pool!, isPremium: true);
  controller.startNewGame(
    mode: GameMode.family,
    variant: GameVariant.classic,
    circuitId: CircuitId.oasisRoute,
    players: _gameInProgress().players,
  );
  await _settle(tester);
}

GameState _gameInProgress() {
  final now = DateTime(2026, 1, 1);
  return GameState(
    gameId: 'audit',
    gameMode: GameMode.family,
    gameVariant: GameVariant.classic,
    circuitId: CircuitId.oasisRoute,
    players: [
      for (var i = 0; i < 4; i++)
        Player(
          id: 'p$i',
          // A name long enough to test the row, not a placeholder.
          name: 'Abdurrahmane$i',
          team: kBoardSeats[i],
          horses: const [HorseState(), HorseState()],
        ),
    ],
    currentPlayerIndex: 0,
    turnPhase: TurnPhase.selectingGait,
    askedQuestionIds: const {},
    // The free edition's draw counter is one more pill in the HUD row.
    maxDraws: GameState.freeDrawLimit,
    drawCount: 12,
    startedAt: now,
    updatedAt: now,
  );
}

void main() {
  for (final (label, size) in [
    ('small 320x568', _small),
    ('large 430x932', _large),
    ('tablet portrait 834x1194', _tabletPortrait),
    ('tablet landscape 1194x834', _tabletLandscape),
    ('big tablet landscape 1366x1024', _bigTabletLandscape),
    ('android phone 360x780', _androidPhone),
    ('android tablet 800x1280', _androidTablet),
    ('android tablet landscape 1280x800', _androidTabletLandscape),
  ]) {
    for (final scale in [1.0, 1.3]) {
      group('$label at text scale $scale', () {
        for (final route in _routes) {
          testWidgets('$route lays out without overflow', (tester) async {
            await _pump(tester, route, size: size, textScale: scale);
            expect(tester.takeException(), isNull, reason: '$route overflowed');
          });
        }

        testWidgets('/game lays out without overflow', (tester) async {
          await _pump(
            tester,
            '/game',
            size: size,
            textScale: scale,
            save: _gameInProgress(),
          );
          expect(tester.takeException(), isNull, reason: '/game overflowed');
        });

        testWidgets('/results lays out without overflow', (tester) async {
          await _pump(tester, '/results', size: size, textScale: scale);
          await _startGameForResults(tester);
          expect(tester.takeException(), isNull, reason: '/results overflowed');
        });
      });
    }
  }

  // Right-to-left is not a mirror of the French layout: Arabic runs
  // wider on some labels, narrower on others, and every hard-coded
  // "left" becomes a bug. The floor phone at the large text size is the
  // harshest combination, so it is the one that gates.
  group('Arabic (RTL) on the small phone at text scale 1.3', () {
    for (final route in _routes) {
      testWidgets('$route lays out without overflow', (tester) async {
        await _pump(
          tester,
          route,
          size: _small,
          textScale: 1.3,
          languageCode: 'ar',
        );
        expect(
          tester.takeException(),
          isNull,
          reason: '$route overflowed in RTL',
        );
      });
    }

    testWidgets('/game lays out without overflow', (tester) async {
      await _pump(
        tester,
        '/game',
        size: _small,
        textScale: 1.3,
        languageCode: 'ar',
        save: _gameInProgress(),
      );
      expect(tester.takeException(), isNull, reason: '/game overflowed in RTL');
    });

    testWidgets('/results lays out without overflow', (tester) async {
      await _pump(
        tester,
        '/results',
        size: _small,
        textScale: 1.3,
        languageCode: 'ar',
      );
      await _startGameForResults(tester);
      expect(
        tester.takeException(),
        isNull,
        reason: '/results overflowed in RTL',
      );
    });
  });
}
