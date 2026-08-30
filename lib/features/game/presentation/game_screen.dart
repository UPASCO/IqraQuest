import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/board/board_widget.dart';
import '../../../widgets/dice_widget.dart';
import '../../../widgets/question_card.dart';
import '../application/game_controller.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int? _selectedAnswer;
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
    });

    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final state = session.gameState;
    final currentPlayer = state.currentPlayer;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(radius: 10, backgroundColor: currentPlayer.team.color(colors)),
            const SizedBox(width: 8),
            Text(currentPlayer.name),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _PlayerStrip(state: state),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(
                      child: BoardWidget(
                        state: state,
                        selectablePawns: {
                          for (final m in session.legalMoves) '${m.playerId}:${m.pawnIndex}',
                        },
                        onPawnTap: (playerIndex, pawnIndex) {
                          final move = session.legalMoves.firstWhere(
                            (m) =>
                                m.playerId == state.players[playerIndex].id &&
                                m.pawnIndex == pawnIndex,
                          );
                          ref.read(gameControllerProvider.notifier).selectPawn(move);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DiceArea(session: session, l10n: l10n),
                ],
              ),
            ),
            if (session.currentQuestion != null &&
                session.currentQuestion!.id != _dismissedQuestionId &&
                currentPlayer.isHuman)
              _QuestionOverlay(
                question: session.currentQuestion!,
                selectedAnswer: _selectedAnswer,
                lastAnswerCorrect: session.lastAnswerCorrect,
                onSelect: (i) {
                  setState(() => _selectedAnswer = i);
                  ref.read(gameControllerProvider.notifier).answerQuestion(i);
                },
                onContinue: () {
                  final wasCorrect = session.lastAnswerCorrect;
                  setState(() => _dismissedQuestionId = session.currentQuestion!.id);
                  final controller = ref.read(gameControllerProvider.notifier);
                  if (wasCorrect == true) {
                    controller.rollDice();
                  } else {
                    controller.continueAfterFeedback();
                  }
                },
              ),
            if (state.freeBankExhausted &&
                state.turnPhase == TurnPhase.waitingForDice &&
                session.currentQuestion == null)
              Align(
                alignment: Alignment.topCenter,
                child: _Banner(text: l10n.freeBankExhaustedMessage),
              ),
          ],
        ),
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
    return Row(
      children: [
        for (var i = 0; i < state.players.length; i++)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                  Icon(Icons.circle, size: 10, color: state.players[i].team.color(colors)),
                  const SizedBox(height: 2),
                  Text(
                    state.players[i].name,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DiceArea extends ConsumerWidget {
  const _DiceArea({required this.session, required this.l10n});

  final GameSession session;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = session.gameState;
    final canRoll = state.turnPhase == TurnPhase.waitingForDice && state.currentPlayer.isHuman;
    return Column(
      children: [
        DiceWidget(
          value: state.lastDiceValue ?? 1,
          enabled: canRoll,
          onTap: () => ref.read(gameControllerProvider.notifier).rollDice(),
        ),
        const SizedBox(height: 6),
        Text(
          canRoll ? l10n.rollDice : l10n.diceLocked,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}

class _QuestionOverlay extends StatelessWidget {
  const _QuestionOverlay({
    required this.question,
    required this.selectedAnswer,
    required this.lastAnswerCorrect,
    required this.onSelect,
    required this.onContinue,
  });

  final Question question;
  final int? selectedAnswer;
  final bool? lastAnswerCorrect;
  final ValueChanged<int> onSelect;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: QuestionCard(
            question: question,
            selectedIndex: selectedAnswer,
            isCorrect: lastAnswerCorrect,
            onSelect: onSelect,
            onContinue: lastAnswerCorrect != null ? onContinue : null,
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.goldAccent.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}
