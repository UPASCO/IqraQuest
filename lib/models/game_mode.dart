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
  /// How many horses a player actually races with. The board always
  /// paints four stable slots, but a shorter format fills only the ones
  /// it races: a quick race is one horse, not four with a win declared
  /// on the first one home. The slots left over are drawn as greyed
  /// silhouettes, so it reads as "not in this race" and not as a stable
  /// that has lost its horses.
  int get horsesPerPlayer => horsesToWin;

  /// The four slots the plate paints in every stable, whatever the
  /// format — the shape of the original board.
  static const int stableSlots = 4;

  /// How many of a player's horses must arrive for the win. With
  /// [horsesPerPlayer] horses on the table, every format now asks for
  /// all of them; the two stay separate because a resumed save may hold
  /// a stable set to a different size.
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
