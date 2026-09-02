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
      'اسحب بطاقة، أجب، تقدّم — وأوصل حصانك إلى مكة.';

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
  String get ridersTitle => 'الفرسان';

  @override
  String get storeLoading => 'جارٍ الاتصال بالمتجر…';

  @override
  String get storeUnavailableCta => 'المتجر غير متاح';

  @override
  String get premiumBenefitBank => 'بنك الأسئلة كاملاً، كل سؤال بمصدره';

  @override
  String premiumBenefitUnlimited(int count) {
    return 'مباريات غير محدودة حتى مكة (النسخة المجانية تتوقف بعد $count سحبة)';
  }

  @override
  String get premiumBenefitFamily => 'شراء واحد لكل العائلة، بدون إعلانات';

  @override
  String get progressEmpty => 'العب أول مباراة: سيظهر تقدمك هنا.';

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
  String get learnMore => 'اعرف المزيد';

  @override
  String get questionDetailsTitle => 'خلف الإجابة';

  @override
  String get theQuestionLabel => 'السؤال';

  @override
  String get theAnswerLabel => 'الإجابة الصحيحة';

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
  String get premiumUnlockAll => 'افتح بنك الأسئلة كاملاً وكل مستويات الصعوبة';

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
  String premiumCta(String price) {
    return 'فتح الكل — $price';
  }

  @override
  String premiumQuestionsIncluded(num count) {
    return '$count سؤالًا موثقًا، لكل منها مصدره — والمجموعة تكبر باستمرار.';
  }

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get about => 'حول التطبيق';

  @override
  String get aboutDialogTitle => 'حول إكرا كويست';

  @override
  String versionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String copyrightNotice(String year) {
    return '© $year IqraQuest. جميع الحقوق محفوظة.';
  }

  @override
  String get originalWorkNotice =>
      'إكرا كويست، وفكرة اللعبة وقواعدها ورسومها واسمها ومحتواها أعمال أصلية محمية بحقوق النشر. يُمنع أي نسخ أو تقليد أو اقتباس، كليًا أو جزئيًا، دون إذن كتابي.';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get genericError => 'حدث خطأ ما.';

  @override
  String get parentalGateTitle => 'سؤال لأولياء الأمور';

  @override
  String get parentalGateInstruction => 'حل هذه المسألة للمتابعة.';

  @override
  String get placeMecca => 'مكة';

  @override
  String get placeMedina => 'المدينة';

  @override
  String get placeAlAqsa => 'المسجد الأقصى';

  @override
  String get placeArafat => 'عرفات';

  @override
  String get placeMina => 'منى';

  @override
  String circuitSpecialSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مربع خاص',
      many: '$count مربعًا خاصًا',
      few: '$count مربعات خاصة',
      two: 'مربعان خاصان',
      one: 'مربع خاص واحد',
      zero: 'لا مربعات خاصة',
    );
    return '$_temp0';
  }

  @override
  String get drawCard => 'اسحب بطاقة';

  @override
  String get drawnCardTitle => 'البطاقة المسحوبة';

  @override
  String cardWorth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يساوي $count مربع',
      many: 'يساوي $count مربعًا',
      few: 'يساوي $count مربعات',
      two: 'يساوي مربعين',
      one: 'يساوي مربعًا واحدًا',
    );
    return '$_temp0';
  }

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
      'أهدأ مسار: واحات وقليل من المفاجآت.';

  @override
  String get circuitCaravanTrailDescription =>
      'تحديات ومحطات على الطريق. أكثر تكتيكًا.';

  @override
  String get circuitGreatRideDescription =>
      'أكثر المسارات حيوية: تحديات واختصارات ومبارزات.';

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
  String opponentThinking(String name) {
    return '$name يفكّر…';
  }

  @override
  String opponentDrew(String name, int count) {
    return '$name يسحب $count';
  }

  @override
  String correctAnswerWas(String answer) {
    return 'الإجابة الصحيحة: $answer';
  }

  @override
  String get scoreboardTitle => 'لوحة السباق';

  @override
  String scoreboardCorrect(int count) {
    return '$count إجابات صحيحة';
  }

  @override
  String scoreboardBestStreak(int count) {
    return 'سلسلة من $count';
  }

  @override
  String get playAgainSameRiders => 'سباق آخر!';

  @override
  String opponentMoved(String name) {
    return '$name يتقدم!';
  }

  @override
  String opponentStayed(String name) {
    return '$name يبقى مكانه.';
  }

  @override
  String get shareScore => 'مشاركة';

  @override
  String shareVictoryText(String name, int points) {
    return 'فاز $name بسباق IqraQuest بـ $points ⭐! هل تجرّب دورك؟';
  }

  @override
  String shareDailyText(int score, int total) {
    return '$score/$total في تحدي اليوم من IqraQuest! هل تتفوّق عليّ؟';
  }

  @override
  String get dailyChallengeDone => 'اكتمل تحدي اليوم';

  @override
  String dailyChallengeScore(num score, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score إجابة صحيحة من $total',
      many: '$score إجابة صحيحة من $total',
      few: '$score إجابات صحيحة من $total',
      two: 'إجابتان صحيحتان من $total',
      one: 'إجابة صحيحة واحدة من $total',
      zero: 'لا إجابات صحيحة من $total',
    );
    return '$_temp0';
  }

  @override
  String get dailyChallengeComeBack => 'عُد غدًا لتحدٍّ جديد.';

  @override
  String get aiOpponentsLabel => 'الخصوم';

  @override
  String get playersLabel => 'اللاعبون';

  @override
  String get outcomeMoved => 'حصانك يتقدم!';

  @override
  String get outcomeStayed => 'حصانك يبقى مكانه. لم تخسر شيئًا.';

  @override
  String get outcomeCaptured => 'لقد أسرت حصان الخصم!';

  @override
  String get outcomeExited => 'حصانك يخرج من الإسطبل!';

  @override
  String get outcomeNoLegalMove =>
      'هذه البطاقة لا تحرّك أي حصان. الدور التالي!';

  @override
  String get noExitHint => 'تحتاج إلى 6 لإخراج حصان من الإسطبل.';

  @override
  String get bonusTurnHint => 'دور إضافي: الرقم 6 يمنحك دورًا آخر!';

  @override
  String get celebrateSixTitle => 'ستة!';

  @override
  String get celebrateSixBody => 'ستسحب مرة أخرى بعد هذا الدور.';

  @override
  String get celebrateSixExitBody => 'يمكن لحصان الخروج — وستلعب مرة أخرى!';

  @override
  String get celebrateExitTitle => 'خروج!';

  @override
  String get celebrateExitBody => 'يمكن لحصان مغادرة الإسطبل.';

  @override
  String get celebrateCaptureTitle => 'أسر!';

  @override
  String get celebrateCaptureBody => 'حصان الخصم يعود إلى إسطبله.';

  @override
  String get celebrateCapturedTitle => 'أُسر…';

  @override
  String get celebrateCapturedBody =>
      'حصانك يعود إلى الإسطبل. سيخرج مجددًا بالرقم 6.';

  @override
  String get celebrateArrivalTitle => 'مكة!';

  @override
  String get celebrateArrivalBody => 'وصل حصانك. سؤال أخير للتثبيت!';

  @override
  String get freeLimitTitle => 'نهاية السباق المجاني';

  @override
  String freeLimitLeader(String name) {
    return 'في الصدارة: $name';
  }

  @override
  String freeLimitBody(int count) {
    return 'تتوقف النسخة المجانية بعد $count سحبة. مع بريميوم، يمتد السباق حتى مكة.';
  }

  @override
  String get freeLimitCta => 'افتح السباق غير المحدود';

  @override
  String drawsCounter(int count, int max) {
    return 'السحبات: $count من $max';
  }

  @override
  String moveChoiceTitle(int count) {
    return 'ماذا ستفعل بهذا الرقم $count؟';
  }

  @override
  String get moveChoiceExit => 'إخراج حصان من الإسطبل';

  @override
  String moveChoiceAdvance(int number, int count) {
    return 'الحصان $number: تقدّم $count';
  }

  @override
  String get moveHintCapture => 'أسر!';

  @override
  String get moveHintFinish => 'الوصول!';

  @override
  String get moveHintOasis => 'واحة';

  @override
  String opponentExits(String name) {
    return '$name يُخرج حصانًا!';
  }

  @override
  String opponentNoMove(String name) {
    return '$name لا يستطيع تحريك شيء.';
  }

  @override
  String opponentReplays(String name) {
    return '$name سحب 6 ويلعب مجددًا!';
  }

  @override
  String opponentCaptured(String name) {
    return '$name يأسر حصانًا!';
  }

  @override
  String get outcomeShieldBlocked => 'حمى الدرع الحصان.';

  @override
  String get playerProfile => 'مستوى الأسئلة';

  @override
  String get levelEasy => 'سهل';

  @override
  String get levelIntermediate => 'متوسط';

  @override
  String get levelExpert => 'خبير';

  @override
  String get raceRulesUpdatedTitle => 'تم تحسين قواعد السباق';

  @override
  String get raceRulesUpdatedBody =>
      'تغيّرت القواعد: تسحب الآن بطاقة، وقيمتها تحدد المسافة والصعوبة معًا. تقدّمك وأوسمتك ومشترياتك محفوظة — الجولة الجارية وحدها لا يمكن استئنافها بالقواعد الجديدة.';

  @override
  String get startNewRace => 'ابدأ سباقًا جديدًا';

  @override
  String get rulesTitle => 'القواعد';

  @override
  String get ruleDrawCardTitle => 'اسحب بطاقة';

  @override
  String get ruleDrawCardBody =>
      'في دورك، اسحب بطاقة: يظهر سؤالها فورًا، دائمًا على مستواك — سهل أو متوسط أو خبير — الذي اخترته في البداية. أما قيمتها، من 1 إلى 6 مربعات، فتبقى مخفية حتى تجيب.';

  @override
  String get ruleAnswerToAdvanceTitle => 'أجب لتتقدم';

  @override
  String get ruleAnswerToAdvanceBody =>
      'الإجابة الصحيحة تكسبك مربعات البطاقة. اختر بعدها الحصان الذي يأخذها: المسه لترى مربع وصوله، ثم اسحبه إليه — الإفلات هو الحركة. الإجابة الخاطئة تترك كل شيء مكانه: لا تتراجع أبدًا.';

  @override
  String get ruleEscalierTitle => 'السلّم إلى مكة';

  @override
  String get ruleEscalierBody =>
      'بعد دورة كاملة حول اللوحة، يصعد حصانك درجات سلّمه الخمس إلى مكة. وهناك لا يستطيع أحد اللحاق به.';

  @override
  String get ruleExitTitle => 'الخروج من الإسطبل';

  @override
  String get ruleExitBody =>
      'لكل لاعب أربعة أحصنة، والأول منها يقف أصلًا على مربع الانطلاق: تلعب منذ البطاقة الأولى دون انتظار. أما الثلاثة الباقية فتخرج من الإسطبل بالرقم 6: أجب إجابة صحيحة ليقف الحصان على مربع الانطلاق — ولأن الرقم 6 يعيد اللعب، ينطلق فورًا. والاختيار لك: إخراج آخر أو التقدّم.';

  @override
  String get ruleSixTitle => 'الرقم 6 يعيد اللعب';

  @override
  String get ruleSixBody =>
      'كما مع النرد: حين تسحب 6 تلعب مجددًا بعد دورك، سواء أصبت أم لا. ولا يمكن لحصانين من أحصنتك أن يتشاركا المربع نفسه أبدًا.';

  @override
  String get ruleCaptureTitle => 'الأسر والإعادة';

  @override
  String get ruleCaptureBody =>
      'الوصول تمامًا إلى حصان الخصم يعيده بهدوء إلى إسطبله — إلا إذا كان المربع واحة أو كان ذلك الحصان يحمل درع المعرفة. والحصان الخارج من إسطبله يأسر دائمًا على مربع انطلاقه.';

  @override
  String get ruleStreakTitle => 'اندفاع المعرفة';

  @override
  String get ruleStreakBody =>
      'ثلاث إجابات صحيحة متتالية تمنح درعًا، وخمس تمنح الركض الكبير، وعشر تمنح شارة إتقان. يُصرف الركض الكبير تلقائيًا، وفقط حين تكفي مربعاته الاثنان لبلوغ النهاية. المكافآت تأتي من المعرفة وحدها.';

  @override
  String get ruleArrivalTitle => 'الوصول';

  @override
  String get ruleArrivalBody =>
      'اِبلغ نهاية المسار — وتجاوز الخط مسموح — ثم أجب عن سؤال الرحلة لتثبيت وصولك. الإجابة الخاطئة لا تعيدك أبدًا: تحاول ببساطة في الدور التالي.';

  @override
  String get hapticFeedback => 'الاهتزاز';

  @override
  String squaresWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مربع',
      many: '$count مربعًا',
      few: '$count مربعات',
      two: 'مربعان',
      one: 'مربع واحد',
      zero: 'لا مربعات',
    );
    return '$_temp0';
  }

  @override
  String get chooseHorseToMove => 'اختر حصانًا';

  @override
  String get touchHorseHint => 'المس حصانًا لترى إلى أين سيذهب';

  @override
  String get dragHorseToDestination => 'اسحب الحصان إلى مربعه الذهبي';

  @override
  String get bonusLabel => 'مكافأة';

  @override
  String bonusPlus(int value) {
    return '+$value مربعات';
  }

  @override
  String bonusRide(int value) {
    return 'مربع مكافأة! يتقدّم حصانك $value مربعات إضافية.';
  }

  @override
  String cardWasWorth(int value) {
    return 'كانت هذه البطاقة تساوي $value مربعات.';
  }

  @override
  String get answerToReveal => 'أجب لتكشف قيمتها';

  @override
  String opponentPlaces(String name) {
    return '$name يختار حصانًا…';
  }

  @override
  String opponentBonus(String name, int value) {
    return '$name يحصل على مكافأة +$value!';
  }

  @override
  String get leaderLabel => 'في المقدمة';

  @override
  String tookTheLead(String name) {
    return '$name يتصدّر السباق!';
  }

  @override
  String bonusSquareSemantics(int value) {
    return 'مربع مكافأة +$value';
  }

  @override
  String moveHintBonus(int value) {
    return 'مكافأة +$value';
  }

  @override
  String get bonusSquaresTeaser =>
      '16 مربع مكافأة على اللوحة: +5 و+10 و+20 النادر.';

  @override
  String get ridersSubtitle =>
      'كل فارس يختار مستواه؛ البطاقة تحدّد المسافة فقط.';

  @override
  String get ruleBonusTitle => 'مربعات المكافأة';

  @override
  String get ruleBonusBody =>
      'توزَّع ستة عشر مربع مكافأة على اللوحة في كل لعبة، أربعة في كل ربع. الحصان الذي يتوقف عليها تمامًا يتقدّم فورًا +5 أو +10 أو +20 مربعًا — مرة واحدة في الدور، ويبقى المربع في اللعب للجميع.';
}
