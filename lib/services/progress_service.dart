import 'package:flutter/foundation.dart';

import '../models/question_category.dart';
import 'local_storage_service.dart';

@immutable
class ProgressStats {
  const ProgressStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.dayStreak = 0,
    this.lastPlayedDate,
    this.categoryCorrect = const {},
    this.categoryTotal = const {},
    this.dailyChallengesCompleted = 0,
  });

  final int gamesPlayed;
  final int gamesWon;
  final int questionsAnswered;
  final int correctAnswers;
  final int dayStreak;
  final DateTime? lastPlayedDate;
  final Map<QuestionCategory, int> categoryCorrect;
  final Map<QuestionCategory, int> categoryTotal;
  final int dailyChallengesCompleted;

  double get winRate => gamesPlayed == 0 ? 0 : gamesWon / gamesPlayed;
  double get accuracy => questionsAnswered == 0 ? 0 : correctAnswers / questionsAnswered;

  ProgressStats copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? questionsAnswered,
    int? correctAnswers,
    int? dayStreak,
    DateTime? lastPlayedDate,
    Map<QuestionCategory, int>? categoryCorrect,
    Map<QuestionCategory, int>? categoryTotal,
    int? dailyChallengesCompleted,
  }) => ProgressStats(
    gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    gamesWon: gamesWon ?? this.gamesWon,
    questionsAnswered: questionsAnswered ?? this.questionsAnswered,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    dayStreak: dayStreak ?? this.dayStreak,
    lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
    categoryCorrect: categoryCorrect ?? this.categoryCorrect,
    categoryTotal: categoryTotal ?? this.categoryTotal,
    dailyChallengesCompleted: dailyChallengesCompleted ?? this.dailyChallengesCompleted,
  );

  factory ProgressStats.fromJson(Map<String, dynamic> json) => ProgressStats(
    gamesPlayed: json['gamesPlayed'] as int? ?? 0,
    gamesWon: json['gamesWon'] as int? ?? 0,
    questionsAnswered: json['questionsAnswered'] as int? ?? 0,
    correctAnswers: json['correctAnswers'] as int? ?? 0,
    dayStreak: json['dayStreak'] as int? ?? 0,
    lastPlayedDate: json['lastPlayedDate'] == null
        ? null
        : DateTime.parse(json['lastPlayedDate'] as String),
    categoryCorrect: {
      for (final entry in (json['categoryCorrect'] as Map<String, dynamic>? ?? {}).entries)
        QuestionCategory.values.byName(entry.key): entry.value as int,
    },
    categoryTotal: {
      for (final entry in (json['categoryTotal'] as Map<String, dynamic>? ?? {}).entries)
        QuestionCategory.values.byName(entry.key): entry.value as int,
    },
    dailyChallengesCompleted: json['dailyChallengesCompleted'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'gamesPlayed': gamesPlayed,
    'gamesWon': gamesWon,
    'questionsAnswered': questionsAnswered,
    'correctAnswers': correctAnswers,
    'dayStreak': dayStreak,
    'lastPlayedDate': lastPlayedDate?.toIso8601String(),
    'categoryCorrect': categoryCorrect.map((k, v) => MapEntry(k.name, v)),
    'categoryTotal': categoryTotal.map((k, v) => MapEntry(k.name, v)),
    'dailyChallengesCompleted': dailyChallengesCompleted,
  };
}

/// All progression is local-only (spec §70/§84): no account, no server.
class ProgressService {
  ProgressService(this._storage);

  static const _key = 'iqraquest.progress.v1';
  final LocalStorageService _storage;

  ProgressStats load() {
    final json = _storage.getJson(_key);
    if (json == null) return const ProgressStats();
    return ProgressStats.fromJson(json);
  }

  Future<void> save(ProgressStats stats) => _storage.setJson(_key, stats.toJson());

  Future<ProgressStats> recordAnswer({
    required bool correct,
    required QuestionCategory category,
  }) async {
    final current = load();
    final total = Map<QuestionCategory, int>.from(current.categoryTotal);
    final okMap = Map<QuestionCategory, int>.from(current.categoryCorrect);
    total[category] = (total[category] ?? 0) + 1;
    if (correct) okMap[category] = (okMap[category] ?? 0) + 1;

    final updated = current.copyWith(
      questionsAnswered: current.questionsAnswered + 1,
      correctAnswers: current.correctAnswers + (correct ? 1 : 0),
      categoryTotal: total,
      categoryCorrect: okMap,
    );
    await save(updated);
    return updated;
  }

  Future<ProgressStats> recordDailyChallengeCompletion() async {
    final current = load();
    final updated = current.copyWith(
      dailyChallengesCompleted: current.dailyChallengesCompleted + 1,
    );
    await save(updated);
    return updated;
  }

  Future<ProgressStats> recordGameEnd({required bool won}) async {
    final current = load();
    final today = DateTime.now();
    final last = current.lastPlayedDate;
    final isConsecutiveDay =
        last != null && today.difference(DateTime(last.year, last.month, last.day)).inDays == 1;
    final isSameDay =
        last != null &&
        last.year == today.year &&
        last.month == today.month &&
        last.day == today.day;

    final newStreak = isSameDay
        ? current.dayStreak
        : (isConsecutiveDay ? current.dayStreak + 1 : 1);

    final updated = current.copyWith(
      gamesPlayed: current.gamesPlayed + 1,
      gamesWon: current.gamesWon + (won ? 1 : 0),
      lastPlayedDate: today,
      dayStreak: newStreak,
    );
    await save(updated);
    return updated;
  }
}
