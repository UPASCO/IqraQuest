import 'package:flutter/foundation.dart';

import 'movement_choice.dart';

/// Tracks which of the six gaits a player has already spent.
///
/// Each gait 1–6 can be used once per cycle; once all six are spent the
/// cycle refills and every gait is available again. This is what keeps
/// the game strategic instead of letting a player spam "6" every turn —
/// and it is fully deterministic and visible, so a player can plan around
/// what they have left.
@immutable
class GaitCycle {
  const GaitCycle({this.usedSteps = const {}, this.completedCycles = 0});

  /// The `steps` values already spent in the current cycle.
  final Set<int> usedSteps;

  /// How many full cycles this player has completed — shown in the UI so
  /// "everything is available again" reads as progress, not a reset bug.
  final int completedCycles;

  bool isAvailable(MovementChoice choice) => !usedSteps.contains(choice.steps);

  List<MovementChoice> get available => MovementChoice.all.where(isAvailable).toList();

  List<MovementChoice> get used => MovementChoice.all.where((c) => !isAvailable(c)).toList();

  bool get isFresh => usedSteps.isEmpty;

  /// Spends [choice]. When that empties the cycle, it immediately refills
  /// so the next turn always has something to choose.
  GaitCycle consume(MovementChoice choice) {
    final next = {...usedSteps, choice.steps};
    if (next.length >= MovementChoice.all.length) {
      return GaitCycle(usedSteps: const {}, completedCycles: completedCycles + 1);
    }
    return GaitCycle(usedSteps: next, completedCycles: completedCycles);
  }

  factory GaitCycle.fromJson(Map<String, dynamic> json) => GaitCycle(
    usedSteps: Set<int>.from(json['usedSteps'] as List? ?? const []),
    completedCycles: json['completedCycles'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'usedSteps': usedSteps.toList()..sort(),
    'completedCycles': completedCycles,
  };

  @override
  bool operator ==(Object other) =>
      other is GaitCycle &&
      other.completedCycles == completedCycles &&
      setEquals(other.usedSteps, usedSteps);

  @override
  int get hashCode => Object.hash(completedCycles, Object.hashAllUnordered(usedSteps));
}
