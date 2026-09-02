import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/l10n/generated/app_localizations.dart';
import 'package:iqraquest/l10n/generated/app_localizations_fr.dart';
import 'package:iqraquest/models/question.dart';
import 'package:iqraquest/models/question_category.dart';
import 'package:iqraquest/theme/app_theme.dart';
import 'package:iqraquest/widgets/question_card.dart';
import 'package:iqraquest/widgets/question_details_sheet.dart';

/// The game teaches only if the *why* is one tap away after every
/// answer — on the easy level too, where the inline explanation is
/// hidden. "Learn more" must open the lesson: the question, the right
/// answer, the explanation and its source.
final fr = AppLocalizationsFr();

final question = Question(
  id: 'faith_001',
  category: QuestionCategory.faith,
  difficulty: QuestionDifficulty.easy,
  value: 1,
  ageLevel: '7+',
  question: 'Combien y a-t-il de piliers de l\'islam ?',
  answers: const ['Cinq', 'Quatre', 'Six', 'Trois'],
  correctAnswerIndex: 0,
  explanation:
      'Le Prophète ﷺ a dit : « L\'islam est bâti sur cinq piliers. »',
  sourceType: SourceType.hadithBukhari,
  sourceWork: 'Sahih al-Bukhari',
  sourceReference: '8',
  sourceDisplay: 'Sahih al-Bukhari 8',
  sourceVerificationStatus: SourceVerificationStatus.verified,
  consensusStatus: ConsensusStatus.nonControversial,
  isFree: true,
);

Widget host(Widget child) => MaterialApp(
  locale: const Locale('fr'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.light('fr'),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets(
    'the feedback sheet on the easy level still offers the lesson',
    (tester) async {
      await tester.pumpWidget(
        host(
          AnswerFeedbackSheet(
            question: question,
            isCorrect: false,
            showExplanation: false,
            onContinue: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The inline explanation is hidden on this level…
      expect(find.text(question.explanation), findsNothing);
      // …but the "Learn more" link is there.
      final learnMore = find.byKey(const Key('learn-more'));
      expect(learnMore, findsOneWidget);
      expect(find.text(fr.learnMore), findsOneWidget);

      await tester.tap(learnMore);
      await tester.pumpAndSettle();

      final sheet = find.byKey(const Key('question-details'));
      expect(sheet, findsOneWidget);
      expect(find.text(fr.questionDetailsTitle), findsOneWidget);
      expect(
        find.descendant(of: sheet, matching: find.text(question.question)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('Cinq')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sheet,
          matching: find.text(question.explanation),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sheet,
          matching: find.text(question.sourceDisplay),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('question-details-close')));
      await tester.pumpAndSettle();
      expect(sheet, findsNothing);
    },
  );

  testWidgets('the details sheet opens from the standalone button', (
    tester,
  ) async {
    await tester.pumpWidget(host(LearnMoreButton(question: question)));
    await tester.tap(find.byKey(const Key('learn-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('question-details')), findsOneWidget);
    expect(find.text(fr.theAnswerLabel.toUpperCase()), findsOneWidget);
  });
}
