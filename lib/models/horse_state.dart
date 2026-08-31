import 'package:flutter/foundation.dart';

import 'pawn_position.dart';

/// One horse belonging to a player: where it stands, and whether a
/// knowledge shield is currently protecting it.
@immutable
class HorseState {
  const HorseState({
    this.position = const HomePosition(),
    this.hasShield = false,
    this.awaitingJourneyQuestion = false,
  });

  final PawnPosition position;

  /// Earned by a 3-answer streak; absorbs one capture instead of the
  /// horse being sent back to the stable (spec §8/§9).
  final bool hasShield;

  /// The horse has reached the end of the course and is waiting for its
  /// "Question du voyage" to make the arrival official (spec §10). A wrong
  /// answer never pushes it back — the player simply tries again next turn.
  final bool awaitingJourneyQuestion;

  bool get isHome => position is HomePosition;
  bool get isFinished => position is FinishedPosition;

  /// A horse counts as "done" only once its journey question is answered.
  bool get hasArrived => isFinished && !awaitingJourneyQuestion;

  HorseState copyWith({PawnPosition? position, bool? hasShield, bool? awaitingJourneyQuestion}) =>
      HorseState(
        position: position ?? this.position,
        hasShield: hasShield ?? this.hasShield,
        awaitingJourneyQuestion: awaitingJourneyQuestion ?? this.awaitingJourneyQuestion,
      );

  factory HorseState.fromJson(Map<String, dynamic> json) => HorseState(
    position: PawnPosition.fromJson(json['position'] as Map<String, dynamic>),
    hasShield: json['hasShield'] as bool? ?? false,
    awaitingJourneyQuestion: json['awaitingJourneyQuestion'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'position': position.toJson(),
    'hasShield': hasShield,
    'awaitingJourneyQuestion': awaitingJourneyQuestion,
  };

  @override
  bool operator ==(Object other) =>
      other is HorseState &&
      other.position == position &&
      other.hasShield == hasShield &&
      other.awaitingJourneyQuestion == awaitingJourneyQuestion;

  @override
  int get hashCode => Object.hash(position, hasShield, awaitingJourneyQuestion);
}
