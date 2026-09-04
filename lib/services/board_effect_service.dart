import '../models/circuit.dart';
import '../models/movement_choice.dart';
import '../models/player.dart';
import '../models/question_category.dart';
import 'movement_choice_service.dart';

/// Describes what each square does, so the UI can show it on the board
/// *before* a player commits to a gait, and so a landing resolves through
/// one well-defined path.
///
/// Every effect here is deterministic and announced in advance. Nothing
/// advances or retreats a horse at random, nothing grants a random reward,
/// and nothing picks an opponent for you (spec §7).
class BoardEffectService {
  const BoardEffectService({this.movementChoices = const MovementChoiceService()});

  final MovementChoiceService movementChoices;

  /// A duel is fought at mid risk, so both players face a comparable
  /// question whatever gait led the challenger there.
  static const MovementChoice _duelGait = MovementChoice(3);

  /// Squares that ask the player something before resolving. The rest
  /// apply silently the moment the horse lands.
  bool isInteractive(CellEffect effect) => switch (effect) {
    CellEffect.challenge || CellEffect.shortcut || CellEffect.relay || CellEffect.duel => true,
    CellEffect.plain || CellEffect.oasis || CellEffect.knowledge || CellEffect.wisdom => false,
  };

  /// Whether this effect can run at all right now — a Duel needs an
  /// opponent, a Relay needs a second horse to hand the move to.
  ///
  /// Duel and Relay are additionally held back from this release: their
  /// full flows (opponent's question, horse hand-off picker) have no UI
  /// yet, and a square must never offer a decision it cannot resolve.
  /// Until those screens ship, both squares apply silently like a plain
  /// square — the engine rules for them stay tested and ready.
  bool isAvailableFor(CellEffect effect, {required int playerCount, required int horseCount}) =>
      switch (effect) {
        CellEffect.duel || CellEffect.relay => false,
        _ => true,
      };

  /// Whether this square asks the player an optional question at all.
  /// Ask this first: a null level from [questionDifficultyFor] means
  /// "draw it mixed", not "no question".
  bool asksQuestion(CellEffect effect) => switch (effect) {
    CellEffect.challenge || CellEffect.shortcut || CellEffect.duel => true,
    _ => false,
  };

  /// The level of the optional question a square asks for: null to draw
  /// it mixed (the rider plays the mixed level), or when the square asks
  /// none at all — see [asksQuestion].
  QuestionDifficulty? questionDifficultyFor(CellEffect effect, PlayerProfile profile) =>
      switch (effect) {
        CellEffect.challenge || CellEffect.shortcut => movementChoices.bonusDifficultyFor(profile),
        CellEffect.duel => movementChoices.difficultyFor(_duelGait, profile),
        _ => null,
      };

  /// Extra knowledge points granted just for landing here.
  int bonusPointsFor(CellEffect effect) => switch (effect) {
    CellEffect.knowledge => 1,
    _ => 0,
  };

  /// How many squares a won Défi adds (spec §7).
  int get challengeBonusSteps => 2;
}
