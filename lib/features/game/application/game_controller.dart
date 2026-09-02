import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../models/models.dart';
import '../../../services/board_effect_service.dart';
import '../../../services/game_save_service.dart';
import '../../../services/movement_choice_service.dart';
import '../../../services/progress_service.dart';
import '../../../services/question_deck.dart';
import '../../../services/question_repository.dart';
import '../domain/game_engine.dart';
import '../domain/horse_ai.dart';

/// How long a card that can move nothing stays on the table before the
/// turn passes by itself: long enough to read "no 5, no 6", short enough
/// that a stable full of horses is not a stable full of waiting.
const Duration kNoMoveBeat = Duration(milliseconds: 2500);

/// Everything the presentation layer needs to render one turn.
@immutable
class GameSession {
  const GameSession({
    required this.gameState,
    this.currentQuestion,
    this.preview,
    this.isAiTurnInProgress = false,
    this.journeyHorseIndex,
    this.journeyAttemptedHorses = const {},
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

  /// Horses whose journey question was already attempted THIS turn — a
  /// missed one is retried on a later turn, never in a loop (spec §10).
  final Set<int> journeyAttemptedHorses;

  GameSession copyWith({
    GameState? gameState,
    Object? currentQuestion = _unset,
    Object? preview = _unset,
    bool? isAiTurnInProgress,
    Object? journeyHorseIndex = _unset,
    Set<int>? journeyAttemptedHorses,
  }) => GameSession(
    gameState: gameState ?? this.gameState,
    currentQuestion: identical(currentQuestion, _unset)
        ? this.currentQuestion
        : currentQuestion as Question?,
    preview: identical(preview, _unset)
        ? this.preview
        : preview as GaitPreview?,
    isAiTurnInProgress: isAiTurnInProgress ?? this.isAiTurnInProgress,
    journeyHorseIndex: identical(journeyHorseIndex, _unset)
        ? this.journeyHorseIndex
        : journeyHorseIndex as int?,
    journeyAttemptedHorses:
        journeyAttemptedHorses ?? this.journeyAttemptedHorses,
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

  /// The draw pile for this game. Rebuilt whenever the playable bank
  /// changes — buying Premium mid-game widens it immediately.
  QuestionDeck? _deck;

  void configure({required List<Question> pool, required bool isPremium}) {
    _pool = pool;
    _isPremium = isPremium;
    // Free players draw from the free bank only; the die is the same six
    // faces for everyone, so nothing about the ride changes.
    _deck = QuestionDeck(
      pool: isPremium ? pool : pool.where((q) => q.isFree).toList(),
      random: _random,
    );
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
      // The free edition is a race of fifty cards; Premium runs to Mecca.
      maxDraws: _isPremium ? null : GameState.freeDrawLimit,
      startedAt: now,
      updatedAt: now,
    );
    state = GameSession(gameState: gameState);
    _persist();
    _beginTurn();
  }

  /// Starts the finished game over with the same riders, the same board
  /// and the same format — the "again!" at the end of a game, which has
  /// to be one tap or it is never said.
  ///
  /// Every rider starts back in the stable with a clean streak and an
  /// empty satchel: rewards are earned by knowledge inside a game, and
  /// carrying them over would let the last game decide the next one.
  bool restartSameSetup() {
    final s = state;
    if (s == null) return false;
    final previous = s.gameState;
    startNewGame(
      mode: previous.gameMode,
      variant: previous.gameVariant,
      circuitId: previous.circuitId,
      players: [
        for (final p in previous.players)
          p.copyWith(
            horses: [for (final _ in p.horses) const HorseState()],
            streak: const KnowledgeStreak(),
            rewards: const RewardInventory(),
            answersByCategory: const {},
          ),
      ],
    );
    return true;
  }

  bool loadSaved() {
    var saved = saveService.load();
    if (saved == null || saved.turnPhase == TurnPhase.gameOver) return false;
    // A save can be written while a question is on screen, but the
    // question text itself is never persisted — resume at the nearest
    // safe decision point instead of a phase with nothing to tap.
    saved = switch (saved.turnPhase) {
      // The gait is only consumed when the answer resolves, so backing
      // out to gait selection loses nothing.
      TurnPhase.answeringQuestion => saved.copyWith(
        turnPhase: TurnPhase.selectingGait,
        pendingGait: null,
      ),
      // The journey question is re-asked by _beginTurn below.
      TurnPhase.answeringJourneyQuestion => saved.copyWith(
        turnPhase: TurnPhase.selectingGait,
      ),
      // The move already happened; the turn simply concludes.
      TurnPhase.showingFeedback ||
      TurnPhase.turnComplete => engine.endTurn(saved),
      // A card that could move nothing has been seen: the turn passes.
      TurnPhase.noMove => engine.endTurn(saved),
      // The card is on the table and the choice is still open: it is
      // persisted, so the player resumes exactly there. (An opponent's
      // choice is made again by _beginTurn.)
      _ => saved,
    };
    if (saved.turnPhase == TurnPhase.gameOver) return false;
    state = GameSession(gameState: saved);
    _persist();
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
  GaitPreview? preview(
    int horseIndex,
    MovementChoice choice, {
    bool useGrandGallop = false,
  }) {
    final s = state;
    if (s == null) return null;
    return engine.previewGait(
      s.gameState,
      horseIndex,
      choice,
      useGrandGallop: useGrandGallop,
    );
  }

  /// What the drawn card can do, for the choice sheet and the board.
  List<LegalMove> get legalMoves {
    final s = state;
    final card = s?.gameState.drawnCard;
    if (s == null || card == null) return const [];
    return engine.legalMoves(s.gameState, card);
  }

  /// Draws this turn's card.
  ///
  /// The card's value is both how far a horse rides and how hard its
  /// question is: drawing replaces rolling a die. What happens next
  /// depends on what the value can do — nothing (the turn passes after
  /// a beat), one thing (it is committed straight away), or several
  /// (the turn waits for [chooseMove]).
  void drawCard() {
    final s = state;
    if (s == null || s.gameState.turnPhase != TurnPhase.selectingGait) return;

    final level = s.gameState.currentPlayer.profile.difficulty;
    final card = _deck?.draw(level);
    if (card == null) {
      // No playable question at all: the turn still resolves rather than
      // stalling or paywalling mid-game. A 6 gets a horse out (without
      // its replay — no deck, no second draw); nothing else is drawn, so
      // the move is the whole turn.
      final choice = const MovementChoice(6);
      final drawn = engine
          .drawCard(s.gameState, choice)
          .copyWith(freeBankExhausted: true, extraTurn: s.gameState.extraTurn);
      state = s.copyWith(gameState: drawn);
      _persist();
      final moves = legalMoves;
      if (moves.isEmpty) {
        _armNoMoveBeat();
        return;
      }
      final committed = engine
          .commitGait(drawn, moves.first.horseIndex, choice)
          .copyWith(extraTurn: s.gameState.extraTurn);
      state = state!.copyWith(gameState: committed);
      _persist();
      _resolveAnswer(
        correct: true,
        questionId: 'free-bank-exhausted',
        category: null,
      );
      continueAfterFeedback();
      return;
    }

    final choice = MovementChoice(card.value);
    // The card sets the distance for everyone; the question on it was
    // dealt at the rider's own level. A seven-year-old who draws a 6
    // rides six squares like anyone else and answers an easy question
    // for it; an expert who draws a 1 still faces an expert question.
    final dealt = card.question;

    final drawn = engine.drawCard(s.gameState, choice);
    state = s.copyWith(
      gameState: drawn,
      // The bank stores correct answers at index 0: shuffle on draw so
      // the on-screen order never gives the answer away. Held until a
      // horse is chosen; the sheet only opens once the move is known.
      currentQuestion: dealt.withShuffledAnswers(_random),
      preview: null,
    );
    _persist();

    final moves = legalMoves;
    if (moves.isEmpty) {
      _armNoMoveBeat();
      return;
    }
    // Exits are interchangeable: every horse in the stable is the same
    // horse to bring out. One exit plus nothing else is no choice.
    final distinct = <LegalMove>[];
    var exitSeen = false;
    for (final m in moves) {
      if (m.exitsStable) {
        if (exitSeen) continue;
        exitSeen = true;
      }
      distinct.add(m);
    }
    if (distinct.length == 1) {
      chooseMove(distinct.first.horseIndex);
      return;
    }
    final player = drawn.currentPlayer;
    if (player.isAi) _runAiMoveChoice();
  }

  /// Commits the drawn card to [horseIndex]: out of the stable, or the
  /// card's distance along the course. Then the question opens.
  void chooseMove(int horseIndex) {
    final s = state;
    if (s == null || s.gameState.turnPhase != TurnPhase.choosingHorse) return;
    final card = s.gameState.drawnCard;
    if (card == null) return;
    if (!legalMoves.any((m) => m.horseIndex == horseIndex)) return;

    // A Grand Galop is spent on exactly the terms the opponent spends
    // it on: only when it turns this move into an arrival.
    final useGrandGallop =
        s.gameState.currentPlayer.rewards.hasGrandGallop &&
        engine
            .previewGait(s.gameState, horseIndex, card, useGrandGallop: true)
            .reachesFinish;
    final committed = engine.commitGait(
      s.gameState,
      horseIndex,
      card,
      useGrandGallop: useGrandGallop,
    );
    // A game resumed mid-choice comes back without its question (the
    // text is never persisted): deal one now at the rider's level.
    final question =
        s.currentQuestion ??
        _drawQuestion(committed, committed.currentPlayer.profile.difficulty);
    state = s.copyWith(
      gameState: question == null
          ? committed.copyWith(freeBankExhausted: true)
          : committed,
      currentQuestion: question,
      preview: engine.previewGait(
        s.gameState,
        horseIndex,
        card,
        useGrandGallop: useGrandGallop,
      ),
    );
    _persist();

    if (question == null) {
      _resolveAnswer(
        correct: true,
        questionId: 'free-bank-exhausted',
        category: null,
      );
      continueAfterFeedback();
      return;
    }
    final player = committed.currentPlayer;
    if (player.isAi) _runAiAnswer(player.aiDifficulty!, question.difficulty);
  }

  /// The card on the table can move nothing: it stays in view for one
  /// beat, then the turn passes on its own. Tapping through
  /// ([continueAfterFeedback]) ends it sooner.
  void _armNoMoveBeat() {
    _noMoveTimer?.cancel();
    _noMoveTimer = Timer(kNoMoveBeat, () {
      if (!mounted) return;
      if (state?.gameState.turnPhase == TurnPhase.noMove) _endTurn();
    });
  }

  Timer? _noMoveTimer;

  @override
  void dispose() {
    _noMoveTimer?.cancel();
    super.dispose();
  }

  /// Commits a horse and an explicit distance. Kept for the flows that
  /// still name their own value — the AI turn and the tests.
  void selectGait(
    int horseIndex,
    MovementChoice choice, {
    bool useGrandGallop = false,
  }) {
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
      gameState: question == null
          ? committed.copyWith(freeBankExhausted: true)
          : committed,
      currentQuestion: question,
      preview: engine.previewGait(
        s.gameState,
        horseIndex,
        choice,
        useGrandGallop: useGrandGallop,
      ),
    );
    _persist();

    // The bank holds no question of this difficulty at all (it recycles
    // before that — see _drawQuestion): play continues uninterrupted
    // rather than being blocked or paywalled mid-game.
    if (question == null) {
      _resolveAnswer(
        correct: true,
        questionId: 'free-bank-exhausted',
        category: null,
      );
      // No feedback screen exists for a question that was never shown:
      // the turn moves straight along.
      continueAfterFeedback();
      return;
    }

    if (player.isAi) _runAiAnswer(player.aiDifficulty!, difficulty);
  }

  Question? _drawQuestion(GameState gameState, QuestionDifficulty difficulty) {
    final fresh = questionRepository.pickQuestion(
      pool: _pool,
      askedQuestionIds: gameState.askedQuestionIds,
      isPremium: _isPremium,
      difficulty: difficulty,
      random: _random,
    );
    // The bank stores correct answers at index 0: shuffle on draw so the
    // on-screen order never gives the answer away.
    if (fresh != null) return fresh.withShuffledAnswers(_random);
    // Every question of this difficulty has been asked once this game
    // (quick in the free edition): recycle rather than degrade into
    // questionless moves — bonuses must come from knowledge, always.
    return questionRepository
        .pickQuestion(
          pool: _pool,
          askedQuestionIds: const {},
          isPremium: _isPremium,
          difficulty: difficulty,
          random: _random,
        )
        ?.withShuffledAnswers(_random);
  }

  // ---------------------------------------------------------------------
  // Turn: answering
  // ---------------------------------------------------------------------

  void answerQuestion(int selectedIndex) {
    final s = state;
    final question = s?.currentQuestion;
    if (s == null || question == null) return;
    // Only one resolution per question: a double-tap during feedback
    // must not re-award points or re-run the landing effect.
    if (s.gameState.turnPhase != TurnPhase.answeringQuestion) return;
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

    var next = engine.applyAnswer(
      s.gameState,
      correct: correct,
      questionId: questionId,
    );

    // Track the player's strongest category so a 10-streak can award the
    // right mastery badge.
    if (correct && category != null) {
      final players = [...next.players];
      final player = players[next.currentPlayerIndex];
      final counts = {...player.answersByCategory};
      counts[category] = (counts[category] ?? 0) + 1;
      // The badge honours the strongest category INCLUDING the answer
      // that just completed the streak.
      QuestionCategory dominant = category;
      var best = -1;
      counts.forEach((c, n) {
        if (n > best) {
          best = n;
          dominant = c;
        }
      });
      final rewards = next.justUnlocked.contains(StreakReward.masteryBadge)
          ? player.rewards.copyWith(
              masteryBadges: {...player.rewards.masteryBadges, dominant},
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
        next = engine.collectFact(
          next,
          '${landed.name}:$questionId',
          bonusPoints: bonus,
        );
      }
    }

    state = s.copyWith(gameState: next, preview: null);
    _persist();
  }

  /// Called once the player has read the explanation and source — or
  /// tapped through a card that could move nothing.
  void continueAfterFeedback() {
    final s = state;
    if (s == null) return;
    final gameState = s.gameState;

    if (gameState.turnPhase == TurnPhase.noMove) {
      _noMoveTimer?.cancel();
      _endTurn();
      return;
    }
    // Waiting on a horse choice: there is nothing to continue from.
    if (gameState.turnPhase == TurnPhase.choosingHorse) return;

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

    // A horse that reached the finish owes its journey question — but at
    // most once per turn: a missed one is retried on a LATER turn.
    final awaiting = engine
        .horsesAwaitingJourneyQuestion(gameState.currentPlayer)
        .where((h) => !s.journeyAttemptedHorses.contains(h));
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
      journeyAttemptedHorses: const {},
    );
    _persist();
    if (next.turnPhase == TurnPhase.gameOver) {
      final won = next.winnerId == next.players.first.id;
      progressService.recordGameEnd(won: won);
      return;
    }
    _beginTurn();
  }

  /// Opens the new player's turn: a horse waiting at the finish gets its
  /// journey question first (the retry promised "on a later turn"), then
  /// an AI player starts thinking.
  void _beginTurn() {
    final s = state;
    if (s == null) return;
    if (s.gameState.turnPhase == TurnPhase.choosingHorse) {
      // Resumed mid-choice: a human sees the sheet again; an opponent
      // simply chooses.
      if (s.gameState.currentPlayer.isAi) _runAiMoveChoice();
      return;
    }
    if (s.gameState.turnPhase != TurnPhase.selectingGait) return;
    final awaiting = engine.horsesAwaitingJourneyQuestion(
      s.gameState.currentPlayer,
    );
    if (awaiting.isNotEmpty) {
      startJourneyQuestion(awaiting.first);
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
    state = s.copyWith(
      gameState: engine.declineCellOffer(s.gameState),
      currentQuestion: null,
    );
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
        // The bonus goes to the horse that landed on the square.
        horseIndex:
            s.gameState.pendingCellHorseIndex ?? s.preview?.horseIndex ?? 0,
      ),
      _ => engine.declineCellOffer(s.gameState),
    };

    state = s.copyWith(gameState: next, currentQuestion: null);
    _persist();
    // The board shows the outcome (the horse jumps, or stays); the turn
    // itself must keep moving — a bonus jump can even reach the finish
    // and owe its journey question right now.
    continueAfterFeedback();
  }

