// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'IqraQuest';

  @override
  String get appTagline => 'The journey of knowledge';

  @override
  String get onboardingWelcomeTitle => 'Welcome to IqraQuest';

  @override
  String get onboardingWelcomeSubtitle =>
      'Draw a card, answer, ride on — and bring your horse home to Mecca.';

  @override
  String get getStarted => 'Get started';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get play => 'Play';

  @override
  String get soloMode => 'Solo';

  @override
  String get familyMode => 'Family';

  @override
  String get dailyChallenge => 'Daily Challenge';

  @override
  String get progress => 'Progress';

  @override
  String get settings => 'Settings';

  @override
  String get premium => 'Premium';

  @override
  String get continueGame => 'Continue game';

  @override
  String get quickGame => 'Quick game';

  @override
  String get classicGame => 'Classic game';

  @override
  String get chooseDifficulty => 'Choose difficulty';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get playerName => 'Name';

  @override
  String get chooseTeam => 'Choose team';

  @override
  String get ridersTitle => 'The riders';

  @override
  String get storeLoading => 'Connecting to the store…';

  @override
  String get storeUnavailableCta => 'Store unavailable';

  @override
  String get premiumBenefitBank =>
      'The whole question bank, each with its source';

  @override
  String premiumBenefitUnlimited(int count) {
    return 'Unlimited games, all the way to Mecca (the free edition stops after $count draws)';
  }

  @override
  String get premiumBenefitFamily =>
      'One purchase for the whole family, no ads';

  @override
  String get progressEmpty =>
      'Play a first game: your progress will show up here.';

  @override
  String get addPlayer => 'Add player';

  @override
  String get startGame => 'Start game';

  @override
  String get yourTurn => 'Your turn';

  @override
  String get categoryProphets => 'Prophets';

  @override
  String get categorySira => 'Sira';

  @override
  String get categoryQuran => 'Qur\'an';

  @override
  String get categoryFaith => 'Faith';

  @override
  String get categoryVirtues => 'Virtues';

  @override
  String get category => 'Category';

  @override
  String get correctAnswer => 'Correct!';

  @override
  String get incorrectAnswer => 'Not quite…';

  @override
  String get learnMore => 'Learn more';

  @override
  String get questionDetailsTitle => 'Behind the answer';

  @override
  String get theQuestionLabel => 'The question';

  @override
  String get theAnswerLabel => 'The right answer';

  @override
  String get explanationLabel => 'Explanation';

  @override
  String get sourceLabel => 'Source';

  @override
  String get nextPlayer => 'Next player';

  @override
  String get rolledSix => 'A six! Another turn — a new question.';

  @override
  String get playAgain => 'Play again';

  @override
  String get protectedSquareLabel => 'Protected square';

  @override
  String get freeBankExhaustedMessage =>
      'All the free edition\'s questions have been used for this game.';

  @override
  String get victory => 'Victory!';

  @override
  String get gameOver => 'Game over';

  @override
  String get backToHome => 'Back to home';

  @override
  String get gamesPlayed => 'Games played';

  @override
  String get winRate => 'Win rate';

  @override
  String get questionsAnswered => 'Questions answered';

  @override
  String get streak => 'Day streak';

  @override
  String get premiumTitle => 'IqraQuest Premium';

  @override
  String get premiumUnlockAll =>
      'Unlock the full question bank and every difficulty';

  @override
  String get premiumOneTime => 'One-time payment — no subscription';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get purchaseSuccess => 'Thank you! Premium is now active.';

  @override
  String get purchaseError =>
      'Purchase couldn\'t be completed. Please try again later.';

  @override
  String get language => 'Language';

  @override
  String get reduceMotion => 'Reduce motion';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get howToPlay => 'How to play';

  @override
  String get privacySummary =>
      'IqraQuest runs entirely on your device: no account, no ads, no tracking, and nothing is ever sent over the Internet.';

  @override
  String defaultPlayerName(num number) {
    return 'Player $number';
  }

  @override
  String aiPlayerName(num number) {
    return 'Rider $number';
  }

  @override
  String opponentWins(String name) {
    return '$name wins the race!';
  }

  @override
  String get wellRidden => 'A fine ride — every question learned counts.';

  @override
  String horseSemantics(String color, num number) {
    return '$color horse $number';
  }

  @override
  String get teamEmerald => 'emerald';

  @override
  String get teamSaphir => 'sapphire';

  @override
  String get teamGrenat => 'garnet';

  @override
  String get teamSafran => 'saffron';

  @override
  String premiumCta(String price) {
    return 'Unlock everything — $price';
  }

  @override
  String premiumQuestionsIncluded(num count) {
    return '$count verified questions, each with its source — and the bank keeps growing.';
  }

  @override
  String get darkMode => 'Dark mode';

  @override
  String get about => 'About';

  @override
  String get aboutDialogTitle => 'About IqraQuest';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String copyrightNotice(String year) {
    return '© $year IqraQuest. All rights reserved.';
  }

  @override
  String get originalWorkNotice =>
      'IqraQuest, its game concept, rules, artwork, name and content are original works protected by copyright. Any reproduction, imitation or adaptation, in whole or in part, without written permission is prohibited.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get genericError => 'Something went wrong.';

  @override
  String get parentalGateTitle => 'A question for parents';

  @override
  String get parentalGateInstruction => 'Solve this to continue.';

  @override
  String get placeMecca => 'Mecca';

  @override
  String get placeMedina => 'Medina';

  @override
  String get placeAlAqsa => 'Al-Aqsa';

  @override
  String get placeArafat => 'Mount Arafat';

  @override
  String get placeMina => 'Mina';

  @override
  String circuitSpecialSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count special squares',
      one: '$count special square',
    );
    return '$_temp0';
  }

  @override
  String get drawCard => 'Draw a card';

  @override
  String get drawnCardTitle => 'Card drawn';

  @override
  String cardWorth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Worth $count squares',
      one: 'Worth $count square',
    );
    return '$_temp0';
  }

  @override
  String gaitSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count squares',
      one: '$count square',
    );
    return '$_temp0';
  }

  @override
  String get gaitNameWalk => 'Walk';

  @override
  String get gaitNameTrot => 'Trot';

  @override
  String get gaitNameCanter => 'Canter';

  @override
  String get gaitNameGallop => 'Gallop';

  @override
  String get gaitNameFullGallop => 'Full gallop';

  @override
  String get gaitNameCharge => 'Charge';

  @override
  String get chooseFormat => 'Game format';

  @override
  String get gaitAlreadyUsed => 'Already used this cycle';

  @override
  String gaitSemanticLabel(int steps, String difficulty, int points) {
    return 'Move $steps squares, $difficulty question, $points knowledge points';
  }

  @override
  String get selectHorse => 'Choose your horse';

  @override
  String get knowledgeStreak => 'Knowledge momentum';

  @override
  String get knowledgePointsLabel => 'Knowledge points';

  @override
  String get shieldEarned => 'Shield earned! Your horse is protected.';

  @override
  String get grandGallopEarned =>
      'Grand Gallop unlocked! +2 squares whenever you choose.';

  @override
  String get masteryBadgeEarned => 'Mastery badge earned!';

  @override
  String get useGrandGallop => 'Use the Grand Gallop (+2)';

  @override
  String get chooseCircuit => 'Choose your course';

  @override
  String get circuitOasisRoute => 'The Oasis Road';

  @override
  String get circuitCaravanTrail => 'The Caravan Trail';

  @override
  String get circuitGreatRide => 'The Great Ride of Knowledge';

  @override
  String get circuitOasisRouteDescription =>
      'The calmest ride: oases, and few surprises.';

  @override
  String get circuitCaravanTrailDescription =>
      'Challenges and relays along the way. More tactical.';

  @override
  String get circuitGreatRideDescription =>
      'The liveliest ride: challenges, shortcuts and duels.';

  @override
  String get cellOasis => 'Oasis';

  @override
  String get cellKnowledge => 'Knowledge';

  @override
  String get cellChallenge => 'Challenge';

  @override
  String get cellShortcut => 'Shortcut';

  @override
  String get cellDuel => 'Duel';

  @override
  String get cellWisdom => 'Wisdom';

  @override
  String get cellRelay => 'Relay';

  @override
  String get cellOasisDescription => 'Your horse is safe from capture here.';

  @override
  String get cellChallengeOffer =>
      'Answer a harder question to move 2 extra squares?';

  @override
  String get acceptChallenge => 'Take the challenge';

  @override
  String get declineChallenge => 'Keep my move';

  @override
  String get saveFact => 'Keep this fact';

  @override
  String get journeyQuestion => 'Journey question';

  @override
  String get journeyQuestionIntro =>
      'One last question to make your arrival official.';

  @override
  String opponentThinking(String name) {
    return '$name is thinking…';
  }

  @override
  String opponentDrew(String name, int count) {
    return '$name draws a $count';
  }

  @override
  String correctAnswerWas(String answer) {
    return 'The right answer: $answer';
  }

  @override
  String get scoreboardTitle => 'Race board';

  @override
  String scoreboardCorrect(int count) {
    return '$count correct';
  }

  @override
  String scoreboardBestStreak(int count) {
    return 'streak of $count';
  }

  @override
  String get playAgainSameRiders => 'Race again!';

  @override
  String opponentMoved(String name) {
    return '$name moves ahead!';
  }

  @override
  String opponentStayed(String name) {
    return '$name holds its ground.';
  }

  @override
  String get shareScore => 'Share';

  @override
  String shareVictoryText(String name, int points) {
    return '$name won the IqraQuest race with $points ⭐! Your turn?';
  }

  @override
  String shareDailyText(int score, int total) {
    return '$score/$total on today\'s IqraQuest challenge! Can you beat it?';
  }

  @override
  String get dailyChallengeDone => 'Today\'s challenge done';

  @override
  String dailyChallengeScore(num score, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score right out of $total',
      one: '$score right out of $total',
      zero: 'None right out of $total',
    );
    return '$_temp0';
  }

  @override
  String get dailyChallengeComeBack => 'Come back tomorrow for a new one.';

  @override
  String get aiOpponentsLabel => 'Opponents';

  @override
  String get playersLabel => 'Players';

  @override
  String get outcomeMoved => 'Your horse moves ahead!';

  @override
  String get outcomeStayed => 'Your horse holds its ground. Nothing is lost.';

  @override
  String get outcomeCaptured => 'You capture an opponent\'s horse!';

  @override
  String get outcomeExited => 'Your horse leaves the stable!';

  @override
  String get outcomeNoLegalMove =>
      'This card can\'t move any horse. Next turn!';

  @override
  String get noExitHint => 'You need a 6 to bring a horse out of the stable.';

  @override
  String get bonusTurnHint => 'Bonus turn: the 6 lets you play again!';

  @override
  String get celebrateSixTitle => 'SIX!';

  @override
  String get celebrateSixBody => 'You\'ll draw again after this turn.';

  @override
  String get celebrateSixExitBody =>
      'A horse can come out — and you\'ll play again!';

  @override
  String get celebrateExitTitle => 'Gate open!';

  @override
  String get celebrateExitBody => 'A horse can leave the stable.';

  @override
  String get celebrateCaptureTitle => 'Captured!';

  @override
  String get celebrateCaptureBody =>
      'The opponent\'s horse goes back to its stable.';

  @override
  String get celebrateCapturedTitle => 'Caught…';

  @override
  String get celebrateCapturedBody =>
      'Your horse goes back to the stable. A 6 brings it out again.';

  @override
  String get celebrateArrivalTitle => 'Mecca!';

  @override
  String get celebrateArrivalBody =>
      'Your horse has arrived. One last question to make it official!';

  @override
  String get freeLimitTitle => 'End of the free race';

  @override
  String freeLimitLeader(String name) {
    return 'In the lead: $name';
  }

  @override
  String freeLimitBody(int count) {
    return 'The free edition stops after $count draws. With Premium, the race runs all the way to Mecca.';
  }

  @override
  String get freeLimitCta => 'Unlock the unlimited race';

  @override
  String drawsCounter(int count, int max) {
    return 'Draws: $count of $max';
  }

  @override
  String moveChoiceTitle(int count) {
    return 'What will you do with this $count?';
  }

  @override
  String get moveChoiceExit => 'Bring a horse out of the stable';

  @override
  String moveChoiceAdvance(int number, int count) {
    return 'Horse $number: ride $count ahead';
  }

  @override
  String get moveHintCapture => 'capture!';

  @override
  String get moveHintFinish => 'finish!';

  @override
  String get moveHintOasis => 'oasis';

  @override
  String opponentExits(String name) {
    return '$name brings a horse out!';
  }

  @override
  String opponentNoMove(String name) {
    return '$name can\'t move anything.';
  }

  @override
  String opponentReplays(String name) {
    return '$name drew a 6 and plays again!';
  }

  @override
  String opponentCaptured(String name) {
    return '$name captures a horse!';
  }

  @override
  String get outcomeShieldBlocked => 'The shield protected the horse.';

  @override
  String get playerProfile => 'Question level';

  @override
  String get levelEasy => 'Easy';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelExpert => 'Expert';

  @override
  String get raceRulesUpdatedTitle => 'The race rules have been improved';

  @override
  String get raceRulesUpdatedBody =>
      'The rules have changed: you now draw a card, and its value gives both the distance and the difficulty. Your progress, badges and purchases are kept — only the game in progress cannot resume under the new rules.';

  @override
  String get startNewRace => 'Start a new race';

  @override
  String get rulesTitle => 'The rules';

  @override
  String get ruleDrawCardTitle => 'Draw a card';

  @override
  String get ruleDrawCardBody =>
      'On your turn, draw a card. Its value, 1 to 6, is how many squares you move. The question is always at your own level — easy, intermediate or expert — chosen at the start for every card you draw.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Answer to advance';

  @override
  String get ruleAnswerToAdvanceBody =>
      'A right answer moves your horse exactly the number of squares on the card. A wrong one leaves it where it stands: you never go backwards.';

  @override
  String get ruleEscalierTitle => 'The escalier to Mecca';

  @override
  String get ruleEscalierBody =>
      'After a full lap of the board, your horse climbs the five steps of its escalier to Mecca. Once there, no one can catch it.';

  @override
  String get ruleExitTitle => 'Leaving the stable';

  @override
  String get ruleExitBody =>
      'Each player has four horses in the stable. A horse comes out only on a 6: answer correctly and it takes its start square — and since a 6 plays again, it rides right away. If you already have a horse on the course, you choose: bring another out, or ride.';

  @override
  String get ruleSixTitle => 'A 6 plays again';

  @override
  String get ruleSixBody =>
      'Just like the die: when you draw a 6 you play again after your turn, whether your answer was right or not. And two of your own horses can never share a square.';

  @override
  String get ruleCaptureTitle => 'Capture and send home';

  @override
  String get ruleCaptureBody =>
      'Landing exactly on an opponent\'s horse sends it calmly back to its stable — unless the square is an oasis, or that horse carries a knowledge shield. A horse leaving its stable always captures on its start square.';

  @override
  String get ruleStreakTitle => 'The knowledge streak';

  @override
  String get ruleStreakBody =>
      'Three correct answers in a row earn a shield, five the Grand Gallop, and ten a mastery badge. The Grand Gallop spends itself, and only when its +2 squares are enough to reach the finish. Bonuses come from knowledge alone.';

  @override
  String get ruleArrivalTitle => 'The arrival';

  @override
  String get ruleArrivalBody =>
      'Reach the end of the course — going past the line is fine — then answer the Question of the Journey to make your arrival official. A wrong answer never pushes you back: you simply try again next turn.';
}
