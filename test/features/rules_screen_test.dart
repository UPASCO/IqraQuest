// The rules screen is the only place a player can go to understand the
// game, and it is now one tap from the board. So it has to be complete
// and it has to be current.
//
// It was neither: it opened on "draw a card" and never said anywhere how
// the game is won, and its first step still promised that a card hides
// its value — which stopped being true when the card started announcing
// its stake.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/tutorial/presentation/tutorial_screen.dart';
import 'package:iqraquest/l10n/generated/app_localizations.dart';
import 'package:iqraquest/l10n/generated/app_localizations_en.dart';
import 'package:iqraquest/l10n/generated/app_localizations_fr.dart';
import 'package:iqraquest/theme/app_theme.dart';

Future<void> _pumpRules(WidgetTester tester, {Locale locale = const Locale('fr')}) async {
  tester.view.physicalSize = const Size(420, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light('fr'),
      home: const TutorialScreen(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  final fr = AppLocalizationsFr();
  final en = AppLocalizationsEn();

  testWidgets('the rules open on how the race is won', (tester) async {
    await _pumpRules(tester);
    final goal = find.text(fr.ruleGoalTitle);
    expect(goal, findsOneWidget, reason: 'the goal of the game is not stated');
    // First on the page, not buried: a player who reads one step must
    // read the one that says what they are racing for.
    final goalTop = tester.getRect(goal).top;
    for (final other in [
      fr.ruleDrawCardTitle,
      fr.ruleAnswerToAdvanceTitle,
      fr.ruleExitTitle,
    ]) {
      expect(
        tester.getRect(find.text(other)).top,
        greaterThan(goalTop),
        reason: '"$other" comes before the goal',
      );
    }
    // And it names the three finish lines a table can pick.
    expect(fr.ruleGoalBody, contains('quatre chevaux'));
    expect(fr.ruleGoalBody, contains('rapide'));
    expect(fr.ruleGoalBody, contains('duo'));
    expect(fr.ruleGoalBody, contains('classique'));
  });

  testWidgets('every step of a turn has a rule, in the order it happens', (
    tester,
  ) async {
    await _pumpRules(tester);
    final order = [
      fr.ruleGoalTitle,
      fr.ruleDrawCardTitle,
      fr.ruleAnswerToAdvanceTitle,
      fr.ruleExitTitle,
      fr.ruleSixTitle,
      fr.ruleBonusTitle,
      fr.ruleSpecialCellsTitle,
      fr.ruleCaptureTitle,
      fr.ruleEscalierTitle,
      fr.ruleArrivalTitle,
      fr.ruleStreakTitle,
      fr.ruleKnowledgeTitle,
    ];
    var previous = double.negativeInfinity;
    for (final title in order) {
      final finder = find.text(title);
      expect(finder, findsOneWidget, reason: '"$title" is missing');
      final top = tester.getRect(finder).top;
      expect(top, greaterThan(previous), reason: '"$title" is out of order');
      previous = top;
    }
  });

  test('no rule still claims the card hides what it is worth', () {
    // The card announces its stake as it turns over; the old text
    // promised the opposite, which is worse than saying nothing.
    for (final l10n in <AppLocalizations>[fr, en]) {
      expect(
        l10n.ruleDrawCardBody.toLowerCase(),
        isNot(anyOf(contains('cachée'), contains('hidden'))),
      );
    }
    expect(fr.ruleDrawCardBody, contains('galops'));
    expect(en.ruleDrawCardBody.toLowerCase(), contains('gallop'));
  });

  test('the three HUD counters each have a rule that explains them', () {
    // Whatever the player sees in the bar, they can look it up.
    expect(fr.ruleKnowledgeBody, contains('points de savoir'));
    expect(fr.ruleStreakBody, contains("d'affilée"));
    expect(fr.ruleGoalBody, contains('La Mecque'));
  });

  test('a ride is counted in gallops, and the finish is Mecca', () {
    // One unit for what a card is worth, one destination for the race.
    expect(fr.ruleStreakBody, contains('+2 galops'));
    expect(fr.ruleSpecialCellsBody, contains('+2 galops'));
    expect(fr.ruleArrivalBody, contains('La Mecque'));
    expect(
      fr.ruleArrivalBody,
      isNot(contains("de l'oasis")),
      reason: 'the oasis is a kind of square, not the finish line',
    );
  });

  test('the bonus squares are described as the option they now are', () {
    expect(fr.ruleBonusBody, contains('Si la table les garde'));
    expect(fr.ruleBonusBody, contains("s'enchaînent"));
    expect(fr.ruleCaptureBody, contains('20 galops'));
  });
}
