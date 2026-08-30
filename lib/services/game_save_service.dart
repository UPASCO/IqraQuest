import '../models/game_state.dart';
import 'local_storage_service.dart';

/// Persists the in-progress game so it survives closing the app,
/// backgrounding, or a device reboot (spec §80–§83).
class GameSaveService {
  GameSaveService(this._storage);

  static const _key = 'iqraquest.save.currentGame.v1';
  final LocalStorageService _storage;

  Future<void> save(GameState state) => _storage.setJson(_key, state.toJson());

  /// Returns null both when there is no save and when the save is
  /// corrupted — the caller must never crash on either (spec §83); a
  /// corrupted save is simply discarded so the user can start fresh.
  GameState? load() {
    final json = _storage.getJson(_key);
    if (json == null) return null;
    try {
      return GameState.fromJson(json);
    } catch (_) {
      _storage.remove(_key);
      return null;
    }
  }

  bool get hasSave => _storage.getJson(_key) != null;

  Future<void> clear() => _storage.remove(_key);
}
