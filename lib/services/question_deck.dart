import 'dart:math';

import '../models/question.dart';
import '../models/question_category.dart';

/// One card off the deck: how far it is worth, and the question the
/// rider answers for it.
class DrawnCard {
  const DrawnCard({required this.value, required this.question});

  /// 1..6 — the squares the card is worth.
  final int value;

  final Question question;
}

/// The draw pile that replaces the die.
///
/// A turn starts by drawing a card worth 1 to 6 squares. The value is a
/// fair die — picked uniformly, whatever the bank happens to hold — and
/// the question that comes with it is dealt at the rider's own level,
/// chosen before the game: easy, intermediate or expert. The card never
/// decides how hard the question is.
///
/// The deck keeps **one pile per level**, each shuffled once, dealt out,
/// then reshuffled when it runs dry, so a question never repeats until
/// every other card of its level has been seen.
class QuestionDeck {
  QuestionDeck({required List<Question> pool, Random? random})
    : _random = random ?? Random() {
    for (final question in pool) {
      _remaining
          .putIfAbsent(question.difficulty, () => <Question>[])
          .add(question);
      _source
          .putIfAbsent(question.difficulty, () => <Question>[])
          .add(question);
    }
    for (final pile in _remaining.values) {
      pile.shuffle(_random);
    }
  }

  final Random _random;

  /// Cards still to be dealt this cycle, per level.
  final Map<QuestionDifficulty, List<Question>> _remaining = {};

  /// Every card of a level, kept so a spent pile can be refilled.
  final Map<QuestionDifficulty, List<Question>> _source = {};

  /// The levels this deck can actually deal.
  List<QuestionDifficulty> get availableLevels =>
      QuestionDifficulty.values.where(_source.containsKey).toList();

  bool get isEmpty => _source.isEmpty;

  /// The values the deck can produce: always the six faces of a die.
  List<int> get availableValues => const [1, 2, 3, 4, 5, 6];

  /// Draws the next card for a rider playing at [level]: a value chosen
  /// uniformly in 1..6, and the next question off that level's pile.
  ///
  /// A level the bank does not hold falls back to the nearest one it
  /// does, so a turn is never blocked by a thin bank. Returns null only
  /// for a deck built from an empty pool.
  DrawnCard? draw(QuestionDifficulty level) {
    final question = drawQuestion(level);
    if (question == null) return null;
    return DrawnCard(value: 1 + _random.nextInt(6), question: question);
  }

  /// The next question of [level] (or the nearest level held), without
  /// a value — for the questions the board asks outside a draw.
  Question? drawQuestion(QuestionDifficulty level) {
    if (_source.isEmpty) return null;
    final tier = _fallbackOrder(level).firstWhere(_source.containsKey);
    var pile = _remaining[tier];
    if (pile == null || pile.isEmpty) {
      // Every card of this level has been seen: deal the level afresh.
      pile = List<Question>.from(_source[tier]!)..shuffle(_random);
      _remaining[tier] = pile;
    }
    return pile.removeLast();
  }

  /// Preferred level first, then the closest neighbours.
  static List<QuestionDifficulty> _fallbackOrder(QuestionDifficulty level) =>
      switch (level) {
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
}
