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
      'Ambil kartu, jawab, melaju — dan bawa kudamu sampai ke Makkah.';

  @override
  String get getStarted => 'Mulai';

  @override
  String get onboardingHowTo => 'Cara bermain';

  @override
  String get onboardingStepDraw => 'Ambil kartu: ia mengumumkan lompatannya';

  @override
  String get onboardingStepAnswer => 'Jawab benar: lompatannya milikmu';

  @override
  String get onboardingStepRide => 'Letakkan kudamu dan berlari ke oasis';

  @override
  String get onboardingLanguageHint =>
      'Kamu bisa mengubahnya nanti di Pengaturan.';

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
  String get duoGame => 'Permainan Duo';

  @override
  String horsesToMecca(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kuda ke Mekah',
    );
    return '$_temp0';
  }

  @override
  String get formatQuickHint => 'Balapan terpendek.';

  @override
  String get formatDuoHint => 'Balapan satu malam.';

  @override
  String get formatClassicHint => 'Permainan penuh, seperti aslinya.';

  @override
  String get bonusSquaresOption => 'Petak bonus di lintasan';

  @override
  String get bonusSquaresOn =>
      '16 petak memberi tunggangan ekstra: +5, +10, atau +20.';

  @override
  String get bonusSquaresOff =>
      'Lintasan murni: satu kartu bernilai persis derap-nya.';

  @override
  String get muteSound => 'Matikan suara';

  @override
  String get unmuteSound => 'Nyalakan suara';

  @override
  String get chooseDifficulty => 'Pilih tingkat kesulitan';

  @override
  String get difficultyEasy => 'Mudah';

  @override
  String get difficultyMedium => 'Sedang';

  @override
  String get difficultyHard => 'Sulit';

  @override
  String get playerName => 'Nama';

  @override
  String get chooseTeam => 'Pilih tim';

  @override
  String get ridersTitle => 'Para penunggang';

  @override
  String get storeLoading => 'Menghubungkan ke toko…';

  @override
  String get storeUnavailableCta => 'Toko tidak tersedia';

  @override
  String get premiumBenefitBank =>
      'Seluruh bank soal, masing-masing dengan sumbernya';

  @override
  String premiumBenefitUnlimited(int count) {
    return 'Permainan tanpa batas, sampai Makkah (versi gratis berhenti setelah $count kali ambil kartu)';
  }

  @override
  String get premiumBenefitFamily =>
      'Satu pembelian untuk seluruh keluarga, tanpa iklan';

  @override
  String get progressEmpty =>
      'Mainkan permainan pertama: kemajuanmu akan muncul di sini.';

  @override
  String get addPlayer => 'Tambah Pemain';

  @override
  String get startGame => 'Mulai Permainan';

  @override
  String get yourTurn => 'Giliranmu';

  @override
  String get categoryProphets => 'Para Nabi';

  @override
  String get categorySira => 'Sirah';

  @override
  String get categoryQuran => 'Al-Qur\'an';

  @override
  String get categoryFaith => 'Akidah';

  @override
  String get categoryVirtues => 'Akhlak';

  @override
  String get category => 'Kategori';

  @override
  String get correctAnswer => 'Benar!';

  @override
  String get incorrectAnswer => 'Belum tepat…';

  @override
  String get learnMore => 'Pelajari lebih lanjut';

  @override
  String get questionDetailsTitle => 'Di balik jawaban';

  @override
  String get theQuestionLabel => 'Pertanyaan';

  @override
  String get theAnswerLabel => 'Jawaban yang benar';

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
      'Buka seluruh bank pertanyaan dan semua tingkat kesulitan';

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
  String get soundEffects => 'Efek Suara';

  @override
  String get howToPlay => 'Cara Bermain';

  @override
  String get privacySummary =>
      'IqraQuest berjalan sepenuhnya di perangkat Anda: tanpa akun, tanpa iklan, tanpa pelacakan, dan tidak ada yang dikirim melalui Internet.';

  @override
  String defaultPlayerName(num number) {
    return 'Pemain $number';
  }

  @override
  String aiPlayerName(num number) {
    return 'Penunggang $number';
  }

  @override
  String opponentWins(String name) {
    return '$name memenangkan balapan!';
  }

  @override
  String get wellRidden =>
      'Perjalanan yang bagus — setiap pertanyaan yang dipelajari berarti.';

  @override
  String horseSemantics(String color, num number) {
    return 'Kuda $color $number';
  }

  @override
  String get teamEmerald => 'zamrud';

  @override
  String get teamSaphir => 'safir';

  @override
  String get teamGrenat => 'merah delima';

  @override
  String get teamSafran => 'safron';

  @override
  String premiumCta(String price) {
    return 'Buka semua — $price';
  }

  @override
  String premiumQuestionsIncluded(num count) {
    return '$count pertanyaan terverifikasi, masing-masing dengan sumbernya — dan bank soal terus bertambah.';
  }

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get about => 'Tentang';

  @override
  String get aboutDialogTitle => 'Tentang IqraQuest';

  @override
  String versionLabel(String version) {
    return 'Versi $version';
  }

  @override
  String copyrightNotice(String year) {
    return '© $year IqraQuest. Hak cipta dilindungi.';
  }

  @override
  String get originalWorkNotice =>
      'IqraQuest, konsep permainannya, aturannya, ilustrasinya, namanya, dan isinya adalah karya asli yang dilindungi hak cipta. Segala bentuk penggandaan, peniruan, atau adaptasi, seluruhnya atau sebagian, tanpa izin tertulis dilarang.';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get genericError => 'Terjadi kesalahan.';

  @override
  String get parentalGateTitle => 'Pertanyaan untuk orang tua';

  @override
  String get parentalGateInstruction => 'Selesaikan ini untuk melanjutkan.';

  @override
  String get placeMecca => 'Makkah';

  @override
  String get placeMedina => 'Madinah';

  @override
  String get placeAlAqsa => 'Al-Aqsa';

  @override
  String get placeArafat => 'Arafah';

  @override
  String get placeMina => 'Mina';

  @override
  String circuitSpecialSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count petak khusus',
    );
    return '$_temp0';
  }

  @override
  String get drawCard => 'Ambil kartu';

  @override
  String get drawnCardTitle => 'Kartu terambil';

  @override
  String cardWorth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kartu $count lompatan',
    );
    return '$_temp0';
  }

  @override
  String gaitSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kotak',
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
  String get gaitAlreadyUsed => 'Sudah dipakai siklus ini';

  @override
  String gaitSemanticLabel(int steps, String difficulty, int points) {
    return 'Maju $steps kotak, pertanyaan $difficulty, $points poin pengetahuan';
  }

  @override
  String get selectHorse => 'Pilih kudamu';

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
      'Rute paling tenang: oase, sedikit kejutan.';

  @override
  String get circuitCaravanTrailDescription =>
      'Tantangan dan estafet di sepanjang jalan. Lebih taktis.';

  @override
  String get circuitGreatRideDescription =>
      'Rute paling ramai: tantangan, jalan pintas, dan duel.';

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
  String opponentThinking(String name) {
    return '$name sedang berpikir…';
  }

  @override
  String opponentDrew(String name, int count) {
    return '$name menarik kartu $count';
  }

  @override
  String correctAnswerWas(String answer) {
    return 'Jawaban yang benar: $answer';
  }

  @override
  String get scoreboardTitle => 'Papan Balapan';

  @override
  String scoreboardCorrect(int count) {
    return '$count benar';
  }

  @override
  String scoreboardBestStreak(int count) {
    return 'rentetan $count';
  }

  @override
  String get playAgainSameRiders => 'Balapan Lagi!';

  @override
  String opponentMoved(String name) {
    return '$name melaju!';
  }

  @override
  String opponentStayed(String name) {
    return '$name tetap di tempat.';
  }

  @override
  String get shareScore => 'Bagikan';

  @override
  String shareVictoryText(String name, int points) {
    return '$name memenangkan balapan IqraQuest dengan $points ⭐! Giliranmu?';
  }

  @override
  String shareDailyText(int score, int total) {
    return '$score/$total di tantangan harian IqraQuest! Bisa lebih baik?';
  }

  @override
  String get dailyChallengeDone => 'Tantangan harian selesai';

  @override
  String dailyChallengeScore(num score, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score benar dari $total',
    );
    return '$_temp0';
  }

  @override
  String get dailyChallengeComeBack => 'Kembali besok untuk tantangan baru.';

  @override
  String get aiOpponentsLabel => 'Lawan';

  @override
  String get playersLabel => 'Pemain';

  @override
  String get outcomeMoved => 'Kudamu melaju!';

  @override
  String get outcomeStayed => 'Kudamu tetap di tempat. Tidak ada yang hilang.';

  @override
  String get outcomeCaptured => 'Kamu menangkap kuda lawan!';

  @override
  String get outcomeExited => 'Kudamu keluar dari kandang!';

  @override
  String get outcomeNoLegalMove =>
      'Kartu ini tak bisa menggerakkan kuda mana pun. Giliran berikutnya!';

  @override
  String get noExitHint =>
      'Kamu butuh angka 6 untuk mengeluarkan kuda dari kandang.';

  @override
  String get bonusTurnHint => 'Giliran bonus: angka 6 membuatmu main lagi!';

  @override
  String get celebrateSixTitle => 'ENAM!';

  @override
  String get celebrateSixBody =>
      'Kamu akan mengambil kartu lagi setelah giliran ini.';

  @override
  String get celebrateSixExitBody =>
      'Seekor kuda boleh keluar — dan kamu main lagi!';

  @override
  String get celebrateExitTitle => 'Gerbang terbuka!';

  @override
  String get celebrateExitBody => 'Seekor kuda boleh keluar dari kandang.';

  @override
  String get celebrateCaptureTitle => 'Tangkap!';

  @override
  String get celebrateCaptureBody => 'Kuda lawan kembali ke kandangnya.';

  @override
  String get celebrateCapturedTitle => 'Tertangkap…';

  @override
  String get celebrateCapturedBody =>
      'Kudamu kembali ke kandang. Angka 6 mengeluarkannya lagi.';

  @override
  String get celebrateArrivalTitle => 'Makkah!';

  @override
  String get celebrateArrivalBody =>
      'Kudamu sudah tiba. Satu pertanyaan terakhir untuk mengesahkannya!';

  @override
  String get freeLimitTitle => 'Akhir balapan gratis';

  @override
  String freeLimitLeader(String name) {
    return 'Memimpin: $name';
  }

  @override
  String freeLimitBody(int count) {
    return 'Versi gratis berhenti setelah $count kali ambil kartu. Dengan Premium, balapan berlanjut sampai Makkah.';
  }

  @override
  String get freeLimitCta => 'Buka balapan tanpa batas';

  @override
  String drawsCounter(int count, int max) {
    return 'Ambil kartu: $count dari $max';
  }

  @override
  String moveChoiceTitle(int count) {
    return 'Mau diapakan angka $count ini?';
  }

  @override
  String get moveChoiceExit => 'Keluarkan kuda dari kandang';

  @override
  String moveChoiceAdvance(int number, int count) {
    return 'Kuda $number: maju $count';
  }

  @override
  String moveHintCapture(int value) {
    return 'tangkap! +$value';
  }

  @override
  String get moveHintFinish => 'finis!';

  @override
  String get moveHintOasis => 'oasis';

  @override
  String opponentExits(String name) {
    return '$name mengeluarkan kuda!';
  }

  @override
  String opponentNoMove(String name) {
    return '$name tak bisa menggerakkan apa pun.';
  }

  @override
  String opponentReplays(String name) {
    return '$name mendapat 6 dan main lagi!';
  }

  @override
  String opponentCaptured(String name) {
    return '$name menangkap kuda!';
  }

  @override
  String get outcomeShieldBlocked => 'Perisai melindungi kuda itu.';

  @override
  String get playerProfile => 'Tingkat pertanyaan';

  @override
  String get levelEasy => 'Mudah';

  @override
  String get levelIntermediate => 'Menengah';

  @override
  String get levelExpert => 'Ahli';

  @override
  String get raceRulesUpdatedTitle => 'Aturan balapan telah ditingkatkan';

  @override
  String get raceRulesUpdatedBody =>
      'Aturannya berubah: sekarang kamu mengambil kartu, dan nilainya menentukan jarak sekaligus tingkat kesulitan. Progres, lencana, dan pembelianmu tetap tersimpan — hanya permainan yang sedang berjalan tidak bisa dilanjutkan dengan aturan baru.';

  @override
  String get startNewRace => 'Mulai balapan baru';

  @override
  String get rulesTitle => 'Aturan main';

  @override
  String get ruleDrawCardTitle => 'Ambil kartu';

  @override
  String get ruleDrawCardBody =>
      'Pada giliranmu, ambil satu kartu: pertanyaannya langsung terbuka, selalu sesuai tingkatmu — mudah, menengah, atau ahli — yang dipilih di awal. Nilainya, 1 sampai 6 petak, tetap tersembunyi sampai kamu menjawab.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Jawab untuk maju';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Jawaban benar memberimu petak-petak kartu itu. Lalu pilih kuda yang mengambilnya: sentuh untuk melihat tujuannya, lalu seret ke sana — melepasnya adalah langkahnya. Jawaban salah membiarkan semuanya di tempat: kamu tidak pernah mundur.';

  @override
  String get ruleEscalierTitle => 'Tangga menuju Makkah';

  @override
  String get ruleEscalierBody =>
      'Setelah satu putaran penuh, kudamu menaiki lima anak tangganya menuju Makkah. Di sana tidak ada yang bisa menyusulnya.';

  @override
  String get ruleExitTitle => 'Keluar dari kandang';

  @override
  String get ruleExitBody =>
      'Setiap pemain punya empat kuda, dan yang pertama sudah berada di petak awalnya: kamu bermain sejak kartu pertama, tanpa menunggu. Tiga lainnya keluar dari kandang dengan angka 6: jawab benar dan kuda menempati petak awal — dan karena 6 memberi giliran lagi, ia langsung melaju. Pilihanmu: keluarkan satu lagi, atau maju.';

  @override
  String get ruleSixTitle => 'Angka 6 main lagi';

  @override
  String get ruleSixBody =>
      'Seperti dadu: saat mengambil 6, kamu main lagi setelah giliranmu, benar atau salah jawabannya. Dan dua kudamu tak pernah berbagi satu petak.';

  @override
  String get ruleCaptureTitle => 'Menangkap dan memulangkan';

  @override
  String get ruleCaptureBody =>
      'Mendarat tepat di kuda lawan mengirimnya kembali dengan tenang ke kandang — kecuali petaknya oasis, atau kuda itu membawa perisai pengetahuan. Menangkap ada imbalannya: kudamu langsung melompat 20 lompatan. Kuda yang keluar dari kandang selalu menangkap di petak start-nya.';

  @override
  String get ruleStreakTitle => 'Rentetan pengetahuan';

  @override
  String get ruleStreakBody =>
      'Tiga jawaban benar berturut-turut memberi perisai, lima memberi Grand Galop, dan sepuluh memberi lencana penguasaan. Grand Galop terpakai sendiri, dan hanya bila +2 petaknya cukup untuk mencapai garis akhir. Bonus hanya datang dari pengetahuan.';

  @override
  String get ruleArrivalTitle => 'Kedatangan';

  @override
  String get ruleArrivalBody =>
      'Garis akhir dicapai dengan hitungan tepat: tiga petak dari oasis kamu butuh persis 3. Angka 4, 5, atau 6 membiarkan kuda di tempatnya, menunggu kartu yang pas. Setelah sampai, jawab Pertanyaan Perjalanan untuk mengesahkan kedatanganmu; jawaban salah tidak pernah memundurkanmu, kamu tinggal mencoba lagi.';

  @override
  String get hapticFeedback => 'Getaran';

  @override
  String squaresWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Menang $count lompatan',
    );
    return '$_temp0';
  }

  @override
  String get chooseHorseToMove => 'Pilih seekor kuda';

  @override
  String get touchHorseHint => 'Sentuh kuda untuk melihat tujuannya';

  @override
  String get dragHorseToDestination => 'Seret kuda ke petak emasnya';

  @override
  String get bonusLabel => 'BONUS';

  @override
  String bonusPlus(int value) {
    return '+$value lompatan';
  }

  @override
  String get captureBonusLabel => 'TANGKAP';

  @override
  String captureBonusRide(int value) {
    return 'Tangkap! Kudamu melompat $value lompatan ke depan.';
  }

  @override
  String bonusRide(int value) {
    return 'Petak bonus! Kudamu melaju $value petak lagi.';
  }

  @override
  String cardWasWorth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kartu ini bernilai $count lompatan.',
    );
    return '$_temp0';
  }

  @override
  String get answerToReveal => 'Jawab untuk mengungkap nilainya';

  @override
  String opponentPlaces(String name) {
    return '$name memilih kuda…';
  }

  @override
  String opponentBonus(String name, int value) {
    return '$name mendapat bonus +$value!';
  }

  @override
  String get leaderLabel => 'Memimpin';

  @override
  String tookTheLead(String name) {
    return '$name memimpin!';
  }

  @override
  String bonusSquareSemantics(int value) {
    return 'Petak bonus +$value';
  }

  @override
  String moveHintBonus(int value) {
    return 'Bonus +$value';
  }

  @override
  String get bonusSquaresTeaser =>
      '16 petak bonus menanti di papan: +5, +10, dan +20 yang langka.';

  @override
  String get ridersSubtitle =>
      'Setiap penunggang memilih tingkatnya; kartu hanya menentukan jarak.';

  @override
  String get ruleBonusTitle => 'Petak bonus';

  @override
  String get ruleBonusBody =>
      'Enam belas petak bonus dibagikan di papan setiap permainan, empat per kuadran. Kuda yang berhenti tepat di atasnya langsung melaju +5, +10, atau +20 lompatan — dan bila lompatan itu mendaratkannya tepat di petak bonus lain, petak itu ikut menyala: bonus berantai. Setiap petak membayar sekali per giliran dan tetap berlaku untuk semua.';
}
