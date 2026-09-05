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
      'Cabut kad, jawab, teruskan — dan bawa kuda anda ke Makkah.';

  @override
  String get getStarted => 'Mulakan';

  @override
  String get onboardingHowTo => 'Cara bermain';

  @override
  String get onboardingStepDraw => 'Ambil kad: ia mengumumkan lompatannya';

  @override
  String get onboardingStepAnswer => 'Jawab betul: lompatan itu milik anda';

  @override
  String get onboardingStepRide => 'Letakkan kuda anda dan berlari ke oasis';

  @override
  String get onboardingLanguageHint =>
      'Anda boleh menukarnya kemudian dalam Tetapan.';

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
  String noMoveOvershoot(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Kad terlalu besar: kudamu $count petak dari Mekah dan perlukan tepat $count.',
    );
    return '$_temp0';
  }

  @override
  String get hudArrivedHeading => 'Kuda yang tiba';

  @override
  String get hudKnowledgeShort => 'ilmu';

  @override
  String get hudStreakShort => 'rentetan';

  @override
  String get hudCardsShort => 'kad';

  @override
  String get boardMenuTitle => 'Menu permainan';

  @override
  String get boardMenuOpen => 'Buka menu permainan';

  @override
  String get autoPlaySingleMove => 'Gerakan automatik';

  @override
  String get autoPlaySingleMoveHint =>
      'Apabila hanya satu kuda boleh bermain kad itu, ia melaju sendiri.';

  @override
  String get testerMode => 'Mod penguji';

  @override
  String testerModeHint(int total) {
    return 'Membuka kesemua $total soalan pada peranti ini tanpa pembelian. Tetapan ini hanya ada dalam versi ujian.';
  }

  @override
  String testerBankPlayable(int count, int total) {
    return '$count daripada $total soalan boleh dimainkan';
  }

  @override
  String get restartRace => 'Mulakan semula perlumbaan';

  @override
  String get restartRaceConfirm =>
      'Perlumbaan yang sedang berjalan akan hilang. Penunggang yang sama bermula semula dari kandang.';

  @override
  String get backToHome => 'Kembali ke Laman Utama';

  @override
  String get backToHomeHint =>
      'Permainan disimpan; kamu boleh menyambungnya nanti.';

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
  String get formatQuickHint => 'Perlumbaan paling singkat.';

  @override
  String get formatDuoHint => 'Perlumbaan satu petang.';

  @override
  String get formatClassicHint => 'Permainan penuh, seperti asalnya.';

  @override
  String get bonusSquaresOption => 'Petak bonus di laluan';

  @override
  String get bonusSquaresOn =>
      '16 petak memberi tunggangan tambahan: +5, +10 atau +20.';

  @override
  String get bonusSquaresOff =>
      'Laluan tulen: satu kad bernilai tepat derapnya.';

  @override
  String get muteSound => 'Senyapkan bunyi';

  @override
  String get unmuteSound => 'Hidupkan bunyi';

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
  String get ridersTitle => 'Para penunggang';

  @override
  String get storeLoading => 'Menyambung ke kedai…';

  @override
  String get storeUnavailableCta => 'Kedai tidak tersedia';

  @override
  String get premiumBenefitBank =>
      'Seluruh bank soalan, setiap satu dengan sumbernya';

  @override
  String premiumBenefitUnlimited(int count) {
    return 'Permainan tanpa had, hingga ke Makkah (versi percuma berhenti selepas $count cabutan)';
  }

  @override
  String get premiumBenefitFamily =>
      'Satu pembelian untuk seisi keluarga, tanpa iklan';

  @override
  String get progressEmpty =>
      'Main permainan pertama: kemajuan anda akan dipaparkan di sini.';

  @override
  String get addPlayer => 'Tambah Pemain';

  @override
  String get startGame => 'Mulakan Permainan';

  @override
  String get yourTurn => 'Giliran anda';

  @override
  String get categoryProphets => 'Para Nabi';

  @override
  String get categorySira => 'Sirah';

  @override
  String get categoryQuran => 'Al-Quran';

  @override
  String get categoryFaith => 'Akidah';

  @override
  String get categoryVirtues => 'Akhlak';

  @override
  String get category => 'Kategori';

  @override
  String get correctAnswer => 'Betul!';

  @override
  String get incorrectAnswer => 'Tidak tepat…';

  @override
  String get learnMore => 'Ketahui lebih lanjut';

  @override
  String get questionDetailsTitle => 'Di sebalik jawapan';

  @override
  String get theQuestionLabel => 'Soalan';

  @override
  String get theAnswerLabel => 'Jawapan yang betul';

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
      'Buka kunci seluruh bank soalan dan semua tahap kesukaran';

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
  String get howToPlay => 'Cara Bermain';

  @override
  String get privacySummary =>
      'IqraQuest berjalan sepenuhnya pada peranti anda: tiada akaun, tiada iklan, tiada penjejakan, dan tiada apa-apa dihantar melalui Internet.';

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
    return '$name memenangi perlumbaan!';
  }

  @override
  String get wellRidden =>
      'Tunggangan yang baik — setiap soalan yang dipelajari bermakna.';

  @override
  String horseSemantics(String color, num number) {
    return 'Kuda $color $number';
  }

  @override
  String get teamEmerald => 'zamrud';

  @override
  String get teamSaphir => 'nilam';

  @override
  String get teamGrenat => 'delima';

  @override
  String get teamSafran => 'safron';

  @override
  String premiumCta(String price) {
    return 'Buka semua — $price';
  }

  @override
  String premiumQuestionsIncluded(num count) {
    return '$count soalan disahkan, setiap satu dengan sumbernya — dan bank soalan terus berkembang.';
  }

  @override
  String get darkMode => 'Mod Gelap';

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
    return '© $year IqraQuest. Hak cipta terpelihara.';
  }

  @override
  String get originalWorkNotice =>
      'IqraQuest, konsep permainannya, peraturannya, ilustrasinya, namanya dan kandungannya adalah karya asli yang dilindungi hak cipta. Sebarang pengeluaran semula, peniruan atau adaptasi, sepenuhnya atau sebahagian, tanpa kebenaran bertulis adalah dilarang.';

  @override
  String get privacyPolicy => 'Dasar Privasi';

  @override
  String get genericError => 'Sesuatu tidak kena.';

  @override
  String get parentalGateTitle => 'Soalan untuk ibu bapa';

  @override
  String get parentalGateInstruction => 'Selesaikan ini untuk teruskan.';

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
      other: '$count petak khas',
    );
    return '$_temp0';
  }

  @override
  String get drawCard => 'Cabut kad';

  @override
  String get drawnCardTitle => 'Kad dicabut';

  @override
  String cardWorth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kad $count lompatan',
    );
    return '$_temp0';
  }

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
  String get knowledgeStreak => 'Jawapan betul berturut-turut';

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
      'Laluan paling tenang: oasis, sedikit kejutan.';

  @override
  String get circuitCaravanTrailDescription =>
      'Cabaran dan larian ganti di sepanjang jalan. Lebih taktikal.';

  @override
  String get circuitGreatRideDescription =>
      'Laluan paling meriah: cabaran, jalan pintas dan pertarungan.';

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
  String opponentThinking(String name) {
    return '$name sedang berfikir…';
  }

  @override
  String opponentDrew(String name, int count) {
    return '$name menarik kad $count';
  }

  @override
  String correctAnswerWas(String answer) {
    return 'Jawapan yang betul: $answer';
  }

  @override
  String get scoreboardTitle => 'Papan Perlumbaan';

  @override
  String scoreboardCorrect(int count) {
    return '$count betul';
  }

  @override
  String scoreboardBestStreak(int count) {
    return 'rentetan $count';
  }

  @override
  String get playAgainSameRiders => 'Lumba Lagi!';

  @override
  String opponentMoved(String name) {
    return '$name maju!';
  }

  @override
  String opponentStayed(String name) {
    return '$name kekal.';
  }

  @override
  String get shareScore => 'Kongsi';

  @override
  String shareVictoryText(String name, int points) {
    return '$name memenangi lumba IqraQuest dengan $points ⭐! Giliran anda?';
  }

  @override
  String shareDailyText(int score, int total) {
    return '$score/$total dalam cabaran harian IqraQuest! Boleh lebih baik?';
  }

  @override
  String get dailyChallengeDone => 'Cabaran harian selesai';

  @override
  String dailyChallengeScore(num score, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score betul daripada $total',
    );
    return '$_temp0';
  }

  @override
  String get dailyChallengeComeBack => 'Kembali esok untuk cabaran baharu.';

  @override
  String get aiOpponentsLabel => 'Lawan';

  @override
  String get playersLabel => 'Pemain';

  @override
  String get outcomeMoved => 'Kuda anda maju!';

  @override
  String get outcomeStayed => 'Kuda anda kekal. Tiada apa yang hilang.';

  @override
  String get outcomeCaptured => 'Anda menangkap kuda lawan!';

  @override
  String get outcomeExited => 'Kuda anda keluar dari kandang!';

  @override
  String get outcomeNoLegalMove =>
      'Kad ini tidak dapat menggerakkan mana-mana kuda. Giliran seterusnya!';

  @override
  String get noExitHint =>
      'Anda perlukan 6 untuk mengeluarkan kuda dari kandang.';

  @override
  String get bonusTurnHint => 'Giliran bonus: 6 membuat anda bermain lagi!';

  @override
  String get celebrateSixTitle => 'ENAM!';

  @override
  String get celebrateSixBody => 'Anda akan mencabut lagi selepas giliran ini.';

  @override
  String get celebrateSixExitBody =>
      'Seekor kuda boleh keluar — dan anda bermain lagi!';

  @override
  String get celebrateExitTitle => 'Pintu terbuka!';

  @override
  String get celebrateExitBody => 'Seekor kuda boleh keluar dari kandang.';

  @override
  String get celebrateCaptureTitle => 'Tangkap!';

  @override
  String get celebrateCaptureBody => 'Kuda lawan pulang ke kandangnya.';

  @override
  String get celebrateCapturedTitle => 'Ditangkap…';

  @override
  String get celebrateCapturedBody =>
      'Kuda anda pulang ke kandang. 6 mengeluarkannya semula.';

  @override
  String get celebrateArrivalTitle => 'Makkah!';

  @override
  String get celebrateArrivalBody =>
      'Kuda anda telah tiba. Satu soalan terakhir untuk mengesahkannya!';

  @override
  String get freeLimitTitle => 'Tamat perlumbaan percuma';

  @override
  String freeLimitLeader(String name) {
    return 'Mendahului: $name';
  }

  @override
  String freeLimitBody(int count) {
    return 'Versi percuma berhenti selepas $count cabutan. Dengan Premium, perlumbaan berterusan hingga ke Makkah.';
  }

  @override
  String get freeLimitCta => 'Buka perlumbaan tanpa had';

  @override
  String drawsCounter(int count, int max) {
    return 'Cabutan: $count daripada $max';
  }

  @override
  String moveChoiceTitle(int count) {
    return 'Apa yang anda mahu buat dengan $count ini?';
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
  String get moveHintFinish => 'tamat!';

  @override
  String get moveHintOasis => 'oasis';

  @override
  String opponentExits(String name) {
    return '$name mengeluarkan kuda!';
  }

  @override
  String opponentNoMove(String name) {
    return '$name tidak dapat menggerakkan apa-apa.';
  }

  @override
  String opponentReplays(String name) {
    return '$name mendapat 6 dan bermain lagi!';
  }

  @override
  String opponentCaptured(String name) {
    return '$name menangkap kuda!';
  }

  @override
  String get outcomeShieldBlocked => 'Perisai melindungi kuda itu.';

  @override
  String get outcomeShelteredByOasis =>
      'Oasis melindungi kuda itu: tiada siapa pulang ke kandang.';

  @override
  String get playerProfile => 'Tahap soalan';

  @override
  String get levelBeginner => 'Langkah pertama';

  @override
  String get levelBeginnerHint =>
      'Langkah pertama: asas yang paling awal, yang sudah diketahui semua orang.';

  @override
  String get levelEasy => 'Mudah';

  @override
  String get levelIntermediate => 'Sederhana';

  @override
  String get levelExpert => 'Pakar';

  @override
  String get levelMixed => 'Campuran';

  @override
  String get levelMixedHint =>
      'Campuran: setiap kad menarik tahapnya sendiri — mudah, sederhana atau pakar.';

  @override
  String get raceRulesUpdatedTitle =>
      'Peraturan perlumbaan telah ditambah baik';

  @override
  String get raceRulesUpdatedBody =>
      'Peraturan telah berubah: anda kini mencabut kad, dan nilainya memberi jarak sekali gus tahap kesukaran. Kemajuan, lencana dan pembelian anda dikekalkan — hanya permainan yang sedang berjalan tidak dapat disambung dengan peraturan baharu.';

  @override
  String get startNewRace => 'Mulakan perlumbaan baharu';

  @override
  String get rulesTitle => 'Peraturan';

  @override
  String get ruleGoalTitle => 'Memenangi perlumbaan';

  @override
  String get ruleGoalBody =>
      'Setiap pemain membawa empat kuda ke Mekah, di tengah papan. Sebelum permainan, meja memilih berapa yang mesti tiba: satu untuk perlumbaan pantas, dua untuk perlumbaan duo, keempat-empatnya untuk permainan klasik. Pemain pertama yang berjaya menang.';

  @override
  String get ruleKnowledgeTitle => 'Poin ilmu';

  @override
  String get ruleKnowledgeBody =>
      'Bintang pada bar mengira poin ilmumu: satu bagi setiap jawapan betul, dan satu lagi di petak Pengetahuan. Ia tidak menggerakkan kudamu — ia menyatakan apa yang kamu pelajari, dan memisahkan pemain jika permainan berhenti sebelum sesiapa tiba.';

  @override
  String get ruleSpecialCellsTitle => 'Petak khas';

  @override
  String get ruleSpecialCellsBody =>
      'Laluan yang kamu pilih membawa petak yang berfungsi, sama di keempat sukuannya: Oasis melindungi daripada tangkapan, Pengetahuan memberi satu poin ilmu, Cabaran menawarkan soalan lebih sukar untuk +2 derap, Jalan Singkat soalan sukar untuk memotong ke depan, dan Hikmah memberi satu fakta untuk disimpan. Cabaran atau Jalan Singkat yang gagal hanya merugikan bonusnya: kudamu kekal di tempatnya.';

  @override
  String get ruleDrawCardTitle => 'Cabut sekeping kad';

  @override
  String get ruleDrawCardBody =>
      'Pada pusinganmu, cabut satu kad. Kad itu terbalik menunjukkan nilainya — «Kad 5 derap» — kemudian soalannya terbuka, selalu pada tahapmu, yang dipilih pada mulanya: mudah, sederhana, pakar atau campuran. Jadi kamu tahu nilai jawapan betul sebelum menjawab.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Jawab untuk maju';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Jawapan betul memberimu derap kad itu: satu derap, satu petak. Kemudian pilih kuda yang mengambilnya — sentuh untuk melihat ke mana ia akan mendarat, lalu leretkannya ke petak emasnya. Melepaskannya ialah langkahnya: tiada apa bergerak sebelumnya, tiada pengesahan selepasnya. Jawapan salah tidak menggerakkan apa-apa: kamu tidak pernah mengundur.';

  @override
  String get ruleEscalierTitle => 'Tangga ke Makkah';

  @override
  String get ruleEscalierBody =>
      'Selepas satu pusingan penuh, kuda anda menaiki lima anak tangga tangganya ke Makkah. Di situ tiada siapa boleh mengejarnya.';

  @override
  String get ruleExitTitle => 'Keluar dari kandang';

  @override
  String get ruleExitBody =>
      'Setiap pemain ada empat kuda, dan yang pertama sudah berada di petak mulanya: kamu bermain dari kad pertama, tanpa menunggu. Tiga yang lain keluar dari kandang dengan angka 6 — jawab betul dan kuda itu mengambil petak mula. Dua kudamu tidak boleh berkongsi satu petak: kudamu yang berada di petak mula menutup pintunya sehingga ia bergerak.';

  @override
  String get ruleSixTitle => '6 bermain lagi';

  @override
  String get ruleSixBody =>
      'Seperti pada dadu: jika kamu mencabut 6, kamu bermain lagi selepas pusinganmu, betul atau salah jawapanmu.';

  @override
  String get ruleCaptureTitle => 'Menangkap dan menghantar pulang';

  @override
  String get ruleCaptureBody =>
      'Mendarat tepat pada kuda lawan menghantarnya pulang dengan tenang ke kandang — melainkan petak itu oasis, atau kuda itu membawa perisai ilmu. Tangkapan ada ganjarannya: kuda anda melompat 20 lompatan serta-merta. Kuda yang keluar dari kandang sentiasa menangkap di petak permulaannya.';

  @override
  String get ruleStreakTitle => 'Rentetan jawapan betul';

  @override
  String get ruleStreakBody =>
      'Tiga jawapan betul berturut-turut memberi perisai, lima memberi Grand Galop, dan sepuluh lencana penguasaan. Grand Galop dibelanjakan sendiri, dan hanya apabila +2 derapnya cukup untuk sampai ke penamat. Bonus datang daripada pengetahuan sahaja.';

  @override
  String get ruleArrivalTitle => 'Ketibaan';

  @override
  String get ruleArrivalBody =>
      'Garisan penamat dicapai dengan kiraan tepat: tiga petak dari Mekah anda perlukan tepat 3. Nombor 4, 5 atau 6 membiarkan kuda di tempatnya, menunggu kad yang betul. Setibanya, jawab Soalan Perjalanan untuk mengesahkan ketibaan anda; jawapan salah tidak pernah mengundurkan anda, anda cuba lagi pada giliran seterusnya.';

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
  String get touchHorseHint => 'Sentuh kuda untuk melihat ke mana ia pergi';

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
    return 'Tangkap! Kuda anda melompat $value lompatan ke hadapan.';
  }

  @override
  String bonusRide(int value) {
    return 'Petak bonus! Kuda anda mara $value petak lagi.';
  }

  @override
  String cardWasWorth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kad ini bernilai $count lompatan.',
    );
    return '$_temp0';
  }

  @override
  String get bonusMissedNote => 'Bonus terlepas: kudamu kekal di tempatnya.';

  @override
  String get answerToReveal => 'Jawab untuk mendedahkan nilainya';

  @override
  String opponentPlaces(String name) {
    return '$name memilih kuda…';
  }

  @override
  String opponentBonus(String name, int value) {
    return '$name mendapat bonus +$value!';
  }

  @override
  String get leaderLabel => 'Mendahului';

  @override
  String tookTheLead(String name) {
    return '$name mendahului!';
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
      '16 petak bonus menanti di papan: +5, +10 dan +20 yang jarang.';

  @override
  String get ridersSubtitle =>
      'Setiap penunggang memilih tahapnya; kad hanya menentukan jarak.';

  @override
  String get ruleBonusTitle => 'Petak bonus';

  @override
  String get ruleBonusBody =>
      'Jika meja mengekalkannya, enam belas petak bonus disebar di papan setiap permainan, empat setiap sukuan. Kuda yang berhenti tepat di atasnya terus melaju +5, +10 atau +20 derap — dan jika laju itu mendaratkannya tepat di petak bonus lain, petak itu turut menyala: bonus berangkai. Setiap petak membayar sekali setiap pusingan dan kekal dalam permainan untuk semua. Tanpanya, satu kad bernilai tepat derapnya.';
}
