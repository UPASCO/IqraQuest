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
      'سوالات کے جواب دیں، اپنی چال چنیں، اور اپنے گھوڑے کو مکہ سے مدینہ لے جائیں۔';

  @override
  String get getStarted => 'شروع کریں';

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
  String get backToHome => 'ہوم پر واپس جائیں';

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
  String get premiumUnlockAll => 'تمام 500 سوالات اور ہر مشکل درجہ کھولیں';

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
  String get privacyPolicy => 'رازداری کی پالیسی';

  @override
  String get genericError => 'کچھ غلط ہو گیا۔';

  @override
  String get parentalGateTitle => 'والدین کے لیے ایک سوال';

  @override
  String get parentalGateInstruction => 'جاری رکھنے کے لیے یہ حل کریں۔';

  @override
  String get chooseYourGait => 'اپنی چال منتخب کریں';

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
  String get confirmBoldGait => 'اس چال کے لیے مشکل سوال آئے گا۔ جاری رکھیں؟';

  @override
  String get knowledgeStreak => 'علم کی رفتار';

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
      'مختصر، روشن راستہ۔ تیز کھیل کے لیے بہترین۔';

  @override
  String get circuitCaravanTrailDescription =>
      'پڑاؤ اور لالٹینیں۔ زیادہ حکمت عملی والا راستہ۔';

  @override
  String get circuitGreatRideDescription =>
      'دن سے ستاروں بھرے آسمان تک۔ عظیم سفر۔';

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
  String get outcomeMoved => 'آپ کا گھوڑا آگے بڑھا!';

  @override
  String get outcomeStayed => 'آپ کا گھوڑا وہیں رہا۔ کچھ نہیں گیا۔';

  @override
  String get outcomeCaptured => 'آپ نے حریف کو پیچھے چھوڑا!';

  @override
  String get outcomeShieldBlocked => 'ڈھال نے گھوڑے کو بچا لیا۔';

  @override
  String get playerProfile => 'کھلاڑی کا درجہ';

  @override
  String get profileChild => 'بچہ';

  @override
  String get profileDiscovery => 'دریافت';

  @override
  String get profileIntermediate => 'درمیانہ';

  @override
  String get profileAdvanced => 'اعلیٰ';

  @override
  String get raceRulesUpdatedTitle => 'دوڑ کے قواعد بہتر کر دیے گئے';

  @override
  String get raceRulesUpdatedBody =>
      'پانسہ ختم: اب آپ خود اپنی چال اور اس کے ساتھ خطرے کا درجہ چنتے ہیں۔ آپ کی پیش رفت، بیجز اور خریداری محفوظ ہیں — صرف جاری کھیل نئے قواعد کے ساتھ جاری نہیں رہ سکتا۔';

  @override
  String get startNewRace => 'نئی دوڑ شروع کریں';

  @override
  String get rulesTitle => 'قواعد';

  @override
  String get ruleChooseGaitTitle => 'اپنی چال چنیں';

  @override
  String get ruleChooseGaitBody =>
      'آپ خود طے کرتے ہیں کہ کتنے خانے آگے بڑھنا ہے، 1 سے 6 تک۔ جتنا دور جائیں گے، سوال اتنا مشکل ہوگا: 1-2 آسان، 3-4 درمیانہ، 5-6 مشکل۔';

  @override
  String get ruleAnswerToAdvanceTitle => 'آگے بڑھنے کے لیے جواب دیں';

  @override
  String get ruleAnswerToAdvanceBody =>
      'درست جواب آپ کے گھوڑے کو بالکل اتنا ہی آگے بڑھاتا ہے جتنا آپ نے چنا۔ غلط جواب اسے وہیں رکھتا ہے — آپ کبھی پیچھے نہیں ہٹتے۔';

  @override
  String get ruleGaitCycleTitle => 'فی چکر ایک چال';

  @override
  String get ruleGaitCycleBody =>
      'ہر چال صرف ایک بار استعمال ہوتی ہے۔ جب چھ ختم ہو جائیں تو سب واپس آ جاتی ہیں — پہلے سے منصوبہ بنائیں۔';

  @override
  String get ruleCaptureTitle => 'آگے نکلیں اور واپس بھیجیں';

  @override
  String get ruleCaptureBody =>
      'حریف کے گھوڑے پر بالکل ٹھیک پہنچنا اسے سکون سے اس کے اصطبل واپس بھیج دیتا ہے — سوائے اس کے کہ خانہ نخلستان ہو یا وہ گھوڑا علم کی ڈھال رکھتا ہو۔';

  @override
  String get ruleStreakTitle => 'علم کی روانی';

  @override
  String get ruleStreakBody =>
      'لگاتار تین درست جواب ایک ڈھال دیتے ہیں، پانچ عظیم سرپٹ (+2 خانے) اور دس مہارت کا بیج۔ انعامات صرف علم سے ملتے ہیں۔';

  @override
  String get ruleArrivalTitle => 'آمد';

  @override
  String get ruleArrivalBody =>
      'راستے کے آخر تک پہنچیں — لکیر سے آگے نکلنا ٹھیک ہے — پھر اپنی آمد کی توثیق کے لیے سفر کے سوال کا جواب دیں۔ غلط جواب آپ کو کبھی پیچھے نہیں کرتا: آپ اگلی باری میں دوبارہ کوشش کرتے ہیں۔';
}
