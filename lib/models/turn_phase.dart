/// The per-turn state machine. Exactly one phase is active at a time, and
/// [GameEngine] is the only thing allowed to transition it.
///
/// There is no "waiting for dice" phase any more: a turn starts with the
/// player choosing a gait, which decides both how far they move and how
/// hard the question will be.
enum TurnPhase {
  /// The deck is on the table: the player draws this turn's card.
  selectingGait,

  /// The card is drawn and more than one horse could use it — bring one
  /// out of the stable, or ride one already on the course. The player
  /// (or the opponent's brain) picks; nothing moves until the question
  /// that follows is answered.
  choosingHorse,

  /// The card is drawn and no horse can use it: every horse is still in
  /// the stable and the card is not a 6, or every destination is
  /// taken by the player's own horses. The turn passes after a short
  /// beat — the card is seen, the disappointment is felt, and play moves
  /// on.
  noMove,

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
