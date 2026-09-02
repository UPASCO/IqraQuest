import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'question_details_sheet.dart';
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
    this.brief = false,
    this.largeText = false,
  });

  final Question question;
  final int? selectedIndex;
  final bool? isCorrect;
  final ValueChanged<int>? onSelect;
  final VoidCallback? onContinue;

  /// Once answered, show only the verdict on the tiles — no explanation,
  /// no button. The screen then hands over to [AnswerFeedbackSheet] so
  /// the ride on the board is not hidden behind a wall of text.
  final bool brief;

  /// Child level: bigger answer type and taller tiles, so a young reader
  /// can read and hit them without help.
  final bool largeText;

  static const _letters = ['A', 'B', 'C', 'D'];

  /// The card is a fixed light parchment in both themes, so its ink is
  /// fixed dark too — theme text colors would turn cream in dark mode.
  static const Color _ink = Color(0xFF3A2C12);
  static const Color _inkSoft = Color(0xFF7A6842);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final answered = isCorrect != null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFCF5E4), Color(0xFFF2E3C4)],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFD8B76A), width: 1.2),
        ),
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
                    _CategoryChip(
                      category: question.category,
                      label: switch (question.category) {
                        QuestionCategory.prophets => l10n.categoryProphets,
                        QuestionCategory.sira => l10n.categorySira,
                        QuestionCategory.quran => l10n.categoryQuran,
                        QuestionCategory.faith => l10n.categoryFaith,
                        QuestionCategory.virtues => l10n.categoryVirtues,
                      },
                    ),
                    const SizedBox(width: 8),
                    _DifficultyDots(difficulty: question.difficulty),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  question.question,
                  // Fixed dark ink: the parchment stays light in dark mode.
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(color: _ink),
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < question.answers.length; i++) ...[
                  _AnswerTile(
                    letter: _letters[i],
                    text: question.answers[i],
                    state: _tileState(i),
                    large: largeText,
                    onTap: answered || onSelect == null
                        ? null
                        : () => onSelect!(i),
                  ),
                  const SizedBox(height: 12),
                ],
                if (answered && !brief) ...[
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
                        ?.copyWith(color: _inkSoft),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.explanation,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: _ink),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.sourceLabel,
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: _inkSoft),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.sourceDisplay,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _inkSoft,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 6),
                  LearnMoreButton(question: question),
                  if (onContinue != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Material(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
                            onTap: onContinue,
                            child: Center(
                              child: Text(
                                MaterialLocalizations.of(context)
                                    .continueButtonLabel,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: const Color(0xFF4A3410),
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _AnswerTileState _tileState(int index) {
    if (isCorrect == null) {
      return selectedIndex == index
          ? _AnswerTileState.selected
          : _AnswerTileState.neutral;
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
    this.large = false,
  });

  final String letter;
  final String text;
  final _AnswerTileState state;
  final VoidCallback? onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (bg, border, fg) = switch (state) {
      _AnswerTileState.neutral => (
        Colors.white,
        const Color(0xFFCBB98F),
        QuestionCard._ink,
      ),
      _AnswerTileState.selected => (
        colors.primary.withValues(alpha: 0.12),
        colors.primary,
        QuestionCard._ink,
      ),
      _AnswerTileState.correct => (
        colors.success.withValues(alpha: 0.16),
        colors.success,
        QuestionCard._ink,
      ),
      _AnswerTileState.incorrect => (
        colors.error.withValues(alpha: 0.14),
        colors.error,
        QuestionCard._ink,
      ),
      _AnswerTileState.dimmed => (
        const Color(0xFFF0E7D2),
        const Color(0xFFD5C49B),
        QuestionCard._inkSoft,
      ),
    };

    return Semantics(
      button: true,
      selected: state == _AnswerTileState.selected,
      label: '$letter. $text',
      child: _PressableEdge(
        edgeColor: border,
        enabled: onTap != null,
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: large ? 60 : 52),
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
                  style: large
                      ? Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        )
                      : Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(color: fg),
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

/// A game button, not a form row: the tile sits on a solid darker edge
/// and physically presses down onto it. 80-120ms, honors Reduce Motion.
class _PressableEdge extends StatefulWidget {
  const _PressableEdge({
    required this.child,
    required this.edgeColor,
    required this.enabled,
    this.onTap,
  });

  final Widget child;
  final Color edgeColor;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  State<_PressableEdge> createState() => _PressableEdgeState();
}

class _PressableEdgeState extends State<_PressableEdge> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    const depth = 4.0;
    final pressed = _down && widget.enabled;
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: Padding(
        padding: EdgeInsets.only(top: pressed ? depth : 0),
        child: AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.tap),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: pressed
                ? const []
                : [
                    BoxShadow(
                      color: Color.lerp(widget.edgeColor, Colors.black, 0.25)!,
                      offset: const Offset(0, depth),
                    ),
                  ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// The second beat of an answer: the verdict, the right answer when the
/// player missed it, the explanation and its source, and the way on.
///
/// Lives at the bottom of the screen with the board unblurred above it,
/// so the horse is seen riding while the player reads why.
class AnswerFeedbackSheet extends StatelessWidget {
  const AnswerFeedbackSheet({
    super.key,
    required this.question,
    required this.isCorrect,
    required this.onContinue,
    this.showExplanation = true,
  });

  final Question question;
  final bool isCorrect;
  final VoidCallback onContinue;

  /// Off for the child level: the verdict and the right answer are the
  /// lesson; a paragraph of sources is for the grown-ups' level.
  final bool showExplanation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFCF5E4), Color(0xFFF2E3C4)],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFD8B76A), width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _FeedbackBand(
                correct: isCorrect,
                correctLabel: l10n.correctAnswer,
                incorrectLabel: l10n.incorrectAnswer,
              ),
              if (!isCorrect) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.correctAnswerWas(
                    question.answers[question.correctAnswerIndex],
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: QuestionCard._ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              if (showExplanation) ...[
                const SizedBox(height: 12),
                Text(
                  question.explanation,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: QuestionCard._ink, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  question.sourceDisplay,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: QuestionCard._inkSoft,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              // The lesson is one tap away on every level, the easy one
              // included: the paragraph above is hidden there, the door
              // to it is not.
              const SizedBox(height: 6),
              LearnMoreButton(question: question),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Material(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                      onTap: onContinue,
                      child: Center(
                        child: Text(
                          MaterialLocalizations.of(context).continueButtonLabel,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: const Color(0xFF4A3410),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
          // Bounded: "Not quite — here is the answer" wraps at the large
          // text size on a small phone instead of running off the card.
          Expanded(
            child: Text(
              correct ? correctLabel : incorrectLabel,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: color),
            ),
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
        label,
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
