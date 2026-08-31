import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../models/models.dart';
import '../../../services/board_effect_service.dart';
import '../../../services/game_save_service.dart';
import '../../../services/movement_choice_service.dart';
import '../../../services/progress_service.dart';
import '../../../services/question_repository.dart';
import '../domain/game_engine.dart';
import '../domain/horse_ai.dart';

/// Everything the presentation layer needs to render one turn.
@immutable
class GameSession {
  const GameSession({
    required this.gameState,
    this.currentQuestion,
    this.preview,
    this.isAiTurnInProgress = false,
    this.journeyHorseIndex,
  });

  final GameState gameState;

  /// The question currently on screen (a turn question, a bonus question
  /// from an interactive square, or a journey question).
  final Question? currentQuestion;

  /// What the gait the player is hovering would do, for the confirm step.
  final GaitPreview? preview;

  final bool isAiTurnInProgress;

  /// Set while a "Question du voyage" is being answered.
  final int? journeyHorseIndex;

  GameSession copyWith({
    GameState? gameState,
    Object? currentQuestion = _unset,
    Object? preview = _unset,
    bool? isAiTurnInProgress,
    Object? journeyHorseIndex = _unset,
  }) => GameSession(
    gameState: gameState ?? this.gameState,
    currentQuestion: identical(currentQuestion, _unset)
        ? this.currentQuestion
        : currentQuestion as Question?,
    preview: identical(preview, _unset) ? this.preview : preview as GaitPreview?,
    isAiTurnInProgress: isAiTurnInProgress ?? this.isAiTurnInProgress,
    journeyHorseIndex: identical(journeyHorseIndex, _unset)
        ? this.journeyHorseIndex
        : journeyHorseIndex as int?,
  );
}

const Object _unset = Object();

/// Orchestrates one game: wires [GameEngine] to question selection, AI
/// turns, autosave on every mutation, and progress tracking.
class GameController extends StateNotifier<GameSession?> {
  GameController({
    required this.engine,
    required this.questionRepository,
    required this.saveService,
    required this.progressService,
    this.movementChoices = const MovementChoiceService(),
    this.boardEffects = const BoardEffectService(),
    HorseAi? ai,
    Random? random,
  }) : ai = ai ?? HorseAi(),
       _random = random ?? Random(),
       super(null);

  final GameEngine engine;
  final QuestionRepository questionRepository;
  final GameSaveService saveService;
  final ProgressService progressService;
  final MovementChoiceService movementChoices;
  final BoardEffectService boardEffects;
  final HorseAi ai;
  final Random _random;

  List<Question> _pool = const [];
  bool _isPremium = false;

  void configure({required List<Question> pool, required bool isPremium}) {
    _pool = pool;
    _isPremium = isPremium;
  }

  // ---------------------------------------------------------------------
  // Game lifecycle
  // ---------------------------------------------------------------------

  void startNewGame({
    required GameMode mode,
    required GameVariant variant,
    required CircuitId circuitId,
    required List<Player> players,
  }) {
    final now = DateTime.now();
    final gameState = GameState(
      gameId: 'g_${now.microsecondsSinceEpoch}',
      gameMode: mode,
      gameVariant: variant,
      circuitId: circuitId,
      players: players,
      currentPlayerIndex: 0,
      turnPhase: TurnPhase.selectingGait,
      askedQuestionIds: const {},
      startedAt: now,
      updatedAt: now,
    );
    state = GameSession(gameState: gameState);
    _persist();
    _maybeRunAiTurn();
  }

