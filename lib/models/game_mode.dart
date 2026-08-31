/// Solo (1 human + AI opponents) vs Family (2-4 humans, same device).
enum GameMode { solo, family }

/// The three game formats (spec §5). Horse counts are deliberately small:
/// with a question on every single turn, four horses each would stretch a
/// game far past what a family sitting will bear.
enum GameVariant {
  /// Course rapide — one horse each, short circuit, ~5-10 minutes.
  quick,

  /// Course classique — two horses each, full circuit, ~15-25 minutes.
  classic,

  /// Grand parcours familial — 2-4 players, more interactive squares, and
  /// a difficulty profile set separately per player so a child and an
  /// adult can genuinely play together.
  family,
}

extension GameVariantX on GameVariant {
  int get horsesPerPlayer => switch (this) {
    GameVariant.quick => 1,
    GameVariant.classic => 2,
    GameVariant.family => 2,
  };

  int get maxPlayers => switch (this) {
    GameVariant.quick => 4,
    GameVariant.classic => 4,
    GameVariant.family => 4,
  };
}
