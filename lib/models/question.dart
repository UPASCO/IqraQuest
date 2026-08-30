import 'package:flutter/foundation.dart';

import 'question_category.dart';

/// A single canonical quiz question, fully localized for one language.
///
/// The *canonical knowledge* (`id`, category, difficulty, source, free/
/// premium tier, correct answer position) is language-independent and
/// lives once in `assets/data/questions/master/`. Each per-language file
/// under `assets/data/questions/<lang>/` supplies only the translated
/// text fields for the same `id` — see CONTENT_SOURCE_POLICY.md §Modèle
/// canonique.
@immutable
class Question {
  const Question({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.ageLevel,
    required this.question,
    required this.answers,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.sourceType,
    required this.sourceWork,
    required this.sourceReference,
    required this.sourceDisplay,
    required this.sourceVerificationStatus,
    required this.consensusStatus,
    required this.isFree,
  }) : assert(answers.length == 4, 'A question must have exactly 4 answers'),
       assert(correctAnswerIndex >= 0 && correctAnswerIndex < 4, 'correctAnswerIndex must be 0..3');

  final String id;
  final QuestionCategory category;
  final QuestionDifficulty difficulty;
  final String ageLevel;

  final String question;
  final List<String> answers;
  final int correctAnswerIndex;
  final String explanation;

  final SourceType sourceType;
  final String sourceWork;
  final String sourceReference;

  /// Human-readable citation, already localized (e.g.
  /// "Coran — Sourate Hûd, 11:37-38").
  final String sourceDisplay;

  final SourceVerificationStatus sourceVerificationStatus;
  final ConsensusStatus consensusStatus;

  final bool isFree;

  String get correctAnswer => answers[correctAnswerIndex];

  bool isCorrect(int selectedIndex) => selectedIndex == correctAnswerIndex;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      category: QuestionCategory.values.byName(json['category'] as String),
      difficulty: QuestionDifficulty.values.byName(json['difficulty'] as String),
      ageLevel: json['ageLevel'] as String,
      question: json['question'] as String,
      answers: List<String>.from(json['answers'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String,
      sourceType: SourceType.values.byName(json['sourceType'] as String),
      sourceWork: json['sourceWork'] as String,
      sourceReference: json['sourceReference'] as String,
      sourceDisplay: json['sourceDisplay'] as String,
      sourceVerificationStatus: SourceVerificationStatus.values.byName(
        json['sourceVerificationStatus'] as String,
      ),
      consensusStatus: ConsensusStatus.values.byName(json['consensusStatus'] as String),
      isFree: json['isFree'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'difficulty': difficulty.name,
    'ageLevel': ageLevel,
    'question': question,
    'answers': answers,
    'correctAnswerIndex': correctAnswerIndex,
    'explanation': explanation,
    'sourceType': sourceType.name,
    'sourceWork': sourceWork,
    'sourceReference': sourceReference,
    'sourceDisplay': sourceDisplay,
    'sourceVerificationStatus': sourceVerificationStatus.name,
    'consensusStatus': consensusStatus.name,
    'isFree': isFree,
  };

  @override
  bool operator ==(Object other) => other is Question && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
