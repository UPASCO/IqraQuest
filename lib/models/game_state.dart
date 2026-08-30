import 'package:flutter/foundation.dart';

import 'game_mode.dart';
import 'player.dart';
import 'turn_phase.dart';

/// Full logical state of one game — sufficient to serialize, close the app,
/// and resume identically later (spec §80–83).
@immutable
class GameState {
  const GameState({
    required this.gameId,
    required this.gameMode,
    required this.gameVariant,
    required this.players,
    required this.currentPlayerIndex,
    required this.turnPhase,
    required this.askedQuestionIds,
    required this.startedAt,
    required this.updatedAt,
    this.currentQuestionId,
    this.lastDiceValue,
    this.winnerId,
    this.freeBankExhausted = false,
  });

  final String gameId;
  final GameMode gameMode;
  final GameVariant gameVariant;
  final List<Player> players;
  final int currentPlayerIndex;
  final TurnPhase turnPhase;
  final String? currentQuestionId;

  /// Every question id already asked this game — enforces spec §48 (no
  /// repeats within a single game).
  final Set<String> askedQuestionIds;

  final int? lastDiceValue;
  final String? winnerId;

  /// True once the free edition's 50-question bank has been fully used in
  /// this game (spec §49): dice rolls no longer require a question for the
  /// remainder of this game, but the game is never interrupted or blocked.
  final bool freeBankExhausted;

  final DateTime startedAt;
  final DateTime updatedAt;

  Player get currentPlayer => players[currentPlayerIndex];

  GameState copyWith({
    List<Player>? players,
    int? currentPlayerIndex,
    TurnPhase? turnPhase,
    Object? currentQuestionId = _unset,
    Set<String>? askedQuestionIds,
    Object? lastDiceValue = _unset,
    Object? winnerId = _unset,
    bool? freeBankExhausted,
    DateTime? updatedAt,
  }) {
    return GameState(
      gameId: gameId,
      gameMode: gameMode,
      gameVariant: gameVariant,
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      turnPhase: turnPhase ?? this.turnPhase,
      currentQuestionId: identical(currentQuestionId, _unset)
          ? this.currentQuestionId
          : currentQuestionId as String?,
      askedQuestionIds: askedQuestionIds ?? this.askedQuestionIds,
      lastDiceValue: identical(lastDiceValue, _unset) ? this.lastDiceValue : lastDiceValue as int?,
      winnerId: identical(winnerId, _unset) ? this.winnerId : winnerId as String?,
      freeBankExhausted: freeBankExhausted ?? this.freeBankExhausted,
      startedAt: startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
    gameId: json['gameId'] as String,
    gameMode: GameMode.values.byName(json['gameMode'] as String),
    gameVariant: GameVariant.values.byName(json['gameVariant'] as String),
    players: (json['players'] as List)
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList(),
    currentPlayerIndex: json['currentPlayerIndex'] as int,
    turnPhase: TurnPhase.values.byName(json['turnPhase'] as String),
    currentQuestionId: json['currentQuestionId'] as String?,
    askedQuestionIds: Set<String>.from(json['askedQuestionIds'] as List),
    lastDiceValue: json['lastDiceValue'] as int?,
    winnerId: json['winnerId'] as String?,
    freeBankExhausted: json['freeBankExhausted'] as bool? ?? false,
    startedAt: DateTime.parse(json['startedAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'gameMode': gameMode.name,
    'gameVariant': gameVariant.name,
    'players': players.map((p) => p.toJson()).toList(),
    'currentPlayerIndex': currentPlayerIndex,
    'turnPhase': turnPhase.name,
    'currentQuestionId': currentQuestionId,
    'askedQuestionIds': askedQuestionIds.toList(),
    'lastDiceValue': lastDiceValue,
    'winnerId': winnerId,
    'freeBankExhausted': freeBankExhausted,
    'startedAt': startedAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

const Object _unset = Object();
