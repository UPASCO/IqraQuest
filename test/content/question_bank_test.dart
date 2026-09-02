import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

import 'package:iqraquest/models/question_category.dart';
import 'package:iqraquest/services/question_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repo = QuestionRepository();

  for (final lang in QuestionRepository.supportedContentLanguages) {
    group('Question bank ($lang)', () {
      late final Future<void> ready;

      setUpAll(() {
        ready = repo.loadAll(lang);
      });

      test('loads with no crash and every question is verified + non-controversial', () async {
        await ready;
        final questions = await repo.loadAll(lang);
        expect(questions, isNotEmpty);
        for (final q in questions) {
          expect(q.sourceVerificationStatus, SourceVerificationStatus.verified);
          expect(q.consensusStatus, ConsensusStatus.nonControversial);
          expect(q.answers, hasLength(4));
          expect(q.answers.every((a) => a.trim().isNotEmpty), isTrue);
          expect(q.question.trim(), isNotEmpty);
          expect(q.explanation.trim(), isNotEmpty);
          expect(q.sourceDisplay.trim(), isNotEmpty);
          expect(q.sourceReference.trim(), isNotEmpty);
        }
      });

      test('ids are unique', () async {
        final questions = await repo.loadAll(lang);
        final ids = questions.map((q) => q.id).toList();
        expect(ids.toSet().length, ids.length);
      });

      test('covers every category', () async {
        final questions = await repo.loadAll(lang);
        final categories = questions.map((q) => q.category).toSet();
        expect(categories, QuestionCategory.values.toSet());
      });

      test('has both free and premium questions', () async {
        final questions = await repo.loadAll(lang);
        expect(questions.any((q) => q.isFree), isTrue);
        expect(questions.any((q) => !q.isFree), isTrue);
      });
    });
  }

  group('Cross-language parity', () {
    test('every language exposes exactly the same question ids', () async {
      final fr = (await repo.loadAll('fr')).map((q) => q.id).toSet();
      for (final lang in QuestionRepository.supportedContentLanguages) {
        final ids = (await QuestionRepository().loadAll(lang)).map((q) => q.id).toSet();
        expect(ids, fr, reason: lang);
      }
    });

    test('the correct answer index is identical across languages for every id', () async {
      final fr = {
        for (final q in await QuestionRepository().loadAll('fr')) q.id: q.correctAnswerIndex,
      };
      final en = {
        for (final q in await QuestionRepository().loadAll('en')) q.id: q.correctAnswerIndex,
      };
      final ar = {
        for (final q in await QuestionRepository().loadAll('ar')) q.id: q.correctAnswerIndex,
      };
      for (final id in fr.keys) {
        expect(en[id], fr[id], reason: id);
        expect(ar[id], fr[id], reason: id);
      }
    });
  });

  group('Selection logic', () {
    test('an unauthenticated (free) player never receives a Premium-only question', () async {
      final questions = await repo.loadAll('en');
      final asked = <String>{};
      for (var i = 0; i < 200; i++) {
        final q = repo.pickQuestion(pool: questions, askedQuestionIds: asked, isPremium: false);
        if (q == null) break;
        expect(q.isFree, isTrue);
        asked.add(q.id);
      }
    });

    test('no question is ever repeated within the same askedQuestionIds set', () async {
      final questions = await repo.loadAll('en');
      final asked = <String>{};
      for (var i = 0; i < questions.length; i++) {
        final q = repo.pickQuestion(pool: questions, askedQuestionIds: asked, isPremium: true);
        if (q == null) break;
        expect(asked.contains(q.id), isFalse);
        asked.add(q.id);
      }
    });

    test('free bank exhaustion is detected once every free question is asked', () async {
      final questions = await repo.loadAll('en');
      final freeIds = questions.where((q) => q.isFree).map((q) => q.id).toSet();
      expect(repo.isFreeBankExhausted(pool: questions, askedQuestionIds: freeIds), isTrue);
      expect(repo.isFreeBankExhausted(pool: questions, askedQuestionIds: {}), isFalse);
    });
  });

  group('Answer display order', () {
    test('shuffling keeps the right answer right and varies its position', () async {
      final questions = await repo.loadAll('en');
      // Authoring convention: canonical data stores the correct answer
      // first, which is exactly why draws must shuffle.
      expect(questions.every((q) => q.correctAnswerIndex == 0), isTrue);

      final rng = Random(7);
      final positions = <int>{};
      for (final q in questions) {
        final shuffled = q.withShuffledAnswers(rng);
        positions.add(shuffled.correctAnswerIndex);
        expect(shuffled.correctAnswer, q.correctAnswer,
            reason: 'the marked answer must stay the true one');
        expect(shuffled.answers.toSet(), q.answers.toSet());
        expect(shuffled.isCorrect(shuffled.correctAnswerIndex), isTrue);
      }
      expect(positions.length, 4,
          reason: 'across the bank the right answer must land on every slot');
    });
  });
}
