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
      'Kort, zonnig parcours. Perfect voor een snel spel.';

  @override
  String get circuitCaravanTrailDescription =>
      'Kampen en lantaarns. Een strategischer parcours.';

  @override
  String get circuitGreatRideDescription =>
      'Van daglicht tot sterrenhemel. De grote reis.';

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
  String get outcomeMoved => 'Je paard gaat vooruit!';

  @override
  String get outcomeStayed => 'Je paard blijft staan. Er gaat niets verloren.';

  @override
  String get outcomeCaptured => 'Je haalt een tegenstander in!';

  @override
  String get outcomeShieldBlocked => 'Het schild beschermde het paard.';

  @override
  String get playerProfile => 'Spelerniveau';

  @override
  String get profileChild => 'Kind';

  @override
  String get profileDiscovery => 'Ontdekking';

  @override
  String get profileIntermediate => 'Gemiddeld';

  @override
  String get profileAdvanced => 'Gevorderd';

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
      'Trek bij jouw beurt een kaart. De waarde, 1 tot 6, is zowel het aantal vakjes als de moeilijkheid van de vraag: 1 het makkelijkst, 6 het moeilijkst.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Antwoord om vooruit te gaan';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Een goed antwoord verplaatst je paard precies de gekozen afstand. Een fout antwoord laat het staan — je gaat nooit achteruit.';

  @override
  String get ruleEscalierTitle => 'De trap naar Mekka';

  @override
  String get ruleEscalierBody =>
      'Na een volledige ronde beklimt je paard de vijf treden van zijn trap naar Mekka. Daar kan niemand het nog inhalen.';

  @override
  String get ruleCaptureTitle => 'Inhalen en naar huis sturen';

  @override
  String get ruleCaptureBody =>
      'Precies op het paard van een tegenstander landen stuurt het rustig terug naar de stal — tenzij het vakje een oase is of dat paard een kennisschild draagt.';

  @override
  String get ruleStreakTitle => 'De kennisreeks';

  @override
  String get ruleStreakBody =>
      'Drie goede antwoorden op rij leveren een schild op, vijf de Grote Galop (+2 vakjes) en tien een meesterschapsbadge. Bonussen komen alleen uit kennis.';

  @override
  String get ruleArrivalTitle => 'De aankomst';

  @override
  String get ruleArrivalBody =>
      'Bereik het einde van het parcours — voorbij de streep gaan mag — en beantwoord dan de Vraag van de Reis om je aankomst te bevestigen. Een fout zet je nooit terug: je probeert het gewoon opnieuw.';
}
