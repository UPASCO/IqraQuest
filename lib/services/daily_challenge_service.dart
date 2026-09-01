import 'dart:math';

import '../models/question.dart';

/// Picks 5 questions deterministically from the calendar date (spec §69):
/// same day → same question ids, everywhere, regardless of UI language
/// (the language only changes which text is shown for those same ids).
/// Entirely local — no server-issued daily set.
class DailyChallengeService {
  const DailyChallengeService();

  static const int questionsPerChallenge = 5;

  List<Question> challengeFor({required DateTime date, required List<Question> pool}) {
    if (pool.isEmpty) return const [];
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final sorted = [...pool]..sort((a, b) => a.id.compareTo(b.id));
    final rng = Random(seed);
    final shuffled = [...sorted]..shuffle(rng);
    // Answer order is shuffled too (the bank stores the correct answer
    // first); same seed = same challenge for everyone on a given day.
    return [
      for (final q in shuffled.take(questionsPerChallenge)) q.withShuffledAnswers(rng),
    ];
  }

  String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