  bool loadSaved() {
    final saved = saveService.load();
    if (saved == null || saved.turnPhase == TurnPhase.gameOver) return false;
    state = GameSession(gameState: saved);
    _maybeRunAiTurn();
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

  // ---------------------------------------------------------------------
  // Turn: choosing a gait
  // ---------------------------------------------------------------------

  List<MovementChoice> get availableGaits {
    final s = state;
    if (s == null) return const [];
    return engine.availableGaits(s.gameState.currentPlayer);
  }

  List<int> get movableHorses {
    final s = state;
    if (s == null) return const [];
    return engine.movableHorses(s.gameState.currentPlayer);
  }

  /// What a gait would do — used for the board hint and the confirmation
  /// step on bold gaits in child mode.
  GaitPreview? preview(int horseIndex, MovementChoice choice, {bool useGrandGallop = false}) {
    final s = state;
    if (s == null) return null;
    return engine.previewGait(s.gameState, horseIndex, choice, useGrandGallop: useGrandGallop);
  }

  /// The player commits to a horse and a gait; the matching question is
  /// drawn immediately.
  void selectGait(int horseIndex, MovementChoice choice, {bool useGrandGallop = false}) {
    final s = state;
    if (s == null || s.gameState.turnPhase != TurnPhase.selectingGait) return;

    final committed = engine.commitGait(
      s.gameState,
      horseIndex,
      choice,
      useGrandGallop: useGrandGallop,
    );
    final player = committed.currentPlayer;
    final difficulty = movementChoices.difficultyFor(choice, player.profile);
    final question = _drawQuestion(committed, difficulty);

    state = s.copyWith(
      gameState: question == null ? committed.copyWith(freeBankExhausted: true) : committed,
      currentQuestion: question,
      preview: engine.previewGait(s.gameState, horseIndex, choice, useGrandGallop: useGrandGallop),
    );
    _persist();

    // The free bank is spent: play continues uninterrupted rather than
    // being blocked or paywalled mid-game — the move simply succeeds.
    if (question == null) {
      _resolveAnswer(correct: true, questionId: 'free-bank-exhausted', category: null);
      return;
    }

    if (player.isAi) _runAiAnswer(player.aiDifficulty!, difficulty);
  }

  Question? _drawQuestion(GameState gameState, QuestionDifficulty difficulty) =>
      questionRepository.pickQuestion(
        pool: _pool,
        askedQuestionIds: gameState.askedQuestionIds,
        isPremium: _isPremium,
        difficulty: difficulty,
        random: _random,
      );

  // ---------------------------------------------------------------------
  // Turn: answering
  // ---------------------------------------------------------------------

  void answerQuestion(int selectedIndex) {
    final s = state;
    final question = s?.currentQuestion;
    if (s == null || question == null) return;
    _resolveAnswer(
      correct: question.isCorrect(selectedIndex),
      questionId: question.id,
      category: question.category,
    );
  }

  void _resolveAnswer({
    required bool correct,
    required String questionId,
    required QuestionCategory? category,
  }) {
    final s = state;
    if (s == null) return;

    if (category != null) {
      progressService.recordAnswer(correct: correct, category: category);
    }

    var next = engine.applyAnswer(s.gameState, correct: correct, questionId: questionId);

    // Track the player's strongest category so a 10-streak can award the
    // right mastery badge.
    if (correct && category != null) {
      final players = [...next.players];
      final player = players[next.currentPlayerIndex];
      final counts = {...player.answersByCategory};
      counts[category] = (counts[category] ?? 0) + 1;
      final rewards = next.justUnlocked.contains(StreakReward.masteryBadge)
          ? player.rewards.copyWith(
              masteryBadges: {...player.rewards.masteryBadges, player.dominantCategory ?? category},
            )
          : player.rewards;
      players[next.currentPlayerIndex] = player.copyWith(
        answersByCategory: counts,
        rewards: rewards,
      );
      next = next.copyWith(players: players);
    }

    // Passive squares apply the moment the horse lands.
    final landed = next.landedEffect;
    if (correct && landed != null && !boardEffects.isInteractive(landed)) {
      final bonus = boardEffects.bonusPointsFor(landed);
      if (bonus > 0 || landed == CellEffect.wisdom) {
        next = engine.collectFact(next, '${landed.name}:$questionId', bonusPoints: bonus);
      }
    }

    state = s.copyWith(gameState: next, preview: null);
    _persist();
  }

  /// Called once the player has read the explanation and source.
  void continueAfterFeedback() {
    final s = state;
    if (s == null) return;
    final gameState = s.gameState;

    // An interactive square is waiting on a decision.
    final pendingCell = gameState.pendingCellEffect;
    if (pendingCell != null &&
        boardEffects.isAvailableFor(
          pendingCell,
          playerCount: gameState.players.length,
          horseCount: gameState.currentPlayer.horses.length,
        )) {
      state = s.copyWith(
        gameState: gameState.copyWith(turnPhase: TurnPhase.resolvingCell),
        currentQuestion: null,
      );
      _persist();
      return;
    }

    // A horse that reached the finish owes its journey question.
    final awaiting = engine.horsesAwaitingJourneyQuestion(gameState.currentPlayer);
    if (awaiting.isNotEmpty) {
      startJourneyQuestion(awaiting.first);
      return;
    }

    _endTurn();
  }

  void _endTurn() {
    final s = state;
    if (s == null) return;
    final next = engine.endTurn(s.gameState);
    state = s.copyWith(
      gameState: next,
      currentQuestion: null,
      preview: null,
      journeyHorseIndex: null,
    );
    _persist();
    if (next.turnPhase == TurnPhase.gameOver) {
      final won = next.winnerId == next.players.first.id;
      progressService.recordGameEnd(won: won);
      return;
    }
    _maybeRunAiTurn();
  }

  // ---------------------------------------------------------------------
  // Interactive squares
  // ---------------------------------------------------------------------

  /// The player turned down an optional Défi / Raccourci, or a square had
  /// nothing to decide.
  void declineCellOffer() {
    final s = state;
    if (s == null) return;
    state = s.copyWith(gameState: engine.declineCellOffer(s.gameState), currentQuestion: null);
    _persist();
    continueAfterFeedback();
  }

  /// Draws the optional bonus question for a Défi or Raccourci square.
  void acceptCellChallenge() {
    final s = state;
    if (s == null) return;
    final effect = s.gameState.pendingCellEffect;
    if (effect == null) return;

    final profile = s.gameState.currentPlayer.profile;
    final difficulty = boardEffects.questionDifficultyFor(effect, profile);
    if (difficulty == null) {
      declineCellOffer();
      return;
    }
    final question = _drawQuestion(s.gameState, difficulty);
    if (question == null) {
      declineCellOffer();
      return;
    }
    state = s.copyWith(currentQuestion: question);
  }

  /// Resolves the optional bonus question the player accepted.
  void answerCellQuestion(int selectedIndex) {
    final s = state;
    final question = s?.currentQuestion;
    final effect = s?.gameState.pendingCellEffect;
    if (s == null || question == null || effect == null) return;

    final correct = question.isCorrect(selectedIndex);
    progressService.recordAnswer(correct: correct, category: question.category);

    final next = switch (effect) {
      CellEffect.challenge => engine.resolveChallenge(
        s.gameState,
        correct: correct,
        questionId: question.id,
      ),
      CellEffect.shortcut => engine.resolveShortcut(
        s.gameState,
        correct: correct,
        questionId: question.id,
        horseIndex: s.preview?.horseIndex ?? 0,
      ),
      _ => engine.declineCellOffer(s.gameState),
    };

    state = s.copyWith(gameState: next, currentQuestion: null);
    _persist();
  }

  /// A Relais square: hand the squares just earned to another horse.
  void resolveRelay({required int fromHorseIndex, required int toHorseIndex, required int steps}) {
    final s = state;
    if (s == null) return;
    state = s.copyWith(
      gameState: engine.resolveRelay(
        s.gameState,
        fromHorseIndex: fromHorseIndex,
        toHorseIndex: toHorseIndex,
        steps: steps,
      ),
    );
    _persist();
    _endTurn();
  }

  // ---------------------------------------------------------------------
  // Arrival
  // ---------------------------------------------------------------------

  void startJourneyQuestion(int horseIndex) {
    final s = state;
    if (s == null) return;
    final profile = s.gameState.currentPlayer.profile;
    final question = _drawQuestion(s.gameState, movementChoices.journeyDifficultyFor(profile));
    if (question == null) {
      // No question left to ask: the arrival simply stands.
      final next = engine.answerJourneyQuestion(
        s.gameState,
        correct: true,
        questionId: 'free-bank-exhausted',
        horseIndex: horseIndex,
      );
      state = s.copyWith(gameState: next, currentQuestion: null);
      _persist();
      if (next.turnPhase != TurnPhase.gameOver) _endTurn();
      return;
    }
    state = s.copyWith(
      gameState: s.gameState.copyWith(turnPhase: TurnPhase.answeringJourneyQuestion),
      currentQuestion: question,
      journeyHorseIndex: horseIndex,
    );
    _persist();

    final player = s.gameState.currentPlayer;
    if (player.isAi) {
      _runAiJourneyAnswer(player.aiDifficulty!, question);
    }
  }

  void answerJourneyQuestion(int selectedIndex) {
    final s = state;
    final question = s?.currentQuestion;
    final horseIndex = s?.journeyHorseIndex;
    if (s == null || question == null || horseIndex == null) return;

    final correct = question.isCorrect(selectedIndex);
    progressService.recordAnswer(correct: correct, category: question.category);

    final next = engine.answerJourneyQuestion(
      s.gameState,
      correct: correct,
      questionId: question.id,
      horseIndex: horseIndex,
    );
    state = s.copyWith(gameState: next);
    _persist();

    if (next.turnPhase == TurnPhase.gameOver) {
      progressService.recordGameEnd(won: next.winnerId == next.players.first.id);
    }
  }

  // ---------------------------------------------------------------------
  // AI turns — same engine, same visible options, never cheating
  // ---------------------------------------------------------------------

  void _maybeRunAiTurn() {
    final s = state;
    if (s == null) return;
    if (!s.gameState.currentPlayer.isAi) return;
    if (s.gameState.turnPhase != TurnPhase.selectingGait) return;
    _runAiGaitChoice();
  }

  Future<void> _runAiGaitChoice() async {
    final s = state;
    if (s == null) return;
    state = s.copyWith(isAiTurnInProgress: true);
    await Future<void>.delayed(const Duration(milliseconds: 550));

    final current = state;
    if (current == null || !current.gameState.currentPlayer.isAi) return;

    final decision = ai.chooseGait(
      state: current.gameState,
      engine: engine,
      difficulty: current.gameState.currentPlayer.aiDifficulty!,
    );
    state = current.copyWith(isAiTurnInProgress: false);
    selectGait(decision.horseIndex, decision.choice, useGrandGallop: decision.useGrandGallop);
  }

  Future<void> _runAiAnswer(AiDifficulty aiDifficulty, QuestionDifficulty _) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final s = state;
    final question = s?.currentQuestion;
    if (s == null || question == null) return;

    final correct = ai.decideAnswerCorrect(aiDifficulty);
    final index = correct
        ? question.correctAnswerIndex
        : (question.correctAnswerIndex + 1) % question.answers.length;
    answerQuestion(index);

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (state?.gameState.currentPlayer.isAi ?? false) _runAiCellDecision();
  }

