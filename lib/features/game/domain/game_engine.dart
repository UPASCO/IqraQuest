import 'dart:math';

import '../../../models/game_mode.dart';
import '../../../models/game_state.dart';
import '../../../models/pawn_position.dart';
import '../../../models/player.dart';
import '../../../models/turn_phase.dart';
import 'pawn_move.dart';

/// The single source of truth for IqraQuest's board-game rules.
///
/// Pure, deterministic (aside from [rollDice]) and platform-independent —
/// no widgets, no I/O. The same instance drives human players and every AI
/// difficulty (spec §35: "the AI never cheats, the dice stays impartial").
/// See spec §40–§48 for the rules encoded here, and `test/features/game`
/// for the behavioural test suite (spec §100).
class GameEngine {
  GameEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  int rollDice() => _random.nextInt(6) + 1;

  int teamIndexOf(GameState state, String playerId) =>
      state.players.indexWhere((p) => p.id == playerId);

  // ---------------------------------------------------------------------
  // Turn phase 1: question gate (spec §40)
  // ---------------------------------------------------------------------

  /// A correct answer unlocks the dice for the current player.
  GameState applyAnswerCorrect(GameState state, {required String questionId}) {
    return state.copyWith(
      turnPhase: TurnPhase.waitingForDice,
      currentQuestionId: questionId,
      askedQuestionIds: {...state.askedQuestionIds, questionId},
      updatedAt: DateTime.now(),
    );
  }

  /// A wrong answer forfeits this player's roll; the turn passes on.
  GameState applyAnswerIncorrect(GameState state, {required String questionId}) {
    final marked = state.copyWith(
      turnPhase: TurnPhase.turnComplete,
      currentQuestionId: questionId,
      askedQuestionIds: {...state.askedQuestionIds, questionId},
      lastDiceValue: null,
      updatedAt: DateTime.now(),
    );
    return _endTurn(marked, rolledSix: false);
  }