  /// A Relais square: hand the squares just earned to another horse.
  void resolveRelay({
    required int fromHorseIndex,
    required int toHorseIndex,
    required int steps,
  }) {
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
    final question = _drawQuestion(
      s.gameState,
      movementChoices.journeyDifficultyFor(profile),
    );
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
      gameState: s.gameState.copyWith(
        turnPhase: TurnPhase.answeringJourneyQuestion,
      ),
      currentQuestion: question,
      journeyHorseIndex: horseIndex,
      journeyAttemptedHorses: {...s.journeyAttemptedHorses, horseIndex},
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
      progressService.recordGameEnd(
        won: next.winnerId == next.players.first.id,
      );
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
    // The player may have left the board during that pause; a
    // disposed notifier must not be read or written.
    if (!mounted) return;

    final current = state;
    if (current == null || !current.gameState.currentPlayer.isAi) return;
    if (current.gameState.turnPhase != TurnPhase.selectingGait) return;
    if (engine.movableHorses(current.gameState.currentPlayer).isEmpty) {
      // Nothing can move (every horse finished or waiting on a journey
      // retry already attempted): the turn simply passes.
      state = current.copyWith(isAiTurnInProgress: false);
      _endTurn();
      return;
    }

    // The same deck as the human, the same draw: the opponent only
    // decides what the card does once it is on the table.
    state = current.copyWith(isAiTurnInProgress: false);
    drawCard();
  }

