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
  String get onboardingHowTo => 'How it plays';

  @override
  String get onboardingStepDraw => 'Draw a card: it announces its gallops';

  @override
  String get onboardingStepAnswer => 'Answer right: the gallops are yours';

  @override
  String get onboardingStepRide => 'Set a horse down and ride to the oasis';

  @override
  String get onboardingLanguageHint => 'You can change it later in Settings.';

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
  String get hudArrivedHeading => 'Horses home';

  @override
  String get hudKnowledgeShort => 'knowledge';

  @override
  String get hudStreakShort => 'streak';

  @override
  String get hudCardsShort => 'cards';

  @override
  String get boardMenuTitle => 'Game menu';

  @override
  String get boardMenuOpen => 'Open the game menu';

  @override
  String get autoPlaySingleMove => 'Automatic move';

  @override
  String get autoPlaySingleMoveHint =>
      'When only one horse can play the card, it rides by itself.';

  @override
  String get restartRace => 'Restart the race';

  @override
  String get restartRaceConfirm =>
      'The race in progress will be lost. The same riders start again from the stable.';

  @override
  String get backToHome => 'Back to home';

  @override
  String get backToHomeHint => 'The game is saved; you can pick it up again.';

  @override
  String get duoGame => 'Duo game';

  @override
  String horsesToMecca(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horses to Mecca',
      one: '$count horse to Mecca',
    );
    return '$_temp0';
  }

  @override
  String get formatQuickHint => 'The shortest race.';

  @override
  String get formatDuoHint => 'An evening\'s race.';

  @override
  String get formatClassicHint => 'The full game, as in the original.';

  @override
  String get bonusSquaresOption => 'Bonus squares on the course';

  @override
  String get bonusSquaresOn =>
      '16 squares grant an extra ride: +5, +10 or +20.';

  @override
  String get bonusSquaresOff =>
      'A pure ride: a card is worth exactly its gallops.';

  @override
  String get muteSound => 'Mute sound';

  @override
  String get unmuteSound => 'Unmute sound';

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
      other: 'A $count-gallop card',
      one: 'A $count-gallop card',
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
  String moveHintCapture(int value) {
    return 'capture! +$value';
  }

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
      'On your turn, draw a card: its question opens at once, always at your own level — easy, intermediate or expert — chosen at the start. Its value, 1 to 6 squares, stays hidden until you answer.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Answer to advance';

  @override
  String get ruleAnswerToAdvanceBody =>
      'A right answer wins you the card\'s squares. Then choose the horse that takes them: touch it to see where it would land, and drag it there — the drop is the move. A wrong answer leaves everything where it stands: you never go backwards.';

  @override
  String get ruleEscalierTitle => 'The escalier to Mecca';

  @override
  String get ruleEscalierBody =>
      'After a full lap of the board, your horse climbs the five steps of its escalier to Mecca. Once there, no one can catch it.';

  @override
  String get ruleExitTitle => 'Leaving the stable';

  @override
  String get ruleExitBody =>
      'Each player has four horses, and the first is already on its start square: you play from the very first card, with nothing to wait for. The other three leave the stable on a 6: answer correctly and the horse takes the start square — and since a 6 plays again, it rides right away. The choice is yours: bring another out, or ride.';

  @override
  String get ruleSixTitle => 'A 6 plays again';

  @override
  String get ruleSixBody =>
      'Just like the die: when you draw a 6 you play again after your turn, whether your answer was right or not. And two of your own horses can never share a square.';

  @override
  String get ruleCaptureTitle => 'Capture and send home';

  @override
  String get ruleCaptureBody =>
      'Landing exactly on an opponent\'s horse sends it calmly back to its stable — unless the square is an oasis, or that horse carries a knowledge shield. A capture pays: your horse bounds 20 gallops forward at once. A horse leaving its stable always captures on its start square.';

  @override
  String get ruleStreakTitle => 'The knowledge streak';

  @override
  String get ruleStreakBody =>
      'Three correct answers in a row earn a shield, five the Grand Gallop, and ten a mastery badge. The Grand Gallop spends itself, and only when its +2 squares are enough to reach the finish. Bonuses come from knowledge alone.';

  @override
  String get ruleArrivalTitle => 'The arrival';

  @override
  String get ruleArrivalBody =>
      'The finish is reached on an exact count: three squares from the oasis you need exactly a 3. A 4, a 5 or a 6 leaves the horse where it stands, waiting for the right card. Once there, answer the Question of the Journey to make the arrival official; a wrong answer never pushes you back, you simply try again next turn.';

  @override
  String get hapticFeedback => 'Vibration';

  @override
  String squaresWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Won $count gallops',
      one: 'Won $count gallop',
    );
    return '$_temp0';
  }

  @override
  String get chooseHorseToMove => 'Choose a horse';

  @override
  String get touchHorseHint => 'Touch a horse to see where it would go';

  @override
  String get dragHorseToDestination => 'Drag the horse to its golden square';

  @override
  String get bonusLabel => 'BONUS';

  @override
  String bonusPlus(int value) {
    return '+$value gallops';
  }

  @override
  String get captureBonusLabel => 'CAPTURE';

  @override
  String captureBonusRide(int value) {
    return 'Capture! Your horse bounds $value gallops forward.';
  }

  @override
  String bonusRide(int value) {
    return 'Bonus square! Your horse rides on $value more squares.';
  }

  @override
  String cardWasWorth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This card was worth $count gallops.',
      one: 'This card was worth $count gallop.',
    );
    return '$_temp0';
  }

  @override
  String get answerToReveal => 'Answer to reveal its value';

  @override
  String opponentPlaces(String name) {
    return '$name is choosing a horse…';
  }

  @override
  String opponentBonus(String name, int value) {
    return '$name lands a +$value bonus!';
  }

  @override
  String get leaderLabel => 'Leading';

  @override
  String tookTheLead(String name) {
    return '$name takes the lead!';
  }

  @override
  String bonusSquareSemantics(int value) {
    return 'Bonus square +$value';
  }

  @override
  String moveHintBonus(int value) {
    return 'Bonus +$value';
  }

  @override
  String get bonusSquaresTeaser =>
      '16 bonus squares await on the board: +5, +10 and the rare +20.';

  @override
  String get ridersSubtitle =>
      'Every rider picks their level; the card only sets the distance.';

  @override
  String get ruleBonusTitle => 'Bonus squares';

  @override
  String get ruleBonusBody =>
      'Sixteen bonus squares are dealt onto the board each game, four per quarter. A horse that stops exactly on one rides on at once by +5, +10 or +20 gallops — and if that bound sets it down exactly on another bonus square, that one fires too: bonuses chain. Each square pays once per turn, and stays in play for everyone.';
}
