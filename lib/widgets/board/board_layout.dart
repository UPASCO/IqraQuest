import 'dart:math' as math;
import 'dart:ui';

import '../../models/pawn_position.dart';

/// Computes screen-space geometry for the board from a logical
/// [BoardGeometry] — the presentation layer's only bridge from engine
/// indices to pixels (spec §39: the engine itself never sees coordinates).
class BoardLayout {
  BoardLayout(this.size)
    : center = Offset(size.width / 2, size.height / 2),
      _trackPoints = _computeTrackPoints(size) {
    _finalLanePoints = {for (var t = 0; t < 4; t++) t: _computeFinalLane(t, size, center)};
    _homeSlots = {for (var t = 0; t < 4; t++) t: _computeHomeSlots(t, size)};
  }

  final Size size;
  final Offset center;
  final List<Offset> _trackPoints;
  late final Map<int, List<Offset>> _finalLanePoints;
  late final Map<int, List<Offset>> _homeSlots;

  Offset trackPoint(int index) => _trackPoints[index % BoardGeometry.trackLength];

  Offset finalLanePoint(int teamIndex, int step) => _finalLanePoints[teamIndex]![step - 1];

  Offset finishPoint(int teamIndex) => _finalLanePoints[teamIndex]!.last;

  Offset homeSlot(int teamIndex, int pawnIndex) => _homeSlots[teamIndex]![pawnIndex % 4];

  Offset pointFor(int teamIndex, PawnPosition position) => switch (position) {
    HomePosition() => homeSlot(teamIndex, 0),
    TrackPosition(:final index) => trackPoint(index),
    FinalLanePosition(:final step) => finalLanePoint(teamIndex, step),
    FinishedPosition() => finishPoint(teamIndex),
  };

  static List<Offset> _computeTrackPoints(Size size) {
    final margin = size.shortestSide * 0.09;
    final rect = Rect.fromLTWH(margin, margin, size.width - margin * 2, size.height - margin * 2);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.shortestSide * 0.16));
    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    final n = BoardGeometry.trackLength;
    final points = <Offset>[];
    for (var i = 0; i < n; i++) {
      final distance = metric.length * i / n;
      final tangent = metric.getTangentForOffset(distance)!;
      points.add(tangent.position);
    }
    return points;
  }

  static List<Offset> _computeFinalLane(int teamIndex, Size size, Offset center) {
    final entry = BoardGeometry.entryIndexForTeam(teamIndex);
    // The square just before this team's entry is where its final lane
    // branches off the shared track, heading inward to the shared center.
    final exitIndex = (entry - 1 + BoardGeometry.trackLength) % BoardGeometry.trackLength;
    final trackPoints = _computeTrackPoints(size);
    final branch = trackPoints[exitIndex];
    final points = <Offset>[];
    for (var step = 1; step <= BoardGeometry.finalLaneLength; step++) {
      final t = step / (BoardGeometry.finalLaneLength + 1);
      points.add(Offset.lerp(branch, center, t)!);
    }
    // Slightly fan out each team's finish mark so 4 finishes don't overlap.
    final angle = teamIndex * (math.pi / 2);
    final fanned = Offset(center.dx + 10 * math.cos(angle), center.dy + 10 * math.sin(angle));
    points.add(fanned);
    return points;
  }

  static List<Offset> _computeHomeSlots(int teamIndex, Size size) {
    final margin = size.shortestSide * 0.09;
    final stableSize = margin * 1.6;
    final positions = <Offset>[
      Offset(margin * 0.6, margin * 0.6),
      Offset(size.width - margin * 0.6, margin * 0.6),
      Offset(size.width - margin * 0.6, size.height - margin * 0.6),
      Offset(margin * 0.6, size.height - margin * 0.6),
    ];
    final base = positions[teamIndex];
    final offsets = [
      Offset(-stableSize * 0.3, -stableSize * 0.3),
      Offset(stableSize * 0.3, -stableSize * 0.3),
      Offset(-stableSize * 0.3, stableSize * 0.3),
      Offset(stableSize * 0.3, stableSize * 0.3),
    ];
    return offsets.map((o) => base + o).toList();
  }
}
