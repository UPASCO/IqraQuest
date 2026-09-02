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
  String get backToHome => 'Ana Sayfaya Dön';

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
      other: '$count kare değerinde',
      one: '$count kare değerinde',
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
  String get knowledgeStreak => 'Bilgi ivmesi';

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
  String get moveHintCapture => 'yakala!';

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
  String get playerProfile => 'Soru seviyesi';

  @override
  String get levelEasy => 'Kolay';

  @override
  String get levelIntermediate => 'Orta';

  @override
  String get levelExpert => 'Uzman';

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
  String get ruleDrawCardTitle => 'Bir kart çek';

  @override
  String get ruleDrawCardBody =>
      'Sıran geldiğinde bir kart çek. 1 ile 6 arasındaki değeri kaç kare ilerleyeceğindir. Soru ise her zaman kendi seviyendedir — kolay, orta ya da uzman — başta bütün kartların için seçtiğin seviye.';

  @override
  String get ruleAnswerToAdvanceTitle => 'İlerlemek için cevapla';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Doğru cevap atını kartta yazan kare kadar ilerletir. Yanlış cevap onu yerinde bırakır: asla geri gitmezsin.';

  @override
  String get ruleEscalierTitle => 'Mekke\'ye çıkan merdiven';

  @override
  String get ruleEscalierBody =>
      'Tahtada tam bir tur attıktan sonra atın kendi merdiveninin beş basamağını çıkıp Mekke\'ye ulaşır. Orada kimse ona yetişemez.';

  @override
  String get ruleExitTitle => 'Ahırdan çıkmak';

  @override
  String get ruleExitBody =>
      'Her oyuncunun ahırda dört atı vardır. Bir at yalnızca 6 ile çıkar: doğru cevapla, başlangıç karesine yerleşsin — 6 yeniden oynattığı için hemen yola çıkar. Pistte zaten bir atın varsa seçersin: bir at daha çıkar ya da ilerle.';

  @override
  String get ruleSixTitle => '6 yeniden oynatır';

  @override
  String get ruleSixBody =>
      'Zardaki gibi: 6 çektiğinde, cevabın doğru olsun olmasın, turundan sonra yeniden oynarsın. Ve iki atın asla aynı karede duramaz.';

  @override
  String get ruleCaptureTitle => 'Yakala ve ahıra yolla';

  @override
  String get ruleCaptureBody =>
      'Rakibin atının bulunduğu kareye tam olarak konmak onu sakince ahırına yollar — kare bir vaha değilse ya da o at bir bilgi kalkanı taşımıyorsa. Ahırdan çıkan bir at başlangıç karesinde her zaman yakalar.';

  @override
  String get ruleStreakTitle => 'Bilgi serisi';

  @override
  String get ruleStreakBody =>
      'Üst üste üç doğru cevap bir kalkan, beş Büyük Dörtnal, on ise ustalık rozeti kazandırır. Büyük Dörtnal kendiliğinden harcanır ve yalnızca +2 karesi bitişe ulaşmaya yettiğinde. Bonuslar yalnızca bilgiden gelir.';

  @override
  String get ruleArrivalTitle => 'Varış';

  @override
  String get ruleArrivalBody =>
      'Parkurun sonuna ulaş — çizgiyi geçmek serbest — sonra varışını resmileştirmek için Yolculuk Sorusu\'nu cevapla. Yanlış cevap seni asla geri götürmez: sıradaki turda yeniden denersin.';
}
