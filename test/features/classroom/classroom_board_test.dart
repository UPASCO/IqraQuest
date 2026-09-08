// The board a class watches. Everything here is checked from the back
// row: what the wall shows, and — just as much — what it never shows.
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
import 'package:iqraquest/features/classroom/domain/classroom_state.dart';
import 'package:iqraquest/features/classroom/presentation/classroom_board_screen.dart';
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

/// A projector-sized screen, a room, and the bank loaded for real.
///
/// The board loads its own bank in the session's language, so the
/// repository handed to it is pre-warmed here under [WidgetTester.runAsync]:
/// an asset read started inside a widget test's clock never completes,
/// and the wall would sit for ever on a spinner.
Future<Widget> boardApp({
  required String location,
  required FakeClassroomGateway room,
  required WidgetTester tester,
}) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await LocalStorageService.create();
  final repository = QuestionRepository();
  final bank = await tester.runAsync(() => repository.loadAll('en'));

  return ProviderScope(
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
      initialSettingsProvider.overrideWithValue(const AppSettings()),
      initialPremiumProvider.overrideWithValue(false),
      appRouterProvider.overrideWithValue(
        buildAppRouter(initialLocation: location),
      ),
    ],
    child: const IqraQuestApp(),
  );
}

Future<({FakeClassroomGateway room, List<Question> bank, String code})>
pumpBoard(
  WidgetTester tester, {
  int questions = 3,
  int teamCount = 2,
  ClassroomScoring scoring = ClassroomScoring.teams,
}) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final room = FakeClassroomGateway(random: Random(3));
  final repository = QuestionRepository();
  final bank = await tester.runAsync(() => repository.loadAll('en'));
  final cards = bank!.take(questions).toList();
  final code = room.openSession(
    lessonId: 'lesson_prophets_beginner_01',
    questionIds: [for (final c in cards) c.id],
    teamCount: teamCount,
    boardLanguage: 'en',
    scoring: scoring,
  );

  await tester.pumpWidget(
    await boardApp(
      location: '/classroom/board/$code',
      room: room,
      tester: tester,
    ),
  );
  await settle(tester, 12);
  return (room: room, bank: cards, code: code);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    rootBundle.clear();
  });

  testWidgets('the lobby keeps the code on the wall and names the joiners', (
    tester,
  ) async {
    final harness = await pumpBoard(tester);
    await harness.room.join(code: harness.code, nickname: 'Amina');
    await harness.room.join(code: harness.code, nickname: 'Yusuf');
    await settle(tester);

    expect(find.byKey(const Key('board-lobby')), findsOneWidget);
    expect(find.text(harness.code), findsOneWidget);
    expect(find.text(en.classroomBoardHowToJoin), findsOneWidget);
    expect(find.text('Amina'), findsOneWidget);
    expect(find.text('Yusuf'), findsOneWidget);
  });

  testWidgets('an unknown code says so instead of waiting for ever', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      await boardApp(
        location: '/classroom/board/ZZZZZZ',
        room: FakeClassroomGateway(random: Random(5)),
        tester: tester,
      ),
    );
    await settle(tester, 12);

    expect(find.byKey(const Key('board-error')), findsOneWidget);
    expect(find.text(en.classroomUnknownCode), findsOneWidget);
  });

  testWidgets('the open card is shown without ever giving the answer away', (
    tester,
  ) async {
    final harness = await pumpBoard(tester);
    final seat = await harness.room.join(
      code: harness.code,
      nickname: 'Amina',
    );
    harness.room.ask(harness.code);
    await settle(tester);

    final card = harness.bank.first;
    expect(find.text(card.question), findsOneWidget);
    expect(find.byKey(const Key('board-answer-3')), findsOneWidget);
    expect(
      find.byIcon(Icons.check_circle),
      findsNothing,
      reason: 'the wall is not where the class reads the answer first',
    );
    expect(find.text(en.classroomAnsweredCount(0, 1)), findsOneWidget);

    await harness.room.answer(
      code: harness.code,
      token: seat.token,
      questionIndex: 0,
      choice: 0,
    );
    await settle(tester);
    expect(
      find.text(en.classroomAnsweredCount(1, 1)),
      findsOneWidget,
      reason: 'how many, never who',
    );
    expect(find.text(card.explanation), findsNothing);
  });

  testWidgets('the answers keep their place while the card is on the wall', (
    tester,
  ) async {
    final harness = await pumpBoard(tester);
    harness.room.ask(harness.code);
    await settle(tester);

    List<String> shown() => [
      for (var i = 0; i < 4; i++)
        tester
            .widget<Text>(
              find
                  .descendant(
                    of: find.byKey(Key('board-answer-$i')),
                    matching: find.byType(Text),
                  )
                  .first,
            )
            .data!,
    ];

    final first = shown();
    expect(first.toSet(), harness.bank.first.answers.toSet());

    // Somebody answers, the board redraws — the answers must not move
    // while a class is reading them.
    final seat = await harness.room.join(
      code: harness.code,
      nickname: 'Amina',
    );
    await harness.room.answer(
      code: harness.code,
      token: seat.token,
      questionIndex: 0,
      choice: 1,
    );
    await settle(tester);
    expect(shown(), first);
  });

  testWidgets('the reveal shows the answer, the why and the source', (
    tester,
  ) async {
    final harness = await pumpBoard(tester);
    harness.room.ask(harness.code);
    await settle(tester);
    harness.room.reveal(harness.code);
    await settle(tester);

    final card = harness.bank.first;
    expect(find.byKey(const Key('board-reveal')), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text(card.explanation), findsOneWidget);
    expect(
      find.text(card.sourceDisplay),
      findsOneWidget,
      reason: 'a lesson that cannot be checked is not a lesson',
    );
  });

  testWidgets('a right answer moves that team\'s horse, and only that one', (
    tester,
  ) async {
    final harness = await pumpBoard(tester, teamCount: 2);
    final a = await harness.room.join(code: harness.code, nickname: 'Amina');
    await harness.room.join(code: harness.code, nickname: 'Yusuf');
    harness.room.ask(harness.code);
    await settle(tester);

    expect(find.byKey(const Key('board-lane-0')), findsOneWidget);
    expect(find.byKey(const Key('board-lane-1')), findsOneWidget);
    expect(find.text(en.classroomSquaresCount(0)), findsNWidgets(2));

    await harness.room.answer(
      code: harness.code,
      token: a.token,
      questionIndex: 0,
      choice: 0,
    );
    await settle(tester);

    expect(find.text(en.classroomSquaresCount(1)), findsOneWidget);
    expect(find.text(en.classroomSquaresCount(0)), findsOneWidget);
  });

  testWidgets('the end ranks the teams and names the cards to go over', (
    tester,
  ) async {
    final harness = await pumpBoard(tester, questions: 2, teamCount: 2);
    final a = await harness.room.join(code: harness.code, nickname: 'Amina');
    final b = await harness.room.join(code: harness.code, nickname: 'Yusuf');

    // First card: one right, one wrong — the class half missed it.
    harness.room.ask(harness.code);
    await harness.room.answer(
      code: harness.code,
      token: a.token,
      questionIndex: 0,
      choice: 0,
    );
    await harness.room.answer(
      code: harness.code,
      token: b.token,
      questionIndex: 0,
      choice: 2,
    );
    harness.room.reveal(harness.code);
    // Second card: both right, so it is not worth going over again.
    harness.room.ask(harness.code);
    await harness.room.answer(
      code: harness.code,
      token: a.token,
      questionIndex: 1,
      choice: 0,
    );
    await harness.room.answer(
      code: harness.code,
      token: b.token,
      questionIndex: 1,
      choice: 0,
    );
    harness.room.reveal(harness.code);
    harness.room.ask(harness.code);
    await settle(tester);

    expect(find.byKey(const Key('board-over')), findsOneWidget);
    expect(find.text(en.classroomSessionOver), findsOneWidget);
    expect(find.byKey(const Key('board-podium-0')), findsOneWidget);
    expect(find.byKey(const Key('board-podium-1')), findsOneWidget);

    expect(find.text(en.classroomToReview), findsOneWidget);
    expect(
      find.byKey(const Key('board-review-0')),
      findsOneWidget,
      reason: 'the half-missed card is the one to go over',
    );
    expect(find.byKey(const Key('board-review-1')), findsNothing);
    expect(find.text(harness.bank.first.question), findsOneWidget);
    expect(find.text(en.classroomSuccessRate(50)), findsOneWidget);
  });

  testWidgets('the lobby carries a QR beside the code, for whoever can scan', (
    tester,
  ) async {
    final harness = await pumpBoard(tester);

    expect(find.byKey(const Key('board-qr')), findsOneWidget);
    expect(find.text(en.classroomScanToJoin), findsOneWidget);
    expect(
      find.text(harness.code),
      findsOneWidget,
      reason: 'the six characters stay on the wall for those without a camera',
    );
    expect(
      classroomJoinUrl(harness.code),
      endsWith('/#/classroom?code=${harness.code}'),
      reason: 'scanning lands on the join form with the code filled in',
    );
  });

  testWidgets('the team mode shows lanes and no name against a score', (
    tester,
  ) async {
    final harness = await pumpBoard(tester, teamCount: 2);
    final seat = await harness.room.join(code: harness.code, nickname: 'Amina');
    harness.room.ask(harness.code);
    await harness.room.answer(
      code: harness.code,
      token: seat.token,
      questionIndex: 0,
      choice: 0,
    );
    await settle(tester);

    expect(find.byKey(const Key('board-lane-0')), findsOneWidget);
    expect(find.byKey(const Key('board-ranking')), findsNothing);
    expect(find.text('Amina'), findsNothing);
  });

  testWidgets('the individual mode ranks the pupils on the wall', (
    tester,
  ) async {
    final harness = await pumpBoard(
      tester,
      teamCount: 2,
      scoring: ClassroomScoring.individual,
    );
    final a = await harness.room.join(code: harness.code, nickname: 'Amina');
    await harness.room.join(code: harness.code, nickname: 'Yusuf');
    harness.room.ask(harness.code);
    await harness.room.answer(
      code: harness.code,
      token: a.token,
      questionIndex: 0,
      choice: 0,
    );
    await settle(tester);

    expect(find.byKey(const Key('board-ranking')), findsOneWidget);
    expect(find.byKey(const Key('board-lane-0')), findsNothing);
    expect(find.text('Amina'), findsOneWidget);
    expect(find.text(en.classroomPointsCount(1)), findsOneWidget);
    expect(find.text(en.classroomPointsCount(0)), findsOneWidget);
  });

  testWidgets('the countdown appears only when the teacher set one', (
    tester,
  ) async {
    final harness = await pumpBoard(tester);
    harness.room.ask(harness.code);
    await settle(tester);

    expect(
      find.byKey(const Key('classroom-countdown')),
      findsNothing,
      reason: 'no timer by default: the teacher reveals by hand',
    );
  });

  testWidgets('a timed question shows the seconds left, on the wall', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final room = FakeClassroomGateway(random: Random(21));
    final repository = QuestionRepository();
    final bank = await tester.runAsync(() => repository.loadAll('en'));
    final code = room.openSession(
      lessonId: 'p',
      questionIds: [bank!.first.id],
      boardLanguage: 'en',
      secondsPerQuestion: 30,
    );

    await tester.pumpWidget(
      await boardApp(
        location: '/classroom/board/$code',
        room: room,
        tester: tester,
      ),
    );
    await settle(tester, 12);
    room.ask(code);
    await settle(tester);

    expect(find.byKey(const Key('classroom-countdown')), findsOneWidget);
    // The card is still the biggest thing on the wall; the timer is not
    // allowed to take the room over.
    expect(find.text(bank.first.question), findsOneWidget);
  });

  testWidgets('a small classroom screen still fits the card', (tester) async {
    final harness = await pumpBoard(tester);
    // Not every school has a wide projector; some cast to a 4:3 screen
    // at the back of the room.
    tester.view.physicalSize = const Size(800, 600);
    await tester.pump();
    harness.room.ask(harness.code);
    await settle(tester);

    expect(find.text(harness.bank.first.question), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the wall never carries a name against an answer', (
    tester,
  ) async {
    final harness = await pumpBoard(tester);
    final seat = await harness.room.join(
      code: harness.code,
      nickname: 'Amina',
    );
    harness.room.ask(harness.code);
    await harness.room.answer(
      code: harness.code,
      token: seat.token,
      questionIndex: 0,
      choice: 2,
    );
    await settle(tester);

    expect(
      find.text('Amina'),
      findsNothing,
      reason: 'names belong to the lobby, not to a wrong answer',
    );
  });
}