  Future<void> _runAiJourneyAnswer(AiDifficulty aiDifficulty, Question question) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (state == null) return;
    final correct = ai.decideAnswerCorrect(aiDifficulty);
    answerJourneyQuestion(
      correct
          ? question.correctAnswerIndex
          : (question.correctAnswerIndex + 1) % question.answers.length,
    );
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (state?.gameState.turnPhase != TurnPhase.gameOver) _endTurn();
  }

  void _runAiCellDecision() {
    final s = state;
    if (s == null) return;
    final effect = s.gameState.pendingCellEffect;
    if (effect == null) {
      continueAfterFeedback();
      return;
    }
    // A confident opponent takes the optional challenge; a cautious one
    // banks what it already has.
    final difficulty = s.gameState.currentPlayer.aiDifficulty!;
    final takesIt = difficulty == AiDifficulty.hard;
    if (takesIt && (effect == CellEffect.challenge || effect == CellEffect.shortcut)) {
      acceptCellChallenge();
      final question = state?.currentQuestion;
      if (question != null) {
        final correct = ai.decideAnswerCorrect(difficulty);
        answerCellQuestion(
          correct
              ? question.correctAnswerIndex
              : (question.correctAnswerIndex + 1) % question.answers.length,
        );
      }
    }
    declineCellOffer();
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
