import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../models/models.dart';
import '../../../services/game_save_service.dart';
import '../../../services/progress_service.dart';
import '../../../services/question_repository.dart';
import '../domain/game_engine.dart';
import '../domain/horse_ai.dart';
import '../domain/pawn_move.dart';

/// Everything the presentation layer needs to render one turn. [gameState]
/// is what gets persisted; [currentQuestion] and [legalMoves] are
/// transient UI-facing context derived from it.
@immutable
class GameSession {
  const GameSession({
    required this.gameState,
    this.currentQuestion,
    this.legalMoves = const [],
    this.lastAnswerCorrect,
    this.isAiTurnInProgress = false,
  });

  final GameState gameState;
  final Question? currentQuestion;
  final List<PawnMove> legalMoves;
  final bool? lastAnswerCorrect;
  final bool isAiTurnInProgress;

  GameSession copyWith({
    GameState? gameState,
    Object? currentQuestion = _unset,
    List<PawnMove>? legalMoves,
    Object? lastAnswerCorrect = _unset,
    bool? isAiTurnInProgress,
  }) {
    return GameSession(
      gameState: gameState ?? this.gameState,
      currentQuestion: identical(currentQuestion, _unset)
          ? this.currentQuestion
          : currentQuestion as Question?,
      legalMoves: legalMoves ?? this.legalMoves,
      lastAnswerCorrect: identical(lastAnswerCorrect, _unset)
          ? this.lastAnswerCorrect
          : lastAnswerCorrect as bool?,
      isAiTurnInProgress: isAiTurnInProgress ?? this.isAiTurnInProgress,
    );
  }
}

const Object _unset = Object();

/// Orchestrates one game: wraps [GameEngine] with question selection, AI
/// turns, autosave-on-every-mutation (spec §80), and progress tracking.
class GameController extends StateNotifier<GameSession?> {
  GameController({
    required this.engine,
    required this.questionRepository,
    required this.saveService,
    required this.progressService,
    HorseAi? ai,
    Random? random,
  }) : ai = ai ?? HorseAi(),
       _random = random ?? Random(),
       super(null);

  final GameEngine engine;
  final QuestionRepository questionRepository;
  final GameSaveService saveService;
  final ProgressService progressService;
  final HorseAi ai;
  final Random _random;

  List<Question> _pool = const [];
  bool _isPremium = false;

  void configure({required List<Question> pool, required bool isPremium}) {
    _pool = pool;
    _isPremium = isPremium;
  }

  void startNewGame({
    required GameMode mode,
    required GameVariant variant,
    required List<Player> players,
  }) {
    final now = DateTime.now();
    final gameState = GameState(
      gameId: 'g_${now.microsecondsSinceEpoch}',
      gameMode: mode,
      gameVariant: variant,
      players: players,
      currentPlayerIndex: 0,
      turnPhase: TurnPhase.waitingForQuestion,
      askedQuestionIds: const {},
      startedAt: now,
      updatedAt: now,
    );
    state = GameSession(gameState: gameState);
    _persist();
    _beginTurn();
  }

  bool loadSaved() {
    final saved = saveService.load();
    if (saved == null || saved.turnPhase == TurnPhase.gameOver) return false;
    state = GameSession(gameState: saved);
    _beginTurn();
    return true;
  }

  void _persist() {
    final s = state;
    if (s == null) return;
    if (s.gameState.turnPhase == TurnPhase.gameOver) {
      saveService.clear();
    } else {
      saveService.save(s.gameState);
    }
  }

  void _beginTurn() {
    final s = state;
    if (s == null || s.gameState.turnPhase == TurnPhase.gameOver) return;

    if (questionRepository.isFreeBankExhausted(
          pool: _pool,
          askedQuestionIds: s.gameState.askedQuestionIds,
        ) &&
        !_isPremium) {
      final next = engine.allowDiceWithoutQuestion(s.gameState);
      state = s.copyWith(gameState: next, currentQuestion: null, lastAnswerCorrect: null);
      _persist();
      _maybeRunAiTurn();
      return;
    }

    final question = questionRepository.pickQuestion(
      pool: _pool,
      askedQuestionIds: s.gameState.askedQuestionIds,
      isPremium: _isPremium,
      random: _random,
    );
    state = s.copyWith(currentQuestion: question, lastAnswerCorrect: null);

    if (s.gameState.currentPlayer.isAi) {
      _runAiQuestionAndDice();
    }
  }

