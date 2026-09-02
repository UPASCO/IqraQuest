/// The per-turn state machine. Exactly one phase is active at a time, and
/// [GameEngine] is the only thing allowed to transition it.
///
/// A turn reads: draw a card, answer its question, *then* — if the answer
/// was right — see how many squares it won, pick a horse, and set it down
/// on its destination with a finger. Nothing moves by itself after a
/// right answer: the player keeps the decision.
enum TurnPhase {
  /// The deck is on the table: the player draws this turn's card.
  selectingGait,

  /// The card's question is on screen. Its value stays face down until
  /// the answer is judged.
  answeringQuestion,

  /// The answer, explanation and source are shown; on a right answer the
  /// card's value is revealed with them.
  showingFeedback,

  /// The answer was right and the squares are won: the horses that can
  /// use them wait for the player to pick one up and set it down on its
  /// destination. The choice stays open until a horse is dropped on its
  /// square; the drop itself is the confirmation.
  choosingHorse,

  /// A horse has been set down and is riding — its own squares, then a
  /// bonus square's extra squares if it landed on one. The turn moves
  /// on by itself once the ride settles.
  movingHorse,

  /// The squares were won but no horse can use them: every horse is
  /// still in the stable and the card is not a 6, or every destination
  /// is taken by the player's own horses. The turn passes after a short
  /// beat — the card is seen, the disappointment is felt, and play moves
  /// on.
  noMove,

  /// The horse landed on an interactive square (Défi, Raccourci, Relais,
  /// Duel) and the player has a decision to make.
  resolvingCell,

  /// A horse has reached the finish and owes its "Question du voyage".
  answeringJourneyQuestion,

  turnComplete,
  gameOver,
}
