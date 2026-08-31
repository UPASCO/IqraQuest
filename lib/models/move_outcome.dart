/// What actually happened on the last resolved move — drives feedback,
/// animation and haptics.
enum MoveOutcome {
  /// Correct answer: the horse advanced exactly the chosen number.
  moved,

  /// Wrong answer: the horse held its ground (never a setback).
  stayed,

  /// Landed on an opponent, who returns calmly to their stable.
  captured,

  /// Landed on an opponent carrying a knowledge shield: the shield
  /// absorbed it and nobody went home.
  blockedByShield,

  /// Reached the end of the course; the journey question is now owed.
  reachedFinish,

  /// An optional cell challenge was won.
  bonusEarned,

  /// An optional cell challenge was missed — costs only the bonus.
  bonusMissed,
}
