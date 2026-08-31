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
      'Answer questions, choose your gait, guide your horse from Makkah to Madinah.';

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
  String get premiumUnlockAll => 'Unlock all 500 questions and every difficulty';

  @override
  String get premiumOneTime => 'One-time payment — no subscription';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get purchaseSuccess => 'Thank you! Premium is now active.';

  @override
  String get purchaseError => 'Purchase couldn\'t be completed. Please try again later.';

  @override
  String get language => 'Language';

  @override
  String get reduceMotion => 'Reduce motion';

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
  String get chooseYourGait => 'Choose your gait';

  @override
  String gaitSquares(int count) {
    return '$count squares';
  }

  @override
  String get gaitAlreadyUsed => 'Already used this cycle';

  @override
  String gaitSemanticLabel(int steps, String difficulty, int points) {
    return 'Move $steps squares, $difficulty question, $points knowledge points';
  }

  @override
  String get selectHorse => 'Choose your horse';

  @override
  String get confirmBoldGait => 'This gait draws a harder question. Continue?';

  @override
  String get knowledgeStreak => 'Knowledge momentum';

  @override
  String get knowledgePointsLabel => 'Knowledge points';

  @override
  String get shieldEarned => 'Shield earned! Your horse is protected.';

  @override
  String get grandGallopEarned => 'Grand Gallop unlocked! +2 squares whenever you choose.';

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
  String get circuitOasisRouteDescription => 'A short, sunlit course. Perfect for a quick game.';

  @override
  String get circuitCaravanTrailDescription => 'Camps and lanterns. A more strategic course.';

  @override
  String get circuitGreatRideDescription => 'From daylight to a starlit sky. The great journey.';

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
  String get cellChallengeOffer => 'Answer a harder question to move 2 extra squares?';

  @override
  String get acceptChallenge => 'Take the challenge';

  @override
  String get declineChallenge => 'Keep my move';

  @override
  String get saveFact => 'Keep this fact';

  @override
  String get journeyQuestion => 'Journey question';

  @override
  String get journeyQuestionIntro => 'One last question to make your arrival official.';

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
      'The dice is gone: you now choose your own gait, and with it your level of risk. Your progress, badges and purchases are all kept — only the game in progress cannot continue under the new rules.';

  @override
  String get startNewRace => 'Start a new race';

  @override
  String get rulesTitle => 'The rules';

  @override
  String get ruleChooseGaitTitle => 'Choose your gait';

  @override
  String get ruleChooseGaitBody =>
      'You decide how far to move, from 1 to 6 squares. The further you go, the harder the question: 1-2 easy, 3-4 medium, 5-6 hard.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Answer to advance';

  @override
  String get ruleAnswerToAdvanceBody =>
      'A correct answer moves your horse exactly the distance you chose. A wrong answer leaves it where it stands — you never go backwards.';

  @override
  String get ruleGaitCycleTitle => 'One gait per cycle';

  @override
  String get ruleGaitCycleBody =>
      'Each gait can be used only once. When all six are spent, the whole set comes back — so plan ahead.';

  @override
  String get ruleCaptureTitle => 'Overtake and send home';

  @override
  String get ruleCaptureBody =>
      'Landing exactly on an opponent\'s horse sends it calmly back to its stable — unless the square is an oasis, or that horse carries a knowledge shield.';

  @override
  String get ruleStreakTitle => 'The knowledge streak';

  @override
  String get ruleStreakBody =>
      'Three correct answers in a row earn a shield, five earn the Grand Gallop (+2 squares), and ten earn a mastery badge. Bonuses come from knowledge alone.';

  @override
  String get ruleArrivalTitle => 'The arrival';

  @override
  String get ruleArrivalBody =>
      'Reach the end of the course — going past the line is fine — then answer the Question of the Journey to make your arrival official. A wrong answer never pushes you back: you simply try again next turn.';
}
