import 'dart:math';

import '../models/question.dart';

/// The draw pile that replaces the die.
///
/// A turn starts by drawing a question card worth 1 to 6 squares. The
/// value is also the card's difficulty: a 1 is the easiest question and
/// the shortest move, a 6 the hardest and the longest. Answer it and the
/// horse advances by the card's value.
///
/// The deck keeps **one pile per value** rather than a single shuffled
/// stack. That is what makes the draw as fair as a die: the value is
/// picked uniformly first, and only then a question of that value comes
/// off its own pile. A single stack would instead follow whatever mix
/// the bank happens to hold — today 29 questions of value 3 against 12
/// of value 6, which would roll a 3 nearly three times as often as a 6.
///
/// Each pile is shuffled once, dealt out, then reshuffled when it runs
/// dry, so a question never repeats until every other card of its value
/// has been seen.
class QuestionDeck {
  QuestionDeck({required List<Question> pool, Random? random})
    : _random = random ?? Random() {
    for (final question in pool) {
      _remaining.putIfAbsent(question.value, () => <Question>[]).add(question);
      _source.putIfAbsent(question.value, () => <Question>[]).add(question);
    }
    for (final pile in _remaining.values) {
      pile.shuffle(_random);
    }
  }

  final Random _random;

  /// Cards still to be dealt this cycle, per value.
  final Map<int, List<Question>> _remaining = {};

  /// Every card of a value, kept so a spent pile can be refilled.
  final Map<int, List<Question>> _source = {};

  /// The card values this deck can actually produce, ascending.
  ///
  /// A value missing from the bank cannot be drawn, and the draw would
  /// then be a biased die rather than a fair one — the content pipeline
  /// asserts every value has at least one free question so this stays
  /// the full 1..6 in practice.
  List<int> get availableValues => _source.keys.toList()..sort();

  bool get isEmpty => _source.isEmpty;

  /// Draws the next card: a value chosen uniformly, then a question of
  /// that value. Returns null only for a deck built from an empty pool.
  Question? draw() {
    final values = availableValues;
    if (values.isEmpty) return null;

    final value = values[_random.nextInt(values.length)];
    var pile = _remaining[value];
    if (pile == null || pile.isEmpty) {
      // Every card of this value has been seen: deal the value afresh.
      pile = List<Question>.from(_source[value]!)..shuffle(_random);
      _remaining[value] = pile;
    }
    return pile.removeLast();
  }

  /// Draws a card of exactly [value] — used where the rules call for a
  /// specific tier rather than a roll, such as the harder question a
  /// challenge square offers. Returns null if the bank holds no question
  /// of that value.
  Question? drawValue(int value) {
    if (!_source.containsKey(value)) return null;
    var pile = _remaining[value];
    if (pile == null || pile.isEmpty) {
      pile = List<Question>.from(_source[value]!)..shuffle(_random);
      _remaining[value] = pile;
    }
    return pile.removeLast();
  }
}
