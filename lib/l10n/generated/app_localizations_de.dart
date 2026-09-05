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
      'Zieh eine Karte, antworte, reite weiter — und bring dein Pferd nach Mekka.';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get onboardingHowTo => 'So wird gespielt';

  @override
  String get onboardingStepDraw => 'Zieh eine Karte: sie nennt ihren Galopp';

  @override
  String get onboardingStepAnswer => 'Antworte richtig: der Galopp gehört dir';

  @override
  String get onboardingStepRide => 'Setz dein Pferd und reite zur Oase';

  @override
  String get onboardingLanguageHint =>
      'Du kannst sie später in den Einstellungen ändern.';

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
  String noMoveOvershoot(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Karte zu groß: Dein Pferd ist $count Felder von Mekka entfernt und braucht genau $count.',
      one:
          'Karte zu groß: Dein Pferd ist $count Feld von Mekka entfernt und braucht genau 1.',
    );
    return '$_temp0';
  }

  @override
  String get hudArrivedHeading => 'Angekommene Pferde';

  @override
  String get hudKnowledgeShort => 'Wissen';

  @override
  String get hudStreakShort => 'Serie';

  @override
  String get hudCardsShort => 'Karten';

  @override
  String get boardMenuTitle => 'Spielmenü';

  @override
  String get boardMenuOpen => 'Spielmenü öffnen';

  @override
  String get autoPlaySingleMove => 'Automatischer Zug';

  @override
  String get autoPlaySingleMoveHint =>
      'Kann nur ein Pferd die Karte spielen, zieht es von allein.';

  @override
  String get testerMode => 'Testermodus';

  @override
  String testerModeHint(int total) {
    return 'Schaltet alle $total Fragen auf diesem Gerät frei, ohne Kauf. Diese Einstellung gibt es nur in Testversionen.';
  }

  @override
  String testerBankPlayable(int count, int total) {
    return '$count von $total Fragen spielbar';
  }

  @override
  String get restartRace => 'Rennen neu starten';

  @override
  String get restartRaceConfirm =>
      'Das laufende Rennen geht verloren. Dieselben Reiter starten wieder vom Stall.';

  @override
  String get backToHome => 'Zurück zum Start';

  @override
  String get backToHomeHint =>
      'Das Spiel wird gespeichert; du kannst später weitermachen.';

  @override
  String get duoGame => 'Duo-Spiel';

  @override
  String horsesToMecca(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Pferde nach Mekka',
      one: '$count Pferd nach Mekka',
    );
    return '$_temp0';
  }

  @override
  String get formatQuickHint => 'Das kürzeste Rennen.';

  @override
  String get formatDuoHint => 'Ein Rennen für einen Abend.';

  @override
  String get formatClassicHint => 'Das ganze Spiel, wie im Original.';

  @override
  String get bonusSquaresOption => 'Bonusfelder auf der Strecke';

  @override
  String get bonusSquaresOn =>
      '16 Felder schenken einen Extra-Ritt: +5, +10 oder +20.';

  @override
  String get bonusSquaresOff =>
      'Reine Strecke: Eine Karte zählt genau ihre Galoppe.';

  @override
  String get muteSound => 'Ton aus';

  @override
  String get unmuteSound => 'Ton an';

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
  String get ridersTitle => 'Die Reiter';

  @override
  String get storeLoading => 'Verbindung zum Store…';

  @override
  String get storeUnavailableCta => 'Store nicht verfügbar';

  @override
  String get premiumBenefitBank => 'Die ganze Fragensammlung, jede mit Quelle';

  @override
  String premiumBenefitUnlimited(int count) {
    return 'Unbegrenzte Spiele bis nach Mekka (die Gratisversion endet nach $count Zügen)';
  }

  @override
  String get premiumBenefitFamily =>
      'Ein Kauf für die ganze Familie, ohne Werbung';

  @override
  String get progressEmpty =>
      'Spiel eine erste Partie: dein Fortschritt erscheint hier.';

  @override
  String get addPlayer => 'Spieler hinzufügen';

  @override
  String get startGame => 'Spiel starten';

  @override
  String get yourTurn => 'Du bist dran';

  @override
  String get categoryProphets => 'Propheten';

  @override
  String get categorySira => 'Sira';

  @override
  String get categoryQuran => 'Koran';

  @override
  String get categoryFaith => 'Glaube';

  @override
  String get categoryVirtues => 'Tugenden';

  @override
  String get category => 'Kategorie';

  @override
  String get correctAnswer => 'Richtig!';

  @override
  String get incorrectAnswer => 'Nicht ganz…';

  @override
  String get learnMore => 'Mehr erfahren';

  @override
  String get questionDetailsTitle => 'Hinter der Antwort';

  @override
  String get theQuestionLabel => 'Die Frage';

  @override
  String get theAnswerLabel => 'Die richtige Antwort';

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
  String get premiumUnlockAll =>
      'Schalte die gesamte Fragensammlung und jeden Schwierigkeitsgrad frei';

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
  String get soundEffects => 'Soundeffekte';

  @override
  String get howToPlay => 'Spielanleitung';

  @override
  String get privacySummary =>
      'IqraQuest läuft vollständig auf deinem Gerät: kein Konto, keine Werbung, kein Tracking, und nichts wird je ins Internet gesendet.';

  @override
  String defaultPlayerName(num number) {
    return 'Spieler $number';
  }

  @override
  String aiPlayerName(num number) {
    return 'Reiter $number';
  }

  @override
  String opponentWins(String name) {
    return '$name gewinnt das Rennen!';
  }

  @override
  String get wellRidden => 'Ein schöner Ritt — jede gelernte Frage zählt.';

  @override
  String horseSemantics(String color, num number) {
    return '$color Pferd $number';
  }

  @override
  String get teamEmerald => 'Smaragd';

  @override
  String get teamSaphir => 'Saphir';

  @override
  String get teamGrenat => 'Granat';

  @override
  String get teamSafran => 'Safran';

  @override
  String premiumCta(String price) {
    return 'Alles freischalten — $price';
  }

  @override
  String premiumQuestionsIncluded(num count) {
    return '$count geprüfte Fragen, jede mit Quelle — und die Sammlung wächst weiter.';
  }

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get about => 'Über';

  @override
  String get aboutDialogTitle => 'Über IqraQuest';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String copyrightNotice(String year) {
    return '© $year IqraQuest. Alle Rechte vorbehalten.';
  }

  @override
  String get originalWorkNotice =>
      'IqraQuest, sein Spielkonzept, seine Regeln, seine Illustrationen, sein Name und seine Inhalte sind urheberrechtlich geschützte Originalwerke. Jede vollständige oder teilweise Vervielfältigung, Nachahmung oder Bearbeitung ohne schriftliche Genehmigung ist untersagt.';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get genericError => 'Etwas ist schiefgelaufen.';

  @override
  String get parentalGateTitle => 'Eine Frage für Eltern';

  @override
  String get parentalGateInstruction => 'Löse das, um fortzufahren.';

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
      other: '$count Sonderfelder',
      one: '$count Sonderfeld',
    );
    return '$_temp0';
  }

  @override
  String get drawCard => 'Karte ziehen';

  @override
  String get drawnCardTitle => 'Gezogene Karte';

  @override
  String cardWorth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Karte über $count Galopp',
      one: 'Karte über $count Galopp',
    );
    return '$_temp0';
  }

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
  String get gaitNameWalk => 'Schritt';

  @override
  String get gaitNameTrot => 'Trab';

  @override
  String get gaitNameCanter => 'Kanter';

  @override
  String get gaitNameGallop => 'Galopp';

  @override
  String get gaitNameFullGallop => 'Renngalopp';

  @override
  String get gaitNameCharge => 'Attacke';

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
  String get knowledgeStreak => 'Richtige Antworten in Folge';

  @override
  String get knowledgePointsLabel => 'Wissenspunkte';

  @override
  String get shieldEarned => 'Schild verdient! Dein Pferd ist geschützt.';

  @override
  String get grandGallopEarned =>
      'Großer Galopp freigeschaltet! +2 Felder, wann du willst.';

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
      'Die ruhigste Strecke: Oasen, wenig Überraschungen.';

  @override
  String get circuitCaravanTrailDescription =>
      'Herausforderungen und Staffeln unterwegs. Taktischer.';

  @override
  String get circuitGreatRideDescription =>
      'Die lebhafteste Strecke: Herausforderungen, Abkürzungen und Duelle.';

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
  String get cellOasisDescription =>
      'Dein Pferd ist hier vor dem Überholen sicher.';

  @override
  String get cellChallengeOffer =>
      'Eine schwerere Frage für 2 zusätzliche Felder beantworten?';

  @override
  String get acceptChallenge => 'Herausforderung annehmen';

  @override
  String get declineChallenge => 'Zug behalten';

  @override
  String get saveFact => 'Diesen Fakt behalten';

  @override
  String get journeyQuestion => 'Reisefrage';

  @override
  String get journeyQuestionIntro =>
      'Eine letzte Frage, um deine Ankunft zu bestätigen.';

  @override
  String opponentThinking(String name) {
    return '$name überlegt…';
  }

  @override
  String opponentDrew(String name, int count) {
    return '$name zieht eine $count';
  }

  @override
  String correctAnswerWas(String answer) {
    return 'Die richtige Antwort: $answer';
  }

  @override
  String get scoreboardTitle => 'Rennstand';

  @override
  String scoreboardCorrect(int count) {
    return '$count richtig';
  }

  @override
  String scoreboardBestStreak(int count) {
    return 'Serie von $count';
  }

  @override
  String get playAgainSameRiders => 'Noch ein Rennen!';

  @override
  String opponentMoved(String name) {
    return '$name zieht vor!';
  }

  @override
  String opponentStayed(String name) {
    return '$name bleibt stehen.';
  }

  @override
  String get shareScore => 'Teilen';

  @override
  String shareVictoryText(String name, int points) {
    return '$name hat das IqraQuest-Rennen mit $points ⭐ gewonnen! Du auch?';
  }

  @override
  String shareDailyText(int score, int total) {
    return '$score/$total bei der IqraQuest-Tagesaufgabe! Schaffst du mehr?';
  }

  @override
  String get dailyChallengeDone => 'Tagesaufgabe geschafft';

  @override
  String dailyChallengeScore(num score, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score von $total richtig',
    );
    return '$_temp0';
  }

  @override
  String get dailyChallengeComeBack => 'Morgen wartet eine neue Aufgabe.';

  @override
  String get aiOpponentsLabel => 'Gegner';

  @override
  String get playersLabel => 'Spieler';

  @override
  String get outcomeMoved => 'Dein Pferd zieht vor!';

  @override
  String get outcomeStayed => 'Dein Pferd bleibt stehen. Nichts geht verloren.';

  @override
  String get outcomeCaptured => 'Du schlägst ein gegnerisches Pferd!';

  @override
  String get outcomeExited => 'Dein Pferd verlässt den Stall!';

  @override
  String get outcomeNoLegalMove =>
      'Diese Karte kann kein Pferd bewegen. Nächster Zug!';

  @override
  String get noExitHint =>
      'Du brauchst eine 6, um ein Pferd aus dem Stall zu holen.';

  @override
  String get bonusTurnHint => 'Bonuszug: Die 6 lässt dich noch einmal ziehen!';

  @override
  String get celebrateSixTitle => 'SECHS!';

  @override
  String get celebrateSixBody => 'Nach diesem Zug ziehst du noch einmal.';

  @override
  String get celebrateSixExitBody =>
      'Ein Pferd darf raus – und du ziehst noch einmal!';

  @override
  String get celebrateExitTitle => 'Tor auf!';

  @override
  String get celebrateExitBody => 'Ein Pferd darf den Stall verlassen.';

  @override
  String get celebrateCaptureTitle => 'Geschlagen!';

  @override
  String get celebrateCaptureBody =>
      'Das gegnerische Pferd kehrt in seinen Stall zurück.';

  @override
  String get celebrateCapturedTitle => 'Erwischt…';

  @override
  String get celebrateCapturedBody =>
      'Dein Pferd kehrt in den Stall zurück. Mit einer 6 kommt es wieder raus.';

  @override
  String get celebrateArrivalTitle => 'Mekka!';

  @override
  String get celebrateArrivalBody =>
      'Dein Pferd ist angekommen. Eine letzte Frage macht es offiziell!';

  @override
  String get freeLimitTitle => 'Ende des Gratis-Rennens';

  @override
  String freeLimitLeader(String name) {
    return 'In Führung: $name';
  }

  @override
  String freeLimitBody(int count) {
    return 'Die Gratisversion endet nach $count Zügen. Mit Premium geht das Rennen bis nach Mekka.';
  }

  @override
  String get freeLimitCta => 'Unbegrenztes Rennen freischalten';

  @override
  String drawsCounter(int count, int max) {
    return 'Züge: $count von $max';
  }

  @override
  String moveChoiceTitle(int count) {
    return 'Was machst du mit dieser $count?';
  }

  @override
  String get moveChoiceExit => 'Ein Pferd aus dem Stall holen';

  @override
  String moveChoiceAdvance(int number, int count) {
    return 'Pferd $number: $count vorrücken';
  }

  @override
  String moveHintCapture(int value) {
    return 'schlagen! +$value';
  }

  @override
  String get moveHintFinish => 'Ziel!';

  @override
  String get moveHintOasis => 'Oase';

  @override
  String opponentExits(String name) {
    return '$name holt ein Pferd raus!';
  }

  @override
  String opponentNoMove(String name) {
    return '$name kann nichts bewegen.';
  }

  @override
  String opponentReplays(String name) {
    return '$name hat eine 6 gezogen und ist noch einmal dran!';
  }

  @override
  String opponentCaptured(String name) {
    return '$name schlägt ein Pferd!';
  }

  @override
  String get outcomeShieldBlocked => 'Das Schild hat das Pferd geschützt.';

  @override
  String get outcomeShelteredByOasis =>
      'Die Oase schützt dieses Pferd: Niemand muss zurück in den Stall.';

  @override
  String get playerProfile => 'Fragenniveau';

  @override
  String get levelBeginner => 'Erste Schritte';

  @override
  String get levelBeginnerHint =>
      'Erste Schritte: die allerersten Grundlagen, die jeder schon kennt.';

  @override
  String get levelEasy => 'Leicht';

  @override
  String get levelIntermediate => 'Mittel';

  @override
  String get levelExpert => 'Experte';

  @override
  String get levelMixed => 'Gemischt';

  @override
  String get levelMixedHint =>
      'Gemischt: Jede Karte zieht ihr eigenes Niveau – leicht, mittel oder Experte.';

  @override
  String get raceRulesUpdatedTitle => 'Die Rennregeln wurden verbessert';

  @override
  String get raceRulesUpdatedBody =>
      'Die Regeln haben sich geändert: Du ziehst jetzt eine Karte, und ihr Wert gibt zugleich Distanz und Schwierigkeit. Fortschritt, Abzeichen und Käufe bleiben erhalten — nur das laufende Spiel lässt sich mit den neuen Regeln nicht fortsetzen.';

  @override
  String get startNewRace => 'Neues Rennen starten';

  @override
  String get rulesTitle => 'Die Regeln';

  @override
  String get ruleGoalTitle => 'Das Rennen gewinnen';

  @override
  String get ruleGoalBody =>
      'Jeder Spieler führt vier Pferde nach Mekka, in die Mitte des Bretts. Vor dem Spiel wählt der Tisch, wie viele ankommen müssen: eines für ein schnelles Rennen, zwei für ein Duo-Rennen, alle vier für das klassische Spiel. Wer es zuerst schafft, gewinnt.';

  @override
  String get ruleKnowledgeTitle => 'Wissenspunkte';

  @override
  String get ruleKnowledgeBody =>
      'Der Stern in der Leiste zählt deine Wissenspunkte: einen für jede richtige Antwort und einen weiteren auf einem Wissensfeld. Sie bewegen dein Pferd nicht — sie sagen, was du gelernt hast, und entscheiden zwischen den Spielern, wenn das Spiel vor der Ankunft endet.';

  @override
  String get ruleSpecialCellsTitle => 'Die Sonderfelder';

  @override
  String get ruleSpecialCellsBody =>
      'Die gewählte Strecke trägt Felder, die etwas tun, in allen vier Vierteln dieselben: die Oase schützt vor Schlagen, Wissen gibt einen Wissenspunkt, die Herausforderung bietet eine schwerere Frage für +2 Galopps, die Abkürzung eine schwere Frage, um vorzurücken, und Weisheit schenkt eine Erkenntnis. Eine verlorene Herausforderung oder Abkürzung kostet nur den Bonus: dein Pferd bleibt stehen.';

  @override
  String get ruleDrawCardTitle => 'Zieh eine Karte';

  @override
  String get ruleDrawCardBody =>
      'Zieh in deinem Zug eine Karte. Sie dreht sich auf ihren Wert — „Karte über 5 Galopps\" — dann öffnet sich ihre Frage, immer auf deiner Stufe, die du vorher gewählt hast: leicht, mittel, Experte oder gemischt. Du weißt also vorher, was eine richtige Antwort wert ist.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Antworte, um vorzurücken';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Eine richtige Antwort gewinnt die Galopps der Karte: ein Galopp, ein Feld. Wähle dann das Pferd, das sie nimmt — tippe es an, um sein Ziel zu sehen, und zieh es auf sein goldenes Feld. Das Ablegen ist der Zug: davor bewegt sich nichts, danach fragt nichts nach einer Bestätigung. Eine falsche Antwort bewegt nichts: du gehst nie zurück.';

  @override
  String get ruleEscalierTitle => 'Die Treppe nach Mekka';

  @override
  String get ruleEscalierBody =>
      'Nach einer vollen Runde steigt dein Pferd die fünf Stufen seiner Treppe nach Mekka hinauf. Dort kann es niemand mehr einholen.';

  @override
  String get ruleExitTitle => 'Den Stall verlassen';

  @override
  String get ruleExitBody =>
      'Jeder Spieler hat vier Pferde, und das erste steht schon auf seinem Startfeld: du spielst ab der ersten Karte, ohne zu warten. Die anderen drei verlassen den Stall bei einer 6 — antworte richtig, und das Pferd nimmt das Startfeld. Zwei deiner Pferde teilen niemals ein Feld: eines von dir auf deinem Startfeld hält das Tor zu, bis es weiterzieht.';

  @override
  String get ruleSixTitle => 'Die 6 zieht noch einmal';

  @override
  String get ruleSixBody =>
      'Wie beim Würfel: Ziehst du eine 6, kommst du nach deinem Zug noch einmal dran — richtig geantwortet oder nicht.';

  @override
  String get ruleCaptureTitle => 'Schlagen und heimschicken';

  @override
  String get ruleCaptureBody =>
      'Wer genau auf dem Pferd eines Gegners landet, schickt es ruhig in seinen Stall zurück — außer das Feld ist eine Oase oder das Pferd trägt einen Wissensschild. Ein Schlag zahlt sich aus: Dein Pferd springt sofort 20 Galopp vor. Ein Pferd, das den Stall verlässt, schlägt auf seinem Startfeld immer.';

  @override
  String get ruleStreakTitle => 'Die Serie richtiger Antworten';

  @override
  String get ruleStreakBody =>
      'Drei richtige Antworten hintereinander bringen einen Schild, fünf den Großen Galopp und zehn ein Meisterabzeichen. Der Große Galopp wird von selbst eingesetzt, und nur wenn seine +2 Galopps zum Ziel reichen. Boni kommen allein aus Wissen.';

  @override
  String get ruleArrivalTitle => 'Die Ankunft';

  @override
  String get ruleArrivalBody =>
      'Das Ziel wird nur mit der genauen Zahl erreicht: drei Felder vor Mekka brauchst du genau eine 3. Eine 4, 5 oder 6 lässt das Pferd stehen, bis die richtige Karte kommt. Bist du da, beantworte die Frage der Reise, um die Ankunft zu bestätigen; ein Fehler wirft dich nie zurück, du versuchst es im nächsten Zug erneut.';

  @override
  String get hapticFeedback => 'Vibration';

  @override
  String squaresWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Galoppsprünge gewonnen',
      one: '$count Galopp gewonnen',
    );
    return '$_temp0';
  }

  @override
  String get chooseHorseToMove => 'Wähle ein Pferd';

  @override
  String get touchHorseHint => 'Tippe ein Pferd an, um sein Ziel zu sehen';

  @override
  String get dragHorseToDestination => 'Zieh das Pferd auf sein goldenes Feld';

  @override
  String get bonusLabel => 'BONUS';

  @override
  String bonusPlus(int value) {
    return '+$value Galopp';
  }

  @override
  String get captureBonusLabel => 'SCHLAG';

  @override
  String captureBonusRide(int value) {
    return 'Geschlagen! Dein Pferd springt $value Galopp vor.';
  }

  @override
  String bonusRide(int value) {
    return 'Bonusfeld! Dein Pferd reitet $value Felder weiter.';
  }

  @override
  String cardWasWorth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Diese Karte war $count Galoppsprünge wert.',
      one: 'Diese Karte war $count Galopp wert.',
    );
    return '$_temp0';
  }

  @override
  String get bonusMissedNote =>
      'Bonus verpasst: Dein Pferd bleibt, wo es steht.';

  @override
  String get answerToReveal => 'Antworte, um ihren Wert zu sehen';

  @override
  String opponentPlaces(String name) {
    return '$name wählt ein Pferd…';
  }

  @override
  String opponentBonus(String name, int value) {
    return '$name holt einen +$value-Bonus!';
  }

  @override
  String get leaderLabel => 'Vorne';

  @override
  String tookTheLead(String name) {
    return '$name übernimmt die Führung!';
  }

  @override
  String bonusSquareSemantics(int value) {
    return 'Bonusfeld +$value';
  }

  @override
  String moveHintBonus(int value) {
    return 'Bonus +$value';
  }

  @override
  String get bonusSquaresTeaser =>
      '16 Bonusfelder warten auf dem Brett: +5, +10 und das seltene +20.';

  @override
  String get ridersSubtitle =>
      'Jeder Reiter wählt sein Niveau; die Karte bestimmt nur die Distanz.';

  @override
  String get ruleBonusTitle => 'Die Bonusfelder';

  @override
  String get ruleBonusBody =>
      'Behält der Tisch sie, werden je Spiel sechzehn Bonusfelder aufs Brett verteilt, vier pro Viertel. Ein Pferd, das genau darauf hält, reitet sofort +5, +10 oder +20 Galopps weiter — und setzt dieser Ritt es genau auf ein weiteres Bonusfeld, löst auch dieses aus: Boni verketten sich. Jedes Feld zahlt einmal pro Zug und bleibt für alle im Spiel. Ohne sie zählt eine Karte genau ihre Galopps.';

  @override
  String get newGameTitle => 'Neues Spiel';

  @override
  String get setupWhoPlays => 'Wer spielt?';

  @override
  String get soloTileCaption => 'gegen den Computer';

  @override
  String get computerLevelLabel => 'Computerstufe';

  @override
  String get setupRaceLength => 'Spieldauer';

  @override
  String get raceLengthShort => 'Kurzes Spiel';

  @override
  String get raceLengthMedium => 'Mittleres Spiel';

  @override
  String get raceLengthFull => 'Ganzes Spiel';

  @override
  String get setupCourse => 'Strecke';
}
