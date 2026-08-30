/// Solo (1 human + AI opponents) vs Family (2-4 humans, same device).
enum GameMode { solo, family }

/// Quick (1 pawn/player, first pawn home wins) vs Classic (4 pawns/player,
/// all 4 home to win) — spec §37/§38. The same [GameEngine] drives both.
enum GameVariant { quick, classic }

extension GameVariantX on GameVariant {
  int get pawnsPerPlayer => switch (this) {
    GameVariant.quick => 1,
    GameVariant.classic => 4,
  };
}
