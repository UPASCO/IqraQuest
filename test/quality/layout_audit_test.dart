// A layout regression net: renders every screen at the smallest and
// largest phones the app supports, at normal AND accessibility text
// sizes, and fails on any overflow.
//
// This is the class of bug that only shows up on someone else's phone —
// a label that fits in French at 100% and blows its row in German at
// 130%. Catching it here is much cheaper than catching it in review.
import 'package:flutter/material.dart';
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
import 'package:iqraquest/services/game_save_service.dart' show GameSaveService;
import 'package:iqraquest/theme/app_team.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The narrowest and the widest phones the app is built for. The small
/// one is where things collide; the large one is where they strand.
const _small = Size(320, 568); // iPhone SE 1st gen — the floor
const _large = Size(430, 932); // iPhone Pro Max — the ceiling

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
        legacyGameMigrationServiceProvider
            .overrideWithValue(LegacyGameMigrationService(storage)),
        questionRepositoryProvider.overrideWithValue(QuestionRepository()),
        purchaseServiceProvider.overrideWith((ref) => PurchaseService()),
        initialSettingsProvider.overrideWithValue(const AppSettings()),
        initialPremiumProvider.overrideWithValue(true),
        appRouterProvider.overrideWithValue(buildAppRouter(initialLocation: route)),
      ],
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: const IqraQuestApp(),
      ),
    ),
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
    startedAt: now,
    updatedAt: now,
  );
}

void main() {
  for (final (label, size) in [('small 320x568', _small), ('large 430x932', _large)]) {
    for (final scale in [1.0, 1.3]) {
      group('$label at text scale $scale', () {
        for (final route in _routes) {
          testWidgets('$route lays out without overflow', (tester) async {
            await _pump(tester, route, size: size, textScale: scale);
            expect(tester.takeException(), isNull, reason: '$route overflowed');
          });
        }

        testWidgets('/game lays out without overflow', (tester) async {
          await _pump(tester, '/game',
              size: size, textScale: scale, save: _gameInProgress());
          expect(tester.takeException(), isNull, reason: '/game overflowed');
        });
      });
    }
  }
}
