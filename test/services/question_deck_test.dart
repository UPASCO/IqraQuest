import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/models/question.dart';
import 'package:iqraquest/models/question_category.dart';
import 'package:iqraquest/services/question_deck.dart';

Question q(String id, QuestionDifficulty difficulty) => Question(
  id: id,
  category: QuestionCategory.faith,
  difficulty: difficulty,
  value: 1,
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

/// A bank shaped like the real one: far more mid-level questions than
/// expert ones. The die must NOT inherit that skew, and a rider must
/// only ever be asked at their own level.
List<Question> lopsidedPool() => [
  for (var i = 0; i < 5; i++) q('e_$i', QuestionDifficulty.easy),
  for (var i = 0; i < 57; i++) q('m_$i', QuestionDifficulty.medium),
  for (var i = 0; i < 3; i++) q('h_$i', QuestionDifficulty.hard),
];

void main() {
  group('QuestionDeck', () {
    test('the die has six faces whatever the bank holds', () {
      final deck = QuestionDeck(pool: lopsidedPool(), random: Random(7));
      expect(deck.availableValues, [1, 2, 3, 4, 5, 6]);
      expect(deck.availableLevels, QuestionDifficulty.values);
    });

    test('the drawn value is uniform across 1..6, at every level', () {
      final deck = QuestionDeck(pool: lopsidedPool(), random: Random(42));
      for (final level in QuestionDifficulty.values) {
        final counts = <int, int>{for (var v = 1; v <= 6; v++) v: 0};
        const draws = 6000;
        for (var i = 0; i < draws; i++) {
          final card = deck.draw(level)!;
          counts[card.value] = counts[card.value]! + 1;
        }
        const expected = draws / 6;
        for (var v = 1; v <= 6; v++) {
          expect(
            (counts[v]! - expected).abs() / expected,
            lessThan(0.15),
            reason:
                '$level: value $v came up ${counts[v]} times, expected about $expected',
          );
        }
      }
    });

    test('the question is always at the level asked for, whatever the value', () {
      final deck = QuestionDeck(pool: lopsidedPool(), random: Random(3));
      for (final level in QuestionDifficulty.values) {
        for (var i = 0; i < 40; i++) {
          final card = deck.draw(level)!;
          expect(
            card.question.difficulty,
            level,
            reason:
                'a $level rider drew a ${card.question.difficulty} question on a ${card.value}',
          );
        }
      }
    });

    test('a level does not repeat a question until its pile is spent', () {
      final deck = QuestionDeck(pool: lopsidedPool(), random: Random(3));
      // The hard pile holds exactly three questions, so three
      // consecutive expert draws must all be different.
      final seen = <String>{};
      for (var i = 0; i < 3; i++) {
        final card = deck.draw(QuestionDifficulty.hard)!;
        expect(
          seen.add(card.question.id),
          isTrue,
          reason: '${card.question.id} repeated early',
        );
      }
      // The fourth draw reshuffles and may legitimately repeat.
      expect(deck.draw(QuestionDifficulty.hard), isNotNull);
    });

    test('a spent pile refills instead of running dry', () {
      final deck = QuestionDeck(
        pool: [q('only', QuestionDifficulty.hard)],
        random: Random(1),
      );
      for (var i = 0; i < 5; i++) {
        expect(deck.draw(QuestionDifficulty.hard)?.question.id, 'only');
      }
    });

    test('a level the bank does not hold falls back to the nearest one', () {
      final deck = QuestionDeck(
        pool: [
          q('a', QuestionDifficulty.easy),
          q('b', QuestionDifficulty.medium),
        ],
        random: Random(1),
      );
      expect(deck.availableLevels, [
        QuestionDifficulty.easy,
        QuestionDifficulty.medium,
      ]);
      expect(
        deck.draw(QuestionDifficulty.hard)!.question.difficulty,
        QuestionDifficulty.medium,
      );
    });

    test('an empty pool draws nothing rather than throwing', () {
      final deck = QuestionDeck(pool: const [], random: Random(1));
      expect(deck.isEmpty, isTrue);
      expect(deck.draw(QuestionDifficulty.easy), isNull);
      expect(deck.drawQuestion(QuestionDifficulty.medium), isNull);
    });
  });
}
