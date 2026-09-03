import '../../../models/circuit.dart';
import '../../../models/game_mode.dart';
import '../../../models/player.dart' show AiDifficulty;

/// Carries the choices made on Mode Selection into Player Setup.
class PlayerSetupArgs {
  const PlayerSetupArgs({
    required this.mode,
    required this.variant,
    required this.circuitId,
    this.aiOpponentCount = 1,
    this.aiDifficulty = AiDifficulty.medium,
    this.humanPlayerCount = 2,
    this.bonusesEnabled = true,
  });

  final GameMode mode;
  final GameVariant variant;

  /// The course the players chose — always picked deliberately, never
  /// assigned at random (spec §6).
  final CircuitId circuitId;

  /// Solo mode only: 1-3 AI opponents.
  final int aiOpponentCount;
  final AiDifficulty aiDifficulty;

  /// Family mode only: 2-4 human players.
  final int humanPlayerCount;

  /// Whether the sixteen bonus squares are laid on the parcours. Off is
  /// the pure classic ride: a card is worth exactly its own squares.
  final bool bonusesEnabled;
}
