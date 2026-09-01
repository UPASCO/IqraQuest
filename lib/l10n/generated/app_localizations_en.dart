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
  String get outcomeMoved => 'Your horse moves ahead!';

  @override
  String get outcomeStayed => 'Your horse holds its ground. Nothing is lost.';

  @override
  String get outcomeCaptured => 'You overtake an opponent!';

  @override
  String get outcomeShieldBlocked => 'The shield protected the horse.';

  @override
  String get playerProfile => 'Player level';

  @override
  String get profileChild => 'Child';

  @override
  String get profileDiscovery => 'Discovery';

  @override
  String get profileIntermediate => 'Intermediate';

  @override
  String get profileAdvanced => 'Advanced';

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
      'On your turn, draw a card. Its value, 1 to 6, is both how many squares you move and how hard the question is: 1 the easiest, 6 the hardest.';

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
  String get ruleCaptureTitle => 'Overtake and send home';

  @override
  String get ruleCaptureBody =>
      'Landing exactly on an opponent\'s horse sends it calmly back to its stable — unless the square is an oasis, or that horse carries a knowledge shield.';

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
