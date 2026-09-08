// The teacher's console, walked the way a teacher walks it on a Tuesday
// afternoon: an address, a lesson, a code read out loud, and three
// buttons for twenty minutes.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/app/app.dart';
import 'package:iqraquest/app/providers.dart';
import 'package:iqraquest/app/router.dart';
import 'package:iqraquest/features/classroom/application/classroom_controller.dart';
import 'package:iqraquest/features/classroom/application/teacher_console_controller.dart';
import 'package:iqraquest/features/classroom/data/fake_classroom_gateway.dart';
import 'package:iqraquest/features/classroom/data/fake_teacher_gateway.dart';
import 'package:iqraquest/features/classroom/data/teacher_gateway.dart';
import 'package:iqraquest/features/classroom/domain/classroom_state.dart';
import 'package:iqraquest/features/classroom/presentation/teacher_console_screen.dart';
import 'package:iqraquest/l10n/generated/app_localizations_en.dart';
import 'package:iqraquest/services/entitlement_service.dart';
import 'package:iqraquest/services/game_save_service.dart';
import 'package:iqraquest/services/legacy_game_migration_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:iqraquest/services/purchase_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/services/lesson_catalog.dart';
import 'package:iqraquest/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final en = AppLocalizationsEn();

class _MemoryEntitlements implements EntitlementService {
  bool _premium = false;
  @override
  Future<bool> isPremium() async => _premium;
  @override
  Future<void> grantPremium() async => _premium = true;
  @override
  Future<void> revokePremium() async => _premium = false;
}

Future<void> settle(WidgetTester tester, [int frames = 8]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

Licence licence({int concurrent = 1, Duration? life}) => Licence(
  id: 'l1',
  email: 'ecole@example.org',
  plan: 'classe',
  concurrentSessions: concurrent,
  expiresAt: DateTime.now().add(life ?? const Duration(days: 30)),
);

/// The console on a laptop, with an in-memory school behind it.
Future<({FakeTeacherGateway console, FakeClassroomGateway room})> pumpConsole(
  WidgetTester tester, {
  Licence? granted,
  String? signedInAs,
}) async {
  tester.view.physicalSize = const Size(1100, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({});
  final storage = await LocalStorageService.create();
  final room = FakeClassroomGateway(random: Random(9));
  final console = FakeTeacherGateway(
    room: room,
    licence: granted,
    signedInAs: signedInAs,
  );
  final repository = QuestionRepository();
  final bank = await tester.runAsync(() => repository.loadAll('en'));

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
        questionRepositoryProvider.overrideWithValue(repository),
        questionPoolProvider.overrideWith((ref) => bank!),
        purchaseServiceProvider.overrideWith((ref) => PurchaseService()),
        classroomGatewayProvider.overrideWithValue(room),
        teacherGatewayProvider.overrideWithValue(console),
        initialSettingsProvider.overrideWithValue(const AppSettings()),
        initialPremiumProvider.overrideWithValue(false),
        // The console's own route is web-only — a phone build must not
        // be able to reach a payment page at all — so the test mounts
        // the screen through a router of its own.
        appRouterProvider.overrideWithValue(
          GoRouter(
            initialLocation: '/teacher',
            routes: [
              GoRoute(
                path: '/teacher',
                builder: (c, s) => const TeacherConsoleScreen(fragment: ''),
              ),
            ],
          ),
        ),
      ],
      child: const IqraQuestApp(),
    ),
  );
  await settle(tester, 12);
  return (console: console, room: room);
}

