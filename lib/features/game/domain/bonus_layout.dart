import 'dart:math';

import '../../../models/bonus_tile.dart';
import '../../../models/circuit.dart';

/// Board generation: where the sixteen bonus squares of a game go.
///
/// Random, but not naive. The circuit is four quadrants, and every game
/// gets **exactly four bonus squares per quadrant**, so no corner of the
/// table starts advantaged. The values are dealt as four quadrant kits
/// that all add up to the same total (+35), shuffled across the
/// quadrants:
///
/// | kit          | sum |
/// |--------------|-----|
/// | 5, 5, 5, 20  | 35  |
/// | 5, 5, 5, 20  | 35  |
/// | 5, 10, 10, 10| 35  |
/// | 5, 10, 10, 10| 35  |
///
/// That makes +5 frequent (8 of 16), +10 intermediate (6) and +20 rare
/// (2) — and the two +20 always sit in *opposite* quadrants, so the big
/// jumps are never next to each other. Inside a quadrant, bonus squares
/// are never adjacent (a gap of at least one square, across quadrant
/// borders too), never on a square that already has an effect (an oasis,
/// a knowledge chest…) and never on a team's start square.
///
/// Everything comes from one [seed], so a layout can be replayed,
/// tested and reproduced from a bug report.
class BonusLayout {
  const BonusLayout._();

  static const int tilesPerQuadrant = 4;
  static const int tileCount = 16;

  /// The four value kits, every one worth the same +35.
  static const List<List<int>> _kits = [
    [5, 5, 5, 20],
    [5, 5, 5, 20],
    [5, 10, 10, 10],
    [5, 10, 10, 10],
  ];

  /// The bonus squares of a game, sorted by track index.
  static List<BonusTile> generate(Circuit circuit, int seed) {
    final random = Random(seed);
    final n = circuit.squaresPerQuadrant;

    // The two +20 kits go to opposite quadrants: (0, 2) or (1, 3).
    final bigPair = random.nextBool() ? const [0, 2] : const [1, 3];
    final smallPair = bigPair[0] == 0 ? const [1, 3] : const [0, 2];
    final kitByQuadrant = <int, List<int>>{
      bigPair[0]: [..._kits[0]],
      bigPair[1]: [..._kits[1]],
      smallPair[0]: [..._kits[2]],
      smallPair[1]: [..._kits[3]],
    };

    // Squares a bonus may sit on: plain ones, away from every team's
    // start square (offset 0) and, to keep the gap across the border,
    // away from the quadrant's last square too when the next quadrant
    // starts with a bonus — handled by the adjacency check below.
    final eligible = <int>[
      for (var offset = 1; offset < n; offset++)
        if (circuit.quadrantEffects[offset] == null) offset,
    ];

    final tiles = <BonusTile>[];
    for (var q = 0; q < 4; q++) {
      final base = q * n;
      final chosen = _pickSpread(eligible, tilesPerQuadrant, random);
      final values = [...kitByQuadrant[q]!]..shuffle(random);
      for (var i = 0; i < chosen.length; i++) {
        tiles.add(BonusTile(trackIndex: base + chosen[i], value: values[i]));
      }
    }
    tiles.sort((a, b) => a.trackIndex.compareTo(b.trackIndex));
    return tiles;
  }

  /// [count] offsets out of [candidates], no two adjacent, spread along
  /// the quadrant rather than bunched: the quadrant is cut into [count]
  /// bands and one square is drawn from each band, then the draw is
  /// retried while any pair touches.
  static List<int> _pickSpread(List<int> candidates, int count, Random random) {
    final sorted = [...candidates]..sort();
    final bandSize = sorted.length / count;
    for (var attempt = 0; attempt < 64; attempt++) {
      final picked = <int>[];
      for (var b = 0; b < count; b++) {
        final start = (b * bandSize).floor();
        final end = ((b + 1) * bandSize).floor().clamp(start + 1, sorted.length);
        picked.add(sorted[start + random.nextInt(end - start)]);
      }
      picked.sort();
      var touching = false;
      for (var i = 1; i < picked.length; i++) {
        if (picked[i] - picked[i - 1] < 2) touching = true;
      }
      // Start squares (offset 0) are never eligible, so the last square
      // of one quadrant and the first bonus of the next are always at
      // least two apart: the gap holds across the border by construction.
      if (!touching) return picked;
    }
    // Deterministic fallback: every other eligible square.
    return [for (var i = 0; i < count; i++) sorted[(i * 2).clamp(0, sorted.length - 1)]];
  }

  /// A seed for a new game, derived from its id so the layout is fixed the
  /// moment the game exists — and reproducible from the save alone.
  static int seedFor(String gameId) {
    var h = 0x811C9DC5;
    for (final unit in gameId.codeUnits) {
      h ^= unit;
      h = (h * 0x01000193) & 0x7FFFFFFF;
    }
    return h;
  }
}
