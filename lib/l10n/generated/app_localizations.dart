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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  /// **'Answer questions, roll the dice, guide your horse from Makkah to Madinah.'**
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

  /// Dice button label
  ///
  /// In en, this message translates to:
  /// **'Roll the dice'**
  String get rollDice;

  /// Dice disabled state message
  ///
  /// In en, this message translates to:
  /// **'Answer the question to unlock the dice'**
  String get diceLocked;

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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
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
