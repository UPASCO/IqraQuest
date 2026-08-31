import '../models/movement_choice.dart';
import '../models/player.dart';
import '../models/question_category.dart';

/// Turns a chosen gait into the question difficulty actually drawn for a
/// given player.
///
/// The gait→risk mapping is identical for everyone (1-2 gentle, 3-4
/// steady, 5-6 bold), which is what keeps the board fair and readable.
/// What changes per profile is what those tiers *mean*: a child taking a
/// bold gait deserves a question that is hard *for a child*, not an adult
/// question they cannot possibly answer (spec §14).
class MovementChoiceService {
  const MovementChoiceService();

  QuestionDifficulty difficultyFor(MovementChoice choice, PlayerProfile profile) {
    return switch (profile) {
      PlayerProfile.child || PlayerProfile.discovery => switch (choice.risk) {
        DifficultyRisk.gentle || DifficultyRisk.steady => QuestionDifficulty.easy,
        DifficultyRisk.bold => QuestionDifficulty.medium,
      },
      PlayerProfile.intermediate => choice.difficulty,
      PlayerProfile.advanced => switch (choice.risk) {
        DifficultyRisk.gentle => QuestionDifficulty.medium,
        DifficultyRisk.steady || DifficultyRisk.bold => QuestionDifficulty.hard,
      },
    };
  }

  /// The difficulty of an optional bonus question (Défi, Raccourci): one
  /// tier above what this player's bold gait would draw, capped at hard.
  QuestionDifficulty bonusDifficultyFor(PlayerProfile profile) {
    final bold = difficultyFor(const MovementChoice(6), profile);
    return switch (bold) {
      QuestionDifficulty.easy => QuestionDifficulty.medium,
      QuestionDifficulty.medium || QuestionDifficulty.hard => QuestionDifficulty.hard,
    };
  }

  /// The "Question du voyage" that validates an arrival is drawn at the
  /// player's usual level, never as a difficulty spike (spec §10).
  QuestionDifficulty journeyDifficultyFor(PlayerProfile profile) =>
      difficultyFor(const MovementChoice(3), profile);

  /// Knowledge points are a pure function of the gait's risk tier, the
  /// same for every profile — effort is rewarded equally.
  int knowledgePointsFor(MovementChoice choice) => choice.knowledgePoints;
}
