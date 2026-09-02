import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:iqraquest/services/share_service.dart';
import 'package:iqraquest/theme/app_team.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sharing a score: the results board and the daily challenge each hand
/// the platform sheet a sentence a parent can post as-is plus a PNG of
/// the ornate score card — never an empty share, never a crash when the
/// sheet is unavailable.
final en = AppLocalizationsEn();

class _FakeShare extends ShareService {
  const _FakeShare(this.log);
  final List<({String text, Uint8List? image, Rect? origin})> log;

  @override
  Future<bool> shareScore({
    required String text,
    String? subject,
    Uint8List? image,
    String imageName = 'iqraquest_score.png',
    Rect? origin,
  }) async {
    log.add((text: text, image: image, origin: origin));
    return true;
  }
}

Future<ProviderContainer> pumpApp(
  WidgetTester tester,
  String location,
  List<({String text, Uint8List? image, Rect? origin})> log,
) async {
  SharedPreferences.setMockInitialValues({});
  rootBundle.clear();
  final storage = await tester.runAsync(LocalStorageService.create);
  tester.view.physicalSize = const Size(390, 844);
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
        shareServiceProvider.overrideWithValue(_FakeShare(log)),
        initialSettingsProvider.overrideWithValue(const AppSettings()),
        initialPremiumProvider.overrideWithValue(true),
        appRouterProvider.overrideWithValue(
          buildAppRouter(initialLocation: location),
        ),
      ],
      child: const IqraQuestApp(),
    ),
  );
  await settle(tester);
  return ProviderScope.containerOf(tester.element(find.byType(IqraQuestApp)));
}

Future<void> settle(WidgetTester tester, [int frames = 10]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Player _human(String id, String name, AppTeam team) => Player(
  id: id,
  name: name,
  team: team,
  horses: const [HorseState(), HorseState()],
);

void main() {
  testWidgets(
    'results board shares the winner sentence with a PNG of the card',
    (tester) async {
      final log = <({String text, Uint8List? image, Rect? origin})>[];
      final container = await pumpApp(tester, '/results', log);
      final controller = container.read(gameControllerProvider.notifier);
      final pool = await tester.runAsync(
        () => QuestionRepository().loadAll('en'),
      );
      controller.configure(pool: pool!, isPremium: true);
      controller.startNewGame(
        mode: GameMode.family,
        variant: GameVariant.classic,
        circuitId: CircuitId.oasisRoute,
        players: [
          _human('p0', 'Amina', AppTeam.emerald),
          _human('p1', 'Yusuf', AppTeam.saphir),
        ],
      );
      await settle(tester);

      expect(find.byKey(const Key('share-score')), findsOneWidget);
      // toImage needs a real event loop.
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('share-score')));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await settle(tester);

      expect(log, hasLength(1));
      expect(log.single.text, en.shareVictoryText('Amina', 0));
      expect(
        log.single.image,
        isNotNull,
        reason: 'the ornate card must ship as a picture',
      );
      // PNG signature: the share sheet gets a real image, not raw pixels.
      expect(log.single.image!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
      expect(log.single.image!.length, greaterThan(20 * 1024));
      expect(log.single.origin, isNotNull, reason: 'iPad popover anchor');
    },
  );

  testWidgets('daily challenge summary shares the day score', (tester) async {
    final log = <({String text, Uint8List? image, Rect? origin})>[];
    await pumpApp(tester, '/daily-challenge', log);
    // Real asset IO for the question pool: the bank is decoded off the
    // main isolate and only completes while real time runs, so wait for
    // the first card rather than for a fixed delay that a loaded machine
    // would overrun.
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while (find.text('A').evaluate().isEmpty &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      }
    });
    await settle(tester);

    // Play the whole challenge: always the first choice, then continue.
    // Every wait is against real time, never a fixed number of frames: a
    // loaded machine decodes the bank slowly, and a fixed wait is exactly
    // the kind of flake that only ever fails on the build runner.
    Future<void> waitFor(Finder finder, String what) async {
      await tester.runAsync(() async {
        final deadline = DateTime.now().add(const Duration(seconds: 20));
        while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await tester.pump();
        }
      });
      await settle(tester);
      expect(finder, findsWidgets, reason: '$what never appeared');
    }

    var guard = 0;
    while (find.byKey(const Key('share-score')).evaluate().isEmpty &&
        guard++ < 20) {
      await waitFor(find.text('A'), 'a question');
      final choice = find.text('A').first;
      await tester.ensureVisible(choice);
      await settle(tester);
      await tester.tap(choice);
      await settle(tester);
      await waitFor(find.text('Continue'), 'the way on');
      await tester.ensureVisible(find.text('Continue').last);
      await tester.pump();
      await tester.tap(find.text('Continue').last);
      await settle(tester);
    }
    expect(find.byKey(const Key('share-score')), findsOneWidget);
    expect(find.text(en.dailyChallengeDone), findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('share-score')));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await settle(tester);
    expect(log, hasLength(1));
    expect(log.single.text, contains('/'));
    expect(log.single.image, isNotNull);
  });
}
