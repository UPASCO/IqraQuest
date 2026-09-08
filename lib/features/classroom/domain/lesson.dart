import 'package:flutter/foundation.dart';

import '../../../models/question_category.dart';

/// One period's worth of cards: a single theme, a single level, and
/// between eight and eleven questions — what a class actually gets
/// through between the bell and the bell.
///
/// The cut is made once, by `tool/content/gen_lessons.py`, and shipped
/// as an asset: the same code handed to the same class next week draws
/// the same cards in the same order, and the teacher's console, the
/// projected board and the pupils' phones all read one list.
@immutable
class Lesson {
  const Lesson({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.index,
    required this.questionIds,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] as String,
    category: QuestionCategory.values.byName(json['category'] as String),
    difficulty: QuestionDifficulty.values.byName(json['difficulty'] as String),
    index: json['index'] as int,
    questionIds: List.unmodifiable(
      (json['questionIds'] as List).cast<String>(),
    ),
  );

  final String id;
  final QuestionCategory category;
  final QuestionDifficulty difficulty;

  /// Its place among the lessons of the same theme and level, from 1 —
  /// the number a teacher reads on the console and says out loud.
  final int index;

  final List<String> questionIds;

  int get questionCount => questionIds.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'difficulty': difficulty.name,
    'index': index,
    'questionIds': questionIds,
  };
}
