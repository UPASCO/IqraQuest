// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appName => 'IqraQuest';

  @override
  String get appTagline => 'Perjalanan ilmu';

  @override
  String get onboardingWelcomeTitle => 'Selamat Datang ke IqraQuest';

  @override
  String get onboardingWelcomeSubtitle =>
      'Jawab soalan, pilih langkah anda, dan bawa kuda anda dari Makkah ke Madinah.';

  @override
  String get getStarted => 'Mulakan';

  @override
  String get chooseLanguage => 'Pilih bahasa';

  @override
  String get play => 'Main';

  @override
  String get soloMode => 'Solo';

  @override
  String get familyMode => 'Keluarga';

  @override
  String get dailyChallenge => 'Cabaran Harian';

  @override
  String get progress => 'Kemajuan';

  @override
  String get settings => 'Tetapan';

  @override
  String get premium => 'Premium';

  @override
  String get continueGame => 'Sambung Permainan';

  @override
  String get quickGame => 'Permainan Pantas';

  @override
  String get classicGame => 'Permainan Klasik';

  @override
  String get chooseDifficulty => 'Pilih tahap kesukaran';

  @override
  String get difficultyEasy => 'Mudah';

  @override
  String get difficultyMedium => 'Sederhana';

  @override
  String get difficultyHard => 'Sukar';

  @override
  String get playerName => 'Nama';

  @override
  String get chooseTeam => 'Pilih pasukan';

  @override
  String get addPlayer => 'Tambah Pemain';

  @override
  String get startGame => 'Mulakan Permainan';

  @override
  String get yourTurn => 'Giliran anda';

  @override
  String get category => 'Kategori';

  @override
  String get correctAnswer => 'Betul!';

  @override
  String get incorrectAnswer => 'Tidak tepat…';

  @override
  String get explanationLabel => 'Penjelasan';

  @override
  String get sourceLabel => 'Sumber';

  @override
  String get nextPlayer => 'Pemain Seterusnya';

  @override
  String get rolledSix => 'Enam! Giliran lagi — soalan baharu.';

  @override
  String get playAgain => 'Main Lagi';

  @override
  String get protectedSquareLabel => 'Petak Dilindungi';

  @override
  String get freeBankExhaustedMessage =>
      'Semua soalan edisi percuma telah digunakan dalam permainan ini.';

  @override
  String get victory => 'Kemenangan!';

  @override
  String get gameOver => 'Permainan Tamat';

  @override
  String get backToHome => 'Kembali ke Laman Utama';

  @override
  String get gamesPlayed => 'Permainan Dimainkan';

  @override
  String get winRate => 'Kadar Kemenangan';

  @override
  String get questionsAnswered => 'Soalan Dijawab';

  @override
  String get streak => 'Rentetan Hari';

  @override
  String get premiumTitle => 'IqraQuest Premium';

  @override
  String get premiumUnlockAll =>
      'Buka kunci 500 soalan dan semua tahap kesukaran';

  @override
  String get premiumOneTime => 'Bayaran sekali — tiada langganan';

  @override
  String get restorePurchases => 'Pulihkan Pembelian';

  @override
  String get purchaseSuccess => 'Terima kasih! Premium kini aktif.';

  @override
  String get purchaseError =>
      'Pembelian tidak dapat diselesaikan. Sila cuba lagi kemudian.';

  @override
  String get language => 'Bahasa';

  @override
  String get reduceMotion => 'Kurangkan Gerakan';

  @override
  String get soundEffects => 'Kesan Bunyi';

  @override
  String get darkMode => 'Mod Gelap';

  @override
  String get about => 'Tentang';

  @override
  String get privacyPolicy => 'Dasar Privasi';

  @override
  String get genericError => 'Sesuatu tidak kena.';

  @override
  String get parentalGateTitle => 'Soalan untuk ibu bapa';

  @override
  String get parentalGateInstruction => 'Selesaikan ini untuk teruskan.';

  @override
  String get chooseYourGait => 'Pilih langkah anda';

  @override
  String gaitSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count petak',
    );
    return '$_temp0';
  }

  @override
  String get gaitNameWalk => 'Jalan';

  @override
  String get gaitNameTrot => 'Derap';

  @override
  String get gaitNameCanter => 'Kanter';

  @override
  String get gaitNameGallop => 'Galop';

  @override
  String get gaitNameFullGallop => 'Galop penuh';

  @override
  String get gaitNameCharge => 'Serbuan';

  @override
  String get chooseFormat => 'Format permainan';

  @override
  String get gaitAlreadyUsed => 'Sudah digunakan kitaran ini';

  @override
  String gaitSemanticLabel(int steps, String difficulty, int points) {
    return 'Maju $steps petak, soalan $difficulty, $points mata ilmu';
  }

  @override
  String get selectHorse => 'Pilih kuda anda';

  @override
  String get confirmBoldGait =>
      'Langkah ini menarik soalan lebih sukar. Teruskan?';

  @override
  String get knowledgeStreak => 'Momentum ilmu';

  @override
  String get knowledgePointsLabel => 'Mata ilmu';

  @override
  String get shieldEarned => 'Perisai diperoleh! Kuda anda dilindungi.';

  @override
  String get grandGallopEarned =>
      'Grand Gallop dibuka! +2 petak bila-bila anda mahu.';

  @override
  String get masteryBadgeEarned => 'Lencana penguasaan diperoleh!';

  @override
  String get useGrandGallop => 'Guna Grand Gallop (+2)';

  @override
  String get chooseCircuit => 'Pilih laluan anda';

  @override
  String get circuitOasisRoute => 'Laluan Oasis';

  @override
  String get circuitCaravanTrail => 'Denai Kafilah';

  @override
  String get circuitGreatRide => 'Pengembaraan Agung Ilmu';

  @override
  String get circuitOasisRouteDescription =>
      'Laluan pendek dan cerah. Sesuai untuk permainan pantas.';

  @override
  String get circuitCaravanTrailDescription =>
      'Perkhemahan dan tanglung. Laluan yang lebih strategik.';

  @override
  String get circuitGreatRideDescription =>
      'Dari siang ke langit berbintang. Pengembaraan agung.';

  @override
  String get cellOasis => 'Oasis';

  @override
  String get cellKnowledge => 'Ilmu';

  @override
  String get cellChallenge => 'Cabaran';

  @override
  String get cellShortcut => 'Jalan pintas';

  @override
  String get cellDuel => 'Pertandingan';

  @override
  String get cellWisdom => 'Hikmah';

  @override
  String get cellRelay => 'Lapor';

  @override
  String get cellOasisDescription =>
      'Kuda anda selamat daripada ditangkap di sini.';

  @override
  String get cellChallengeOffer =>
      'Jawab soalan lebih sukar untuk maju 2 petak lagi?';

  @override
  String get acceptChallenge => 'Terima cabaran';

  @override
  String get declineChallenge => 'Kekalkan langkah saya';

  @override
  String get saveFact => 'Simpan fakta ini';

  @override
  String get journeyQuestion => 'Soalan pengembaraan';

  @override
  String get journeyQuestionIntro =>
      'Satu soalan terakhir untuk mengesahkan ketibaan anda.';

  @override
  String get outcomeMoved => 'Kuda anda maju!';

  @override
  String get outcomeStayed => 'Kuda anda kekal. Tiada apa yang hilang.';

  @override
  String get outcomeCaptured => 'Anda memintas lawan!';

  @override
  String get outcomeShieldBlocked => 'Perisai melindungi kuda itu.';

  @override
  String get playerProfile => 'Tahap pemain';

  @override
  String get profileChild => 'Kanak-kanak';

  @override
  String get profileDiscovery => 'Penerokaan';

  @override
  String get profileIntermediate => 'Sederhana';

  @override
  String get profileAdvanced => 'Lanjutan';

  @override
  String get raceRulesUpdatedTitle =>
      'Peraturan perlumbaan telah ditambah baik';

  @override
  String get raceRulesUpdatedBody =>
      'Dadu telah tiada: kini anda memilih langkah anda sendiri, dan dengannya tahap risiko anda. Kemajuan, lencana dan pembelian anda dikekalkan — hanya permainan yang sedang berjalan tidak dapat diteruskan dengan peraturan baharu.';

  @override
  String get startNewRace => 'Mulakan perlumbaan baharu';

  @override
  String get rulesTitle => 'Peraturan';

  @override
  String get ruleChooseGaitTitle => 'Pilih langkah anda';

  @override
  String get ruleChooseGaitBody =>
      'Anda yang menentukan sejauh mana untuk bergerak, dari 1 hingga 6 petak. Semakin jauh, semakin sukar soalannya: 1-2 mudah, 3-4 sederhana, 5-6 sukar.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Jawab untuk maju';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Jawapan betul menggerakkan kuda anda tepat sejauh yang anda pilih. Jawapan salah membiarkannya di tempatnya — anda tidak pernah berundur.';

  @override
  String get ruleGaitCycleTitle => 'Satu langkah setiap kitaran';

  @override
  String get ruleGaitCycleBody =>
      'Setiap langkah hanya boleh digunakan sekali. Apabila keenam-enamnya habis, semuanya kembali — jadi rancang lebih awal.';

  @override
  String get ruleCaptureTitle => 'Memintas dan menghantar pulang';

  @override
  String get ruleCaptureBody =>
      'Mendarat tepat pada kuda lawan menghantarnya pulang dengan tenang ke kandang — melainkan petak itu oasis, atau kuda itu membawa perisai ilmu.';

  @override
  String get ruleStreakTitle => 'Rentetan ilmu';

  @override
  String get ruleStreakBody =>
      'Tiga jawapan betul berturut-turut memberi perisai, lima memberi Larian Agung (+2 petak), dan sepuluh memberi lencana penguasaan. Bonus datang daripada ilmu sahaja.';

  @override
  String get ruleArrivalTitle => 'Ketibaan';

  @override
  String get ruleArrivalBody =>
      'Capai penghujung laluan — melepasi garisan tidak mengapa — kemudian jawab Soalan Perjalanan untuk mengesahkan ketibaan anda. Jawapan salah tidak pernah mengundurkan anda: anda cuba lagi pada giliran seterusnya.';
}
