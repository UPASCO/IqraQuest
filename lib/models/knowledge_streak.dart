import 'package:flutter/foundation.dart';

/// A reward earned purely through consecutive correct answers. Never
/// bought, never granted at random (spec §9: "Les bonus sont exclusivement
/// obtenus par les connaissances").
enum StreakReward {
  /// 3 in a row — protects one horse from a single capture.
  shield,

  /// 5 in a row — adds 2 squares to a future successful move, spent when
  /// the player chooses. Only one can be held at a time.
  grandGallop,

  /// 10 in a row — a mastery badge in the player's dominant category.
  masteryBadge,
}

/// The "Élan du savoir" gauge: consecutive correct answers, and the
/// thresholds they unlock.
@immutable
class KnowledgeStreak {
  const KnowledgeStreak({this.current = 0, this.best = 0});

  static const int shieldThreshold = 3;
  static const int grandGallopThreshold = 5;
  static const int masteryThreshold = 10;

  final int current;
  final int best;

  /// The next threshold this streak is working toward, for the gauge.
  int get nextThreshold {
    if (current < shieldThreshold) return shieldThreshold;
    if (current < grandGallopThreshold) return grandGallopThreshold;
    if (current < masteryThreshold) return masteryThreshold;
    // Past 10 the gauge keeps cycling every 10 so it never looks "maxed".
    return ((current ~/ masteryThreshold) + 1) * masteryThreshold;
  }

  double get progressToNextThreshold {
    final previous = switch (nextThreshold) {
      shieldThreshold => 0,
      grandGallopThreshold => shieldThreshold,
      masteryThreshold => grandGallopThreshold,
      final other => other - masteryThreshold,
    };
    final span = nextThreshold - previous;
    return span == 0 ? 0 : (current - previous) / span;
  }

  /// Advances the streak by one correct answer, reporting any thresholds
  /// crossed by *this* answer.
  ({KnowledgeStreak streak, List<StreakReward> unlocked}) recordCorrect() {
    final next = current + 1;
    return (
      streak: KnowledgeStreak(current: next, best: next > best ? next : best),
      unlocked: [
        if (next == shieldThreshold) StreakReward.shield,
        if (next == grandGallopThreshold) StreakReward.grandGallop,
        if (next == masteryThreshold) StreakReward.masteryBadge,
      ],
    );
  }

  /// A wrong answer zeroes the run — but never takes back rewards already
  /// earned (spec §9).
  KnowledgeStreak recordIncorrect() => KnowledgeStreak(current: 0, best: best);

  factory KnowledgeStreak.fromJson(Map<String, dynamic> json) =>
      KnowledgeStreak(current: json['current'] as int? ?? 0, best: json['best'] as int? ?? 0);

  Map<String, dynamic> toJson() => {'current': current, 'best': best};

  @override
  bool operator ==(Object other) =>
      other is KnowledgeStreak && other.current == current && other.best == best;

  @override
  int get hashCode => Object.hash(current, best);
}
