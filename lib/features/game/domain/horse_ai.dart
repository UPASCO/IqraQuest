import 'dart:math';

import '../../../models/game_state.dart';
import '../../../models/pawn_position.dart';
import '../../../models/player.dart';
import 'pawn_move.dart';

/// AI opponents run through the exact same [GameEngine] as a human player
/// — they never see hidden information and the dice is never biased for
/// them (spec §35: "the AI never cheats, the dice stays impartial").
/// Difficulty only changes (a) how often the AI "knows" the right answer
/// and (b) how well it chooses among the engine's legal moves.
class HorseAi {
  HorseAi({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const _answerAccuracy = {
    AiDifficulty.easy: 0.45,
    AiDifficulty.medium: 0.68,
    AiDifficulty.hard: 0.88,
  };

  bool decideAnswerCorrect(AiDifficulty difficulty) {
    return _random.nextDouble() < _answerAccuracy[difficulty]!;
  }

  /// Picks one of the engine-provided [legalMoves]. Never invents a move
  /// the engine didn't offer.
  PawnMove chooseMove({
    required List<PawnMove> legalMoves,
    required AiDifficulty difficulty,
    required GameState state,
  }) {
    assert(legalMoves.isNotEmpty);
    if (difficulty == AiDifficulty.easy) {
      return legalMoves[_random.nextInt(legalMoves.length)];
    }

    final scored = legalMoves.map((m) => (move: m, score: _score(m, state, difficulty))).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    if (difficulty == AiDifficulty.medium && scored.length > 1 && _random.nextDouble() < 0.25) {
      // Medium AI occasionally picks its 2nd-best move — competent, not
      // omniscient.
      return scored[1].move;
    }
    return scored.first.move;
  }

  double _score(PawnMove move, GameState state, AiDifficulty difficulty) {
    double score = 0;

    // Leaving the stable is always valuable — more pieces in play.
    if (move.from is HomePosition) score += 5;

    // Capturing an opponent is the single best outcome.
    if (move.isCapture) score += 12;

    // Reaching the finish line outright is excellent.
    if (move.to is FinishedPosition) score += 15;
    if (move.to is FinalLanePosition) score += 6;

    // Landing on a protected square is safe.
    if (move.to case TrackPosition(:final isProtected) when isProtected) {
      score += 4;
    }

    // Hard AI additionally avoids leaving a pawn exposed to imminent
    // capture (within the next 1-6 squares of any opponent).
    if (difficulty == AiDifficulty.hard && move.to is TrackPosition) {
      final destination = move.to as TrackPosition;
      if (!destination.isProtected && _isExposed(destination, move.playerId, state)) {
        score -= 7;
      }
    }

    // Prefer overall progress (further along its own journey).
    score += _progressValue(move.to) * 0.01;

    return score;
  }

  bool _isExposed(TrackPosition destination, String movingPlayerId, GameState state) {
    for (final other in state.players) {
      if (other.id == movingPlayerId) continue;
      for (final pawn in other.pawns) {
        if (pawn is! TrackPosition) continue;
        final gap = (destination.index - pawn.index) % BoardGeometry.trackLength;
        if (gap >= 1 && gap <= 6) return true;
      }
    }
    return false;
  }

  double _progressValue(PawnPosition position) => switch (position) {
    HomePosition() => 0,
    TrackPosition(:final index) => index.toDouble(),
    FinalLanePosition(:final step) => 52 + step.toDouble(),
    FinishedPosition() => 100,
  };
}
