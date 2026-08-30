import '../../../models/game_mode.dart';
import '../../../models/player.dart' show AiDifficulty;

/// Carries the choices made on Mode Selection into Player Setup.
class PlayerSetupArgs {
  const PlayerSetupArgs({
    required this.mode,
    required this.variant,
    this.aiOpponentCount = 1,
    this.aiDifficulty = AiDifficulty.medium,
    this.humanPlayerCount = 2,
  });

  final GameMode mode;
  final GameVariant variant;

  /// Solo mode only: 1-3 AI opponents.
  final int aiOpponentCount;
  final AiDifficulty aiDifficulty;

  /// Family mode only: 2-4 human players.
  final int humanPlayerCount;
}
