import 'dart:math' as math;

import '../models/models.dart';
import 'local_storage_service.dart';

/// One game kept under a name the table chose.
///
/// The entry carries what the list of saves shows — the name, when it
/// was kept, who was riding, how far along the journey is — so the
/// sheet never has to decode every game to draw a row. The game itself
/// lives under its own key ([NamedGameSaveService.load]).
class NamedGameSave {
  const NamedGameSave({
    required this.id,
    required this.name,
    required this.savedAt,
    required this.gameId,
    required this.gameUpdatedAt,
    required this.schemaVersion,
    required this.mode,
    required this.variant,
    required this.circuitId,
    required this.riderNames,
    required this.progress,
    required this.drawCount,
  });

  final String id;
  final String name;
  final DateTime savedAt;

  /// Which game this is, and how far it had got when it was kept. The
  /// pair tells whether a game in progress is already on the shelf
  /// exactly as it stands — the one case where replacing it loses
  /// nothing ([NamedGameSaveService.holds]).
  final String gameId;
  final DateTime gameUpdatedAt;

  /// The save format the game was written with; the loader rejoins an
  /// older one at the deck rather than mid-turn.
  final int schemaVersion;

  final GameMode mode;
  final GameVariant variant;
  final CircuitId circuitId;

  /// Every rider at the table, in seat order, the computer's included.
  final List<String> riderNames;

  /// The furthest human horse along the journey, 0 to 1.
  final double progress;

  final int drawCount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'savedAt': savedAt.toIso8601String(),
    'gameId': gameId,
    'gameUpdatedAt': gameUpdatedAt.toIso8601String(),
    'schemaVersion': schemaVersion,
    'mode': mode.name,
    'variant': variant.name,
    'circuitId': circuitId.name,
    'riderNames': riderNames,
    'progress': progress,
    'drawCount': drawCount,
  };

  /// Null for an entry this version cannot read: one bad row must never
  /// hide the rest of the shelf, nor crash the screen that lists it.
  static NamedGameSave? fromJson(Map<String, dynamic> json) {
    try {
      return NamedGameSave(
        id: json['id'] as String,
        name: json['name'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
        gameId: json['gameId'] as String,
        gameUpdatedAt: DateTime.parse(json['gameUpdatedAt'] as String),
        schemaVersion: json['schemaVersion'] as int? ?? GameState.schemaVersion,
        mode: GameMode.values.byName(json['mode'] as String),
        variant: GameVariant.values.byName(json['variant'] as String),
        circuitId: CircuitId.values.byName(
          json['circuitId'] as String? ?? CircuitId.oasisRoute.name,
        ),
        riderNames: [
          for (final name in json['riderNames'] as List? ?? const [])
            name.toString(),
        ],
        progress: ((json['progress'] as num?) ?? 0).toDouble().clamp(0.0, 1.0),
        drawCount: json['drawCount'] as int? ?? 0,
      );
    } catch (_) {
      return null;
    }
  }
}

/// The shelf of games kept under a name, beside the one autosave slot.
///
/// The autosave follows whatever game is being played and is overwritten
/// by the next one; a named save stays until the table deletes it. It
/// is written from the board's menu and read back from the setup
/// screen's "Load" — the moment a table decides what to play.
///
/// Saving under a name that is already on the shelf replaces that save:
/// "Papa" kept on Tuesday and again on Wednesday is one game, not two.
/// Names are matched with case and spacing folded, because a child
/// retyping one will not match it exactly.
class NamedGameSaveService {
  NamedGameSaveService(this._storage, {math.Random? random})
    : _random = random ?? math.Random();

  /// Plenty for a family, and a bound on how much of the preferences
  /// store the shelf may take. Nothing is ever dropped to make room: a
  /// full shelf says so and lets the table choose what goes.
  static const int maxSaves = 20;

  static const _indexKey = 'iqraquest.saves.named.index.v1';
  static String _stateKey(String id) => 'iqraquest.saves.named.$id.v1';

  final LocalStorageService _storage;
  final math.Random _random;

