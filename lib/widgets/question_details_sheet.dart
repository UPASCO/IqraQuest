import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/question.dart';
import '../models/question_category.dart';
import '../theme/app_theme.dart';

/// The lesson behind a card, opened from the "Learn more" button once a
/// question is answered: the question again, the right answer set apart,
/// the explanation at reading size and the source it rests on.
///
/// A quiz teaches only if the player can linger on the *why*; the
/// feedback beat in play is deliberately short, so this sheet is where
/// the learning happens, at the player's own pace, on every level —
/// including the easy one, where the inline explanation is hidden.
Future<void> showQuestionDetails(BuildContext context, Question question) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) => QuestionDetailsSheet(question: question),
  );
}

class QuestionDetailsSheet extends StatelessWidget {
  const QuestionDetailsSheet({super.key, required this.question});

  final Question question;

  // The sheet is a fixed parchment in both themes, like the card.
  static const _ink = Color(0xFF2A2116);
  static const _inkSoft = Color(0xFF6B5A3E);
  static const _gold = Color(0xFFC89A3C);
  static const _goldDeep = Color(0xFF8C6420);
  static const _leaf = Color(0xFF1F7A4D);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final screen = MediaQuery.sizeOf(context);
    final categoryLabel = switch (question.category) {
      QuestionCategory.prophets => l10n.categoryProphets,
      QuestionCategory.sira => l10n.categorySira,
      QuestionCategory.quran => l10n.categoryQuran,
      QuestionCategory.faith => l10n.categoryFaith,
      QuestionCategory.virtues => l10n.categoryVirtues,
    };
    final correct = question.answers[question.correctAnswerIndex];

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          color: _goldDeep,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Semantics(
          label: l10n.questionDetailsTitle,
          child: Container(
            key: const Key('question-details'),
            constraints: BoxConstraints(maxHeight: screen.height * 0.86),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFCF5E4), Color(0xFFF0DFBD)],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFD8B76A), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Crest: category and level, then the title in
                        // the card's own display voice.
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _gold.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                categoryLabel,
                                style: textTheme.labelSmall?.copyWith(
                                  color: _goldDeep,
                                  letterSpacing: 0.4,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _LevelDots(difficulty: question.difficulty),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.questionDetailsTitle,
                          style: textTheme.headlineSmall?.copyWith(
                            color: _ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const _Rule(),
                        const SizedBox(height: 16),

                        label(l10n.theQuestionLabel),
                        Text(
                          question.question,
                          style: textTheme.titleMedium?.copyWith(
                            color: _ink,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18),

                        label(l10n.theAnswerLabel),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          decoration: BoxDecoration(
                            color: _leaf.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _leaf.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: _leaf,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  correct,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: _ink,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        label(l10n.explanationLabel),
                        Text(
                          question.explanation,
                          style: textTheme.bodyLarge?.copyWith(
                            color: _ink,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),

                        label(l10n.sourceLabel),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: _gold.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _gold.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.menu_book_rounded,
                                size: 18,
                                color: _goldDeep,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  question.sourceDisplay,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: _inkSoft,
                                    fontStyle: FontStyle.italic,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 18),
                  child: SizedBox(
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
                          key: const Key('question-details-close'),
                          onTap: () => Navigator.of(context).pop(),
                          child: Center(
                            child: Text(
                              MaterialLocalizations.of(
                                context,
                              ).closeButtonLabel,
                              style: textTheme.titleMedium?.copyWith(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The "Learn more" affordance shared by the in-game feedback sheet and
/// the daily-challenge card: a quiet gold link with a book, never a second
/// primary button competing with "Continue".
class LearnMoreButton extends StatelessWidget {
  const LearnMoreButton({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        key: const Key('learn-more'),
        onPressed: () => showQuestionDetails(context, question),
        style: TextButton.styleFrom(
          foregroundColor: QuestionDetailsSheet._goldDeep,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          visualDensity: VisualDensity.compact,
        ),
        icon: const Icon(Icons.auto_stories_rounded, size: 18),
        label: Text(
          l10n.learnMore,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: QuestionDetailsSheet._goldDeep,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
            decorationColor: QuestionDetailsSheet._gold,
          ),
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x00C89A3C), Color(0xFFC89A3C)],
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.star_rounded, size: 12, color: Color(0xFFC89A3C)),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFC89A3C), Color(0x00C89A3C)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelDots extends StatelessWidget {
  const _LevelDots({required this.difficulty});

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
              color: i < filled
                  ? colors.secondary
                  : const Color(0xFFC89A3C).withValues(alpha: 0.35),
            ),
          ),
        );
      }),
    );
  }
}
