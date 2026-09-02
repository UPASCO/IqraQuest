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
  const MovementChoice(this.steps)
    : assert(steps >= minSteps && steps <= maxSteps);

  static const int minSteps = 1;
  static const int maxSteps = 6;

  /// The value that lets a horse leave the stable: the rule of the *jeu
  /// des petits chevaux*, where only a 6 opens the gate. Because a 6 also
  /// replays, the horse that just came out rides on the very next draw.
  static const Set<int> stableExitValues = {6};

  /// The value that grants a second draw: a 6 always lets the same
  /// player play again, exactly as a 6 on the die does.
  static const int extraTurnValue = 6;

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

  /// Whether this card can bring a horse out of the stable.
  bool get opensStable => stableExitValues.contains(steps);

  /// Whether this card earns the player another draw after this turn.
  bool get grantsExtraTurn => steps == extraTurnValue;

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
  bool operator ==(Object other) =>
      other is MovementChoice && other.steps == steps;

  @override
  int get hashCode => steps.hashCode;

  @override
  String toString() => 'MovementChoice($steps)';
}
