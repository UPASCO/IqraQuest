import 'package:flutter/foundation.dart';

import 'bonus_tile.dart';
import 'circuit.dart';
import 'game_mode.dart';
import 'knowledge_streak.dart';
import 'move_outcome.dart';
import 'movement_choice.dart';
import 'player.dart';
import 'turn_phase.dart';

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
    this.bonusTiles = const [],
    this.bonusSeed = 0,
    this.pendingBonus,
    this.bonusUsedThisTurn = false,
    this.lastBonusValue,
    this.movedHorseIndex,
    this.pendingCellEffect,
    this.pendingCellHorseIndex,
    this.landedEffect,
    this.lastAnswerCorrect,
    this.lastMoveOutcome,
    this.justUnlocked = const [],
    this.winnerId,
    this.freeBankExhausted = false,
    this.drawnCard,
    this.extraTurn = false,
    this.isBonusTurn = false,
    this.drawCount = 0,
    this.maxDraws,
    this.endedByDrawLimit = false,
  });

  /// How many cards a free-edition game lasts. The race then stops on
  /// the leader, and the results board says what Premium removes.
  static const int freeDrawLimit = 50;

  /// Bumped when the save format changes incompatibly. Version 1 was the
  /// old dice-based engine; version 2 the gait engine; version 3 adds the
  /// bonus squares and the answer-first turn. A version 2 save still
  /// loads — its positions are kept and its turn restarts at the deck —
  /// while version 1 is detected as legacy and offered a fresh game
  /// rather than silently discarded (spec §18).
  static const int schemaVersion = 3;

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

  /// The sixteen bonus squares of this game, fixed at the first draw and
  /// kept for the whole game (see `BonusLayout`).
  final List<BonusTile> bonusTiles;

  /// The seed [bonusTiles] were generated from: a save carries it, so
  /// the layout can be rebuilt, replayed and reproduced from a report.
  final int bonusSeed;

  /// A bonus square a horse has just landed on, waiting to be ridden.
  final PendingBonus? pendingBonus;

  /// At most one bonus square fires per turn: the extra ride it grants
  /// can land on another bonus square without setting it off.
  final bool bonusUsedThisTurn;

  /// The bonus ridden this turn, for the board's celebration.
  final int? lastBonusValue;

  /// Which of the current player's horses was set down this turn.
  final int? movedHorseIndex;

  /// An interactive square is waiting on a player decision.
  final CellEffect? pendingCellEffect;

  /// Which of the current player's horses landed on that square — the
  /// bonus movement must go to it, never to some other horse.
  final int? pendingCellHorseIndex;

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

  /// The card drawn this turn, from the draw until the turn ends. It is
  /// what the player is choosing a horse for, and what the opponent's
  /// turn is narrated from.
  final MovementChoice? drawnCard;

  /// A 6 was drawn this turn: when the turn ends, the same player draws
  /// again instead of handing over (the rule of the die, kept for the
  /// deck).
  final bool extraTurn;

  /// This turn IS the second draw a 6 earned, so the table can say so.
  final bool isBonusTurn;

  /// Cards drawn since the game started, every player counted.
  final int drawCount;

  /// The free edition's ceiling on [drawCount]; null for Premium, whose
  /// races run to Mecca.
  final int? maxDraws;

  /// The game ended because [maxDraws] was reached, not because a stable
  /// arrived: the winner is the leader at that moment.
  final bool endedByDrawLimit;

  final DateTime startedAt;
  final DateTime updatedAt;

  Player get currentPlayer => players[currentPlayerIndex];

  /// The bonus square at [trackIndex], if any.
  BonusTile? bonusAt(int trackIndex) {
    for (final b in bonusTiles) {
      if (b.trackIndex == trackIndex) return b;
    }
    return null;
  }

  /// The schema version a save was written with, for the loader.
  static int schemaVersionOf(Map<String, dynamic> json) =>
      json['schemaVersion'] as int? ?? 1;

  GameState copyWith({
    List<Player>? players,
    int? currentPlayerIndex,
    TurnPhase? turnPhase,
    CircuitId? circuitId,
    Object? currentQuestionId = _unset,
    Set<String>? askedQuestionIds,
    List<BonusTile>? bonusTiles,
    int? bonusSeed,
    Object? pendingBonus = _unset,
    bool? bonusUsedThisTurn,
    Object? lastBonusValue = _unset,
    Object? movedHorseIndex = _unset,
    Object? pendingCellEffect = _unset,
    Object? pendingCellHorseIndex = _unset,
    Object? landedEffect = _unset,
    Object? lastAnswerCorrect = _unset,
    Object? lastMoveOutcome = _unset,
    List<StreakReward>? justUnlocked,
    Object? winnerId = _unset,
    bool? freeBankExhausted,
    Object? drawnCard = _unset,
    bool? extraTurn,
    bool? isBonusTurn,
    int? drawCount,
    Object? maxDraws = _unset,
    bool? endedByDrawLimit,
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
      bonusTiles: bonusTiles ?? this.bonusTiles,
      bonusSeed: bonusSeed ?? this.bonusSeed,
      pendingBonus: identical(pendingBonus, _unset)
          ? this.pendingBonus
          : pendingBonus as PendingBonus?,
      bonusUsedThisTurn: bonusUsedThisTurn ?? this.bonusUsedThisTurn,
      lastBonusValue: identical(lastBonusValue, _unset)
          ? this.lastBonusValue
          : lastBonusValue as int?,
      movedHorseIndex: identical(movedHorseIndex, _unset)
          ? this.movedHorseIndex
          : movedHorseIndex as int?,
      pendingCellEffect: identical(pendingCellEffect, _unset)
          ? this.pendingCellEffect
          : pendingCellEffect as CellEffect?,
      pendingCellHorseIndex: identical(pendingCellHorseIndex, _unset)
          ? this.pendingCellHorseIndex
          : pendingCellHorseIndex as int?,
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
      winnerId: identical(winnerId, _unset)
          ? this.winnerId
          : winnerId as String?,
      freeBankExhausted: freeBankExhausted ?? this.freeBankExhausted,
      drawnCard: identical(drawnCard, _unset)
          ? this.drawnCard
          : drawnCard as MovementChoice?,
      extraTurn: extraTurn ?? this.extraTurn,
      isBonusTurn: isBonusTurn ?? this.isBonusTurn,
      drawCount: drawCount ?? this.drawCount,
      maxDraws: identical(maxDraws, _unset) ? this.maxDraws : maxDraws as int?,
      endedByDrawLimit: endedByDrawLimit ?? this.endedByDrawLimit,
      startedAt: startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
    gameId: json['gameId'] as String,
    gameMode: GameMode.values.byName(json['gameMode'] as String),
    gameVariant: GameVariant.values.byName(json['gameVariant'] as String),
    circuitId: CircuitId.values.byName(
      json['circuitId'] as String? ?? CircuitId.oasisRoute.name,
    ),
    players: (json['players'] as List)
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList(),
    currentPlayerIndex: json['currentPlayerIndex'] as int,
    turnPhase: TurnPhase.values.byName(json['turnPhase'] as String),
    currentQuestionId: json['currentQuestionId'] as String?,
    askedQuestionIds: Set<String>.from(json['askedQuestionIds'] as List),
    bonusTiles: [
      for (final b in (json['bonusTiles'] as List? ?? const []))
        BonusTile.fromJson(b as Map<String, dynamic>),
    ],
    bonusSeed: json['bonusSeed'] as int? ?? 0,
    pendingBonus: json['pendingBonus'] == null
        ? null
        : PendingBonus.fromJson(json['pendingBonus'] as Map<String, dynamic>),
    bonusUsedThisTurn: json['bonusUsedThisTurn'] as bool? ?? false,
    lastBonusValue: json['lastBonusValue'] as int?,
    movedHorseIndex: json['movedHorseIndex'] as int?,
    pendingCellEffect: json['pendingCellEffect'] == null
        ? null
        : CellEffect.values.byName(json['pendingCellEffect'] as String),
    pendingCellHorseIndex: json['pendingCellHorseIndex'] as int?,
    justUnlocked: [
      for (final r in (json['justUnlocked'] as List? ?? const []))
        StreakReward.values.byName(r as String),
    ],
    landedEffect: json['landedEffect'] == null
        ? null
        : CellEffect.values.byName(json['landedEffect'] as String),
    lastAnswerCorrect: json['lastAnswerCorrect'] as bool?,
    lastMoveOutcome: json['lastMoveOutcome'] == null
        ? null
        : MoveOutcome.values.byName(json['lastMoveOutcome'] as String),
    winnerId: json['winnerId'] as String?,
    freeBankExhausted: json['freeBankExhausted'] as bool? ?? false,
    drawnCard: json['drawnCard'] == null
        ? null
        : MovementChoice(json['drawnCard'] as int),
    extraTurn: json['extraTurn'] as bool? ?? false,
    isBonusTurn: json['isBonusTurn'] as bool? ?? false,
    drawCount: json['drawCount'] as int? ?? 0,
    maxDraws: json['maxDraws'] as int?,
    endedByDrawLimit: json['endedByDrawLimit'] as bool? ?? false,
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
    'bonusTiles': [for (final b in bonusTiles) b.toJson()],
    'bonusSeed': bonusSeed,
    'pendingBonus': pendingBonus?.toJson(),
    'bonusUsedThisTurn': bonusUsedThisTurn,
    'lastBonusValue': lastBonusValue,
    'movedHorseIndex': movedHorseIndex,
    'pendingCellEffect': pendingCellEffect?.name,
    'pendingCellHorseIndex': pendingCellHorseIndex,
    'justUnlocked': [for (final r in justUnlocked) r.name],
    'landedEffect': landedEffect?.name,
    'lastAnswerCorrect': lastAnswerCorrect,
    'lastMoveOutcome': lastMoveOutcome?.name,
    'winnerId': winnerId,
    'freeBankExhausted': freeBankExhausted,
    'drawnCard': drawnCard?.steps,
    'extraTurn': extraTurn,
    'isBonusTurn': isBonusTurn,
    'drawCount': drawCount,
    'maxDraws': maxDraws,
    'endedByDrawLimit': endedByDrawLimit,
    'startedAt': startedAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

const Object _unset = Object();
