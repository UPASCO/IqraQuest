import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('it'),
    Locale('ms'),
    Locale('nl'),
    Locale('pt'),
    Locale('tr'),
    Locale('ur'),
  ];

  /// Application name, unchanged across locales
  ///
  /// In en, this message translates to:
  /// **'IqraQuest'**
  String get appName;

  /// Home screen tagline under the logo
  ///
  /// In en, this message translates to:
  /// **'The journey of knowledge'**
  String get appTagline;

  /// Onboarding first screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome to IqraQuest'**
  String get onboardingWelcomeTitle;

  /// Onboarding first screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Answer questions, choose your gait, guide your horse from Makkah to Madinah.'**
  String get onboardingWelcomeSubtitle;

  /// Primary CTA button on onboarding
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// Language picker label
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// Primary home screen action
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Home screen mode option
  ///
  /// In en, this message translates to:
  /// **'Solo'**
  String get soloMode;

  /// Home screen mode option
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get familyMode;

  /// Home screen menu item
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallenge;

  /// Home screen menu item
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Home screen menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Home screen menu item / badge
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// Resume a saved game
  ///
  /// In en, this message translates to:
  /// **'Continue game'**
  String get continueGame;

  /// Game variant: 1 pawn per player
  ///
  /// In en, this message translates to:
  /// **'Quick game'**
  String get quickGame;

  /// Game variant: 4 pawns per player
  ///
  /// In en, this message translates to:
  /// **'Classic game'**
  String get classicGame;

  /// AI difficulty picker label
  ///
  /// In en, this message translates to:
  /// **'Choose difficulty'**
  String get chooseDifficulty;

  /// AI/quiz difficulty level
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// AI/quiz difficulty level
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// AI/quiz difficulty level
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// Player name input label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get playerName;

  /// Team/color picker label
  ///
  /// In en, this message translates to:
  /// **'Choose team'**
  String get chooseTeam;

  /// Add another player button
  ///
  /// In en, this message translates to:
  /// **'Add player'**
  String get addPlayer;

  /// Confirm player setup and begin
  ///
  /// In en, this message translates to:
  /// **'Start game'**
  String get startGame;

  /// Turn banner
  ///
  /// In en, this message translates to:
  /// **'Your turn'**
  String get yourTurn;

  /// Question category name
  ///
  /// In en, this message translates to:
  /// **'Prophets'**
  String get categoryProphets;

  /// Question category name (biography of the Prophet)
  ///
  /// In en, this message translates to:
  /// **'Sira'**
  String get categorySira;

  /// Question category name
  ///
  /// In en, this message translates to:
  /// **'Qur\'an'**
  String get categoryQuran;

  /// Question category name
  ///
  /// In en, this message translates to:
  /// **'Faith'**
  String get categoryFaith;

  /// Question category name
  ///
  /// In en, this message translates to:
  /// **'Virtues'**
  String get categoryVirtues;

  /// Question card: category label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Feedback: correct
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correctAnswer;

  /// Feedback: incorrect
  ///
  /// In en, this message translates to:
  /// **'Not quite…'**
  String get incorrectAnswer;

  /// Question card section header
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanationLabel;

  /// Question card section header
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceLabel;

  /// Turn transition button
  ///
  /// In en, this message translates to:
  /// **'Next player'**
  String get nextPlayer;

  /// Message shown when a 6 grants another turn
  ///
  /// In en, this message translates to:
  /// **'A six! Another turn — a new question.'**
  String get rolledSix;

  /// Post-game button
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgain;

  /// Board legend for a safe square
  ///
  /// In en, this message translates to:
  /// **'Protected square'**
  String get protectedSquareLabel;

  /// Shown once the free question bank runs out mid-game
  ///
  /// In en, this message translates to:
  /// **'All the free edition\'s questions have been used for this game.'**
  String get freeBankExhaustedMessage;

  /// Win screen title
  ///
  /// In en, this message translates to:
  /// **'Victory!'**
  String get victory;

  /// End-of-game screen title (generic)
  ///
  /// In en, this message translates to:
  /// **'Game over'**
  String get gameOver;

  /// Navigation button back to home screen
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// Progress stat label
  ///
  /// In en, this message translates to:
  /// **'Games played'**
  String get gamesPlayed;

  /// Progress stat label
  ///
  /// In en, this message translates to:
  /// **'Win rate'**
  String get winRate;

  /// Progress stat label
  ///
  /// In en, this message translates to:
  /// **'Questions answered'**
  String get questionsAnswered;

  /// Progress stat label: daily streak
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get streak;

  /// Premium sheet title
  ///
  /// In en, this message translates to:
  /// **'IqraQuest Premium'**
  String get premiumTitle;

  /// Premium sheet value proposition
  ///
  /// In en, this message translates to:
  /// **'Unlock all 500 questions and every difficulty'**
  String get premiumUnlockAll;

  /// Premium sheet: pricing model note
  ///
  /// In en, this message translates to:
  /// **'One-time payment — no subscription'**
  String get premiumOneTime;

  /// Premium sheet button
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// Purchase result feedback
  ///
  /// In en, this message translates to:
  /// **'Thank you! Premium is now active.'**
  String get purchaseSuccess;

  /// Purchase result feedback: failure
  ///
  /// In en, this message translates to:
  /// **'Purchase couldn\'t be completed. Please try again later.'**
  String get purchaseError;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Settings item: accessibility
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reduceMotion;

  /// Settings item: toggle for game sound effects
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// Settings item: opens the tutorial
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get howToPlay;

  /// Body of the privacy dialog: the app's whole privacy story in one line
  ///
  /// In en, this message translates to:
  /// **'IqraQuest runs entirely on your device: no account, no ads, no tracking, and nothing is ever sent over the Internet.'**
  String get privacySummary;

  /// Default name for a human player seat
  ///
  /// In en, this message translates to:
  /// **'Player {number}'**
  String defaultPlayerName(num number);

  /// Name shown for a computer opponent
  ///
  /// In en, this message translates to:
  /// **'Rider {number}'**
  String aiPlayerName(num number);

  /// Results title when a computer opponent wins the race
  ///
  /// In en, this message translates to:
  /// **'{name} wins the race!'**
  String opponentWins(String name);

  /// Encouraging subtitle when the player did not win
  ///
  /// In en, this message translates to:
  /// **'A fine ride — every question learned counts.'**
  String get wellRidden;

  /// Screen-reader label for one horse piece on the board
  ///
  /// In en, this message translates to:
  /// **'{color} horse {number}'**
  String horseSemantics(String color, num number);

  /// Team colour name
  ///
  /// In en, this message translates to:
  /// **'emerald'**
  String get teamEmerald;

  /// Team colour name
  ///
  /// In en, this message translates to:
  /// **'sapphire'**
  String get teamSaphir;

  /// Team colour name
  ///
  /// In en, this message translates to:
  /// **'garnet'**
  String get teamGrenat;

  /// Team colour name
  ///
  /// In en, this message translates to:
  /// **'saffron'**
  String get teamSafran;

  /// Premium purchase button: unlock everything at the Store price
  ///
  /// In en, this message translates to:
  /// **'Unlock everything — {price}'**
  String premiumCta(String price);

  /// Premium screen: how many verified questions the full bank holds today
  ///
  /// In en, this message translates to:
  /// **'{count} verified questions, each with its source — and the bank keeps growing.'**
  String premiumQuestionsIncluded(num count);

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Settings item / legal link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Fallback error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get genericError;

  /// Parental gate dialog title, shown before purchases/external links
  ///
  /// In en, this message translates to:
  /// **'A question for parents'**
  String get parentalGateTitle;

  /// Parental gate dialog body
  ///
  /// In en, this message translates to:
  /// **'Solve this to continue.'**
  String get parentalGateInstruction;

  /// Header above the six horseshoe gait choices
  ///
  /// In en, this message translates to:
  /// **'Choose your gait'**
  String get chooseYourGait;

  /// How far a gait moves, shown under each horseshoe
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} square} other{{count} squares}}'**
  String gaitSquares(num count);

  /// Name of the 1-square gait, shown on its chip
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get gaitNameWalk;

  /// Name of the 2-square gait, shown on its chip
  ///
  /// In en, this message translates to:
  /// **'Trot'**
  String get gaitNameTrot;

  /// Name of the 3-square gait, shown on its chip
  ///
  /// In en, this message translates to:
  /// **'Canter'**
  String get gaitNameCanter;

  /// Name of the 4-square gait, shown on its chip
  ///
  /// In en, this message translates to:
  /// **'Gallop'**
  String get gaitNameGallop;

  /// Name of the 5-square gait, shown on its chip
  ///
  /// In en, this message translates to:
  /// **'Full gallop'**
  String get gaitNameFullGallop;

  /// Name of the 6-square gait, shown on its chip
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get gaitNameCharge;

  /// Section header above the quick/classic format choice
  ///
  /// In en, this message translates to:
  /// **'Game format'**
  String get chooseFormat;

  /// Hint on a gait already spent this cycle
  ///
  /// In en, this message translates to:
  /// **'Already used this cycle'**
  String get gaitAlreadyUsed;

  /// Screen-reader label for one gait: distance, difficulty, reward
  ///
  /// In en, this message translates to:
  /// **'Move {steps} squares, {difficulty} question, {points} knowledge points'**
  String gaitSemanticLabel(int steps, String difficulty, int points);

  /// Prompt to pick which horse to move
  ///
  /// In en, this message translates to:
  /// **'Choose your horse'**
  String get selectHorse;

  /// Confirmation before a risky gait in child mode
  ///
  /// In en, this message translates to:
  /// **'This gait draws a harder question. Continue?'**
  String get confirmBoldGait;

  /// Name of the streak gauge
  ///
  /// In en, this message translates to:
  /// **'Knowledge momentum'**
  String get knowledgeStreak;

  /// Label for accumulated knowledge points
  ///
  /// In en, this message translates to:
  /// **'Knowledge points'**
  String get knowledgePointsLabel;

  /// Celebration when a 3-answer streak earns a shield
  ///
  /// In en, this message translates to:
  /// **'Shield earned! Your horse is protected.'**
  String get shieldEarned;

  /// Celebration when a 5-answer streak unlocks the Grand Gallop
  ///
  /// In en, this message translates to:
  /// **'Grand Gallop unlocked! +2 squares whenever you choose.'**
  String get grandGallopEarned;

  /// Celebration when a 10-answer streak earns a mastery badge
  ///
  /// In en, this message translates to:
  /// **'Mastery badge earned!'**
  String get masteryBadgeEarned;

  /// Toggle to spend the Grand Gallop on this move
  ///
  /// In en, this message translates to:
  /// **'Use the Grand Gallop (+2)'**
  String get useGrandGallop;

  /// Header on the circuit picker
  ///
  /// In en, this message translates to:
  /// **'Choose your course'**
  String get chooseCircuit;

  /// Circuit name
  ///
  /// In en, this message translates to:
  /// **'The Oasis Road'**
  String get circuitOasisRoute;

  /// Circuit name
  ///
  /// In en, this message translates to:
  /// **'The Caravan Trail'**
  String get circuitCaravanTrail;

  /// Circuit name
  ///
  /// In en, this message translates to:
  /// **'The Great Ride of Knowledge'**
  String get circuitGreatRide;

  /// Circuit description
  ///
  /// In en, this message translates to:
  /// **'A short, sunlit course. Perfect for a quick game.'**
  String get circuitOasisRouteDescription;

  /// Circuit description
  ///
  /// In en, this message translates to:
  /// **'Camps and lanterns. A more strategic course.'**
  String get circuitCaravanTrailDescription;

  /// Circuit description
  ///
  /// In en, this message translates to:
  /// **'From daylight to a starlit sky. The great journey.'**
  String get circuitGreatRideDescription;

  /// Special square name
  ///
  /// In en, this message translates to:
  /// **'Oasis'**
  String get cellOasis;

  /// Special square name
  ///
  /// In en, this message translates to:
  /// **'Knowledge'**
  String get cellKnowledge;

  /// Special square name
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get cellChallenge;

  /// Special square name
  ///
  /// In en, this message translates to:
  /// **'Shortcut'**
  String get cellShortcut;

  /// Special square name
  ///
  /// In en, this message translates to:
  /// **'Duel'**
  String get cellDuel;

  /// Special square name
  ///
  /// In en, this message translates to:
  /// **'Wisdom'**
  String get cellWisdom;

  /// Special square name
  ///
  /// In en, this message translates to:
  /// **'Relay'**
  String get cellRelay;

  /// What the Oasis square does
  ///
  /// In en, this message translates to:
  /// **'Your horse is safe from capture here.'**
  String get cellOasisDescription;

  /// The optional Défi offer
  ///
  /// In en, this message translates to:
  /// **'Answer a harder question to move 2 extra squares?'**
  String get cellChallengeOffer;

  /// Accept the optional challenge
  ///
  /// In en, this message translates to:
  /// **'Take the challenge'**
  String get acceptChallenge;

  /// Decline the optional challenge and keep the move
  ///
  /// In en, this message translates to:
  /// **'Keep my move'**
  String get declineChallenge;

  /// Keep a fact in the personal collection
  ///
  /// In en, this message translates to:
  /// **'Keep this fact'**
  String get saveFact;

  /// Name of the final question that validates an arrival
  ///
  /// In en, this message translates to:
  /// **'Journey question'**
  String get journeyQuestion;

  /// Explains the journey question
  ///
  /// In en, this message translates to:
  /// **'One last question to make your arrival official.'**
  String get journeyQuestionIntro;

  /// Feedback after a correct answer
  ///
  /// In en, this message translates to:
  /// **'Your horse moves ahead!'**
  String get outcomeMoved;

  /// Feedback after a wrong answer — never a setback
  ///
  /// In en, this message translates to:
  /// **'Your horse holds its ground. Nothing is lost.'**
  String get outcomeStayed;

  /// Feedback when passing an opponent
  ///
  /// In en, this message translates to:
  /// **'You overtake an opponent!'**
  String get outcomeCaptured;

  /// Feedback when a shield absorbs an overtake
  ///
  /// In en, this message translates to:
  /// **'The shield protected the horse.'**
  String get outcomeShieldBlocked;

  /// Label for the per-player knowledge level
  ///
  /// In en, this message translates to:
  /// **'Player level'**
  String get playerProfile;

  /// Player level
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get profileChild;

  /// Player level
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get profileDiscovery;

  /// Player level
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get profileIntermediate;

  /// Player level
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get profileAdvanced;

  /// Shown once when a pre-gait save is detected
  ///
  /// In en, this message translates to:
  /// **'The race rules have been improved'**
  String get raceRulesUpdatedTitle;

  /// Explains why an old save cannot be resumed
  ///
  /// In en, this message translates to:
  /// **'The dice is gone: you now choose your own gait, and with it your level of risk. Your progress, badges and purchases are all kept — only the game in progress cannot continue under the new rules.'**
  String get raceRulesUpdatedBody;

  /// Button to start fresh after the rules change
  ///
  /// In en, this message translates to:
  /// **'Start a new race'**
  String get startNewRace;

  /// Title of the rules screen
  ///
  /// In en, this message translates to:
  /// **'The rules'**
  String get rulesTitle;

  /// Rules step 1 title
  ///
  /// In en, this message translates to:
  /// **'Choose your gait'**
  String get ruleChooseGaitTitle;

  /// Rules step 1 body
  ///
  /// In en, this message translates to:
  /// **'You decide how far to move, from 1 to 6 squares. The further you go, the harder the question: 1-2 easy, 3-4 medium, 5-6 hard.'**
  String get ruleChooseGaitBody;

  /// Rules step 2 title
  ///
  /// In en, this message translates to:
  /// **'Answer to advance'**
  String get ruleAnswerToAdvanceTitle;

  /// Rules step 2 body
  ///
  /// In en, this message translates to:
  /// **'A correct answer moves your horse exactly the distance you chose. A wrong answer leaves it where it stands — you never go backwards.'**
  String get ruleAnswerToAdvanceBody;

  /// Rules step 3 title
  ///
  /// In en, this message translates to:
  /// **'One gait per cycle'**
  String get ruleGaitCycleTitle;

  /// Rules step 3 body
  ///
  /// In en, this message translates to:
  /// **'Each gait can be used only once. When all six are spent, the whole set comes back — so plan ahead.'**
  String get ruleGaitCycleBody;

  /// Rules step 4 title
  ///
  /// In en, this message translates to:
  /// **'Overtake and send home'**
  String get ruleCaptureTitle;

  /// Rules step 4 body
  ///
  /// In en, this message translates to:
  /// **'Landing exactly on an opponent\'s horse sends it calmly back to its stable — unless the square is an oasis, or that horse carries a knowledge shield.'**
  String get ruleCaptureBody;

  /// Rules step 5 title
  ///
  /// In en, this message translates to:
  /// **'The knowledge streak'**
  String get ruleStreakTitle;

  /// Rules step 5 body
  ///
  /// In en, this message translates to:
  /// **'Three correct answers in a row earn a shield, five earn the Grand Gallop (+2 squares), and ten earn a mastery badge. Bonuses come from knowledge alone.'**
  String get ruleStreakBody;

  /// Rules step 6 title
  ///
  /// In en, this message translates to:
  /// **'The arrival'**
  String get ruleArrivalTitle;

  /// Rules step 6 body
  ///
  /// In en, this message translates to:
  /// **'Reach the end of the course — going past the line is fine — then answer the Question of the Journey to make your arrival official. A wrong answer never pushes you back: you simply try again next turn.'**
  String get ruleArrivalBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'id',
    'it',
    'ms',
    'nl',
    'pt',
    'tr',
    'ur',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ms':
      return AppLocalizationsMs();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
