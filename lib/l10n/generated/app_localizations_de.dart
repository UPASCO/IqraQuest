// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'IqraQuest';

  @override
  String get appTagline => 'Die Reise des Wissens';

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei IqraQuest';

  @override
  String get onboardingWelcomeSubtitle =>
      'Beantworte Fragen, wähle deine Gangart und führe dein Pferd von Mekka nach Medina.';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get chooseLanguage => 'Sprache wählen';

  @override
  String get play => 'Spielen';

  @override
  String get soloMode => 'Solo';

  @override
  String get familyMode => 'Familie';

  @override
  String get dailyChallenge => 'Tagesherausforderung';

  @override
  String get progress => 'Fortschritt';

  @override
  String get settings => 'Einstellungen';

  @override
  String get premium => 'Premium';

  @override
  String get continueGame => 'Spiel fortsetzen';

  @override
  String get quickGame => 'Schnellspiel';

  @override
  String get classicGame => 'Klassisches Spiel';

  @override
  String get chooseDifficulty => 'Schwierigkeit wählen';

  @override
  String get difficultyEasy => 'Leicht';

  @override
  String get difficultyMedium => 'Mittel';

  @override
  String get difficultyHard => 'Schwer';

  @override
  String get playerName => 'Name';

  @override
  String get chooseTeam => 'Team wählen';

  @override
  String get addPlayer => 'Spieler hinzufügen';

  @override
  String get startGame => 'Spiel starten';

  @override
  String get yourTurn => 'Du bist dran';

  @override
  String get category => 'Kategorie';

  @override
  String get correctAnswer => 'Richtig!';

  @override
  String get incorrectAnswer => 'Nicht ganz…';

  @override
  String get explanationLabel => 'Erklärung';

  @override
  String get sourceLabel => 'Quelle';

  @override
  String get nextPlayer => 'Nächster Spieler';

  @override
  String get rolledSix => 'Eine Sechs! Noch eine Runde — neue Frage.';

  @override
  String get playAgain => 'Nochmal spielen';

  @override
  String get protectedSquareLabel => 'Geschütztes Feld';

  @override
  String get freeBankExhaustedMessage =>
      'Alle Fragen der kostenlosen Edition wurden in dieser Partie verwendet.';

  @override
  String get victory => 'Sieg!';

  @override
  String get gameOver => 'Spiel beendet';

  @override
  String get backToHome => 'Zurück zum Start';

  @override
  String get gamesPlayed => 'Gespielte Spiele';

  @override
  String get winRate => 'Siegquote';

  @override
  String get questionsAnswered => 'Beantwortete Fragen';

  @override
  String get streak => 'Tagesserie';

  @override
  String get premiumTitle => 'IqraQuest Premium';

  @override
  String get premiumUnlockAll => 'Schalte alle 500 Fragen und jeden Schwierigkeitsgrad frei';

  @override
  String get premiumOneTime => 'Einmalzahlung — kein Abonnement';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get purchaseSuccess => 'Danke! Premium ist jetzt aktiv.';

  @override
  String get purchaseError =>
      'Kauf konnte nicht abgeschlossen werden. Bitte später erneut versuchen.';

  @override
  String get language => 'Sprache';

  @override
  String get reduceMotion => 'Bewegung reduzieren';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get about => 'Über';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get genericError => 'Etwas ist schiefgelaufen.';

  @override
  String get parentalGateTitle => 'Eine Frage für Eltern';

  @override
  String get parentalGateInstruction => 'Löse das, um fortzufahren.';

  @override
  String get chooseYourGait => 'Wähle deine Gangart';

  @override
  String gaitSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Felder',
      one: '$count Feld',
    );
    return '$_temp0';
  }

  @override
  String get chooseFormat => 'Spielformat';

  @override
  String get gaitAlreadyUsed => 'In diesem Zyklus bereits genutzt';

  @override
  String gaitSemanticLabel(int steps, String difficulty, int points) {
    return '$steps Felder vor, $difficulty Frage, $points Wissenspunkte';
  }

  @override
  String get selectHorse => 'Wähle dein Pferd';

  @override
  String get confirmBoldGait => 'Diese Gangart zieht eine schwerere Frage. Weiter?';

  @override
  String get knowledgeStreak => 'Wissensschwung';

  @override
  String get knowledgePointsLabel => 'Wissenspunkte';

  @override
  String get shieldEarned => 'Schild verdient! Dein Pferd ist geschützt.';

  @override
  String get grandGallopEarned => 'Großer Galopp freigeschaltet! +2 Felder, wann du willst.';

  @override
  String get masteryBadgeEarned => 'Meisterschaftsabzeichen verdient!';

  @override
  String get useGrandGallop => 'Großen Galopp einsetzen (+2)';

  @override
  String get chooseCircuit => 'Wähle deine Strecke';

  @override
  String get circuitOasisRoute => 'Die Oasenstraße';

  @override
  String get circuitCaravanTrail => 'Der Karawanenpfad';

  @override
  String get circuitGreatRide => 'Der Große Ritt des Wissens';

  @override
  String get circuitOasisRouteDescription =>
      'Kurze, sonnige Strecke. Perfekt für ein schnelles Spiel.';

  @override
  String get circuitCaravanTrailDescription => 'Lager und Laternen. Eine strategischere Strecke.';

  @override
  String get circuitGreatRideDescription => 'Vom Tag zum Sternenhimmel. Die große Reise.';

  @override
  String get cellOasis => 'Oase';

  @override
  String get cellKnowledge => 'Wissen';

  @override
  String get cellChallenge => 'Herausforderung';

  @override
  String get cellShortcut => 'Abkürzung';

  @override
  String get cellDuel => 'Duell';

  @override
  String get cellWisdom => 'Weisheit';

  @override
  String get cellRelay => 'Staffel';

  @override
  String get cellOasisDescription => 'Dein Pferd ist hier vor dem Überholen sicher.';

  @override
  String get cellChallengeOffer => 'Eine schwerere Frage für 2 zusätzliche Felder beantworten?';

  @override
  String get acceptChallenge => 'Herausforderung annehmen';

  @override
  String get declineChallenge => 'Zug behalten';

  @override
  String get saveFact => 'Diesen Fakt behalten';

  @override
  String get journeyQuestion => 'Reisefrage';

  @override
  String get journeyQuestionIntro => 'Eine letzte Frage, um deine Ankunft zu bestätigen.';

  @override
  String get outcomeMoved => 'Dein Pferd zieht vor!';

  @override
  String get outcomeStayed => 'Dein Pferd bleibt stehen. Nichts geht verloren.';

  @override
  String get outcomeCaptured => 'Du überholst einen Gegner!';

  @override
  String get outcomeShieldBlocked => 'Das Schild hat das Pferd geschützt.';

  @override
  String get playerProfile => 'Spielerstufe';

  @override
  String get profileChild => 'Kind';

  @override
  String get profileDiscovery => 'Entdeckung';

  @override
  String get profileIntermediate => 'Mittel';

  @override
  String get profileAdvanced => 'Fortgeschritten';

  @override
  String get raceRulesUpdatedTitle => 'Die Rennregeln wurden verbessert';

  @override
  String get raceRulesUpdatedBody =>
      'Der Würfel ist weg: Du wählst jetzt deine Gangart und damit dein Risiko. Fortschritt, Abzeichen und Käufe bleiben erhalten — nur das laufende Spiel kann nicht mit den neuen Regeln fortgesetzt werden.';

  @override
  String get startNewRace => 'Neues Rennen starten';

  @override
  String get rulesTitle => 'Die Regeln';

  @override
  String get ruleChooseGaitTitle => 'Wähle deine Gangart';

  @override
  String get ruleChooseGaitBody =>
      'Du entscheidest, wie weit du ziehst, von 1 bis 6 Feldern. Je weiter, desto schwerer die Frage: 1-2 leicht, 3-4 mittel, 5-6 schwer.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Antworte, um vorzurücken';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Eine richtige Antwort bewegt dein Pferd genau um die gewählte Distanz. Eine falsche Antwort lässt es stehen — du gehst nie zurück.';

  @override
  String get ruleGaitCycleTitle => 'Eine Gangart pro Runde';

  @override
  String get ruleGaitCycleBody =>
      'Jede Gangart kann nur einmal genutzt werden. Sind alle sechs verbraucht, kommen sie alle zurück — plane voraus.';

  @override
  String get ruleCaptureTitle => 'Überholen und heimschicken';

  @override
  String get ruleCaptureBody =>
      'Wer genau auf dem Pferd eines Gegners landet, schickt es ruhig in seinen Stall zurück — außer das Feld ist eine Oase oder das Pferd trägt einen Wissensschild.';

  @override
  String get ruleStreakTitle => 'Der Schwung des Wissens';

  @override
  String get ruleStreakBody =>
      'Drei richtige Antworten in Folge bringen einen Schild, fünf den Großen Galopp (+2 Felder) und zehn ein Meisterabzeichen. Boni gibt es nur durch Wissen.';

  @override
  String get ruleArrivalTitle => 'Die Ankunft';

  @override
  String get ruleArrivalBody =>
      'Erreiche das Ende der Strecke — über die Linie hinaus ist erlaubt — und beantworte dann die Frage der Reise, um deine Ankunft zu bestätigen. Ein Fehler wirft dich nie zurück: Du versuchst es einfach im nächsten Zug erneut.';
}
