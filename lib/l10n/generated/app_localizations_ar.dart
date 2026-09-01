// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'إكرا كويست';

  @override
  String get appTagline => 'رحلة المعرفة';

  @override
  String get onboardingWelcomeTitle => 'مرحبًا بك في إكرا كويست';

  @override
  String get onboardingWelcomeSubtitle =>
      'أجب عن الأسئلة، اختر خطوتك، وقُد حصانك من مكة إلى المدينة.';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get play => 'العب';

  @override
  String get soloMode => 'فردي';

  @override
  String get familyMode => 'عائلي';

  @override
  String get dailyChallenge => 'تحدي اليوم';

  @override
  String get progress => 'التقدم';

  @override
  String get settings => 'الإعدادات';

  @override
  String get premium => 'بريميوم';

  @override
  String get continueGame => 'متابعة اللعبة';

  @override
  String get quickGame => 'لعبة سريعة';

  @override
  String get classicGame => 'لعبة كلاسيكية';

  @override
  String get chooseDifficulty => 'اختر مستوى الصعوبة';

  @override
  String get difficultyEasy => 'سهل';

  @override
  String get difficultyMedium => 'متوسط';

  @override
  String get difficultyHard => 'صعب';

  @override
  String get playerName => 'الاسم';

  @override
  String get chooseTeam => 'اختر الفريق';

  @override
  String get addPlayer => 'إضافة لاعب';

  @override
  String get startGame => 'ابدأ اللعبة';

  @override
  String get yourTurn => 'دورك';

  @override
  String get categoryProphets => 'الأنبياء';

  @override
  String get categorySira => 'السيرة';

  @override
  String get categoryQuran => 'القرآن';

  @override
  String get categoryFaith => 'العقيدة';

  @override
  String get categoryVirtues => 'الأخلاق';

  @override
  String get category => 'الفئة';

  @override
  String get correctAnswer => 'إجابة صحيحة!';

  @override
  String get incorrectAnswer => 'ليست كذلك تمامًا…';

  @override
  String get explanationLabel => 'التوضيح';

  @override
  String get sourceLabel => 'المصدر';

  @override
  String get nextPlayer => 'اللاعب التالي';

  @override
  String get rolledSix => 'ستة! دور جديد — سؤال جديد.';

  @override
  String get playAgain => 'العب مجددًا';

  @override
  String get protectedSquareLabel => 'مربع محمي';

  @override
  String get freeBankExhaustedMessage =>
      'تم استخدام جميع أسئلة النسخة المجانية في هذه اللعبة.';

  @override
  String get victory => 'النصر!';

  @override
  String get gameOver => 'انتهت اللعبة';

  @override
  String get backToHome => 'العودة إلى الرئيسية';

  @override
  String get gamesPlayed => 'عدد المباريات';

  @override
  String get winRate => 'معدل الفوز';

  @override
  String get questionsAnswered => 'الأسئلة المجاب عنها';

  @override
  String get streak => 'سلسلة الأيام';

  @override
  String get premiumTitle => 'إكرا كويست بريميوم';

  @override
  String get premiumUnlockAll => 'افتح جميع الأسئلة الـ500 وكل مستويات الصعوبة';

  @override
  String get premiumOneTime => 'دفعة واحدة — بدون اشتراك';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get purchaseSuccess => 'شكرًا لك! تم تفعيل بريميوم.';

  @override
  String get purchaseError => 'تعذّر إتمام الشراء. حاول مرة أخرى لاحقًا.';

  @override
  String get language => 'اللغة';

  @override
  String get reduceMotion => 'تقليل الحركة';

  @override
  String get soundEffects => 'المؤثرات الصوتية';

  @override
  String get howToPlay => 'طريقة اللعب';

  @override
  String get privacySummary =>
      'يعمل إكرا كويست بالكامل على جهازك: لا حساب، ولا إعلانات، ولا تتبّع، ولا يُرسل أي شيء عبر الإنترنت.';

  @override
  String defaultPlayerName(num number) {
    return 'اللاعب $number';
  }

  @override
  String aiPlayerName(num number) {
    return 'الفارس $number';
  }

  @override
  String opponentWins(String name) {
    return '$name يفوز بالسباق!';
  }

  @override
  String get wellRidden => 'ركوب رائع — كل سؤال تعلمته يُحتسب.';

  @override
  String horseSemantics(String color, num number) {
    return 'حصان $color $number';
  }

  @override
  String get teamEmerald => 'زمردي';

  @override
  String get teamSaphir => 'ياقوتي أزرق';

  @override
  String get teamGrenat => 'عقيقي';

  @override
  String get teamSafran => 'زعفراني';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get about => 'حول التطبيق';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get genericError => 'حدث خطأ ما.';

  @override
  String get parentalGateTitle => 'سؤال لأولياء الأمور';

  @override
  String get parentalGateInstruction => 'حل هذه المسألة للمتابعة.';

  @override
  String get chooseYourGait => 'اختر خطوتك';

  @override
  String gaitSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مربع',
      many: '$count مربعًا',
      few: '$count مربعات',
      two: 'مربعان',
      one: 'مربع واحد',
    );
    return '$_temp0';
  }

  @override
  String get gaitNameWalk => 'مشي';

  @override
  String get gaitNameTrot => 'خبب';

  @override
  String get gaitNameCanter => 'هرولة';

  @override
  String get gaitNameGallop => 'عدو';

  @override
  String get gaitNameFullGallop => 'عدو كامل';

  @override
  String get gaitNameCharge => 'انطلاقة';

  @override
  String get chooseFormat => 'نمط اللعبة';

  @override
  String get gaitAlreadyUsed => 'مستخدمة في هذه الدورة';

  @override
  String gaitSemanticLabel(int steps, String difficulty, int points) {
    return 'التقدم $steps مربعات، سؤال $difficulty، $points نقاط معرفة';
  }

  @override
  String get selectHorse => 'اختر حصانك';

  @override
  String get confirmBoldGait => 'هذه الخطوة تتطلب سؤالاً أصعب. هل نتابع؟';

  @override
  String get knowledgeStreak => 'زخم المعرفة';

  @override
  String get knowledgePointsLabel => 'نقاط المعرفة';

  @override
  String get shieldEarned => 'حصلت على درع! حصانك محمي.';

  @override
  String get grandGallopEarned => 'انطلق الركض الكبير! +2 مربعات متى شئت.';

  @override
  String get masteryBadgeEarned => 'حصلت على شارة الإتقان!';

  @override
  String get useGrandGallop => 'استخدم الركض الكبير (+2)';

  @override
  String get chooseCircuit => 'اختر مسارك';

  @override
  String get circuitOasisRoute => 'طريق الواحات';

  @override
  String get circuitCaravanTrail => 'درب القوافل';

  @override
  String get circuitGreatRide => 'مسيرة المعرفة الكبرى';

  @override
  String get circuitOasisRouteDescription =>
      'مسار قصير مشمس. مثالي للعبة سريعة.';

  @override
  String get circuitCaravanTrailDescription =>
      'مخيمات وفوانيس. مسار أكثر استراتيجية.';

  @override
  String get circuitGreatRideDescription =>
      'من النهار إلى سماء النجوم. الرحلة الكبرى.';

  @override
  String get cellOasis => 'واحة';

  @override
  String get cellKnowledge => 'معرفة';

  @override
  String get cellChallenge => 'تحدٍ';

  @override
  String get cellShortcut => 'طريق مختصر';

  @override
  String get cellDuel => 'مبارزة';

  @override
  String get cellWisdom => 'حكمة';

  @override
  String get cellRelay => 'تناوب';

  @override
  String get cellOasisDescription => 'حصانك في مأمن من الأسر هنا.';

  @override
  String get cellChallengeOffer =>
      'هل تجيب عن سؤال أصعب للتقدم مربعين إضافيين؟';

  @override
  String get acceptChallenge => 'اقبل التحدي';

  @override
  String get declineChallenge => 'احتفظ بحركتي';

  @override
  String get saveFact => 'احفظ هذه المعلومة';

  @override
  String get journeyQuestion => 'سؤال الرحلة';

  @override
  String get journeyQuestionIntro => 'سؤال أخير لتأكيد وصولك.';

  @override
  String get outcomeMoved => 'حصانك يتقدم!';

  @override
  String get outcomeStayed => 'حصانك يبقى مكانه. لم تخسر شيئًا.';

  @override
  String get outcomeCaptured => 'لقد تجاوزت خصمًا!';

  @override
  String get outcomeShieldBlocked => 'حمى الدرع الحصان.';

  @override
  String get playerProfile => 'مستوى اللاعب';

  @override
  String get profileChild => 'طفل';

  @override
  String get profileDiscovery => 'اكتشاف';

  @override
  String get profileIntermediate => 'متوسط';

  @override
  String get profileAdvanced => 'متقدم';

  @override
  String get raceRulesUpdatedTitle => 'تم تحسين قواعد السباق';

  @override
  String get raceRulesUpdatedBody =>
      'اختفى النرد: أنت الآن تختار خطوتك، ومعها مستوى المخاطرة. تقدمك وشاراتك ومشترياتك محفوظة — اللعبة الجارية فقط لا يمكن متابعتها بالقواعد الجديدة.';

  @override
  String get startNewRace => 'ابدأ سباقًا جديدًا';

  @override
  String get rulesTitle => 'القواعد';

  @override
  String get ruleChooseGaitTitle => 'اختر خطوتك';

  @override
  String get ruleChooseGaitBody =>
      'أنت تقرر عدد المربعات التي تتقدمها، من 1 إلى 6. كلما ابتعدت، صعب السؤال: 1-2 سهل، 3-4 متوسط، 5-6 صعب.';

  @override
  String get ruleAnswerToAdvanceTitle => 'أجب لتتقدم';

  @override
  String get ruleAnswerToAdvanceBody =>
      'الإجابة الصحيحة تحرك حصانك بالضبط بالمسافة التي اخترتها. والإجابة الخاطئة تتركه مكانه — لا تتراجع أبدًا.';

  @override
  String get ruleGaitCycleTitle => 'خطوة واحدة لكل دورة';

  @override
  String get ruleGaitCycleBody =>
      'كل خطوة تُستخدم مرة واحدة فقط. وعندما تنفد الست، تعود جميعها — فخطط مسبقًا.';

  @override
  String get ruleCaptureTitle => 'التجاوز والإعادة';

  @override
  String get ruleCaptureBody =>
      'الوصول تمامًا إلى حصان الخصم يعيده بهدوء إلى إسطبله — إلا إذا كان المربع واحة أو كان ذلك الحصان يحمل درع المعرفة.';

  @override
  String get ruleStreakTitle => 'اندفاع المعرفة';

  @override
  String get ruleStreakBody =>
      'ثلاث إجابات صحيحة متتالية تمنح درعًا، وخمس تمنح الركض الكبير (+2 مربع)، وعشر تمنح شارة إتقان. المكافآت تأتي من المعرفة وحدها.';

  @override
  String get ruleArrivalTitle => 'الوصول';

  @override
  String get ruleArrivalBody =>
      'اِبلغ نهاية المسار — وتجاوز الخط مسموح — ثم أجب عن سؤال الرحلة لتثبيت وصولك. الإجابة الخاطئة لا تعيدك أبدًا: تحاول ببساطة في الدور التالي.';
}
