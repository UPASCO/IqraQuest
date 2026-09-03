/// Solo (1 human + AI opponents) vs Family (2-4 humans, same device).
enum GameMode { solo, family }

/// How long a race is — and it is the ONLY thing a format changes.
///
/// Every format plays the full *jeu des petits chevaux*: four horses in
/// every stable, the same 52-square parcours, the same rules. What the
/// player picks is the finish line: **how many of their four horses must
/// reach Mecca** before the race is over. One is a sprint, two is an
/// evening, four is the classic game.
///
/// Said plainly, because a format nobody can tell apart is not a choice:
/// the picker names the win condition, not an abstract label.
enum GameVariant {
  /// Course rapide — the first horse home wins.
  quick,

  /// Course en duo — two horses of the same stable must arrive.
  duo,

  /// Course classique — all four, as in the original game.
  classic,

  /// Kept for games saved before the formats were named by their win
  /// condition; it plays exactly like [classic]. Never offered any more.
  family,
}

extension GameVariantX on GameVariant {
  /// Four in every stable, whatever the format: the board has four
  /// slots and the rules of the original game assume them.
  int get horsesPerPlayer => 4;

  /// How many of a player's horses must arrive for the win.
  int get horsesToWin => switch (this) {
    GameVariant.quick => 1,
    GameVariant.duo => 2,
    GameVariant.classic => 4,
    GameVariant.family => 4,
  };

  int get maxPlayers => 4;

  /// The formats a player may choose, shortest race first. [family] is
  /// deliberately absent: it was never a different game.
  static const List<GameVariant> choosable = [
    GameVariant.quick,
    GameVariant.duo,
    GameVariant.classic,
  ];
}
