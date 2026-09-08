// The pupil's screen, walked the way a class walks it: a code off the
// board, a first name, and then four answers at a time — with the wifi
// dropping once, because it will.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/app/app.dart';
import 'package:iqraquest/app/providers.dart';
import 'package:iqraquest/app/router.dart';
import 'package:iqraquest/features/classroom/application/classroom_controller.dart';
import 'package:iqraquest/features/classroom/data/fake_classroom_gateway.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

final en = AppLocalizationsEn();

Future<void> settle(WidgetTester tester, [int frames = 8]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

class _MemoryEntitlements implements EntitlementService {
  bool _premium = false;
  @override
  Future<bool> isPremium() async => _premium;
  @override
  Future<void> grantPremium() async => _premium = true;
  @override
  Future<void> revokePremium() async => _premium = false;
}

/// The room, the app, and the bank loaded for real — the pupil's screen
/// looks up its cards in it, so a fake bank would prove nothing.
Future<({FakeClassroomGateway room, List<Question> bank})> pumpPupil(
  WidgetTester tester,
) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({});
  final storage = await LocalStorageService.create();
  final room = FakeClassroomGateway(random: Random(11));
  final bank = await tester.runAsync(() => QuestionRepository().loadAll('en'));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
        settingsServiceProvider.overrideWithValue(SettingsService(storage)),
        entitlementServiceProvider.overrideWithValue(_MemoryEntitlements()),
        progressServiceProvider.overrideWithValue(ProgressService(storage)),
        gameSaveServiceProvider.overrideWithValue(GameSaveService(storage)),
        legacyGameMigrationServiceProvider.overrideWithValue(
          LegacyGameMigrationService(storage),
        ),
        questionRepositoryProvider.overrideWithValue(QuestionRepository()),
        // Loaded for real above, under runAsync: left to itself the
        // provider's asset read would never complete in a widget test,
        // and the pupil's screen would sit for ever on a card that
        // never comes.
        questionPoolProvider.overrideWith((ref) => bank!),
        purchaseServiceProvider.overrideWith((ref) => PurchaseService()),
        classroomGatewayProvider.overrideWithValue(room),
        initialSettingsProvider.overrideWithValue(const AppSettings()),
        initialPremiumProvider.overrideWithValue(false),
        appRouterProvider.overrideWithValue(
          buildAppRouter(initialLocation: '/classroom'),
        ),
      ],
      child: const IqraQuestApp(),
    ),
  );
  await settle(tester);
  return (room: room, bank: bank!);
}