  /// The opponent's card can do more than one thing: it "thinks" for a
  /// beat (the table says so), then commits.
  Future<void> _runAiMoveChoice() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    final s = state;
    if (s == null || !s.gameState.currentPlayer.isAi) return;
    if (s.gameState.turnPhase != TurnPhase.choosingHorse) return;
    final moves = legalMoves;
    if (moves.isEmpty) {
      _endTurn();
      return;
    }
    final horse = ai.chooseMove(
      state: s.gameState,
      engine: engine,
      difficulty: s.gameState.currentPlayer.aiDifficulty!,
      moves: moves,
    );
    chooseMove(horse);
  }

  Future<void> _runAiAnswer(
    AiDifficulty aiDifficulty,
    QuestionDifficulty _,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    // The player may have left the board during that pause; a
    // disposed notifier must not be read or written.
    if (!mounted) return;
    final s = state;
    final question = s?.currentQuestion;
    if (s == null || question == null) return;

    final correct = ai.decideAnswerCorrect(aiDifficulty);
    final index = correct
        ? question.correctAnswerIndex
        : (question.correctAnswerIndex + 1) % question.answers.length;
    answerQuestion(index);

    await Future<void>.delayed(const Duration(milliseconds: 900));
    // The player may have left the board during that pause; a
    // disposed notifier must not be read or written.
    if (!mounted) return;
    if (state?.gameState.currentPlayer.isAi ?? false) _runAiCellDecision();
  }

  Future<void> _runAiJourneyAnswer(
    AiDifficulty aiDifficulty,
    Question question,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    // The player may have left the board during that pause; a
    // disposed notifier must not be read or written.
    if (!mounted) return;
    if (state == null) return;
    final correct = ai.decideAnswerCorrect(aiDifficulty);
    answerJourneyQuestion(
      correct
          ? question.correctAnswerIndex
          : (question.correctAnswerIndex + 1) % question.answers.length,
    );
    await Future<void>.delayed(const Duration(milliseconds: 600));
    // The player may have left the board during that pause; a
    // disposed notifier must not be read or written.
    if (!mounted) return;
    // continueAfterFeedback, not _endTurn: the per-turn attempt guard
    // stops a retry loop, and a second arrived horse still gets its own
    // question.
    if (state?.gameState.turnPhase == TurnPhase.showingFeedback) {
      continueAfterFeedback();
    }
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
    if (takesIt &&
        (effect == CellEffect.challenge || effect == CellEffect.shortcut)) {
      acceptCellChallenge();
      final question = state?.currentQuestion;
      if (question != null) {
        final correct = ai.decideAnswerCorrect(difficulty);
        answerCellQuestion(
          correct
              ? question.correctAnswerIndex
              : (question.correctAnswerIndex + 1) % question.answers.length,
        );
        // answerCellQuestion already moved the turn along.
        return;
      }
    }
    declineCellOffer();
  }
}

final gameControllerProvider =
    StateNotifierProvider<GameController, GameSession?>((ref) {
      return GameController(
        engine: ref.watch(gameEngineProvider),
        questionRepository: ref.watch(questionRepositoryProvider),
        saveService: ref.watch(gameSaveServiceProvider),
        progressService: ref.watch(progressServiceProvider),
      );
    });
