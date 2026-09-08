// The lessons a teacher opens. They are cut once, by
// tool/content/gen_lessons.py, and shipped as an asset — so what this
// file checks is the shipped cut itself, not a fixture of it.
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/classroom/domain/lesson.dart';
import 'package:iqraquest/features/classroom/presentation/lesson_labels.dart';
import 'package:iqraquest/l10n/generated/app_localizations_en.dart';
import 'package:iqraquest/l10n/generated/app_localizations_fr.dart';
import 'package:iqraquest/models/question_category.dart';
import 'package:iqraquest/services/lesson_catalog.dart';
import 'package:iqraquest/services/question_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every lesson is one period long: eight to eleven cards', () async {
    final lessons = await LessonCatalog().load();

    expect(lessons, isNotEmpty);
    for (final lesson in lessons) {
      expect(
        lesson.questionCount,
        inInclusiveRange(8, 11),
        reason: '${lesson.id} does not fit a class period',
      );
    }
  });

  test('the lessons cover the whole bank, each card exactly once', () async {
    final lessons = await LessonCatalog().load();
    final bank = await QuestionRepository().loadAll('en');

    final seen = <String>{};
    for (final lesson in lessons) {
      for (final id in lesson.questionIds) {
        expect(seen.add(id), isTrue, reason: '$id is in two lessons');
      }
    }
    expect(
      seen.length,
      bank.length,
      reason: 'a card in no lesson is a card no class will ever see',
    );
  });

  test('every card a lesson names is really in the bank', () async {
    final lessons = await LessonCatalog().load();
    final bank = await QuestionRepository().loadAll('en');
    final known = {for (final q in bank) q.id};

    for (final lesson in lessons) {
      for (final id in lesson.questionIds) {
        expect(known, contains(id), reason: '${lesson.id} names an unknown $id');
      }
    }
  });

  test('a lesson holds one theme and one level, and says which', () async {
    final lessons = await LessonCatalog().load();
    final bank = await QuestionRepository().loadAll('en');
    final byId = {for (final q in bank) q.id: q};

    for (final lesson in lessons) {
      for (final id in lesson.questionIds) {
        expect(byId[id]!.category, lesson.category, reason: lesson.id);
        expect(byId[id]!.difficulty, lesson.difficulty, reason: lesson.id);
      }
    }
  });

  test('lesson ids are unique and numbered from one within a level', () async {
    final lessons = await LessonCatalog().load();

    expect(lessons.map((l) => l.id).toSet(), hasLength(lessons.length));
    final groups = <String, List<int>>{};
    for (final lesson in lessons) {
      groups
          .putIfAbsent('${lesson.category.name}/${lesson.difficulty.name}', () => [])
          .add(lesson.index);
    }
    for (final entry in groups.entries) {
      expect(
        entry.value,
        List.generate(entry.value.length, (i) => i + 1),
        reason: '${entry.key} is not numbered 1..n in order',
      );
    }
  });

  test('the catalog is filtered the two ways a teacher thinks', () async {
    final lessons = await LessonCatalog().load();

    final sira = LessonCatalog.byCategory(lessons, QuestionCategory.sira);
    expect(sira, isNotEmpty);
    expect(sira.every((l) => l.category == QuestionCategory.sira), isTrue);

    final beginner = LessonCatalog.byDifficulty(
      lessons,
      QuestionDifficulty.beginner,
    );
    expect(beginner, isNotEmpty);
    expect(
      beginner.every((l) => l.difficulty == QuestionDifficulty.beginner),
      isTrue,
    );

    expect(LessonCatalog.byId(lessons, lessons.first.id), lessons.first);
    expect(LessonCatalog.byId(lessons, 'lesson_nowhere_01'), isNull);
  });

  test('a lesson is named in the reader own language, never in code', () async {
    final lessons = await LessonCatalog().load();
    final lesson = lessons.firstWhere(
      (l) =>
          l.category == QuestionCategory.sira &&
          l.difficulty == QuestionDifficulty.beginner,
    );

    expect(
      lessonTitle(AppLocalizationsEn(), lesson),
      'Sira · First steps ${lesson.index}',
    );
    expect(
      lessonTitle(AppLocalizationsFr(), lesson),
      contains('Premiers pas'),
      reason: 'the French teacher reads a French lesson name',
    );
    for (final l in lessons) {
      expect(lessonTitle(AppLocalizationsFr(), l), isNot(contains('lesson_')));
    }
  });

  test('the round trip through the wire keeps a lesson whole', () async {
    final lesson = (await LessonCatalog().load()).first;
    final restored = Lesson.fromJson(lesson.toJson());

    expect(restored.id, lesson.id);
    expect(restored.category, lesson.category);
    expect(restored.difficulty, lesson.difficulty);
    expect(restored.questionIds, lesson.questionIds);
  });
}
