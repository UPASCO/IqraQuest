import 'package:flutter/material.dart';

import 'local_storage_service.dart';

class AppSettings {
  const AppSettings({
    this.languageCode,
    this.themeMode = ThemeMode.system,
    this.reduceMotion = false,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.dailyChallengeNotifications = false,
  });

  /// null = follow system locale (falls back to English if unsupported).
  final String? languageCode;
  final ThemeMode themeMode;
  final bool reduceMotion;
  final bool soundEnabled;

  /// The little buzzes of the board (a horse picked up, set down, a
  /// bonus fired). Off, the board stays silent to the hand.
  final bool hapticsEnabled;
  final bool dailyChallengeNotifications;

  AppSettings copyWith({
    String? languageCode,
    ThemeMode? themeMode,
    bool? reduceMotion,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? dailyChallengeNotifications,
  }) => AppSettings(
    languageCode: languageCode ?? this.languageCode,
    themeMode: themeMode ?? this.themeMode,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    dailyChallengeNotifications: dailyChallengeNotifications ?? this.dailyChallengeNotifications,
  );
}

/// Local-only user preferences (spec §84: no account, nothing leaves the
/// device).
class SettingsService {
  SettingsService(this._storage);

  final LocalStorageService _storage;

  static const _langKey = 'iqraquest.settings.language';
  static const _themeKey = 'iqraquest.settings.themeMode';
  static const _reduceMotionKey = 'iqraquest.settings.reduceMotion';
  static const _soundKey = 'iqraquest.settings.sound';
  static const _hapticsKey = 'iqraquest.settings.haptics';
  static const _notifKey = 'iqraquest.settings.dailyNotifications';

  AppSettings load() {
    return AppSettings(
      languageCode: _storage.getString(_langKey),
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == (_storage.getString(_themeKey) ?? 'system'),
        orElse: () => ThemeMode.system,
      ),
      reduceMotion: _storage.getBool(_reduceMotionKey) ?? false,
      soundEnabled: _storage.getBool(_soundKey) ?? true,
      hapticsEnabled: _storage.getBool(_hapticsKey) ?? true,
      dailyChallengeNotifications: _storage.getBool(_notifKey) ?? false,
    );
  }

  Future<void> save(AppSettings settings) async {
    if (settings.languageCode != null) {
      await _storage.setString(_langKey, settings.languageCode!);
    }
    await _storage.setString(_themeKey, settings.themeMode.name);
    await _storage.setBool(_reduceMotionKey, settings.reduceMotion);
    await _storage.setBool(_soundKey, settings.soundEnabled);
    await _storage.setBool(_hapticsKey, settings.hapticsEnabled);
    await _storage.setBool(_notifKey, settings.dailyChallengeNotifications);
  }
}
