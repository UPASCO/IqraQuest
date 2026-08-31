import '../models/game_state.dart';
import 'local_storage_service.dart';

/// What a stored save turns out to be.
enum SaveCompatibility {
  /// Nothing saved.
  none,

  /// Written by this version of the engine; safe to resume.
  current,

  /// Written by the old dice-based engine. The race rules changed, so the
  /// in-progress game cannot be resumed faithfully — but it is never
  /// silently thrown away (spec §18).
  legacy,
}

/// Detects saves written before the dice was replaced by the gait system,
/// and handles them without ever destroying user data.
///
/// Progress, statistics, badges, preferences, collected facts and the
/// Premium entitlement all live under *separate* storage keys and are not
/// touched by this: only the single in-progress-game blob can be
/// format-incompatible.
class LegacyGameMigrationService {
  LegacyGameMigrationService(this._storage);

  static const _saveKey = 'iqraquest.save.currentGame.v1';
  static const _archiveKey = 'iqraquest.save.legacyGame.archive';
  static const _noticeKey = 'iqraquest.migration.raceRulesNoticeSeen';

  final LocalStorageService _storage;

  SaveCompatibility inspect() {
    final json = _storage.getJson(_saveKey);
    if (json == null) return SaveCompatibility.none;

    final version = json['schemaVersion'] as int?;
    if (version != null && version >= GameState.schemaVersion) {
      return SaveCompatibility.current;
    }
    // Version 1 had no schemaVersion field and carried dice state.
    return SaveCompatibility.legacy;
  }

  /// Moves an unreadable legacy save aside instead of deleting it, so the
  /// user's data is preserved even though the game cannot resume from it.
  Future<void> archiveLegacySave() async {
    final json = _storage.getJson(_saveKey);
    if (json == null) return;
    await _storage.setJson(_archiveKey, {
      'archivedAt': DateTime.now().toIso8601String(),
      'reason': 'raceRulesUpdated',
      'save': json,
    });
    await _storage.remove(_saveKey);
  }

  /// The "the race rules have been improved" explanation is shown exactly
  /// once (spec §18).
  bool get hasSeenRaceRulesNotice => _storage.getBool(_noticeKey) ?? false;

  Future<void> markRaceRulesNoticeSeen() => _storage.setBool(_noticeKey, true);
}
