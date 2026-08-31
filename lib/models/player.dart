import 'package:flutter/foundation.dart';

import '../theme/app_team.dart';
import 'gait_cycle.dart';
import 'horse_state.dart';
import 'knowledge_streak.dart';
import 'question_category.dart';
import 'reward_inventory.dart';

/// AI opponent strength. Only affects how often the AI answers correctly
/// and how boldly it picks gaits — it plays through the exact same engine
/// as a human and gets no hidden information.
enum AiDifficulty { easy, medium, hard }

/// Per-player knowledge level (spec §14). This is what lets a 7-year-old
/// and an adult share the same board fairly: the gait→difficulty mapping
/// is identical, but "hard" means something different per profile, so a
/// child's bold gait draws a question suited to their age.
enum PlayerProfile { child, discovery, intermediate, advanced }

extension PlayerProfileX on PlayerProfile {
  /// Child mode gets larger text, optional read-aloud, a confirmation on
  /// risky gaits, and never a countdown (spec §14).
  bool get isChildMode => this == PlayerProfile.child;

  /// Whether gaits 5–6 ask for confirmation before committing.
  bool get confirmsRiskyGaits => this == PlayerProfile.child;
}

@immutable
class Player {
  const Player({
    required this.id,
    required this.name,
    required this.team,
    required this.horses,
    this.profile = PlayerProfile.intermediate,
    this.gaitCycle = const GaitCycle(),
    this.streak = const KnowledgeStreak(),
    this.rewards = const RewardInventory(),
    this.aiDifficulty,
    this.answersByCategory = const {},
  });

  final String id;

  /// Local-only display name (never transmitted anywhere).
  final String name;

  final AppTeam team;
  final PlayerProfile profile;

  final List<HorseState> horses;

  /// Which of the six gaits are still available this cycle.
  final GaitCycle gaitCycle;

  final KnowledgeStreak streak;
  final RewardInventory rewards;

  /// Correct answers per category, used to decide which mastery badge a
  /// 10-streak earns.
  final Map<QuestionCategory, int> answersByCategory;

  /// null for a human player; set for an AI-controlled player.
  final AiDifficulty? aiDifficulty;

  bool get isAi => aiDifficulty != null;
  bool get isHuman => !isAi;

  /// The game is won when every horse has both reached the finish and
  /// passed its journey question.
  bool get hasArrivedCompletely => horses.every((h) => h.hasArrived);

  /// The category this player answers best in — the badge a 10-streak
  /// awards.
  QuestionCategory? get dominantCategory {
    if (answersByCategory.isEmpty) return null;
    var best = answersByCategory.entries.first;
    for (final entry in answersByCategory.entries) {
      if (entry.value > best.value) best = entry;
    }
    return best.key;
  }

  Player copyWith({
    String? name,
    List<HorseState>? horses,
    PlayerProfile? profile,
    GaitCycle? gaitCycle,
    KnowledgeStreak? streak,
    RewardInventory? rewards,
    Map<QuestionCategory, int>? answersByCategory,
  }) => Player(
    id: id,
    name: name ?? this.name,
    team: team,
    profile: profile ?? this.profile,
    aiDifficulty: aiDifficulty,
    horses: horses ?? this.horses,
    gaitCycle: gaitCycle ?? this.gaitCycle,
    streak: streak ?? this.streak,
    rewards: rewards ?? this.rewards,
    answersByCategory: answersByCategory ?? this.answersByCategory,
  );

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'] as String,
    name: json['name'] as String,
    team: AppTeam.values.byName(json['team'] as String),
    profile: PlayerProfile.values.byName(
      json['profile'] as String? ?? PlayerProfile.intermediate.name,
    ),
    aiDifficulty: json['aiDifficulty'] == null
        ? null
        : AiDifficulty.values.byName(json['aiDifficulty'] as String),
    horses: (json['horses'] as List)
        .map((h) => HorseState.fromJson(h as Map<String, dynamic>))
        .toList(),
    gaitCycle: GaitCycle.fromJson(json['gaitCycle'] as Map<String, dynamic>? ?? const {}),
    streak: KnowledgeStreak.fromJson(json['streak'] as Map<String, dynamic>? ?? const {}),
    rewards: RewardInventory.fromJson(json['rewards'] as Map<String, dynamic>? ?? const {}),
    answersByCategory: {
      for (final entry in (json['answersByCategory'] as Map<String, dynamic>? ?? const {}).entries)
        QuestionCategory.values.byName(entry.key): entry.value as int,
    },
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'team': team.name,
    'profile': profile.name,
    'aiDifficulty': aiDifficulty?.name,
    'horses': horses.map((h) => h.toJson()).toList(),
    'gaitCycle': gaitCycle.toJson(),
    'streak': streak.toJson(),
    'rewards': rewards.toJson(),
    'answersByCategory': answersByCategory.map((k, v) => MapEntry(k.name, v)),
  };
}
