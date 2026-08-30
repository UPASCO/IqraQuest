import 'package:flutter/foundation.dart';

import '../theme/app_team.dart';
import 'pawn_position.dart';

/// AI opponent strength. Only affects answer-probability and move
/// heuristics — never the dice, which stays impartial for every player
/// (spec §35).
enum AiDifficulty { easy, medium, hard }

@immutable
class Player {
  const Player({
    required this.id,
    required this.name,
    required this.team,
    required this.pawns,
    this.aiDifficulty,
  });

  final String id;

  /// Local-only display name (never transmitted anywhere).
  final String name;

  final AppTeam team;

  /// null for a human player; set for an AI-controlled player.
  final AiDifficulty? aiDifficulty;

  final List<PawnPosition> pawns;

  bool get isAi => aiDifficulty != null;
  bool get isHuman => !isAi;

  bool get hasWon => pawns.every((p) => p is FinishedPosition);

  Player copyWith({String? name, List<PawnPosition>? pawns}) => Player(
    id: id,
    name: name ?? this.name,
    team: team,
    aiDifficulty: aiDifficulty,
    pawns: pawns ?? this.pawns,
  );

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'] as String,
    name: json['name'] as String,
    team: AppTeam.values.byName(json['team'] as String),
    aiDifficulty: json['aiDifficulty'] == null
        ? null
        : AiDifficulty.values.byName(json['aiDifficulty'] as String),
    pawns: (json['pawns'] as List)
        .map((p) => PawnPosition.fromJson(p as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'team': team.name,
    'aiDifficulty': aiDifficulty?.name,
    'pawns': pawns.map((p) => p.toJson()).toList(),
  };
}
