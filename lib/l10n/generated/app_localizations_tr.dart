// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'IqraQuest';

  @override
  String get appTagline => 'Bilgi yolculuğu';

  @override
  String get onboardingWelcomeTitle => 'IqraQuest\'e Hoş Geldiniz';

  @override
  String get onboardingWelcomeSubtitle =>
      'Bir kart çek, cevapla, ilerle — ve atını Mekke\'ye ulaştır.';

  @override
  String get getStarted => 'Başla';

  @override
  String get onboardingHowTo => 'Nasıl oynanır';

  @override
  String get onboardingStepDraw => 'Bir kart çek: dörtnalını söyler';

  @override
  String get onboardingStepAnswer => 'Doğru cevapla: dörtnal senindir';

  @override
  String get onboardingStepRide => 'Atını koy ve vahaya dörtnala git';

  @override
  String get onboardingLanguageHint =>
      'Daha sonra ayarlardan değiştirebilirsin.';

  @override
  String get chooseLanguage => 'Dil seçin';

  @override
  String get play => 'Oyna';

  @override
  String get soloMode => 'Tek Kişilik';

  @override
  String get familyMode => 'Aile';

  @override
  String get dailyChallenge => 'Günlük Meydan Okuma';

  @override
  String get progress => 'İlerleme';

  @override
  String get settings => 'Ayarlar';

  @override
  String get premium => 'Premium';

  @override
  String get continueGame => 'Oyuna Devam Et';

  @override
  String get quickGame => 'Hızlı Oyun';

  @override
  String get classicGame => 'Klasik Oyun';

  @override
  String noMoveOvershoot(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Kart fazla büyük: atın Mekke\'ye $count kare uzakta ve tam olarak $count gerekiyor.',
    );
    return '$_temp0';
  }

  @override
  String get hudArrivedHeading => 'Varan atlar';

  @override
  String get hudKnowledgeShort => 'bilgi';

  @override
  String get hudStreakShort => 'seri';

  @override
  String get hudCardsShort => 'kart';

  @override
  String get boardMenuTitle => 'Oyun menüsü';

  @override
  String get boardMenuOpen => 'Oyun menüsünü aç';

  @override
  String get autoPlaySingleMove => 'Otomatik hamle';

  @override
  String get autoPlaySingleMoveHint =>
      'Kartı yalnızca bir at oynayabiliyorsa, kendiliğinden ilerler.';

  @override
  String get testerMode => 'Test modu';

  @override
  String testerModeHint(int total) {
    return 'Bu cihazdaki $total sorunun tamamını satın alma olmadan açar. Bu ayar yalnızca test sürümlerinde bulunur.';
  }

  @override
  String testerBankPlayable(int count, int total) {
    return '$total sorudan $count tanesi oynanabilir';
  }

  @override
  String get restartRace => 'Yarışı yeniden başlat';

  @override
  String get restartRaceConfirm =>
      'Süren yarış kaybolacak. Aynı biniciler ahırdan yeniden başlar.';

  @override
  String get backToHome => 'Ana Sayfaya Dön';

  @override
  String get backToHomeHint => 'Oyun kaydedilir; daha sonra devam edebilirsin.';

  @override
  String get duoGame => 'İkili Oyun';

  @override
  String horsesToMecca(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mekke\'ye $count at',
    );
    return '$_temp0';
  }

  @override
  String get formatQuickHint => 'En kısa yarış.';

  @override
  String get formatDuoHint => 'Bir akşamlık yarış.';

  @override
  String get formatClassicHint => 'Orijinaldeki gibi tam oyun.';

  @override
  String get bonusSquaresOption => 'Parkurda bonus kareler';

  @override
  String get bonusSquaresOn => '16 kare fazladan koşu verir: +5, +10 veya +20.';

  @override
  String get bonusSquaresOff =>
      'Saf parkur: bir kart tam olarak kendi dörtnalları kadar eder.';

  @override
  String get muteSound => 'Sesi kapat';

  @override
  String get unmuteSound => 'Sesi aç';

  @override
  String get chooseDifficulty => 'Zorluk seçin';

  @override
  String get difficultyEasy => 'Kolay';

  @override
  String get difficultyMedium => 'Orta';

  @override
  String get difficultyHard => 'Zor';

  @override
  String get playerName => 'İsim';

  @override
  String get chooseTeam => 'Takım seçin';

  @override
  String get ridersTitle => 'Biniciler';

  @override
  String get storeLoading => 'Mağazaya bağlanılıyor…';

  @override
  String get storeUnavailableCta => 'Mağaza kullanılamıyor';

  @override
  String get premiumBenefitBank => 'Tüm soru bankası, her biri kaynağıyla';

  @override
  String premiumBenefitUnlimited(int count) {
    return 'Mekke\'ye kadar sınırsız oyun (ücretsiz sürüm $count çekilişten sonra durur)';
  }

  @override
  String get premiumBenefitFamily =>
      'Tüm aile için tek bir satın alma, reklamsız';

  @override
  String get progressEmpty => 'İlk oyununu oyna: ilerlemen burada görünecek.';

  @override
  String get addPlayer => 'Oyuncu Ekle';

  @override
  String get startGame => 'Oyunu Başlat';

  @override
  String get yourTurn => 'Sıra Sende';

  @override
  String get categoryProphets => 'Peygamberler';

  @override
  String get categorySira => 'Siyer';

  @override
  String get categoryQuran => 'Kur\'an';

  @override
  String get categoryFaith => 'İman';

  @override
  String get categoryVirtues => 'Erdemler';

  @override
  String get category => 'Kategori';

  @override
  String get correctAnswer => 'Doğru!';

  @override
  String get incorrectAnswer => 'Tam değil…';

  @override
  String get learnMore => 'Daha fazla bilgi';

  @override
  String get questionDetailsTitle => 'Cevabın arkasında';

  @override
  String get theQuestionLabel => 'Soru';

  @override
  String get theAnswerLabel => 'Doğru cevap';

  @override
  String get explanationLabel => 'Açıklama';

  @override
  String get sourceLabel => 'Kaynak';

  @override
  String get nextPlayer => 'Sonraki Oyuncu';

  @override
  String get rolledSix => 'Altı geldi! Yeni tur — yeni soru.';

  @override
  String get playAgain => 'Tekrar Oyna';

  @override
  String get protectedSquareLabel => 'Korumalı Kare';

  @override
  String get freeBankExhaustedMessage =>
      'Bu oyunda ücretsiz sürümün tüm soruları kullanıldı.';

  @override
  String get victory => 'Zafer!';

  @override
  String get gameOver => 'Oyun Bitti';

  @override
  String get gamesPlayed => 'Oynanan Oyunlar';

  @override
  String get winRate => 'Kazanma Oranı';

  @override
  String get questionsAnswered => 'Cevaplanan Sorular';

  @override
  String get streak => 'Gün Serisi';

  @override
  String get premiumTitle => 'IqraQuest Premium';

  @override
  String get premiumUnlockAll =>
      'Tüm soru bankasının ve her zorluk seviyesinin kilidini açın';

  @override
  String get premiumOneTime => 'Tek seferlik ödeme — abonelik yok';

  @override
  String get restorePurchases => 'Satın Alımları Geri Yükle';

  @override
  String get purchaseSuccess => 'Teşekkürler! Premium artık aktif.';

  @override
  String get purchaseError =>
      'Satın alma tamamlanamadı. Lütfen daha sonra tekrar deneyin.';

  @override
  String get language => 'Dil';

  @override
  String get reduceMotion => 'Hareketi Azalt';

  @override
  String get soundEffects => 'Ses Efektleri';

  @override
  String get howToPlay => 'Nasıl Oynanır';

  @override
  String get privacySummary =>
      'IqraQuest tamamen cihazınızda çalışır: hesap yok, reklam yok, izleme yok ve hiçbir şey internete gönderilmez.';

  @override
  String defaultPlayerName(num number) {
    return 'Oyuncu $number';
  }

  @override
  String aiPlayerName(num number) {
    return 'Binici $number';
  }

  @override
  String opponentWins(String name) {
    return 'Yarışı $name kazandı!';
  }

  @override
  String get wellRidden => 'Güzel bir sürüştü — öğrenilen her soru değerlidir.';

  @override
  String horseSemantics(String color, num number) {
    return '$color at $number';
  }

  @override
  String get teamEmerald => 'zümrüt';

  @override
  String get teamSaphir => 'safir';

  @override
  String get teamGrenat => 'lal';

  @override
  String get teamSafran => 'safran';

  @override
  String premiumCta(String price) {
    return 'Tümünün kilidini aç — $price';
  }

  @override
  String premiumQuestionsIncluded(num count) {
    return 'Kaynağıyla birlikte $count doğrulanmış soru — ve soru bankası büyümeye devam ediyor.';
  }

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get about => 'Hakkında';

  @override
  String get aboutDialogTitle => 'IqraQuest Hakkında';

  @override
  String versionLabel(String version) {
    return 'Sürüm $version';
  }

  @override
  String copyrightNotice(String year) {
    return '© $year IqraQuest. Tüm hakları saklıdır.';
  }

  @override
  String get originalWorkNotice =>
      'IqraQuest, oyun konsepti, kuralları, çizimleri, adı ve içeriği telif hakkıyla korunan özgün eserlerdir. Yazılı izin olmadan tamamen veya kısmen çoğaltılması, taklit edilmesi veya uyarlanması yasaktır.';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get genericError => 'Bir şeyler ters gitti.';

  @override
  String get parentalGateTitle => 'Ebeveynler için bir soru';

  @override
  String get parentalGateInstruction => 'Devam etmek için bunu çöz.';

  @override
  String get placeMecca => 'Mekke';

  @override
  String get placeMedina => 'Medine';

  @override
  String get placeAlAqsa => 'Mescid-i Aksa';

  @override
  String get placeArafat => 'Arafat Dağı';

  @override
  String get placeMina => 'Mina';

  @override
  String circuitSpecialSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count özel kare',
    );
    return '$_temp0';
  }

  @override
  String get drawCard => 'Kart çek';

  @override
  String get drawnCardTitle => 'Çekilen kart';

  @override
  String cardWorth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dörtnallık kart',
    );
    return '$_temp0';
  }

  @override
  String gaitSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kare',
      one: '$count kare',
    );
    return '$_temp0';
  }

  @override
  String get gaitNameWalk => 'Adım';

  @override
  String get gaitNameTrot => 'Tırıs';

  @override
  String get gaitNameCanter => 'Eşkin';

  @override
  String get gaitNameGallop => 'Dörtnal';

  @override
  String get gaitNameFullGallop => 'Doludizgin';

  @override
  String get gaitNameCharge => 'Hücum';

  @override
  String get chooseFormat => 'Oyun formatı';

  @override
  String get gaitAlreadyUsed => 'Bu turda kullanıldı';

  @override
  String gaitSemanticLabel(int steps, String difficulty, int points) {
    return '$steps kare ilerle, $difficulty soru, $points bilgi puanı';
  }

  @override
  String get selectHorse => 'Atını seç';

  @override
  String get knowledgeStreak => 'Üst üste doğru cevap';

  @override
  String get knowledgePointsLabel => 'Bilgi puanı';

  @override
  String get shieldEarned => 'Kalkan kazandın! Atın korunuyor.';

  @override
  String get grandGallopEarned => 'Büyük Dörtnal açıldı! İstediğinde +2 kare.';

  @override
  String get masteryBadgeEarned => 'Ustalık rozeti kazandın!';

  @override
  String get useGrandGallop => 'Büyük Dörtnal kullan (+2)';

  @override
  String get chooseCircuit => 'Parkurunu seç';

  @override
  String get circuitOasisRoute => 'Vahalar Yolu';

  @override
  String get circuitCaravanTrail => 'Kervan Yolu';

  @override
  String get circuitGreatRide => 'Büyük Bilgi Yolculuğu';

  @override
  String get circuitOasisRouteDescription =>
      'En sakin parkur: vahalar, az sürpriz.';

  @override
  String get circuitCaravanTrailDescription =>
      'Yol boyunca meydan okumalar ve bayraklar. Daha taktik.';

  @override
  String get circuitGreatRideDescription =>
      'En hareketli parkur: meydan okumalar, kısayollar ve düellolar.';

  @override
  String get cellOasis => 'Vaha';

  @override
  String get cellKnowledge => 'Bilgi';

  @override
  String get cellChallenge => 'Meydan okuma';

  @override
  String get cellShortcut => 'Kestirme';

  @override
  String get cellDuel => 'Düello';

  @override
  String get cellWisdom => 'Hikmet';

  @override
  String get cellRelay => 'Bayrak';

  @override
  String get cellOasisDescription => 'Atın burada yakalanmaktan güvende.';

  @override
  String get cellChallengeOffer =>
      '2 kare fazla ilerlemek için daha zor bir soru cevaplansın mı?';

  @override
  String get acceptChallenge => 'Meydan okumayı kabul et';

  @override
  String get declineChallenge => 'Hamlemi koru';

  @override
  String get saveFact => 'Bu bilgiyi sakla';

  @override
  String get journeyQuestion => 'Yolculuk sorusu';

  @override
  String get journeyQuestionIntro => 'Varışını onaylamak için son bir soru.';

  @override
  String opponentThinking(String name) {
    return '$name düşünüyor…';
  }

  @override
  String opponentDrew(String name, int count) {
    return '$name bir $count çekti';
  }

  @override
  String correctAnswerWas(String answer) {
    return 'Doğru cevap: $answer';
  }

  @override
  String get scoreboardTitle => 'Yarış Tablosu';

  @override
  String scoreboardCorrect(int count) {
    return '$count doğru';
  }

  @override
  String scoreboardBestStreak(int count) {
    return '$count seri';
  }

  @override
  String get playAgainSameRiders => 'Bir Yarış Daha!';

  @override
  String opponentMoved(String name) {
    return '$name ilerliyor!';
  }

  @override
  String opponentStayed(String name) {
    return '$name yerinde kalıyor.';
  }

  @override
  String get shareScore => 'Paylaş';

  @override
  String shareVictoryText(String name, int points) {
    return '$name IqraQuest yarışını $points ⭐ ile kazandı! Sıra sende mi?';
  }

  @override
  String shareDailyText(int score, int total) {
    return 'IqraQuest günün mücadelesinde $score/$total! Geçebilir misin?';
  }

  @override
  String get dailyChallengeDone => 'Günün mücadelesi tamam';

  @override
  String dailyChallengeScore(num score, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$total sorudan $score doğru',
    );
    return '$_temp0';
  }

  @override
  String get dailyChallengeComeBack => 'Yarın yeni bir mücadele için gel.';

  @override
  String get aiOpponentsLabel => 'Rakipler';

  @override
  String get playersLabel => 'Oyuncular';

  @override
  String get outcomeMoved => 'Atın ilerliyor!';

  @override
  String get outcomeStayed => 'Atın yerinde kalıyor. Kaybın yok.';

  @override
  String get outcomeCaptured => 'Rakibin atını yakaladın!';

  @override
  String get outcomeExited => 'Atın ahırdan çıkıyor!';

  @override
  String get outcomeNoLegalMove =>
      'Bu kart hiçbir atı hareket ettiremiyor. Sıradaki tur!';

  @override
  String get noExitHint => 'Ahırdan bir at çıkarmak için 6 gerekir.';

  @override
  String get bonusTurnHint => 'Bonus tur: 6 sana bir kez daha oynatıyor!';

  @override
  String get celebrateSixTitle => 'ALTI!';

  @override
  String get celebrateSixBody => 'Bu turdan sonra yeniden çekeceksin.';

  @override
  String get celebrateSixExitBody =>
      'Bir at çıkabilir — ve yeniden oynayacaksın!';

  @override
  String get celebrateExitTitle => 'Kapı açık!';

  @override
  String get celebrateExitBody => 'Bir at ahırdan çıkabilir.';

  @override
  String get celebrateCaptureTitle => 'Yakaladın!';

  @override
  String get celebrateCaptureBody => 'Rakibin atı ahırına dönüyor.';

  @override
  String get celebrateCapturedTitle => 'Yakalandın…';

  @override
  String get celebrateCapturedBody =>
      'Atın ahıra dönüyor. Bir 6 onu yeniden çıkarır.';

  @override
  String get celebrateArrivalTitle => 'Mekke!';

  @override
  String get celebrateArrivalBody =>
      'Atın vardı. Resmileştirmek için son bir soru!';

  @override
  String get freeLimitTitle => 'Ücretsiz yarışın sonu';

  @override
  String freeLimitLeader(String name) {
    return 'Önde: $name';
  }

  @override
  String freeLimitBody(int count) {
    return 'Ücretsiz sürüm $count çekilişten sonra durur. Premium ile yarış Mekke\'ye kadar sürer.';
  }

  @override
  String get freeLimitCta => 'Sınırsız yarışın kilidini aç';

  @override
  String drawsCounter(int count, int max) {
    return 'Çekiliş: $count / $max';
  }

  @override
  String moveChoiceTitle(int count) {
    return 'Bu $count ile ne yapacaksın?';
  }

  @override
  String get moveChoiceExit => 'Ahırdan bir at çıkar';

  @override
  String moveChoiceAdvance(int number, int count) {
    return 'At $number: $count ilerle';
  }

  @override
  String moveHintCapture(int value) {
    return 'yakala! +$value';
  }

  @override
  String get moveHintFinish => 'varış!';

  @override
  String get moveHintOasis => 'vaha';

  @override
  String opponentExits(String name) {
    return '$name bir at çıkarıyor!';
  }

  @override
  String opponentNoMove(String name) {
    return '$name hiçbir şeyi oynatamıyor.';
  }

  @override
  String opponentReplays(String name) {
    return '$name 6 çekti ve yeniden oynuyor!';
  }

  @override
  String opponentCaptured(String name) {
    return '$name bir at yakalıyor!';
  }

  @override
  String get outcomeShieldBlocked => 'Kalkan atı korudu.';

  @override
  String get outcomeShelteredByOasis =>
      'Vaha o atı koruyor: kimse ahıra dönmüyor.';

  @override
  String get playerProfile => 'Soru seviyesi';

  @override
  String get levelBeginner => 'İlk adımlar';

  @override
  String get levelBeginnerHint =>
      'İlk adımlar: herkesin zaten bildiği en temel bilgiler.';

  @override
  String get levelEasy => 'Kolay';

  @override
  String get levelIntermediate => 'Orta';

  @override
  String get levelExpert => 'Uzman';

  @override
  String get levelMixed => 'Karışık';

  @override
  String get levelMixedHint =>
      'Karışık: her kart kendi seviyesini çeker, ilk adımlardan uzmana.';

  @override
  String get raceRulesUpdatedTitle => 'Yarış kuralları geliştirildi';

  @override
  String get raceRulesUpdatedBody =>
      'Kurallar değişti: artık bir kart çekiyorsun ve kartın değeri hem mesafeyi hem zorluğu veriyor. İlerlemen, rozetlerin ve satın alımların korunuyor — yalnızca devam eden oyun yeni kurallarla sürdürülemiyor.';

  @override
  String get startNewRace => 'Yeni bir yarış başlat';

  @override
  String get rulesTitle => 'Kurallar';

  @override
  String get ruleGoalTitle => 'Yarışı kazanmak';

  @override
  String get ruleGoalBody =>
      'Her oyuncu dört atını tahtanın ortasındaki Mekke\'ye götürür. Oyundan önce masa kaç atın varması gerektiğini seçer: hızlı yarış için bir, ikili yarış için iki, klasik oyun için dördü. Bunu ilk başaran kazanır.';

  @override
  String get ruleKnowledgeTitle => 'Bilgi puanları';

  @override
  String get ruleKnowledgeBody =>
      'Çubuktaki yıldız bilgi puanlarını sayar: her doğru cevap için bir, Bilgi karesinde bir tane daha. Atını ilerletmezler — ne öğrendiğini söyler ve oyun varıştan önce biterse oyuncuları ayırırlar.';

  @override
  String get ruleSpecialCellsTitle => 'Özel kareler';

  @override
  String get ruleSpecialCellsBody =>
      'Seçtiğin parkurda bir şey yapan kareler var, dört çeyreğinde de aynıları: Vaha yakalanmaktan korur, Bilgi bir bilgi puanı verir, Meydan okuma +2 dörtnal için daha zor bir soru sunar, Kısayol öne geçmek için zor bir soru, Hikmet ise saklayacağın bir bilgi verir. Kaybedilen bir Meydan okuma ya da Kısayol yalnızca bonusa mal olur: atın yerinde kalır.';

  @override
  String get ruleDrawCardTitle => 'Bir kart çek';

  @override
  String get ruleDrawCardBody =>
      'Sıran gelince bir kart çek. Kart değerini göstererek dönüyor — «5 dörtnallık kart» — sonra sorusu açılır, her zaman başta seçtiğin düzeyde: kolay, orta, uzman ya da karışık. Yani doğru cevabın değerini cevaplamadan önce bilirsin.';

  @override
  String get ruleAnswerToAdvanceTitle => 'İlerlemek için cevapla';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Doğru cevap kartın dörtnallarını kazandırır: bir dörtnal, bir kare. Sonra onları alacak atı seç — nereye varacağını görmek için dokun, ardından altın karesine sürükle. Bırakmak hamledir: öncesinde hiçbir şey oynamaz, sonrasında onay istenmez. Yanlış cevap hiçbir şeyi oynatmaz: asla geri gitmezsin.';

  @override
  String get ruleEscalierTitle => 'Mekke\'ye çıkan merdiven';

  @override
  String get ruleEscalierBody =>
      'Tahtada tam bir tur attıktan sonra atın kendi merdiveninin beş basamağını çıkıp Mekke\'ye ulaşır. Orada kimse ona yetişemez.';

  @override
  String get ruleExitTitle => 'Ahırdan çıkmak';

  @override
  String get ruleExitBody =>
      'Her oyuncunun dört atı var ve ilki zaten başlangıç karesinde: ilk karttan itibaren oynarsın, bekleyecek bir şey yok. Diğer üçü 6 ile ahırdan çıkar — doğru cevap ver, at başlangıç karesine yerleşir. İki atın asla aynı kareyi paylaşmaz: başlangıç karende duran atın, ilerleyene kadar kapıyı kapalı tutar.';

  @override
  String get ruleSixTitle => '6 yeniden oynatır';

  @override
  String get ruleSixBody =>
      'Zardaki gibi: 6 çekersen, cevabın doğru ya da yanlış olsun, turundan sonra yeniden oynarsın.';

  @override
  String get ruleCaptureTitle => 'Yakala ve ahıra yolla';

  @override
  String get ruleCaptureBody =>
      'Rakibin atının bulunduğu kareye tam olarak konmak onu sakince ahırına yollar — kare bir vaha değilse ya da o at bir bilgi kalkanı taşımıyorsa. Yakalamak ödüllendirilir: atın hemen 20 dörtnal ileri sıçrar. Ahırdan çıkan bir at başlangıç karesinde her zaman yakalar.';

  @override
  String get ruleStreakTitle => 'Doğru cevap serisi';

  @override
  String get ruleStreakBody =>
      'Üst üste üç doğru cevap bir kalkan, beş Büyük Dörtnal, on ise ustalık rozeti kazandırır. Büyük Dörtnal kendiliğinden harcanır ve yalnızca +2 dörtnalı bitişe ulaşmaya yettiğinde. Bonuslar yalnızca bilgiden gelir.';

  @override
  String get ruleArrivalTitle => 'Varış';

  @override
  String get ruleArrivalBody =>
      'Varış tam sayıyla kazanılır: Mekke\'ye üç kare kala tam olarak 3 gerekir. 4, 5 ya da 6 atı yerinde bırakır, doğru kartı bekler. Vardığında varışını resmileştirmek için Yolculuk Sorusu\'nu cevapla; yanlış cevap seni asla geri götürmez, sıradaki turda yeniden denersin.';

  @override
  String get hapticFeedback => 'Titreşim';

  @override
  String squaresWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dörtnal kazanıldı',
    );
    return '$_temp0';
  }

  @override
  String get chooseHorseToMove => 'Bir at seç';

  @override
  String get touchHorseHint => 'Nereye gideceğini görmek için bir ata dokun';

  @override
  String get dragHorseToDestination => 'Atı altın karesine sürükle';

  @override
  String get bonusLabel => 'BONUS';

  @override
  String bonusPlus(int value) {
    return '+$value dörtnal';
  }

  @override
  String get captureBonusLabel => 'YAKALAMA';

  @override
  String captureBonusRide(int value) {
    return 'Yakaladın! Atın $value dörtnal ileri sıçrıyor.';
  }

  @override
  String bonusRide(int value) {
    return 'Bonus kare! Atın $value kare daha ilerliyor.';
  }

  @override
  String cardWasWorth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bu kart $count dörtnal değerindeydi.',
    );
    return '$_temp0';
  }

  @override
  String get bonusMissedNote => 'Bonus kaçtı: atın olduğu yerde kalıyor.';

  @override
  String get answerToReveal => 'Değerini görmek için cevapla';

  @override
  String opponentPlaces(String name) {
    return '$name bir at seçiyor…';
  }

  @override
  String opponentBonus(String name, int value) {
    return '$name +$value bonus kazandı!';
  }

  @override
  String get leaderLabel => 'Önde';

  @override
  String tookTheLead(String name) {
    return '$name öne geçti!';
  }

  @override
  String bonusSquareSemantics(int value) {
    return 'Bonus kare +$value';
  }

  @override
  String moveHintBonus(int value) {
    return 'Bonus +$value';
  }

  @override
  String get bonusSquaresTeaser =>
      'Tahtada 16 bonus kare seni bekliyor: +5, +10 ve nadir +20.';

  @override
  String get ridersSubtitle =>
      'Her binici seviyesini seçer; kart yalnızca mesafeyi belirler.';

  @override
  String get ruleBonusTitle => 'Bonus kareler';

  @override
  String get ruleBonusBody =>
      'Masa onları tutarsa, her oyunda tahtaya on altı bonus kare dağıtılır, çeyrek başına dört. Tam üzerinde duran at hemen +5, +10 ya da +20 dörtnal daha ilerler — ve bu koşu onu tam başka bir bonus karesine indirirse o da patlar: bonuslar zincirlenir. Her kare turda bir kez öder ve herkes için oyunda kalır. Onlar olmadan bir kart tam olarak kendi dörtnalları kadar eder.';

  @override
  String get newGameTitle => 'Yeni oyun';

  @override
  String get setupWhoPlays => 'Kim oynuyor?';

  @override
  String get soloTileCaption => 'bilgisayara karşı';

  @override
  String get computerLevelLabel => 'Bilgisayar seviyesi';

  @override
  String get setupRaceLength => 'Oyun süresi';

  @override
  String get raceLengthShort => 'Kısa oyun';

  @override
  String get raceLengthMedium => 'Orta oyun';

  @override
  String get raceLengthFull => 'Tam oyun';

  @override
  String get setupCourse => 'Parkur';

  @override
  String get courseCalm => 'Sakin';

  @override
  String get courseLively => 'Hareketli';

  @override
  String get courseIntense => 'Yoğun';

  @override
  String get courseSquareOasis => 'Vaha: atın orada güvende';

  @override
  String get courseSquareKnowledge => 'Bilgi: +1 bilgi puanı';

  @override
  String get courseSquareChallenge => 'Meydan okuma: +2 kare için ek soru';

  @override
  String get courseSquareShortcut => 'Kestirme: öne atlamak için zor bir soru';

  @override
  String get courseSquareWisdom => 'Hikmet: keşfedip saklayacağın bir bilgi';

  @override
  String get levelEasyHint => 'Kolay: ilk öğrenilenler üzerine basit sorular.';

  @override
  String get levelIntermediateHint =>
      'Orta: kıssaları ve kuralları iyi bilenler için.';

  @override
  String get levelExpertHint =>
      'Uzman: en ayrıntılı sorular, ayet ve hadislerle.';
}
