/// The per-turn state machine. Exactly one phase is active at a time, and
/// [GameEngine] is the only thing allowed to transition it.
///
/// There is no "waiting for dice" phase any more: a turn starts with the
/// player choosing a gait, which decides both how far they move and how
/// hard the question will be.
enum TurnPhase {
  /// The player picks a horse and one of their remaining gaits.
  selectingGait,

  /// A question of the chosen gait's difficulty is on screen.
  answeringQuestion,

  /// The answer, explanation and source are shown.
  showingFeedback,

  /// The horse landed on an interactive square (Défi, Raccourci, Relais,
  /// Duel) and the player has a decision to make.
  resolvingCell,

  /// A horse has reached the finish and owes its "Question du voyage".
  answeringJourneyQuestion,

  turnComplete,
  gameOver,
}