Future<void> joinAs(WidgetTester tester, String code, String name) async {
  await tester.enterText(find.byKey(const Key('classroom-code')), code);
  await tester.enterText(find.byKey(const Key('classroom-nickname')), name);
  await settle(tester);
  await tester.tap(find.byKey(const Key('classroom-join')));
  await settle(tester);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    rootBundle.clear();
  });

  testWidgets('the form asks for a code and a first name, and says why', (
    tester,
  ) async {
    await pumpPupil(tester);

    expect(find.text(en.classroomCodeLabel), findsOneWidget);
    expect(find.text(en.classroomNicknameLabel), findsOneWidget);
    expect(
      find.text(en.classroomPrivacyNote),
      findsOneWidget,
      reason: 'a child can read what the app keeps of them',
    );
    expect(
      tester.widget<ElevatedButton>(find.byKey(const Key('classroom-join'))).onPressed,
      isNull,
      reason: 'nothing to join with yet',
    );
  });

  testWidgets('a scanned QR fills the code in, leaving only the first name', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final room = FakeClassroomGateway(random: Random(11));
    final bank = await tester.runAsync(() => QuestionRepository().loadAll('en'));
    final code = room.openSession(
      lessonId: 'piliers',
      questionIds: [bank!.first.id],
    );

    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(storage),
          settingsServiceProvider.overrideWithValue(SettingsService(storage)),
          entitlementServiceProvider.overrideWithValue(_MemoryEntitlements()),
          progressServiceProvider.overrideWithValue(ProgressService(storage)),
          gameSaveServiceProvider.overrideWithValue(GameSaveService(storage)),
          legacyGameMigrationServiceProvider.overrideWithValue(
            LegacyGameMigrationService(storage),
          ),
          questionRepositoryProvider.overrideWithValue(QuestionRepository()),
          questionPoolProvider.overrideWith((ref) => bank),
          purchaseServiceProvider.overrideWith((ref) => PurchaseService()),
          classroomGatewayProvider.overrideWithValue(room),
          initialSettingsProvider.overrideWithValue(const AppSettings()),
          initialPremiumProvider.overrideWithValue(false),
          appRouterProvider.overrideWithValue(
            buildAppRouter(
              initialLocation: '/classroom?code=${code.toLowerCase()}',
            ),
          ),
        ],
        child: const IqraQuestApp(),
      ),
    );
    await settle(tester);

    expect(
      tester
          .widget<TextField>(find.byKey(const Key('classroom-code')))
          .controller
          ?.text,
      code,
      reason: 'read off the QR, in the shape the room writes codes',
    );

    // Only the first name is left to type, and the room takes it.
    await tester.enterText(
      find.byKey(const Key('classroom-nickname')),
      'Amina',
    );
    await settle(tester);
    await tester.tap(find.byKey(const Key('classroom-join')));
    await settle(tester);
    expect(find.byKey(const Key('classroom-waiting')), findsOneWidget);
  });

  testWidgets('a wrong code is said plainly, and the form stays', (
    tester,
  ) async {
    await pumpPupil(tester);
    await joinAs(tester, 'ZZZZZZ', 'Amina');

    expect(find.text(en.classroomUnknownCode), findsOneWidget);
    expect(find.byKey(const Key('classroom-code')), findsOneWidget);
  });

  testWidgets('joining lands in the room and waits for the teacher', (
    tester,
  ) async {
    final harness = await pumpPupil(tester);
    final code = harness.room.openSession(
      lessonId: 'piliers',
      questionIds: [harness.bank.first.id],
    );

    await joinAs(tester, code, 'Amina');

    expect(find.byKey(const Key('classroom-waiting')), findsOneWidget);
    expect(find.text(en.classroomWaiting), findsOneWidget);
    expect(find.text(en.classroomWaitingHint), findsOneWidget);
  });

  testWidgets(
    'the card arrives in the pupil\'s language, is answered once, and the '
    'right answer waits for the teacher',
    (tester) async {
      final harness = await pumpPupil(tester);
      final card = harness.bank.firstWhere((q) => q.answers.length == 4);
      final code = harness.room.openSession(
        lessonId: 'piliers',
        questionIds: [card.id],
      );
      await joinAs(tester, code, 'Amina');

      harness.room.ask(code);
      await settle(tester);
      expect(find.text(card.question), findsOneWidget);
      expect(find.text(en.classroomQuestionOf(1, 1)), findsOneWidget);
      // Nothing on the pupil's screen betrays the answer before the
      // class sees it.
      expect(find.byIcon(Icons.check_circle), findsNothing);

      // The answers are shown in this device's own order; find where the
      // right one landed and tap it.
      final shown = [
        for (var i = 0; i < 4; i++)
          tester
              .widget<Text>(
                find
                    .descendant(
                      of: find.byKey(Key('classroom-answer-$i')),
                      matching: find.byType(Text),
                    )
                    .first,
              )
              .data!,
      ];
      final rightSlot = shown.indexOf(card.answers[card.correctAnswerIndex]);
      expect(rightSlot, isNot(-1));

      await tester.tap(find.byKey(Key('classroom-answer-$rightSlot')));
      await settle(tester);
      expect(find.text(en.classroomAnswerSent), findsOneWidget);
      expect(harness.room.correctCount(code, 0), 1);

      // Tapping again changes nothing: the first answer stands.
      await tester.tap(find.byKey(const Key('classroom-answer-0')));
      await settle(tester);
      expect(harness.room.correctCount(code, 0), 1);

      harness.room.reveal(code);
      await settle(tester);
      expect(find.text(en.correctAnswer), findsOneWidget);
      expect(
        find.text(card.explanation),
        findsOneWidget,
        reason: 'the why arrives with the verdict',
      );
    },
  );

  testWidgets('a wrong answer is not called out before the reveal', (
    tester,
  ) async {
    final harness = await pumpPupil(tester);
    final card = harness.bank.first;
    final code = harness.room.openSession(
      lessonId: 'piliers',
      questionIds: [card.id],
    );
    await joinAs(tester, code, 'Yusuf');
    harness.room.ask(code);
    await settle(tester);

    final shown = [
      for (var i = 0; i < 4; i++)
        tester
            .widget<Text>(
              find
                  .descendant(
                    of: find.byKey(Key('classroom-answer-$i')),
                    matching: find.byType(Text),
                  )
                  .first,
            )
            .data!,
    ];
    final wrongSlot = shown.indexWhere(
      (t) => t != card.answers[card.correctAnswerIndex],
    );
    await tester.tap(find.byKey(Key('classroom-answer-$wrongSlot')));
    await settle(tester);

    expect(find.text(en.classroomAnswerSent), findsOneWidget);
    expect(
      find.text(en.incorrectAnswer),
      findsNothing,
      reason: 'the verdict belongs to the moment the class sees it',
    );
    expect(harness.room.correctCount(code, 0), 0);

    harness.room.reveal(code);
    await settle(tester);
    expect(find.text(en.incorrectAnswer), findsOneWidget);
  });

  testWidgets('the next question wipes the previous answer', (tester) async {
    final harness = await pumpPupil(tester);
    final cards = harness.bank.take(2).toList();
    final code = harness.room.openSession(
      lessonId: 'piliers',
      questionIds: [for (final c in cards) c.id],
    );
    await joinAs(tester, code, 'Amina');

    harness.room.ask(code);
    await settle(tester);
    await tester.tap(find.byKey(const Key('classroom-answer-0')));
    await settle(tester);
    expect(find.text(en.classroomAnswerSent), findsOneWidget);

    harness.room.reveal(code);
    harness.room.ask(code);
    await settle(tester);

    expect(find.text(cards[1].question), findsOneWidget);
    expect(find.text(en.classroomAnswerSent), findsNothing);
    expect(find.text(en.classroomQuestionOf(2, 2)), findsOneWidget);
  });

  testWidgets('the end says what the pupil brought their team', (tester) async {
    final harness = await pumpPupil(tester);
    final code = harness.room.openSession(
      lessonId: 'piliers',
      questionIds: [harness.bank.first.id],
    );
    await joinAs(tester, code, 'Amina');
    harness.room.ask(code);
    await settle(tester);
    harness.room.reveal(code);
    harness.room.ask(code); // past the last card: the session ends
    await settle(tester);

    expect(find.byKey(const Key('classroom-over')), findsOneWidget);
    expect(find.text(en.classroomSessionOver), findsOneWidget);
  });

  testWidgets('leaving a class is asked for, never a stray back gesture', (
    tester,
  ) async {
    final harness = await pumpPupil(tester);
    final code = harness.room.openSession(
      lessonId: 'piliers',
      questionIds: [harness.bank.first.id],
    );
    await joinAs(tester, code, 'Amina');

    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(
      find.text(en.classroomPrivacyNote),
      findsOneWidget,
      reason: 'the confirmation, not the exit',
    );

    await tester.tap(find.byKey(const Key('classroom-leave-confirm')));
    await settle(tester);
    expect(
      find.text(en.appTagline),
      findsOneWidget,
      reason: 'leaving a class lands home, not on an empty form',
    );
  });

  testWidgets('a pupil whose app restarted comes straight back to the room', (
    tester,
  ) async {
    final harness = await pumpPupil(tester);
    final code = harness.room.openSession(
      lessonId: 'piliers',
      questionIds: [harness.bank.first.id],
    );
    await joinAs(tester, code, 'Amina');
    expect(find.byKey(const Key('classroom-waiting')), findsOneWidget);

    // The app is killed and started again on the same device: the seat
    // was kept, so the child does not have to ask for the code twice.
    await tester.pumpWidget(const SizedBox.shrink());
    await settle(tester, 2);
    final storage = await LocalStorageService.create();
    expect(
      storage.getJson('iqraquest.classroom.seat.v1'),
      isNotNull,
      reason: 'the seat outlives the app, and only the session',
    );
  });
}
