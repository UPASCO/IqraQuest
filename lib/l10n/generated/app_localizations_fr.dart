// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'IqraQuest';

  @override
  String get appTagline => 'Le voyage de la connaissance';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue sur IqraQuest';

  @override
  String get onboardingWelcomeSubtitle =>
      'Pioche une carte, réponds, avance — et ramène ton cheval jusqu\'à La Mecque.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get chooseLanguage => 'Choisir la langue';

  @override
  String get play => 'Jouer';

  @override
  String get soloMode => 'Solo';

  @override
  String get familyMode => 'Famille';

  @override
  String get dailyChallenge => 'Défi du jour';

  @override
  String get progress => 'Progression';

  @override
  String get settings => 'Réglages';

  @override
  String get premium => 'Premium';

  @override
  String get continueGame => 'Continuer la partie';

  @override
  String get quickGame => 'Partie rapide';

  @override
  String get classicGame => 'Partie classique';

  @override
  String get chooseDifficulty => 'Choisir la difficulté';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Moyen';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get playerName => 'Prénom';

  @override
  String get chooseTeam => 'Choisir l\'équipe';

  @override
  String get addPlayer => 'Ajouter un joueur';

  @override
  String get startGame => 'Démarrer la partie';

  @override
  String get yourTurn => 'À toi de jouer';

  @override
  String get categoryProphets => 'Prophètes';

  @override
  String get categorySira => 'Sîra';

  @override
  String get categoryQuran => 'Coran';

  @override
  String get categoryFaith => 'Foi';

  @override
  String get categoryVirtues => 'Vertus';

  @override
  String get category => 'Catégorie';

  @override
  String get correctAnswer => 'Bonne réponse !';

  @override
  String get incorrectAnswer => 'Pas tout à fait…';

  @override
  String get explanationLabel => 'Explication';

  @override
  String get sourceLabel => 'Source';

  @override
  String get nextPlayer => 'Joueur suivant';

  @override
  String get rolledSix => 'Un 6 ! Nouveau tour — nouvelle question.';

  @override
  String get playAgain => 'Rejouer';

  @override
  String get protectedSquareLabel => 'Case protégée';

  @override
  String get freeBankExhaustedMessage =>
      'Toutes les questions de l\'édition gratuite ont été utilisées pour cette partie.';

  @override
  String get victory => 'Victoire !';

  @override
  String get gameOver => 'Partie terminée';

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String get gamesPlayed => 'Parties jouées';

  @override
  String get winRate => 'Taux de victoire';

  @override
  String get questionsAnswered => 'Questions répondues';

  @override
  String get streak => 'Série de jours';

  @override
  String get premiumTitle => 'IqraQuest Premium';

  @override
  String get premiumUnlockAll =>
      'Débloque toute la banque de questions et toutes les difficultés';

  @override
  String get premiumOneTime => 'Paiement unique — aucun abonnement';

  @override
  String get restorePurchases => 'Restaurer mes achats';

  @override
  String get purchaseSuccess => 'Merci ! Premium est activé.';

  @override
  String get purchaseError =>
      'Achat impossible pour le moment. Réessaie plus tard.';

  @override
  String get language => 'Langue';

  @override
  String get reduceMotion => 'Réduire les animations';

  @override
  String get soundEffects => 'Effets sonores';

  @override
  String get howToPlay => 'Comment jouer';

  @override
  String get privacySummary =>
      'IqraQuest fonctionne entièrement sur votre appareil : aucun compte, aucune publicité, aucun suivi, et rien n\'est envoyé sur Internet.';

  @override
  String defaultPlayerName(num number) {
    return 'Joueur $number';
  }

  @override
  String aiPlayerName(num number) {
    return 'Cavalier $number';
  }

  @override
  String opponentWins(String name) {
    return '$name remporte la course !';
  }

  @override
  String get wellRidden => 'Belle chevauchée — chaque question apprise compte.';

  @override
  String horseSemantics(String color, num number) {
    return 'Cheval $color $number';
  }

  @override
  String get teamEmerald => 'émeraude';

  @override
  String get teamSaphir => 'saphir';

  @override
  String get teamGrenat => 'grenat';

  @override
  String get teamSafran => 'safran';

  @override
  String premiumCta(String price) {
    return 'Tout débloquer — $price';
  }

  @override
  String premiumQuestionsIncluded(num count) {
    return '$count questions vérifiées, chacune avec sa source — et la banque continue de grandir.';
  }

  @override
  String get darkMode => 'Mode nuit';

  @override
  String get about => 'À propos';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get genericError => 'Une erreur est survenue.';

  @override
  String get parentalGateTitle => 'Question pour les parents';

  @override
  String get parentalGateInstruction => 'Résous ce calcul pour continuer.';

  @override
  String get placeMecca => 'La Mecque';

  @override
  String get placeMedina => 'Médine';

  @override
  String get placeAlAqsa => 'Al-Aqsa';

  @override
  String get placeArafat => 'Mont Arafat';

  @override
  String get placeMina => 'Mina';

  @override
  String circuitSpecialSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cases spéciales',
      one: '$count case spéciale',
    );
    return '$_temp0';
  }

  @override
  String get drawCard => 'Piocher une carte';

  @override
  String get drawnCardTitle => 'Carte piochée';

  @override
  String cardWorth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vaut $count cases',
      one: 'Vaut $count case',
    );
    return '$_temp0';
  }

  @override
  String gaitSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cases',
      one: '$count case',
    );
    return '$_temp0';
  }

  @override
  String get gaitNameWalk => 'Pas';

  @override
  String get gaitNameTrot => 'Trot';

  @override
  String get gaitNameCanter => 'Petit galop';

  @override
  String get gaitNameGallop => 'Galop';

  @override
  String get gaitNameFullGallop => 'Ventre à terre';

  @override
  String get gaitNameCharge => 'Charge';

  @override
  String get chooseFormat => 'Format de partie';

  @override
  String get gaitAlreadyUsed => 'Déjà utilisée ce cycle';

  @override
  String gaitSemanticLabel(int steps, String difficulty, int points) {
    return 'Avancer de $steps cases, question $difficulty, $points points de savoir';
  }

  @override
  String get selectHorse => 'Choisis ton cheval';

  @override
  String get knowledgeStreak => 'Élan du savoir';

  @override
  String get knowledgePointsLabel => 'Points de savoir';

  @override
  String get shieldEarned => 'Bouclier obtenu ! Ton cheval est protégé.';

  @override
  String get grandGallopEarned =>
      'Grand Galop débloqué ! +2 cases quand tu veux.';

  @override
  String get masteryBadgeEarned => 'Badge de maîtrise obtenu !';

  @override
  String get useGrandGallop => 'Utiliser le Grand Galop (+2)';

  @override
  String get chooseCircuit => 'Choisis ton circuit';

  @override
  String get circuitOasisRoute => 'La Route des Oasis';

  @override
  String get circuitCaravanTrail => 'La Piste des Caravanes';

  @override
  String get circuitGreatRide => 'La Grande Chevauchée du Savoir';

  @override
  String get circuitOasisRouteDescription =>
      'Le parcours le plus calme : des oasis, peu d\'imprévus.';

  @override
  String get circuitCaravanTrailDescription =>
      'Des défis et des relais en chemin. Plus tactique.';

  @override
  String get circuitGreatRideDescription =>
      'Le parcours le plus animé : défis, raccourcis et duels.';

  @override
  String get cellOasis => 'Oasis';

  @override
  String get cellKnowledge => 'Connaissance';

  @override
  String get cellChallenge => 'Défi';

  @override
  String get cellShortcut => 'Raccourci';

  @override
  String get cellDuel => 'Duel';

  @override
  String get cellWisdom => 'Sagesse';

  @override
  String get cellRelay => 'Relais';

  @override
  String get cellOasisDescription => 'Ton cheval y est protégé des captures.';

  @override
  String get cellChallengeOffer =>
      'Répondre à une question plus difficile pour avancer de 2 cases de plus ?';

  @override
  String get acceptChallenge => 'Relever le défi';

  @override
  String get declineChallenge => 'Garder mon déplacement';

  @override
  String get saveFact => 'Garder cette connaissance';

  @override
  String get journeyQuestion => 'Question du voyage';

  @override
  String get journeyQuestionIntro =>
      'Une dernière question pour valider ton arrivée.';

  @override
  String opponentThinking(String name) {
    return '$name réfléchit…';
  }

  @override
  String opponentDrew(String name, int count) {
    return '$name pioche un $count';
  }

  @override
  String correctAnswerWas(String answer) {
    return 'La bonne réponse : $answer';
  }

  @override
  String get scoreboardTitle => 'Tableau de la course';

  @override
  String scoreboardCorrect(int count) {
    return '$count bonnes réponses';
  }

  @override
  String scoreboardBestStreak(int count) {
    return 'série de $count';
  }

  @override
  String get playAgainSameRiders => 'Encore une course !';

  @override
  String opponentMoved(String name) {
    return '$name avance !';
  }

  @override
  String opponentStayed(String name) {
    return '$name reste sur place.';
  }

  @override
  String get outcomeMoved => 'Ton cheval avance !';

  @override
  String get outcomeStayed => 'Ton cheval reste sur place. Rien n\'est perdu.';

  @override
  String get outcomeCaptured => 'Tu dépasses un adversaire !';

  @override
  String get outcomeShieldBlocked => 'Le bouclier a protégé le cheval.';

  @override
  String get playerProfile => 'Niveau du joueur';

  @override
  String get profileChild => 'Enfant';

  @override
  String get profileDiscovery => 'Découverte';

  @override
  String get profileIntermediate => 'Intermédiaire';

  @override
  String get profileAdvanced => 'Avancé';

  @override
  String get raceRulesUpdatedTitle => 'Les règles de course ont été améliorées';

  @override
  String get raceRulesUpdatedBody =>
      'Les règles ont changé : on pioche maintenant une carte, et sa valeur donne à la fois la distance et la difficulté. Ta progression, tes badges et tes achats sont conservés — seule la partie en cours ne peut pas reprendre avec les nouvelles règles.';

  @override
  String get startNewRace => 'Commencer une nouvelle course';

  @override
  String get rulesTitle => 'Les règles';

  @override
  String get ruleDrawCardTitle => 'Pioche une carte';

  @override
  String get ruleDrawCardBody =>
      'À ton tour, pioche une carte. Sa valeur, de 1 à 6, est à la fois le nombre de cases et la difficulté de la question : 1 la plus facile, 6 la plus dure.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Réponds pour avancer';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Une bonne réponse fait avancer ton cheval exactement du nombre de cases inscrit sur la carte. Une mauvaise réponse le laisse sur place : tu ne recules jamais.';

  @override
  String get ruleEscalierTitle => 'L\'escalier vers La Mecque';

  @override
  String get ruleEscalierBody =>
      'Après un tour complet du plateau, ton cheval monte les cinq marches de son escalier jusqu\'à La Mecque. Là, personne ne peut plus le rattraper.';

  @override
  String get ruleCaptureTitle => 'Dépasser et renvoyer';

  @override
  String get ruleCaptureBody =>
      'Arriver exactement sur un cheval adverse le renvoie tranquillement à son écurie — sauf si la case est une oasis ou si ce cheval porte un bouclier du savoir.';

  @override
  String get ruleStreakTitle => 'L\'élan du savoir';

  @override
  String get ruleStreakBody =>
      'Trois bonnes réponses d\'affilée offrent un bouclier, cinq le Grand Galop et dix un badge de maîtrise. Le Grand Galop se dépense tout seul, et seulement quand ses +2 cases suffisent à franchir l\'arrivée. Les bonus s\'obtiennent uniquement par la connaissance.';

  @override
  String get ruleArrivalTitle => 'L\'arrivée';

  @override
  String get ruleArrivalBody =>
      'Atteins le bout du parcours — dépasser la ligne est permis — puis réponds à la Question du voyage pour valider ton arrivée. Une erreur ne te fait jamais reculer : tu réessaies au tour suivant.';
}
