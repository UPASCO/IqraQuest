/// Solo (1 human + AI opponents) vs Family (2-4 humans, same device).
enum GameMode { solo, family }

/// The three game formats (spec §5). Every format plays the full *jeu
/// des petits chevaux*: four horses in every stable. What changes is
/// how many must reach Mecca to win — one for a quick race, all four for
/// the classic and family games.
enum GameVariant {
  /// Course rapide — four horses each, the first one home wins.
  quick,

  /// Course classique — the four horses of the original game, all home.
  classic,

  /// Grand parcours familial — 2-4 players, more interactive squares, and
  /// a difficulty profile set separately per player so a child and an
  /// adult can genuinely play together.
  family,
}

extension GameVariantX on GameVariant {
  /// Four in every stable, whatever the format: the board has four
  /// slots and the rules of the original game assume them.
  int get horsesPerPlayer => 4;

  /// How many of a player's horses must arrive for the win.
  int get horsesToWin => switch (this) {
    GameVariant.quick => 1,
    GameVariant.classic => 4,
    GameVariant.family => 4,
  };

  int get maxPlayers => switch (this) {
    GameVariant.quick => 4,
    GameVariant.classic => 4,
    GameVariant.family => 4,
  };
}
