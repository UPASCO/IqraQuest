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

/// The draw pile that replaces the die — a *draw without replacement*.
///
/// A turn starts by drawing a card worth 1 to 6 squares. The value is a
/// fair die — picked uniformly, whatever the bank happens to hold — and
/// the question that comes with it is dealt at the rider's own level,
/// chosen before the game: easy, intermediate or expert. The card never
/// decides how hard the question is.
///
/// The deck keeps **one pile per level**, shuffled once at the start of
/// the game and dealt out card by card; a dealt question leaves the pile
/// and cannot come back until every other card of its level has been
/// seen. Only then is the pile dealt afresh — and even then the most
/// recently seen cards are held back from the first hands of the new
/// pile, so a question is never *just* back.
///
/// Dealing is not blind either: the next card is picked from the top
/// few of the pile with a weighted preference for a change of category
/// (Prophets after Qur'an, Sira after Faith…) and of subject (not two
/// Musa cards in a row), so a hundred-card evening feels varied rather
/// than clustered. The order still comes from the shuffle: nothing is
/// predictable, and nothing about the *distance* is ever touched.
///
/// Built for a bank of thousands: every operation is linear in the pile
/// at worst, and the memory it keeps is the bank itself plus a short
/// history.
class QuestionDeck {
  QuestionDeck({
    required List<Question> pool,
    Random? random,
    this.lookahead = 8,
    this.recentMemory = 12,
  }) : _random = random ?? Random() {
    for (final question in pool) {
      _source
          .putIfAbsent(question.difficulty, () => <Question>[])
          .add(question);
    }
    for (final entry in _source.entries) {
      _remaining[entry.key] = [...entry.value]..shuffle(_random);
    }
  }

  final Random _random;

  /// How many cards off the top of a pile are weighed for variety.
  final int lookahead;

  /// How many recently dealt cards are held back when a pile is refilled.
  final int recentMemory;

  /// Cards still to be dealt this cycle, per level.
  final Map<QuestionDifficulty, List<Question>> _remaining = {};

  /// Every card of a level, kept so a spent pile can be refilled.
  final Map<QuestionDifficulty, List<Question>> _source = {};

  /// How many recently seen cards sit at the bottom of a refilled pile:
  /// the deal stays above them while any fresh card remains.
  final Map<QuestionDifficulty, int> _heldAtBottom = {};

  /// The last few categories and subjects dealt, most recent last.
  final List<QuestionCategory> _recentCategories = [];
  final List<String> _recentTopics = [];
  final List<String> _recentIds = [];

  /// The levels this deck can actually deal.
  List<QuestionDifficulty> get availableLevels =>
      QuestionDifficulty.values.where(_source.containsKey).toList();

  bool get isEmpty => _source.isEmpty;

  /// The values the deck can produce: always the six faces of a die.
  List<int> get availableValues => const [1, 2, 3, 4, 5, 6];

  /// Cards of [level] not yet dealt in the current cycle.
  int remainingAt(QuestionDifficulty level) => _remaining[level]?.length ?? 0;

  /// Removes [ids] from every pile — the questions a resumed game has
  /// already asked, so a save never repeats what the players have seen.
  void exclude(Iterable<String> ids) {
    final set = ids.toSet();
    if (set.isEmpty) return;
    for (final pile in _remaining.values) {
      pile.removeWhere((q) => set.contains(q.id));
    }
    _heldAtBottom.clear();
    _recentIds.addAll(set.take(recentMemory));
    _trim(_recentIds, recentMemory);
  }

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
    var pile = _remaining[tier]!;
    if (pile.isEmpty) {
      pile = _refill(tier);
    }
    final index = _pickVaried(pile, _heldAtBottom[tier] ?? 0);
    final question = pile.removeAt(index);
    _remember(question);
    return question;
  }

  /// Every card of this level has been seen: deal the level afresh, the
  /// most recent ones held back to the bottom of the new pile.
  List<Question> _refill(QuestionDifficulty tier) {
    final all = [..._source[tier]!]..shuffle(_random);
    final recent = _recentIds.toSet();
    final fresh = all.where((q) => !recent.contains(q.id)).toList();
    final held = all.where((q) => recent.contains(q.id)).toList();
    // The pile is dealt from its end: fresh cards on top, held-back
    // cards underneath them.
    final pile = [...held, ...fresh];
    _remaining[tier] = pile;
    _heldAtBottom[tier] = fresh.isEmpty ? 0 : held.length;
    return pile;
  }

  /// The index in [pile] of the card to deal: the top few are weighed,
  /// a change of category and of subject wins, and among equals the
  /// shuffle's own order decides.
  int _pickVaried(List<Question> pile, int held) {
    final top = pile.length - 1;
    if (pile.length == 1) return top;
    // Never reach down into the held-back cards while fresh ones remain.
    final fresh = pile.length - held;
    final window = lookahead.clamp(1, fresh > 0 ? fresh : pile.length);
    var bestIndex = top;
    var bestScore = double.negativeInfinity;
    for (var k = 0; k < window; k++) {
      final index = top - k;
      final q = pile[index];
      var score = 0.0;
      final lastCategory = _recentCategories.isEmpty
          ? null
          : _recentCategories.last;
      final beforeLast = _recentCategories.length < 2
          ? null
          : _recentCategories[_recentCategories.length - 2];
      if (q.category == lastCategory) score -= 3;
      if (q.category == beforeLast) score -= 1;
      if (_recentTopics.contains(topicOf(q))) score -= 2;
      // A little noise keeps the tie-break from being the pile order
      // every time, without ever overriding a real preference.
      score += _random.nextDouble() * 0.5;
      if (score > bestScore) {
        bestScore = score;
        bestIndex = index;
      }
    }
    return bestIndex;
  }

  void _remember(Question q) {
    _recentCategories.add(q.category);
    _trim(_recentCategories, 3);
    _recentTopics.add(topicOf(q));
    _trim(_recentTopics, 6);
    _recentIds.add(q.id);
    _trim(_recentIds, recentMemory);
  }

  static void _trim<T>(List<T> list, int max) {
    while (list.length > max) {
      list.removeAt(0);
    }
  }

  /// The subject a question is "about", for the anti-repeat: the first
  /// word of its right answer (a prophet's name, a place, a number), so
  /// three cards whose answer is Musa cannot follow one another.
  static String topicOf(Question q) {
    final answer = q.correctAnswer.toLowerCase();
    final word = answer
        .split(RegExp(r'[\s(\-–—,/]+'))
        .firstWhere((w) => w.isNotEmpty, orElse: () => answer);
    return '${q.category.name}:$word';
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
