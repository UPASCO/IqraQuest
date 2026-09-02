import '../models/game_state.dart';
import 'local_storage_service.dart';

/// Persists the in-progress game so it survives closing the app,
/// backgrounding, or a device reboot (spec §80–§83).
class GameSaveService {
  GameSaveService(this._storage);

  static const _key = 'iqraquest.save.currentGame.v1';
  final LocalStorageService _storage;

  Future<void> save(GameState state) => _storage.setJson(_key, state.toJson());

  /// Returns null both when there is no save and when the save cannot be
  /// parsed — the caller must never crash on either (spec §83). An
  /// unreadable save is NEVER deleted here: it may be a legacy-format
  /// game that LegacyGameMigrationService still needs to archive
  /// (spec §18 — user data is moved aside, not destroyed).
  GameState? load() {
    final json = _storage.getJson(_key);
    if (json == null) return null;
    try {
      return GameState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  bool get hasSave => _storage.getJson(_key) != null;

  /// The schema version the current save was written with, or null
  /// when there is no readable save. The loader uses it to tell a save
  /// from an earlier turn order apart from one of its own.
  int? savedSchemaVersion() {
    final json = _storage.getJson(_key);
    if (json == null) return null;
    try {
      return GameState.schemaVersionOf(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() => _storage.remove(_key);
}
