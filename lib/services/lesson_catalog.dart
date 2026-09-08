import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../features/classroom/domain/lesson.dart';
import '../models/question_category.dart';

/// The shipped list of classroom lessons, cut from the bank by
/// `tool/content/gen_lessons.py`.
///
/// Language-independent on purpose: a lesson is a list of card ids, and
/// each device — pupil's phone or projector — reads those cards in its
/// own language. A class where one child reads Arabic and the next
/// reads French is answering the same question.
class LessonCatalog {
  LessonCatalog();

  static const String assetPath = 'assets/data/lessons/lessons.json';

  List<Lesson>? _cache;

  Future<List<Lesson>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final lessons = [
      for (final entry in (json['lessons'] as List).cast<Map<String, dynamic>>())
        Lesson.fromJson(entry),
    ];
    return _cache = List.unmodifiable(lessons);
  }

  /// The lessons of one theme, easiest level first — how the console
  /// lists them for a teacher who has a topic in mind.
  static List<Lesson> byCategory(List<Lesson> all, QuestionCategory category) =>
      [for (final l in all) if (l.category == category) l];

  /// The lessons of one level, whatever the theme — how the console
  /// lists them for a teacher who has a class in mind.
  static List<Lesson> byDifficulty(
    List<Lesson> all,
    QuestionDifficulty difficulty,
  ) => [for (final l in all) if (l.difficulty == difficulty) l];

  static Lesson? byId(List<Lesson> all, String id) {
    for (final l in all) {
      if (l.id == id) return l;
    }
    return null;
  }
}
