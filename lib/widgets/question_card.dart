import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'geometric_motif_painter.dart';

/// The single most important component in IqraQuest (spec §27): the
/// question → answer → feedback → explanation → source flow that gates
/// every dice roll.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.selectedIndex,
    required this.isCorrect,
    required this.onSelect,
    required this.onContinue,
  });

  final Question question;
  final int? selectedIndex;
  final bool? isCorrect;
  final ValueChanged<int>? onSelect;
  final VoidCallback? onContinue;

  static const _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final answered = isCorrect != null;

    return Material(
      color: colors.surfaceElevated,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: GeometricMotifBackground(
        opacity: 0.05,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _CategoryChip(category: question.category, label: l10n.category),
                  const SizedBox(width: 8),
                  _DifficultyDots(difficulty: question.difficulty),
                ],
              ),
              const SizedBox(height: 16),
              Text(question.question, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              for (var i = 0; i < question.answers.length; i++) ...[
                _AnswerTile(
                  letter: _letters[i],
                  text: question.answers[i],
                  state: _tileState(i),
                  onTap: answered || onSelect == null ? null : () => onSelect!(i),
                ),
                const SizedBox(height: 10),
              ],
              if (answered) ...[
                const SizedBox(height: 8),
                _FeedbackBand(
                  correct: isCorrect!,
                  correctLabel: l10n.correctAnswer,
                  incorrectLabel: l10n.incorrectAnswer,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.explanationLabel,
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(question.explanation, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                Text(
                  l10n.sourceLabel,
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  question.sourceDisplay,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.textSecondary, fontStyle: FontStyle.italic),
                ),
                if (onContinue != null) ...[
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      child: Text(MaterialLocalizations.of(context).continueButtonLabel),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  _AnswerTileState _tileState(int index) {
    if (isCorrect == null) {
      return selectedIndex == index ? _AnswerTileState.selected : _AnswerTileState.neutral;
    }
    if (index == question.correctAnswerIndex) return _AnswerTileState.correct;
    if (index == selectedIndex) return _AnswerTileState.incorrect;
    return _AnswerTileState.dimmed;
  }
}

enum _AnswerTileState { neutral, selected, correct, incorrect, dimmed }

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String text;
  final _AnswerTileState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (bg, border, fg) = switch (state) {
      _AnswerTileState.neutral => (colors.surface, colors.divider, colors.textPrimary),
      _AnswerTileState.selected => (
        colors.primary.withValues(alpha: 0.12),
        colors.primary,
        colors.textPrimary,
      ),
      _AnswerTileState.correct => (
        colors.success.withValues(alpha: 0.16),
        colors.success,
        colors.textPrimary,
      ),
      _AnswerTileState.incorrect => (
        colors.error.withValues(alpha: 0.14),
        colors.error,
        colors.textPrimary,
      ),
      _AnswerTileState.dimmed => (colors.surface, colors.divider, colors.textSecondary),
    };

    return Semantics(
      button: true,
      selected: state == _AnswerTileState.selected,
      label: '$letter. $text',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1.4),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: border,
                child: Text(
                  letter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: fg),
                ),
              ),
              if (state == _AnswerTileState.correct)
                Icon(Icons.check_circle, color: colors.success)
              else if (state == _AnswerTileState.incorrect)
                Icon(Icons.cancel, color: colors.error),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackBand extends StatelessWidget {
  const _FeedbackBand({
    required this.correct,
    required this.correctLabel,
    required this.incorrectLabel,
  });

  final bool correct;
  final String correctLabel;
  final String incorrectLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = correct ? colors.success : colors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(correct ? Icons.check_circle : Icons.info, color: color),
          const SizedBox(width: 8),
          Text(
            correct ? correctLabel : incorrectLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.label});
  final QuestionCategory category;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.goldAccent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        category.name,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: colors.goldAccent, letterSpacing: 0.4),
      ),
    );
  }
}

class _DifficultyDots extends StatelessWidget {
  const _DifficultyDots({required this.difficulty});
  final QuestionDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filled = switch (difficulty) {
      QuestionDifficulty.easy => 1,
      QuestionDifficulty.medium => 2,
      QuestionDifficulty.hard => 3,
    };
    return Row(
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.only(right: 3),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled ? colors.secondary : colors.divider,
            ),
          ),
        );
      }),
    );
  }
}
