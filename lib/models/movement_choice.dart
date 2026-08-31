import 'package:flutter/foundation.dart';

import 'question_category.dart';

/// How much risk a player takes on this turn. Purely a function of how far
/// they choose to move — never rolled, never drawn, never random.
enum DifficultyRisk { gentle, steady, bold }

/// One "allure" (gait): the player's deliberate choice of how far to move,
/// which *is* their choice of how hard a question to face.
///
/// This is the mechanic that replaced the dice entirely. Progression
/// depends on knowledge and nerve, not chance:
///
/// | steps | difficulty   | knowledge points |
/// |-------|--------------|------------------|
/// | 1, 2  | easy         | 1                |
/// | 3, 4  | medium       | 2                |
/// | 5, 6  | hard         | 3                |
@immutable
class MovementChoice {
  const MovementChoice(this.steps) : assert(steps >= minSteps && steps <= maxSteps);

  static const int minSteps = 1;
  static const int maxSteps = 6;

  /// Every gait in a cycle, in display order.
  static const List<MovementChoice> all = [
    MovementChoice(1),
    MovementChoice(2),
    MovementChoice(3),
    MovementChoice(4),
    MovementChoice(5),
    MovementChoice(6),
  ];

  final int steps;

  DifficultyRisk get risk => switch (steps) {
    1 || 2 => DifficultyRisk.gentle,
    3 || 4 => DifficultyRisk.steady,
    _ => DifficultyRisk.bold,
  };

  /// The difficulty tier of the question this gait will draw. The player
  /// sees this *before* committing, so the trade-off is always informed.
  QuestionDifficulty get difficulty => switch (risk) {
    DifficultyRisk.gentle => QuestionDifficulty.easy,
    DifficultyRisk.steady => QuestionDifficulty.medium,
    DifficultyRisk.bold => QuestionDifficulty.hard,
  };

  int get knowledgePoints => switch (risk) {
    DifficultyRisk.gentle => 1,
    DifficultyRisk.steady => 2,
    DifficultyRisk.bold => 3,
  };

  /// Gaits 5 and 6 ask for a confirmation step in child mode (spec §13).
  bool get needsConfirmationForChildren => steps >= 5;

  @override
  bool operator ==(Object other) => other is MovementChoice && other.steps == steps;

  @override
  int get hashCode => steps.hashCode;

  @override
  String toString() => 'MovementChoice($steps)';
}
