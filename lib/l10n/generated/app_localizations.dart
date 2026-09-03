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

  /// Welcome screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Draw a card, answer, ride on — and bring your horse home to Mecca.'**
  String get onboardingWelcomeSubtitle;

  /// Primary CTA button on onboarding
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// Welcome screen: heading over the three-gesture strip
  ///
  /// In en, this message translates to:
  /// **'How it plays'**
  String get onboardingHowTo;

  /// Welcome screen, gesture 1: draw a card (it announces its stake)
  ///
  /// In en, this message translates to:
  /// **'Draw a card: it announces its gallops'**
  String get onboardingStepDraw;

  /// Welcome screen, gesture 2: answer right to win the gallops
  ///
  /// In en, this message translates to:
  /// **'Answer right: the gallops are yours'**
  String get onboardingStepAnswer;

  /// Welcome screen, gesture 3: place a horse and ride to the oasis
  ///
  /// In en, this message translates to:
  /// **'Set a horse down and ride to the oasis'**
  String get onboardingStepRide;

  /// Welcome screen: under the language chips
  ///
  /// In en, this message translates to:
  /// **'You can change it later in Settings.'**
  String get onboardingLanguageHint;

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

  /// Game variant: four horses each, the first one home wins
  ///
  /// In en, this message translates to:
  /// **'Quick game'**
  String get quickGame;

  /// Game variant: 4 pawns per player
  ///
  /// In en, this message translates to:
  /// **'Classic game'**
  String get classicGame;

  /// Game format: two of a player's four horses must reach Mecca
  ///
  /// In en, this message translates to:
  /// **'Duo game'**
  String get duoGame;

  /// What a format asks for: how many horses must reach Mecca
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} horse to Mecca} other{{count} horses to Mecca}}'**
  String horsesToMecca(num count);

  /// Format card: how long the quick race runs
  ///
  /// In en, this message translates to:
  /// **'The shortest race.'**
  String get formatQuickHint;

  /// Format card: how long the two-horse race runs
  ///
  /// In en, this message translates to:
  /// **'An evening\'s race.'**
  String get formatDuoHint;

  /// Format card: how long the full race runs
  ///
  /// In en, this message translates to:
  /// **'The full game, as in the original.'**
  String get formatClassicHint;

  /// Setup toggle: play with the bonus squares on the course
  ///
  /// In en, this message translates to:
  /// **'Bonus squares on the course'**
  String get bonusSquaresOption;

  /// Setup toggle, on: what the bonus squares give
  ///
  /// In en, this message translates to:
  /// **'16 squares grant an extra ride: +5, +10 or +20.'**
  String get bonusSquaresOn;

  /// Setup toggle, off: the pure ride
  ///
  /// In en, this message translates to:
  /// **'A pure ride: a card is worth exactly its gallops.'**
  String get bonusSquaresOff;

  /// Board button: silence the game
  ///
  /// In en, this message translates to:
  /// **'Mute sound'**
  String get muteSound;

  /// Board button: bring the game's sound back
  ///
  /// In en, this message translates to:
  /// **'Unmute sound'**
  String get unmuteSound;

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

  /// Middle difficulty; kept short so a three-way selector stays symmetrical
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

  /// Player setup screen title: the riders about to take the track
  ///
  /// In en, this message translates to:
  /// **'The riders'**
  String get ridersTitle;

  /// Premium screen: button label while the Store product is still loading
  ///
  /// In en, this message translates to:
  /// **'Connecting to the store…'**
  String get storeLoading;

  /// Premium screen: disabled button label when the Store cannot be reached
  ///
  /// In en, this message translates to:
  /// **'Store unavailable'**
  String get storeUnavailableCta;

  /// Premium benefit row: the complete question bank
  ///
  /// In en, this message translates to:
  /// **'The whole question bank, each with its source'**
  String get premiumBenefitBank;

  /// Premium benefit row: games run to the end (the free edition stops after N draws)
  ///
  /// In en, this message translates to:
  /// **'Unlimited games, all the way to Mecca (the free edition stops after {count} draws)'**
  String premiumBenefitUnlimited(int count);

  /// Premium benefit row: one purchase for the whole family, no ads
  ///
  /// In en, this message translates to:
  /// **'One purchase for the whole family, no ads'**
  String get premiumBenefitFamily;

  /// Progress screen hint shown before any game has been played
  ///
  /// In en, this message translates to:
  /// **'Play a first game: your progress will show up here.'**
  String get progressEmpty;

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

  /// Button under an answered question: opens the details sheet
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// Title of the details sheet shown after an answer
  ///
  /// In en, this message translates to:
  /// **'Behind the answer'**
  String get questionDetailsTitle;

  /// Details sheet section header: the question text
  ///
  /// In en, this message translates to:
  /// **'The question'**
  String get theQuestionLabel;

  /// Details sheet section header: the right answer
  ///
  /// In en, this message translates to:
  /// **'The right answer'**
  String get theAnswerLabel;

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
  /// **'Unlock the full question bank and every difficulty'**
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

  /// Title of the About dialog opened from Settings
  ///
  /// In en, this message translates to:
  /// **'About IqraQuest'**
  String get aboutDialogTitle;

  /// Version line in the About dialog
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// Copyright line in the About dialog and Settings
  ///
  /// In en, this message translates to:
  /// **'© {year} IqraQuest. All rights reserved.'**
  String copyrightNotice(String year);

  /// Legal paragraph in the About dialog: the game concept and content are protected
  ///
  /// In en, this message translates to:
  /// **'IqraQuest, its game concept, rules, artwork, name and content are original works protected by copyright. Any reproduction, imitation or adaptation, in whole or in part, without written permission is prohibited.'**
  String get originalWorkNotice;

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

  /// Centre of the board: the destination every horse rides to
  ///
  /// In en, this message translates to:
  /// **'Mecca'**
  String get placeMecca;

  /// Green corner
  ///
  /// In en, this message translates to:
  /// **'Medina'**
  String get placeMedina;

  /// Red corner: the mosque itself, not the city around it
  ///
  /// In en, this message translates to:
  /// **'Al-Aqsa'**
  String get placeAlAqsa;

  /// Blue corner
  ///
  /// In en, this message translates to:
  /// **'Mount Arafat'**
  String get placeArafat;

  /// Gold corner
  ///
  /// In en, this message translates to:
  /// **'Mina'**
  String get placeMina;

  /// How eventful a board is, shown on its card
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} special square} other{{count} special squares}}'**
  String circuitSpecialSquares(num count);

  /// Call to action on the face-down deck: draw this turn's card
  ///
  /// In en, this message translates to:
  /// **'Draw a card'**
  String get drawCard;

  /// Headline over the freshly turned card
  ///
  /// In en, this message translates to:
  /// **'Card drawn'**
  String get drawnCardTitle;

  /// The stake announced on the drawn card, and kept in view during its question: how many gallops a right answer wins
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{A {count}-gallop card} other{A {count}-gallop card}}'**
  String cardWorth(num count);

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

  /// Oasis Route card description
  ///
  /// In en, this message translates to:
  /// **'The calmest ride: oases, and few surprises.'**
  String get circuitOasisRouteDescription;

  /// Caravan Trail card description
  ///
  /// In en, this message translates to:
  /// **'Challenges and relays along the way. More tactical.'**
  String get circuitCaravanTrailDescription;

  /// Great Ride card description
  ///
  /// In en, this message translates to:
  /// **'The liveliest ride: challenges, shortcuts and duels.'**
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

  /// Turn banner while an AI opponent is choosing a horse
  ///
  /// In en, this message translates to:
  /// **'{name} is thinking…'**
  String opponentThinking(String name);

  /// Turn banner: the AI opponent drew a card worth N squares
  ///
  /// In en, this message translates to:
  /// **'{name} draws a {count}'**
  String opponentDrew(String name, int count);

  /// Feedback sheet: the right answer, shown after a wrong one
  ///
  /// In en, this message translates to:
  /// **'The right answer: {answer}'**
  String correctAnswerWas(String answer);

  /// Results screen: heading over the per-player score rows
  ///
  /// In en, this message translates to:
  /// **'Race board'**
  String get scoreboardTitle;

  /// Results screen: correct answers count, short
  ///
  /// In en, this message translates to:
  /// **'{count} correct'**
  String scoreboardCorrect(int count);

  /// Results screen: best streak of the game, short
  ///
  /// In en, this message translates to:
  /// **'streak of {count}'**
  String scoreboardBestStreak(int count);

  /// Results screen: restart with the same players, one tap
  ///
  /// In en, this message translates to:
  /// **'Race again!'**
  String get playAgainSameRiders;

  /// Turn banner: the AI opponent answered right and its horse moved
  ///
  /// In en, this message translates to:
  /// **'{name} moves ahead!'**
  String opponentMoved(String name);

  /// Turn banner: the AI opponent answered wrong and stays put
  ///
  /// In en, this message translates to:
  /// **'{name} holds its ground.'**
  String opponentStayed(String name);

  /// Button: share the score card (results and daily challenge)
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareScore;

  /// Share text after a race: winner and stars
  ///
  /// In en, this message translates to:
  /// **'{name} won the IqraQuest race with {points} ⭐! Your turn?'**
  String shareVictoryText(String name, int points);

  /// Share text after the daily challenge: score out of total
  ///
  /// In en, this message translates to:
  /// **'{score}/{total} on today\'s IqraQuest challenge! Can you beat it?'**
  String shareDailyText(int score, int total);

  /// Daily challenge summary title once all questions are answered
  ///
  /// In en, this message translates to:
  /// **'Today\'s challenge done'**
  String get dailyChallengeDone;

  /// Daily challenge summary: right answers out of total
  ///
  /// In en, this message translates to:
  /// **'{score, plural, =0{None right out of {total}} one{{score} right out of {total}} other{{score} right out of {total}}}'**
  String dailyChallengeScore(num score, int total);

  /// Daily challenge summary: invitation to return tomorrow
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow for a new one.'**
  String get dailyChallengeComeBack;

  /// Mode selection: stepper label for the number of computer riders
  ///
  /// In en, this message translates to:
  /// **'Opponents'**
  String get aiOpponentsLabel;

  /// Mode selection: stepper label for the number of human riders
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get playersLabel;

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

  /// Feedback when landing on an opponent's horse and sending it home
  ///
  /// In en, this message translates to:
  /// **'You capture an opponent\'s horse!'**
  String get outcomeCaptured;

  /// Feedback after a correct answer on a 5 or 6 brought a horse out
  ///
  /// In en, this message translates to:
  /// **'Your horse leaves the stable!'**
  String get outcomeExited;

  /// Banner when the drawn card can move no horse at all
  ///
  /// In en, this message translates to:
  /// **'This card can\'t move any horse. Next turn!'**
  String get outcomeNoLegalMove;

  /// Banner when every horse is in the stable and the card is not a 6
  ///
  /// In en, this message translates to:
  /// **'You need a 6 to bring a horse out of the stable.'**
  String get noExitHint;

  /// Deck hint on the second draw a 6 earned
  ///
  /// In en, this message translates to:
  /// **'Bonus turn: the 6 lets you play again!'**
  String get bonusTurnHint;

  /// Celebration title when a 6 is drawn
  ///
  /// In en, this message translates to:
  /// **'SIX!'**
  String get celebrateSixTitle;

  /// Celebration body when a 6 is drawn: the player draws again after this turn
  ///
  /// In en, this message translates to:
  /// **'You\'ll draw again after this turn.'**
  String get celebrateSixBody;

  /// Celebration body when a 6 both opens the stable and grants a replay
  ///
  /// In en, this message translates to:
  /// **'A horse can come out — and you\'ll play again!'**
  String get celebrateSixExitBody;

  /// Celebration title when the gate opens (folded into the 6 celebration)
  ///
  /// In en, this message translates to:
  /// **'Gate open!'**
  String get celebrateExitTitle;

  /// Celebration body when the gate opens (folded into the 6 celebration)
  ///
  /// In en, this message translates to:
  /// **'A horse can leave the stable.'**
  String get celebrateExitBody;

  /// Celebration title when the player captures an opponent's horse
  ///
  /// In en, this message translates to:
  /// **'Captured!'**
  String get celebrateCaptureTitle;

  /// Celebration body when the player captures an opponent's horse
  ///
  /// In en, this message translates to:
  /// **'The opponent\'s horse goes back to its stable.'**
  String get celebrateCaptureBody;

  /// Notice title when the player's own horse is captured
  ///
  /// In en, this message translates to:
  /// **'Caught…'**
  String get celebrateCapturedTitle;

  /// Notice body when the player's own horse is captured
  ///
  /// In en, this message translates to:
  /// **'Your horse goes back to the stable. A 6 brings it out again.'**
  String get celebrateCapturedBody;

  /// Celebration title when a horse reaches the centre
  ///
  /// In en, this message translates to:
  /// **'Mecca!'**
  String get celebrateArrivalTitle;

  /// Celebration body when a horse reaches the centre
  ///
  /// In en, this message translates to:
  /// **'Your horse has arrived. One last question to make it official!'**
  String get celebrateArrivalBody;

  /// Results title when the free edition's draw limit ended the race
  ///
  /// In en, this message translates to:
  /// **'End of the free race'**
  String get freeLimitTitle;

  /// Results subtitle: who was ahead when the free race stopped
  ///
  /// In en, this message translates to:
  /// **'In the lead: {name}'**
  String freeLimitLeader(String name);

  /// Results body: the free edition stops after N draws; Premium runs to the end
  ///
  /// In en, this message translates to:
  /// **'The free edition stops after {count} draws. With Premium, the race runs all the way to Mecca.'**
  String freeLimitBody(int count);

  /// Results button: open the Premium screen after a free race stopped
  ///
  /// In en, this message translates to:
  /// **'Unlock the unlimited race'**
  String get freeLimitCta;

  /// HUD pill, free edition: cards drawn out of the limit (screen-reader label)
  ///
  /// In en, this message translates to:
  /// **'Draws: {count} of {max}'**
  String drawsCounter(int count, int max);

  /// Sheet title after a draw when several horses could use the card
  ///
  /// In en, this message translates to:
  /// **'What will you do with this {count}?'**
  String moveChoiceTitle(int count);

  /// Choice sheet option: bring a horse out of the stable
  ///
  /// In en, this message translates to:
  /// **'Bring a horse out of the stable'**
  String get moveChoiceExit;

  /// Choice sheet option: ride horse N by the card's value
  ///
  /// In en, this message translates to:
  /// **'Horse {number}: ride {count} ahead'**
  String moveChoiceAdvance(int number, int count);

  /// Choice sheet tag: this move captures an opponent, and what the capture is worth
  ///
  /// In en, this message translates to:
  /// **'capture! +{value}'**
  String moveHintCapture(int value);

  /// Choice sheet tag: this move reaches the finish
  ///
  /// In en, this message translates to:
  /// **'finish!'**
  String get moveHintFinish;

  /// Choice sheet tag: this move lands on a safe oasis
  ///
  /// In en, this message translates to:
  /// **'oasis'**
  String get moveHintOasis;

  /// Turn banner: the AI opponent brought a horse out of its stable
  ///
  /// In en, this message translates to:
  /// **'{name} brings a horse out!'**
  String opponentExits(String name);

  /// Turn banner: the AI opponent's card could move nothing
  ///
  /// In en, this message translates to:
  /// **'{name} can\'t move anything.'**
  String opponentNoMove(String name);

  /// Turn banner: the AI opponent drew a 6 and plays again
  ///
  /// In en, this message translates to:
  /// **'{name} drew a 6 and plays again!'**
  String opponentReplays(String name);

  /// Turn banner: the AI opponent captured a horse
  ///
  /// In en, this message translates to:
  /// **'{name} captures a horse!'**
  String opponentCaptured(String name);

  /// Feedback when a shield absorbs an overtake
  ///
  /// In en, this message translates to:
  /// **'The shield protected the horse.'**
  String get outcomeShieldBlocked;

  /// Label over the per-rider question level picker
  ///
  /// In en, this message translates to:
  /// **'Question level'**
  String get playerProfile;

  /// Question level a rider plays at, chosen before the game
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get levelEasy;

  /// Question level a rider plays at, chosen before the game
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get levelIntermediate;

  /// Question level a rider plays at, chosen before the game
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get levelExpert;

  /// Shown once when a pre-gait save is detected
  ///
  /// In en, this message translates to:
  /// **'The race rules have been improved'**
  String get raceRulesUpdatedTitle;

  /// Legacy save notice body
  ///
  /// In en, this message translates to:
  /// **'The rules have changed: you now draw a card, and its value gives both the distance and the difficulty. Your progress, badges and purchases are kept — only the game in progress cannot resume under the new rules.'**
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
  /// **'Draw a card'**
  String get ruleDrawCardTitle;

  /// Rules step 1 body
  ///
  /// In en, this message translates to:
  /// **'On your turn, draw a card: its question opens at once, always at your own level — easy, intermediate or expert — chosen at the start. Its value, 1 to 6 squares, stays hidden until you answer.'**
  String get ruleDrawCardBody;

  /// Rules step 2 title
  ///
  /// In en, this message translates to:
  /// **'Answer to advance'**
  String get ruleAnswerToAdvanceTitle;

  /// Rules step 2 body
  ///
  /// In en, this message translates to:
  /// **'A right answer wins you the card\'s squares. Then choose the horse that takes them: touch it to see where it would land, and drag it there — the drop is the move. A wrong answer leaves everything where it stands: you never go backwards.'**
  String get ruleAnswerToAdvanceBody;

  /// Rules step 3 title
  ///
  /// In en, this message translates to:
  /// **'The escalier to Mecca'**
  String get ruleEscalierTitle;

  /// Rules step 3 body
  ///
  /// In en, this message translates to:
  /// **'After a full lap of the board, your horse climbs the five steps of its escalier to Mecca. Once there, no one can catch it.'**
  String get ruleEscalierBody;

  /// Rules step: leaving the stable on a 6
  ///
  /// In en, this message translates to:
  /// **'Leaving the stable'**
  String get ruleExitTitle;

  /// Rules step body: one horse already out, the other three on a 6
  ///
  /// In en, this message translates to:
  /// **'Each player has four horses, and the first is already on its start square: you play from the very first card, with nothing to wait for. The other three leave the stable on a 6: answer correctly and the horse takes the start square — and since a 6 plays again, it rides right away. The choice is yours: bring another out, or ride.'**
  String get ruleExitBody;

  /// Rules step: a 6 grants another draw
  ///
  /// In en, this message translates to:
  /// **'A 6 plays again'**
  String get ruleSixTitle;

  /// Rules step body: replay on 6, no two own horses on one square
  ///
  /// In en, this message translates to:
  /// **'Just like the die: when you draw a 6 you play again after your turn, whether your answer was right or not. And two of your own horses can never share a square.'**
  String get ruleSixBody;

  /// Rules step 4 title
  ///
  /// In en, this message translates to:
  /// **'Capture and send home'**
  String get ruleCaptureTitle;

  /// Rules step 4 body: a capture sends the horse home and pays twenty
  ///
  /// In en, this message translates to:
  /// **'Landing exactly on an opponent\'s horse sends it calmly back to its stable — unless the square is an oasis, or that horse carries a knowledge shield. A capture pays: your horse bounds 20 gallops forward at once. A horse leaving its stable always captures on its start square.'**
  String get ruleCaptureBody;

  /// Rules step 5 title
  ///
  /// In en, this message translates to:
  /// **'The knowledge streak'**
  String get ruleStreakTitle;

  /// Rules step 5 body
  ///
  /// In en, this message translates to:
  /// **'Three correct answers in a row earn a shield, five the Grand Gallop, and ten a mastery badge. The Grand Gallop spends itself, and only when its +2 squares are enough to reach the finish. Bonuses come from knowledge alone.'**
  String get ruleStreakBody;

  /// Rules step 6 title
  ///
  /// In en, this message translates to:
  /// **'The arrival'**
  String get ruleArrivalTitle;

  /// Rules step 6 body: the finish is reached on an exact count
  ///
  /// In en, this message translates to:
  /// **'The finish is reached on an exact count: three squares from the oasis you need exactly a 3. A 4, a 5 or a 6 leaves the horse where it stands, waiting for the right card. Once there, answer the Question of the Journey to make the arrival official; a wrong answer never pushes you back, you simply try again next turn.'**
  String get ruleArrivalBody;

  /// Settings item: toggle for the board's vibrations
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get hapticFeedback;

  /// Reward reveal caption after a right answer: the gallops won, i.e. how far the card carries a horse
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Won {count} gallop} other{Won {count} gallops}}'**
  String squaresWon(int count);

  /// Placement banner: pick which horse takes the won squares
  ///
  /// In en, this message translates to:
  /// **'Choose a horse'**
  String get chooseHorseToMove;

  /// Placement banner hint before any horse is touched
  ///
  /// In en, this message translates to:
  /// **'Touch a horse to see where it would go'**
  String get touchHorseHint;

  /// Placement banner hint once a horse is selected: drag it onto the highlighted square
  ///
  /// In en, this message translates to:
  /// **'Drag the horse to its golden square'**
  String get dragHorseToDestination;

  /// Word shouted when a bonus square fires, above its value
  ///
  /// In en, this message translates to:
  /// **'BONUS'**
  String get bonusLabel;

  /// Bonus value with its unit, e.g. '+10 gallops'
  ///
  /// In en, this message translates to:
  /// **'+{value} gallops'**
  String bonusPlus(int value);

  /// Word shouted when a capture pays its bond of extra squares
  ///
  /// In en, this message translates to:
  /// **'CAPTURE'**
  String get captureBonusLabel;

  /// Turn banner while the horse rides the bond a capture paid
  ///
  /// In en, this message translates to:
  /// **'Capture! Your horse bounds {value} gallops forward.'**
  String captureBonusRide(int value);

  /// Turn banner while the horse rides the bonus it landed on
  ///
  /// In en, this message translates to:
  /// **'Bonus square! Your horse rides on {value} more squares.'**
  String bonusRide(int value);

  /// Feedback sheet line after a wrong answer: what the card would have moved
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{This card was worth {count} gallop.} other{This card was worth {count} gallops.}}'**
  String cardWasWorth(int count);

  /// Face of the drawn card while its value is still hidden
  ///
  /// In en, this message translates to:
  /// **'Answer to reveal its value'**
  String get answerToReveal;

  /// Turn banner while the AI opponent picks which horse takes its squares
  ///
  /// In en, this message translates to:
  /// **'{name} is choosing a horse…'**
  String opponentPlaces(String name);

  /// Turn banner when the AI opponent's horse fires a bonus square
  ///
  /// In en, this message translates to:
  /// **'{name} lands a +{value} bonus!'**
  String opponentBonus(String name, int value);

  /// Small HUD tag on the rider currently ahead in the race
  ///
  /// In en, this message translates to:
  /// **'Leading'**
  String get leaderLabel;

  /// Short notice when a rider overtakes to become the leader
  ///
  /// In en, this message translates to:
  /// **'{name} takes the lead!'**
  String tookTheLead(String name);

  /// Screen-reader label of a bonus square on the board
  ///
  /// In en, this message translates to:
  /// **'Bonus square +{value}'**
  String bonusSquareSemantics(int value);

  /// Destination tag: this ride ends on a bonus square worth +N
  ///
  /// In en, this message translates to:
  /// **'Bonus +{value}'**
  String moveHintBonus(int value);

  /// Player setup screen: what the board holds this game
  ///
  /// In en, this message translates to:
  /// **'16 bonus squares await on the board: +5, +10 and the rare +20.'**
  String get bonusSquaresTeaser;

  /// Player setup screen subtitle under the title
  ///
  /// In en, this message translates to:
  /// **'Every rider picks their level; the card only sets the distance.'**
  String get ridersSubtitle;

  /// Rules step: the bonus squares
  ///
  /// In en, this message translates to:
  /// **'Bonus squares'**
  String get ruleBonusTitle;

  /// Rules step body: sixteen bonus squares, four per quarter, +5/+10/+20, and they chain
  ///
  /// In en, this message translates to:
  /// **'Sixteen bonus squares are dealt onto the board each game, four per quarter. A horse that stops exactly on one rides on at once by +5, +10 or +20 gallops — and if that bound sets it down exactly on another bonus square, that one fires too: bonuses chain. Each square pays once per turn, and stays in play for everyone.'**
  String get ruleBonusBody;
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
