import 'package:flutter/foundation.dart';

/// The board's logical geometry (spec §39: "never screen coordinates in the
/// business engine"). Track squares are numbered 0..[trackLength]-1 around
/// a shared loop; each team enters the loop at its own `entryIndex` and,
/// after a full lap, peels off into a private final lane of
/// [finalLaneLength] squares before reaching [FinishedPosition].
class BoardGeometry {
  const BoardGeometry._();

  static const int trackLength = 52;
  static const int finalLaneLength = 6;
  static const int squaresPerQuadrant = trackLength ~/ 4; // 13

  /// Squares (by global track index) that are "protected" — a pawn landing
  /// here cannot be captured (spec §44). Includes every team's entry
  /// square plus one further waypoint per quadrant, marked with the star
  /// motif in the UI.
  static const Set<int> protectedSquares = {0, 8, 13, 21, 26, 34, 39, 47};

  static int entryIndexForTeam(int teamIndex) => (teamIndex * squaresPerQuadrant) % trackLength;
}

/// A pawn's logical location. Never carries screen/pixel data — rendering
/// maps this to board coordinates in the presentation layer only.
@immutable
sealed class PawnPosition {
  const PawnPosition();

  factory PawnPosition.fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'home' => const HomePosition(),
      'track' => TrackPosition(json['index'] as int),
      'finalLane' => FinalLanePosition(json['step'] as int),
      'finished' => const FinishedPosition(),
      final other => throw ArgumentError('Unknown PawnPosition type $other'),
    };
  }

  Map<String, dynamic> toJson();
}

/// In the stable — not yet on the board. Requires a 6 to leave (spec §41).
final class HomePosition extends PawnPosition {
  const HomePosition();

  @override
  Map<String, dynamic> toJson() => const {'type': 'home'};

  @override
  bool operator ==(Object other) => other is HomePosition;
  @override
  int get hashCode => 0;
}

/// On the shared circular track, at global index [index] (0..51).
final class TrackPosition extends PawnPosition {
  const TrackPosition(this.index) : assert(index >= 0 && index < BoardGeometry.trackLength);

  final int index;

  bool get isProtected => BoardGeometry.protectedSquares.contains(index);

  @override
  Map<String, dynamic> toJson() => {'type': 'track', 'index': index};

  @override
  bool operator ==(Object other) => other is TrackPosition && other.index == index;
  @override
  int get hashCode => Object.hash('track', index);
}

/// In the pawn's own private final lane, [step] squares from the track
/// exit (1..6). Never shared with another team, so never capturable.
final class FinalLanePosition extends PawnPosition {
  const FinalLanePosition(this.step) : assert(step >= 1 && step <= BoardGeometry.finalLaneLength);

  final int step;

  @override
  Map<String, dynamic> toJson() => {'type': 'finalLane', 'step': step};

  @override
  bool operator ==(Object other) => other is FinalLanePosition && other.step == step;
  @override
  int get hashCode => Object.hash('finalLane', step);
}

/// Reached the end. Terminal state.
final class FinishedPosition extends PawnPosition {
  const FinishedPosition();

  @override
  Map<String, dynamic> toJson() => const {'type': 'finished'};

  @override
  bool operator ==(Object other) => other is FinishedPosition;
  @override
  int get hashCode => 1;
}
