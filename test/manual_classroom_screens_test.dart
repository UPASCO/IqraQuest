@Tags(['manual'])
library;

// Le mode Classe, rendu en images plutôt qu'en paragraphes.
//
// Ce fichier ne vérifie rien : il photographie les vrais écrans, dans
// l'ordre où une séance se déroule, pour qu'on puisse regarder ce qu'une
// classe verra au lieu de l'imaginer. Il est tagué `manual` et exclu de
// la suite par défaut, comme les autres captures.
//
//   flutter test --tags=manual test/manual_classroom_screens_test.dart
//
// Les fichiers arrivent dans build/screenshots/classe-*.png.
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show ByteData, FontLoader, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/services/entitlement_service.dart';
import 'package:iqraquest/services/game_save_service.dart';
import 'package:iqraquest/services/legacy_game_migration_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:iqraquest/services/purchase_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/services/settings_service.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryEntitlements implements EntitlementService {
  bool _premium = false;
  @override
  Future<bool> isPremium() async => _premium;
  @override
  Future<void> grantPremium() async => _premium = true;
  @override
  Future<void> revokePremium() async => _premium = false;
}

Future<void> settle(WidgetTester tester, [int frames = 10]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

Future<void> capture(WidgetTester tester, String name) async {
  final element = find.byType(RepaintBoundary).evaluate().first;
  final boundary = element.renderObject! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final dir = Directory('build/screenshots')..createSync(recursive: true);
    File('${dir.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

/// Une classe complète, en français, avec sa banque de cartes.
Future<({FakeClassroomGateway room, List<Question> bank, String code})> stage(
  WidgetTester tester, {
  required Size size,
  required String location,
  int questions = 4,
  int teamCount = 3,
  ClassroomScoring scoring = ClassroomScoring.teams,
  int secondsPerQuestion = 0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;

  SharedPreferences.setMockInitialValues({});
  rootBundle.clear();
  final storage = await LocalStorageService.create();
  final room = FakeClassroomGateway(random: Random(17));
  final repository = QuestionRepository();
  final bank = await tester.runAsync(() => repository.loadAll('fr'));
  // Des cartes courtes : une capture doit se lire, pas se déchiffrer.
  final cards = bank!.where((q) => q.question.length < 90).take(questions).toList();
  final code = room.openSession(
    lessonId: 'lesson_prophets_beginner_01',
    questionIds: [for (final c in cards) c.id],
    teamCount: teamCount,
    boardLanguage: 'fr',
    scoring: scoring,
    secondsPerQuestion: secondsPerQuestion,
  );

  await tester.pumpWidget(
    RepaintBoundary(
      child: ProviderScope(
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
          questionPoolProvider.overrideWith((ref) => cards),
          purchaseServiceProvider.overrideWith((ref) => PurchaseService()),
          classroomGatewayProvider.overrideWithValue(room),
          initialSettingsProvider.overrideWithValue(
            const AppSettings(languageCode: 'fr'),
          ),
          initialPremiumProvider.overrideWithValue(false),
          appRouterProvider.overrideWithValue(
            buildAppRouter(initialLocation: location),
          ),
        ],
        child: const IqraQuestApp(),
      ),
    ),
  );
  await settle(tester, 14);
  return (room: room, bank: cards, code: code);
}

/// Les polices de l'application, chargées pour de vrai.
///
/// Un test widget rend par défaut avec une police de test dont chaque
/// glyphe est un rectangle noir : parfait pour mesurer une mise en page,
/// inutile pour montrer un écran à quelqu'un. On enregistre donc les
/// deux polices livrées avec l'app, sous les noms que le thème demande.
Future<void> loadAppFonts() async {
  for (final family in const {
    'NotoSans': 'assets/fonts/NotoSans-Regular.ttf',
    'NotoNaskhArabic': 'assets/fonts/NotoNaskhArabic-Regular.ttf',
  }.entries) {
    final bytes = File(family.value).readAsBytesSync();
    await (FontLoader(family.key)
          ..addFont(Future.value(ByteData.sublistView(bytes))))
        .load();
  }
}

void main() {
  setUpAll(loadAppFonts);

  const board = Size(1280, 800);
  const phone = Size(420, 900);

  testWidgets('1 — le vestibule projeté : le code et le QR', (tester) async {
    final s = await stage(tester, size: board, location: '/classroom/board/');
    await tester.pumpWidget(const SizedBox.shrink());
    final live = await stage(
      tester,
      size: board,
      location: '/classroom/board/${s.code}',
    );
    for (final name in ['Amina', 'Yusuf', 'Sara', 'Bilal', 'Maryam', 'Idris']) {
      await live.room.join(code: live.code, nickname: name);
    }
    await settle(tester);
    await capture(tester, 'classe-1-vestibule');
  });

  testWidgets('2 — la question au tableau, et qui a répondu', (tester) async {
    final s = await stage(tester, size: board, location: '/classroom/board/');
    await tester.pumpWidget(const SizedBox.shrink());
    final live = await stage(
      tester,
      size: board,
      location: '/classroom/board/${s.code}',
      secondsPerQuestion: 30,
    );
    final seats = [
      for (final n in ['Amina', 'Yusuf', 'Sara', 'Bilal', 'Maryam', 'Idris'])
        await live.room.join(code: live.code, nickname: n),
    ];
    live.room.ask(live.code);
    for (final seat in seats.take(4)) {
      await live.room.answer(
        code: live.code,
        token: seat.token,
        questionIndex: 0,
        choice: seats.indexOf(seat).isEven ? 0 : 2,
      );
    }
    await settle(tester);
    await capture(tester, 'classe-2-question');
  });

  testWidgets('3 — la réponse montrée, et les chevaux qui avancent', (
    tester,
  ) async {
    final s = await stage(tester, size: board, location: '/classroom/board/');
    await tester.pumpWidget(const SizedBox.shrink());
    final live = await stage(
      tester,
      size: board,
      location: '/classroom/board/${s.code}',
    );
    final seats = [
      for (final n in ['Amina', 'Yusuf', 'Sara', 'Bilal', 'Maryam', 'Idris'])
        await live.room.join(code: live.code, nickname: n),
    ];
    // Deux cartes jouées, pour que les couloirs aient bougé.
    for (var q = 0; q < 2; q++) {
      live.room.ask(live.code);
      for (var i = 0; i < seats.length; i++) {
        await live.room.answer(
          code: live.code,
          token: seats[i].token,
          questionIndex: q,
          choice: (i + q) % 3 == 0 ? 2 : 0,
        );
      }
      if (q == 0) live.room.reveal(live.code);
    }
    live.room.reveal(live.code);
    await settle(tester);
    await capture(tester, 'classe-3-reponse');
  });

  testWidgets('4 — le téléphone de l\'élève : la carte et ses réponses', (
    tester,
  ) async {
    final s = await stage(tester, size: phone, location: '/classroom');
    await tester.enterText(find.byKey(const Key('classroom-code')), s.code);
    await tester.enterText(
      find.byKey(const Key('classroom-nickname')),
      'Amina',
    );
    await settle(tester);
    await tester.tap(find.byKey(const Key('classroom-join')));
    await settle(tester);
    s.room.ask(s.code);
    await settle(tester);
    await capture(tester, 'classe-4-eleve');

    await tester.tap(find.byKey(const Key('classroom-answer-1')));
    await settle(tester);
    await capture(tester, 'classe-5-eleve-a-repondu');

    s.room.reveal(s.code);
    await settle(tester);
    await capture(tester, 'classe-6-eleve-reponse');
  });

  testWidgets('7 — la fin : podium et cartes à revoir', (tester) async {
    final s = await stage(tester, size: board, location: '/classroom/board/');
    await tester.pumpWidget(const SizedBox.shrink());
    final live = await stage(
      tester,
      size: board,
      location: '/classroom/board/${s.code}',
    );
    final seats = [
      for (final n in ['Amina', 'Yusuf', 'Sara', 'Bilal', 'Maryam', 'Idris'])
        await live.room.join(code: live.code, nickname: n),
    ];
    for (var q = 0; q < live.bank.length; q++) {
      live.room.ask(live.code);
      for (var i = 0; i < seats.length; i++) {
        await live.room.answer(
          code: live.code,
          token: seats[i].token,
          questionIndex: q,
          choice: (i + q) % 3 == 0 ? 1 : 0,
        );
      }
      live.room.reveal(live.code);
    }
    live.room.ask(live.code);
    await settle(tester);
    await capture(tester, 'classe-7-fin');
  });

  testWidgets('8 — le mode individuel : chaque prénom classé', (tester) async {
    final s = await stage(
      tester,
      size: board,
      location: '/classroom/board/',
      scoring: ClassroomScoring.individual,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    final live = await stage(
      tester,
      size: board,
      location: '/classroom/board/${s.code}',
      scoring: ClassroomScoring.individual,
    );
    final seats = [
      for (final n in ['Amina', 'Yusuf', 'Sara', 'Bilal', 'Maryam'])
        await live.room.join(code: live.code, nickname: n),
    ];
    for (var q = 0; q < 2; q++) {
      live.room.ask(live.code);
      for (var i = 0; i < seats.length; i++) {
        await live.room.answer(
          code: live.code,
          token: seats[i].token,
          questionIndex: q,
          choice: i <= q + 1 ? 0 : 3,
        );
      }
      if (q == 0) live.room.reveal(live.code);
    }
    await settle(tester);
    await capture(tester, 'classe-8-classement-individuel');
  });

  testWidgets('9 — la console de l\'enseignant', (tester) async {
    tester.view.physicalSize = const Size(900, 1150);
    tester.view.devicePixelRatio = 1.0;
    SharedPreferences.setMockInitialValues({});
    rootBundle.clear();
    final storage = await LocalStorageService.create();
    final room = FakeClassroomGateway(random: Random(23));
    final console = FakeTeacherGateway(
      room: room,
      signedInAs: 'direction@ecole-annour.fr',
      licence: Licence(
        id: 'l1',
        email: 'direction@ecole-annour.fr',
        plan: 'ecole',
        concurrentSessions: 3,
        expiresAt: DateTime(2027, 8, 31),
        schoolName: 'École An-Nour',
      ),
    );
    final repository = QuestionRepository();
    final bank = await tester.runAsync(() => repository.loadAll('fr'));

    await tester.pumpWidget(
      RepaintBoundary(
        child: ProviderScope(
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
            initialSettingsProvider.overrideWithValue(
              const AppSettings(languageCode: 'fr'),
            ),
            initialPremiumProvider.overrideWithValue(false),
            appRouterProvider.overrideWithValue(
              GoRouter(
                initialLocation: '/teacher',
                routes: [
                  GoRoute(
                    path: '/teacher',
                    builder: (c, s) =>
                        const TeacherConsoleScreen(fragment: ''),
                  ),
                ],
              ),
            ),
          ],
          child: const IqraQuestApp(),
        ),
      ),
    );
    await settle(tester, 14);
    await capture(tester, 'classe-9-console');

    await tester.tap(find.byKey(const Key('teacher-open')));
    await settle(tester);

    // La console pendant la leçon, pas dans le vestibule : c'est là que
    // l'enseignant lit où il en est sans se retourner vers le tableau.
    final code = tester
        .widget<Text>(find.byKey(const Key('teacher-code')))
        .data!;
    final seats = [
      for (final n in ['Amina', 'Yusuf', 'Sara', 'Bilal', 'Maryam'])
        await room.join(code: code, nickname: n),
    ];
    room.ask(code);
    for (var i = 0; i < 3; i++) {
      await room.answer(
        code: code,
        token: seats[i].token,
        questionIndex: 0,
        choice: i == 2 ? 2 : 0,
      );
    }
    await settle(tester);
    await capture(tester, 'classe-10-console-en-seance');
  });

  testWidgets('11 — la connexion, et l\'abonnement fini', (tester) async {
    tester.view.physicalSize = const Size(900, 1150);
    tester.view.devicePixelRatio = 1.0;
    SharedPreferences.setMockInitialValues({});
    rootBundle.clear();
    final storage = await LocalStorageService.create();
    final room = FakeClassroomGateway(random: Random(31));

    Future<void> pump(FakeTeacherGateway console) async {
      final repository = QuestionRepository();
      final bank = await tester.runAsync(() => repository.loadAll('fr'));
      await tester.pumpWidget(
        RepaintBoundary(
          child: ProviderScope(
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
              initialSettingsProvider.overrideWithValue(
                const AppSettings(languageCode: 'fr'),
              ),
              initialPremiumProvider.overrideWithValue(false),
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
        ),
      );
      await settle(tester, 14);
    }

    // Personne n'est entré : l'adresse, le mot de passe, et le chemin de
    // secours en dessous.
    await pump(FakeTeacherGateway(room: room));
    await tester.enterText(
      find.byKey(const Key('teacher-email')),
      'direction@ecole-annour.fr',
    );
    await tester.enterText(
      find.byKey(const Key('teacher-password')),
      'un-mot-de-passe',
    );
    await settle(tester);
    await capture(tester, 'classe-11-connexion');

    // L'abonnement est fini : l'école garde son espace et son historique,
    // et ne peut plus ouvrir de séance.
    await tester.pumpWidget(const SizedBox.shrink());
    final code = room.openSession(
      lessonId: 'lesson_prophets_beginner_01',
      questionIds: const ['q1', 'q2', 'q3'],
      scoring: ClassroomScoring.individual,
    );
    final seats = [
      for (final n in ['Amina', 'Yusuf', 'Sara'])
        await room.join(code: code, nickname: n),
    ];
    for (var q = 0; q < 3; q++) {
      room.ask(code);
      for (var i = 0; i < seats.length; i++) {
        await room.answer(
          code: code,
          token: seats[i].token,
          questionIndex: q,
          choice: i <= q ? 0 : 2,
        );
      }
      room.reveal(code);
    }
    room.close(code);

    await pump(
      FakeTeacherGateway(
        room: room,
        signedInAs: 'direction@ecole-annour.fr',
        licence: Licence(
          id: 'l1',
          email: 'direction@ecole-annour.fr',
          plan: 'École — 3 salles',
          concurrentSessions: 3,
          expiresAt: DateTime(2026, 8, 31),
          schoolName: 'École An-Nour',
        ),
      ),
    );
    await capture(tester, 'classe-12-abonnement-fini');

    await tester.tap(find.byKey(const Key('teacher-history-open')));
    await settle(tester);
    await capture(tester, 'classe-13-historique-et-notes');
  });
}
