import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'features/classroom/application/classroom_controller.dart';
import 'features/classroom/data/classroom_config.dart';
import 'features/classroom/data/classroom_gateway.dart';
import 'features/classroom/data/fake_classroom_gateway.dart';
import 'features/classroom/data/fake_teacher_gateway.dart';
import 'features/classroom/data/supabase_classroom_gateway.dart';
import 'features/classroom/data/supabase_teacher_gateway.dart';
import 'features/classroom/data/teacher_gateway.dart';
import 'features/classroom/application/teacher_console_controller.dart';
import 'app/build_flags.dart';
import 'app/router.dart';
import 'services/entitlement_service.dart';
import 'services/game_save_service.dart';
import 'services/legacy_game_migration_service.dart';
import 'services/local_storage_service.dart';
import 'services/progress_service.dart';
import 'services/purchase_service.dart';
import 'services/question_repository.dart';
import 'services/settings_service.dart';

const _onboardingCompleteKey = 'iqraquest.onboarding.complete';

/// The classroom's line to the outside.
///
/// With a Supabase project compiled in (`--dart-define=SUPABASE_URL=...`,
/// see server/README.md) this is the real room. Without one it is an
/// empty room in memory: the screen still opens and says honestly that
/// no class can be reached, rather than hiding a feature that is coming.
ClassroomGateway _classroomGateway() => ClassroomConfig.isConfigured
    ? SupabaseClassroomGateway(
        url: ClassroomConfig.url,
        anonKey: ClassroomConfig.anonKey,
      )
    : FakeClassroomGateway();

/// The teacher's console, on the same line as the room.
///
/// With no Supabase project compiled in it drives the very room the
/// pupils' fake talks to, and hands out a day's trial licence — so a
/// build with no server can still be walked from end to end. With one,
/// it is the real console and this branch is never taken.
TeacherGateway _teacherGateway(
  ClassroomGateway classroom,
  LocalStorageService storage,
) {
  if (ClassroomConfig.isConfigured) {
    return SupabaseTeacherGateway(
      url: ClassroomConfig.url,
      anonKey: ClassroomConfig.anonKey,
      storage: storage,
      redirectTo: ClassroomConfig.consoleCallbackUrl.isEmpty
          ? null
          : ClassroomConfig.consoleCallbackUrl,
    );
  }
  return FakeTeacherGateway(
    room: classroom as FakeClassroomGateway,
    signInOnSend: true,
    licence: Licence(
      id: 'demo',
      email: 'demo@iqraquest',
      plan: 'essai',
      concurrentSessions: 1,
      expiresAt: DateTime.now().add(const Duration(days: 1)),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A phone stays portrait: the board is composed for it, and landscape
  // on a 320-point screen would crop the track and the camps out of the
  // cover-fitted scene. A tablet is a different object — it gets put
  // down on a table, and a table has no "up" — so it may be turned, and
  // every screen is laid out to hold its composition either way.
  //
  // The shortest side is the honest test: it does not change with
  // rotation, so the app cannot change its mind mid-turn.
  final view = WidgetsBinding.instance.platformDispatcher.implicitView;
  final logicalSize = view == null
      ? null
      : view.physicalSize / view.devicePixelRatio;
  final isTablet = (logicalSize?.shortestSide ?? 0) >= 600;
  await SystemChrome.setPreferredOrientations(
    isTablet
        ? const [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
        : const [DeviceOrientation.portraitUp],
  );

  final storage = await LocalStorageService.create();
  final settingsService = SettingsService(storage);
  final entitlementService = EntitlementService();
  final progressService = ProgressService(storage);
  final saveService = GameSaveService(storage);
  final legacyMigration = LegacyGameMigrationService(storage);
  final questionRepository = QuestionRepository();
  final purchaseService = PurchaseService();

  // Best-effort: the Store may be unavailable (no network, emulator
  // without Play Services, etc). Purchases still work once it becomes
  // reachable; Premium already granted stays available offline
  // regardless (spec §78).
  unawaited(purchaseService.initialize());

  final isPremium = await entitlementService.isPremium();
  final settings = settingsService.load();
  final hasOnboarded = storage.getBool(_onboardingCompleteKey) ?? false;

  final classroomGateway = _classroomGateway();

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
        classroomGatewayProvider.overrideWithValue(classroomGateway),
        teacherGatewayProvider.overrideWithValue(
          _teacherGateway(classroomGateway, storage),
        ),
        settingsServiceProvider.overrideWithValue(settingsService),
        entitlementServiceProvider.overrideWithValue(entitlementService),
        progressServiceProvider.overrideWithValue(progressService),
        gameSaveServiceProvider.overrideWithValue(saveService),
        legacyGameMigrationServiceProvider.overrideWithValue(legacyMigration),
        questionRepositoryProvider.overrideWithValue(questionRepository),
        purchaseServiceProvider.overrideWithValue(purchaseService),
        initialSettingsProvider.overrideWithValue(settings),
        initialPremiumProvider.overrideWithValue(isPremium),
        appRouterProvider.overrideWithValue(
          buildAppRouter(
            // Le binaire d'école ouvre sur la console : `/home` n'y
            // existe pas, et démarrer sur une route absente laisserait
            // une page blanche à la première école qui vient.
            initialLocation: kSchoolBuild
                ? '/teacher'
                : (hasOnboarded ? '/home' : '/onboarding'),
          ),
        ),
      ],
      child: const IqraQuestApp(),
    ),
  );
}
