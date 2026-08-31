import 'dart:math' as math;
import 'dart:ui';

import '../../models/circuit.dart';
import '../../models/pawn_position.dart';

/// Computes screen-space geometry for one [Circuit] — the presentation
/// layer's only bridge from engine indices to pixels. The engine itself
/// never sees coordinates.
///
/// The track is deliberately NOT a rounded rectangle: it is an organic
/// loop that meanders like a trail worn through country. The moment the
/// loop reads as a geometric board shape, the world collapses back into
/// "a game board placed on sand".
class BoardLayout {
  BoardLayout(this.size, this.circuit)
    : center = Offset(size.width / 2, size.height / 2),
      trackPath = _organicLoop(size) {
    _trackPoints = _samplePath(trackPath, circuit.trackLength);
    _campCenters = List.generate(4, (t) {
      final entry = _trackPoints[circuit.entryIndexForTeam(t) % circuit.trackLength];
      final out = entry - center;
      final len = out.distance == 0 ? 1 : out.distance;
      return entry + out * (size.shortestSide * 0.118 / len);
    });
    _finalLanePoints = {for (var t = 0; t < 4; t++) t: _computeFinalLane(t)};
    _homeSlots = {for (var t = 0; t < 4; t++) t: _computeHomeSlots(t)};
  }

  final Size size;
  final Circuit circuit;
  final Offset center;

  /// The meandering loop itself, for the route painter.
  final Path trackPath;

  late final List<Offset> _trackPoints;
  late final List<Offset> _campCenters;
  late final Map<int, List<Offset>> _finalLanePoints;
  late final Map<int, List<Offset>> _homeSlots;

  Offset trackPoint(int index) => _trackPoints[index % circuit.trackLength];

  Offset finalLanePoint(int teamIndex, int step) => _finalLanePoints[teamIndex]![step - 1];

  Offset finishPoint(int teamIndex) => _finalLanePoints[teamIndex]!.last;

  /// Where this team's caravan camp sits: just off the trail, at its own
  /// entry — part of the journey, not a corner of a board.
  Offset campCenter(int teamIndex) => _campCenters[teamIndex];

  Offset homeSlot(int teamIndex, int horseIndex) => _homeSlots[teamIndex]![horseIndex % 4];

  Offset pointFor(int teamIndex, PawnPosition position) => switch (position) {
    HomePosition() => homeSlot(teamIndex, 0),
    TrackPosition(:final index) => trackPoint(index),
    FinalLanePosition(:final step) => finalLanePoint(teamIndex, step),
    FinishedPosition() => finishPoint(teamIndex),
  };

  /// A closed loop whose radius breathes around the circle — two low
  /// harmonics give a hand-worn trail, never a recognizable geometric
  /// primitive.
  static Path _organicLoop(Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final base = size.shortestSide * 0.385;
    const n = 96;
    final pts = <Offset>[];
    for (var i = 0; i < n; i++) {
      final th = math.pi * 2 * i / n;
      final r = base * (1 + 0.085 * math.sin(2 * th + 0.9) + 0.05 * math.sin(3 * th + 2.6));
      pts.add(c + Offset(math.cos(th) * r, math.sin(th) * r * 0.98));
    }
    final path = Path();
    // Smooth through midpoints so the trail has no corners at all.
    Offset mid(Offset a, Offset b) => Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    path.moveTo(mid(pts[0], pts[1]).dx, mid(pts[0], pts[1]).dy);
    for (var i = 1; i <= n; i++) {
      final p = pts[i % n];
      final m = mid(p, pts[(i + 1) % n]);
      path.quadraticBezierTo(p.dx, p.dy, m.dx, m.dy);
    }
    path.close();
    return path;
  }

  static List<Offset> _samplePath(Path path, int n) {
    final metric = path.computeMetrics().first;
    return [
      for (var i = 0; i < n; i++) metric.getTangentForOffset(metric.length * i / n)!.position,
    ];
  }

  List<Offset> _computeFinalLane(int teamIndex) {
    final entry = circuit.entryIndexForTeam(teamIndex);
    // The square just before this team's entry is where its final lane
    // branches off the shared track, heading inward to the shared center.
    final exitIndex = (entry - 1 + circuit.trackLength) % circuit.trackLength;
    final branch = _trackPoints[exitIndex];
    // The lane bows sideways on its way in, so the four approaches meet
    // the centre as worn riding arcs rather than a straight X.
    final normal = Offset(-(center.dy - branch.dy), center.dx - branch.dx);
    final points = <Offset>[];
    for (var step = 1; step <= circuit.finalLaneLength; step++) {
      final t = step / (circuit.finalLaneLength + 1);
      final straight = Offset.lerp(branch, center, t)!;
      points.add(straight + normal * (0.115 * math.sin(t * math.pi)));
    }
    // Slightly fan out each team's finish mark so 4 finishes don't overlap.
    final angle = teamIndex * (math.pi / 2);
    final fanned = Offset(center.dx + 10 * math.cos(angle), center.dy + 10 * math.sin(angle));
    points.add(fanned);
    return points;
  }

  List<Offset> _computeHomeSlots(int teamIndex) {
    final base = _campCenters[teamIndex];
    final s = size.shortestSide * 0.052;
    return [
      base + Offset(-s * 0.6, -s * 0.4),
      base + Offset(s * 0.6, -s * 0.4),
      base + Offset(-s * 0.6, s * 0.6),
      base + Offset(s * 0.6, s * 0.6),
    ];
  }
}
