/// The per-turn state machine (spec §81). Exactly one phase is active at a
/// time; [GameEngine] is the only thing allowed to transition it.
enum TurnPhase {
  waitingForQuestion,
  questionAnsweredCorrectly,
  questionAnsweredIncorrectly,
  waitingForDice,
  waitingForPawnSelection,
  animatingMove,
  turnComplete,
  gameOver,
}
