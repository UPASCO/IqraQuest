import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../services/movement_choice_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/board/board_environment.dart';
import '../../../widgets/board/board_widget.dart';
import '../../../widgets/gait_selector.dart' show HorseshoePainter;
import '../../../widgets/question_card.dart';
import '../application/game_controller.dart';

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
  MovementChoice? _armedGait;
  MovementChoice? _hoveredGait;
  bool _useGrandGallop = false;
  String? _dismissedQuestionId;

  static const _movementChoices = MovementChoiceService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final session = ref.watch(gameControllerProvider);

    ref.listen(gameControllerProvider, (previous, next) {
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
          _armedGait = null;
          _hoveredGait = null;
          _useGrandGallop = false;
        });
      }
    });

    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final state = session.gameState;
    final player = state.currentPlayer;
    final question = session.currentQuestion;
    final showQuestion =
        question != null &&
        question.id != _dismissedQuestionId &&
        player.isHuman &&
        (state.turnPhase == TurnPhase.answeringQuestion ||
            state.turnPhase == TurnPhase.answeringJourneyQuestion ||
            state.turnPhase == TurnPhase.showingFeedback ||
            state.turnPhase == TurnPhase.resolvingCell);

    // The armed gait's destination, shown on the board itself before the
    // player commits: "if I choose 4, I arrive here."
    BoardPreview? boardPreview;
    final armed = _armedGait;
    if (armed != null && state.turnPhase == TurnPhase.selectingGait) {
      final preview = ref
          .read(gameControllerProvider.notifier)
          .preview(_selectedHorse, armed, useGrandGallop: _useGrandGallop);
      if (preview != null) {
        boardPreview = BoardPreview(
          teamIndex: state.currentPlayerIndex,
          from: player.horses[_selectedHorse].position,
          destination: preview.destination,
        );
      }
    }

    final screen = MediaQuery.sizeOf(context);
    // Negative tilt: the TOP of the board recedes toward the horizon.
    const tilt = -0.50;
    final boardSide = screen.width * 1.10;

    return Scaffold(
      backgroundColor: const Color(0xFF0A3327),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: BoardEnvironmentPainter(horizon: 0.20)),
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
                  selectableHorses: state.turnPhase == TurnPhase.selectingGait
                      ? {
                          for (final i in ref.read(gameControllerProvider.notifier).movableHorses)
                            '${player.id}:$i',
                        }
                      : const {},
                  onHorseTap: (playerIndex, horseIndex) {
                    if (playerIndex != state.currentPlayerIndex) return;
                    setState(() => _selectedHorse = horseIndex);
                  },
                ),
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
                ],
              ),
            ),
          ),

          // ---- Bottom: the play bar or the turn pill ----
          if (state.turnPhase == TurnPhase.selectingGait && player.isHuman)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: _GaitBar(
                  player: player,
                  armed: _armedGait,
                  selectedHorse: _selectedHorse,
                  useGrandGallop: _useGrandGallop,
                  l10n: l10n,
                  difficultyFor: (c) => _movementChoices.difficultyFor(c, player.profile),
                  onToggleGrandGallop: (v) => setState(() => _useGrandGallop = v),
                  onTapGait: _onGaitTapped,
                  onConfirm: _armedGait == null ? null : () => _onGaitConfirmed(_armedGait!),
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
              l10n: l10n,
              onSelect: (i) {
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
    );
  }

  TextStyle? _hudText(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge
          ?.copyWith(color: const Color(0xFFF4ECDC), fontWeight: FontWeight.w600);

  /// First tap arms a gait and shows its destination on the board;
  /// tapping the armed gait again (or the confirm arrow) commits it.
  void _onGaitTapped(MovementChoice choice) {
    if (_armedGait == choice) {
      _onGaitConfirmed(choice);
    } else {
      setState(() => _armedGait = choice);
    }
  }

  void _onGaitConfirmed(MovementChoice choice) async {
    final controller = ref.read(gameControllerProvider.notifier);
    final session = ref.read(gameControllerProvider);
    if (session == null) return;
    final player = session.gameState.currentPlayer;

    // Child mode confirms before a bold gait, so a young player never
    // stumbles into a hard question by mistake (spec §13).
    if (player.profile.confirmsRiskyGaits && choice.needsConfirmationForChildren) {
      final l10n = AppLocalizations.of(context);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.chooseYourGait),
          content: Text(l10n.confirmBoldGait),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() {
      _hoveredGait = choice;
      _armedGait = null;
    });
    controller.selectGait(_selectedHorse, choice, useGrandGallop: _useGrandGallop);
    setState(() => _useGrandGallop = false);
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
    return Material(
      color: const Color(0xB3122E22),
      shape: CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.14))),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox(
          width: 38,
          height: 38,
          child: Icon(Icons.arrow_back, size: 19, color: Color(0xFFF4ECDC)),
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

class _GaitBar extends StatelessWidget {
  const _GaitBar({
    required this.player,
    required this.armed,
    required this.selectedHorse,
    required this.useGrandGallop,
    required this.l10n,
    required this.difficultyFor,
    required this.onToggleGrandGallop,
    required this.onTapGait,
    required this.onConfirm,
  });

  final Player player;
  final MovementChoice? armed;
  final int selectedHorse;
  final bool useGrandGallop;
  final AppLocalizations l10n;
  final QuestionDifficulty Function(MovementChoice) difficultyFor;
  final ValueChanged<bool> onToggleGrandGallop;
  final ValueChanged<MovementChoice> onTapGait;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xE610281E),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                l10n.chooseYourGait,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: const Color(0xFFE9DFC8), fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (player.horses.length > 1)
                Text(
                  '${l10n.selectHorse} ${selectedHorse + 1}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white54),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final choice in MovementChoice.all) ...[
                Expanded(
                  child: _GaitChip(
                    choice: choice,
                    available: player.gaitCycle.isAvailable(choice),
                    armed: armed == choice,
                    difficulty: difficultyFor(choice),
                    label: l10n.gaitSquares(choice.steps),
                    semanticLabel: l10n.gaitSemanticLabel(
                      choice.steps,
                      _difficultyLabel(difficultyFor(choice)),
                      choice.knowledgePoints,
                    ),
                    unavailableHint: l10n.gaitAlreadyUsed,
                    onTap: () => onTapGait(choice),
                  ),
                ),
                if (choice.steps < MovementChoice.maxSteps) const SizedBox(width: 6),
              ],
              // The gold "ride" arrow appears once a gait is armed.
              AnimatedSize(
                duration: AppMotion.of(context, AppMotion.micro),
                curve: AppMotion.easeOut,
                child: onConfirm == null
                    ? const SizedBox(height: 54)
                    : Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Material(
                          key: const Key('gait-confirm'),
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: Ink(
                            width: 46,
                            height: 46,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFF3D68A), Color(0xFFD8A032)],
                              ),
                            ),
                            child: InkWell(
                              onTap: onConfirm,
                              child: const Icon(Icons.arrow_forward, color: Color(0xFF4A3410)),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          if (player.rewards.hasGrandGallop)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: useGrandGallop,
              onChanged: onToggleGrandGallop,
              activeThumbColor: const Color(0xFFEBC06A),
              title: Text(
                l10n.useGrandGallop,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: const Color(0xFFE9DFC8)),
              ),
            ),
        ],
      ),
    );
  }

  String _difficultyLabel(QuestionDifficulty d) => switch (d) {
    QuestionDifficulty.easy => l10n.difficultyEasy,
    QuestionDifficulty.medium => l10n.difficultyMedium,
    QuestionDifficulty.hard => l10n.difficultyHard,
  };
}

