import 'dart:math';

import '../../../models/circuit.dart';
import '../../../models/game_state.dart';
import '../../../models/movement_choice.dart';
import '../../../models/pawn_position.dart';
import '../../../models/player.dart';
import 'game_engine.dart';

/// AI opponents play through the exact same [GameEngine] as a human: they
/// draw from the same deck and choose only what the card does — which
/// horse comes out, or which one rides.
///
/// The one thing that *is* simulated is whether the AI "knows" the answer
/// — an AI cannot genuinely answer a quiz question, so its accuracy is
/// modelled per difficulty. That models an opponent's knowledge; it never
/// moves a horse by chance, and the AI sees no information a human player
/// could not see.
class HorseAi {
  HorseAi({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const _answerAccuracy = {
    AiDifficulty.easy: 0.45,
    AiDifficulty.medium: 0.68,
    AiDifficulty.hard: 0.88,
  };

  /// Models whether this opponent knows the answer at the difficulty its
  /// drawn card carries.
  bool decideAnswerCorrect(AiDifficulty difficulty) =>
      _random.nextDouble() < _answerAccuracy[difficulty]!;

  /// Picks which of the card's [moves] the opponent takes.
  ///
  /// The opponent draws exactly as a human does: the value is the
  /// deck's, never its own. All it decides is what to do with it — bring
  /// a horse out, or ride one already on the course — and it decides
  /// that from the same options the player would see on the board.
  int chooseMove({
    required GameState state,
    required GameEngine engine,
    required AiDifficulty difficulty,
    required List<LegalMove> moves,
  }) {
    assert(moves.isNotEmpty);
    final card = state.drawnCard ?? const MovementChoice(1);
    final options = <({int horseIndex, double score})>[
      for (final move in moves)
        (
          horseIndex: move.horseIndex,
          score: _scoreMove(move, card, state, difficulty),
        ),
    ];
    options.sort((a, b) => b.score.compareTo(a.score));

    final picked = switch (difficulty) {
      // A beginner opponent plays it safe and a little haphazardly.
      AiDifficulty.easy => options[_random.nextInt(options.length)],
      // Competent, not omniscient: usually the best move, sometimes the
      // second-best.
      AiDifficulty.medium =>
        options.length > 1 && _random.nextDouble() < 0.3
            ? options[1]
            : options.first,
      AiDifficulty.hard => options.first,
    };
    return picked.horseIndex;
  }

  double _scoreMove(
    LegalMove move,
    MovementChoice card,
    GameState state,
    AiDifficulty difficulty,
  ) {
    var score = 0.0;
    final accuracy = _answerAccuracy[difficulty]!;

    // Progress is the payoff, discounted by the odds of missing the
    // question. An exit is worth a ride of a few squares: a horse on the
    // course is a horse that can use every later card.
    score += (move.exitsStable ? 4 : card.steps) * accuracy * 1.5;
    if (move.exitsStable) score += 5;

    if (move.reachesFinish) score += 25;
    if (move.capturesOpponent) score += 14;
    if (move.effect == CellEffect.oasis) score += 6;
    if (move.effect == CellEffect.knowledge) score += 3;
    if (move.effect == CellEffect.challenge) score += 2;
    if (move.effect == CellEffect.shortcut) score += 4;

    // A hard opponent also avoids parking within an opponent's reach.
    if (difficulty == AiDifficulty.hard &&
        move.destination is TrackPosition &&
        move.effect != CellEffect.oasis &&
        _isExposed(move.destination as TrackPosition, state)) {
      score -= 8;
    }
    return score;
  }

  bool _isExposed(TrackPosition destination, GameState state) {
    final circuit = state.circuit;
    for (final other in state.players) {
      if (other.id == state.currentPlayer.id) continue;
      for (final horse in other.horses) {
        final position = horse.position;
        if (position is! TrackPosition) continue;
        final gap = (destination.index - position.index) % circuit.trackLength;
        if (gap >= MovementChoice.minSteps && gap <= MovementChoice.maxSteps) {
          return true;
        }
      }
    }
    return false;
  }
}
