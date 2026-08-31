// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'IqraQuest';

  @override
  String get appTagline => 'Perjalanan pengetahuan';

  @override
  String get onboardingWelcomeTitle => 'Selamat Datang di IqraQuest';

  @override
  String get onboardingWelcomeSubtitle =>
      'Jawab pertanyaan, pilih langkahmu, dan bawa kudamu dari Makkah ke Madinah.';

  @override
  String get getStarted => 'Mulai';

  @override
  String get chooseLanguage => 'Pilih bahasa';

  @override
  String get play => 'Main';

  @override
  String get soloMode => 'Solo';

  @override
  String get familyMode => 'Keluarga';

  @override
  String get dailyChallenge => 'Tantangan Harian';

  @override
  String get progress => 'Kemajuan';

  @override
  String get settings => 'Pengaturan';

  @override
  String get premium => 'Premium';

  @override
  String get continueGame => 'Lanjutkan Permainan';

  @override
  String get quickGame => 'Permainan Cepat';

  @override
  String get classicGame => 'Permainan Klasik';

  @override
  String get chooseDifficulty => 'Pilih tingkat kesulitan';

  @override
  String get difficultyEasy => 'Mudah';

  @override
  String get difficultyMedium => 'Menengah';

  @override
  String get difficultyHard => 'Sulit';

  @override
  String get playerName => 'Nama';

  @override
  String get chooseTeam => 'Pilih tim';

  @override
  String get addPlayer => 'Tambah Pemain';

  @override
  String get startGame => 'Mulai Permainan';

  @override
  String get yourTurn => 'Giliranmu';

  @override
  String get category => 'Kategori';

  @override
  String get correctAnswer => 'Benar!';

  @override
  String get incorrectAnswer => 'Belum tepat…';

  @override
  String get explanationLabel => 'Penjelasan';

  @override
  String get sourceLabel => 'Sumber';

  @override
  String get nextPlayer => 'Pemain Berikutnya';

  @override
  String get rolledSix => 'Angka enam! Giliran lagi — pertanyaan baru.';

  @override
  String get playAgain => 'Main Lagi';

  @override
  String get protectedSquareLabel => 'Kotak Terlindungi';

  @override
  String get freeBankExhaustedMessage =>
      'Semua pertanyaan edisi gratis telah digunakan pada permainan ini.';

  @override
  String get victory => 'Kemenangan!';

  @override
  String get gameOver => 'Permainan Selesai';

  @override
  String get backToHome => 'Kembali ke Beranda';

  @override
  String get gamesPlayed => 'Permainan Dimainkan';

  @override
  String get winRate => 'Tingkat Kemenangan';

  @override
  String get questionsAnswered => 'Pertanyaan Dijawab';

  @override
  String get streak => 'Rentetan Hari';

  @override
  String get premiumTitle => 'IqraQuest Premium';

  @override
  String get premiumUnlockAll =>
      'Buka 500 pertanyaan dan semua tingkat kesulitan';

  @override
  String get premiumOneTime => 'Pembayaran sekali — tanpa langganan';

  @override
  String get restorePurchases => 'Pulihkan Pembelian';

  @override
  String get purchaseSuccess => 'Terima kasih! Premium kini aktif.';

  @override
  String get purchaseError =>
      'Pembelian tidak dapat diselesaikan. Coba lagi nanti.';

  @override
  String get language => 'Bahasa';

  @override
  String get reduceMotion => 'Kurangi Gerakan';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get about => 'Tentang';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get genericError => 'Terjadi kesalahan.';

  @override
  String get parentalGateTitle => 'Pertanyaan untuk orang tua';

  @override
  String get parentalGateInstruction => 'Selesaikan ini untuk melanjutkan.';

  @override
  String get chooseYourGait => 'Pilih langkahmu';

  @override
  String gaitSquares(int count) {
    return '$count kotak';
  }

  @override
  String get gaitAlreadyUsed => 'Sudah dipakai siklus ini';

  @override
  String gaitSemanticLabel(int steps, String difficulty, int points) {
    return 'Maju $steps kotak, pertanyaan $difficulty, $points poin pengetahuan';
  }

  @override
  String get selectHorse => 'Pilih kudamu';

  @override
  String get confirmBoldGait =>
      'Langkah ini menarik pertanyaan lebih sulit. Lanjutkan?';

  @override
  String get knowledgeStreak => 'Momentum pengetahuan';

  @override
  String get knowledgePointsLabel => 'Poin pengetahuan';

  @override
  String get shieldEarned => 'Perisai diperoleh! Kudamu terlindungi.';

  @override
  String get grandGallopEarned =>
      'Grand Gallop terbuka! +2 kotak kapan pun kamu mau.';

  @override
  String get masteryBadgeEarned => 'Lencana penguasaan diperoleh!';

  @override
  String get useGrandGallop => 'Gunakan Grand Gallop (+2)';

  @override
  String get chooseCircuit => 'Pilih lintasanmu';

  @override
  String get circuitOasisRoute => 'Jalur Oasis';

  @override
  String get circuitCaravanTrail => 'Jejak Kafilah';

  @override
  String get circuitGreatRide => 'Pacuan Agung Pengetahuan';

  @override
  String get circuitOasisRouteDescription =>
      'Lintasan pendek dan cerah. Cocok untuk permainan cepat.';

  @override
  String get circuitCaravanTrailDescription =>
      'Perkemahan dan lentera. Lintasan yang lebih strategis.';

  @override
  String get circuitGreatRideDescription =>
      'Dari siang ke langit berbintang. Perjalanan agung.';

  @override
  String get cellOasis => 'Oasis';

  @override
  String get cellKnowledge => 'Pengetahuan';

  @override
  String get cellChallenge => 'Tantangan';

  @override
  String get cellShortcut => 'Jalan pintas';

  @override
  String get cellDuel => 'Duel';

  @override
  String get cellWisdom => 'Hikmah';

  @override
  String get cellRelay => 'Estafet';

  @override
  String get cellOasisDescription => 'Kudamu aman dari tangkapan di sini.';

  @override
  String get cellChallengeOffer =>
      'Jawab pertanyaan lebih sulit untuk maju 2 kotak lagi?';

  @override
  String get acceptChallenge => 'Terima tantangan';

  @override
  String get declineChallenge => 'Simpan langkahku';

  @override
  String get saveFact => 'Simpan fakta ini';

  @override
  String get journeyQuestion => 'Pertanyaan perjalanan';

  @override
  String get journeyQuestionIntro =>
      'Satu pertanyaan terakhir untuk mengesahkan kedatanganmu.';

  @override
  String get outcomeMoved => 'Kudamu melaju!';

  @override
  String get outcomeStayed => 'Kudamu tetap di tempat. Tidak ada yang hilang.';

  @override
  String get outcomeCaptured => 'Kamu menyalip lawan!';

  @override
  String get outcomeShieldBlocked => 'Perisai melindungi kuda itu.';

  @override
  String get playerProfile => 'Tingkat pemain';

  @override
  String get profileChild => 'Anak';

  @override
  String get profileDiscovery => 'Penjelajahan';

  @override
  String get profileIntermediate => 'Menengah';

  @override
  String get profileAdvanced => 'Lanjutan';

  @override
  String get raceRulesUpdatedTitle => 'Aturan balapan telah ditingkatkan';

  @override
  String get raceRulesUpdatedBody =>
      'Dadu telah hilang: kini kamu memilih langkahmu sendiri, dan dengan itu tingkat risikomu. Kemajuan, lencana, dan pembelianmu tetap tersimpan — hanya permainan yang sedang berjalan tidak dapat dilanjutkan dengan aturan baru.';

  @override
  String get startNewRace => 'Mulai balapan baru';

  @override
  String get rulesTitle => 'Aturan main';

  @override
  String get ruleChooseGaitTitle => 'Pilih langkahmu';

  @override
  String get ruleChooseGaitBody =>
      'Kamu yang menentukan seberapa jauh melangkah, dari 1 sampai 6 petak. Makin jauh, makin sulit pertanyaannya: 1-2 mudah, 3-4 sedang, 5-6 sulit.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Jawab untuk maju';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Jawaban benar menggerakkan kudamu tepat sejauh yang kamu pilih. Jawaban salah membiarkannya di tempat — kamu tidak pernah mundur.';

  @override
  String get ruleGaitCycleTitle => 'Satu langkah per siklus';

  @override
  String get ruleGaitCycleBody =>
      'Setiap langkah hanya bisa dipakai sekali. Ketika keenamnya habis, semuanya kembali — jadi rencanakan.';

  @override
  String get ruleCaptureTitle => 'Menyalip dan memulangkan';

  @override
  String get ruleCaptureBody =>
      'Mendarat tepat di kuda lawan mengirimnya kembali dengan tenang ke kandang — kecuali petaknya oasis, atau kuda itu membawa perisai pengetahuan.';

  @override
  String get ruleStreakTitle => 'Rentetan pengetahuan';

  @override
  String get ruleStreakBody =>
      'Tiga jawaban benar berturut-turut memberi perisai, lima memberi Galop Agung (+2 petak), dan sepuluh memberi lencana penguasaan. Bonus hanya datang dari pengetahuan.';

  @override
  String get ruleArrivalTitle => 'Kedatangan';

  @override
  String get ruleArrivalBody =>
      'Capai ujung lintasan — melewati garis tidak masalah — lalu jawab Pertanyaan Perjalanan untuk mengesahkan kedatanganmu. Jawaban salah tidak pernah memundurkanmu: kamu tinggal mencoba lagi di giliran berikutnya.';
}
