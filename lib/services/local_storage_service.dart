import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin, structured wrapper over [SharedPreferences] — IqraQuest's only
/// persistence mechanism besides [flutter_secure_storage] for the
/// Premium entitlement (spec §31: no backend, everything local).
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStorageService> create() async {
    return LocalStorageService(await SharedPreferences.getInstance());
  }

  Future<void> setJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  Map<String, dynamic>? getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      // A corrupted save must never crash the app (spec §83) — treat it
      // as absent and let the caller fall back to a clean state.
      return null;
    }
  }

  Future<void> remove(String key) => _prefs.remove(key);

  Future<void> setString(String key, String value) => _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);
}
