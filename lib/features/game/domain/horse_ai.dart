import 'dart:math';

import '../../../models/circuit.dart';
import '../../../models/game_state.dart';
import '../../../models/movement_choice.dart';
import '../../../models/pawn_position.dart';
import '../../../models/player.dart';
import 'game_engine.dart';

/// AI opponents play through the exact same [GameEngine] as a human: they
/// pick a horse and a gait from the same visible options, and they are
/// bound by the same gait cycle.
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
  /// chosen gait drew.
  bool decideAnswerCorrect(AiDifficulty difficulty) =>
      _random.nextDouble() < _answerAccuracy[difficulty]!;

  /// Picks a horse and one of the player's remaining gaits. Never returns
  /// a gait the cycle has already spent.
  ({int horseIndex, MovementChoice choice, bool useGrandGallop}) chooseGait({
    required GameState state,
    required GameEngine engine,
    required AiDifficulty difficulty,
  }) {
    final player = state.currentPlayer;
    final gaits = engine.availableGaits(player);
    final horses = engine.movableHorses(player);
    assert(gaits.isNotEmpty && horses.isNotEmpty);

    final options = <({int horseIndex, MovementChoice choice, double score})>[];
    for (final horseIndex in horses) {
      for (final choice in gaits) {
        final preview = engine.previewGait(state, horseIndex, choice);
        options.add((
          horseIndex: horseIndex,
          choice: choice,
          score: _score(preview, state, difficulty),
        ));
      }
    }
    options.sort((a, b) => b.score.compareTo(a.score));

    final picked = switch (difficulty) {
      // A beginner opponent plays it safe and a little haphazardly.
      AiDifficulty.easy => options[_random.nextInt(options.length)],
      // Competent, not omniscient: usually the best move, sometimes the
      // second-best.
      AiDifficulty.medium =>
        options.length > 1 && _random.nextDouble() < 0.3 ? options[1] : options.first,
      AiDifficulty.hard => options.first,
    };

    // Spend a Grand Galop only when it converts a move into an arrival.
    final withBonus =
        player.rewards.hasGrandGallop &&
        engine
            .previewGait(state, picked.horseIndex, picked.choice, useGrandGallop: true)
            .reachesFinish;

    return (horseIndex: picked.horseIndex, choice: picked.choice, useGrandGallop: withBonus);
  }

  double _score(GaitPreview preview, GameState state, AiDifficulty difficulty) {
    var score = 0.0;

    // How likely is this opponent to actually answer at this tier? A
    // beginner taking a "hard" gait is mostly throwing the turn away.
    final accuracy = _answerAccuracy[difficulty]!;
    final tierPenalty = switch (preview.choice.risk) {
      DifficultyRisk.gentle => 0.0,
      DifficultyRisk.steady => (1 - accuracy) * 6,
      DifficultyRisk.bold => (1 - accuracy) * 12,
    };
    score -= tierPenalty;

    // Expected progress is the payoff, discounted by the odds of missing.
    score += preview.choice.steps * accuracy * 1.5;

    if (preview.reachesFinish) score += 25;
    if (preview.capturesOpponent) score += 14;
    if (preview.effect == CellEffect.oasis) score += 6;
    if (preview.effect == CellEffect.knowledge) score += 3;
    if (preview.effect == CellEffect.challenge) score += 2;
    if (preview.effect == CellEffect.shortcut) score += 4;

    // Getting a horse out of the stable is worth doing early.
    if (preview.destination is TrackPosition &&
        state.currentPlayer.horses[preview.horseIndex].isHome) {
      score += 5;
    }

    // A hard opponent also avoids parking within an opponent's reach.
    if (difficulty == AiDifficulty.hard &&
        preview.destination is TrackPosition &&
        preview.effect != CellEffect.oasis &&
        _isExposed(preview.destination as TrackPosition, state)) {
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
