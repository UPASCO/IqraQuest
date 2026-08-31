import 'package:flutter/foundation.dart';

import 'question_category.dart';

/// What a player has earned through knowledge this game. Everything here
/// comes from consecutive correct answers only — nothing is purchasable
/// and nothing is awarded at random (spec §9/§16).
@immutable
class RewardInventory {
  const RewardInventory({
    this.unassignedShields = 0,
    this.hasGrandGallop = false,
    this.masteryBadges = const {},
    this.knowledgePoints = 0,
    this.collectedFactIds = const {},
  });

  /// Shields earned but not yet attached to a horse (a shield is normally
  /// attached immediately to the horse that just moved).
  final int unassignedShields;

  /// At most one Grand Galop is held at a time (spec §9); it adds 2
  /// squares to a successful move, spent when the player decides.
  final bool hasGrandGallop;

  final Set<QuestionCategory> masteryBadges;

  /// Running total from the gaits played (1/2/3 points by risk tier).
  final int knowledgePoints;

  /// Facts and wisdom cards the player chose to keep (spec §7 Sagesse).
  final Set<String> collectedFactIds;

  RewardInventory copyWith({
    int? unassignedShields,
    bool? hasGrandGallop,
    Set<QuestionCategory>? masteryBadges,
    int? knowledgePoints,
    Set<String>? collectedFactIds,
  }) => RewardInventory(
    unassignedShields: unassignedShields ?? this.unassignedShields,
    hasGrandGallop: hasGrandGallop ?? this.hasGrandGallop,
    masteryBadges: masteryBadges ?? this.masteryBadges,
    knowledgePoints: knowledgePoints ?? this.knowledgePoints,
    collectedFactIds: collectedFactIds ?? this.collectedFactIds,
  );

  factory RewardInventory.fromJson(Map<String, dynamic> json) => RewardInventory(
    unassignedShields: json['unassignedShields'] as int? ?? 0,
    hasGrandGallop: json['hasGrandGallop'] as bool? ?? false,
    masteryBadges: {
      for (final name in (json['masteryBadges'] as List? ?? const []))
        QuestionCategory.values.byName(name as String),
    },
    knowledgePoints: json['knowledgePoints'] as int? ?? 0,
    collectedFactIds: Set<String>.from(json['collectedFactIds'] as List? ?? const []),
  );

  Map<String, dynamic> toJson() => {
    'unassignedShields': unassignedShields,
    'hasGrandGallop': hasGrandGallop,
    'masteryBadges': masteryBadges.map((c) => c.name).toList(),
    'knowledgePoints': knowledgePoints,
    'collectedFactIds': collectedFactIds.toList(),
  };
}
