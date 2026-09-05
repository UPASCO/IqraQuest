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
  for (var i = 0; i < 4; i++) q('b_$i', QuestionDifficulty.beginner),
  for (var i = 0; i < 5; i++) q('e_$i', QuestionDifficulty.easy),
  for (var i = 0; i < 57; i++) q('m_$i', QuestionDifficulty.medium),
  for (var i = 0; i < 3; i++) q('h_$i', QuestionDifficulty.hard),
];

void main() {
  deckVarietyTests();
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

Question tagged(String id, QuestionCategory category, String answer) => Question(
  id: id,
  category: category,
  difficulty: QuestionDifficulty.medium,
  value: 1,
  ageLevel: '7+',
  question: 'q$id',
  answers: [answer, 'b', 'c', 'd'],
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

/// A bank built for thousands: no naive random, no early repeat, a
/// change of theme from one card to the next, and a resumed game that
/// never re-asks what it already asked.
void deckVarietyTests() {
  group('QuestionDeck — variety and memory', () {
    test('a category never runs three cards in a row when it can be helped', () {
      // Four categories, evenly held: a blind shuffle would run the same
      // category three times in a row often; the weighted deal must not.
      final pool = <Question>[];
      final categories = QuestionCategory.values.take(4).toList();
      for (var i = 0; i < 200; i++) {
        pool.add(tagged('v$i', categories[i % 4], 'answer$i'));
      }
      final deck = QuestionDeck(pool: pool, random: Random(11));
      var triples = 0;
      var pairs = 0;
      QuestionCategory? last, beforeLast;
      for (var i = 0; i < 200; i++) {
        final q = deck.drawQuestion(QuestionDifficulty.medium)!;
        if (q.category == last) pairs++;
        if (q.category == last && q.category == beforeLast) triples++;
        beforeLast = last;
        last = q.category;
      }
      expect(triples, 0, reason: 'three cards of one category in a row');
      // A blind shuffle repeats the category about a quarter of the time;
      // the weighted deal far less.
      expect(pairs, lessThan(20), reason: '$pairs same-category pairs in 200');
    });

    test('the same subject is not asked twice within a few cards', () {
      final pool = <Question>[];
      for (var i = 0; i < 120; i++) {
        // Twelve subjects, ten cards each — a real bank's shape.
        pool.add(tagged('s$i', QuestionCategory.values[i % 3], 'Subject${i % 12} more'));
      }
      final deck = QuestionDeck(pool: pool, random: Random(5));
      final recent = <String>[];
      var clashes = 0;
      for (var i = 0; i < 120; i++) {
        final topic = QuestionDeck.topicOf(deck.drawQuestion(QuestionDifficulty.medium)!);
        if (recent.contains(topic)) clashes++;
        recent.add(topic);
        if (recent.length > 3) recent.removeAt(0);
      }
      expect(clashes, lessThan(6), reason: '$clashes subject repeats within three cards');
    });

    test('a resumed game excludes what it already asked', () {
      final pool = [for (var i = 0; i < 30; i++) q('m_$i', QuestionDifficulty.medium)];
      final deck = QuestionDeck(pool: pool, random: Random(2));
      final asked = {for (var i = 0; i < 20; i++) 'm_$i'};
      deck.exclude(asked);
      expect(deck.remainingAt(QuestionDifficulty.medium), 10);
      for (var i = 0; i < 10; i++) {
        final id = deck.drawQuestion(QuestionDifficulty.medium)!.id;
        expect(asked.contains(id), isFalse, reason: '$id was already asked');
      }
    });

    test('when a pile is dealt afresh, the last cards seen come last', () {
      final pool = [for (var i = 0; i < 30; i++) q('m_$i', QuestionDifficulty.medium)];
      final deck = QuestionDeck(pool: pool, random: Random(9), recentMemory: 12);
      final order = <String>[];
      for (var i = 0; i < 30; i++) {
        order.add(deck.drawQuestion(QuestionDifficulty.medium)!.id);
      }
      final lastTwelve = order.sublist(18).toSet();
      // The pile is spent: the next eighteen cards are the ones seen
      // longest ago, never one of the twelve just seen.
      for (var i = 0; i < 18; i++) {
        final id = deck.drawQuestion(QuestionDifficulty.medium)!.id;
        expect(lastTwelve.contains(id), isFalse, reason: '$id came straight back');
      }
    });

    test('dealing scales: five thousand cards, ten thousand draws, fast', () {
      final pool = [
        for (var i = 0; i < 5000; i++)
          tagged('big$i', QuestionCategory.values[i % QuestionCategory.values.length], 'Topic${i % 400}'),
      ];
      final deck = QuestionDeck(pool: pool, random: Random(1));
      final watch = Stopwatch()..start();
      final seen = <String>{};
      for (var i = 0; i < 5000; i++) {
        expect(seen.add(deck.drawQuestion(QuestionDifficulty.medium)!.id), isTrue);
      }
      for (var i = 0; i < 5000; i++) {
        deck.drawQuestion(QuestionDifficulty.medium);
      }
      watch.stop();
      expect(watch.elapsedMilliseconds, lessThan(4000));
    });
  });
}
