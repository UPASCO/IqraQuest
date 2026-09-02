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

/// One hop of a horse from square to square, and the cap on a whole
/// ride: the controller waits exactly as long as the board animates, so
/// the bonus square never fires before the horse has visibly stopped on
/// it. Mirrors `AppMotion.hopPerCell` / `AppMotion.moveMax`.
const Duration kHopPerCell = Duration(milliseconds: 170);
const Duration kRideMax = Duration(milliseconds: 950);

/// A leap out of the stable, and the settle after any landing.
const Duration kLeapDuration = Duration(milliseconds: 640);
const Duration kLandingSettle = Duration(milliseconds: 260);

/// The bonus square flares and says its value before the horse rides
/// on: long enough to read "+10", short enough to stay one motion.
const Duration kBonusRevealBeat = Duration(milliseconds: 1000);

/// How long a ride of [steps] squares takes on the board. A horse hops
/// square by square up to twelve squares, and leaps beyond that (a +20
/// bonus is a leap), exactly as `CrossBoardScene` animates it.
Duration rideDurationFor(int steps, {bool leap = false}) {
  if (leap || steps > 12) return kLeapDuration + kLandingSettle;
  final hops = steps * kHopPerCell.inMilliseconds;
  return Duration(milliseconds: min(hops, kRideMax.inMilliseconds)) +
      kLandingSettle;
}

/// Everything the presentation layer needs to render one turn.
@immutable
class GameSession {
  const GameSession({
    required this.gameState,
    this.currentQuestion,
    this.isAiTurnInProgress = false,
    this.journeyHorseIndex,
    this.journeyAttemptedHorses = const {},
  });

  final GameState gameState;

  /// The question currently on screen (a turn question, a bonus question
  /// from an interactive square, or a journey question).
  final Question? currentQuestion;

  final bool isAiTurnInProgress;

  /// Set while a "Question du voyage" is being answered.
  final int? journeyHorseIndex;

  /// Horses whose journey question was already attempted THIS turn — a
  /// missed one is retried on a later turn, never in a loop (spec §10).
  final Set<int> journeyAttemptedHorses;

  GameSession copyWith({
    GameState? gameState,
    Object? currentQuestion = _unset,
    bool? isAiTurnInProgress,
    Object? journeyHorseIndex = _unset,
    Set<int>? journeyAttemptedHorses,
  }) => GameSession(
    gameState: gameState ?? this.gameState,
    currentQuestion: identical(currentQuestion, _unset)
        ? this.currentQuestion
        : currentQuestion as Question?,
    isAiTurnInProgress: isAiTurnInProgress ?? this.isAiTurnInProgress,
    journeyHorseIndex: identical(journeyHorseIndex, _unset)
        ? this.journeyHorseIndex
        : journeyHorseIndex as int?,
    journeyAttemptedHorses:
        journeyAttemptedHorses ?? this.journeyAttemptedHorses,
  );
}

const Object _unset = Object();

