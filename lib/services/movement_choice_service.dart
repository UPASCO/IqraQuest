import '../models/movement_choice.dart';
import '../models/player.dart';
import '../models/question_category.dart';

/// Which question a rider gets.
///
/// The card decides the distance and nothing else: the level of every
/// question is the rider's own, chosen before the game — easy,
/// intermediate, expert, or mixed. A child who draws a 6 rides six
/// squares like anyone else and answers a question that is easy *for a
/// child*; an expert who draws a 1 still gets an expert question for it.
///
/// Every getter here returns null for the mixed level, which fixes no
/// tier: the deck draws one per card instead (`QuestionDeck.draw(null)`).
class MovementChoiceService {
  const MovementChoiceService();

  /// The difficulty of a turn question for [profile], or null on the
  /// mixed level. The card is taken so callers read naturally; it never
  /// changes the answer.
  QuestionDifficulty? difficultyFor(
    MovementChoice choice,
    PlayerProfile profile,
  ) => profile.difficulty;

  /// The difficulty of an optional bonus question (Défi, Raccourci): one
  /// level above the rider's own, capped at hard. The mixed level has no
  /// "one above", so it stays mixed and keeps its full range.
  QuestionDifficulty? bonusDifficultyFor(PlayerProfile profile) =>
      switch (profile.difficulty) {
        QuestionDifficulty.easy => QuestionDifficulty.medium,
        QuestionDifficulty.medium ||
        QuestionDifficulty.hard => QuestionDifficulty.hard,
        null => null,
      };

  /// The "Question du voyage" that validates an arrival is drawn at the
  /// rider's usual level, never as a difficulty spike (spec §10).
  QuestionDifficulty? journeyDifficultyFor(PlayerProfile profile) =>
      profile.difficulty;

  /// Knowledge points follow the level played: the rider's own on a
  /// fixed level, the level actually asked on the mixed one.
  int knowledgePointsFor(PlayerProfile profile, [QuestionDifficulty? asked]) =>
      profile.knowledgePointsFor(asked);
}
