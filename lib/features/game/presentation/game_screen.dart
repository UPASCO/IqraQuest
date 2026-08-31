import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../services/movement_choice_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/board/board_widget.dart';
import '../../../widgets/gait_selector.dart';
import '../../../widgets/question_card.dart';
import '../application/game_controller.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int? _selectedAnswer;
  int _selectedHorse = 0;
  MovementChoice? _hoveredGait;
  bool _useGrandGallop = false;
  String? _dismissedQuestionId;

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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 10, backgroundColor: player.team.color(colors)),
            const SizedBox(width: 8),
            Flexible(child: Text(player.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _PlayerStrip(state: state),
                _StreakGauge(player: player, l10n: l10n),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: BoardWidget(
                        state: state,
                        selectableHorses: state.turnPhase == TurnPhase.selectingGait
                            ? {
                                for (final i
                                    in ref.read(gameControllerProvider.notifier).movableHorses)
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
                if (state.turnPhase == TurnPhase.selectingGait && player.isHuman)
                  _GaitPanel(
                    player: player,
                    selectedHorse: _selectedHorse,
                    hovered: _hoveredGait,
                    useGrandGallop: _useGrandGallop,
                    l10n: l10n,
                    onToggleGrandGallop: (v) => setState(() => _useGrandGallop = v),
                    onSelect: _onGaitSelected,
                  )
                else
                  _TurnBanner(session: session, l10n: l10n),
              ],
            ),
            if (showQuestion)
              _QuestionOverlay(
                question: question,
                isJourney: state.turnPhase == TurnPhase.answeringJourneyQuestion,
                isCellBonus: state.turnPhase == TurnPhase.resolvingCell,
                selectedAnswer: _selectedAnswer,
                lastAnswerCorrect: state.lastAnswerCorrect,
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
      ),
    );
  }

  void _onGaitSelected(MovementChoice choice) async {
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

    setState(() => _hoveredGait = choice);
    controller.selectGait(_selectedHorse, choice, useGrandGallop: _useGrandGallop);
    setState(() => _useGrandGallop = false);
  }
}

/// The six horseshoes plus the horse picker and the Grand Gallop toggle.
class _GaitPanel extends StatelessWidget {
  const _GaitPanel({
    required this.player,
    required this.selectedHorse,
    required this.hovered,
    required this.useGrandGallop,
    required this.l10n,
    required this.onToggleGrandGallop,
    required this.onSelect,
  });

  final Player player;
  final int selectedHorse;
  final MovementChoice? hovered;
  final bool useGrandGallop;
  final AppLocalizations l10n;
  final ValueChanged<bool> onToggleGrandGallop;
  final ValueChanged<MovementChoice> onSelect;

  static const _movementChoices = MovementChoiceService();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.chooseYourGait, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              if (player.horses.length > 1)
                Text(
                  '${l10n.selectHorse} ${selectedHorse + 1}',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: colors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 10),
          GaitSelector(
            cycle: player.gaitCycle,
            selected: hovered,
            difficultyFor: (choice) => _movementChoices.difficultyFor(choice, player.profile),
            onSelected: onSelect,
          ),
          if (player.rewards.hasGrandGallop) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: useGrandGallop,
              onChanged: onToggleGrandGallop,
              title: Text(l10n.useGrandGallop, style: Theme.of(context).textTheme.labelMedium),
            ),
          ],
        ],
      ),
    );
  }
}

/// The "Élan du savoir" gauge — the streak that earns shields, the Grand
/// Gallop and mastery badges.
class _StreakGauge extends StatelessWidget {
  const _StreakGauge({required this.player, required this.l10n});

  final Player player;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final streak = player.streak;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
      child: Row(
        children: [
          Text(
            l10n.knowledgeStreak,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: streak.progressToNextThreshold.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: colors.divider,
                valueColor: AlwaysStoppedAnimation(colors.goldAccent),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${streak.current}/${streak.nextThreshold}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          if (player.rewards.hasGrandGallop) ...[
            const SizedBox(width: 8),
            Icon(Icons.bolt, size: 16, color: colors.goldAccent),
          ],
        ],
      ),
    );
  }
}

class _TurnBanner extends StatelessWidget {
  const _TurnBanner({required this.session, required this.l10n});

  final GameSession session;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      color: colors.surfaceElevated,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _PlayerStrip extends StatelessWidget {
  const _PlayerStrip({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          for (var i = 0; i < state.players.length; i++)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: i == state.currentPlayerIndex
                      ? state.players[i].team.color(colors).withValues(alpha: 0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state.players[i].team.color(colors),
                    width: i == state.currentPlayerIndex ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      state.players[i].name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      '${state.players[i].rewards.knowledgePoints}',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: colors.goldAccent, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
  });

  final Question question;
  final bool isJourney;
  final bool isCellBonus;
  final int? selectedAnswer;
  final bool? lastAnswerCorrect;
  final AppLocalizations l10n;
  final ValueChanged<int> onSelect;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isJourney)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    l10n.journeyQuestion,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ),
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
