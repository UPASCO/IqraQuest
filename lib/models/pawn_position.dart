import 'package:flutter/foundation.dart';

/// A horse's logical location. Never carries screen/pixel data — rendering
/// maps this to board coordinates in the presentation layer only.
///
/// Board geometry (track length, final-lane length, which squares are
/// safe) belongs to the chosen [Circuit], not to a global constant, so the
/// three courses can differ in size and layout.
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

/// In the stable — not yet on the board. Any gait brings a horse out: the
/// move itself is what carries it onto its entry square, so no particular
/// number is ever required to start (spec §4).
final class HomePosition extends PawnPosition {
  const HomePosition();

  @override
  Map<String, dynamic> toJson() => const {'type': 'home'};

  @override
  bool operator ==(Object other) => other is HomePosition;
  @override
  int get hashCode => 0;
}

/// On the shared circular track, at global index [index]. The upper bound
/// is the active circuit's `trackLength`, which the engine enforces.
final class TrackPosition extends PawnPosition {
  const TrackPosition(this.index) : assert(index >= 0);

  final int index;

  @override
  Map<String, dynamic> toJson() => {'type': 'track', 'index': index};

  @override
  bool operator ==(Object other) => other is TrackPosition && other.index == index;
  @override
  int get hashCode => Object.hash('track', index);
}

/// In the horse's own private final lane, [step] squares from the track
/// exit. Never shared with another team, so never capturable. The upper
/// bound is the active circuit's `finalLaneLength`.
final class FinalLanePosition extends PawnPosition {
  const FinalLanePosition(this.step) : assert(step >= 1);

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