  /// Every save on the shelf, the most recently kept first. Rows this
  /// version cannot read are skipped, never thrown.
  List<NamedGameSave> list() {
    final raw = _storage.getJson(_indexKey)?['saves'];
    if (raw is! List) return const [];
    final saves = <NamedGameSave>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      final save = NamedGameSave.fromJson(item);
      if (save != null) saves.add(save);
    }
    saves.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return saves;
  }

  bool get isFull => list().length >= maxSaves;

  /// Trims and collapses the spacing of a name; what is stored and shown.
  static String normalize(String name) =>
      name.trim().replaceAll(RegExp(r'\s+'), ' ');

  static String _fold(String name) => normalize(name).toLowerCase();

  /// The save kept under [name], if any — case and spacing aside.
  NamedGameSave? byName(String name) {
    final wanted = _fold(name);
    if (wanted.isEmpty) return null;
    for (final save in list()) {
      if (_fold(save.name) == wanted) return save;
    }
    return null;
  }

  /// The save this game was last kept under, if any.
  NamedGameSave? byGame(String gameId) {
    for (final save in list()) {
      if (save.gameId == gameId) return save;
    }
    return null;
  }

  /// Whether [state] is on the shelf exactly as it stands: same game,
  /// not a move further. Replacing such a game loses nothing.
  bool holds(GameState state) => list().any(
    (save) =>
        save.gameId == state.gameId &&
        save.gameUpdatedAt.isAtSameMomentAs(state.updatedAt),
  );

  /// Keeps [state] under [name], replacing the save already kept under
  /// that name. Null when the shelf is full and the name is new; an
  /// empty name is a programming error, the caller proposes one.
  Future<NamedGameSave?> save(GameState state, {required String name}) async {
    final clean = normalize(name);
    if (clean.isEmpty) throw ArgumentError.value(name, 'name', 'must not be blank');
    final saves = list();
    final existing = byName(clean);
    if (existing == null && saves.length >= maxSaves) return null;
    final id = existing?.id ?? _newId(saves);
    final entry = NamedGameSave(
      id: id,
      name: clean,
      savedAt: DateTime.now(),
      gameId: state.gameId,
      gameUpdatedAt: state.updatedAt,
      schemaVersion: GameState.schemaVersion,
      mode: state.gameMode,
      variant: state.gameVariant,
      circuitId: state.circuitId,
      riderNames: [for (final p in state.players) p.name],
      progress: journeyProgress(state),
      drawCount: state.drawCount,
    );
    // The game first, the index second: an index row without its game
    // is skipped on load, a game without its row is merely invisible.
    await _storage.setJson(_stateKey(id), state.toJson());
    await _writeIndex([entry, ...saves.where((s) => s.id != id)]);
    return entry;
  }

  /// The game kept under [id], or null when it is missing or unreadable
  /// — the caller says so, and never crashes on a save (spec §83).
  GameState? load(String id) {
    final json = _storage.getJson(_stateKey(id));
    if (json == null) return null;
    try {
      return GameState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> delete(String id) async {
    await _storage.remove(_stateKey(id));
    await _writeIndex(list().where((s) => s.id != id).toList());
  }

  Future<void> _writeIndex(List<NamedGameSave> saves) =>
      _storage.setJson(_indexKey, {'saves': [for (final s in saves) s.toJson()]});

  String _newId(List<NamedGameSave> taken) {
    final ids = {for (final s in taken) s.id};
    while (true) {
      final id =
          's_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(0xFFFF)}';
      if (!ids.contains(id)) return id;
    }
  }

  /// How far along the journey the table is: the furthest human horse,
  /// 0 to 1 — what the home screen's journey card shows as well.
  static double journeyProgress(GameState state) {
    final circuit = state.circuit;
    if (circuit.journeyLength <= 0) return 0;
    var best = 0;
    for (var t = 0; t < state.players.length; t++) {
      if (state.players[t].isAi) continue;
      for (final horse in state.players[t].horses) {
        best = math.max(best, circuit.progressOf(horse.position, t) ?? 0);
      }
    }
    return (best / circuit.journeyLength).clamp(0.0, 1.0);
  }
}
