import 'dart:ui' as ui;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart'
    show
        gameEngineProvider,
        hapticServiceProvider,
        settingsControllerProvider,
        soundServiceProvider;
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../services/sound_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/board/cross_board_scene.dart';
import '../../../widgets/bonus_callout.dart';
import '../../../widgets/celebration_overlay.dart';
import '../../../widgets/earned_steps_medallion.dart';
import '../../../widgets/illustration.dart';
import '../../../widgets/question_card.dart';
import '../../../widgets/question_card_draw.dart';
import '../application/game_controller.dart';
import '../domain/game_engine.dart';
import '../../../widgets/button_label.dart';

/// How long the answered card stays up, verdict on the tiles, before it
/// folds down to the short sheet with the way on. Long enough to read
/// "right" or "wrong"; short enough that the prize is what comes next.
const Duration kAnswerBeatDuration = Duration(milliseconds: 1000);

/// How long the result medallion holds the centre of the board before
/// it gives way to the placement — the board is already live under it.
const Duration kEarnBeat = Duration(milliseconds: 1700);

/// How long "X takes the lead" stays on the HUD.
const Duration kLeadToastDuration = Duration(milliseconds: 1900);

/// The game screen is the world: a full-bleed dawn landscape with the
/// journey tilted into perspective, and every piece of UI floating over
/// it. No app bar, no page chrome — opening this screen must feel like
/// entering a place, not a form.
///
/// A turn on it, in order: tap the deck, answer the question, read the
/// verdict, watch the squares won land as a medallion, pick a horse up
/// off the plate and set it down on its lit square — the drop is the
/// move, nothing asks to confirm — then, if the horse stopped on a
/// bonus, see it flare and ride on.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int? _selectedAnswer;
  String? _dismissedQuestionId;

  /// The key moment on screen, if any: a capture, an arrival. Held for
  /// one beat over everything else, tap to skip.
  CelebrationKind? _celebration;
  String _celebrationTitle = '';
  String _celebrationBody = '';
  Timer? _celebrationTimer;
  Timer? _landingTimer;

  /// An answer plays in two beats. Beat one: the card shows the verdict
  /// on its tiles. Beat two: the card folds down to a short sheet with
  /// the explanation and the way on.
  bool _compactFeedback = false;
  int? _pointsEarned;
  Timer? _beatTimer;

  /// While the drawn card is turning over, the question sheet is held
  /// back: the card lands on its question mark, then the question opens.
  bool _revealing = false;
  int _revealPips = 1;
  Timer? _revealTimer;
  Timer? _resultsTimer;

  /// The squares just won, landing as a medallion over the board.
  bool _earnBeat = false;
  Timer? _earnTimer;

  /// The placement in progress on the plate: which horse is lit, and
  /// whether one is under the finger — for the banner's hint.
  int? _placementSelected;
  bool _dragging = false;

  /// "X takes the lead", briefly.
  String? _leadToast;
  Timer? _leadTimer;
  String? _leaderId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    // Watched, not read: the board's own mute button has to redraw the
    // moment it is tapped.
    final soundOn = ref.watch(settingsControllerProvider).soundEnabled;
    final session = ref.watch(gameControllerProvider);

    ref.listen(gameControllerProvider, (previous, next) {
      _beginAnswerBeatsIfNeeded(previous, next);
      _beginEarnBeatIfNeeded(previous, next);
      _playCuesFor(previous, next);
      _celebrateLandingsIfNeeded(previous, next);
      _watchTheLead(previous, next);
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
      if (next?.gameState.turnPhase != TurnPhase.choosingHorse &&
          (_placementSelected != null || _dragging)) {
        setState(() {
          _placementSelected = null;
          _dragging = false;
        });
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

    // The placement: the board is the control. Every horse that can
    // ride the won squares is offered with its destination; the drop
    // validates.
    BoardPlacement? placement;
    if (state.turnPhase == TurnPhase.choosingHorse &&
        player.isHuman &&
        _celebration == null) {
      final legal = ref.read(gameControllerProvider.notifier).legalMoves;
      placement = BoardPlacement(
        teamIndex: state.currentPlayerIndex,
        options: [
          for (final m in legal)
            PlacementOption(
              horseIndex: m.horseIndex,
              destination: m.destination,
              exitsStable: m.exitsStable,
              bonusValue: m.bonusValue,
              capturesOpponent: m.capturesOpponent,
              reachesFinish: m.reachesFinish,
              tag: _tagFor(m, l10n),
            ),
        ],
      );
    }
    final leader = ref.read(gameEngineProvider).leader(state);
    final pendingBonus = state.pendingBonus;

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
            // the HUD and the deck stay put above it. While a horse is
            // being placed the viewer stands still: the finger on the
            // plate is moving a horse, never the board.
            Positioned.fill(
              child: InteractiveViewer(
                key: const Key('board-zoom'),
                minScale: 1,
                maxScale: 2.5,
                panEnabled: placement == null,
                scaleEnabled: placement == null,
                child: CrossBoardScene(
                  key: const Key('board-scene'),
                  state: state,
                  placement: placement,
                  onHorseSelected: (h) {
                    if (h == null) return;
                    ref.read(soundServiceProvider).play(Sfx.tap);
                    ref.read(hapticServiceProvider).select();
                    setState(() => _placementSelected = h);
                  },
                  onDragStarted: (h) {
                    ref.read(soundServiceProvider).play(Sfx.pickup);
                    ref.read(hapticServiceProvider).pickup();
                    setState(() {
                      _placementSelected = h;
                      _dragging = true;
                    });
                  },
                  onHorseDropped: (h) {
                    final ok = ref
                        .read(gameControllerProvider.notifier)
                        .placeHorse(h);
                    if (ok) {
                      ref.read(soundServiceProvider).play(Sfx.drop);
                      ref.read(hapticServiceProvider).drop();
                      _earnTimer?.cancel();
                      setState(() {
                        _earnBeat = false;
                        _placementSelected = null;
                        _dragging = false;
                      });
                    }
                    return ok;
                  },
                  onBadDrop: (h) {
                    ref.read(soundServiceProvider).play(Sfx.snapBack);
                    ref.read(hapticServiceProvider).wrongDrop();
                    setState(() => _dragging = false);
                  },
                ),
              ),
            ),

            // ---- Floating HUD ----
            //
            // Read top to bottom: who is playing, where the race stands,
            // and what this rider has earned. Every number carries the
            // word for what it counts — a bare "4/5" beside a flame told
            // nobody anything — and the whole stack is centred under a
            // button bar with the same weight on both sides.
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _GlassIconButton(
                          key: const Key('board-back'),
                          icon: Icons.arrow_back,
                          label: MaterialLocalizations.of(
                            context,
                          ).backButtonTooltip,
                          onTap: () => context.go('/home'),
                        ),
                        const SizedBox(width: 6),
                        // Silence, within reach of the thumb that is
                        // already on the board: a table that starts a
                        // race in a quiet room should not have to leave
                        // the game to find the setting.
                        _GlassIconButton(
                          key: const Key('mute-toggle'),
                          icon: soundOn ? Icons.volume_up : Icons.volume_off,
                          label: soundOn ? l10n.muteSound : l10n.unmuteSound,
                          onTap: () => ref
                              .read(settingsControllerProvider.notifier)
                              .setSoundEnabled(!soundOn),
                        ),
                        const SizedBox(width: 8),
                        // The name takes the middle and ellipsizes inside
                        // it, so the two pairs of buttons stay level.
                        Expanded(
                          child: Center(
                            child: _HudPill(
                              highlight: true,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 6,
                                    backgroundColor: player.team.color(colors),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
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
                          ),
                        ),
                        const SizedBox(width: 8),
                        _GlassIconButton(
                          key: const Key('rules-shortcut'),
                          icon: Icons.help_outline,
                          label: l10n.rulesTitle,
                          onTap: () => context.push('/tutorial'),
                        ),
                        const SizedBox(width: 6),
                        _GlassIconButton(
                          key: const Key('board-menu'),
                          icon: Icons.menu,
                          label: l10n.boardMenuOpen,
                          onTap: () => _openBoardMenu(context, ref, l10n),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // The standing of the race. One heading over the row
                    // says what all four numbers count, which is cheaper
                    // than repeating the word in every pill — and the
                    // painted stables are scenery, so this is the only
                    // place the score is actually readable.
                    _HudGroup(
                      heading: l10n.hudArrivedHeading,
                      children: [
                        for (var i = 0; i < state.players.length; i++)
                          _HudPill(
                            highlight: i == state.currentPlayerIndex,
                            child: Semantics(
                              label: state.players[i].id == leader.id
                                  ? '${state.players[i].name}, '
                                        '${l10n.hudArrivedHeading} '
                                        '${state.players[i].horses.where((h) => h.position is FinishedPosition).length}'
                                        '/${state.players[i].horses.length}, '
                                        '${l10n.leaderLabel}'
                                  : '${state.players[i].name}, '
                                        '${l10n.hudArrivedHeading} '
                                        '${state.players[i].horses.where((h) => h.position is FinishedPosition).length}'
                                        '/${state.players[i].horses.length}',
                              child: ExcludeSemantics(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 5,
                                      backgroundColor: state.players[i].team
                                          .color(colors),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${state.players[i].horses.where((h) => h.position is FinishedPosition).length}'
                                      '/${state.players[i].horses.length}',
                                      style: _hudText(context),
                                    ),
                                    if (state.players[i].id == leader.id &&
                                        state.players.length > 1) ...[
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.star_rounded,
                                        key: Key('leader-star'),
                                        size: 14,
                                        color: Color(0xFFFFE08A),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // What this rider has earned, and — in the free
                    // edition — how far into its fifty cards the table is.
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _HudStat(
                          key: const Key('hud-knowledge'),
                          icon: Icons.auto_awesome,
                          iconColor: const Color(0xFFEBC06A),
                          value: '${player.rewards.knowledgePoints}',
                          word: l10n.hudKnowledgeShort,
                          semantics:
                              '${l10n.knowledgePointsLabel} : '
                              '${player.rewards.knowledgePoints}',
                        ),
                        _HudStat(
                          key: const Key('hud-streak'),
                          icon: Icons.local_fire_department,
                          iconColor: player.streak.current > 0
                              ? const Color(0xFFF0A24B)
                              : Colors.white38,
                          value:
                              '${player.streak.current}/${player.streak.nextThreshold}',
                          word: l10n.hudStreakShort,
                          highlight: player.streak.current >= 3,
                          semantics:
                              '${l10n.knowledgeStreak} : '
                              '${player.streak.current} / ${player.streak.nextThreshold}',
                        ),
                        if (state.maxDraws != null)
                          _HudStat(
                            key: const Key('hud-cards'),
                            icon: Icons.style,
                            iconColor: const Color(0xFFEBC06A),
                            value: '${state.drawCount}/${state.maxDraws}',
                            word: l10n.hudCardsShort,
                            semantics: l10n.drawsCounter(
                              state.drawCount,
                              state.maxDraws!,
                            ),
                          ),
                      ],
                    ),
                    if (_leadToast != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(child: _LeadToast(text: _leadToast!)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ---- Bottom: the deck, the placement banner or the turn pill ----
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
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: _PlacementBanner(
                    value: state.drawnCard?.steps ?? 0,
                    title: l10n.squaresWon(state.drawnCard?.steps ?? 0),
                    hint: _placementSelected == null
                        ? l10n.touchHorseHint
                        : l10n.dragHorseToDestination,
                    extra: state.extraTurn ? l10n.celebrateSixBody : null,
                  ),
                ),
              )
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
                    // The stake is announced with the card — "a
                    // five-gallop card" — so the player knows what the
                    // right answer is worth before reading the question.
                    child: DrawnCardReveal(
                      value: state.drawnCard?.steps,
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
                // The stake stays in view while the question is read:
                // only the turn's own card carries one.
                stake:
                    state.drawnCard != null &&
                        state.turnPhase != TurnPhase.answeringJourneyQuestion &&
                        state.turnPhase != TurnPhase.resolvingCell
                    ? l10n.cardWorth(state.drawnCard!.steps)
                    : null,
                selectedAnswer: _selectedAnswer,
                // The verdict belongs to the question being judged, and
                // to no other. A journey question or a special square's
                // question opens in its own phase, and reading the
                // previous answer's verdict there is what once showed a
                // fresh card already answered — its tiles dead, its right
                // answer given away.
                lastAnswerCorrect:
                    state.turnPhase == TurnPhase.showingFeedback
                    ? state.lastAnswerCorrect
                    : null,
                compact: _compactFeedback && state.lastAnswerCorrect != null,
                largeText: player.profile.isChildMode,
                note:
                    state.lastAnswerCorrect == false &&
                        state.turnPhase == TurnPhase.showingFeedback &&
                        session.journeyHorseIndex == null &&
                        state.drawnCard != null &&
                        state.movedHorseIndex == null
                    ? l10n.cardWasWorth(state.drawnCard!.steps)
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
                  ref.read(hapticServiceProvider).select();
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

            // The prize: the squares won, as a medallion over the board.
            // Not a modal — the horses under it are already live.
            if (_earnBeat && state.drawnCard != null)
              Positioned.fill(
                key: const Key('earn-medallion'),
                child: IgnorePointer(
                  child: Align(
                    alignment: const Alignment(0, -0.22),
                    child: EarnedStepsMedallion(
                      value: state.drawnCard!.steps,
                      caption: l10n.squaresWon(state.drawnCard!.steps),
                    ),
                  ),
                ),
              ),

            // BONUS +10: the square under the horse has fired; it rides
            // on the moment this beat is over.
            if (pendingBonus != null)
              Positioned.fill(
                key: const Key('bonus-callout'),
                child: IgnorePointer(
                  child: Align(
                    alignment: const Alignment(0, -0.18),
                    child: BonusCallout(
                      value: pendingBonus.value,
                      label: pendingBonus.fromCapture
                          ? l10n.captureBonusLabel
                          : l10n.bonusLabel,
                      valueText: l10n.bonusPlus(pendingBonus.value),
                    ),
                  ),
                ),
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

  /// What the destination holds, in two words, for the marker's tag.
  String? _tagFor(LegalMove m, AppLocalizations l10n) {
    if (m.reachesFinish) return l10n.moveHintFinish;
    if (m.capturesOpponent) return l10n.moveHintCapture(kCaptureBonus);
    if (m.bonusValue != null) return l10n.moveHintBonus(m.bonusValue!);
    if (m.effect == CellEffect.oasis) return l10n.moveHintOasis;
    return null;
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
    if (kind != CelebrationKind.captured) {
      ref.read(hapticServiceProvider).heavy();
    }
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

  /// How long the board takes to show the ride that just happened, so
  /// a burst can wait for the horse to land. A horse set down by hand is
  /// already there; an opponent's ride and a bonus ride hop across.
  Duration _rideHold(GameSession previous, GameSession next) {
    final prev = previous.gameState;
    final now = next.gameState;
    final byHand =
        now.currentPlayer.isHuman &&
        prev.turnPhase == TurnPhase.choosingHorse &&
        now.turnPhase == TurnPhase.movingHorse;
    if (byHand) return const Duration(milliseconds: 380);
    final idx = now.currentPlayerIndex;
    final circuit = now.circuit;
    var steps = 0;
    var leap = false;
    final before = prev.players[idx].horses;
    final after = now.players[idx].horses;
    for (var h = 0; h < after.length && h < before.length; h++) {
      if (before[h].position == after[h].position) continue;
      final p0 = circuit.progressOf(before[h].position, idx);
      final p1 = circuit.progressOf(after[h].position, idx);
      if (p0 == null || p1 == null) {
        leap = true;
      } else {
        steps = (p1 - p0).abs();
      }
    }
    return AppMotion.of(context, rideDurationFor(steps, leap: leap));
  }

  /// A capture or an arrival is celebrated when the horse *lands*: after
  /// the ride itself, so the burst happens where the eye already is.
  void _celebrateLandingsIfNeeded(GameSession? previous, GameSession? next) {
    if (previous == null || next == null) return;
    final prevState = previous.gameState;
    final nextState = next.gameState;
    // A ride happened: a horse was set down, or the bonus was ridden.
    final rode =
        (nextState.turnPhase == TurnPhase.movingHorse &&
            prevState.turnPhase == TurnPhase.choosingHorse) ||
        (prevState.pendingBonus != null && nextState.pendingBonus == null);
    if (!rode) return;
    final outcome = nextState.lastMoveOutcome;
    if (outcome != MoveOutcome.captured &&
        outcome != MoveOutcome.reachedFinish) {
      return;
    }
    // A bonus ride that neither captured nor arrived carries the first
    // ride's outcome forward: only celebrate what this ride did.
    if (prevState.pendingBonus != null &&
        prevState.lastMoveOutcome == outcome &&
        !_someoneWentHome(prevState, nextState) &&
        outcome == MoveOutcome.captured) {
      return;
    }

    final mover = nextState.currentPlayer;
    final l10n = AppLocalizations.of(context);
    final hold = _rideHold(previous, next);

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

  bool _someoneWentHome(GameState before, GameState after) {
    for (var p = 0; p < after.players.length; p++) {
      final b = before.players[p].horses;
      final a = after.players[p].horses;
      for (var h = 0; h < a.length && h < b.length; h++) {
        if (a[h].isHome && !b[h].isHome) return true;
      }
    }
    return false;
  }

  /// Draws the turn's card, then holds the question back long enough
  /// for the card to turn over onto its question mark.
  void _onDrawCard() {
    if (_revealing || _celebration != null) return;
    final controller = ref.read(gameControllerProvider.notifier);
    ref.read(soundServiceProvider).play(Sfx.cardDraw);
    ref.read(hapticServiceProvider).select();
    controller.drawCard();

    final session = ref.read(gameControllerProvider);
    final drawn = session?.gameState.drawnCard;
    final card = session?.currentQuestion;
    if (drawn == null || card == null) return; // the turn resolved itself

    setState(() {
      _revealing = true;
      // The pips are the rider's level — the same on every card they
      // draw — never something the card decided.
      _revealPips = switch (card.difficulty) {
        QuestionDifficulty.easy => 1,
        QuestionDifficulty.medium => 2,
        QuestionDifficulty.hard => 3,
      };
    });

    _revealTimer?.cancel();
    _revealTimer = Timer(kCardRevealDuration, () {
      if (!mounted) return;
      setState(() => _revealing = false);
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
        _compactFeedback = false;
        _pointsEarned = earned > 0 ? earned : null;
      });
      _beatTimer = Timer(kAnswerBeatDuration, () {
        if (!mounted) return;
        setState(() => _compactFeedback = true);
      });
    } else if (leaving) {
      _beatTimer?.cancel();
      setState(() {
        _compactFeedback = false;
        _pointsEarned = null;
      });
    }
  }

  /// The squares are won: the medallion lands over the board for a
  /// beat. The placement under it is already live — a quick hand can
  /// pick a horse up before the medallion has faded.
  void _beginEarnBeatIfNeeded(GameSession? previous, GameSession? next) {
    if (previous == null || next == null) return;
    final prevState = previous.gameState;
    final nextState = next.gameState;
    final opened =
        (nextState.turnPhase == TurnPhase.choosingHorse ||
            nextState.turnPhase == TurnPhase.noMove) &&
        prevState.turnPhase == TurnPhase.showingFeedback &&
        nextState.currentPlayer.isHuman;
    if (!opened) return;
    _earnTimer?.cancel();
    setState(() => _earnBeat = true);
    _earnTimer = Timer(AppMotion.of(context, kEarnBeat), () {
      if (!mounted) return;
      setState(() => _earnBeat = false);
    });
  }

  /// A change of leader is said once, quietly, on the HUD.
  void _watchTheLead(GameSession? previous, GameSession? next) {
    if (next == null) return;
    final state = next.gameState;
    if (state.players.length < 2) return;
    final leader = ref.read(gameEngineProvider).leader(state);
    final wasNobody = _leaderId == null;
    if (_leaderId == leader.id) return;
    _leaderId = leader.id;
    if (wasNobody || previous == null) return;
    // Only an actual overtake — a horse that moved — not a tie-break
    // shifting on points.
    final moved = _anyHorseMoved(previous.gameState, state);
    if (!moved) return;
    _leadTimer?.cancel();
    setState(() => _leadToast = AppLocalizations.of(context).tookTheLead(leader.name));
    _leadTimer = Timer(kLeadToastDuration, () {
      if (mounted) setState(() => _leadToast = null);
    });
  }

  bool _anyHorseMoved(GameState before, GameState after) {
    for (var p = 0; p < after.players.length && p < before.players.length; p++) {
      final b = before.players[p].horses;
      final a = after.players[p].horses;
      for (var h = 0; h < a.length && h < b.length; h++) {
        if (a[h].position != b[h].position) return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _resultsTimer?.cancel();
    _beatTimer?.cancel();
    _celebrationTimer?.cancel();
    _landingTimer?.cancel();
    _earnTimer?.cancel();
    _leadTimer?.cancel();
    super.dispose();
  }

  /// Turns game-state transitions into sound and touch cues; the answer
  /// feedback, the prize, the ride, the bonus, offers, streaks and the
  /// win each have a voice.
  void _playCuesFor(GameSession? previous, GameSession? next) {
    if (previous == null || next == null) return;
    final sound = ref.read(soundServiceProvider);
    final haptics = ref.read(hapticServiceProvider);
    final prevState = previous.gameState;
    final nextState = next.gameState;
    final human = nextState.currentPlayer.isHuman;

    if (nextState.turnPhase == TurnPhase.gameOver &&
        prevState.turnPhase != TurnPhase.gameOver) {
      final winner = nextState.players
          .where((p) => p.id == nextState.winnerId)
          .firstOrNull;
      // The fanfare itself belongs to the results board; here only the
      // arrival is felt.
      if (winner == null || winner.isHuman) haptics.heavy();
      return;
    }
    if (nextState.turnPhase == TurnPhase.showingFeedback &&
        prevState.turnPhase != TurnPhase.showingFeedback) {
      final correct = nextState.lastAnswerCorrect == true;
      sound.play(correct ? Sfx.correct : Sfx.wrong);
      // Felt, not only heard: a firm tap for right, a soft one for wrong.
      // Only the human's own answers buzz the phone.
      if (human) correct ? haptics.correct() : haptics.wrong();
    }
    // The squares are won: the medallion lands. A 6 says so in its own
    // voice — it is also a second draw.
    if ((nextState.turnPhase == TurnPhase.choosingHorse ||
            nextState.turnPhase == TurnPhase.noMove) &&
        prevState.turnPhase == TurnPhase.showingFeedback &&
        human) {
      sound.play(nextState.extraTurn ? Sfx.six : Sfx.earn);
      haptics.earn();
    }
    // A bonus square fires: +5, +10 and +20 each have their own voice
    // and their own weight in the hand.
    final bonus = nextState.pendingBonus;
    if (bonus != null && prevState.pendingBonus == null) {
      sound.play(switch (bonus.value) {
        >= 20 => Sfx.bonusBig,
        >= 10 => Sfx.bonusMid,
        _ => Sfx.bonusSmall,
      });
      if (human) haptics.bonus(bonus.value);
    }
    if (nextState.justUnlocked.isNotEmpty &&
        nextState.justUnlocked.length != prevState.justUnlocked.length) {
      sound.play(Sfx.streak);
    }
    if (nextState.turnPhase == TurnPhase.resolvingCell &&
        prevState.turnPhase != TurnPhase.resolvingCell) {
      sound.play(Sfx.chest);
    }
    // Any horse actually riding = hoofbeats; arriving on an oasis adds
    // its water shimmer. A horse set down by hand has its own drop
    // sound and does not ride.
    final byHand =
        human &&
        prevState.turnPhase == TurnPhase.choosingHorse &&
        nextState.turnPhase == TurnPhase.movingHorse;
    if (!byHand && _anyHorseMoved(prevState, nextState)) {
      sound.play(Sfx.moveHoofs);
    }
    if (_anyHorseMoved(prevState, nextState) &&
        nextState.landedEffect == CellEffect.oasis) {
      sound.play(Sfx.water);
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

/// The board's own menu: the few things a table asks for mid-race
/// without wanting to leave the game — the rules, the switches that
/// change how a turn feels, a clean restart, and the way out (which
/// keeps the save).
///
/// It is a sheet rather than a screen because the board must stay
/// visible behind it: nothing here is a decision about the race.
Future<void> _openBoardMenu(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Consumer(
        builder: (context, ref, _) {
          final settings = ref.watch(settingsControllerProvider);
          final notifier = ref.read(settingsControllerProvider.notifier);
          final text = Theme.of(context).textTheme;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    l10n.boardMenuTitle,
                    textAlign: TextAlign.center,
                    style: text.titleLarge,
                  ),
                ),
                ListTile(
                  key: const Key('menu-rules'),
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(l10n.rulesTitle),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/tutorial');
                  },
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  key: const Key('menu-auto-move'),
                  value: settings.autoPlaceSingleMove,
                  onChanged: notifier.setAutoPlaceSingleMove,
                  secondary: const Icon(Icons.bolt_outlined),
                  title: Text(l10n.autoPlaySingleMove),
                  subtitle: Text(l10n.autoPlaySingleMoveHint),
                ),
                SwitchListTile.adaptive(
                  key: const Key('menu-sound'),
                  value: settings.soundEnabled,
                  onChanged: notifier.setSoundEnabled,
                  secondary: const Icon(Icons.volume_up_outlined),
                  title: Text(l10n.soundEffects),
                ),
                SwitchListTile.adaptive(
                  key: const Key('menu-haptics'),
                  value: settings.hapticsEnabled,
                  onChanged: notifier.setHapticsEnabled,
                  secondary: const Icon(Icons.vibration),
                  title: Text(l10n.hapticFeedback),
                ),
                SwitchListTile.adaptive(
                  key: const Key('menu-reduce-motion'),
                  value: settings.reduceMotion,
                  onChanged: notifier.setReduceMotion,
                  secondary: const Icon(Icons.animation_outlined),
                  title: Text(l10n.reduceMotion),
                ),
                const Divider(height: 1),
                ListTile(
                  key: const Key('menu-restart'),
                  leading: const Icon(Icons.refresh),
                  title: Text(l10n.restartRace),
                  onTap: () async {
                    // Throwing a race away is asked for out loud, once.
                    final ok = await showDialog<bool>(
                      context: sheetContext,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(l10n.restartRace),
                        content: Text(l10n.restartRaceConfirm),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: Text(
                              MaterialLocalizations.of(
                                dialogContext,
                              ).cancelButtonLabel,
                            ),
                          ),
                          FilledButton(
                            key: const Key('menu-restart-confirm'),
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: Text(l10n.restartRace),
                          ),
                        ],
                      ),
                    );
                    if (ok != true) return;
                    ref.read(gameControllerProvider.notifier).restartSameSetup();
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                ),
                ListTile(
                  key: const Key('menu-home'),
                  leading: const Icon(Icons.home_outlined),
                  title: Text(l10n.backToHome),
                  subtitle: Text(l10n.backToHomeHint),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.go('/home');
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    ),
  );
}

/// The one type style of the HUD: every pill, counter and word is set in
/// it, so the bar reads as one instrument rather than a row of widgets.
TextStyle? _hudText(BuildContext context) => Theme.of(context)
    .textTheme
    .labelLarge
    ?.copyWith(color: const Color(0xFFF4ECDC), fontWeight: FontWeight.w600);

/// A heading and the row of pills it explains. One word over four
/// counters beats the same word repeated inside each of them.
class _HudGroup extends StatelessWidget {
  const _HudGroup({required this.heading, required this.children});

  final String heading;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          heading.toUpperCase(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFFEBC06A),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 5),
        // A Wrap, not a Row: four riders fold onto a second line on a
        // narrow phone at a large text size rather than overflow it.
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: children,
        ),
      ],
    );
  }
}

/// One counter of the HUD: its glyph, its number, and **the word for what
/// it counts**. The word is what a bare "4/5" beside a flame was missing.
class _HudStat extends StatelessWidget {
  const _HudStat({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.word,
    required this.semantics,
    this.highlight = false,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String word;

  /// The full sentence a screen reader hears — the short word on screen
  /// is a reminder, not a definition.
  final String semantics;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return _HudPill(
      highlight: highlight,
      child: Semantics(
        label: semantics,
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 5),
              Text(value, style: _hudText(context)),
              const SizedBox(width: 4),
              Text(
                word,
                style: _hudText(
                  context,
                )?.copyWith(color: Colors.white70, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.label,
  });

  final IconData icon;
  final VoidCallback onTap;

  /// What this button does, for a screen reader — never guessed from the
  /// glyph: two of these sit side by side on the board.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
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

/// "X takes the lead": a gold line under the HUD, one beat.
class _LeadToast extends StatelessWidget {
  const _LeadToast({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: const Key('lead-toast'),
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.of(context, AppMotion.micro),
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, (1 - t) * -6), child: child),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xE6122E22),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xFFEBC06A), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 15, color: Color(0xFFFFE08A)),
            const SizedBox(width: 6),
            // "X passe en tete !" is a sentence with a name in it: it
            // shortens rather than pushing the pill past the screen.
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFFFFE9AE),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The placement's bottom banner: the squares won as a gold coin, and
/// what to do with them — touch a horse, then drag it to its square.
class _PlacementBanner extends StatelessWidget {
  const _PlacementBanner({
    required this.value,
    required this.title,
    required this.hint,
    this.extra,
  });

  final int value;
  final String title;
  final String hint;

  /// One more line: the 6's second draw.
  final String? extra;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('placement-banner'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xF210281E),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFEBC06A).withValues(alpha: 0.65),
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
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF3D68A), Color(0xFFDBA83E)],
              ),
              boxShadow: [
                BoxShadow(color: Color(0x80DBA83E), blurRadius: 14),
              ],
            ),
            child: Text(
              '$value',
              style: const TextStyle(
                color: Color(0xFF3A2A08),
                fontWeight: FontWeight.w900,
                fontSize: 24,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFF3D68A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: AppMotion.of(context, AppMotion.micro),
                  child: Text(
                    hint,
                    key: ValueKey(hint),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFF4ECDC),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (extra != null)
                  Text(
                    extra!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xCCE9DFC8),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.pan_tool_alt_outlined, color: Color(0xFFEBC06A), size: 24),
        ],
      ),
    );
  }
}

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
    final riding = state.pendingBonus?.value ?? state.lastBonusValue;
    final fromCapture = state.pendingBonus?.fromCapture ?? false;
    final String text;
    if (player.isHuman) {
      if (state.turnPhase == TurnPhase.movingHorse && riding != null) {
        text = fromCapture
            ? l10n.captureBonusRide(riding)
            : l10n.bonusRide(riding);
      } else {
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
      }
    } else {
      // The opponent's turn is narrated, never silent: what it is doing,
      // then what happened. An unexplained pause reads as a freeze.
      final drawn = state.drawnCard;
      text = switch (state.turnPhase) {
        TurnPhase.answeringQuestion => l10n.opponentThinking(player.name),
        TurnPhase.choosingHorse => l10n.opponentPlaces(player.name),
        TurnPhase.movingHorse when riding != null => l10n.opponentBonus(
          player.name,
          riding,
        ),
        TurnPhase.showingFeedback
            when state.lastAnswerCorrect == true && drawn != null =>
          l10n.opponentDrew(player.name, drawn.steps),
        _ => switch (outcome) {
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
            state.isBonusTurn
                ? l10n.opponentReplays(player.name)
                : l10n.opponentThinking(player.name),
        },
      };
    }
    return Container(
      key: const Key('turn-banner'),
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
    this.note,
    this.stake,
  });

  final Question question;
  final bool isJourney;
  final bool isCellBonus;

  /// What a right answer is worth — "Carte à 5 galops" — kept over the
  /// question so the stake is never out of sight while it is played for.
  final String? stake;
  final int? selectedAnswer;
  final bool? lastAnswerCorrect;

  /// Second beat of the answer: a short sheet at the bottom.
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

  /// One line under the verdict: after a wrong answer, what the card
  /// was worth.
  final String? note;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    if (compact) {
      return Positioned.fill(
        child: Stack(
          children: [
            // Only the bottom is scrimmed: the board stays sharp above
            // the sheet.
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
                      note: note,
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
                    if (stake != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _StakePill(text: stake!),
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

/// The stake, worn over the question as a gold pill: the number the
/// whole card is played for, in the same gold as the prize it becomes.
class _StakePill extends StatelessWidget {
  const _StakePill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const Key('stake-pill'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xF20C2B22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEBC06A), width: 1.3),
          boxShadow: const [
            BoxShadow(color: Color(0x80000000), blurRadius: 14, offset: Offset(0, 4)),
          ],
        ),
        // The text is flexible and ellipsizes: on the floor phone at a
        // large text size a rigid row here is the one thing that can push
        // the question panel off its edge.
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.style, size: 16, color: Color(0xFFEBC06A)),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFFF3D68A),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
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
