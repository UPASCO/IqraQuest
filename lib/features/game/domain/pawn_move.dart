import 'package:flutter/foundation.dart';

import '../../../models/pawn_position.dart';

/// One legal move: pawn [pawnIndex] of [playerId] goes from [from] to
/// [to]. If it lands on an opponent, [capturedPlayerId]/[capturedPawnIndex]
/// identify the pawn sent home (spec §43) — always null for a landing on
/// a protected square, an empty square, or a final-lane/finish square
/// (those are private per player and never capturable).
@immutable
class PawnMove {
  const PawnMove({
    required this.playerId,
    required this.pawnIndex,
    required this.from,
    required this.to,
    this.capturedPlayerId,
    this.capturedPawnIndex,
  });

  final String playerId;
  final int pawnIndex;
  final PawnPosition from;
  final PawnPosition to;
  final String? capturedPlayerId;
  final int? capturedPawnIndex;

  bool get isCapture => capturedPlayerId != null;
}
