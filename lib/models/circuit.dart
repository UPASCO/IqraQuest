import 'package:flutter/foundation.dart';

import 'pawn_position.dart';

/// What a square does when a horse lands on it. Every effect is fixed,
/// visible on the board before the player commits to a gait, and fully
/// deterministic — no square ever moves a horse at random, grants a random
/// reward, or picks an opponent for you (spec §7).
enum CellEffect {
  plain,

  /// Safe square: a horse here cannot be captured.
  oasis,

  /// Shows a short sourced fact and grants one extra knowledge point.
  knowledge,

  /// Offer: keep your move, or answer a harder question for +2 squares.
  /// Failing the optional question costs only the bonus, never a setback.
  challenge,

  /// Offer: answer a hard question to take a shorter path forward.
  /// Failing leaves the horse exactly where it already stood.
  shortcut,

  /// Multiplayer only: the active player picks an opponent and both answer
  /// a question of the same difficulty; the winner earns a shield.
  duel,

  /// A teaching or historical fact the player may keep in their collection.
  /// Carries no gameplay advantage at all.
  wisdom,

  /// Lets the player hand the move they just earned to another of their
  /// own horses instead.
  relay,
}

/// One playable course. Layouts are fixed and shown before the game
/// starts, and every quadrant carries the identical pattern of special
/// squares, so no team's starting corner is ever advantaged (spec §6).
@immutable
class Circuit {
  const Circuit({
    required this.id,
    required this.squaresPerQuadrant,
    required this.finalLaneLength,
    required this.quadrantEffects,
    this.shortcutJump = 4,
  });

  final CircuitId id;

  /// The shared loop is four identical quadrants.
  final int squaresPerQuadrant;
  final int finalLaneLength;

  /// Effects keyed by offset *within a quadrant*, replicated to all four —
  /// this is what makes fairness structural rather than something to
  /// verify by eye.
  final Map<int, CellEffect> quadrantEffects;

  /// How far ahead a successful Shortcut carries a horse.
  final int shortcutJump;

  int get trackLength => squaresPerQuadrant * 4;

  int entryIndexForTeam(int teamIndex) => (teamIndex * squaresPerQuadrant) % trackLength;

  CellEffect effectAt(int trackIndex) {
    final offset = trackIndex % squaresPerQuadrant;
    return quadrantEffects[offset] ?? CellEffect.plain;
  }

  bool isSafe(int trackIndex) => effectAt(trackIndex) == CellEffect.oasis;

  /// Where a successful shortcut from [trackIndex] lands.
  int shortcutTargetFrom(int trackIndex) => (trackIndex + shortcutJump) % trackLength;

  /// Total distance from leaving the stable to the finish line.
  int get journeyLength => trackLength + finalLaneLength;

  /// How far along its own journey a horse stands, or null if still in
  /// the stable. This is the same geometry the engine moves by, exposed
  /// so presentation can animate a move through every intermediate
  /// square instead of teleporting across the board.
  int? progressOf(PawnPosition position, int teamIndex) => switch (position) {
    HomePosition() => null,
    TrackPosition(:final index) => (index - entryIndexForTeam(teamIndex)) % trackLength,
    FinalLanePosition(:final step) => trackLength + step - 1,
    FinishedPosition() => journeyLength,
  };

  /// The square a horse stands on after [progress] steps of its journey.
  PawnPosition positionAt(int progress, int teamIndex) {
    if (progress >= journeyLength) return const FinishedPosition();
    if (progress >= trackLength) {
      return FinalLanePosition(progress - trackLength + 1);
    }
    return TrackPosition((entryIndexForTeam(teamIndex) + progress) % trackLength);
  }

  List<int> get safeSquares => [
    for (var i = 0; i < trackLength; i++)
      if (isSafe(i)) i,
  ];

  /// Every board is the parcours of the traditional French *jeu des
  /// petits chevaux*: a 56-square circuit — 14 per quadrant — and a
  /// six-step escalier per team, climbed on an exact count. The three
  /// boards differ only in the scenery they ride through and in which
  /// squares carry an effect, never in the distance: a race is only fair
  /// to compare when everyone runs the same course.
  static const int _squaresPerQuadrant = 14; // 14 x 4 = the 56-square circuit
  static const int _escalierSteps = 6;

  static const Circuit oasisRoute = Circuit(
    id: CircuitId.oasisRoute,
    squaresPerQuadrant: _squaresPerQuadrant,
    finalLaneLength: _escalierSteps,
    quadrantEffects: {
      0: CellEffect.oasis,
      4: CellEffect.knowledge,
      8: CellEffect.wisdom,
      11: CellEffect.oasis,
    },
  );

  static const Circuit caravanTrail = Circuit(
    id: CircuitId.caravanTrail,
    squaresPerQuadrant: _squaresPerQuadrant,
    finalLaneLength: _escalierSteps,
    quadrantEffects: {
      0: CellEffect.oasis,
      3: CellEffect.knowledge,
      6: CellEffect.challenge,
      9: CellEffect.oasis,
      12: CellEffect.relay,
    },
  );

  static const Circuit greatRide = Circuit(
    id: CircuitId.greatRide,
    squaresPerQuadrant: _squaresPerQuadrant,
    finalLaneLength: _escalierSteps,
    quadrantEffects: {
      0: CellEffect.oasis,
      2: CellEffect.knowledge,
      4: CellEffect.challenge,
      6: CellEffect.shortcut,
      8: CellEffect.oasis,
      10: CellEffect.duel,
      12: CellEffect.wisdom,
    },
  );

  static const List<Circuit> all = [oasisRoute, caravanTrail, greatRide];

  static Circuit byId(CircuitId id) => all.firstWhere((c) => c.id == id, orElse: () => oasisRoute);
}

enum CircuitId { oasisRoute, caravanTrail, greatRide }