  /// Called by the UI when a human selects an answer tile.
  void answerQuestion(int selectedIndex) {
    final s = state;
    final question = s?.currentQuestion;
    if (s == null || question == null) return;

    final correct = question.isCorrect(selectedIndex);
    progressService.recordAnswer(correct: correct, category: question.category);

    final nextState = correct
        ? engine.applyAnswerCorrect(s.gameState, questionId: question.id)
        : engine.applyAnswerIncorrect(s.gameState, questionId: question.id);

    state = s.copyWith(gameState: nextState, lastAnswerCorrect: correct);
    _persist();
    // The engine has already unlocked the dice (correct) or passed the
    // turn (incorrect); either way we wait for the human to acknowledge
    // the explanation/source before moving on — see [continueAfterFeedback].
  }

  /// Called once the question feedback (explanation/source) has been
  /// read, whether the answer was correct (unlocks the dice) or not (the
  /// engine already passed the turn — this starts the next one).
  void continueAfterFeedback() {
    final s = state;
    if (s == null) return;
    if (s.lastAnswerCorrect == false) {
      _beginTurn();
    }
    // If correct, the UI calls rollDice() directly when the player taps
    // the dice; nothing to do here besides having surfaced the feedback.
  }

  /// Called once the question feedback (explanation/source) has been
  /// dismissed after a correct answer, or to roll after the free-bank
  /// fallback.
  void rollDice() {
    final s = state;
    if (s == null || s.gameState.turnPhase != TurnPhase.waitingForDice) return;

    final result = engine.applyDiceRoll(s.gameState);
    state = s.copyWith(gameState: result.state, legalMoves: result.legalMoves);
    _persist();

    if (result.legalMoves.isEmpty) {
      _afterTurnResolved();
    } else if (result.state.currentPlayer.isAi) {
      _aiChooseMove(result.legalMoves);
    }
  }

  void selectPawn(PawnMove move) {
    final s = state;
    if (s == null) return;
    final next = engine.applyMove(s.gameState, move);
    state = s.copyWith(gameState: next, legalMoves: const []);
    _persist();
    _afterTurnResolved();
  }

  void _afterTurnResolved() {
    final s = state;
    if (s == null) return;
    if (s.gameState.turnPhase == TurnPhase.gameOver) {
      final won = s.gameState.winnerId == s.gameState.players.first.id;
      progressService.recordGameEnd(won: won);
      return;
    }
    state = s.copyWith(currentQuestion: null);
    _beginTurn();
  }

  // ---------------------------------------------------------------------
  // AI turns — same engine, never cheats (spec §35).
  // ---------------------------------------------------------------------

  void _maybeRunAiTurn() {
    final s = state;
    if (s == null || !s.gameState.currentPlayer.isAi) return;
    rollDice();
  }

  Future<void> _runAiQuestionAndDice() async {
    final s = state;
    final question = s?.currentQuestion;
    final player = s?.gameState.currentPlayer;
    if (s == null || question == null || player == null) return;

    state = s.copyWith(isAiTurnInProgress: true);
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final correct = ai.decideAnswerCorrect(player.aiDifficulty!);
    final afterAnswer = correct
        ? engine.applyAnswerCorrect(state!.gameState, questionId: question.id)
        : engine.applyAnswerIncorrect(state!.gameState, questionId: question.id);

    state = state!.copyWith(
      gameState: afterAnswer,
      lastAnswerCorrect: correct,
      isAiTurnInProgress: false,
    );
    progressService.recordAnswer(correct: correct, category: question.category);
    _persist();

    if (!correct) {
      _beginTurn();
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 400));
    rollDice();
  }

  Future<void> _aiChooseMove(List<PawnMove> legalMoves) async {
    final s = state;
    if (s == null) return;
    final player = s.gameState.currentPlayer;
    state = s.copyWith(isAiTurnInProgress: true);
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final move = ai.chooseMove(
      legalMoves: legalMoves,
      difficulty: player.aiDifficulty!,
      state: s.gameState,
    );
    state = state!.copyWith(isAiTurnInProgress: false);
    selectPawn(move);
  }
}

final gameControllerProvider = StateNotifierProvider<GameController, GameSession?>((ref) {
  return GameController(
    engine: ref.watch(gameEngineProvider),
    questionRepository: ref.watch(questionRepositoryProvider),
    saveService: ref.watch(gameSaveServiceProvider),
    progressService: ref.watch(progressServiceProvider),
  );
});
