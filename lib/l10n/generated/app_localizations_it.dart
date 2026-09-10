// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'IqraQuest';

  @override
  String get appTagline => 'Il viaggio della conoscenza';

  @override
  String get onboardingWelcomeTitle => 'Benvenuto su IqraQuest';

  @override
  String get onboardingWelcomeSubtitle =>
      'Pesca una carta, rispondi, avanza — e porta il tuo cavallo fino alla Mecca.';

  @override
  String get getStarted => 'Inizia';

  @override
  String get onboardingHowTo => 'Come si gioca';

  @override
  String get onboardingStepDraw => 'Pesca una carta: annuncia i suoi galoppi';

  @override
  String get onboardingStepAnswer => 'Rispondi bene: i galoppi sono tuoi';

  @override
  String get onboardingStepRide =>
      'Posa il tuo cavallo e galoppa fino all\'oasi';

  @override
  String get onboardingLanguageHint =>
      'Potrai cambiarla più tardi nelle impostazioni.';

  @override
  String get chooseLanguage => 'Scegli lingua';

  @override
  String get play => 'Gioca';

  @override
  String get soloMode => 'Solo';

  @override
  String get familyMode => 'Famiglia';

  @override
  String get dailyChallenge => 'Sfida del giorno';

  @override
  String get progress => 'Progressi';

  @override
  String get settings => 'Impostazioni';

  @override
  String get premium => 'Premium';

  @override
  String get continueGame => 'Continua partita';

  @override
  String get quickGame => 'Partita rapida';

  @override
  String get classicGame => 'Partita classica';

  @override
  String noMoveOvershoot(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Carta troppo grande: il tuo cavallo è a $count caselle dalla Mecca e gli serve esattamente $count.',
      one:
          'Carta troppo grande: il tuo cavallo è a $count casella dalla Mecca e gli serve esattamente 1.',
    );
    return '$_temp0';
  }

  @override
  String get hudArrivedHeading => 'Cavalli arrivati';

  @override
  String get hudKnowledgeShort => 'sapere';

  @override
  String get hudStreakShort => 'serie';

  @override
  String get hudCardsShort => 'carte';

  @override
  String get boardMenuTitle => 'Menu della partita';

  @override
  String get boardMenuOpen => 'Apri il menu della partita';

  @override
  String get autoPlaySingleMove => 'Mossa automatica';

  @override
  String get autoPlaySingleMoveHint =>
      'Quando un solo cavallo può giocare la carta, avanza da sé.';

  @override
  String get testerMode => 'Modalità tester';

  @override
  String testerModeHint(int total) {
    return 'Sblocca tutte le $total domande su questo dispositivo, senza acquisto. Questa impostazione esiste solo nelle versioni di prova.';
  }

  @override
  String testerBankPlayable(int count, int total) {
    return '$count domande giocabili su $total';
  }

  @override
  String get restartRace => 'Ricomincia la corsa';

  @override
  String get restartRaceConfirm =>
      'La corsa in corso andrà persa. Gli stessi cavalieri ripartono dalla stalla.';

  @override
  String get backToHome => 'Torna alla home';

  @override
  String get backToHomeHint => 'La partita è salvata; potrai riprenderla.';

  @override
  String get duoGame => 'Partita in duo';

  @override
  String horsesToMecca(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cavalli alla Mecca',
      one: '$count cavallo alla Mecca',
    );
    return '$_temp0';
  }

  @override
  String get formatQuickHint => 'La corsa più breve.';

  @override
  String get formatDuoHint => 'Una corsa di una sera.';

  @override
  String get formatClassicHint =>
      'La partita completa, come nel gioco originale.';

  @override
  String get bonusSquaresOption => 'Caselle bonus sul percorso';

  @override
  String get bonusSquaresOn =>
      '16 caselle regalano una cavalcata in più: +5, +10 o +20.';

  @override
  String get bonusSquaresOff =>
      'Percorso puro: una carta vale esattamente i suoi galoppi.';

  @override
  String get muteSound => 'Disattiva audio';

  @override
  String get unmuteSound => 'Attiva audio';

  @override
  String get chooseDifficulty => 'Scegli difficoltà';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Medio';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get playerName => 'Nome';

  @override
  String get chooseTeam => 'Scegli squadra';

  @override
  String get ridersTitle => 'I cavalieri';

  @override
  String get storeLoading => 'Connessione allo store…';

  @override
  String get storeUnavailableCta => 'Store non disponibile';

  @override
  String get premiumBenefitBank =>
      'Tutta la banca di domande, ognuna con la sua fonte';

  @override
  String premiumBenefitUnlimited(int count) {
    return 'Partite illimitate, fino alla Mecca (la versione gratuita si ferma dopo $count pescate)';
  }

  @override
  String get premiumBenefitFamily =>
      'Un solo acquisto per tutta la famiglia, senza pubblicità';

  @override
  String get progressEmpty =>
      'Gioca una prima partita: i tuoi progressi appariranno qui.';

  @override
  String get addPlayer => 'Aggiungi giocatore';

  @override
  String get startGame => 'Inizia partita';

  @override
  String get yourTurn => 'Tocca a te';

  @override
  String get categoryProphets => 'Profeti';

  @override
  String get categorySira => 'Sira';

  @override
  String get categoryQuran => 'Corano';

  @override
  String get categoryFaith => 'Fede';

  @override
  String get categoryVirtues => 'Virtù';

  @override
  String get category => 'Categoria';

  @override
  String get correctAnswer => 'Risposta corretta!';

  @override
  String get incorrectAnswer => 'Non proprio…';

  @override
  String get learnMore => 'Scopri di più';

  @override
  String get questionDetailsTitle => 'Dietro la risposta';

  @override
  String get theQuestionLabel => 'La domanda';

  @override
  String get theAnswerLabel => 'La risposta giusta';

  @override
  String get explanationLabel => 'Spiegazione';

  @override
  String get detailLabel => 'Nel dettaglio';

  @override
  String get sourceLabel => 'Fonte';

  @override
  String get nextPlayer => 'Prossimo giocatore';

  @override
  String get rolledSix => 'Un sei! Un altro turno — nuova domanda.';

  @override
  String get playAgain => 'Gioca ancora';

  @override
  String get protectedSquareLabel => 'Casella protetta';

  @override
  String get freeBankExhaustedMessage =>
      'Tutte le domande dell\'edizione gratuita sono state usate in questa partita.';

  @override
  String get victory => 'Vittoria!';

  @override
  String get gameOver => 'Partita terminata';

  @override
  String get gamesPlayed => 'Partite giocate';

  @override
  String get winRate => 'Percentuale di vittorie';

  @override
  String get questionsAnswered => 'Domande risposte';

  @override
  String get streak => 'Serie di giorni';

  @override
  String get premiumTitle => 'IqraQuest Premium';

  @override
  String get premiumUnlockAll =>
      'Sblocca tutte le carte, tutti i percorsi, i salvataggi e il livello misto';

  @override
  String get premiumOneTime => 'Pagamento unico — nessun abbonamento';

  @override
  String get restorePurchases => 'Ripristina acquisti';

  @override
  String get purchaseSuccess => 'Grazie! Premium è ora attivo.';

  @override
  String get purchaseError =>
      'Impossibile completare l\'acquisto. Riprova più tardi.';

  @override
  String get language => 'Lingua';

  @override
  String get reduceMotion => 'Riduci animazioni';

  @override
  String get soundEffects => 'Effetti sonori';

  @override
  String get howToPlay => 'Come si gioca';

  @override
  String get privacySummary =>
      'IqraQuest funziona interamente sul tuo dispositivo: nessun account, nessuna pubblicità, nessun tracciamento, e nulla viene mai inviato su Internet.';

  @override
  String defaultPlayerName(num number) {
    return 'Giocatore $number';
  }

  @override
  String aiPlayerName(num number) {
    return 'Cavaliere $number';
  }

  @override
  String opponentWins(String name) {
    return '$name vince la corsa!';
  }

  @override
  String get wellRidden => 'Bella cavalcata — ogni domanda imparata conta.';

  @override
  String horseSemantics(String color, num number) {
    return 'Cavallo $color $number';
  }

  @override
  String get teamEmerald => 'smeraldo';

  @override
  String get teamSaphir => 'zaffiro';

  @override
  String get teamGrenat => 'granata';

  @override
  String get teamSafran => 'zafferano';

  @override
  String premiumCta(String price) {
    return 'Sblocca tutto — $price';
  }

  @override
  String premiumQuestionsIncluded(num count) {
    return '$count domande verificate, ognuna con la sua fonte — e la raccolta continua a crescere.';
  }

  @override
  String get darkMode => 'Modalità scura';

  @override
  String get about => 'Informazioni';

  @override
  String get aboutDialogTitle => 'Informazioni su IqraQuest';

  @override
  String versionLabel(String version) {
    return 'Versione $version';
  }

  @override
  String copyrightNotice(String year) {
    return '© $year IqraQuest. Tutti i diritti riservati.';
  }

  @override
  String get originalWorkNotice =>
      'IqraQuest, il suo concetto di gioco, le sue regole, le sue illustrazioni, il suo nome e i suoi contenuti sono opere originali protette dal diritto d\'autore. È vietata qualsiasi riproduzione, imitazione o adattamento, totale o parziale, senza autorizzazione scritta.';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get genericError => 'Qualcosa è andato storto.';

  @override
  String get parentalGateTitle => 'Una domanda per i genitori';

  @override
  String get parentalGateInstruction => 'Risolvi questo per continuare.';

  @override
  String get placeMecca => 'La Mecca';

  @override
  String get placeMedina => 'Medina';

  @override
  String get placeAlAqsa => 'Al-Aqsa';

  @override
  String get placeArafat => 'Monte Arafat';

  @override
  String get placeMina => 'Mina';

  @override
  String circuitSpecialSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caselle speciali',
      one: '$count casella speciale',
    );
    return '$_temp0';
  }

  @override
  String get drawCard => 'Pesca una carta';

  @override
  String get drawnCardTitle => 'Carta pescata';

  @override
  String cardWorth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Carta da $count galoppi',
      one: 'Carta da $count galoppo',
    );
    return '$_temp0';
  }

  @override
  String gaitSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caselle',
      one: '$count casella',
    );
    return '$_temp0';
  }

  @override
  String get gaitNameWalk => 'Passo';

  @override
  String get gaitNameTrot => 'Trotto';

  @override
  String get gaitNameCanter => 'Piccolo galoppo';

  @override
  String get gaitNameGallop => 'Galoppo';

  @override
  String get gaitNameFullGallop => 'Galoppo disteso';

  @override
  String get gaitNameCharge => 'Carica';

  @override
  String get chooseFormat => 'Formato di partita';

  @override
  String get gaitAlreadyUsed => 'Già usata in questo ciclo';

  @override
  String gaitSemanticLabel(int steps, String difficulty, int points) {
    return 'Avanza di $steps caselle, domanda $difficulty, $points punti sapere';
  }

  @override
  String get selectHorse => 'Scegli il tuo cavallo';

  @override
  String get knowledgeStreak => 'Risposte esatte di fila';

  @override
  String get knowledgePointsLabel => 'Punti sapere';

  @override
  String get shieldEarned => 'Scudo ottenuto! Il tuo cavallo è protetto.';

  @override
  String get grandGallopEarned =>
      'Gran Galoppo sbloccato! +2 caselle quando vuoi.';

  @override
  String get masteryBadgeEarned => 'Distintivo di maestria ottenuto!';

  @override
  String get useGrandGallop => 'Usa il Gran Galoppo (+2)';

  @override
  String get chooseCircuit => 'Scegli il tuo percorso';

  @override
  String get circuitOasisRoute => 'La Via delle Oasi';

  @override
  String get circuitCaravanTrail => 'La Pista delle Carovane';

  @override
  String get circuitGreatRide => 'La Grande Cavalcata del Sapere';

  @override
  String get circuitOasisRouteDescription =>
      'Il percorso più tranquillo: oasi e poche sorprese.';

  @override
  String get circuitCaravanTrailDescription =>
      'Sfide e staffette lungo il cammino. Più tattico.';

  @override
  String get circuitGreatRideDescription =>
      'Il percorso più vivace: sfide, scorciatoie e duelli.';

  @override
  String get cellOasis => 'Oasi';

  @override
  String get cellKnowledge => 'Conoscenza';

  @override
  String get cellChallenge => 'Sfida';

  @override
  String get cellShortcut => 'Scorciatoia';

  @override
  String get cellDuel => 'Duello';

  @override
  String get cellWisdom => 'Saggezza';

  @override
  String get cellRelay => 'Staffetta';

  @override
  String get cellOasisDescription => 'Il tuo cavallo è al sicuro qui.';

  @override
  String get cellChallengeOffer =>
      'Rispondere a una domanda più difficile per avanzare di 2 caselle?';

  @override
  String get acceptChallenge => 'Accetta la sfida';

  @override
  String get declineChallenge => 'Tieni la mia mossa';

  @override
  String get saveFact => 'Conserva questo fatto';

  @override
  String get journeyQuestion => 'Domanda del viaggio';

  @override
  String get journeyQuestionIntro =>
      'Un\'ultima domanda per convalidare il tuo arrivo.';

  @override
  String opponentThinking(String name) {
    return '$name sta pensando…';
  }

  @override
  String opponentDrew(String name, int count) {
    return '$name pesca un $count';
  }

  @override
  String correctAnswerWas(String answer) {
    return 'La risposta giusta: $answer';
  }

  @override
  String get scoreboardTitle => 'Tabellone della corsa';

  @override
  String scoreboardCorrect(int count) {
    return '$count corrette';
  }

  @override
  String scoreboardBestStreak(int count) {
    return 'serie di $count';
  }

  @override
  String get playAgainSameRiders => 'Un\'altra corsa!';

  @override
  String opponentMoved(String name) {
    return '$name avanza!';
  }

  @override
  String opponentStayed(String name) {
    return '$name resta fermo.';
  }

  @override
  String get shareScore => 'Condividi';

  @override
  String shareVictoryText(String name, int points) {
    return '$name ha vinto la corsa IqraQuest con $points ⭐! Tocca a te?';
  }

  @override
  String shareDailyText(int score, int total) {
    return '$score/$total alla sfida del giorno IqraQuest! Fai di meglio?';
  }

  @override
  String get dailyChallengeDone => 'Sfida del giorno completata';

  @override
  String dailyChallengeScore(num score, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score giuste su $total',
      one: '$score giusta su $total',
      zero: 'Nessuna risposta giusta su $total',
    );
    return '$_temp0';
  }

  @override
  String get dailyChallengeComeBack => 'Torna domani per una nuova sfida.';

  @override
  String get aiOpponentsLabel => 'Avversari';

  @override
  String get playersLabel => 'Giocatori';

  @override
  String get outcomeMoved => 'Il tuo cavallo avanza!';

  @override
  String get outcomeStayed => 'Il tuo cavallo resta fermo. Non perdi nulla.';

  @override
  String get outcomeCaptured => 'Catturi un cavallo avversario!';

  @override
  String get outcomeExited => 'Il tuo cavallo esce dalla stalla!';

  @override
  String get outcomeNoLegalMove =>
      'Questa carta non può muovere nessun cavallo. Turno successivo!';

  @override
  String get noExitHint => 'Serve un 6 per far uscire un cavallo dalla stalla.';

  @override
  String get bonusTurnHint => 'Turno bonus: il 6 ti fa giocare ancora!';

  @override
  String get celebrateSixTitle => 'SEI!';

  @override
  String get celebrateSixBody => 'Pescherai di nuovo dopo questo turno.';

  @override
  String get celebrateSixExitBody =>
      'Un cavallo può uscire — e giocherai ancora!';

  @override
  String get celebrateExitTitle => 'Uscita!';

  @override
  String get celebrateExitBody => 'Un cavallo può uscire dalla stalla.';

  @override
  String get celebrateCaptureTitle => 'Cattura!';

  @override
  String get celebrateCaptureBody =>
      'Il cavallo avversario torna nella sua stalla.';

  @override
  String get celebrateCapturedTitle => 'Catturato…';

  @override
  String get celebrateCapturedBody =>
      'Il tuo cavallo torna nella stalla. Un 6 lo farà uscire di nuovo.';

  @override
  String get celebrateArrivalTitle => 'La Mecca!';

  @override
  String get celebrateArrivalBody =>
      'Il tuo cavallo è arrivato. Un\'ultima domanda per convalidarlo!';

  @override
  String get freeLimitTitle => 'Fine della corsa gratuita';

  @override
  String freeLimitLeader(String name) {
    return 'In testa: $name';
  }

  @override
  String freeLimitBody(int count) {
    return 'La versione gratuita si ferma dopo $count pescate. Con Premium, la corsa arriva fino alla Mecca.';
  }

  @override
  String get freeLimitCta => 'Sblocca la corsa illimitata';

  @override
  String drawsCounter(int count, int max) {
    return 'Pescate: $count su $max';
  }

  @override
  String moveChoiceTitle(int count) {
    return 'Che fai con questo $count?';
  }

  @override
  String get moveChoiceExit => 'Far uscire un cavallo dalla stalla';

  @override
  String moveChoiceAdvance(int number, int count) {
    return 'Cavallo $number: avanza di $count';
  }

  @override
  String moveHintCapture(int value) {
    return 'cattura! +$value';
  }

  @override
  String get moveHintFinish => 'arrivo!';

  @override
  String get moveHintOasis => 'oasi';

  @override
  String opponentExits(String name) {
    return '$name fa uscire un cavallo!';
  }

  @override
  String opponentNoMove(String name) {
    return '$name non può muovere nulla.';
  }

  @override
  String opponentReplays(String name) {
    return '$name ha pescato un 6 e gioca ancora!';
  }

  @override
  String opponentCaptured(String name) {
    return '$name cattura un cavallo!';
  }

  @override
  String get outcomeShieldBlocked => 'Lo scudo ha protetto il cavallo.';

  @override
  String get outcomeShelteredByOasis =>
      'L\'Oasi protegge quel cavallo: nessuno torna alla stalla.';

  @override
  String get playerProfile => 'Livello delle domande';

  @override
  String get levelBeginner => 'Primi passi';

  @override
  String get levelBeginnerHint =>
      'Primi passi: le primissime basi, quelle che tutti già conoscono.';

  @override
  String get levelEasy => 'Facile';

  @override
  String get levelIntermediate => 'Intermedio';

  @override
  String get levelExpert => 'Esperto';

  @override
  String get levelMixed => 'Misto';

  @override
  String get levelMixedHint =>
      'Misto: ogni carta pesca il suo livello, dai primi passi a esperto.';

  @override
  String get raceRulesUpdatedTitle =>
      'Le regole della corsa sono state migliorate';

  @override
  String get raceRulesUpdatedBody =>
      'Le regole sono cambiate: ora peschi una carta, e il suo valore dà insieme la distanza e la difficoltà. I tuoi progressi, i badge e gli acquisti restano — solo la partita in corso non può riprendere con le nuove regole.';

  @override
  String get startNewRace => 'Inizia una nuova corsa';

  @override
  String get rulesTitle => 'Le regole';

  @override
  String get ruleGoalTitle => 'Vincere la corsa';

  @override
  String get ruleGoalBody =>
      'Ogni giocatore conduce quattro cavalli verso la Mecca, al centro del tabellone. Prima della partita il tavolo scegli quanti devono arrivare: uno per una corsa rapida, due per una corsa in duo, tutti e quattro per la partita classica. Vince il primo che ci riesce.';

  @override
  String get ruleKnowledgeTitle => 'Punti sapere';

  @override
  String get ruleKnowledgeBody =>
      'La stella nella barra conta i tuoi punti sapere: uno per ogni risposta esatta e uno in più su una casella Conoscenza. Non fanno avanzare il cavallo — dicono che cosa hai imparato e separano i giocatori se la partita finisce prima dell\'arrivo.';

  @override
  String get ruleSpecialCellsTitle => 'Le caselle speciali';

  @override
  String get ruleSpecialCellsBody =>
      'Il percorso che hai scelto porta caselle che fanno qualcosa, le stesse nei suoi quattro quarti: l\'Oasi protegge dalle catture, Conoscenza dà un punto sapere, la Sfida propone una domanda più difficile per +2 galoppi, la Scorciatoia una domanda difficile per passare avanti, e Saggezza offre un fatto da conservare. Una Sfida o una Scorciatoia mancata costa solo il bonus: il tuo cavallo resta dov\'è.';

  @override
  String get ruleDrawCardTitle => 'Pesca una carta';

  @override
  String get ruleDrawCardBody =>
      'Al tuo turno pesca una carta. Si gira sul suo valore — «Carta da 5 galoppi» — poi si apre la domanda, sempre al tuo livello, scelto all\'inizio: facile, intermedio, esperto o misto. Sai quindi quanto vale una risposta esatta prima di rispondere.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Rispondi per avanzare';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Una risposta esatta ti fa guadagnare i galoppi della carta: un galoppo, una casella. Scegli poi il cavallo che li prende — toccalo per vedere dove arriverebbe, poi trascinalo sulla sua casella dorata. Lasciarlo è la mossa: nulla si muove prima, nulla chiede conferma dopo. Una risposta sbagliata non muove nulla: non torni mai indietro.';

  @override
  String get ruleEscalierTitle => 'La scala verso La Mecca';

  @override
  String get ruleEscalierBody =>
      'Dopo un giro completo del tabellone, il tuo cavallo sale i cinque gradini della sua scala verso La Mecca. Lì nessuno può più raggiungerlo.';

  @override
  String get ruleExitTitle => 'Uscire dalla stalla';

  @override
  String get ruleExitBody =>
      'Ogni giocatore ha quattro cavalli, e il primo è già sulla sua casella di partenza: giochi dalla prima carta, senza attendere. Gli altri tre escono dalla stalla con un 6 — rispondi bene e il cavallo prende la casella di partenza. Due dei tuoi cavalli non condividono mai una casella: uno dei tuoi fermo sulla casella di partenza tiene chiuso il cancello finché non avanza.';

  @override
  String get ruleSixTitle => 'Il 6 fa rigiocare';

  @override
  String get ruleSixBody =>
      'Come col dado: se peschi un 6, giochi di nuovo dopo il tuo turno, che la risposta sia esatta o no.';

  @override
  String get ruleCaptureTitle => 'Cattura e rimanda a casa';

  @override
  String get ruleCaptureBody =>
      'Arrivare esattamente sul cavallo di un avversario lo rimanda con calma alla sua stalla, a meno che la casella sia un\'oasi o quel cavallo porti uno scudo del sapere. La cattura si paga: il tuo cavallo balza subito di 20 galoppi. Un cavallo che esce dalla stalla cattura sempre sulla sua casella di partenza.';

  @override
  String get ruleStreakTitle => 'La serie di risposte esatte';

  @override
  String get ruleStreakBody =>
      'Tre risposte giuste di fila danno uno scudo, cinque il Gran Galoppo e dieci un distintivo di maestria. Il Gran Galoppo si spende da solo, e solo quando i suoi +2 galoppi bastano a tagliare il traguardo. I bonus vengono solo dalla conoscenza.';

  @override
  String get ruleArrivalTitle => 'L\'arrivo';

  @override
  String get ruleArrivalBody =>
      'Il traguardo si raggiunge con il conto esatto: a tre caselle dalla Mecca ti serve esattamente un 3. Un 4, un 5 o un 6 lascia il cavallo dov\'è, in attesa della carta giusta. Una volta arrivato, rispondi alla Domanda del viaggio per convalidare l\'arrivo; un errore non ti fa mai arretrare, riprovi al turno successivo.';

  @override
  String get hapticFeedback => 'Vibrazione';

  @override
  String squaresWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count galoppi vinti',
      one: '$count galoppo vinto',
    );
    return '$_temp0';
  }

  @override
  String get chooseHorseToMove => 'Scegli un cavallo';

  @override
  String get touchHorseHint => 'Tocca un cavallo per vedere dove andrebbe';

  @override
  String get dragHorseToDestination =>
      'Trascina il cavallo sulla sua casella dorata';

  @override
  String get bonusLabel => 'BONUS';

  @override
  String bonusPlus(int value) {
    return '+$value galoppi';
  }

  @override
  String get captureBonusLabel => 'CATTURA';

  @override
  String captureBonusRide(int value) {
    return 'Cattura! Il tuo cavallo balza in avanti di $value galoppi.';
  }

  @override
  String bonusRide(int value) {
    return 'Casella bonus! Il tuo cavallo avanza di altre $value caselle.';
  }

  @override
  String cardWasWorth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Questa carta valeva $count galoppi.',
      one: 'Questa carta valeva $count galoppo.',
    );
    return '$_temp0';
  }

  @override
  String get bonusMissedNote => 'Bonus mancato: il tuo cavallo resta dov\'è.';

  @override
  String get answerToReveal => 'Rispondi per scoprire il suo valore';

  @override
  String opponentPlaces(String name) {
    return '$name sceglie un cavallo…';
  }

  @override
  String opponentBonus(String name, int value) {
    return '$name ottiene un bonus +$value!';
  }

  @override
  String get leaderLabel => 'In testa';

  @override
  String tookTheLead(String name) {
    return '$name passa in testa!';
  }

  @override
  String bonusSquareSemantics(int value) {
    return 'Casella bonus +$value';
  }

  @override
  String moveHintBonus(int value) {
    return 'Bonus +$value';
  }

  @override
  String get bonusSquaresTeaser =>
      '16 caselle bonus ti aspettano sul tabellone: +5, +10 e la rara +20.';

  @override
  String get ridersSubtitle =>
      'Ogni cavaliere sceglie il suo livello; la carta decide solo la distanza.';

  @override
  String get ruleBonusTitle => 'Le caselle bonus';

  @override
  String get ruleBonusBody =>
      'Se il tavolo le tiene, sedici caselle bonus sono distribuite sul tabellone a ogni partita, quattro per quarto. Un cavallo che si ferma esattamente su una riparte subito di +5, +10 o +20 galoppi — e se quella cavalcata lo posa esattamente su un\'altra casella bonus, parte anche quella: i bonus si concatenano. Ogni casella paga una volta per turno e resta in gioco per tutti. Senza di esse, una carta vale esattamente i suoi galoppi.';

  @override
  String get newGameTitle => 'Nuova partita';

  @override
  String get setupWhoPlays => 'Chi gioca?';

  @override
  String get computerStrengthLabel => 'Forza degli avversari';

  @override
  String get strengthLabelShort => 'Forza';

  @override
  String get autoRidersNote => 'Cavalieri automatici';

  @override
  String autoRidersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cavalieri',
      one: '$count cavaliere',
    );
    return '$_temp0';
  }

  @override
  String get questionLevelNote =>
      'Livello domande: al passo successivo, per giocatore.';

  @override
  String get setupRaceLength => 'Durata della partita';

  @override
  String get raceLengthShort => 'Partita breve';

  @override
  String get raceLengthMedium => 'Partita media';

  @override
  String get raceLengthFull => 'Partita completa';

  @override
  String get setupCourse => 'Percorso';

  @override
  String get courseCalm => 'Tranquillo';

  @override
  String get courseLively => 'Vivace';

  @override
  String get courseIntense => 'Intenso';

  @override
  String get courseSquareOasis => 'Oasi: il tuo cavallo è al sicuro';

  @override
  String get courseSquareKnowledge => 'Conoscenza: +1 punto sapere';

  @override
  String get courseSquareChallenge =>
      'Sfida: una domanda in più per +2 caselle';

  @override
  String get courseSquareShortcut =>
      'Scorciatoia: una domanda difficile per saltare avanti';

  @override
  String get courseSquareWisdom =>
      'Saggezza: un fatto da scoprire e conservare';

  @override
  String get levelEasyHint =>
      'Facile: domande semplici su ciò che si impara per primo.';

  @override
  String get levelIntermediateHint =>
      'Intermedio: per chi conosce già bene storie e regole.';

  @override
  String get levelExpertHint =>
      'Esperto: le domande più precise, con versetti e hadith.';

  @override
  String get saveGame => 'Salva partita';

  @override
  String get saveGameHint => 'Dalle un nome per ritrovarla dopo';

  @override
  String get saveGameNameLabel => 'Nome della partita';

  @override
  String get saveAction => 'Salva';

  @override
  String gameSavedAs(String name) {
    return 'Partita salvata: $name';
  }

  @override
  String get loadGame => 'Carica una partita';

  @override
  String get loadGameAction => 'Carica';

  @override
  String get noSavedGames => 'Nessuna partita salvata per ora.';

  @override
  String get noSavedGamesHint =>
      'Durante una partita, apri il menu ≡ del tabellone e scegli «Salva partita».';

  @override
  String get deleteSave => 'Elimina questo salvataggio';

  @override
  String deleteSaveConfirm(String name) {
    return 'Eliminare «$name»? Questa partita salvata andrà persa.';
  }

  @override
  String get deleteAction => 'Elimina';

  @override
  String get loadGameFailed => 'Questo salvataggio non può essere aperto.';

  @override
  String get gameInProgressTitle => 'C\'è una partita in corso';

  @override
  String get gameInProgressReplaceBody =>
      'Sarà sostituita. Vuoi prima conservarla con un nome?';

  @override
  String get replaceWithoutSaving => 'Sostituisci senza conservare';

  @override
  String get keepUnderName => 'Conserva con un nome…';

  @override
  String savesFull(num count) {
    return 'Hai già $count partite salvate: eliminane una o riutilizza un nome esistente.';
  }

  @override
  String get defaultSaveName => 'La mia partita';

  @override
  String get premiumOnly => 'Solo Premium';

  @override
  String premiumBenefitCourses(String lively, String intense) {
    return 'I percorsi $lively e $intense, con tutte le loro caselle speciali';
  }

  @override
  String get premiumBenefitSaves =>
      'Salvare più partite con un nome e riprenderle';

  @override
  String premiumBenefitMixed(String mixed) {
    return 'Il livello $mixed: ogni carta pesca il proprio livello';
  }

  @override
  String get premiumBannerTitle => 'Passa a Premium';

  @override
  String get premiumBannerBody =>
      'Tutte le carte, tutti i percorsi, i salvataggi';

  @override
  String get premiumActive => 'Premium attivo: tutto sbloccato';

  @override
  String get laterAction => 'Più tardi';

  @override
  String freeLimitPopupBody(int count) {
    return 'Hai giocato le $count carte della versione gratuita. Con Premium la corsa continua fino alla Mecca, con tutte le carte, tutti i percorsi e i salvataggi.';
  }

  @override
  String get classroomJoin => 'Unisciti a una classe';

  @override
  String get classroomCodeLabel => 'Codice della sessione';

  @override
  String get classroomNicknameLabel => 'Il tuo nome';

  @override
  String get classroomPrivacyNote =>
      'Nessun account. Il tuo nome e le tue risposte si cancellano a fine sessione.';

  @override
  String get classroomWaiting => 'La lezione sta per iniziare';

  @override
  String get classroomWaitingHint => 'Il tuo insegnante apre la prima domanda.';

  @override
  String classroomTeamOf(String colour) {
    return 'Squadra $colour';
  }

  @override
  String classroomQuestionOf(num current, num total) {
    return 'Domanda $current di $total';
  }

  @override
  String get classroomAnswerSent => 'Risposta inviata';

  @override
  String get classroomAnswerSentHint =>
      'Guarda la lavagna: la risposta arriva.';

  @override
  String get classroomAnswerMissed => 'Non hai risposto in tempo';

  @override
  String get classroomSessionOver => 'La sessione è finita';

  @override
  String classroomYourScore(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hai fatto avanzare il tuo cavallo di $count caselle',
      one: 'Hai fatto avanzare il tuo cavallo di una casella',
    );
    return '$_temp0';
  }

  @override
  String get classroomLeave => 'Esci dalla classe';

  @override
  String get classroomUnknownCode =>
      'Nessuna sessione aperta ha questo codice.';

  @override
  String get classroomSessionFull => 'Questa sessione è al completo.';

  @override
  String get classroomTooLate => 'Troppo tardi: il tempo era finito.';

  @override
  String get classroomUnreachable =>
      'La classe non è raggiungibile. Controlla la connessione.';

  @override
  String get classroomReconnecting => 'Riconnessione…';

  @override
  String get teacherConsole => 'Console dell\'insegnante';

  @override
  String get teacherSignInHint =>
      'Inserisci l\'indirizzo che ha pagato la licenza: lì ti aspetta un link di accesso. Nessuna password.';

  @override
  String get teacherEmailLabel => 'Indirizzo e-mail';

  @override
  String get teacherSendLink => 'Inviami il link';

  @override
  String teacherLinkSent(String email) {
    return 'Link inviato a $email. Aprilo su questo dispositivo.';
  }

  @override
  String get teacherInvalidEmail => 'Non sembra un indirizzo e-mail.';

  @override
  String get teacherNoLicence =>
      'Nessuna licenza è associata a questo indirizzo.';

  @override
  String get teacherNoLicenceHint =>
      'La licenza è legata all’indirizzo che ha pagato. Se l’acquisto è stato fatto con un altro indirizzo, esci e usa quello.';

  @override
  String get teacherGetLicence => 'Ottieni una licenza';

  @override
  String get teacherLicencePaidElsewhere =>
      'Il pagamento avviene sulla pagina sicura di Stripe; poi torna qui.';

  @override
  String get teacherRefresh => 'Controlla di nuovo';

  @override
  String get teacherSignOut => 'Esci';

  @override
  String teacherLicenceUntil(String date) {
    return 'Licenza valida fino al $date';
  }

  @override
  String get teacherLicenceExpired => 'Licenza scaduta';

  @override
  String get levelLabel => 'Livello';

  @override
  String get teacherChooseLesson => 'Scegli la lezione';

  @override
  String get teacherScoringMode => 'Come si contano i punti';

  @override
  String get teacherScoringTeams => 'A squadre';

  @override
  String get teacherScoringIndividual => 'Classifica individuale';

  @override
  String get teacherScoringIndividualHint =>
      'Ogni nome compare in classifica sulla lavagna. Una classifica mostra il primo, ma anche l’ultimo, davanti a tutta la classe.';

  @override
  String get teacherTimer => 'Cronometro';

  @override
  String get teacherTimerNone => 'Nessuno — rivelo io';

  @override
  String teacherTimerSeconds(num seconds) {
    return '$seconds secondi';
  }

  @override
  String get teacherLength => 'Durata';

  @override
  String teacherLengthAll(num count) {
    return 'Lezione intera ($count carte)';
  }

  @override
  String teacherLengthShort(num count) {
    return 'Le prime $count carte';
  }

  @override
  String get teacherShuffle => 'Mescola l’ordine delle carte';

  @override
  String get teacherShuffleHint =>
      'Una classe che rigioca la stessa lezione non risponde più a memoria.';

  @override
  String get classroomScanToJoin => 'Inquadra il codice, o digitalo';

  @override
  String get classroomRanking => 'Classifica';

  @override
  String classroomPointsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pt',
      one: '$count pt',
    );
    return '$_temp0';
  }

  @override
  String get teacherBackToSite => 'iqraquest.org';

  @override
  String get teacherPasswordLabel => 'Password';

  @override
  String get teacherSignIn => 'Accedi';

  @override
  String get teacherSignInPasswordHint =>
      'Inserisci l\'indirizzo del tuo istituto e la tua password.';

  @override
  String get teacherBadCredentials => 'Indirizzo o password non corretti.';

  @override
  String get teacherForgotPassword => 'Password dimenticata?';

  @override
  String get teacherAccount => 'Il tuo abbonamento';

  @override
  String teacherAccountRooms(num used, num total) {
    String _temp0 = intl.Intl.pluralLogic(
      used,
      locale: localeName,
      other: '$used di $total sale aperte',
      one: '$used di $total sale aperta',
    );
    return '$_temp0';
  }

  @override
  String teacherAccountEndedOn(String date) {
    return 'Terminato il $date';
  }

  @override
  String get teacherRenewByEmail =>
      'Scrivici per rinnovare: riapriamo la tua area il giorno stesso.';

  @override
  String teacherAccountDaysLeft(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ancora $count giorni',
      one: 'Ancora $count giorno',
    );
    return '$_temp0';
  }

  @override
  String get teacherAccountEndingSoon => 'Il tuo abbonamento sta per finire.';

  @override
  String get teacherAccountRenews => 'Si rinnova automaticamente.';

  @override
  String get teacherExpired => 'Il tuo abbonamento è terminato';

  @override
  String get teacherExpiredHint =>
      'Non è più possibile aprire sessioni. Il tuo storico resta, e il rinnovo riapre tutto subito.';

  @override
  String get teacherRenew => 'Rinnova l\'abbonamento';

  @override
  String get teacherHistory => 'Sessioni passate';

  @override
  String get teacherHistoryOpen => 'Vedi lo storico';

  @override
  String get teacherHistoryEmpty => 'Nessuna sessione conclusa per ora.';

  @override
  String teacherHistorySuccess(num percent) {
    return '$percent % di risposte esatte';
  }

  @override
  String get teacherHistoryNamesGone =>
      'I nomi di questa sessione sono stati cancellati (90 giorni).';

  @override
  String get teacherMarksTitle => 'Voti da riportare';

  @override
  String teacherMarksHint(num cards) {
    return 'Su 20, sulle $cards carte della sessione.';
  }

  @override
  String get teacherTeamsLabel => 'Squadre';

  @override
  String teacherTeams(num count) {
    return '$count squadre';
  }

  @override
  String get teacherBoardLanguage => 'Lingua della lavagna';

  @override
  String get teacherOpenSession => 'Apri la sessione';

  @override
  String get teacherOpenBoard => 'Apri la lavagna';

  @override
  String get teacherNextQuestion => 'Domanda successiva';

  @override
  String get teacherRevealAnswer => 'Mostra la risposta';

  @override
  String get teacherEndSession => 'Termina la sessione';

  @override
  String get teacherEndSessionHint =>
      'La sessione si chiude e i nomi degli alunni vengono cancellati. Resta il riepilogo per domanda.';

  @override
  String teacherTooManySessions(num limit) {
    return 'Questa licenza gestisce $limit aula/aule alla volta.';
  }

  @override
  String get teacherLinkSpamHint =>
      'Arriva entro un minuto. Se non c\'è, guarda nella posta indesiderata.';

  @override
  String get teacherTooManyLinks =>
      'Troppi link richiesti. Aspetta un\'ora o controlla l\'invio di e-mail del server.';

  @override
  String get teacherUnreachable => 'Il server non risponde. Riprova tra poco.';

  @override
  String get teacherSessionRunning => 'Sessione in corso';

  @override
  String get classroomBoardCode => 'Codice della classe';

  @override
  String get classroomBoardHowToJoin =>
      'Apri IqraQuest, scegli «Classe» e inserisci questo codice.';

  @override
  String classroomAnsweredCount(num answered, num total) {
    return '$answered / $total hanno risposto';
  }

  @override
  String classroomPupilCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alunni',
      one: '$count alunno',
    );
    return '$_temp0';
  }

  @override
  String classroomSquaresCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caselle',
      one: '$count casella',
    );
    return '$_temp0';
  }

  @override
  String get classroomPodium => 'Podio';

  @override
  String get classroomToReview => 'Da rivedere insieme';

  @override
  String get classroomBoardWaitingFirst => 'La prima domanda sta arrivando';

  @override
  String classroomSuccessRate(num percent) {
    return '$percent% di risposte esatte';
  }

  @override
  String lessonTitle(String theme, String level, num number) {
    return '$theme · $level $number';
  }

  @override
  String lessonCardCount(num count) {
    return '$count carte';
  }

  @override
  String get lesson => 'Lezione';
}
