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
  String get explanationLabel => 'Spiegazione';

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
  String get backToHome => 'Torna alla home';

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
      'Sblocca l\'intero archivio di domande e ogni livello di difficoltà';

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
      other: 'Vale $count caselle',
      one: 'Vale $count casella',
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
  String get knowledgeStreak => 'Slancio del sapere';

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
  String get outcomeMoved => 'Il tuo cavallo avanza!';

  @override
  String get outcomeStayed => 'Il tuo cavallo resta fermo. Non perdi nulla.';

  @override
  String get outcomeCaptured => 'Superi un avversario!';

  @override
  String get outcomeShieldBlocked => 'Lo scudo ha protetto il cavallo.';

  @override
  String get playerProfile => 'Livello giocatore';

  @override
  String get profileChild => 'Bambino';

  @override
  String get profileDiscovery => 'Scoperta';

  @override
  String get profileIntermediate => 'Intermedio';

  @override
  String get profileAdvanced => 'Avanzato';

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
  String get ruleDrawCardTitle => 'Pesca una carta';

  @override
  String get ruleDrawCardBody =>
      'Al tuo turno pesca una carta. Il suo valore, da 1 a 6, è insieme il numero di caselle e la difficoltà della domanda: 1 la più facile, 6 la più difficile.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Rispondi per avanzare';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Una risposta giusta fa avanzare il tuo cavallo esattamente delle caselle indicate sulla carta. Una sbagliata lo lascia dov\'è: non torni mai indietro.';

  @override
  String get ruleEscalierTitle => 'La scala verso La Mecca';

  @override
  String get ruleEscalierBody =>
      'Dopo un giro completo del tabellone, il tuo cavallo sale i cinque gradini della sua scala verso La Mecca. Lì nessuno può più raggiungerlo.';

  @override
  String get ruleCaptureTitle => 'Sorpassa e rimanda a casa';

  @override
  String get ruleCaptureBody =>
      'Arrivare esattamente sul cavallo di un avversario lo rimanda con calma alla sua stalla, a meno che la casella sia un\'oasi o quel cavallo porti uno scudo del sapere.';

  @override
  String get ruleStreakTitle => 'Lo slancio del sapere';

  @override
  String get ruleStreakBody =>
      'Tre risposte giuste di fila danno uno scudo, cinque il Gran Galoppo e dieci un distintivo di maestria. Il Gran Galoppo si spende da solo, e solo quando le sue +2 caselle bastano a tagliare il traguardo. I bonus vengono solo dalla conoscenza.';

  @override
  String get ruleArrivalTitle => 'L\'arrivo';

  @override
  String get ruleArrivalBody =>
      'Raggiungi la fine del percorso — superare la linea è permesso — poi rispondi alla Domanda del viaggio per convalidare il tuo arrivo. Un errore non ti fa mai arretrare: riprovi al turno successivo.';
}
