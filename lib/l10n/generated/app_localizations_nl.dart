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
  String get backToHome => 'Terug naar start';

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
      'Ontgrendel de volledige vragenbank en elke moeilijkheidsgraad';

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
      other: 'Waard: $count vakjes',
      one: 'Waard: $count vakje',
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
  String get knowledgeStreak => 'Kennismomentum';

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
  String get moveHintCapture => 'slaan!';

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
  String get playerProfile => 'Vragenniveau';

  @override
  String get levelEasy => 'Makkelijk';

  @override
  String get levelIntermediate => 'Gemiddeld';

  @override
  String get levelExpert => 'Expert';

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
  String get ruleDrawCardTitle => 'Trek een kaart';

  @override
  String get ruleDrawCardBody =>
      'Trek bij jouw beurt een kaart: de vraag opent meteen, altijd op jouw niveau – makkelijk, gemiddeld of expert – dat je aan het begin koos. De waarde, 1 tot 6 vakjes, blijft verborgen tot je antwoordt.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Antwoord om vooruit te gaan';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Een goed antwoord levert je de vakjes van de kaart op. Kies dan het paard dat ze neemt: tik erop om te zien waar het uitkomt en sleep het daarheen – loslaten is de zet. Een fout antwoord laat alles staan: je gaat nooit achteruit.';

  @override
  String get ruleEscalierTitle => 'De trap naar Mekka';

  @override
  String get ruleEscalierBody =>
      'Na een volledige ronde beklimt je paard de vijf treden van zijn trap naar Mekka. Daar kan niemand het nog inhalen.';

  @override
  String get ruleExitTitle => 'De stal verlaten';

  @override
  String get ruleExitBody =>
      'Elke speler heeft vier paarden in de stal. Een paard komt alleen naar buiten met een 6: antwoord goed en het neemt zijn startvak in – en omdat een 6 opnieuw speelt, rijdt het meteen door. Heb je al een paard op de baan, dan kies je: nog een naar buiten halen, of rijden.';

  @override
  String get ruleSixTitle => 'Een 6 speelt opnieuw';

  @override
  String get ruleSixBody =>
      'Net als met de dobbelsteen: trek je een 6, dan speel je na je beurt nog een keer, of je antwoord nu goed was of niet. En twee van je eigen paarden delen nooit een vak.';

  @override
  String get ruleCaptureTitle => 'Slaan en naar huis sturen';

  @override
  String get ruleCaptureBody =>
      'Precies op het paard van een tegenstander landen stuurt het rustig terug naar de stal — tenzij het vakje een oase is of dat paard een kennisschild draagt. Een paard dat de stal verlaat, slaat altijd op zijn startvak.';

  @override
  String get ruleStreakTitle => 'De kennisreeks';

  @override
  String get ruleStreakBody =>
      'Drie goede antwoorden op rij geven een schild, vijf de Grote Galop en tien een meesterschapsbadge. De Grote Galop wordt vanzelf ingezet, en alleen als zijn +2 vakjes genoeg zijn om de finish te halen. Bonussen komen alleen uit kennis.';

  @override
  String get ruleArrivalTitle => 'De aankomst';

  @override
  String get ruleArrivalBody =>
      'Bereik het einde van het parcours — voorbij de streep gaan mag — en beantwoord dan de Vraag van de Reis om je aankomst te bevestigen. Een fout zet je nooit terug: je probeert het gewoon opnieuw.';

  @override
  String get hapticFeedback => 'Trillingen';

  @override
  String squaresWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vakjes gewonnen',
      one: '$count vakje gewonnen',
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
    return '+$value vakjes';
  }

  @override
  String bonusRide(int value) {
    return 'Bonusvakje! Je paard rijdt nog $value vakjes door.';
  }

  @override
  String cardWasWorth(int value) {
    return 'Deze kaart was $value vakjes waard.';
  }

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
      'Zestien bonusvakjes worden elk spel over het bord verdeeld, vier per kwart. Een paard dat er precies op stopt rijdt meteen +5, +10 of +20 vakjes door – één keer per beurt, en het vakje blijft voor iedereen in het spel.';
}