  /// Free-edition escape hatch (spec §49): once the 50-question free bank
  /// is exhausted mid-game, the dice unlocks without a question for the
  /// rest of *this* game — the game is never interrupted or paywalled
  /// mid-play.
  GameState allowDiceWithoutQuestion(GameState state) {
    return state.copyWith(
      turnPhase: TurnPhase.waitingForDice,
      currentQuestionId: null,
      freeBankExhausted: true,
      updatedAt: DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------
  // Turn phase 2: dice + movement (spec §41–§46)
  // ---------------------------------------------------------------------

  /// Rolls the dice for the current player and computes legal moves.
  /// If none exist, the turn is immediately resolved (still respecting the
  /// "6 grants another question" rule).
  ({GameState state, int diceValue, List<PawnMove> legalMoves}) applyDiceRoll(GameState state) {
    final diceValue = rollDice();
    return applyKnownDiceRoll(state, diceValue);
  }

  /// Same as [applyDiceRoll] but with a pre-determined value — used by
  /// tests and by deterministic replays.
  ({GameState state, int diceValue, List<PawnMove> legalMoves}) applyKnownDiceRoll(
    GameState state,
    int diceValue,
  ) {
    assert(diceValue >= 1 && diceValue <= 6);
    final moves = legalMoves(state, diceValue);
    var next = state.copyWith(lastDiceValue: diceValue, updatedAt: DateTime.now());
    if (moves.isEmpty) {
      next = next.copyWith(turnPhase: TurnPhase.turnComplete);
      next = _endTurn(next, rolledSix: diceValue == 6);
    } else {
      next = next.copyWith(turnPhase: TurnPhase.waitingForPawnSelection);
    }
    return (state: next, diceValue: diceValue, legalMoves: moves);
  }

  /// All legal moves for the current player given [diceValue]. Never
  /// includes an overshoot past the finish (spec §45) or a move onto a
  /// square already held by the mover's own pawn.
  List<PawnMove> legalMoves(GameState state, int diceValue) {
    final player = state.currentPlayer;
    final teamIndex = state.players.indexOf(player);
    final entry = BoardGeometry.entryIndexForTeam(teamIndex);
    final moves = <PawnMove>[];

    for (var i = 0; i < player.pawns.length; i++) {
      final from = player.pawns[i];
      final to = _destinationFor(from, diceValue, entry);
      if (to == null) continue; // overshoot or dice==6 required but absent
      if (_ownPawnOccupies(player, i, to)) continue;

      final capture = _captureAt(state, player.id, to);
      moves.add(
        PawnMove(
          playerId: player.id,
          pawnIndex: i,
          from: from,
          to: to,
          capturedPlayerId: capture?.$1,
          capturedPawnIndex: capture?.$2,
        ),
      );
    }
    return moves;
  }

  PawnPosition? _destinationFor(PawnPosition from, int dice, int entry) {
    return switch (from) {
      HomePosition() => dice == 6 ? TrackPosition(entry) : null,
      TrackPosition(:final index) => _advanceFromTrack(index, dice, entry),
      FinalLanePosition(:final step) => _advanceFromFinalLane(step, dice),
      FinishedPosition() => null,
    };
  }

  PawnPosition? _advanceFromTrack(int index, int dice, int entry) {
    final p = (index - entry) % BoardGeometry.trackLength;
    final newP = p + dice;
    if (newP <= BoardGeometry.trackLength - 1) {
      return TrackPosition((entry + newP) % BoardGeometry.trackLength);
    }
    final laneStep = newP - (BoardGeometry.trackLength - 1);
    if (laneStep < BoardGeometry.finalLaneLength) {
      return FinalLanePosition(laneStep);
    }
    if (laneStep == BoardGeometry.finalLaneLength) {
      return const FinishedPosition();
    }
    return null; // overshoot — illegal
  }

  PawnPosition? _advanceFromFinalLane(int step, int dice) {
    final newStep = step + dice;
    if (newStep == BoardGeometry.finalLaneLength + 1) {
      return const FinishedPosition();
    }
    if (newStep <= BoardGeometry.finalLaneLength) {
      return FinalLanePosition(newStep);
    }
    return null; // overshoot — illegal, exact count required (spec §45)
  }

  bool _ownPawnOccupies(Player player, int movingPawnIndex, PawnPosition to) {
    if (to is! TrackPosition) return false;
    for (var i = 0; i < player.pawns.length; i++) {
      if (i == movingPawnIndex) continue;
      if (player.pawns[i] == to) return true;
    }
    return false;
  }

  (String, int)? _captureAt(GameState state, String movingPlayerId, PawnPosition to) {
    if (to is! TrackPosition || to.isProtected) return null;
    for (final other in state.players) {
      if (other.id == movingPlayerId) continue;
      for (var i = 0; i < other.pawns.length; i++) {
        if (other.pawns[i] == to) return (other.id, i);
      }
    }
    return null;
  }

  /// Commits one [PawnMove]: relocates the pawn, sends a captured opponent
  /// pawn back to its stable, and checks for victory (spec §47).
  GameState applyMove(GameState state, PawnMove move) {
    var players = List<Player>.from(state.players);

    final moverIdx = players.indexWhere((p) => p.id == move.playerId);
    final mover = players[moverIdx];
    final newPawns = List<PawnPosition>.from(mover.pawns);
    newPawns[move.pawnIndex] = move.to;
    players[moverIdx] = mover.copyWith(pawns: newPawns);

    if (move.isCapture) {
      final capturedIdx = players.indexWhere((p) => p.id == move.capturedPlayerId);
      final captured = players[capturedIdx];
      final capturedPawns = List<PawnPosition>.from(captured.pawns);
      capturedPawns[move.capturedPawnIndex!] = const HomePosition();
      players[capturedIdx] = captured.copyWith(pawns: capturedPawns);
    }

    final winner = players.firstWhere((p) => p.id == move.playerId);
    final won = hasPlayerWon(winner, state.gameVariant);

    var next = state.copyWith(
      players: players,
      turnPhase: TurnPhase.turnComplete,
      winnerId: won ? winner.id : null,
      updatedAt: DateTime.now(),
    );

    if (won) {
      return next.copyWith(turnPhase: TurnPhase.gameOver);
    }

    return _endTurn(next, rolledSix: state.lastDiceValue == 6);
  }

  bool hasPlayerWon(Player player, GameVariant variant) => switch (variant) {
    GameVariant.quick => player.pawns.any((p) => p is FinishedPosition),
    GameVariant.classic => player.pawns.every((p) => p is FinishedPosition),
  };

  /// Rolling a 6 grants another turn for the *same* player, but always
  /// gated by a fresh question (spec §46: never two rolls from one
  /// correct answer). Any other value passes the turn to the next player.
  GameState _endTurn(GameState state, {required bool rolledSix}) {
    if (state.turnPhase == TurnPhase.gameOver) return state;
    if (rolledSix) {
      return state.copyWith(
        turnPhase: TurnPhase.waitingForQuestion,
        currentQuestionId: null,
        lastDiceValue: null,
      );
    }
    final nextIndex = (state.currentPlayerIndex + 1) % state.players.length;
    return state.copyWith(
      currentPlayerIndex: nextIndex,
      turnPhase: TurnPhase.waitingForQuestion,
      currentQuestionId: null,
      lastDiceValue: null,
    );
  }

  /// Public wrapper so the presentation layer can resolve a turn after an
  /// animation completes (phase [TurnPhase.animatingMove] →
  /// [TurnPhase.turnComplete] → next phase).
  GameState completeAnimatedMove(GameState state) {
    if (state.turnPhase == TurnPhase.gameOver) return state;
    return _endTurn(state, rolledSix: state.lastDiceValue == 6);
  }
}
