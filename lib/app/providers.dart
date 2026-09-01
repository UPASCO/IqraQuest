import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/game/domain/game_engine.dart';
import '../services/daily_challenge_service.dart';
import '../services/entitlement_service.dart';
import '../services/game_save_service.dart';
import '../services/legacy_game_migration_service.dart';
import '../services/progress_service.dart';
import '../services/purchase_service.dart';
import '../services/question_repository.dart';
import '../services/settings_service.dart';
import '../services/sound_service.dart';

/// Service instances are constructed once in `main()` (they need an
/// `await`) and injected here via `ProviderScope(overrides: ...)`. Every
/// provider below throws until it is overridden at app start —
/// see `lib/main.dart`.
final settingsServiceProvider = Provider<SettingsService>(
  (ref) => throw UnimplementedError('Override in main()'),
);
final entitlementServiceProvider = Provider<EntitlementService>(
  (ref) => throw UnimplementedError('Override in main()'),
);
final progressServiceProvider = Provider<ProgressService>(
  (ref) => throw UnimplementedError('Override in main()'),
);
final gameSaveServiceProvider = Provider<GameSaveService>(
  (ref) => throw UnimplementedError('Override in main()'),
);
final legacyGameMigrationServiceProvider = Provider<LegacyGameMigrationService>(
  (ref) => throw UnimplementedError('Override in main()'),
);
final questionRepositoryProvider = Provider<QuestionRepository>(
  (ref) => throw UnimplementedError('Override in main()'),
);
final purchaseServiceProvider = Provider<PurchaseService>(
  (ref) => throw UnimplementedError('Override in main()'),
);
final dailyChallengeServiceProvider = Provider<DailyChallengeService>(
  (ref) => const DailyChallengeService(),
);
final gameEngineProvider = Provider<GameEngine>((ref) => GameEngine());

/// Loaded once at bootstrap in `main()` and pushed into
/// [settingsControllerProvider] / [premiumControllerProvider] as the
/// initial state — see `lib/main.dart`.
final initialSettingsProvider = Provider<AppSettings>(
  (ref) => throw UnimplementedError('Override in main()'),
);
final initialPremiumProvider = Provider<bool>(
  (ref) => throw UnimplementedError('Override in main()'),
);

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._service, AppSettings initial) : super(initial);

  final SettingsService _service;

  Future<void> update(AppSettings Function(AppSettings) updater) async {
    state = updater(state);
    await _service.save(state);
  }

  Future<void> setLanguage(String code) => update((s) => s.copyWith(languageCode: code));
  Future<void> setThemeMode(ThemeMode mode) => update((s) => s.copyWith(themeMode: mode));
  Future<void> setReduceMotion(bool value) => update((s) => s.copyWith(reduceMotion: value));
  Future<void> setSoundEnabled(bool value) => update((s) => s.copyWith(soundEnabled: value));
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, AppSettings>(
  (ref) =>
      SettingsController(ref.watch(settingsServiceProvider), ref.watch(initialSettingsProvider)),
);

/// One app-wide SFX player, kept in sync with the sound setting.
final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  service.enabled = ref.read(settingsControllerProvider).soundEnabled;
  ref.listen<AppSettings>(
    settingsControllerProvider,
    (_, s) => service.enabled = s.soundEnabled,
  );
  ref.onDispose(service.dispose);
  return service;
});

class PremiumController extends StateNotifier<bool> {
  PremiumController(this._entitlements, bool initial) : super(initial);

  final EntitlementService _entitlements;

  Future<void> grant() async {
    await _entitlements.grantPremium();
    state = true;
  }

  Future<void> revoke() async {
    await _entitlements.revokePremium();
    state = false;
  }
}

final premiumControllerProvider = StateNotifierProvider<PremiumController, bool>(
  (ref) =>
      PremiumController(ref.watch(entitlementServiceProvider), ref.watch(initialPremiumProvider)),
);

/// The effective UI language: explicit user choice, else the device
/// locale if supported, else English.
final effectiveLanguageProvider = Provider<String>((ref) {
  final chosen = ref.watch(settingsControllerProvider).languageCode;
  if (chosen != null) return chosen;
  const supported = {'fr', 'en', 'ar', 'es', 'pt', 'de', 'tr', 'id', 'ur', 'ms', 'it', 'nl'};
  // A malformed platform locale must never crash startup (spec §64/§84
  // philosophy: never crash on locale issues) — fall back to English.
  try {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return supported.contains(deviceLocale.languageCode) ? deviceLocale.languageCode : 'en';
  } catch (_) {
    return 'en';
  }
});

final questionPoolProvider = FutureProvider.autoDispose((ref) async {
  final lang = ref.watch(effectiveLanguageProvider);
  final repo = ref.watch(questionRepositoryProvider);
  return repo.loadAll(lang);
});
