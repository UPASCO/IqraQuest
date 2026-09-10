// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'IqraQuest';

  @override
  String get appTagline => 'De reis van kennis';

  @override
  String get onboardingWelcomeTitle => 'Welkom bij IqraQuest';

  @override
  String get onboardingWelcomeSubtitle =>
      'Trek een kaart, antwoord, rijd door — en breng je paard naar Mekka.';

  @override
  String get getStarted => 'Beginnen';

  @override
  String get onboardingHowTo => 'Zo speel je';

  @override
  String get onboardingStepDraw => 'Trek een kaart: hij noemt zijn galop';

  @override
  String get onboardingStepAnswer => 'Antwoord goed: de galop is van jou';

  @override
  String get onboardingStepRide => 'Zet je paard neer en rijd naar de oase';

  @override
  String get onboardingLanguageHint =>
      'Je kunt dit later in Instellingen wijzigen.';

  @override
  String get chooseLanguage => 'Kies taal';

  @override
  String get play => 'Spelen';

  @override
  String get soloMode => 'Solo';

  @override
  String get familyMode => 'Familie';

  @override
  String get dailyChallenge => 'Dagelijkse uitdaging';

  @override
  String get progress => 'Voortgang';

  @override
  String get settings => 'Instellingen';

  @override
  String get premium => 'Premium';

  @override
  String get continueGame => 'Spel voortzetten';

  @override
  String get quickGame => 'Snel spel';

  @override
  String get classicGame => 'Klassiek spel';

  @override
  String noMoveOvershoot(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Kaart te groot: je paard staat $count vakjes van Mekka en heeft precies $count nodig.',
      one:
          'Kaart te groot: je paard staat $count vakje van Mekka en heeft precies 1 nodig.',
    );
    return '$_temp0';
  }

  @override
  String get hudArrivedHeading => 'Aangekomen paarden';

  @override
  String get hudKnowledgeShort => 'kennis';

  @override
  String get hudStreakShort => 'reeks';

  @override
  String get hudCardsShort => 'kaarten';

  @override
  String get boardMenuTitle => 'Spelmenu';

  @override
  String get boardMenuOpen => 'Spelmenu openen';

  @override
  String get autoPlaySingleMove => 'Automatische zet';

  @override
  String get autoPlaySingleMoveHint =>
      'Kan maar één paard de kaart spelen, dan rijdt het vanzelf.';

  @override
  String get testerMode => 'Testersmodus';

  @override
  String testerModeHint(int total) {
    return 'Ontgrendelt alle $total vragen op dit apparaat, zonder aankoop. Deze instelling bestaat alleen in testversies.';
  }

  @override
  String testerBankPlayable(int count, int total) {
    return '$count van $total vragen speelbaar';
  }

  @override
  String get restartRace => 'Race opnieuw starten';

  @override
  String get restartRaceConfirm =>
      'De lopende race gaat verloren. Dezelfde ruiters starten opnieuw vanaf de stal.';

  @override
  String get backToHome => 'Terug naar start';

  @override
  String get backToHomeHint => 'Het spel is opgeslagen; je kunt later verder.';

  @override
  String get duoGame => 'Duospel';

  @override
  String horsesToMecca(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paarden naar Mekka',
      one: '$count paard naar Mekka',
    );
    return '$_temp0';
  }

  @override
  String get formatQuickHint => 'De kortste race.';

  @override
  String get formatDuoHint => 'Een race voor één avond.';

  @override
  String get formatClassicHint => 'Het volledige spel, net als het origineel.';

  @override
  String get bonusSquaresOption => 'Bonusvakjes op het parcours';

  @override
  String get bonusSquaresOn => '16 vakjes geven een extra rit: +5, +10 of +20.';

  @override
  String get bonusSquaresOff =>
      'Puur parcours: een kaart is precies zijn galops waard.';

  @override
  String get muteSound => 'Geluid uit';

  @override
  String get unmuteSound => 'Geluid aan';

  @override
  String get chooseDifficulty => 'Kies moeilijkheidsgraad';

  @override
  String get difficultyEasy => 'Makkelijk';

  @override
  String get difficultyMedium => 'Gemiddeld';

  @override
  String get difficultyHard => 'Moeilijk';

  @override
  String get playerName => 'Naam';

  @override
  String get chooseTeam => 'Kies team';

  @override
  String get ridersTitle => 'De ruiters';

  @override
  String get storeLoading => 'Verbinden met de store…';

  @override
  String get storeUnavailableCta => 'Store niet beschikbaar';

  @override
  String get premiumBenefitBank => 'De hele vragenbank, elk met bron';

  @override
  String premiumBenefitUnlimited(int count) {
    return 'Onbeperkt spelen, tot aan Mekka (de gratis versie stopt na $count kaarten)';
  }

  @override
  String get premiumBenefitFamily =>
      'Eén aankoop voor het hele gezin, zonder advertenties';

  @override
  String get progressEmpty =>
      'Speel een eerste spel: je voortgang verschijnt hier.';

  @override
  String get addPlayer => 'Speler toevoegen';

  @override
  String get startGame => 'Spel starten';

  @override
  String get yourTurn => 'Jouw beurt';

  @override
  String get categoryProphets => 'Profeten';

  @override
  String get categorySira => 'Sira';

  @override
  String get categoryQuran => 'Koran';

  @override
  String get categoryFaith => 'Geloof';

  @override
  String get categoryVirtues => 'Deugden';

  @override
  String get category => 'Categorie';

  @override
  String get correctAnswer => 'Goed antwoord!';

  @override
  String get incorrectAnswer => 'Niet helemaal…';

  @override
  String get learnMore => 'Meer weten';

  @override
  String get questionDetailsTitle => 'Achter het antwoord';

  @override
  String get theQuestionLabel => 'De vraag';

  @override
  String get theAnswerLabel => 'Het juiste antwoord';

  @override
  String get explanationLabel => 'Uitleg';

  @override
  String get detailLabel => 'In detail';

  @override
  String get sourceLabel => 'Bron';

  @override
  String get nextPlayer => 'Volgende speler';

  @override
  String get rolledSix => 'Een zes! Nog een beurt — nieuwe vraag.';

  @override
  String get playAgain => 'Opnieuw spelen';

  @override
  String get protectedSquareLabel => 'Beschermd vakje';

  @override
  String get freeBankExhaustedMessage =>
      'Alle vragen van de gratis editie zijn gebruikt in dit spel.';

  @override
  String get victory => 'Overwinning!';

  @override
  String get gameOver => 'Spel afgelopen';

  @override
  String get gamesPlayed => 'Gespeelde spellen';

  @override
  String get winRate => 'Winstpercentage';

  @override
  String get questionsAnswered => 'Beantwoorde vragen';

  @override
  String get streak => 'Dagreeks';

  @override
  String get premiumTitle => 'IqraQuest Premium';

  @override
  String get premiumUnlockAll =>
      'Ontgrendel alle kaarten, alle parcoursen, de opgeslagen spellen en het gemengde niveau';

  @override
  String get premiumOneTime => 'Eenmalige betaling — geen abonnement';

  @override
  String get restorePurchases => 'Aankopen herstellen';

  @override
  String get purchaseSuccess => 'Bedankt! Premium is nu actief.';

  @override
  String get purchaseError =>
      'Aankoop kon niet worden voltooid. Probeer het later opnieuw.';

  @override
  String get language => 'Taal';

  @override
  String get reduceMotion => 'Beweging verminderen';

  @override
  String get soundEffects => 'Geluidseffecten';

  @override
  String get howToPlay => 'Zo speel je';

  @override
  String get privacySummary =>
      'IqraQuest draait volledig op je apparaat: geen account, geen advertenties, geen tracking, en er wordt nooit iets via internet verzonden.';

  @override
  String defaultPlayerName(num number) {
    return 'Speler $number';
  }

  @override
  String aiPlayerName(num number) {
    return 'Ruiter $number';
  }

  @override
  String opponentWins(String name) {
    return '$name wint de race!';
  }

  @override
  String get wellRidden => 'Een mooie rit — elke geleerde vraag telt.';

  @override
  String horseSemantics(String color, num number) {
    return '$color paard $number';
  }

  @override
  String get teamEmerald => 'smaragd';

  @override
  String get teamSaphir => 'saffier';

  @override
  String get teamGrenat => 'granaat';

  @override
  String get teamSafran => 'saffraan';

  @override
  String premiumCta(String price) {
    return 'Alles ontgrendelen — $price';
  }

  @override
  String premiumQuestionsIncluded(num count) {
    return '$count geverifieerde vragen, elk met bron — en de vragenbank blijft groeien.';
  }

  @override
  String get darkMode => 'Donkere modus';

  @override
  String get about => 'Over';

  @override
  String get aboutDialogTitle => 'Over IqraQuest';

  @override
  String versionLabel(String version) {
    return 'Versie $version';
  }

  @override
  String copyrightNotice(String year) {
    return '© $year IqraQuest. Alle rechten voorbehouden.';
  }

  @override
  String get originalWorkNotice =>
      'IqraQuest, het spelconcept, de regels, de illustraties, de naam en de inhoud zijn originele werken die auteursrechtelijk beschermd zijn. Elke gehele of gedeeltelijke reproductie, imitatie of bewerking zonder schriftelijke toestemming is verboden.';

  @override
  String get privacyPolicy => 'Privacybeleid';

  @override
  String get genericError => 'Er ging iets mis.';

  @override
  String get parentalGateTitle => 'Een vraag voor ouders';

  @override
  String get parentalGateInstruction => 'Los dit op om verder te gaan.';

  @override
  String get placeMecca => 'Mekka';

  @override
  String get placeMedina => 'Medina';

  @override
  String get placeAlAqsa => 'Al-Aqsa';

  @override
  String get placeArafat => 'Berg Arafat';

  @override
  String get placeMina => 'Mina';

  @override
  String circuitSpecialSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count speciale vakjes',
      one: '$count speciaal vakje',
    );
    return '$_temp0';
  }

  @override
  String get drawCard => 'Trek een kaart';

  @override
  String get drawnCardTitle => 'Getrokken kaart';

  @override
  String cardWorth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kaart van $count galop',
      one: 'Kaart van $count galop',
    );
    return '$_temp0';
  }

  @override
  String gaitSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vakjes',
      one: '$count vakje',
    );
    return '$_temp0';
  }

  @override
  String get gaitNameWalk => 'Stap';

  @override
  String get gaitNameTrot => 'Draf';

  @override
  String get gaitNameCanter => 'Handgalop';

  @override
  String get gaitNameGallop => 'Galop';

  @override
  String get gaitNameFullGallop => 'Rengalop';

  @override
  String get gaitNameCharge => 'Charge';

  @override
  String get chooseFormat => 'Spelvorm';

  @override
  String get gaitAlreadyUsed => 'Al gebruikt deze cyclus';

  @override
  String gaitSemanticLabel(int steps, String difficulty, int points) {
    return '$steps vakjes vooruit, $difficulty vraag, $points kennispunten';
  }

  @override
  String get selectHorse => 'Kies je paard';

  @override
  String get knowledgeStreak => 'Goede antwoorden op rij';

  @override
  String get knowledgePointsLabel => 'Kennispunten';

  @override
  String get shieldEarned => 'Schild verdiend! Je paard is beschermd.';

  @override
  String get grandGallopEarned =>
      'Grote Galop ontgrendeld! +2 vakjes wanneer je wilt.';

  @override
  String get masteryBadgeEarned => 'Meesterschapsbadge verdiend!';

  @override
  String get useGrandGallop => 'Gebruik de Grote Galop (+2)';

  @override
  String get chooseCircuit => 'Kies je parcours';

  @override
  String get circuitOasisRoute => 'De Oaseroute';

  @override
  String get circuitCaravanTrail => 'Het Karavaanpad';

  @override
  String get circuitGreatRide => 'De Grote Rit van Kennis';

  @override
  String get circuitOasisRouteDescription =>
      'De rustigste route: oases, weinig verrassingen.';

  @override
  String get circuitCaravanTrailDescription =>
      'Uitdagingen en estafettes onderweg. Tactischer.';

  @override
  String get circuitGreatRideDescription =>
      'De levendigste route: uitdagingen, sluiproutes en duels.';

  @override
  String get cellOasis => 'Oase';

  @override
  String get cellKnowledge => 'Kennis';

  @override
  String get cellChallenge => 'Uitdaging';

  @override
  String get cellShortcut => 'Kortere weg';

  @override
  String get cellDuel => 'Duel';

  @override
  String get cellWisdom => 'Wijsheid';

  @override
  String get cellRelay => 'Estafette';

  @override
  String get cellOasisDescription => 'Je paard is hier veilig.';

  @override
  String get cellChallengeOffer =>
      'Een moeilijkere vraag beantwoorden voor 2 extra vakjes?';

  @override
  String get acceptChallenge => 'Neem de uitdaging aan';

  @override
  String get declineChallenge => 'Mijn zet houden';

  @override
  String get saveFact => 'Bewaar dit feit';

  @override
  String get journeyQuestion => 'Reisvraag';

  @override
  String get journeyQuestionIntro =>
      'Nog één vraag om je aankomst te bevestigen.';

  @override
  String opponentThinking(String name) {
    return '$name denkt na…';
  }

  @override
  String opponentDrew(String name, int count) {
    return '$name trekt een $count';
  }

  @override
  String correctAnswerWas(String answer) {
    return 'Het juiste antwoord: $answer';
  }

  @override
  String get scoreboardTitle => 'Racebord';

  @override
  String scoreboardCorrect(int count) {
    return '$count goed';
  }

  @override
  String scoreboardBestStreak(int count) {
    return 'reeks van $count';
  }

  @override
  String get playAgainSameRiders => 'Nog een race!';

  @override
  String opponentMoved(String name) {
    return '$name gaat vooruit!';
  }

  @override
  String opponentStayed(String name) {
    return '$name blijft staan.';
  }

  @override
  String get shareScore => 'Delen';

  @override
  String shareVictoryText(String name, int points) {
    return '$name won de IqraQuest-race met $points ⭐! Jij ook?';
  }

  @override
  String shareDailyText(int score, int total) {
    return '$score/$total bij de IqraQuest-daguitdaging! Doe jij het beter?';
  }

  @override
  String get dailyChallengeDone => 'Daguitdaging voltooid';

  @override
  String dailyChallengeScore(num score, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score goed van de $total',
    );
    return '$_temp0';
  }

  @override
  String get dailyChallengeComeBack => 'Kom morgen terug voor een nieuwe.';

  @override
  String get aiOpponentsLabel => 'Tegenstanders';

  @override
  String get playersLabel => 'Spelers';

  @override
  String get outcomeMoved => 'Je paard gaat vooruit!';

  @override
  String get outcomeStayed => 'Je paard blijft staan. Er gaat niets verloren.';

  @override
  String get outcomeCaptured => 'Je slaat een paard van de tegenstander!';

  @override
  String get outcomeExited => 'Je paard verlaat de stal!';

  @override
  String get outcomeNoLegalMove =>
      'Deze kaart kan geen paard verplaatsen. Volgende beurt!';

  @override
  String get noExitHint =>
      'Je hebt een 6 nodig om een paard uit de stal te halen.';

  @override
  String get bonusTurnHint => 'Bonusbeurt: de 6 laat je nog een keer spelen!';

  @override
  String get celebrateSixTitle => 'ZES!';

  @override
  String get celebrateSixBody => 'Na deze beurt trek je nog een keer.';

  @override
  String get celebrateSixExitBody =>
      'Een paard mag naar buiten – en je speelt nog een keer!';

  @override
  String get celebrateExitTitle => 'Poort open!';

  @override
  String get celebrateExitBody => 'Een paard mag de stal verlaten.';

  @override
  String get celebrateCaptureTitle => 'Geslagen!';

  @override
  String get celebrateCaptureBody =>
      'Het paard van de tegenstander gaat terug naar zijn stal.';

  @override
  String get celebrateCapturedTitle => 'Gepakt…';

  @override
  String get celebrateCapturedBody =>
      'Je paard gaat terug naar de stal. Met een 6 komt het weer naar buiten.';

  @override
  String get celebrateArrivalTitle => 'Mekka!';

  @override
  String get celebrateArrivalBody =>
      'Je paard is aangekomen. Nog één vraag om het officieel te maken!';

  @override
  String get freeLimitTitle => 'Einde van de gratis race';

  @override
  String freeLimitLeader(String name) {
    return 'Aan de leiding: $name';
  }

  @override
  String freeLimitBody(int count) {
    return 'De gratis versie stopt na $count kaarten. Met Premium gaat de race door tot aan Mekka.';
  }

  @override
  String get freeLimitCta => 'Onbeperkte race ontgrendelen';

  @override
  String drawsCounter(int count, int max) {
    return 'Kaarten: $count van $max';
  }

  @override
  String moveChoiceTitle(int count) {
    return 'Wat doe je met deze $count?';
  }

  @override
  String get moveChoiceExit => 'Een paard uit de stal halen';

  @override
  String moveChoiceAdvance(int number, int count) {
    return 'Paard $number: $count vooruit';
  }

  @override
  String moveHintCapture(int value) {
    return 'slaan! +$value';
  }

  @override
  String get moveHintFinish => 'finish!';

  @override
  String get moveHintOasis => 'oase';

  @override
  String opponentExits(String name) {
    return '$name haalt een paard naar buiten!';
  }

  @override
  String opponentNoMove(String name) {
    return '$name kan niets verplaatsen.';
  }

  @override
  String opponentReplays(String name) {
    return '$name trok een 6 en speelt nog een keer!';
  }

  @override
  String opponentCaptured(String name) {
    return '$name slaat een paard!';
  }

  @override
  String get outcomeShieldBlocked => 'Het schild beschermde het paard.';

  @override
  String get outcomeShelteredByOasis =>
      'De Oase beschermt dat paard: niemand gaat naar huis.';

  @override
  String get playerProfile => 'Vragenniveau';

  @override
  String get levelBeginner => 'Eerste stappen';

  @override
  String get levelBeginnerHint =>
      'Eerste stappen: de allereerste basis, die iedereen al kent.';

  @override
  String get levelEasy => 'Makkelijk';

  @override
  String get levelIntermediate => 'Gemiddeld';

  @override
  String get levelExpert => 'Expert';

  @override
  String get levelMixed => 'Gemengd';

  @override
  String get levelMixedHint =>
      'Gemengd: elke kaart trekt zijn eigen niveau, van eerste stappen tot expert.';

  @override
  String get raceRulesUpdatedTitle => 'De racerregels zijn verbeterd';

  @override
  String get raceRulesUpdatedBody =>
      'De regels zijn veranderd: je trekt nu een kaart, en de waarde bepaalt zowel de afstand als de moeilijkheid. Je voortgang, badges en aankopen blijven behouden — alleen het lopende spel kan niet verder met de nieuwe regels.';

  @override
  String get startNewRace => 'Start een nieuwe race';

  @override
  String get rulesTitle => 'De regels';

  @override
  String get ruleGoalTitle => 'De race winnen';

  @override
  String get ruleGoalBody =>
      'Elke speler brengt vier paarden naar Mekka, in het midden van het bord. Voor het spel kiest de tafel hoeveel er moeten aankomen: één voor een snelle race, twee voor een duorace, alle vier voor het klassieke spel. Wie het eerst zover komt, wint.';

  @override
  String get ruleKnowledgeTitle => 'Kennispunten';

  @override
  String get ruleKnowledgeBody =>
      'De ster in de balk telt je kennispunten: één voor elk goed antwoord en één extra op een Kennisvakje. Ze laten je paard niet vooruit — ze zeggen wat je hebt geleerd en scheiden de spelers als het spel stopt voordat iemand aankomt.';

  @override
  String get ruleSpecialCellsTitle => 'De speciale vakjes';

  @override
  String get ruleSpecialCellsBody =>
      'Het gekozen parcours heeft vakjes die iets doen, in elk van zijn vier kwarten dezelfde: de Oase beschermt tegen slaan, Kennis geeft een kennispunt, de Uitdaging biedt een moeilijker vraag voor +2 galops, de Kortere Weg een moeilijke vraag om voor te komen, en Wijsheid geeft een feit om te bewaren. Een mislukte Uitdaging of Kortere Weg kost alleen de bonus: je paard blijft staan.';

  @override
  String get ruleDrawCardTitle => 'Trek een kaart';

  @override
  String get ruleDrawCardBody =>
      'Pak op je beurt een kaart. Ze draait om op haar waarde — \"Kaart van 5 galops\" — en dan opent haar vraag, altijd op jouw niveau, vooraf gekozen: makkelijk, gemiddeld, expert of gemengd. Je weet dus wat een goed antwoord waard is voordat je antwoordt.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Antwoord om vooruit te gaan';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Een goed antwoord wint je de galops van de kaart: één galop, één vakje. Kies dan het paard dat ze neemt — tik het aan om te zien waar het zou landen en sleep het naar zijn gouden vakje. Het neerzetten is de zet: daarvoor beweegt niets, daarna vraagt niets om bevestiging. Een fout antwoord beweegt niets: je gaat nooit achteruit.';

  @override
  String get ruleEscalierTitle => 'De trap naar Mekka';

  @override
  String get ruleEscalierBody =>
      'Na een volledige ronde beklimt je paard de vijf treden van zijn trap naar Mekka. Daar kan niemand het nog inhalen.';

  @override
  String get ruleExitTitle => 'De stal verlaten';

  @override
  String get ruleExitBody =>
      'Elke speler heeft vier paarden, en het eerste staat al op zijn startvakje: je speelt vanaf de eerste kaart, zonder te wachten. De andere drie verlaten de stal met een 6 — antwoord goed en het paard neemt het startvakje. Twee van je paarden delen nooit een vakje: een eigen paard op je startvakje houdt de poort dicht tot het verder rijdt.';

  @override
  String get ruleSixTitle => 'Een 6 speelt opnieuw';

  @override
  String get ruleSixBody =>
      'Net als bij de dobbelsteen: trek je een 6, dan speel je na je beurt nog eens, goed of fout geantwoord.';

  @override
  String get ruleCaptureTitle => 'Slaan en naar huis sturen';

  @override
  String get ruleCaptureBody =>
      'Precies op het paard van een tegenstander landen stuurt het rustig terug naar de stal — tenzij het vakje een oase is of dat paard een kennisschild draagt. Slaan loont: je paard springt meteen 20 galop vooruit. Een paard dat de stal verlaat, slaat altijd op zijn startvak.';

  @override
  String get ruleStreakTitle => 'De reeks goede antwoorden';

  @override
  String get ruleStreakBody =>
      'Drie goede antwoorden op rij geven een schild, vijf de Grote Galop en tien een meesterschapsbadge. De Grote Galop wordt vanzelf ingezet, en alleen als zijn +2 galops genoeg zijn om de finish te halen. Bonussen komen alleen uit kennis.';

  @override
  String get ruleArrivalTitle => 'De aankomst';

  @override
  String get ruleArrivalBody =>
      'De finish haal je met het exacte aantal: drie vakjes voor Mekka heb je precies een 3 nodig. Een 4, 5 of 6 laat het paard staan tot de juiste kaart komt. Eenmaal daar beantwoord je de Vraag van de Reis om de aankomst te bevestigen; een fout zet je nooit terug, je probeert het gewoon opnieuw.';

  @override
  String get hapticFeedback => 'Trillingen';

  @override
  String squaresWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count galopsprongen gewonnen',
      one: '$count galop gewonnen',
    );
    return '$_temp0';
  }

  @override
  String get chooseHorseToMove => 'Kies een paard';

  @override
  String get touchHorseHint => 'Tik op een paard om te zien waar het heen gaat';

  @override
  String get dragHorseToDestination => 'Sleep het paard naar zijn gouden vakje';

  @override
  String get bonusLabel => 'BONUS';

  @override
  String bonusPlus(int value) {
    return '+$value galop';
  }

  @override
  String get captureBonusLabel => 'SLAG';

  @override
  String captureBonusRide(int value) {
    return 'Geslagen! Je paard springt $value galop vooruit.';
  }

  @override
  String bonusRide(int value) {
    return 'Bonusvakje! Je paard rijdt nog $value vakjes door.';
  }

  @override
  String cardWasWorth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deze kaart was $count galopsprongen waard.',
      one: 'Deze kaart was $count galop waard.',
    );
    return '$_temp0';
  }

  @override
  String get bonusMissedNote => 'Bonus gemist: je paard blijft waar het staat.';

  @override
  String get answerToReveal => 'Antwoord om de waarde te onthullen';

  @override
  String opponentPlaces(String name) {
    return '$name kiest een paard…';
  }

  @override
  String opponentBonus(String name, int value) {
    return '$name pakt een +$value bonus!';
  }

  @override
  String get leaderLabel => 'Aan kop';

  @override
  String tookTheLead(String name) {
    return '$name neemt de leiding!';
  }

  @override
  String bonusSquareSemantics(int value) {
    return 'Bonusvakje +$value';
  }

  @override
  String moveHintBonus(int value) {
    return 'Bonus +$value';
  }

  @override
  String get bonusSquaresTeaser =>
      '16 bonusvakjes wachten op het bord: +5, +10 en de zeldzame +20.';

  @override
  String get ridersSubtitle =>
      'Elke ruiter kiest zijn niveau; de kaart bepaalt alleen de afstand.';

  @override
  String get ruleBonusTitle => 'De bonusvakjes';

  @override
  String get ruleBonusBody =>
      'Houdt de tafel ze, dan worden er elk spel zestien bonusvakjes op het bord verdeeld, vier per kwart. Een paard dat er precies op stopt, rijdt meteen +5, +10 of +20 galops door — en zet die rit het precies op een ander bonusvakje, dan gaat dat er ook af: bonussen schakelen door. Elk vakje betaalt één keer per beurt en blijft voor iedereen in het spel. Zonder ze is een kaart precies zijn galops waard.';

  @override
  String get newGameTitle => 'Nieuw spel';

  @override
  String get setupWhoPlays => 'Wie speelt er?';

  @override
  String get computerStrengthLabel => 'Sterkte van de tegenstanders';

  @override
  String get strengthLabelShort => 'Sterkte';

  @override
  String get autoRidersNote => 'Automatische ruiters';

  @override
  String autoRidersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ruiters',
      one: '$count ruiter',
    );
    return '$_temp0';
  }

  @override
  String get questionLevelNote =>
      'Vraagniveau: in de volgende stap, per speler.';

  @override
  String get setupRaceLength => 'Speelduur';

  @override
  String get raceLengthShort => 'Kort spel';

  @override
  String get raceLengthMedium => 'Gemiddeld spel';

  @override
  String get raceLengthFull => 'Volledig spel';

  @override
  String get setupCourse => 'Parcours';

  @override
  String get courseCalm => 'Rustig';

  @override
  String get courseLively => 'Levendig';

  @override
  String get courseIntense => 'Intens';

  @override
  String get courseSquareOasis => 'Oase: je paard is daar veilig';

  @override
  String get courseSquareKnowledge => 'Kennis: +1 kennispunt';

  @override
  String get courseSquareChallenge =>
      'Uitdaging: een extra vraag voor +2 vakjes';

  @override
  String get courseSquareShortcut =>
      'Kortere weg: een moeilijke vraag om vooruit te springen';

  @override
  String get courseSquareWisdom =>
      'Wijsheid: een feit om te ontdekken en te bewaren';

  @override
  String get levelEasyHint =>
      'Makkelijk: eenvoudige vragen over wat je eerst leert.';

  @override
  String get levelIntermediateHint =>
      'Gemiddeld: voor wie de verhalen en regels al goed kent.';

  @override
  String get levelExpertHint =>
      'Expert: de preciezste vragen, met verzen en hadiths.';

  @override
  String get saveGame => 'Spel opslaan';

  @override
  String get saveGameHint => 'Geef het een naam om het later terug te vinden';

  @override
  String get saveGameNameLabel => 'Naam van het spel';

  @override
  String get saveAction => 'Opslaan';

  @override
  String gameSavedAs(String name) {
    return 'Spel opgeslagen: $name';
  }

  @override
  String get loadGame => 'Spel laden';

  @override
  String get loadGameAction => 'Laden';

  @override
  String get noSavedGames => 'Nog geen opgeslagen spellen.';

  @override
  String get noSavedGamesHint =>
      'Open tijdens een spel het ≡-menu van het bord en kies ‘Spel opslaan’.';

  @override
  String get deleteSave => 'Dit opgeslagen spel verwijderen';

  @override
  String deleteSaveConfirm(String name) {
    return '‘$name’ verwijderen? Dit opgeslagen spel gaat verloren.';
  }

  @override
  String get deleteAction => 'Verwijderen';

  @override
  String get loadGameFailed => 'Dit opgeslagen spel kan niet worden geopend.';

  @override
  String get gameInProgressTitle => 'Er is een spel bezig';

  @override
  String get gameInProgressReplaceBody =>
      'Het wordt vervangen. Eerst onder een naam bewaren?';

  @override
  String get replaceWithoutSaving => 'Vervangen zonder te bewaren';

  @override
  String get keepUnderName => 'Onder een naam bewaren…';

  @override
  String savesFull(num count) {
    return 'Je hebt al $count opgeslagen spellen: verwijder er een of gebruik een bestaande naam.';
  }

  @override
  String get defaultSaveName => 'Mijn spel';

  @override
  String get premiumOnly => 'Alleen Premium';

  @override
  String premiumBenefitCourses(String lively, String intense) {
    return 'De parcoursen $lively en $intense, met al hun speciale vakjes';
  }

  @override
  String get premiumBenefitSaves =>
      'Meerdere spellen onder een naam bewaren en hervatten';

  @override
  String premiumBenefitMixed(String mixed) {
    return 'Het niveau $mixed: elke kaart trekt zijn eigen niveau';
  }

  @override
  String get premiumBannerTitle => 'Word Premium';

  @override
  String get premiumBannerBody =>
      'Alle kaarten, alle parcoursen, de opgeslagen spellen';

  @override
  String get premiumActive => 'Premium actief: alles is ontgrendeld';

  @override
  String get laterAction => 'Later';

  @override
  String freeLimitPopupBody(int count) {
    return 'Je hebt de $count kaarten van de gratis versie gespeeld. Met Premium gaat de race door tot Mekka, met alle kaarten, alle parcoursen en de opgeslagen spellen.';
  }

  @override
  String get classroomJoin => 'Deelnemen aan een klas';

  @override
  String get classroomCodeLabel => 'Sessiecode';

  @override
  String get classroomNicknameLabel => 'Je voornaam';

  @override
  String get classroomPrivacyNote =>
      'Geen account. Je voornaam en je antwoorden worden gewist als de sessie eindigt.';

  @override
  String get classroomWaiting => 'De les begint zo';

  @override
  String get classroomWaitingHint => 'Je leraar opent de eerste vraag.';

  @override
  String classroomTeamOf(String colour) {
    return 'Team $colour';
  }

  @override
  String classroomQuestionOf(num current, num total) {
    return 'Vraag $current van $total';
  }

  @override
  String get classroomAnswerSent => 'Antwoord verstuurd';

  @override
  String get classroomAnswerSentHint =>
      'Kijk naar het bord: het antwoord komt eraan.';

  @override
  String get classroomAnswerMissed => 'Je hebt niet op tijd geantwoord';

  @override
  String get classroomSessionOver => 'De sessie is voorbij';

  @override
  String classroomYourScore(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Je liet je paard $count vakjes opschuiven',
      one: 'Je liet je paard één vakje opschuiven',
    );
    return '$_temp0';
  }

  @override
  String get classroomLeave => 'De klas verlaten';

  @override
  String get classroomUnknownCode => 'Geen open sessie met die code.';

  @override
  String get classroomSessionFull => 'Deze sessie zit vol.';

  @override
  String get classroomTooLate => 'Te laat: de tijd was om.';

  @override
  String get classroomUnreachable =>
      'De klas is niet bereikbaar. Controleer de verbinding.';

  @override
  String get classroomReconnecting => 'Opnieuw verbinden…';

  @override
  String get teacherConsole => 'Docentenconsole';

  @override
  String get teacherSignInHint =>
      'Voer het adres in waarmee de licentie is betaald: daar wacht een aanmeldlink. Geen wachtwoord.';

  @override
  String get teacherEmailLabel => 'E-mailadres';

  @override
  String get teacherSendLink => 'Stuur mij de link';

  @override
  String teacherLinkSent(String email) {
    return 'Link verzonden naar $email. Open hem op dit apparaat.';
  }

  @override
  String get teacherInvalidEmail => 'Dat lijkt geen e-mailadres.';

  @override
  String get teacherNoLicence => 'Er is geen licentie aan dit adres gekoppeld.';

  @override
  String get teacherNoLicenceHint =>
      'De licentie hangt aan het adres waarmee is betaald. Is er met een ander adres gekocht, meld je dan af en gebruik dat adres.';

  @override
  String get teacherGetLicence => 'Licentie aanschaffen';

  @override
  String get teacherLicencePaidElsewhere =>
      'De betaling verloopt via de beveiligde pagina van Stripe; kom daarna hier terug.';

  @override
  String get teacherRefresh => 'Opnieuw controleren';

  @override
  String get teacherSignOut => 'Afmelden';

  @override
  String teacherLicenceUntil(String date) {
    return 'Licentie geldig tot $date';
  }

  @override
  String get teacherLicenceExpired => 'Licentie verlopen';

  @override
  String get levelLabel => 'Niveau';

  @override
  String get teacherChooseLesson => 'Kies de les';

  @override
  String get teacherScoringMode => 'Hoe punten tellen';

  @override
  String get teacherScoringTeams => 'Per team';

  @override
  String get teacherScoringIndividual => 'Individueel klassement';

  @override
  String get teacherScoringIndividualHint =>
      'Elke voornaam komt geklasseerd op het bord. Een klassement toont de eerste, maar ook de laatste, voor de hele klas.';

  @override
  String get teacherTimer => 'Timer';

  @override
  String get teacherTimerNone => 'Geen — ik onthul zelf';

  @override
  String teacherTimerSeconds(num seconds) {
    return '$seconds seconden';
  }

  @override
  String get teacherLength => 'Lengte';

  @override
  String teacherLengthAll(num count) {
    return 'Hele les ($count kaarten)';
  }

  @override
  String teacherLengthShort(num count) {
    return 'De eerste $count kaarten';
  }

  @override
  String get teacherShuffle => 'Kaartvolgorde schudden';

  @override
  String get teacherShuffleHint =>
      'Een klas die dezelfde les opnieuw speelt, antwoordt niet meer uit het hoofd.';

  @override
  String get classroomScanToJoin => 'Scan het, of typ de code';

  @override
  String get classroomRanking => 'Klassement';

  @override
  String classroomPointsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ptn',
      one: '$count ptn',
    );
    return '$_temp0';
  }

  @override
  String get teacherAccount => 'Je abonnement';

  @override
  String teacherAccountRooms(num used, num total) {
    return '$used van $total zalen open';
  }

  @override
  String teacherAccountDaysLeft(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nog $count dagen',
      one: 'Nog $count dag',
    );
    return '$_temp0';
  }

  @override
  String get teacherAccountEndingSoon => 'Je abonnement loopt binnenkort af.';

  @override
  String get teacherAccountRenews => 'Het wordt automatisch verlengd.';

  @override
  String get teacherExpired => 'Je abonnement is afgelopen';

  @override
  String get teacherExpiredHint =>
      'Er kan geen sessie meer worden geopend. Je geschiedenis blijft bestaan en verlengen opent alles meteen weer.';

  @override
  String get teacherRenew => 'Abonnement verlengen';

  @override
  String get teacherHistory => 'Eerdere sessies';

  @override
  String get teacherHistoryOpen => 'Bekijk de geschiedenis';

  @override
  String get teacherHistoryEmpty => 'Nog geen afgeronde sessie.';

  @override
  String teacherHistorySuccess(num percent) {
    return '$percent % goed';
  }

  @override
  String get teacherHistoryNamesGone =>
      'De namen van deze sessie zijn gewist (90 dagen).';

  @override
  String get teacherMarksTitle => 'Cijfers om over te nemen';

  @override
  String teacherMarksHint(num cards) {
    return 'Op 20, over de $cards kaarten van de sessie.';
  }

  @override
  String get teacherTeamsLabel => 'Teams';

  @override
  String teacherTeams(num count) {
    return '$count teams';
  }

  @override
  String get teacherBoardLanguage => 'Taal van het bord';

  @override
  String get teacherOpenSession => 'Sessie openen';

  @override
  String get teacherOpenBoard => 'Bord openen';

  @override
  String get teacherNextQuestion => 'Volgende vraag';

  @override
  String get teacherRevealAnswer => 'Toon het antwoord';

  @override
  String get teacherEndSession => 'Sessie beëindigen';

  @override
  String get teacherEndSessionHint =>
      'De sessie sluit en de namen van de leerlingen worden gewist. De samenvatting per vraag blijft bewaard.';

  @override
  String teacherTooManySessions(num limit) {
    return 'Deze licentie draait $limit lokaal/lokalen tegelijk.';
  }

  @override
  String get teacherLinkSpamHint =>
      'Hij komt binnen een minuut aan. Zo niet, kijk in je spammap.';

  @override
  String get teacherTooManyLinks =>
      'Te veel links aangevraagd. Wacht een uur of controleer de e-mailverzending van de server.';

  @override
  String get teacherUnreachable =>
      'De server antwoordt niet. Probeer het zo meteen opnieuw.';

  @override
  String get teacherSessionRunning => 'Sessie loopt';

  @override
  String get classroomBoardCode => 'Klascode';

  @override
  String get classroomBoardHowToJoin =>
      'Open IqraQuest, kies «Klas» en voer deze code in.';

  @override
  String classroomAnsweredCount(num answered, num total) {
    return '$answered / $total hebben geantwoord';
  }

  @override
  String classroomPupilCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count leerlingen',
      one: '$count leerling',
    );
    return '$_temp0';
  }

  @override
  String classroomSquaresCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vakjes',
      one: '$count vakje',
    );
    return '$_temp0';
  }

  @override
  String get classroomPodium => 'Podium';

  @override
  String get classroomToReview => 'Samen nog eens bekijken';

  @override
  String get classroomBoardWaitingFirst => 'De eerste vraag komt eraan';

  @override
  String classroomSuccessRate(num percent) {
    return '$percent% goed beantwoord';
  }

  @override
  String lessonTitle(String theme, String level, num number) {
    return '$theme · $level $number';
  }

  @override
  String lessonCardCount(num count) {
    return '$count kaarten';
  }

  @override
  String get lesson => 'Les';
}
