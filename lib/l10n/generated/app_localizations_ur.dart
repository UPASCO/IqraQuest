// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appName => 'اقرا کویسٹ';

  @override
  String get appTagline => 'علم کا سفر';

  @override
  String get onboardingWelcomeTitle => 'اقرا کویسٹ میں خوش آمدید';

  @override
  String get onboardingWelcomeSubtitle =>
      'کارڈ نکالیں، جواب دیں، آگے بڑھیں — اور اپنے گھوڑے کو مکہ پہنچائیں۔';

  @override
  String get getStarted => 'شروع کریں';

  @override
  String get onboardingHowTo => 'کیسے کھیلتے ہیں';

  @override
  String get onboardingStepDraw => 'کارڈ نکالیں: وہ اپنی سرپٹ بتاتا ہے';

  @override
  String get onboardingStepAnswer => 'صحیح جواب دیں: سرپٹ آپ کی ہے';

  @override
  String get onboardingStepRide => 'اپنا گھوڑا رکھیں اور نخلستان تک سرپٹ دوڑیں';

  @override
  String get onboardingLanguageHint =>
      'آپ اسے بعد میں ترتیبات میں بدل سکتے ہیں۔';

  @override
  String get chooseLanguage => 'زبان منتخب کریں';

  @override
  String get play => 'کھیلیں';

  @override
  String get soloMode => 'سولو';

  @override
  String get familyMode => 'خاندان';

  @override
  String get dailyChallenge => 'روزانہ چیلنج';

  @override
  String get progress => 'پیش رفت';

  @override
  String get settings => 'ترتیبات';

  @override
  String get premium => 'پریمیم';

  @override
  String get continueGame => 'کھیل جاری رکھیں';

  @override
  String get quickGame => 'فوری کھیل';

  @override
  String get classicGame => 'کلاسک کھیل';

  @override
  String noMoveOvershoot(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'کارڈ بہت بڑا ہے: تمہارا گھوڑا مکہ سے $count خانے دور ہے اور اسے بالکل $count چاہیے۔',
      one:
          'کارڈ بہت بڑا ہے: تمہارا گھوڑا مکہ سے $count خانہ دور ہے اور اسے بالکل 1 چاہیے۔',
    );
    return '$_temp0';
  }

  @override
  String get hudArrivedHeading => 'پہنچے ہوئے گھوڑے';

  @override
  String get hudKnowledgeShort => 'علم';

  @override
  String get hudStreakShort => 'تسلسل';

  @override
  String get hudCardsShort => 'کارڈ';

  @override
  String get boardMenuTitle => 'کھیل کا مینو';

  @override
  String get boardMenuOpen => 'کھیل کا مینو کھولیں';

  @override
  String get autoPlaySingleMove => 'خودکار چال';

  @override
  String get autoPlaySingleMoveHint =>
      'جب صرف ایک گھوڑا کارڈ کھیل سکے تو وہ خود آگے بڑھ جاتا ہے۔';

  @override
  String get testerMode => 'ٹیسٹر موڈ';

  @override
  String testerModeHint(int total) {
    return 'اس ڈیوائس پر تمام $total سوالات بغیر خریداری کے کھول دیتا ہے۔ یہ ترتیب صرف ٹیسٹ ورژن میں ہوتی ہے۔';
  }

  @override
  String testerBankPlayable(int count, int total) {
    return '$total میں سے $count سوالات کھیلے جا سکتے ہیں';
  }

  @override
  String get restartRace => 'دوڑ دوبارہ شروع کریں';

  @override
  String get restartRaceConfirm =>
      'جاری دوڑ ختم ہو جائے گی۔ وہی سوار اصطبل سے دوبارہ شروع کریں گے۔';

  @override
  String get backToHome => 'ہوم پر واپس جائیں';

  @override
  String get backToHomeHint => 'کھیل محفوظ ہے، تم بعد میں جاری رکھ سکتے ہو۔';

  @override
  String get duoGame => 'جوڑی کھیل';

  @override
  String horsesToMecca(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count گھوڑے مکہ تک',
      one: '$count گھوڑا مکہ تک',
    );
    return '$_temp0';
  }

  @override
  String get formatQuickHint => 'سب سے مختصر دوڑ۔';

  @override
  String get formatDuoHint => 'ایک شام کی دوڑ۔';

  @override
  String get formatClassicHint => 'مکمل کھیل، اصل جیسا۔';

  @override
  String get bonusSquaresOption => 'راستے پر بونس خانے';

  @override
  String get bonusSquaresOn =>
      '16 خانے اضافی سواری دیتے ہیں: ‎+5، ‎+10 یا ‎+20۔';

  @override
  String get bonusSquaresOff => 'خالص راستہ: کارڈ بالکل اپنی سرپٹ کے برابر ہے۔';

  @override
  String get muteSound => 'آواز بند کریں';

  @override
  String get unmuteSound => 'آواز چالو کریں';

  @override
  String get chooseDifficulty => 'مشکل کا درجہ منتخب کریں';

  @override
  String get difficultyEasy => 'آسان';

  @override
  String get difficultyMedium => 'درمیانہ';

  @override
  String get difficultyHard => 'مشکل';

  @override
  String get playerName => 'نام';

  @override
  String get chooseTeam => 'ٹیم منتخب کریں';

  @override
  String get ridersTitle => 'سوار';

  @override
  String get storeLoading => 'اسٹور سے رابطہ ہو رہا ہے…';

  @override
  String get storeUnavailableCta => 'اسٹور دستیاب نہیں';

  @override
  String get premiumBenefitBank =>
      'پورا سوالات کا ذخیرہ، ہر ایک اپنے ماخذ کے ساتھ';

  @override
  String premiumBenefitUnlimited(int count) {
    return 'لامحدود کھیل، مکہ تک (مفت ورژن $count کارڈ کے بعد رک جاتا ہے)';
  }

  @override
  String get premiumBenefitFamily =>
      'پورے خاندان کے لیے ایک ہی خریداری، بغیر اشتہارات';

  @override
  String get progressEmpty =>
      'پہلا کھیل کھیلو: تمہاری پیش رفت یہاں نظر آئے گی۔';

  @override
  String get addPlayer => 'کھلاڑی شامل کریں';

  @override
  String get startGame => 'کھیل شروع کریں';

  @override
  String get yourTurn => 'آپ کی باری';

  @override
  String get categoryProphets => 'انبیاء';

  @override
  String get categorySira => 'سیرت';

  @override
  String get categoryQuran => 'قرآن';

  @override
  String get categoryFaith => 'عقیدہ';

  @override
  String get categoryVirtues => 'اخلاق';

  @override
  String get category => 'زمرہ';

  @override
  String get correctAnswer => 'درست جواب!';

  @override
  String get incorrectAnswer => 'بالکل نہیں…';

  @override
  String get learnMore => 'مزید جانیں';

  @override
  String get questionDetailsTitle => 'جواب کے پیچھے';

  @override
  String get theQuestionLabel => 'سوال';

  @override
  String get theAnswerLabel => 'صحیح جواب';

  @override
  String get explanationLabel => 'وضاحت';

  @override
  String get sourceLabel => 'ماخذ';

  @override
  String get nextPlayer => 'اگلا کھلاڑی';

  @override
  String get rolledSix => 'چھکا! ایک اور باری — نیا سوال۔';

  @override
  String get playAgain => 'دوبارہ کھیلیں';

  @override
  String get protectedSquareLabel => 'محفوظ خانہ';

  @override
  String get freeBankExhaustedMessage =>
      'اس کھیل میں مفت ایڈیشن کے تمام سوالات استعمال ہو چکے ہیں۔';

  @override
  String get victory => 'فتح!';

  @override
  String get gameOver => 'کھیل ختم';

  @override
  String get gamesPlayed => 'کھیلے گئے میچز';

  @override
  String get winRate => 'جیت کی شرح';

  @override
  String get questionsAnswered => 'جواب دیے گئے سوالات';

  @override
  String get streak => 'دنوں کا تسلسل';

  @override
  String get premiumTitle => 'اقرا کویسٹ پریمیم';

  @override
  String get premiumUnlockAll => 'سوالات کا مکمل ذخیرہ اور ہر مشکل درجہ کھولیں';

  @override
  String get premiumOneTime => 'یک وقتی ادائیگی — کوئی سبسکرپشن نہیں';

  @override
  String get restorePurchases => 'خریداری بحال کریں';

  @override
  String get purchaseSuccess => 'شکریہ! پریمیم اب فعال ہے۔';

  @override
  String get purchaseError =>
      'خریداری مکمل نہیں ہو سکی۔ براہ کرم بعد میں دوبارہ کوشش کریں۔';

  @override
  String get language => 'زبان';

  @override
  String get reduceMotion => 'حرکت کم کریں';

  @override
  String get soundEffects => 'آوازی اثرات';

  @override
  String get howToPlay => 'کھیلنے کا طریقہ';

  @override
  String get privacySummary =>
      'اقرا کویسٹ مکمل طور پر آپ کے آلے پر چلتا ہے: نہ اکاؤنٹ، نہ اشتہار، نہ ٹریکنگ، اور کچھ بھی انٹرنیٹ پر نہیں بھیجا جاتا۔';

  @override
  String defaultPlayerName(num number) {
    return 'کھلاڑی $number';
  }

  @override
  String aiPlayerName(num number) {
    return 'سوار $number';
  }

  @override
  String opponentWins(String name) {
    return '$name ریس جیت گیا!';
  }

  @override
  String get wellRidden => 'عمدہ سواری — سیکھا ہوا ہر سوال اہم ہے۔';

  @override
  String horseSemantics(String color, num number) {
    return '$color گھوڑا $number';
  }

  @override
  String get teamEmerald => 'زمردی';

  @override
  String get teamSaphir => 'نیلم';

  @override
  String get teamGrenat => 'یاقوتی';

  @override
  String get teamSafran => 'زعفرانی';

  @override
  String premiumCta(String price) {
    return 'سب کھولیں — $price';
  }

  @override
  String premiumQuestionsIncluded(num count) {
    return '$count تصدیق شدہ سوالات، ہر ایک اپنے ماخذ کے ساتھ — اور ذخیرہ بڑھتا رہتا ہے۔';
  }

  @override
  String get darkMode => 'ڈارک موڈ';

  @override
  String get about => 'بارے میں';

  @override
  String get aboutDialogTitle => 'اقرا کویسٹ کے بارے میں';

  @override
  String versionLabel(String version) {
    return 'ورژن $version';
  }

  @override
  String copyrightNotice(String year) {
    return '© $year IqraQuest۔ جملہ حقوق محفوظ ہیں۔';
  }

  @override
  String get originalWorkNotice =>
      'اقرا کویسٹ، اس کے کھیل کا تصور، قواعد، تصاویر، نام اور مواد اصل تخلیقات ہیں جو کاپی رائٹ سے محفوظ ہیں۔ تحریری اجازت کے بغیر کسی بھی طرح کی مکمل یا جزوی نقل، تقلید یا ترمیم ممنوع ہے۔';

  @override
  String get privacyPolicy => 'رازداری کی پالیسی';

  @override
  String get genericError => 'کچھ غلط ہو گیا۔';

  @override
  String get parentalGateTitle => 'والدین کے لیے ایک سوال';

  @override
  String get parentalGateInstruction => 'جاری رکھنے کے لیے یہ حل کریں۔';

  @override
  String get placeMecca => 'مکہ';

  @override
  String get placeMedina => 'مدینہ';

  @override
  String get placeAlAqsa => 'مسجد اقصیٰ';

  @override
  String get placeArafat => 'عرفات';

  @override
  String get placeMina => 'منیٰ';

  @override
  String circuitSpecialSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خاص خانے',
      one: '$count خاص خانہ',
    );
    return '$_temp0';
  }

  @override
  String get drawCard => 'کارڈ نکالیں';

  @override
  String get drawnCardTitle => 'نکالا گیا کارڈ';

  @override
  String cardWorth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سرپٹ کا کارڈ',
      one: '$count سرپٹ کا کارڈ',
    );
    return '$_temp0';
  }

  @override
  String gaitSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خانے',
      one: 'ایک خانہ',
    );
    return '$_temp0';
  }

  @override
  String get gaitNameWalk => 'قدم';

  @override
  String get gaitNameTrot => 'دلکی';

  @override
  String get gaitNameCanter => 'پویا';

  @override
  String get gaitNameGallop => 'سرپٹ';

  @override
  String get gaitNameFullGallop => 'تیز سرپٹ';

  @override
  String get gaitNameCharge => 'یلغار';

  @override
  String get chooseFormat => 'کھیل کی طرز';

  @override
  String get gaitAlreadyUsed => 'اس چکر میں استعمال ہو چکی';

  @override
  String gaitSemanticLabel(int steps, String difficulty, int points) {
    return '$steps خانے آگے، $difficulty سوال، $points علمی پوائنٹس';
  }

  @override
  String get selectHorse => 'اپنا گھوڑا منتخب کریں';

  @override
  String get knowledgeStreak => 'مسلسل درست جوابات';

  @override
  String get knowledgePointsLabel => 'علمی پوائنٹس';

  @override
  String get shieldEarned => 'ڈھال مل گئی! آپ کا گھوڑا محفوظ ہے۔';

  @override
  String get grandGallopEarned => 'گرینڈ گیلپ کھل گیا! جب چاہیں +2 خانے۔';

  @override
  String get masteryBadgeEarned => 'مہارت کا بیج مل گیا!';

  @override
  String get useGrandGallop => 'گرینڈ گیلپ استعمال کریں (+2)';

  @override
  String get chooseCircuit => 'اپنا راستہ منتخب کریں';

  @override
  String get circuitOasisRoute => 'نخلستانوں کا راستہ';

  @override
  String get circuitCaravanTrail => 'قافلوں کی پگڈنڈی';

  @override
  String get circuitGreatRide => 'علم کی عظیم سواری';

  @override
  String get circuitOasisRouteDescription =>
      'سب سے پرسکون راستہ: نخلستان، کم حیرتیں۔';

  @override
  String get circuitCaravanTrailDescription =>
      'راستے میں چیلنج اور ریلے۔ زیادہ حکمت عملی۔';

  @override
  String get circuitGreatRideDescription =>
      'سب سے پرجوش راستہ: چیلنج، شارٹ کٹ اور مقابلے۔';

  @override
  String get cellOasis => 'نخلستان';

  @override
  String get cellKnowledge => 'علم';

  @override
  String get cellChallenge => 'چیلنج';

  @override
  String get cellShortcut => 'مختصر راستہ';

  @override
  String get cellDuel => 'مقابلہ';

  @override
  String get cellWisdom => 'حکمت';

  @override
  String get cellRelay => 'ریلے';

  @override
  String get cellOasisDescription => 'یہاں آپ کا گھوڑا محفوظ ہے۔';

  @override
  String get cellChallengeOffer =>
      '2 اضافی خانے آگے بڑھنے کے لیے مشکل سوال کا جواب دیں؟';

  @override
  String get acceptChallenge => 'چیلنج قبول کریں';

  @override
  String get declineChallenge => 'اپنی چال رکھیں';

  @override
  String get saveFact => 'یہ بات محفوظ کریں';

  @override
  String get journeyQuestion => 'سفر کا سوال';

  @override
  String get journeyQuestionIntro => 'آپ کی آمد کی تصدیق کے لیے ایک آخری سوال۔';

  @override
  String opponentThinking(String name) {
    return '$name سوچ رہا ہے…';
  }

  @override
  String opponentDrew(String name, int count) {
    return '$name نے $count نکالا';
  }

  @override
  String correctAnswerWas(String answer) {
    return 'صحیح جواب: $answer';
  }

  @override
  String get scoreboardTitle => 'ریس بورڈ';

  @override
  String scoreboardCorrect(int count) {
    return '$count درست';
  }

  @override
  String scoreboardBestStreak(int count) {
    return '$count کا سلسلہ';
  }

  @override
  String get playAgainSameRiders => 'ایک اور ریس!';

  @override
  String opponentMoved(String name) {
    return '$name آگے بڑھا!';
  }

  @override
  String opponentStayed(String name) {
    return '$name وہیں رہا۔';
  }

  @override
  String get shareScore => 'شیئر کریں';

  @override
  String shareVictoryText(String name, int points) {
    return '$name نے IqraQuest ریس $points ⭐ کے ساتھ جیت لی! آپ کی باری؟';
  }

  @override
  String shareDailyText(int score, int total) {
    return 'IqraQuest کے آج کے چیلنج میں $score/$total! آپ بہتر کر سکتے ہیں؟';
  }

  @override
  String get dailyChallengeDone => 'آج کا چیلنج مکمل';

  @override
  String dailyChallengeScore(num score, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$total میں سے $score درست',
    );
    return '$_temp0';
  }

  @override
  String get dailyChallengeComeBack => 'نئے چیلنج کے لیے کل پھر آئیں۔';

  @override
  String get aiOpponentsLabel => 'حریف';

  @override
  String get playersLabel => 'کھلاڑی';

  @override
  String get outcomeMoved => 'آپ کا گھوڑا آگے بڑھا!';

  @override
  String get outcomeStayed => 'آپ کا گھوڑا وہیں رہا۔ کچھ نہیں گیا۔';

  @override
  String get outcomeCaptured => 'آپ نے حریف کا گھوڑا پکڑ لیا!';

  @override
  String get outcomeExited => 'آپ کا گھوڑا اصطبل سے نکلا!';

  @override
  String get outcomeNoLegalMove =>
      'یہ کارڈ کسی گھوڑے کو نہیں ہلا سکتا۔ اگلی باری!';

  @override
  String get noExitHint => 'اصطبل سے گھوڑا نکالنے کے لیے 6 چاہیے۔';

  @override
  String get bonusTurnHint => 'بونس باری: 6 آپ کو دوبارہ کھیلنے دیتا ہے!';

  @override
  String get celebrateSixTitle => 'چھ!';

  @override
  String get celebrateSixBody => 'اس باری کے بعد آپ دوبارہ کارڈ نکالیں گے۔';

  @override
  String get celebrateSixExitBody =>
      'ایک گھوڑا نکل سکتا ہے — اور آپ دوبارہ کھیلیں گے!';

  @override
  String get celebrateExitTitle => 'دروازہ کھلا!';

  @override
  String get celebrateExitBody => 'ایک گھوڑا اصطبل سے نکل سکتا ہے۔';

  @override
  String get celebrateCaptureTitle => 'پکڑ لیا!';

  @override
  String get celebrateCaptureBody => 'حریف کا گھوڑا اپنے اصطبل واپس جاتا ہے۔';

  @override
  String get celebrateCapturedTitle => 'پکڑا گیا…';

  @override
  String get celebrateCapturedBody =>
      'آپ کا گھوڑا اصطبل واپس گیا۔ 6 اسے پھر نکالے گا۔';

  @override
  String get celebrateArrivalTitle => 'مکہ!';

  @override
  String get celebrateArrivalBody =>
      'آپ کا گھوڑا پہنچ گیا۔ توثیق کے لیے ایک آخری سوال!';

  @override
  String get freeLimitTitle => 'مفت ریس کا اختتام';

  @override
  String freeLimitLeader(String name) {
    return 'آگے: $name';
  }

  @override
  String freeLimitBody(int count) {
    return 'مفت ورژن $count کارڈ کے بعد رک جاتا ہے۔ پریمیم کے ساتھ ریس مکہ تک جاتی ہے۔';
  }

  @override
  String get freeLimitCta => 'لامحدود ریس کھولیں';

  @override
  String drawsCounter(int count, int max) {
    return 'کارڈ: $max میں سے $count';
  }

  @override
  String moveChoiceTitle(int count) {
    return 'اس $count کا کیا کریں گے؟';
  }

  @override
  String get moveChoiceExit => 'اصطبل سے ایک گھوڑا نکالیں';

  @override
  String moveChoiceAdvance(int number, int count) {
    return 'گھوڑا $number: $count آگے';
  }

  @override
  String moveHintCapture(int value) {
    return 'پکڑ! +$value';
  }

  @override
  String get moveHintFinish => 'منزل!';

  @override
  String get moveHintOasis => 'نخلستان';

  @override
  String opponentExits(String name) {
    return '$name نے گھوڑا نکالا!';
  }

  @override
  String opponentNoMove(String name) {
    return '$name کچھ نہیں ہلا سکتا۔';
  }

  @override
  String opponentReplays(String name) {
    return '$name نے 6 نکالا اور دوبارہ کھیلتا ہے!';
  }

  @override
  String opponentCaptured(String name) {
    return '$name نے گھوڑا پکڑ لیا!';
  }

  @override
  String get outcomeShieldBlocked => 'ڈھال نے گھوڑے کو بچا لیا۔';

  @override
  String get outcomeShelteredByOasis =>
      'نخلستان اُس گھوڑے کو پناہ دیتا ہے: کوئی اصطبل واپس نہیں جاتا۔';

  @override
  String get playerProfile => 'سوالات کا درجہ';

  @override
  String get levelBeginner => 'پہلے قدم';

  @override
  String get levelBeginnerHint =>
      'پہلے قدم: بالکل ابتدائی باتیں، جو ہر کوئی پہلے سے جانتا ہے۔';

  @override
  String get levelEasy => 'آسان';

  @override
  String get levelIntermediate => 'درمیانہ';

  @override
  String get levelExpert => 'ماہر';

  @override
  String get levelMixed => 'مخلوط';

  @override
  String get levelMixedHint =>
      'ملا جلا: ہر کارڈ اپنی سطح نکالتا ہے، پہلے قدم سے ماہر تک۔';

  @override
  String get raceRulesUpdatedTitle => 'دوڑ کے قواعد بہتر کر دیے گئے';

  @override
  String get raceRulesUpdatedBody =>
      'قواعد بدل گئے ہیں: اب آپ ایک کارڈ نکالتے ہیں، اور اس کی قیمت فاصلہ اور مشکل دونوں طے کرتی ہے۔ آپ کی پیش رفت، بیجز اور خریداری محفوظ ہیں — صرف جاری کھیل نئے قواعد کے ساتھ جاری نہیں رہ سکتا۔';

  @override
  String get startNewRace => 'نئی دوڑ شروع کریں';

  @override
  String get rulesTitle => 'قواعد';

  @override
  String get ruleGoalTitle => 'دوڑ جیتنا';

  @override
  String get ruleGoalBody =>
      'ہر کھلاڑی چار گھوڑے تختے کے مرکز، مکہ کی طرف لے جاتا ہے۔ کھیل سے پہلے میز طے کرتی ہے کہ کتنے پہنچنے چاہییں: تیز دوڑ کے لیے ایک، جوڑی دوڑ کے لیے دو، کلاسک کھیل کے لیے چاروں۔ جو پہلے کر لے وہ جیت جاتا ہے۔';

  @override
  String get ruleKnowledgeTitle => 'علم کے نکات';

  @override
  String get ruleKnowledgeBody =>
      'پٹی کا ستارہ تمہارے علم کے نکات گنتا ہے: ہر درست جواب پر ایک، اور علم کے خانے پر ایک اضافی۔ یہ تمہارا گھوڑا آگے نہیں بڑھاتے — یہ بتاتے ہیں کہ تم نے کیا سیکھا، اور اگر کھیل پہنچنے سے پہلے رک جائے تو کھلاڑیوں کے درمیان فیصلہ کرتے ہیں۔';

  @override
  String get ruleSpecialCellsTitle => 'خاص خانے';

  @override
  String get ruleSpecialCellsBody =>
      'تمہارا منتخب راستہ ایسے خانے رکھتا ہے جو کچھ کرتے ہیں، اس کے چاروں حصوں میں وہی: نخلستان پکڑے جانے سے بچاتا ہے، علم ایک نکتہ دیتا ہے، چیلنج +2 سرپٹ کے لیے مشکل سوال پیش کرتا ہے، شارٹ کٹ آگے نکلنے کے لیے مشکل سوال، اور حکمت ایک بات دیتی ہے جو تم رکھ سکو۔ ناکام چیلنج یا شارٹ کٹ صرف بونس کا نقصان ہے: تمہارا گھوڑا وہیں رہتا ہے۔';

  @override
  String get ruleDrawCardTitle => 'ایک کارڈ نکالیں';

  @override
  String get ruleDrawCardBody =>
      'اپنی باری پر ایک کارڈ نکالو۔ وہ اپنی قیمت دکھاتے ہوئے پلٹتا ہے — «5 سرپٹ کا کارڈ» — پھر اس کا سوال کھلتا ہے، ہمیشہ تمہارے منتخب کردہ درجے پر: آسان، درمیانہ، ماہر یا مخلوط۔ یوں تم جواب دینے سے پہلے جان لیتے ہو کہ درست جواب کی قیمت کیا ہے۔';

  @override
  String get ruleAnswerToAdvanceTitle => 'آگے بڑھنے کے لیے جواب دیں';

  @override
  String get ruleAnswerToAdvanceBody =>
      'درست جواب تمہیں کارڈ کے سرپٹ دلاتا ہے: ایک سرپٹ، ایک خانہ۔ پھر وہ گھوڑا چنو جو انہیں لے — دیکھنے کے لیے چھوؤ کہ وہ کہاں پہنچے گا، پھر اسے اس کے سنہری خانے تک کھینچو۔ چھوڑنا ہی چال ہے: اس سے پہلے کچھ نہیں ہلتا، بعد میں کوئی تصدیق نہیں مانگی جاتی۔ غلط جواب کچھ نہیں ہلاتا: تم کبھی پیچھے نہیں ہٹتے۔';

  @override
  String get ruleEscalierTitle => 'مکہ کی طرف زینہ';

  @override
  String get ruleEscalierBody =>
      'پورے چکر کے بعد آپ کا گھوڑا اپنے زینے کی پانچ سیڑھیاں چڑھ کر مکہ پہنچتا ہے۔ وہاں اسے کوئی نہیں پکڑ سکتا۔';

  @override
  String get ruleExitTitle => 'اصطبل سے نکلنا';

  @override
  String get ruleExitBody =>
      'ہر کھلاڑی کے چار گھوڑے ہیں، اور پہلا پہلے ہی اپنے آغاز کے خانے پر ہے: تم پہلی ہی کارڈ سے کھیلتے ہو، انتظار کے بغیر۔ باقی تین 6 پر اصطبل سے نکلتے ہیں — درست جواب دو اور گھوڑا آغاز کے خانے پر آ جاتا ہے۔ تمہارے دو گھوڑے کبھی ایک خانہ نہیں بانٹ سکتے: تمہارے آغاز کے خانے پر بیٹھا گھوڑا دروازہ بند رکھتا ہے جب تک آگے نہ بڑھے۔';

  @override
  String get ruleSixTitle => '6 دوبارہ کھیل';

  @override
  String get ruleSixBody =>
      'پانسے کی طرح: اگر تم 6 نکالو تو اپنی باری کے بعد دوبارہ کھیلتے ہو، جواب درست ہو یا غلط۔';

  @override
  String get ruleCaptureTitle => 'پکڑیں اور واپس بھیجیں';

  @override
  String get ruleCaptureBody =>
      'حریف کے گھوڑے پر بالکل ٹھیک پہنچنا اسے سکون سے اس کے اصطبل واپس بھیج دیتا ہے — سوائے اس کے کہ خانہ نخلستان ہو یا وہ گھوڑا علم کی ڈھال رکھتا ہو۔ پکڑنے کا انعام ہے: آپ کا گھوڑا فوراً 20 سرپٹ آگے چھلانگ لگاتا ہے۔ اصطبل سے نکلنے والا گھوڑا اپنے شروعاتی خانے پر ہمیشہ پکڑتا ہے۔';

  @override
  String get ruleStreakTitle => 'درست جوابات کا سلسلہ';

  @override
  String get ruleStreakBody =>
      'لگاتار تین درست جواب ایک ڈھال دیتے ہیں، پانچ گرینڈ گیلپ اور دس مہارت کا بیج۔ گرینڈ گیلپ خود خرچ ہوتا ہے، اور صرف تب جب اس کے +2 سرپٹ اختتام تک پہنچنے کے لیے کافی ہوں۔ بونس صرف علم سے ملتے ہیں۔';

  @override
  String get ruleArrivalTitle => 'آمد';

  @override
  String get ruleArrivalBody =>
      'منزل ٹھیک گنتی سے ملتی ہے: مکہ سے تین خانے پہلے آپ کو بالکل 3 چاہیے۔ 4، 5 یا 6 گھوڑے کو وہیں چھوڑ دیتا ہے، صحیح کارڈ کے انتظار میں۔ پہنچنے پر آمد کی توثیق کے لیے سفر کے سوال کا جواب دیں؛ غلط جواب آپ کو کبھی پیچھے نہیں کرتا، آپ اگلی باری دوبارہ کوشش کرتے ہیں۔';

  @override
  String get hapticFeedback => 'وائبریشن';

  @override
  String squaresWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سرپٹیں جیتیں',
      one: '$count سرپٹ جیتی',
    );
    return '$_temp0';
  }

  @override
  String get chooseHorseToMove => 'ایک گھوڑا چنیں';

  @override
  String get touchHorseHint => 'گھوڑے کو چھوئیں تاکہ دیکھیں وہ کہاں جائے گا';

  @override
  String get dragHorseToDestination => 'گھوڑے کو اس کے سنہری خانے تک گھسیٹیں';

  @override
  String get bonusLabel => 'بونس';

  @override
  String bonusPlus(int value) {
    return '+$value سرپٹ';
  }

  @override
  String get captureBonusLabel => 'پکڑ';

  @override
  String captureBonusRide(int value) {
    return 'پکڑ! آپ کا گھوڑا $value سرپٹ آگے چھلانگ لگاتا ہے۔';
  }

  @override
  String bonusRide(int value) {
    return 'بونس خانہ! آپ کا گھوڑا مزید $value خانے آگے بڑھتا ہے۔';
  }

  @override
  String cardWasWorth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'یہ کارڈ $count سرپٹوں کا تھا۔',
      one: 'یہ کارڈ $count سرپٹ کا تھا۔',
    );
    return '$_temp0';
  }

  @override
  String get bonusMissedNote =>
      'بونس رہ گیا: تمہارا گھوڑا اپنی جگہ پر ہی رہتا ہے۔';

  @override
  String get answerToReveal => 'اس کی قیمت جاننے کے لیے جواب دیں';

  @override
  String opponentPlaces(String name) {
    return '$name گھوڑا چن رہا ہے…';
  }

  @override
  String opponentBonus(String name, int value) {
    return '$name کو +$value بونس ملا!';
  }

  @override
  String get leaderLabel => 'سب سے آگے';

  @override
  String tookTheLead(String name) {
    return '$name آگے نکل گیا!';
  }

  @override
  String bonusSquareSemantics(int value) {
    return 'بونس خانہ +$value';
  }

  @override
  String moveHintBonus(int value) {
    return 'بونس +$value';
  }

  @override
  String get bonusSquaresTeaser =>
      'بورڈ پر 16 بونس خانے منتظر ہیں: +5، +10 اور نایاب +20۔';

  @override
  String get ridersSubtitle =>
      'ہر سوار اپنا درجہ چنتا ہے؛ کارڈ صرف فاصلہ طے کرتا ہے۔';

  @override
  String get ruleBonusTitle => 'بونس خانے';

  @override
  String get ruleBonusBody =>
      'اگر میز انہیں رکھے تو ہر کھیل میں سولہ بونس خانے تختے پر تقسیم ہوتے ہیں، ہر چوتھائی میں چار۔ جو گھوڑا بالکل اس پر رکے وہ فوراً ‎+5، ‎+10 یا ‎+20 سرپٹ مزید چلتا ہے — اور اگر یہ چال اسے بالکل کسی دوسرے بونس خانے پر لے جائے تو وہ بھی چل پڑتا ہے: بونس سلسلہ بناتے ہیں۔ ہر خانہ فی باری ایک بار دیتا ہے اور سب کے لیے کھیل میں رہتا ہے۔ ان کے بغیر کارڈ بالکل اپنے سرپٹ کے برابر ہے۔';

  @override
  String get newGameTitle => 'نیا کھیل';

  @override
  String get setupWhoPlays => 'کون کھیل رہا ہے؟';

  @override
  String get soloTileCaption => 'کمپیوٹر کے خلاف';

  @override
  String get computerLevelLabel => 'کمپیوٹر کی سطح';

  @override
  String get setupRaceLength => 'کھیل کی مدت';

  @override
  String get raceLengthShort => 'مختصر کھیل';

  @override
  String get raceLengthMedium => 'درمیانہ کھیل';

  @override
  String get raceLengthFull => 'مکمل کھیل';

  @override
  String get setupCourse => 'راستہ';

  @override
  String get courseCalm => 'پرسکون';

  @override
  String get courseLively => 'چہل پہل';

  @override
  String get courseIntense => 'شدید';

  @override
  String get courseSquareOasis => 'نخلستان: تمہارا گھوڑا وہاں محفوظ ہے';

  @override
  String get courseSquareKnowledge => 'علم: +1 علم پوائنٹ';

  @override
  String get courseSquareChallenge => 'چیلنج: +2 خانوں کے لیے ایک اضافی سوال';

  @override
  String get courseSquareShortcut =>
      'شارٹ کٹ: آگے چھلانگ لگانے کے لیے ایک مشکل سوال';

  @override
  String get courseSquareWisdom =>
      'حکمت: ایک حقیقت جسے دریافت کر کے سنبھال رکھو';

  @override
  String get levelEasyHint => 'آسان: ابتدائی باتوں پر سادہ سوالات۔';

  @override
  String get levelIntermediateHint =>
      'درمیانہ: جو قصے اور احکام اچھی طرح جانتے ہیں۔';

  @override
  String get levelExpertHint =>
      'ماہر: سب سے باریک سوالات، آیات و احادیث کے ساتھ۔';
}
