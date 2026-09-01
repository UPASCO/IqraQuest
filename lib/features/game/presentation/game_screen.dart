import 'dart:ui' as ui;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart' show soundServiceProvider;
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../services/sound_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/board/board_environment.dart';
import '../../../widgets/board/baked_board_scene.dart';
import '../../../widgets/board/board_widget.dart' show BoardPreview, BoardWidget;
import '../../../widgets/illustration.dart';
import '../../../widgets/question_card.dart';
import '../../../widgets/question_card_draw.dart';
import '../application/game_controller.dart';
import '../../../widgets/button_label.dart';

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
  int _selectedHorse = 0;
  MovementChoice? _hoveredGait;
  String? _dismissedQuestionId;

  /// While the drawn card is turning over, the question sheet is held
  /// back: the player reads what the card is worth first, then answers.
  bool _revealing = false;
  int _revealValue = 1;
  int _revealPips = 1;
  Timer? _revealTimer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final session = ref.watch(gameControllerProvider);

    ref.listen(gameControllerProvider, (previous, next) {
      _playCuesFor(previous, next);
      if (next?.gameState.turnPhase == TurnPhase.gameOver &&
          previous?.gameState.turnPhase != TurnPhase.gameOver) {
        context.go('/results');
      }
      if (previous?.currentQuestion?.id != next?.currentQuestion?.id) {
        setState(() => _selectedAnswer = null);
      }
      // A new turn resets the local selection helpers.
      if (previous?.gameState.currentPlayerIndex != next?.gameState.currentPlayerIndex) {
        setState(() {
          _selectedHorse = 0;
          _hoveredGait = null;
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
    final showQuestion =
        question != null &&
        !_revealing &&
        question.id != _dismissedQuestionId &&
        player.isHuman &&
        (state.turnPhase == TurnPhase.answeringQuestion ||
            state.turnPhase == TurnPhase.answeringJourneyQuestion ||
            state.turnPhase == TurnPhase.showingFeedback ||
            state.turnPhase == TurnPhase.resolvingCell);

    // Where the drawn card sends this horse, drawn on the board itself
    // so the ride is never a surprise: "this card takes me here."
    BoardPreview? boardPreview;
    final pending = state.pendingGait;
    final drawnPreview = session.preview;
    if (pending != null && drawnPreview != null) {
      boardPreview = BoardPreview(
        teamIndex: state.currentPlayerIndex,
        from: player.horses[pending.horseIndex].position,
        destination: drawnPreview.destination,
      );
    }

    final screen = MediaQuery.sizeOf(context);
    // Negative tilt: the TOP of the board recedes toward the horizon.
    const tilt = -0.50;
    final boardSide = screen.width * 1.0;
    final region = switch (state.circuitId) {
      CircuitId.oasisRoute => WorldRegion.dawn,
      CircuitId.caravanTrail => WorldRegion.solar,
      CircuitId.greatRide => WorldRegion.fertile,
    };

    final selectable = state.turnPhase == TurnPhase.selectingGait
        ? {
            for (final i in ref.read(gameControllerProvider.notifier).movableHorses)
              '${player.id}:$i',
          }
        : const <String>{};
    // The oasis route plays inside the baked 2.5D diorama; the other
    // circuits still use the painted board until their scenes are baked.
    // The baked plate is painted with a fixed number of tiles; the
    // parcours is now the 56-square petits chevaux circuit, which no
    // current plate matches, so this falls through to the procedural
    // board. It turns itself back on the day a 56-tile plate ships.
    final useDiorama = BakedBoardScene.supportsCircuit(Circuit.byId(state.circuitId));

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
          if (useDiorama)
            Positioned.fill(
              child: BakedBoardScene(
                state: state,
                preview: boardPreview,
                selectableHorses: selectable,
                selectedHorseKey: '${player.id}:$_selectedHorse',
                onHorseTap: (playerIndex, horseIndex) {
                  if (playerIndex != state.currentPlayerIndex) return;
                  setState(() => _selectedHorse = horseIndex);
                },
              ),
            )
          else ...[
            Positioned.fill(
              child: CustomPaint(painter: BoardEnvironmentPainter(horizon: 0.20, region: region)),
            ),

            // The journey, tilted into the landscape.
            Align(
              alignment: const Alignment(0, -0.32),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0014)
                  ..rotateX(tilt),
                child: SizedBox(
                  width: boardSide,
                  height: boardSide,
                  child: BoardWidget(
                    state: state,
                    preview: boardPreview,
                    billboardAngle: tilt,
                    selectableHorses: selectable,
                    onHorseTap: (playerIndex, horseIndex) {
                      if (playerIndex != state.currentPlayerIndex) return;
                      setState(() => _selectedHorse = horseIndex);
                    },
                  ),
                ),
              ),
            ),
          ],

          // ---- Floating HUD ----
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _GlassIconButton(icon: Icons.arrow_back, onTap: () => context.go('/home')),
                      const SizedBox(width: 10),
                      _HudPill(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 6, backgroundColor: player.team.color(colors)),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: screen.width * 0.32),
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
                            const Icon(Icons.auto_awesome, size: 15, color: Color(0xFFEBC06A)),
                            const SizedBox(width: 5),
                            Text('${player.rewards.knowledgePoints}', style: _hudText(context)),
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
                  // glance (the painted stables are scenery).
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < state.players.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        _HudPill(
                          highlight: i == state.currentPlayerIndex,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 5,
                                backgroundColor: state.players[i].team.color(colors),
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
                    horseHint: player.horses.length > 1
                        ? '${l10n.selectHorse} ${_selectedHorse + 1}'
                        : null,
                  ),
                ),
              ),
            )
          else
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: _TurnBanner(session: session, l10n: l10n),
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
                  child: DrawnCardReveal(value: _revealValue, difficultyPips: _revealPips),
                ),
              ),
            ),

          if (showQuestion)
            _QuestionOverlay(
              question: question,
              isJourney: state.turnPhase == TurnPhase.answeringJourneyQuestion,
              isCellBonus: state.turnPhase == TurnPhase.resolvingCell,
              selectedAnswer: _selectedAnswer,
              lastAnswerCorrect: state.lastAnswerCorrect,
              pointsEarned:
                  state.lastAnswerCorrect == true && state.turnPhase == TurnPhase.showingFeedback
                  ? _hoveredGait?.knowledgePoints
                  : null,
              justUnlocked: state.justUnlocked.isEmpty ? null : state.justUnlocked.first,
              streakCurrent: player.streak.current,
              l10n: l10n,
              onSelect: (i) {
                ref.read(soundServiceProvider).play(Sfx.tap);
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
                ref.read(gameControllerProvider.notifier).continueAfterFeedback();
              },
            ),
          if (state.turnPhase == TurnPhase.resolvingCell &&
              session.currentQuestion == null &&
              player.isHuman)
            _CellOfferSheet(
              effect: state.pendingCellEffect!,
              l10n: l10n,
              onAccept: () => ref.read(gameControllerProvider.notifier).acceptCellChallenge(),
              onDecline: () => ref.read(gameControllerProvider.notifier).declineCellOffer(),
            ),
        ],
      ),
      ),
    );
  }

  TextStyle? _hudText(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge
          ?.copyWith(color: const Color(0xFFF4ECDC), fontWeight: FontWeight.w600);

  /// Draws the turn's card, then holds the question back long enough
  /// for the card to turn over and be read.
  void _onDrawCard() {
    if (_revealing) return;
    final controller = ref.read(gameControllerProvider.notifier);
    ref.read(soundServiceProvider).play(Sfx.gaitSelect);
    controller.drawCard(_selectedHorse);

    final drawn = ref.read(gameControllerProvider)?.gameState.pendingGait;
    final card = ref.read(gameControllerProvider)?.currentQuestion;
    if (drawn == null) return; // the turn resolved without a card

    setState(() {
      _revealing = true;
      _revealValue = drawn.choice.steps;
      _revealPips = switch (card?.difficulty) {
        QuestionDifficulty.easy => 1,
        QuestionDifficulty.medium => 2,
        QuestionDifficulty.hard => 3,
        null => 1,
      };
    });
    _revealTimer?.cancel();
    _revealTimer = Timer(kCardRevealDuration, () {
      if (mounted) setState(() => _revealing = false);
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
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
      // The fanfare belongs to a human win; an AI win ends quietly.
      final winner =
          nextState.players.where((p) => p.id == nextState.winnerId).firstOrNull;
      if (winner == null || winner.isHuman) sound.play(Sfx.victory);
      return;
    }
    if (nextState.turnPhase == TurnPhase.showingFeedback &&
        prevState.turnPhase != TurnPhase.showingFeedback) {
      sound.play(nextState.lastAnswerCorrect == true ? Sfx.correct : Sfx.wrong);
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
      sound.play(Sfx.moveHoofs);
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
          color: highlight ? const Color(0xFFEBC06A) : Colors.white.withValues(alpha: 0.14),
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
        shape: CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.14))),
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
    final outcome = session.gameState.lastMoveOutcome;
    final text = switch (outcome) {
      MoveOutcome.moved || MoveOutcome.bonusEarned => l10n.outcomeMoved,
      MoveOutcome.stayed || MoveOutcome.bonusMissed => l10n.outcomeStayed,
      MoveOutcome.captured => l10n.outcomeCaptured,
      MoveOutcome.blockedByShield => l10n.outcomeShieldBlocked,
      MoveOutcome.reachedFinish => l10n.journeyQuestionIntro,
      null => session.isAiTurnInProgress ? '…' : l10n.yourTurn,
    };
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
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: const Color(0xFFF4ECDC), fontWeight: FontWeight.w600),
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
  });

  final Question question;
  final bool isJourney;
  final bool isCellBonus;
  final int? selectedAnswer;
  final bool? lastAnswerCorrect;
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
                  padding: const EdgeInsets.only(top: 2),
                  child: justUnlocked != null
                      // The unlock IS the payout: one hero beat, no
                      // competing chip.
                      ? _StreakBurst(unlocked: justUnlocked!, streak: streakCurrent)
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
                    // The gold arch line crowning the panel ties it to the
                    // game's architecture.
                    const _ArchCrest(),
                    QuestionCard(
                      question: question,
                      selectedIndex: selectedAnswer,
                      isCorrect: lastAnswerCorrect,
                      onSelect: onSelect,
                      onContinue: lastAnswerCorrect != null ? onContinue : null,
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

class _ArchCrest extends StatelessWidget {
  const _ArchCrest();

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 20, width: 132, child: CustomPaint(painter: _ArchCrestPainter()));
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
            const CustomPaint(size: Size(170, 130), painter: _SunburstPainter()),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 44, color: const Color(0xFFFFEBB8)),
                Text(
                  '×$streak',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFFFFEBB8),
                    fontWeight: FontWeight.w900,
                    shadows: const [Shadow(color: Color(0x99000000), blurRadius: 10)],
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
        ..shader = ui.Gradient.radial(c, r, [const Color(0xB3F3D68A), const Color(0x00F3D68A)]),
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
              const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF5A4210)),
              const SizedBox(width: 6),
              Text(
                '+$points',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: const Color(0xFF5A4210), fontWeight: FontWeight.w800),
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
          border: Border.all(color: const Color(0xFFEBC06A).withValues(alpha: 0.55), width: 1.2),
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
                builder: (context, t, child) =>
                    Transform.scale(scale: 0.7 + 0.3 * t.clamp(0.0, 1.0), child: child),
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
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: const Color(0xFFF3D68A), fontWeight: FontWeight.w800),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
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

