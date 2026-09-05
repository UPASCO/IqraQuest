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

  /// Landed on an opponent standing on an Oasis: the square shelters
  /// them, so the two horses share it and nobody goes home. The rule is
  /// the classic safe square, and it has to be *said* — two horses on
  /// one square with no word about it reads as a capture that failed.
  shelteredByOasis,

  /// Reached the end of the course; the journey question is now owed.
  reachedFinish,

  /// A 6 brought a horse out of the stable onto its start square.
  exitedStable,

  /// The drawn card could move nothing: no 6 for a stable full of
  /// horses, or every destination taken by the player's own horses. The
  /// turn passes; nothing is lost.
  noLegalMove,

  /// An optional cell challenge was won.
  bonusEarned,

  /// An optional cell challenge was missed — costs only the bonus.
  bonusMissed,
}
