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
import 'features/classroom/data/supabase_classroom_gateway.dart';
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

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
        classroomGatewayProvider.overrideWithValue(_classroomGateway()),
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
          buildAppRouter(initialLocation: hasOnboarded ? '/home' : '/onboarding'),
        ),
      ],
      child: const IqraQuestApp(),
    ),
  );
}