/// Orchestrates one game: wires [GameEngine] to the question deck, the
/// board's timing, AI turns, autosave on every mutation, and progress
/// tracking.
///
/// The turn it drives, in the order the player lives it:
///
/// 1. [drawCard] — the question opens; the card's value stays face down;
/// 2. [answerQuestion] — the verdict and the explanation;
/// 3. [continueAfterFeedback] — a right answer opens the placement: the
///    squares won are shown and every horse that can ride them lights
///    up; a wrong one ends the turn;
/// 4. [placeHorse] — the player set a horse down on its destination: the
///    ride is final, nothing asks to confirm;
/// 5. the controller waits for the ride, fires a bonus square if the
///    horse stopped on one (once per turn), resolves the landing square,
///    asks the journey question if the horse arrived, and hands over.
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
    this.animate = true,
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

  /// Whether the controller paces itself on the board's animations. Off
  /// in headless tests and simulations, where a ride takes no time.
  final bool animate;

  List<Question> _pool = const [];
  bool _isPremium = false;

  /// The draw pile for this game. Rebuilt whenever the playable bank
  /// changes — buying Premium mid-game widens it immediately.
  QuestionDeck? _deck;

  Timer? _noMoveTimer;
  Timer? _rideTimer;

  void configure({required List<Question> pool, required bool isPremium}) {
    _pool = pool;
    _isPremium = isPremium;
    // Free players draw from the free bank only; the die is the same six
    // faces for everyone, so nothing about the ride changes.
    _deck = QuestionDeck(
      pool: isPremium ? pool : pool.where((q) => q.isFree).toList(),
      random: _random,
    );
    // A game already under way keeps its promise of no repeats: what it
    // has asked leaves the fresh deck at once.
    final asked = state?.gameState.askedQuestionIds;
    if (asked != null && asked.isNotEmpty) _deck!.exclude(asked);
  }

  @override
  void dispose() {
    _noMoveTimer?.cancel();
    _rideTimer?.cancel();
    super.dispose();
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
    _cancelTimers();
    final now = DateTime.now();
    var gameState = GameState(
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
    // The sixteen bonus squares are dealt once, here, from the game's
    // own seed — and then live in the state, never recomputed.
    gameState = engine.ensureBonusLayout(gameState);
    // Nobody waits for a 6 to start playing: the first horse of every
    // rider is already on its start square.
    gameState = gameState.copyWith(
      players: engine.openingLineUp(gameState.players, gameState.circuit),
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
    _cancelTimers();
    final schema = saveService.savedSchemaVersion() ?? GameState.schemaVersion;

    // A save from the previous turn order (card → horse → question) at
    // a mid-turn phase means something else there than it does now: the
    // turn simply restarts at the deck, positions intact.
    if (schema < GameState.schemaVersion &&
        saved.turnPhase != TurnPhase.selectingGait) {
      saved = engine.endTurn(
        saved.copyWith(
          turnPhase: TurnPhase.turnComplete,
          drawnCard: null,
          extraTurn: false,
        ),
      );
    }
    // An older save has no bonus squares yet: it gets its sixteen now,
    // from its own id, and keeps them from here on.
    saved = engine.ensureBonusLayout(saved);

    // A save can be written while a question is on screen, but the
    // question text itself is never persisted — resume at the nearest
    // safe decision point instead of a phase with nothing to tap.
    saved = switch (saved.turnPhase) {
      // The card was drawn but not answered: a fresh card is drawn.
      TurnPhase.answeringQuestion => saved.copyWith(
        turnPhase: TurnPhase.selectingGait,
        drawnCard: null,
        extraTurn: false,
      ),
      // The journey question is re-asked by _beginTurn below.
      TurnPhase.answeringJourneyQuestion => saved.copyWith(
        turnPhase: TurnPhase.selectingGait,
      ),
      // The answer was judged: a right one still owes its placement,
      // anything else concludes the turn.
      TurnPhase.showingFeedback =>
        saved.lastAnswerCorrect == true &&
                saved.drawnCard != null &&
                saved.movedHorseIndex == null
            ? engine.openPlacement(saved)
            : engine.endTurn(saved),
      // The squares are won and the horse not yet set down: persisted,
      // so the player resumes exactly there. (An opponent's choice is
      // made again by _beginTurn.)
      TurnPhase.choosingHorse => saved,
      // The horse was set down: whatever it earned is still earned. A
      // pending bonus rides now, then the landing is resolved.
      TurnPhase.movingHorse => engine.applyPendingBonus(saved),
      // A card that could move nothing has been seen: the turn passes.
      TurnPhase.noMove => engine.endTurn(saved),
      TurnPhase.turnComplete => engine.endTurn(saved),
      _ => saved,
    };
    if (saved.turnPhase == TurnPhase.gameOver) return false;
    state = GameSession(gameState: saved);
    _deck?.exclude(saved.askedQuestionIds);
    _persist();
    if (saved.turnPhase == TurnPhase.movingHorse) {
      _settleRide();
      return true;
    }
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

  void _cancelTimers() {
    _noMoveTimer?.cancel();
    _rideTimer?.cancel();
    _noMoveTimer = null;
    _rideTimer = null;
  }

  // ---------------------------------------------------------------------
  // Reading the turn
  // ---------------------------------------------------------------------

  List<int> get movableHorses {
    final s = state;
    if (s == null) return const [];
    return engine.movableHorses(s.gameState.currentPlayer);
  }

  /// What the won squares can do, for the board: which horses may be
  /// picked up and where each one lands.
  List<LegalMove> get legalMoves {
    final s = state;
    final card = s?.gameState.drawnCard;
    if (s == null || card == null) return const [];
    return engine.legalMoves(s.gameState, card);
  }

  /// The destination of [horseIndex] under the current card, or null if
  /// that horse cannot ride it. The board shows this the moment a horse
  /// is touched, and validates a drop against it.
  LegalMove? moveFor(int horseIndex) {
    for (final m in legalMoves) {
      if (m.horseIndex == horseIndex) return m;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Turn: drawing
  // ---------------------------------------------------------------------

  /// Draws this turn's card: its question opens at once. The card's
  /// value — how far a horse rides — is known to the state but stays
  /// face down on screen until the answer is judged, so the player
  /// answers for the answer's sake and discovers the prize after.
  void drawCard() {
    final s = state;
    if (s == null || s.gameState.turnPhase != TurnPhase.selectingGait) return;

    final level = s.gameState.currentPlayer.profile.difficulty;
    final card = _deck?.draw(level);
    if (card == null) {
      // No playable question at all: the turn still resolves rather than
      // stalling or paywalling mid-game. The card is a 6 (a horse gets
      // out), its answer counts as right, and the player still places.
      final drawn = engine
          .drawCard(s.gameState, const MovementChoice(6))
          .copyWith(freeBankExhausted: true, extraTurn: s.gameState.extraTurn);
      state = s.copyWith(gameState: drawn, currentQuestion: null);
      _persist();
      _resolveAnswer(
        correct: true,
        questionId: 'free-bank-exhausted',
        category: null,
      );
      continueAfterFeedback();
      return;
    }

    // The card sets the distance for everyone; the question on it was
    // dealt at the rider's own level. A seven-year-old who draws a 6
    // rides six squares like anyone else and answers an easy question
    // for it; an expert who draws a 1 still faces an expert question.
    final drawn = engine.drawCard(s.gameState, MovementChoice(card.value));
    state = s.copyWith(
      gameState: drawn,
      // The bank stores correct answers at index 0: shuffle on draw so
      // the on-screen order never gives the answer away.
      currentQuestion: card.question.withShuffledAnswers(_random),
    );
    _persist();

    final player = drawn.currentPlayer;
    if (player.isAi) _runAiAnswer(player.aiDifficulty!);
  }

  /// A question outside the draw — a chest's, a journey's — dealt from
  /// the same deck, so it never repeats what the game has already asked.
  Question? _drawQuestion(GameState gameState, QuestionDifficulty difficulty) {
    final fromDeck = _deck?.drawQuestion(difficulty);
    if (fromDeck != null) return fromDeck.withShuffledAnswers(_random);
    final fresh = questionRepository.pickQuestion(
      pool: _pool,
      askedQuestionIds: gameState.askedQuestionIds,
      isPremium: _isPremium,
      difficulty: difficulty,
      random: _random,
    );
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

    state = s.copyWith(gameState: next);
    _persist();
  }

  /// Called once the player has read the explanation and source — or
  /// tapped through a card that could move nothing.
  ///
  /// After the turn's own question, a right answer opens the placement
  /// and a wrong one concludes the turn; after a journey question or a
  /// chest, the turn concludes.
  void continueAfterFeedback() {
    final s = state;
    if (s == null) return;
    final gameState = s.gameState;

    switch (gameState.turnPhase) {
      case TurnPhase.noMove:
        _noMoveTimer?.cancel();
        _endTurn();
        return;
      // Waiting on the board: there is nothing to continue from.
      case TurnPhase.choosingHorse:
      case TurnPhase.movingHorse:
      case TurnPhase.answeringQuestion:
      case TurnPhase.answeringJourneyQuestion:
      case TurnPhase.selectingGait:
      case TurnPhase.gameOver:
        return;
      case TurnPhase.showingFeedback:
        final ownsPlacement =
            s.journeyHorseIndex == null &&
            gameState.lastAnswerCorrect == true &&
            gameState.drawnCard != null &&
            gameState.movedHorseIndex == null;
        if (ownsPlacement) {
          _openPlacement();
          return;
        }
        _concludeTurn();
      case TurnPhase.resolvingCell:
      case TurnPhase.turnComplete:
        _concludeTurn();
    }
  }

  // ---------------------------------------------------------------------
  // Turn: placing the horse
  // ---------------------------------------------------------------------

  /// The squares are won: the board shows which horses can ride them.
  /// Nothing moves by itself — not even when only one horse could — the
  /// player always sets the horse down. A card that moves nothing stays
  /// in view for one beat, then the turn passes.
  void _openPlacement() {
    final s = state;
    if (s == null) return;
    final next = engine.openPlacement(s.gameState);
    state = s.copyWith(gameState: next, currentQuestion: null);
    _persist();
    if (next.turnPhase == TurnPhase.noMove) {
      _armNoMoveBeat();
      return;
    }
    if (next.currentPlayer.isAi) _runAiPlacement();
  }

  /// The player set [horseIndex] down on its destination — or the
  /// opponent chose it. The drop is the confirmation: the ride is
  /// applied at once, and the controller then waits for the board to
  /// show it before anything else happens.
  ///
  /// Returns false if that horse cannot ride the card, so a board can
  /// snap a bad drop back without touching the state.
  bool placeHorse(int horseIndex) {
    final s = state;
    if (s == null || s.gameState.turnPhase != TurnPhase.choosingHorse) {
      return false;
    }
    final move = moveFor(horseIndex);
    if (move == null) return false;

    final next = engine.placeHorse(s.gameState, horseIndex);
    if (next.turnPhase != TurnPhase.movingHorse) return false;
    state = s.copyWith(gameState: next);
    _persist();

    final steps = move.exitsStable
        ? 0
        : (s.gameState.drawnCard?.steps ?? 1) + (move.usesGrandGallop ? 2 : 0);
    _after(rideDurationFor(steps, leap: move.exitsStable), _afterRide);
    return true;
  }

  /// The horse has visibly stopped. A bonus square under its hooves
  /// flares for a beat, then it rides on; otherwise the landing is
  /// resolved straight away.
  void _afterRide() {
    final s = state;
    if (s == null || s.gameState.turnPhase != TurnPhase.movingHorse) return;
    final bonus = s.gameState.pendingBonus;
    if (bonus == null) {
      _settleRide();
      return;
    }
    _after(kBonusRevealBeat, () {
      final current = state;
      if (current == null || current.gameState.pendingBonus == null) return;
      final next = engine.applyPendingBonus(current.gameState);
      state = current.copyWith(gameState: next);
      _persist();
      _after(rideDurationFor(bonus.value), _settleRide);
    });
  }

  /// Everything the ride triggered, once it is over: a passive square's
  /// fact and point, an interactive square's offer, the journey question
  /// of a horse that arrived — then the hand-off.
  void _settleRide() {
    final s = state;
    if (s == null || s.gameState.turnPhase != TurnPhase.movingHorse) return;
    var next = s.gameState;

    final landed = next.landedEffect;
    if (landed != null && !boardEffects.isInteractive(landed)) {
      final bonus = boardEffects.bonusPointsFor(landed);
      if (bonus > 0 || landed == CellEffect.wisdom) {
        next = engine.collectFact(
          next,
          '${landed.name}:${next.currentQuestionId ?? next.drawCount}',
          bonusPoints: bonus,
        );
      }
    }
    next = engine.completeMove(next);
    state = s.copyWith(gameState: next);
    _persist();
    _concludeTurn();
  }

  /// The turn's ride is done and judged: an interactive square waits on
  /// a decision, an arrived horse owes its journey question, or the turn
  /// is handed over.
  void _concludeTurn() {
    final s = state;
    if (s == null) return;
    final gameState = s.gameState;

    final pendingCell = gameState.pendingCellEffect;
    if (pendingCell != null &&
        boardEffects.isAvailableFor(
          pendingCell,
          playerCount: gameState.players.length,
          horseCount: gameState.currentPlayer.horses.length,
        )) {
      if (gameState.turnPhase != TurnPhase.resolvingCell) {
        state = s.copyWith(
          gameState: gameState.copyWith(turnPhase: TurnPhase.resolvingCell),
          currentQuestion: null,
        );
        _persist();
        if (gameState.currentPlayer.isAi) _runAiCellDecision();
      }
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

  /// The card on the table can move nothing: it stays in view for one
  /// beat, then the turn passes on its own. Tapping through
  /// ([continueAfterFeedback]) ends it sooner.
  void _armNoMoveBeat() {
    _noMoveTimer?.cancel();
    _noMoveTimer = Timer(animate ? kNoMoveBeat : Duration.zero, () {
      if (!mounted) return;
      if (state?.gameState.turnPhase == TurnPhase.noMove) _endTurn();
    });
  }

  /// Runs [action] once the board has had [delay] to show what just
  /// happened — or at once, headless.
  void _after(Duration delay, void Function() action) {
    _rideTimer?.cancel();
    if (!animate) {
      action();
      return;
    }
    _rideTimer = Timer(delay, () {
      if (!mounted) return;
      action();
    });
  }

  void _endTurn() {
    final s = state;
    if (s == null) return;
    final next = engine.endTurn(s.gameState);
    state = s.copyWith(
      gameState: next,
      currentQuestion: null,
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
    switch (s.gameState.turnPhase) {
      case TurnPhase.choosingHorse:
        // Resumed mid-placement: a human sees the board lit again; an
        // opponent simply chooses.
        if (s.gameState.currentPlayer.isAi) _runAiPlacement();
        return;
      case TurnPhase.resolvingCell:
        if (s.gameState.currentPlayer.isAi) _runAiCellDecision();
        return;
      case TurnPhase.selectingGait:
        break;
      case _:
        return;
    }
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
    _concludeTurn();
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
            s.gameState.pendingCellHorseIndex ??
            s.gameState.movedHorseIndex ??
            0,
      ),
      _ => engine.declineCellOffer(s.gameState),
    };

    state = s.copyWith(gameState: next, currentQuestion: null);
    _persist();
    // The board shows the outcome (the horse jumps, or stays); the turn
    // itself must keep moving — a bonus jump can even reach the finish
    // and owe its journey question right now.
    _concludeTurn();
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
    if (s.gameState.turnPhase != TurnPhase.answeringJourneyQuestion) return;

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

  Duration _aiBeat(int milliseconds) =>
      animate ? Duration(milliseconds: milliseconds) : Duration.zero;

  void _maybeRunAiTurn() {
    final s = state;
    if (s == null) return;
    if (!s.gameState.currentPlayer.isAi) return;
    if (s.gameState.turnPhase != TurnPhase.selectingGait) return;
    _runAiDraw();
  }

  Future<void> _runAiDraw() async {
    final s = state;
    if (s == null) return;
    state = s.copyWith(isAiTurnInProgress: true);
    await Future<void>.delayed(_aiBeat(550));
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
    // decides what the card does once the answer is judged.
    state = current.copyWith(isAiTurnInProgress: false);
    drawCard();
  }

  Future<void> _runAiAnswer(AiDifficulty aiDifficulty) async {
    await Future<void>.delayed(_aiBeat(700));
    if (!mounted) return;
    final s = state;
    final question = s?.currentQuestion;
    if (s == null || question == null) return;
    if (s.gameState.turnPhase != TurnPhase.answeringQuestion) return;

    final correct = ai.decideAnswerCorrect(aiDifficulty);
    final index = correct
        ? question.correctAnswerIndex
        : (question.correctAnswerIndex + 1) % question.answers.length;
    answerQuestion(index);

    // The verdict stays on the table for a beat, then the opponent
    // places (or the turn passes).
    await Future<void>.delayed(_aiBeat(900));
    if (!mounted) return;
    if (state?.gameState.turnPhase == TurnPhase.showingFeedback &&
        (state?.gameState.currentPlayer.isAi ?? false)) {
      continueAfterFeedback();
    }
  }

  /// The opponent's squares can go to more than one horse: it "thinks"
  /// for a beat (the table says so), then sets one down.
  Future<void> _runAiPlacement() async {
    await Future<void>.delayed(_aiBeat(650));
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
    placeHorse(horse);
  }

  Future<void> _runAiJourneyAnswer(
    AiDifficulty aiDifficulty,
    Question question,
  ) async {
    await Future<void>.delayed(_aiBeat(700));
    if (!mounted) return;
    if (state == null) return;
    final correct = ai.decideAnswerCorrect(aiDifficulty);
    answerJourneyQuestion(
      correct
          ? question.correctAnswerIndex
          : (question.correctAnswerIndex + 1) % question.answers.length,
    );
    await Future<void>.delayed(_aiBeat(600));
    if (!mounted) return;
    // continueAfterFeedback, not _endTurn: the per-turn attempt guard
    // stops a retry loop, and a second arrived horse still gets its own
    // question.
    if (state?.gameState.turnPhase == TurnPhase.showingFeedback) {
      continueAfterFeedback();
    }
  }

  Future<void> _runAiCellDecision() async {
    await Future<void>.delayed(_aiBeat(500));
    if (!mounted) return;
    final s = state;
    if (s == null) return;
    if (s.gameState.turnPhase != TurnPhase.resolvingCell) return;
    final effect = s.gameState.pendingCellEffect;
    if (effect == null) {
      declineCellOffer();
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
