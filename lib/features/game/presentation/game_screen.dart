import 'dart:ui' as ui;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart' show soundServiceProvider;
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../services/sound_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/board/cross_board_scene.dart';
import '../../../widgets/celebration_overlay.dart';
import '../../../widgets/illustration.dart';
import '../../../widgets/question_card.dart';
import '../../../widgets/question_card_draw.dart';
import '../application/game_controller.dart';
import '../domain/game_engine.dart';
import '../../../widgets/button_label.dart';

/// How long the answered card stays up, verdict on the tiles, before the
/// board comes back and the horse rides. Long enough to read "right" or
/// "wrong"; short enough that the ride is what the player remembers.
const Duration kAnswerBeatDuration = Duration(milliseconds: 1000);

/// The game screen is the world: a full-bleed dawn landscape with the
/// journey tilted into perspective, and every piece of UI floating over
/// it. No app bar, no page chrome — opening this screen must feel like
/// entering a place, not a form.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int? _selectedAnswer;
  String? _dismissedQuestionId;

  /// The key moment on screen, if any: a 6, an open gate, a capture, an
  /// arrival. Held for one beat over everything else, tap to skip.
  CelebrationKind? _celebration;
  String _celebrationTitle = '';
  String _celebrationBody = '';
  Timer? _celebrationTimer;
  Timer? _landingTimer;

  /// An answer plays in two beats. Beat one: the card shows the verdict
  /// on its tiles and the board underneath is held at its pre-move
  /// state. Beat two: the card folds down to a short sheet, the board is
  /// released and the horse rides in full view. Without the hold, the
  /// horse would move behind the blurred card and the player would only
  /// ever see it already arrived.
  GameState? _frozenBoard;
  bool _compactFeedback = false;
  bool _hoofsDeferred = false;
  int? _pointsEarned;
  Timer? _beatTimer;

  /// While the drawn card is turning over, the question sheet is held
  /// back: the player reads what the card is worth first, then answers.
  bool _revealing = false;
  int _revealValue = 1;
  int _revealPips = 1;
  Timer? _revealTimer;
  Timer? _resultsTimer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final session = ref.watch(gameControllerProvider);

    ref.listen(gameControllerProvider, (previous, next) {
      _beginAnswerBeatsIfNeeded(previous, next);
      _playCuesFor(previous, next);
      _celebrateLandingsIfNeeded(previous, next);
      if (next?.gameState.turnPhase == TurnPhase.gameOver &&
          previous?.gameState.turnPhase != TurnPhase.gameOver) {
        // The winning ride is the one ride nobody should miss: let the
        // horse reach the centre before the results board takes over.
        _resultsTimer?.cancel();
        _resultsTimer = Timer(
          AppMotion.of(context, AppMotion.moveMax) +
              const Duration(milliseconds: 450),
          () {
            if (mounted) context.go('/results');
          },
        );
      }
      if (previous?.currentQuestion?.id != next?.currentQuestion?.id) {
        setState(() => _selectedAnswer = null);
      }
    });

    if (session == null) {
      // No game is loaded (cold entry to /game): nothing will ever
      // appear here, so offer the way home instead of an endless spinner.
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/home'),
                child: ButtonLabel(l10n.backToHome),
              ),
            ],
          ),
        ),
      );
    }

    final state = session.gameState;
    final player = state.currentPlayer;
    final question = session.currentQuestion;
    final busy = _revealing || _celebration != null;
    final showQuestion =
        question != null &&
        !busy &&
        question.id != _dismissedQuestionId &&
        player.isHuman &&
        (state.turnPhase == TurnPhase.answeringQuestion ||
            state.turnPhase == TurnPhase.answeringJourneyQuestion ||
            state.turnPhase == TurnPhase.showingFeedback ||
            state.turnPhase == TurnPhase.resolvingCell);

    // Where the drawn card sends this horse, drawn on the board itself
    // so the ride is never a surprise: "this card takes me here."
    ({int teamIndex, PawnPosition destination})? boardPreview;
    final pending = state.pendingGait;
    final drawnPreview = session.preview;
    if (pending != null && drawnPreview != null) {
      boardPreview = (
        teamIndex: state.currentPlayerIndex,
        destination: drawnPreview.destination,
      );
    }

    // While the card waits for a horse, every horse that could use it
    // wears the ring; tapping one on the plate is the same as tapping
    // its line on the sheet.
    final legal = state.turnPhase == TurnPhase.choosingHorse && player.isHuman
        ? ref.read(gameControllerProvider.notifier).legalMoves
        : const <LegalMove>[];
    final selectable = {for (final m in legal) '${player.id}:${m.horseIndex}'};

    return PopScope(
      // System back mid-game behaves exactly like the in-game back
      // button: home, with the autosave keeping the journey resumable.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A3327),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // The classic cross board: plate and anchors are generated
            // from one grid, so a square index always lands on its tile.
            // A square plate can never be wider than the phone, so the
            // board pinches up to 2.5x for a closer look at the squares;
            // the HUD and the deck stay put above it.
            Positioned.fill(
              child: InteractiveViewer(
                key: const Key('board-zoom'),
                minScale: 1,
                maxScale: 2.5,
                child: CrossBoardScene(
                  state: _frozenBoard ?? state,
                  preview: boardPreview,
                  selectableHorses: selectable,
                  onHorseTap: (playerIndex, horseIndex) {
                    if (busy || playerIndex != state.currentPlayerIndex) {
                      return;
                    }
                    if (!selectable.contains('${player.id}:$horseIndex')) {
                      return;
                    }
                    ref.read(soundServiceProvider).play(Sfx.tap);
                    HapticFeedback.selectionClick();
                    ref
                        .read(gameControllerProvider.notifier)
                        .chooseMove(horseIndex);
                  },
                ),
              ),
            ),

            // ---- Floating HUD ----
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _GlassIconButton(
                          icon: Icons.arrow_back,
                          onTap: () => context.go('/home'),
                        ),
                        const SizedBox(width: 10),
                        _HudPill(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 6,
                                backgroundColor: player.team.color(colors),
                              ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.sizeOf(context).width * 0.32,
                                ),
                                child: Text(
                                  player.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _hudText(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        _HudPill(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 15,
                                color: Color(0xFFEBC06A),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${player.rewards.knowledgePoints}',
                                style: _hudText(context),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _HudPill(
                          highlight: player.streak.current >= 3,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 16,
                                color: player.streak.current > 0
                                    ? const Color(0xFFF0A24B)
                                    : Colors.white38,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${player.streak.current}/${player.streak.nextThreshold}',
                                style: _hudText(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Four horses per stable: each player's arrivals at a
                    // glance (the painted stables are scenery) — and, in
                    // the free edition, how many of its fifty cards remain.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state.maxDraws != null) ...[
                          _HudPill(
                            child: Semantics(
                              label: l10n.drawsCounter(
                                state.drawCount,
                                state.maxDraws!,
                              ),
                              child: ExcludeSemantics(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.style,
                                      size: 15,
                                      color: Color(0xFFEBC06A),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${state.drawCount}/${state.maxDraws}',
                                      style: _hudText(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        for (var i = 0; i < state.players.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          _HudPill(
                            highlight: i == state.currentPlayerIndex,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 5,
                                  backgroundColor: state.players[i].team.color(
                                    colors,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${state.players[i].horses.where((h) => h.position is FinishedPosition).length}'
                                  '/${state.players[i].horses.length}',
                                  style: _hudText(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ---- Bottom: the play bar or the turn pill ----
            if (state.turnPhase == TurnPhase.selectingGait && player.isHuman)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                    child: DrawDeck(
                      key: const Key('draw-deck'),
                      onDraw: _onDrawCard,
                      horseHint: state.isBonusTurn ? l10n.bonusTurnHint : null,
                    ),
                  ),
                ),
              )
            else if (state.turnPhase == TurnPhase.choosingHorse &&
                player.isHuman)
              (busy
                  ? const SizedBox.shrink()
                  : _MoveChoiceSheet(
                      card: state.drawnCard ?? const MovementChoice(1),
                      moves: legal,
                      l10n: l10n,
                      onChoose: (horseIndex) {
                        ref.read(soundServiceProvider).play(Sfx.tap);
                        HapticFeedback.selectionClick();
                        ref
                            .read(gameControllerProvider.notifier)
                            .chooseMove(horseIndex);
                      },
                    ))
            else
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: GestureDetector(
                    // A card that could move nothing passes by itself; a
                    // tap on the banner passes it sooner.
                    onTap: state.turnPhase == TurnPhase.noMove && player.isHuman
                        ? () => ref
                              .read(gameControllerProvider.notifier)
                              .continueAfterFeedback()
                        : null,
                    child: _TurnBanner(session: session, l10n: l10n),
                  ),
                ),
              ),

            if (_revealing)
              Positioned.fill(
                // Absorbing: a ColoredBox does not hit-test itself, so
                // without this a tap during the flip would fall straight
                // through to the deck underneath and start another draw.
                child: AbsorbPointer(
                  child: ColoredBox(
                    color: const Color(0xB306251C),
                    child: DrawnCardReveal(
                      value: _revealValue,
                      difficultyPips: _revealPips,
                    ),
                  ),
                ),
              ),

            if (showQuestion)
              _QuestionOverlay(
                question: question,
                isJourney:
                    state.turnPhase == TurnPhase.answeringJourneyQuestion,
                isCellBonus: state.turnPhase == TurnPhase.resolvingCell,
                selectedAnswer: _selectedAnswer,
                lastAnswerCorrect: state.lastAnswerCorrect,
                compact: _compactFeedback && state.lastAnswerCorrect != null,
                largeText: player.profile.isChildMode,
                stakeSteps: state.turnPhase == TurnPhase.answeringQuestion
                    ? state.pendingGait?.choice.steps
                    : null,
                pointsEarned:
                    state.lastAnswerCorrect == true && _pointsEarned != null
                    ? _pointsEarned
                    : null,
                justUnlocked: state.justUnlocked.isEmpty
                    ? null
                    : state.justUnlocked.first,
                streakCurrent: player.streak.current,
                l10n: l10n,
                onSelect: (i) {
                  ref.read(soundServiceProvider).play(Sfx.tap);
                  HapticFeedback.selectionClick();
                  setState(() => _selectedAnswer = i);
                  final controller = ref.read(gameControllerProvider.notifier);
                  switch (state.turnPhase) {
                    case TurnPhase.answeringJourneyQuestion:
                      controller.answerJourneyQuestion(i);
                    case TurnPhase.resolvingCell:
                      controller.answerCellQuestion(i);
                    case _:
                      controller.answerQuestion(i);
                  }
                },
                onContinue: () {
                  setState(() => _dismissedQuestionId = question.id);
                  ref
                      .read(gameControllerProvider.notifier)
                      .continueAfterFeedback();
                },
              ),
            if (state.turnPhase == TurnPhase.resolvingCell &&
                session.currentQuestion == null &&
                player.isHuman)
              _CellOfferSheet(
                effect: state.pendingCellEffect!,
                l10n: l10n,
                onAccept: () => ref
                    .read(gameControllerProvider.notifier)
                    .acceptCellChallenge(),
                onDecline: () => ref
                    .read(gameControllerProvider.notifier)
                    .declineCellOffer(),
              ),

            if (_celebration != null)
              Positioned.fill(
                key: const Key('celebration'),
                child: CelebrationOverlay(
                  kind: _celebration!,
                  title: _celebrationTitle,
                  body: _celebrationBody,
                  onTap: _endCelebration,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Puts a key moment on screen for one beat. The sound is the moment's
  /// own voice, the buzz is felt only for the human's own moments.
  void _celebrate(
    CelebrationKind kind,
    String title,
    String body, {
    Sfx? sound,
  }) {
    if (!mounted) return;
    if (sound != null) ref.read(soundServiceProvider).play(sound);
    if (kind != CelebrationKind.captured) HapticFeedback.heavyImpact();
    _celebrationTimer?.cancel();
    setState(() {
      _celebration = kind;
      _celebrationTitle = title;
      _celebrationBody = body;
    });
    _celebrationTimer = Timer(kCelebrationDuration, _endCelebration);
  }

  void _endCelebration() {
    _celebrationTimer?.cancel();
    if (!mounted || _celebration == null) return;
    setState(() => _celebration = null);
  }

  /// A capture or an arrival is celebrated when the horse *lands*: after
  /// the answer's held beat (a human's) and the ride itself, so the
  /// burst happens where the eye already is.
  void _celebrateLandingsIfNeeded(GameSession? previous, GameSession? next) {
    if (previous == null || next == null) return;
    final prevState = previous.gameState;
    final nextState = next.gameState;
    final entering =
        nextState.turnPhase == TurnPhase.showingFeedback &&
        prevState.turnPhase != TurnPhase.showingFeedback;
    if (!entering) return;
    final outcome = nextState.lastMoveOutcome;
    if (outcome != MoveOutcome.captured &&
        outcome != MoveOutcome.reachedFinish) {
      return;
    }

    final mover = nextState.currentPlayer;
    final l10n = AppLocalizations.of(context);
    final ride = AppMotion.of(context, AppMotion.moveMax);
    final hold = mover.isHuman ? kAnswerBeatDuration + ride : ride;

    _landingTimer?.cancel();
    if (outcome == MoveOutcome.captured) {
      // Who went home? The one horse now in the stable that was not.
      Player? victim;
      for (var p = 0; p < nextState.players.length; p++) {
        final before = prevState.players[p].horses;
        final after = nextState.players[p].horses;
        for (var h = 0; h < after.length && h < before.length; h++) {
          if (after[h].isHome && !before[h].isHome) {
            victim = nextState.players[p];
          }
        }
      }
      if (mover.isHuman) {
        _landingTimer = Timer(hold, () {
          _celebrate(
            CelebrationKind.capture,
            l10n.celebrateCaptureTitle,
            l10n.celebrateCaptureBody,
            sound: Sfx.capture,
          );
        });
      } else if (victim != null && victim.isHuman) {
        _landingTimer = Timer(hold, () {
          _celebrate(
            CelebrationKind.captured,
            l10n.celebrateCapturedTitle,
            l10n.celebrateCapturedBody,
            sound: Sfx.capture,
          );
        });
      } else {
        _landingTimer = Timer(
          hold,
          () => ref.read(soundServiceProvider).play(Sfx.capture),
        );
      }
    } else if (mover.isHuman) {
      _landingTimer = Timer(hold, () {
        _celebrate(
          CelebrationKind.arrival,
          l10n.celebrateArrivalTitle,
          l10n.celebrateArrivalBody,
          sound: Sfx.victory,
        );
      });
    }
  }

  TextStyle? _hudText(BuildContext context) => Theme.of(context)
      .textTheme
      .labelLarge
      ?.copyWith(color: const Color(0xFFF4ECDC), fontWeight: FontWeight.w600);

  /// Draws the turn's card, then holds the question back long enough
  /// for the card to turn over and be read — and, when the card is a
  /// key moment, for that moment to be shouted.
  void _onDrawCard() {
    if (_revealing || _celebration != null) return;
    final controller = ref.read(gameControllerProvider.notifier);
    ref.read(soundServiceProvider).play(Sfx.cardDraw);
    HapticFeedback.selectionClick();
    controller.drawCard();

    final session = ref.read(gameControllerProvider);
    final drawn = session?.gameState.drawnCard;
    final card = session?.currentQuestion;
    if (drawn == null) return; // the turn resolved without a card

    setState(() {
      _revealing = true;
      _revealValue = drawn.steps;
      // The pips are the rider's level — the same on every card they
      // draw — never something the card decided.
      _revealPips = switch (card?.difficulty ??
          session?.gameState.currentPlayer.profile.difficulty) {
        QuestionDifficulty.easy => 1,
        QuestionDifficulty.medium => 2,
        QuestionDifficulty.hard => 3,
        null => 1,
      };
    });

    // What the card is worth beyond its squares: a gate opening, a
    // second draw. Decided now, shouted once the card has been read.
    final l10n = AppLocalizations.of(context);
    final opensGate = controller.legalMoves.any((m) => m.exitsStable);
    (CelebrationKind, String, String, Sfx)? moment;
    if (drawn.grantsExtraTurn) {
      moment = (
        CelebrationKind.six,
        l10n.celebrateSixTitle,
        opensGate ? l10n.celebrateSixExitBody : l10n.celebrateSixBody,
        Sfx.six,
      );
    } else if (opensGate) {
      moment = (
        CelebrationKind.stableOpen,
        l10n.celebrateExitTitle,
        l10n.celebrateExitBody,
        Sfx.stableExit,
      );
    }

    _revealTimer?.cancel();
    _revealTimer = Timer(kCardRevealDuration, () {
      if (!mounted) return;
      setState(() => _revealing = false);
      if (moment != null) {
        _celebrate(moment.$1, moment.$2, moment.$3, sound: moment.$4);
      }
    });
  }

  /// Arms the two answer beats when a human's answer has just been
  /// judged, and clears them the moment the feedback phase is left.
  void _beginAnswerBeatsIfNeeded(GameSession? previous, GameSession? next) {
    if (previous == null || next == null) return;
    final prevState = previous.gameState;
    final nextState = next.gameState;
    final entering =
        nextState.turnPhase == TurnPhase.showingFeedback &&
        prevState.turnPhase != TurnPhase.showingFeedback;
    final leaving =
        nextState.turnPhase != TurnPhase.showingFeedback &&
        prevState.turnPhase == TurnPhase.showingFeedback;

    if (entering && nextState.currentPlayer.isHuman) {
      final idx = nextState.currentPlayerIndex;
      final before = prevState.players[idx].rewards.knowledgePoints;
      final after = nextState.players[idx].rewards.knowledgePoints;
      final earned = after - before;
      _beatTimer?.cancel();
      setState(() {
        _frozenBoard = prevState;
        _compactFeedback = false;
        _pointsEarned = earned > 0 ? earned : null;
      });
      _beatTimer = Timer(kAnswerBeatDuration, () {
        if (!mounted) return;
        setState(() {
          _frozenBoard = null;
          _compactFeedback = true;
        });
        if (_hoofsDeferred) {
          _hoofsDeferred = false;
          ref.read(soundServiceProvider).play(Sfx.moveHoofs);
        }
      });
    } else if (leaving) {
      _beatTimer?.cancel();
      _hoofsDeferred = false;
      setState(() {
        _frozenBoard = null;
        _compactFeedback = false;
        _pointsEarned = null;
      });
    }
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _resultsTimer?.cancel();
    _beatTimer?.cancel();
    _celebrationTimer?.cancel();
    _landingTimer?.cancel();
    super.dispose();
  }

  /// Turns game-state transitions into sound cues; the answer feedback,
  /// the ride itself, offers, streaks and the win each have a voice.
  void _playCuesFor(GameSession? previous, GameSession? next) {
    if (previous == null || next == null) return;
    final sound = ref.read(soundServiceProvider);
    final prevState = previous.gameState;
    final nextState = next.gameState;

    if (nextState.turnPhase == TurnPhase.gameOver &&
        prevState.turnPhase != TurnPhase.gameOver) {
      final winner = nextState.players
          .where((p) => p.id == nextState.winnerId)
          .firstOrNull;
      // The fanfare itself belongs to the results board; here only the
      // arrival is felt.
      if (winner == null || winner.isHuman) HapticFeedback.heavyImpact();
      return;
    }
    if (nextState.turnPhase == TurnPhase.showingFeedback &&
        prevState.turnPhase != TurnPhase.showingFeedback) {
      final correct = nextState.lastAnswerCorrect == true;
      sound.play(correct ? Sfx.correct : Sfx.wrong);
      // Felt, not only heard: a firm tap for right, a soft one for wrong.
      // Only the human's own answers buzz the phone.
      if (nextState.currentPlayer.isHuman) {
        correct ? HapticFeedback.mediumImpact() : HapticFeedback.lightImpact();
      }
    }
    if (nextState.justUnlocked.isNotEmpty &&
        nextState.justUnlocked.length != prevState.justUnlocked.length) {
      sound.play(Sfx.streak);
    }
    if (nextState.turnPhase == TurnPhase.resolvingCell &&
        prevState.turnPhase != TurnPhase.resolvingCell) {
      sound.play(Sfx.chest);
    }
    // Any horse actually moving = hoofbeats; arriving on an oasis adds
    // its water shimmer.
    var moved = false;
    for (var p = 0; p < nextState.players.length && !moved; p++) {
      final prevHorses = prevState.players[p].horses;
      final nextHorses = nextState.players[p].horses;
      for (var h = 0; h < nextHorses.length && !moved; h++) {
        moved = prevHorses[h].position != nextHorses[h].position;
      }
    }
    if (moved) {
      // A human's ride is held for one beat behind the answered card; the
      // hoofbeats wait for it so sound and motion arrive together.
      if (_frozenBoard != null) {
        _hoofsDeferred = true;
      } else {
        sound.play(Sfx.moveHoofs);
      }
      if (nextState.landedEffect == CellEffect.oasis) sound.play(Sfx.water);
    }
  }
}

// ---------------------------------------------------------------------
// HUD building blocks: dark glass floating over the world.
// ---------------------------------------------------------------------

class _HudPill extends StatelessWidget {
  const _HudPill({required this.child, this.highlight = false});

  final Widget child;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xB3122E22),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: highlight
              ? const Color(0xFFEBC06A)
              : Colors.white.withValues(alpha: 0.14),
          width: highlight ? 1.4 : 1,
        ),
      ),
      child: child,
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: Material(
        color: const Color(0xB3122E22),
        shape: CircleBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, size: 19, color: const Color(0xFFF4ECDC)),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// The gait bar: six compact horseshoe chips in a dark glass tray. Tap to
// arm (the board shows the destination), tap again or hit the gold arrow
// to ride.
// ---------------------------------------------------------------------

/// Between-turns status, floating over the world.
class _TurnBanner extends StatelessWidget {
  const _TurnBanner({required this.session, required this.l10n});

  final GameSession session;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final state = session.gameState;
    final outcome = state.lastMoveOutcome;
    final player = state.currentPlayer;
    final allHome = player.horses.every((h) => h.isHome);
    final String text;
    if (player.isHuman) {
      text = switch (outcome) {
        MoveOutcome.moved || MoveOutcome.bonusEarned => l10n.outcomeMoved,
        MoveOutcome.exitedStable => l10n.outcomeExited,
        MoveOutcome.stayed || MoveOutcome.bonusMissed => l10n.outcomeStayed,
        MoveOutcome.captured => l10n.outcomeCaptured,
        MoveOutcome.blockedByShield => l10n.outcomeShieldBlocked,
        MoveOutcome.reachedFinish => l10n.journeyQuestionIntro,
        // The card was seen; now the reason, in one line.
        MoveOutcome.noLegalMove =>
          allHome ? l10n.noExitHint : l10n.outcomeNoLegalMove,
        null => l10n.yourTurn,
      };
    } else {
      // The opponent's turn is narrated, never silent: what it drew,
      // then what happened. An unexplained pause reads as a freeze.
      final drawn = state.drawnCard;
      text = switch (outcome) {
        MoveOutcome.moved ||
        MoveOutcome.bonusEarned ||
        MoveOutcome.reachedFinish => l10n.opponentMoved(player.name),
        MoveOutcome.exitedStable => l10n.opponentExits(player.name),
        MoveOutcome.captured => l10n.opponentCaptured(player.name),
        MoveOutcome.noLegalMove => l10n.opponentNoMove(player.name),
        MoveOutcome.stayed ||
        MoveOutcome.bonusMissed ||
        MoveOutcome.blockedByShield => l10n.opponentStayed(player.name),
        null =>
          drawn != null
              ? l10n.opponentDrew(player.name, drawn.steps)
              : state.isBonusTurn
              ? l10n.opponentReplays(player.name)
              : l10n.opponentThinking(player.name),
      };
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xE610281E),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: const Color(0xFFF4ECDC),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// The Question Experience: the world stays visible, softly blurred and
// darkened; the question rises from the bottom on a parchment panel with
// a gold arch line — native to the game, not a dialog on a gray sheet.
// ---------------------------------------------------------------------

class _QuestionOverlay extends StatelessWidget {
  const _QuestionOverlay({
    required this.question,
    required this.isJourney,
    required this.isCellBonus,
    required this.selectedAnswer,
    required this.lastAnswerCorrect,
    required this.l10n,
    required this.onSelect,
    required this.onContinue,
    this.pointsEarned,
    this.justUnlocked,
    this.streakCurrent = 0,
    this.compact = false,
    this.largeText = false,
    this.stakeSteps,
  });

  final Question question;
  final bool isJourney;
  final bool isCellBonus;

  /// Squares the drawn card is worth, shown above the question so the
  /// child never loses sight of what the answer buys.
  final int? stakeSteps;
  final int? selectedAnswer;
  final bool? lastAnswerCorrect;

  /// Second beat of the answer: the world is clear (the horse is riding)
  /// and only a short sheet sits at the bottom.
  final bool compact;

  /// Child level: bigger answers on the card.
  final bool largeText;
  final AppLocalizations l10n;
  final ValueChanged<int> onSelect;
  final VoidCallback onContinue;

  /// Knowledge points the answer just earned; shown as an immediate
  /// reward chip so every correct answer pays out visibly.
  final int? pointsEarned;

  /// A streak reward crossed by this very answer — the hero moment.
  final StreakReward? justUnlocked;
  final int streakCurrent;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    if (compact) {
      return Positioned.fill(
        child: Stack(
          children: [
            // Only the bottom is scrimmed: the board, and the horse
            // riding across it, stay sharp above the sheet.
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.55, 1.0],
                      colors: [
                        Color(0x0006231A),
                        Color(0x1A06231A),
                        Color(0xB306231A),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (pointsEarned != null)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: justUnlocked != null
                        ? _StreakBurst(
                            unlocked: justUnlocked!,
                            streak: streakCurrent,
                          )
                        : _RewardChip(points: pointsEarned!),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: screen.height * 0.5),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                    reverse: true,
                    child: AnswerFeedbackSheet(
                      question: question,
                      isCorrect: lastAnswerCorrect ?? false,
                      showExplanation: !largeText,
                      onContinue: onContinue,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Positioned.fill(
      child: Stack(
        children: [
          // The world dims and softens but never disappears.
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x3D06231A), Color(0xCC06231A)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // The payout floats over the world, above the panel, where the
          // eye already is. A streak threshold turns it into a hero
          // moment: a golden burst behind the reward.
          if (pointsEarned != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  // Below the two HUD rows, over the top of the plate:
                  // a chip that lands on the rider's name pill hides it.
                  padding: const EdgeInsets.only(top: 104),
                  child: justUnlocked != null
                      // The unlock IS the payout: one hero beat, no
                      // competing chip.
                      ? _StreakBurst(
                          unlocked: justUnlocked!,
                          streak: streakCurrent,
                        )
                      : _RewardChip(points: pointsEarned!),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: screen.height * 0.86),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                reverse: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isJourney)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          l10n.journeyQuestion,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: const Color(0xFFF4ECDC)),
                        ),
                      ),
                    if (stakeSteps != null && lastAnswerCorrect == null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _StakeChip(steps: stakeSteps!, l10n: l10n),
                      ),
                    // The gold arch line crowning the panel ties it to the
                    // game's architecture.
                    const _ArchCrest(),
                    QuestionCard(
                      question: question,
                      selectedIndex: selectedAnswer,
                      isCorrect: lastAnswerCorrect,
                      // Beat one holds the verdict on the tiles only;
                      // the rest follows on the sheet.
                      brief: true,
                      largeText: largeText,
                      onSelect: onSelect,
                      onContinue: null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The drawn card's value, restated right above the question: "5 — worth
/// 5 squares". The card flip was a second ago; this keeps the stake in
/// view while the child reads.
class _StakeChip extends StatelessWidget {
  const _StakeChip({required this.steps, required this.l10n});

  final int steps;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final worth = l10n.cardWorth(steps);
    return Semantics(
      label: worth,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 4, 14, 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: const Color(0xCC0A2A2E),
            border: Border.all(color: const Color(0xFFC59F4A), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF3D68A), Color(0xFFDBA83E)],
                  ),
                ),
                child: Text(
                  '$steps',
                  style: const TextStyle(
                    color: Color(0xFF3A2A08),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                worth,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFFF4ECDC),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchCrest extends StatelessWidget {
  const _ArchCrest();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 132,
      child: CustomPaint(painter: _ArchCrestPainter()),
    );
  }
}

class _ArchCrestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFEBC06A);
    canvas.drawPath(
      Path()
        ..moveTo(0, h)
        ..cubicTo(w * 0.28, h, w * 0.36, h * 0.12, w * 0.5, h * 0.06)
        ..cubicTo(w * 0.64, h * 0.12, w * 0.72, h, w, h),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArchCrestPainter oldDelegate) => false;
}

/// A streak threshold crossed: golden rays burst behind the reward and
/// the earned emblem scales in — one hero beat, then play continues.
class _StreakBurst extends StatelessWidget {
  const _StreakBurst({required this.unlocked, required this.streak});

  final StreakReward unlocked;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final icon = switch (unlocked) {
      StreakReward.shield => Icons.shield,
      StreakReward.grandGallop => Icons.bolt,
      StreakReward.masteryBadge => Icons.workspace_premium,
    };
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.of(context, AppMotion.reward),
      curve: AppMotion.settle,
      builder: (context, t, child) {
        final c = t.clamp(0.0, 1.0);
        return Opacity(
          opacity: c,
          child: Transform.scale(scale: 0.6 + 0.4 * t, child: child),
        );
      },
      child: SizedBox(
        width: 170,
        height: 130,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const CustomPaint(
              size: Size(170, 130),
              painter: _SunburstPainter(),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 44, color: const Color(0xFFFFEBB8)),
                Text(
                  '×$streak',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFFFFEBB8),
                    fontWeight: FontWeight.w900,
                    shadows: const [
                      Shadow(color: Color(0x99000000), blurRadius: 10),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  const _SunburstPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.72;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.radial(c, r, [
          const Color(0xB3F3D68A),
          const Color(0x00F3D68A),
        ]),
    );
    final ray = Paint()..color = const Color(0x66FFE9AE);
    for (var i = 0; i < 12; i++) {
      final a = i * 3.14159 / 6;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(a);
      canvas.drawPath(
        Path()
          ..moveTo(0, -r * 0.30)
          ..lineTo(r * 0.055, -r)
          ..lineTo(-r * 0.055, -r)
          ..close(),
        ray,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) => false;
}

/// The immediate payout of a correct answer: a gold chip that pops in,
/// rises, and settles. Short (one reward beat), language-free ("+2" and a
/// star read everywhere), and skipped to its end state under Reduce
/// Motion.
class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.of(context, AppMotion.reward),
      curve: AppMotion.settle,
      builder: (context, t, child) {
        final clamped = t.clamp(0.0, 1.0);
        return Opacity(
          opacity: clamped,
          child: Transform.translate(
            offset: Offset(0, (1 - clamped) * 16),
            child: Transform.scale(scale: 0.7 + 0.3 * t, child: child),
          ),
        );
      },
      child: Semantics(
        label: '+$points',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF3D68A), Color(0xFFDBA83E)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDBA83E).withValues(alpha: 0.5),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 18,
                color: Color(0xFF5A4210),
              ),
              const SizedBox(width: 6),
              Text(
                '+$points',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF5A4210),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The card is drawn and more than one horse could use it: bring one
/// out of the stable, or ride one already on the road. One tap decides;
/// the horses on the plate wear the ring and answer to a tap as well.
class _MoveChoiceSheet extends StatelessWidget {
  const _MoveChoiceSheet({
    required this.card,
    required this.moves,
    required this.l10n,
    required this.onChoose,
  });

  final MovementChoice card;
  final List<LegalMove> moves;
  final AppLocalizations l10n;
  final ValueChanged<int> onChoose;

  @override
  Widget build(BuildContext context) {
    // Every horse in the stable is the same horse to bring out: one
    // line for the gate, then one per horse on the road.
    final options =
        <({int horseIndex, String label, List<String> tags, IconData icon})>[];
    final exit = moves.where((m) => m.exitsStable).firstOrNull;
    if (exit != null) {
      options.add((
        horseIndex: exit.horseIndex,
        label: l10n.moveChoiceExit,
        tags: [if (exit.capturesOpponent) l10n.moveHintCapture],
        icon: Icons.door_sliding_outlined,
      ));
    }
    for (final m in moves) {
      if (m.exitsStable) continue;
      options.add((
        horseIndex: m.horseIndex,
        label: l10n.moveChoiceAdvance(m.horseIndex + 1, card.steps),
        tags: [
          if (m.reachesFinish) l10n.moveHintFinish,
          if (m.capturesOpponent) l10n.moveHintCapture,
          if (m.effect == CellEffect.oasis) l10n.moveHintOasis,
        ],
        icon: Icons.arrow_circle_right_outlined,
      ));
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Container(
          key: const Key('move-choice'),
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xF210281E),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFEBC06A).withValues(alpha: 0.55),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFF3D68A), Color(0xFFDBA83E)],
                      ),
                    ),
                    child: Text(
                      '${card.steps}',
                      style: const TextStyle(
                        color: Color(0xFF3A2A08),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.moveChoiceTitle(card.steps),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFF3D68A),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < options.length; i++)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                  child: _MoveOption(
                    key: Key('move-option-$i'),
                    icon: options[i].icon,
                    label: options[i].label,
                    tags: options[i].tags,
                    primary: i == 0,
                    onTap: () => onChoose(options[i].horseIndex),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoveOption extends StatelessWidget {
  const _MoveOption({
    super.key,
    required this.icon,
    required this.label,
    required this.tags,
    required this.primary,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final List<String> tags;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = primary ? const Color(0xFF4A3410) : const Color(0xFFF4ECDC);
    return Material(
      clipBehavior: Clip.antiAlias,
      color: primary ? Colors.transparent : const Color(0x1AFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: primary
            ? BorderSide.none
            : BorderSide(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Ink(
        decoration: primary
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF3D68A), Color(0xFFD8A032)],
                ),
              )
            : null,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 22, color: ink),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(color: ink, fontWeight: FontWeight.w800),
                  ),
                ),
                for (final tag in tags)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: primary
                            ? const Color(0x334A3410)
                            : const Color(0x33EBC06A),
                        border: Border.all(
                          color: primary
                              ? const Color(0x664A3410)
                              : const Color(0xAAEBC06A),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: primary ? ink : const Color(0xFFF3D68A),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The optional offer from a Défi or Raccourci square. Declining is always
/// free — failing the optional question only costs the bonus.
class _CellOfferSheet extends StatelessWidget {
  const _CellOfferSheet({
    required this.effect,
    required this.l10n,
    required this.onAccept,
    required this.onDecline,
  });

  final CellEffect effect;
  final AppLocalizations l10n;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final title = switch (effect) {
      CellEffect.challenge => l10n.cellChallenge,
      CellEffect.shortcut => l10n.cellShortcut,
      CellEffect.duel => l10n.cellDuel,
      CellEffect.relay => l10n.cellRelay,
      _ => l10n.cellKnowledge,
    };
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: const Color(0xFF10281E),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFFEBC06A).withValues(alpha: 0.55),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The chest itself, glowing — the player sees the exact
            // object they rode to, not an abstract dialog.
            if (effect == CellEffect.challenge || effect == CellEffect.shortcut)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: AppMotion.of(context, AppMotion.reward),
                curve: AppMotion.settle,
                builder: (context, t, child) => Transform.scale(
                  scale: 0.7 + 0.3 * t.clamp(0.0, 1.0),
                  child: child,
                ),
                child: const ArtPanel(
                  asset: AppArt.chestGlow,
                  width: 108,
                  height: 118,
                  radius: 18,
                  glow: true,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFFF3D68A),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.cellChallengeOffer,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: const Color(0xFFE9DFC8)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onDecline,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xCCE9DFC8),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: ButtonLabel(l10n.declineChallenge),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: Material(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFF3D68A), Color(0xFFD8A032)],
                          ),
                        ),
                        child: InkWell(
                          onTap: onAccept,
                          child: Center(
                            child: Text(
                              l10n.acceptChallenge,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: const Color(0xFF4A3410),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
