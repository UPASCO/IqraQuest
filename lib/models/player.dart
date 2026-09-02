import 'package:flutter/foundation.dart';

import '../theme/app_team.dart';
import 'horse_state.dart';
import 'knowledge_streak.dart';
import 'question_category.dart';
import 'reward_inventory.dart';

/// AI opponent strength. Only affects how often the AI answers correctly
/// and how boldly it picks gaits — it plays through the exact same engine
/// as a human and gets no hidden information.
enum AiDifficulty { easy, medium, hard }

/// The level a rider plays at, chosen before the game and applied to
/// every question they get, whatever the card. Three levels — easy,
/// intermediate, expert — so a 7-year-old and an adult share one board
/// fairly: the same cards, the same distances, each their own questions.
///
/// The names are written into every save file. Older saves carried
/// four levels; [Player.fromJson] folds them onto these three.
enum PlayerProfile { easy, intermediate, expert }

extension PlayerProfileX on PlayerProfile {
  /// The difficulty of every question this rider is asked.
  QuestionDifficulty get difficulty => switch (this) {
    PlayerProfile.easy => QuestionDifficulty.easy,
    PlayerProfile.intermediate => QuestionDifficulty.medium,
    PlayerProfile.expert => QuestionDifficulty.hard,
  };

  /// What a correct answer earns: harder questions, more knowledge.
  int get knowledgePoints => switch (this) {
    PlayerProfile.easy => 1,
    PlayerProfile.intermediate => 2,
    PlayerProfile.expert => 3,
  };

  /// The easy level is the children's level: larger answers on the card,
  /// the verdict and the right answer as the lesson (spec §14).
  bool get isChildMode => this == PlayerProfile.easy;

  /// Reads a level by name, folding the four levels of older saves
  /// (child, discovery, intermediate, advanced) onto today's three.
  static PlayerProfile parse(String? name) => switch (name) {
    'easy' || 'child' || 'discovery' => PlayerProfile.easy,
    'expert' || 'advanced' => PlayerProfile.expert,
    _ => PlayerProfile.intermediate,
  };
}

@immutable
class Player {
  const Player({
    required this.id,
    required this.name,
    required this.team,
    required this.horses,
    this.profile = PlayerProfile.intermediate,
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
  /// passed its journey question — in the classic and family formats;
  /// a quick race asks for one (see [GameVariantX.horsesToWin]).
  bool get hasArrivedCompletely => horses.every((h) => h.hasArrived);

  /// Horses that reached the finish AND passed their journey question.
  int get arrivedCount => horses.where((h) => h.hasArrived).length;

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
    streak: streak ?? this.streak,
    rewards: rewards ?? this.rewards,
    answersByCategory: answersByCategory ?? this.answersByCategory,
  );

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'] as String,
    name: json['name'] as String,
    team: AppTeam.values.byName(json['team'] as String),
    profile: PlayerProfileX.parse(json['profile'] as String?),
    aiDifficulty: json['aiDifficulty'] == null
        ? null
        : AiDifficulty.values.byName(json['aiDifficulty'] as String),
    horses: (json['horses'] as List)
        .map((h) => HorseState.fromJson(h as Map<String, dynamic>))
        .toList(),
    streak: KnowledgeStreak.fromJson(
      json['streak'] as Map<String, dynamic>? ?? const {},
    ),
    rewards: RewardInventory.fromJson(
      json['rewards'] as Map<String, dynamic>? ?? const {},
    ),
    answersByCategory: {
      for (final entry
          in (json['answersByCategory'] as Map<String, dynamic>? ?? const {})
              .entries)
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
    'streak': streak.toJson(),
    'rewards': rewards.toJson(),
    'answersByCategory': answersByCategory.map((k, v) => MapEntry(k.name, v)),
  };
}
