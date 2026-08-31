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

  /// Picks one unasked question at the requested difficulty, honoring the
  /// free/Premium gate and the no-repeat-within-a-game rule.
  ///
  /// The shuffle here only decides *which* question of the requested tier
  /// comes up, so the same question does not repeat within a game — it
  /// never influences how far a horse moves or what a player wins. The
  /// difficulty itself is always the player's own choice of gait.
  ///
  /// If the requested tier is exhausted, this falls back to the nearest
  /// remaining tier rather than returning nothing, so a turn is never
  /// blocked mid-game.
  Question? pickQuestion({
    required List<Question> pool,
    required Set<String> askedQuestionIds,
    required bool isPremium,
    QuestionDifficulty? difficulty,
    QuestionCategory? preferredCategory,
    Random? random,
  }) {
    final rng = random ?? Random();
    final available = pool.where((q) {
      if (askedQuestionIds.contains(q.id)) return false;
      if (!isPremium && !q.isFree) return false;
      return true;
    }).toList();

    if (available.isEmpty) return null;

    var candidates = available;
    if (difficulty != null) {
      for (final tier in _tierFallbackOrder(difficulty)) {
        final atTier = available.where((q) => q.difficulty == tier).toList();
        if (atTier.isNotEmpty) {
          candidates = atTier;
          break;
        }
      }
    }

    if (preferredCategory != null) {
      final inCategory = candidates.where((q) => q.category == preferredCategory).toList();
      if (inCategory.isNotEmpty) candidates = inCategory;
    }

    return candidates[rng.nextInt(candidates.length)];
  }

  /// Preferred tier first, then the closest neighbours.
  List<QuestionDifficulty> _tierFallbackOrder(QuestionDifficulty difficulty) =>
      switch (difficulty) {
        QuestionDifficulty.easy => const [
          QuestionDifficulty.easy,
          QuestionDifficulty.medium,
          QuestionDifficulty.hard,
        ],
        QuestionDifficulty.medium => const [
          QuestionDifficulty.medium,
          QuestionDifficulty.easy,
          QuestionDifficulty.hard,
        ],
        QuestionDifficulty.hard => const [
          QuestionDifficulty.hard,
          QuestionDifficulty.medium,
          QuestionDifficulty.easy,
        ],
      };

  /// True once every free-tier question has been asked this game. Play
  /// then continues without a question gate rather than being interrupted
  /// or paywalled mid-game.
  bool isFreeBankExhausted({required List<Question> pool, required Set<String> askedQuestionIds}) {
    final freeIds = pool.where((q) => q.isFree).map((q) => q.id).toSet();
    return freeIds.isNotEmpty && freeIds.every(askedQuestionIds.contains);
  }
}
