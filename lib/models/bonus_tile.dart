import 'package:flutter/foundation.dart';

/// A square of the shared circuit that carries a bonus: a horse that ends
/// its ride exactly on it rides on by the bonus's value.
///
/// Sixteen of them are placed at the start of every game — four per
/// quadrant, never side by side, the rare +20 in opposite quadrants —
/// and the layout is part of the game state, so it never moves during a
/// game, survives a save and is generated from one seed
/// (see `BonusLayout`).
@immutable
class BonusTile {
  const BonusTile({required this.trackIndex, required this.value})
    : assert(value == 5 || value == 10 || value == 20);

  /// The values a bonus square can carry, smallest first.
  static const List<int> values = [5, 10, 20];

  /// Global index on the shared circuit.
  final int trackIndex;

  /// 5, 10 or 20 extra squares.
  final int value;

  factory BonusTile.fromJson(Map<String, dynamic> json) => BonusTile(
    trackIndex: json['trackIndex'] as int,
    value: json['value'] as int,
  );

  Map<String, dynamic> toJson() => {'trackIndex': trackIndex, 'value': value};

  @override
  bool operator ==(Object other) =>
      other is BonusTile &&
      other.trackIndex == trackIndex &&
      other.value == value;

  @override
  int get hashCode => Object.hash(trackIndex, value);

  @override
  String toString() => 'BonusTile(+$value @ $trackIndex)';
}

/// A bonus a horse has just landed on and is about to ride: recorded in
/// the state between the landing and the extra ride, so the board can
/// flare the square and announce the bonus before the horse moves on —
/// and so a game closed at that instant resumes by riding it.
@immutable
class PendingBonus {
  const PendingBonus({
    required this.horseIndex,
    required this.trackIndex,
    required this.value,
  });

  /// Which of the current player's horses earned it.
  final int horseIndex;

  /// The square it was earned on.
  final int trackIndex;

  final int value;

  factory PendingBonus.fromJson(Map<String, dynamic> json) => PendingBonus(
    horseIndex: json['horseIndex'] as int,
    trackIndex: json['trackIndex'] as int,
    value: json['value'] as int,
  );

  Map<String, dynamic> toJson() => {
    'horseIndex': horseIndex,
    'trackIndex': trackIndex,
    'value': value,
  };
}
