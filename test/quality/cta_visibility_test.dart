// The one button that moves a screen forward must be on screen without
// scrolling — on the smallest phone, at the accessibility text size.
//
// "You have to scroll down to confirm and you can get lost" is exactly
// the report this guards against: a child who has filled in the riders
// and sees no button assumes the screen is broken.
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
import 'package:iqraquest/theme/app_team.dart';
import 'package:iqraquest/widgets/question_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _floor = Size(320, 568);
const _scale = 1.3;

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  String route, {
  bool premium = true,
}) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await tester.runAsync(LocalStorageService.create);
  tester.view.physicalSize = _floor;
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
        initialPremiumProvider.overrideWithValue(premium),
        appRouterProvider.overrideWithValue(
          buildAppRouter(initialLocation: route),
        ),
      ],
      child: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(_scale)),
        child: const IqraQuestApp(),
      ),
    ),
  );
  await _settle(tester);
  return ProviderScope.containerOf(tester.element(find.byType(IqraQuestApp)));
}

/// The widget is fully inside the viewport, so a tap reaches it with no
/// scroll — and there is one of it.
void _expectOnScreen(WidgetTester tester, Finder finder, String what) {
  expect(finder, findsOneWidget, reason: '$what is not on screen');
  final rect = tester.getRect(finder);
  expect(
    rect.top,
    greaterThanOrEqualTo(0),
    reason: '$what starts above the screen',
  );
  expect(
    rect.bottom,
    lessThanOrEqualTo(_floor.height),
    reason: '$what ends below the fold (${rect.bottom} > ${_floor.height})',
  );
}

void main() {
  final en = AppLocalizationsEn();

  testWidgets('mode selection: Continue is pinned', (tester) async {
    await _pump(tester, '/mode-selection');
    _expectOnScreen(tester, find.byType(ElevatedButton), 'Continue');
  });

  testWidgets('riders: Start the game is pinned under four riders', (
    tester,
  ) async {
    await _pump(tester, '/mode-selection');
    // Four humans is the longest form the screen ever shows. The
    // stepper sits below the fold of the list, hence the drag.
    await tester.dragUntilVisible(
      find.byTooltip('+1'),
      find.byType(ListView),
      const Offset(0, -160),
    );
    await _settle(tester);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byTooltip('+1').last);
      await _settle(tester);
    }
    await tester.tap(find.byType(ElevatedButton));
    await _settle(tester);
    _expectOnScreen(
      tester,
      find.byKey(const Key('start-game')),
      'Start the game',
    );
  });

  testWidgets('onboarding: the way in is on screen', (tester) async {
    await _pump(tester, '/onboarding');
    _expectOnScreen(tester, find.byType(FilledButton), 'Start');
  });

  testWidgets('onboarding: a language chip re-renders the screen at once', (
    tester,
  ) async {
    await _pump(tester, '/onboarding');
    // The screen opens in the platform language (English under test).
    expect(find.text('Get started'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('lang-fr')));
    await tester.tap(find.byKey(const ValueKey('lang-fr')));
    await _settle(tester);
    // No confirmation, no reload: the whole screen is French now, the
    // way in included — and it is still on screen.
    expect(find.text('Commencer'), findsOneWidget);
    expect(find.text('Get started'), findsNothing);
    _expectOnScreen(tester, find.byType(FilledButton), 'Commencer');
  });

  testWidgets('onboarding: the three steps never run into each other', (
    tester,
  ) async {
    // The report was "the writing overlaps at the steps": three columns
    // of copy set edge to edge, so the end of one line sat against the
    // start of the next. Measured on the smallest phone at the largest
    // text, where the columns are narrowest.
    await _pump(tester, '/onboarding');
    final labels = [
      for (var n = 1; n <= 3; n++) find.byKey(ValueKey('step-label-$n')),
    ];
    for (final l in labels) {
      expect(l, findsOneWidget);
      await tester.ensureVisible(l);
    }
    await _settle(tester);
    final rects = [for (final l in labels) tester.getRect(l)];
    for (var i = 0; i + 1 < rects.length; i++) {
      expect(
        rects[i + 1].left - rects[i].right,
        greaterThanOrEqualTo(8.0),
        reason:
            'step ${i + 1} ends at ${rects[i].right} and step ${i + 2} '
            'starts at ${rects[i + 1].left}: the copy touches',
      );
    }
  });

  testWidgets('premium: the purchase button is on screen', (tester) async {
    await _pump(tester, '/premium', premium: false);
    _expectOnScreen(tester, find.byType(ElevatedButton), 'Unlock');
  });

  testWidgets('daily challenge: Continue is pinned once answered', (
    tester,
  ) async {
    // An earlier test may have left a never-completing load of the same
    // asset in the bundle cache (started inside its fake-async zone).
    rootBundle.clear();
    await _pump(tester, '/daily-challenge');
    // The bank is real I/O (a large JSON decoded off the main isolate),
    // which only completes while real time runs: wait for the first card
    // rather than for a fixed delay that a loaded machine would overrun.
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while (find.byType(QuestionCard).evaluate().isEmpty &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      }
    });
    await _settle(tester);
    final question = find.byType(QuestionCard);
    expect(question, findsOneWidget, reason: 'the day\'s first question is up');
    final q = tester.widget<QuestionCard>(question).question;
    // The day's question is date-dependent; a long one can push the
    // answers below the fold of the smallest phone, so scroll to it —
    // the card scrolls, only Continue must not.
    final firstAnswer = find.text(q.answers.first).first;
    await tester.ensureVisible(firstAnswer);
    await _settle(tester);
    await tester.tap(firstAnswer);
    await _settle(tester);
    _expectOnScreen(
      tester,
      find.byKey(const Key('daily-continue')),
      'Continue',
    );
  });

  testWidgets('results: Race again is on screen', (tester) async {
    final container = await _pump(tester, '/results');
    // An earlier screen may have started loading the same asset inside
    // its fake-async zone; the cached future would never complete here.
    rootBundle.clear();
    final pool = await tester.runAsync(
      () => QuestionRepository().loadAll('en'),
    );
    final controller = container.read(gameControllerProvider.notifier);
    controller.configure(pool: pool!, isPremium: true);
    controller.startNewGame(
      mode: GameMode.family,
      variant: GameVariant.classic,
      circuitId: CircuitId.oasisRoute,
      players: [
        for (var i = 0; i < 4; i++)
          Player(
            id: 'p$i',
            name: 'Abdurrahmane$i',
            team: kBoardSeats[i],
            horses: const [
              HorseState(),
              HorseState(),
              HorseState(),
              HorseState(),
            ],
          ),
      ],
    );
    await _settle(tester);
    _expectOnScreen(
      tester,
      find.byKey(const Key('race-again')),
      en.playAgainSameRiders,
    );
  });
}
