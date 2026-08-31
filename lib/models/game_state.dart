import 'package:flutter/foundation.dart';

import 'circuit.dart';
import 'game_mode.dart';
import 'knowledge_streak.dart';
import 'move_outcome.dart';
import 'movement_choice.dart';
import 'player.dart';
import 'turn_phase.dart';

/// The gait a player has committed to this turn, before the question is
/// answered. Nothing moves until [GameEngine.applyAnswer] resolves it.
@immutable
class PendingGait {
  const PendingGait({required this.horseIndex, required this.choice, this.usesGrandGallop = false});

  final int horseIndex;
  final MovementChoice choice;
  final bool usesGrandGallop;

  factory PendingGait.fromJson(Map<String, dynamic> json) => PendingGait(
    horseIndex: json['horseIndex'] as int,
    choice: MovementChoice(json['steps'] as int),
    usesGrandGallop: json['usesGrandGallop'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'horseIndex': horseIndex,
    'steps': choice.steps,
    'usesGrandGallop': usesGrandGallop,
  };
}

/// Full logical state of one game — enough to serialize, close the app,
/// and resume identically later.
@immutable
class GameState {
  const GameState({
    required this.gameId,
    required this.gameMode,
    required this.gameVariant,
    required this.circuitId,
    required this.players,
    required this.currentPlayerIndex,
    required this.turnPhase,
    required this.askedQuestionIds,
    required this.startedAt,
    required this.updatedAt,
    this.currentQuestionId,
    this.pendingGait,
    this.pendingCellEffect,
    this.landedEffect,
    this.lastAnswerCorrect,
    this.lastMoveOutcome,
    this.justUnlocked = const [],
    this.winnerId,
    this.freeBankExhausted = false,
  });

  /// Bumped when the save format changes incompatibly. Version 1 was the
  /// old dice-based engine; version 2 is the gait engine. The loader uses
  /// this to detect a legacy save and offer a fresh game rather than
  /// silently discarding anything (spec §18).
  static const int schemaVersion = 2;

  final String gameId;
  final GameMode gameMode;
  final GameVariant gameVariant;

  final CircuitId circuitId;
  Circuit get circuit => Circuit.byId(circuitId);

  final List<Player> players;
  final int currentPlayerIndex;
  final TurnPhase turnPhase;

  final String? currentQuestionId;

  /// Every question id already asked this game — no repeats within a game.
  final Set<String> askedQuestionIds;

  /// The gait locked in for this turn, awaiting its question.
  final PendingGait? pendingGait;

  /// An interactive square is waiting on a player decision.
  final CellEffect? pendingCellEffect;

  /// The effect of the square the horse just landed on (including passive
  /// ones), for feedback.
  final CellEffect? landedEffect;

  final bool? lastAnswerCorrect;
  final MoveOutcome? lastMoveOutcome;

  /// Streak rewards unlocked by the answer just resolved, for celebration.
  final List<StreakReward> justUnlocked;

  final String? winnerId;

  /// True once the free edition's question bank is exhausted in this game:
  /// play continues uninterrupted, never paywalled mid-game.
  final bool freeBankExhausted;

  final DateTime startedAt;
  final DateTime updatedAt;

  Player get currentPlayer => players[currentPlayerIndex];

  GameState copyWith({
    List<Player>? players,
    int? currentPlayerIndex,
    TurnPhase? turnPhase,
    CircuitId? circuitId,
    Object? currentQuestionId = _unset,
    Set<String>? askedQuestionIds,
    Object? pendingGait = _unset,
    Object? pendingCellEffect = _unset,
    Object? landedEffect = _unset,
    Object? lastAnswerCorrect = _unset,
    Object? lastMoveOutcome = _unset,
    List<StreakReward>? justUnlocked,
    Object? winnerId = _unset,
    bool? freeBankExhausted,
    DateTime? updatedAt,
  }) {
    return GameState(
      gameId: gameId,
      gameMode: gameMode,
      gameVariant: gameVariant,
      circuitId: circuitId ?? this.circuitId,
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      turnPhase: turnPhase ?? this.turnPhase,
      currentQuestionId: identical(currentQuestionId, _unset)
          ? this.currentQuestionId
          : currentQuestionId as String?,
      askedQuestionIds: askedQuestionIds ?? this.askedQuestionIds,
      pendingGait: identical(pendingGait, _unset) ? this.pendingGait : pendingGait as PendingGait?,
      pendingCellEffect: identical(pendingCellEffect, _unset)
          ? this.pendingCellEffect
          : pendingCellEffect as CellEffect?,
      landedEffect: identical(landedEffect, _unset)
          ? this.landedEffect
          : landedEffect as CellEffect?,
      lastAnswerCorrect: identical(lastAnswerCorrect, _unset)
          ? this.lastAnswerCorrect
          : lastAnswerCorrect as bool?,
      lastMoveOutcome: identical(lastMoveOutcome, _unset)
          ? this.lastMoveOutcome
          : lastMoveOutcome as MoveOutcome?,
      justUnlocked: justUnlocked ?? this.justUnlocked,
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
    circuitId: CircuitId.values.byName(json['circuitId'] as String? ?? CircuitId.oasisRoute.name),
    players: (json['players'] as List)
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList(),
    currentPlayerIndex: json['currentPlayerIndex'] as int,
    turnPhase: TurnPhase.values.byName(json['turnPhase'] as String),
    currentQuestionId: json['currentQuestionId'] as String?,
    askedQuestionIds: Set<String>.from(json['askedQuestionIds'] as List),
    pendingGait: json['pendingGait'] == null
        ? null
        : PendingGait.fromJson(json['pendingGait'] as Map<String, dynamic>),
    pendingCellEffect: json['pendingCellEffect'] == null
        ? null
        : CellEffect.values.byName(json['pendingCellEffect'] as String),
    landedEffect: json['landedEffect'] == null
        ? null
        : CellEffect.values.byName(json['landedEffect'] as String),
    lastAnswerCorrect: json['lastAnswerCorrect'] as bool?,
    lastMoveOutcome: json['lastMoveOutcome'] == null
        ? null
        : MoveOutcome.values.byName(json['lastMoveOutcome'] as String),
    winnerId: json['winnerId'] as String?,
    freeBankExhausted: json['freeBankExhausted'] as bool? ?? false,
    startedAt: DateTime.parse(json['startedAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'gameId': gameId,
    'gameMode': gameMode.name,
    'gameVariant': gameVariant.name,
    'circuitId': circuitId.name,
    'players': players.map((p) => p.toJson()).toList(),
    'currentPlayerIndex': currentPlayerIndex,
    'turnPhase': turnPhase.name,
    'currentQuestionId': currentQuestionId,
    'askedQuestionIds': askedQuestionIds.toList(),
    'pendingGait': pendingGait?.toJson(),
    'pendingCellEffect': pendingCellEffect?.name,
    'landedEffect': landedEffect?.name,
    'lastAnswerCorrect': lastAnswerCorrect,
    'lastMoveOutcome': lastMoveOutcome?.name,
    'winnerId': winnerId,
    'freeBankExhausted': freeBankExhausted,
    'startedAt': startedAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

const Object _unset = Object();