Future<void> openLesson(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('teacher-open')));
  await settle(tester);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    rootBundle.clear();
  });

  testWidgets('a teacher signs in with an address and no password', (
    tester,
  ) async {
    final harness = await pumpConsole(tester);

    expect(find.text(en.teacherSignInHint), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(find.byKey(const Key('teacher-send')))
          .onPressed,
      isNull,
      reason: 'nothing to send to yet',
    );

    await tester.enterText(
      find.byKey(const Key('teacher-email')),
      'ecole@example.org',
    );
    await settle(tester);
    await tester.tap(find.byKey(const Key('teacher-send')));
    await settle(tester);

    expect(harness.console.linksSent, ['ecole@example.org']);
    expect(find.byKey(const Key('teacher-link-sent')), findsOneWidget);
  });

  testWidgets('an address that is not one is refused before anything is sent', (
    tester,
  ) async {
    final harness = await pumpConsole(tester);

    await tester.enterText(find.byKey(const Key('teacher-email')), 'not-a-mail');
    await settle(tester);
    await tester.tap(find.byKey(const Key('teacher-send')));
    await settle(tester);

    expect(harness.console.linksSent, isEmpty);
    expect(find.text(en.teacherInvalidEmail), findsOneWidget);
  });

  testWidgets('signed in with nothing bought, the console says so', (
    tester,
  ) async {
    await pumpConsole(tester, signedInAs: 'ecole@example.org');

    expect(find.byKey(const Key('teacher-no-licence')), findsOneWidget);
    expect(find.text(en.teacherNoLicence), findsOneWidget);
    expect(find.text('ecole@example.org'), findsOneWidget);
    expect(find.byKey(const Key('teacher-refresh')), findsOneWidget);
  });

  testWidgets('the licence bought meanwhile is picked up on the next check', (
    tester,
  ) async {
    final harness = await pumpConsole(tester, signedInAs: 'ecole@example.org');
    expect(find.byKey(const Key('teacher-no-licence')), findsOneWidget);

    // Stripe has been paid in another tab, and the webhook wrote the row.
    harness.console.grant(licence());
    await tester.tap(find.byKey(const Key('teacher-refresh')));
    await settle(tester);

    expect(find.byKey(const Key('teacher-open')), findsOneWidget);
    expect(find.text(en.teacherChooseLesson), findsOneWidget);
  });

  testWidgets('an expired licence does not open a room', (tester) async {
    await pumpConsole(
      tester,
      signedInAs: 'ecole@example.org',
      granted: licence(life: const Duration(days: -1)),
    );

    expect(find.byKey(const Key('teacher-no-licence')), findsOneWidget);
  });

  testWidgets('opening a lesson gives a code and the pace controls', (
    tester,
  ) async {
    final harness = await pumpConsole(
      tester,
      signedInAs: 'ecole@example.org',
      granted: licence(),
    );

    await openLesson(tester);

    expect(find.byKey(const Key('teacher-running')), findsOneWidget);
    final code = harness.console.codeOf.values.single;
    expect(find.text(code), findsOneWidget);
    expect(find.byKey(const Key('teacher-ask')), findsOneWidget);
    expect(
      find.byKey(const Key('teacher-reveal')),
      findsNothing,
      reason: 'nothing to reveal before anything is asked',
    );

    // The room really exists, with the lesson's cards in it.
    final state = await harness.room.boardState(code);
    expect(state.phase, ClassroomPhase.lobby);
    expect(state.questionIds, isNotEmpty);
  });

  testWidgets('the three gestures run the lesson, one at a time', (
    tester,
  ) async {
    final harness = await pumpConsole(
      tester,
      signedInAs: 'ecole@example.org',
      granted: licence(),
    );
    await openLesson(tester);
    final code = harness.console.codeOf.values.single;

    await tester.tap(find.byKey(const Key('teacher-ask')));
    await settle(tester);
    expect((await harness.room.boardState(code)).phase, ClassroomPhase.asking);
    expect(
      find.byKey(const Key('teacher-ask')),
      findsNothing,
      reason: 'while a card is open, the only gesture is to reveal it',
    );

    await tester.tap(find.byKey(const Key('teacher-reveal')));
    await settle(tester);
    expect(
      (await harness.room.boardState(code)).phase,
      ClassroomPhase.revealing,
    );
    expect(find.byKey(const Key('teacher-ask')), findsOneWidget);
  });

  testWidgets('the console shows the room filling up, and then answering', (
    tester,
  ) async {
    final harness = await pumpConsole(
      tester,
      signedInAs: 'ecole@example.org',
      granted: licence(),
    );
    await openLesson(tester);
    final code = harness.console.codeOf.values.single;

    final seat = await harness.room.join(code: code, nickname: 'Amina');
    await harness.room.join(code: code, nickname: 'Yusuf');
    await settle(tester);
    expect(find.text(en.classroomPupilCount(2)), findsOneWidget);

    await tester.tap(find.byKey(const Key('teacher-ask')));
    await settle(tester);
    await harness.room.answer(
      code: code,
      token: seat.token,
      questionIndex: 0,
      choice: 0,
    );
    await settle(tester);

    expect(
      find.textContaining(en.classroomAnsweredCount(1, 2)),
      findsOneWidget,
      reason: 'a teacher waits for the room, not for a timer',
    );
  });

  testWidgets('ending a session closes the room and forgets the class', (
    tester,
  ) async {
    final harness = await pumpConsole(
      tester,
      signedInAs: 'ecole@example.org',
      granted: licence(),
    );
    await openLesson(tester);
    final code = harness.console.codeOf.values.single;
    await harness.room.join(code: code, nickname: 'Amina');

    expect(find.text(en.teacherEndSessionHint), findsOneWidget);
    await tester.tap(find.byKey(const Key('teacher-end')));
    await settle(tester);

    expect(find.byKey(const Key('teacher-open')), findsOneWidget);
    expect(harness.console.codeOf, isEmpty);
    await expectLater(harness.room.boardState(code), throwsA(anything));
  });

  testWidgets('the individual mode drops the team count, which means nothing there', (
    tester,
  ) async {
    await pumpConsole(
      tester,
      signedInAs: 'ecole@example.org',
      granted: licence(),
    );

    expect(find.byKey(const Key('teacher-teams')), findsOneWidget);
    expect(find.byKey(const Key('teacher-timer')), findsOneWidget);
    expect(find.byKey(const Key('teacher-length')), findsOneWidget);
    expect(find.byKey(const Key('teacher-shuffle')), findsOneWidget);

    await tester.tap(find.byKey(const Key('teacher-scoring')));
    await settle(tester);
    await tester.tap(find.text(en.teacherScoringIndividual).last);
    await settle(tester);

    expect(find.byKey(const Key('teacher-teams')), findsNothing);
    expect(
      find.text(en.teacherScoringIndividualHint),
      findsOneWidget,
      reason: 'a teacher is told what a ranking puts on the wall',
    );
  });

  test('a half-period runs the first cards, in a fresh order', () async {
    final room = FakeClassroomGateway(random: Random(12));
    final console = FakeTeacherGateway(
      room: room,
      signedInAs: 'ecole@example.org',
      licence: licence(),
    );
    final controller = TeacherConsoleController(console);
    await controller.start();
    final lesson = (await LessonCatalog().load()).first;

    await controller.openSession(
      lesson: lesson,
      cardCount: 5,
      shuffle: true,
      secondsPerQuestion: 30,
      scoring: ClassroomScoring.individual,
      random: Random(1),
    );

    final state = await room.boardState(controller.state.code!);
    expect(state.questionIds, hasLength(5));
    expect(state.secondsPerQuestion, 30);
    expect(state.scoring, ClassroomScoring.individual);
    expect(
      state.questionIds.toSet().difference(lesson.questionIds.toSet()),
      isEmpty,
      reason: 'the cards are the lesson\'s own, only fewer and reordered',
    );
    expect(
      state.questionIds,
      isNot(lesson.questionIds.take(5).toList()),
      reason: 'shuffled, so a class replaying does not answer from memory',
    );
  });

  test('the whole lesson runs when no length is chosen', () async {
    final room = FakeClassroomGateway(random: Random(13));
    final console = FakeTeacherGateway(
      room: room,
      signedInAs: 'ecole@example.org',
      licence: licence(),
    );
    final controller = TeacherConsoleController(console);
    await controller.start();
    final lesson = (await LessonCatalog().load()).first;

    await controller.openSession(lesson: lesson);

    final state = await room.boardState(controller.state.code!);
    expect(state.questionIds, lesson.questionIds);
    expect(state.scoring, ClassroomScoring.teams);
  });

  test('a licence for one room does not open a second', () async {
    final room = FakeClassroomGateway(random: Random(4));
    final console = FakeTeacherGateway(
      room: room,
      signedInAs: 'ecole@example.org',
      licence: licence(),
    );
    final controller = TeacherConsoleController(console);
    await controller.start();
    final lesson = (await LessonCatalog().load()).first;

    await controller.openSession(lesson: lesson);
    expect(controller.state.code, isNotNull);

    // A second tab, a second lesson, the same licence.
    final second = TeacherConsoleController(console);
    await second.start();
    await second.openSession(lesson: lesson);

    expect(second.state.error, TeacherError.tooManySessions);
    expect(second.state.errorLimit, 1);
    expect(second.state.code, isNull);
  });

  test('the report a school keeps is written by closing, not by leaving', () async {
    final room = FakeClassroomGateway(random: Random(6));
    final console = FakeTeacherGateway(
      room: room,
      signedInAs: 'ecole@example.org',
      licence: licence(),
    );
    final controller = TeacherConsoleController(console);
    await controller.start();
    final lesson = (await LessonCatalog().load()).first;
    await controller.openSession(lesson: lesson);
    final code = controller.state.code!;
    await room.join(code: code, nickname: 'Amina');

    await controller.endSession();

    expect(controller.state.stage, ConsoleStage.ready);
    expect(controller.state.code, isNull);
    await expectLater(room.boardState(code), throwsA(anything));
  });
}
