import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../models/question.dart';
import '../models/question_category.dart';

/// Loads the question bank for one language, joining the language-
/// independent canonical facts (`assets/data/questions/master/`) with the
/// per-language text (`assets/data/questions/<lang>/`) by `id`.
///
/// Only languages with a shipped `assets/data/questions/<lang>/` directory
/// are supported; see CONTENT_SOURCE_POLICY.md §10 for the current set.
/// Falls back to English if the requested language has no question file.
class QuestionRepository {
  QuestionRepository();

  static const List<String> supportedContentLanguages = ['fr', 'en', 'ar'];
  static const String fallbackLanguage = 'en';

  List<Question>? _cache;
  String? _cachedLanguage;

  Future<List<Question>> loadAll(String languageCode) async {
    final lang = supportedContentLanguages.contains(languageCode) ? languageCode : fallbackLanguage;
    if (_cache != null && _cachedLanguage == lang) return _cache!;

    final masterRaw = await rootBundle.loadString('assets/data/questions/master/questions.json');
    final langRaw = await rootBundle.loadString('assets/data/questions/$lang/questions.json');

    final master = (jsonDecode(masterRaw) as List).cast<Map<String, dynamic>>();
    final content = (jsonDecode(langRaw) as List).cast<Map<String, dynamic>>();
    final contentById = {for (final c in content) c['id'] as String: c};

    final questions = <Question>[];
    for (final m in master) {
      final id = m['id'] as String;
      final c = contentById[id];
      if (c == null) continue; // missing translation — skip, never crash
      if (m['sourceVerificationStatus'] != 'verified') continue;
      if (m['consensusStatus'] != 'nonControversial') continue;

      questions.add(
        Question.fromJson({
          ...m,
          'question': c['question'],
          'answers': c['answers'],
          'correctAnswerIndex': c['correctAnswerIndex'],
          'explanation': c['explanation'],
          'sourceDisplay': c['sourceDisplay'],
        }),
      );
    }

    _cache = List.unmodifiable(questions);
    _cachedLanguage = lang;
    return _cache!;
  }

  /// Picks one unasked question, honoring the free/Premium gate and the
  /// no-repeat-within-a-game rule (spec §48–§49).
  Question? pickQuestion({
    required List<Question> pool,
    required Set<String> askedQuestionIds,
    required bool isPremium,
    QuestionCategory? preferredCategory,
    Random? random,
  }) {
    final rng = random ?? Random();
    var candidates = pool.where((q) {
      if (askedQuestionIds.contains(q.id)) return false;
      if (!isPremium && !q.isFree) return false;
      return true;
    }).toList();

    if (candidates.isEmpty) return null;

    if (preferredCategory != null) {
      final inCategory = candidates.where((q) => q.category == preferredCategory).toList();
      if (inCategory.isNotEmpty) candidates = inCategory;
    }

    return candidates[rng.nextInt(candidates.length)];
  }

  /// True once every free-tier question has been asked this game, for the
  /// free-edition "allow dice without a question" fallback (spec §49).
  bool isFreeBankExhausted({required List<Question> pool, required Set<String> askedQuestionIds}) {
    final freeIds = pool.where((q) => q.isFree).map((q) => q.id).toSet();
    return freeIds.isNotEmpty && freeIds.every(askedQuestionIds.contains);
  }
}
