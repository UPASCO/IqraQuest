import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/models/question.dart';
import 'package:iqraquest/models/question_category.dart';
import 'package:iqraquest/services/question_deck.dart';

Question q(String id, int value) => Question(
  id: id,
  category: QuestionCategory.faith,
  difficulty: switch (value) {
    1 || 2 => QuestionDifficulty.easy,
    3 || 4 => QuestionDifficulty.medium,
    _ => QuestionDifficulty.hard,
  },
  value: value,
  ageLevel: '7+',
  question: 'q$id',
  answers: const ['a', 'b', 'c', 'd'],
  correctAnswerIndex: 0,
  explanation: 'e',
  sourceType: SourceType.quran,
  sourceWork: 'w',
  sourceReference: 'r',
  sourceDisplay: 'd',
  sourceVerificationStatus: SourceVerificationStatus.verified,
  consensusStatus: ConsensusStatus.nonControversial,
  isFree: true,
);

/// A bank shaped like the real one: far more mid-value questions than
/// high-value ones. Drawing must NOT inherit that skew.
List<Question> lopsidedPool() => [
  for (var i = 0; i < 2; i++) q('v1_$i', 1),
  for (var i = 0; i < 3; i++) q('v2_$i', 2),
  for (var i = 0; i < 29; i++) q('v3_$i', 3),
  for (var i = 0; i < 28; i++) q('v4_$i', 4),
  for (var i = 0; i < 2; i++) q('v5_$i', 5),
  q('v6_0', 6),
];

void main() {
  group('QuestionDeck', () {
    test('every value 1..6 can be drawn', () {
      final deck = QuestionDeck(pool: lopsidedPool(), random: Random(7));
      expect(deck.availableValues, [1, 2, 3, 4, 5, 6]);
    });

    test('the drawn value is uniform across 1..6', () {
      // 29 questions of value 3 against 1 of value 6: a single shuffled
      // stack would roll a 3 twenty-nine times as often. The deck has to
      // behave like a fair die instead.
      final deck = QuestionDeck(pool: lopsidedPool(), random: Random(42));
      final counts = <int, int>{for (var v = 1; v <= 6; v++) v: 0};
      const draws = 6000;
      for (var i = 0; i < draws; i++) {
        final card = deck.draw()!;
        counts[card.value] = counts[card.value]! + 1;
      }
      const expected = draws / 6;
      for (var v = 1; v <= 6; v++) {
        expect(
          (counts[v]! - expected).abs() / expected,
          lessThan(0.15),
          reason: 'value $v came up ${counts[v]} times, expected about $expected',
        );
      }
    });

    test('a value does not repeat a question until its pile is spent', () {
      final deck = QuestionDeck(pool: lopsidedPool(), random: Random(3));
      // Value 2 holds exactly three questions, so three consecutive
      // draws of that value must all be different.
      final seen = <String>{};
      for (var i = 0; i < 3; i++) {
        final card = deck.drawValue(2)!;
        expect(seen.add(card.id), isTrue, reason: '${card.id} repeated early');
      }
      // The fourth draw reshuffles and may legitimately repeat.
      expect(deck.drawValue(2), isNotNull);
    });

    test('a spent pile refills instead of running dry', () {
      final deck = QuestionDeck(pool: [q('only', 6)], random: Random(1));
      for (var i = 0; i < 5; i++) {
        expect(deck.drawValue(6)?.id, 'only');
      }
    });

    test('an empty pool draws nothing rather than throwing', () {
      final deck = QuestionDeck(pool: const [], random: Random(1));
      expect(deck.isEmpty, isTrue);
      expect(deck.draw(), isNull);
      expect(deck.drawValue(3), isNull);
    });

    test('a value absent from the bank is never offered', () {
      final deck = QuestionDeck(pool: [q('a', 1), q('b', 4)], random: Random(1));
      expect(deck.availableValues, [1, 4]);
      expect(deck.drawValue(6), isNull);
      for (var i = 0; i < 50; i++) {
        expect([1, 4], contains(deck.draw()!.value));
      }
    });
  });
}
