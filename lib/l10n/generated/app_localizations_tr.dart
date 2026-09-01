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
      'Soruları cevapla, temponu seç, atını Mekke\'den Medine\'ye götür.';

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
  String get chooseYourGait => 'Temponu seç';

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
  String get confirmBoldGait =>
      'Bu tempo daha zor bir soru getirir. Devam edilsin mi?';

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
      'Kısa ve güneşli parkur. Hızlı bir oyun için ideal.';

  @override
  String get circuitCaravanTrailDescription =>
      'Kamplar ve fenerler. Daha stratejik bir parkur.';

  @override
  String get circuitGreatRideDescription =>
      'Gündüzden yıldızlı göğe. Büyük yolculuk.';

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
  String get outcomeMoved => 'Atın ilerliyor!';

  @override
  String get outcomeStayed => 'Atın yerinde kalıyor. Kaybın yok.';

  @override
  String get outcomeCaptured => 'Bir rakibi geçtin!';

  @override
  String get outcomeShieldBlocked => 'Kalkan atı korudu.';

  @override
  String get playerProfile => 'Oyuncu seviyesi';

  @override
  String get profileChild => 'Çocuk';

  @override
  String get profileDiscovery => 'Keşif';

  @override
  String get profileIntermediate => 'Orta';

  @override
  String get profileAdvanced => 'İleri';

  @override
  String get raceRulesUpdatedTitle => 'Yarış kuralları geliştirildi';

  @override
  String get raceRulesUpdatedBody =>
      'Zar kalktı: artık kendi temponu, dolayısıyla risk seviyeni sen seçiyorsun. İlerlemen, rozetlerin ve satın alımların korunuyor — yalnızca devam eden oyun yeni kurallarla sürdürülemiyor.';

  @override
  String get startNewRace => 'Yeni bir yarış başlat';

  @override
  String get rulesTitle => 'Kurallar';

  @override
  String get ruleChooseGaitTitle => 'Temponu seç';

  @override
  String get ruleChooseGaitBody =>
      'Kaç kare ilerleyeceğine sen karar verirsin, 1\'den 6\'ya. Ne kadar uzağa gidersen soru o kadar zorlaşır: 1-2 kolay, 3-4 orta, 5-6 zor.';

  @override
  String get ruleAnswerToAdvanceTitle => 'İlerlemek için cevapla';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Doğru cevap atını tam olarak seçtiğin kadar ilerletir. Yanlış cevap onu olduğu yerde bırakır — asla geri gitmezsin.';

  @override
  String get ruleGaitCycleTitle => 'Döngü başına bir tempo';

  @override
  String get ruleGaitCycleBody =>
      'Her tempo yalnızca bir kez kullanılır. Altısı da bitince hepsi geri gelir — önceden planla.';

  @override
  String get ruleCaptureTitle => 'Geç ve ahıra yolla';

  @override
  String get ruleCaptureBody =>
      'Rakibin atının bulunduğu kareye tam olarak konmak onu sakince ahırına yollar — kare bir vaha değilse ya da o at bir bilgi kalkanı taşımıyorsa.';

  @override
  String get ruleStreakTitle => 'Bilgi serisi';

  @override
  String get ruleStreakBody =>
      'Üst üste üç doğru cevap bir kalkan, beş doğru Büyük Dörtnal (+2 kare), on doğru bir ustalık rozeti kazandırır. Bonuslar yalnızca bilgiyle gelir.';

  @override
  String get ruleArrivalTitle => 'Varış';

  @override
  String get ruleArrivalBody =>
      'Parkurun sonuna ulaş — çizgiyi geçmek serbest — sonra varışını resmileştirmek için Yolculuk Sorusu\'nu cevapla. Yanlış cevap seni asla geri götürmez: sıradaki turda yeniden denersin.';
}
