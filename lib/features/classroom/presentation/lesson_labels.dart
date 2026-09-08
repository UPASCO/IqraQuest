import '../../../l10n/generated/app_localizations.dart';
import '../../../models/question_category.dart';
import '../domain/lesson.dart';

/// What a lesson is called, in the reader's own language.
///
/// The name is composed rather than written: a theme and a level the app
/// already names everywhere else, plus the lesson's number. Cutting the
/// bank differently therefore never leaves a lesson without a title in
/// eleven of the twelve languages.
String lessonTitle(AppLocalizations l10n, Lesson lesson) => l10n.lessonTitle(
  categoryLabel(l10n, lesson.category),
  difficultyLabel(l10n, lesson.difficulty),
  lesson.index,
);

String categoryLabel(AppLocalizations l10n, QuestionCategory category) =>
    switch (category) {
      QuestionCategory.prophets => l10n.categoryProphets,
      QuestionCategory.sira => l10n.categorySira,
      QuestionCategory.quran => l10n.categoryQuran,
      QuestionCategory.faith => l10n.categoryFaith,
      QuestionCategory.virtues => l10n.categoryVirtues,
    };

String difficultyLabel(AppLocalizations l10n, QuestionDifficulty difficulty) =>
    switch (difficulty) {
      QuestionDifficulty.beginner => l10n.levelBeginner,
      QuestionDifficulty.easy => l10n.levelEasy,
      QuestionDifficulty.medium => l10n.levelIntermediate,
      QuestionDifficulty.hard => l10n.levelExpert,
    };