class _GaitChip extends StatelessWidget {
  const _GaitChip({
    required this.choice,
    required this.available,
    required this.armed,
    required this.difficulty,
    required this.label,
    required this.semanticLabel,
    required this.unavailableHint,
    required this.onTap,
  });

  final MovementChoice choice;
  final bool available;
  final bool armed;
  final QuestionDifficulty difficulty;
  final String label;
  final String semanticLabel;
  final String unavailableHint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pips = switch (difficulty) {
      QuestionDifficulty.easy => 1,
      QuestionDifficulty.medium => 2,
      QuestionDifficulty.hard => 3,
    };

    return Semantics(
      button: true,
      enabled: available,
      selected: armed,
      label: semanticLabel,
      hint: available ? null : unavailableHint,
      child: GestureDetector(
        onTap: available ? onTap : null,
        child: AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.micro),
          curve: AppMotion.easeOut,
          height: 54,
          transform: Matrix4.translationValues(0, armed ? -5 : 0, 0),
          decoration: BoxDecoration(
            color: armed
                ? const Color(0xFF1E4A38)
                : Colors.white.withValues(alpha: available ? 0.07 : 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: armed ? const Color(0xFFEBC06A) : Colors.white.withValues(alpha: 0.10),
              width: armed ? 1.6 : 1,
            ),
          ),
          child: Opacity(
            opacity: available ? 1 : 0.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  height: 26,
                  child: CustomPaint(
                    painter: HorseshoePainter(
                      steps: choice.steps,
                      used: !available,
                      selected: false,
                      shoe: const Color(0xFFD9AF56),
                      face: Colors.transparent,
                      ink: const Color(0xFFF4ECDC),
                      accent: colors.primary,
                      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // The caption stays a localized "n squares" string for
                // screen readers and small-print clarity.
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(fontSize: 8.5, color: Colors.white60),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Container(
                        width: 3.6,
                        height: 3.6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < pips ? const Color(0xFFE08A4E) : Colors.white24,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
          // eye already is.
          if (pointsEarned != null)
            Align(
              alignment: const Alignment(0, -0.90),
              child: _RewardChip(points: pointsEarned!),
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
    final colors = context.colors;
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l10n.cellChallengeOffer, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: onDecline, child: Text(l10n.declineChallenge)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(onPressed: onAccept, child: Text(l10n.acceptChallenge)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
