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
  String get onboardingHowTo => 'Comment on joue';

  @override
  String get onboardingStepDraw => 'Pioche une carte : elle annonce ses galops';

  @override
  String get onboardingStepAnswer => 'Réponds juste : les galops sont à toi';

  @override
  String get onboardingStepRide =>
      'Pose ton cheval et galope jusqu\'à l\'oasis';

  @override
  String get onboardingLanguageHint =>
      'Tu pourras la changer plus tard dans les réglages.';

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
  String noMoveOvershoot(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Carte trop grande : ton cheval est à $count cases de La Mecque, il lui faut exactement $count.',
      one:
          'Carte trop grande : ton cheval est à $count case de La Mecque, il lui faut exactement 1.',
    );
    return '$_temp0';
  }

  @override
  String get hudArrivedHeading => 'Chevaux arrivés';

  @override
  String get hudKnowledgeShort => 'savoir';

  @override
  String get hudStreakShort => 'série';

  @override
  String get hudCardsShort => 'cartes';

  @override
  String get boardMenuTitle => 'Menu de la partie';

  @override
  String get boardMenuOpen => 'Ouvrir le menu de la partie';

  @override
  String get autoPlaySingleMove => 'Déplacement automatique';

  @override
  String get autoPlaySingleMoveHint =>
      'Quand un seul cheval peut jouer la carte, il avance tout seul.';

  @override
  String get testerMode => 'Mode testeur';

  @override
  String testerModeHint(int total) {
    return 'Débloque les $total questions sur cet appareil, sans achat. Ce réglage n\'existe que dans les versions de test.';
  }

  @override
  String testerBankPlayable(int count, int total) {
    return '$count questions jouables sur $total';
  }

  @override
  String get restartRace => 'Recommencer la course';

  @override
  String get restartRaceConfirm =>
      'La course en cours sera perdue. Les mêmes cavaliers repartent de l\'écurie.';

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String get backToHomeHint =>
      'La partie est sauvegardée, tu pourras la reprendre.';

  @override
  String get duoGame => 'Partie en duo';

  @override
  String horsesToMecca(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chevaux à La Mecque',
      one: '$count cheval à La Mecque',
    );
    return '$_temp0';
  }

  @override
  String get formatQuickHint => 'La course la plus courte.';

  @override
  String get formatDuoHint => 'Une course d\'un soir.';

  @override
  String get formatClassicHint =>
      'La partie complète, comme au jeu d\'origine.';

  @override
  String get bonusSquaresOption => 'Cases bonus sur le parcours';

  @override
  String get bonusSquaresOn =>
      '16 cases offrent une chevauchée en plus : +5, +10 ou +20.';

  @override
  String get bonusSquaresOff =>
      'Parcours pur : une carte vaut exactement ses galops.';

  @override
  String get muteSound => 'Couper le son';

  @override
  String get unmuteSound => 'Rétablir le son';

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
  String get ridersTitle => 'Les cavaliers';

  @override
  String get storeLoading => 'Connexion à la boutique…';

  @override
  String get storeUnavailableCta => 'Boutique indisponible';

  @override
  String get premiumBenefitBank =>
      'Toute la banque de questions, chacune avec sa source';

  @override
  String premiumBenefitUnlimited(int count) {
    return 'Des parties illimitées, jusqu\'à La Mecque (la version gratuite s\'arrête après $count pioches)';
  }

  @override
  String get premiumBenefitFamily =>
      'Un seul achat pour toute la famille, sans publicité';

  @override
  String get progressEmpty =>
      'Joue une première partie : tes progrès s\'afficheront ici.';

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
  String get learnMore => 'En savoir plus';

  @override
  String get questionDetailsTitle => 'Pour aller plus loin';

  @override
  String get theQuestionLabel => 'La question';

  @override
  String get theAnswerLabel => 'La bonne réponse';

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
  String get aboutDialogTitle => 'À propos d\'IqraQuest';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String copyrightNotice(String year) {
    return '© $year IqraQuest. Tous droits réservés.';
  }

  @override
  String get originalWorkNotice =>
      'IqraQuest, son concept de jeu, ses règles, ses illustrations, son nom et son contenu sont des œuvres originales protégées par le droit d\'auteur. Toute reproduction, imitation ou adaptation, totale ou partielle, sans autorisation écrite est interdite.';

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
      other: 'Carte à $count galops',
      one: 'Carte à $count galop',
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
  String get knowledgeStreak => 'Série de bonnes réponses';

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
  String get shareScore => 'Partager';

  @override
  String shareVictoryText(String name, int points) {
    return '$name a gagné la course IqraQuest avec $points ⭐ ! À toi de jouer ?';
  }

  @override
  String shareDailyText(int score, int total) {
    return '$score/$total au défi du jour IqraQuest ! Tu fais mieux ?';
  }

  @override
  String get dailyChallengeDone => 'Défi du jour terminé';

  @override
  String dailyChallengeScore(num score, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score bonnes réponses sur $total',
      one: '$score bonne réponse sur $total',
      zero: 'Aucune bonne réponse sur $total',
    );
    return '$_temp0';
  }

  @override
  String get dailyChallengeComeBack => 'Reviens demain pour un nouveau défi.';

  @override
  String get aiOpponentsLabel => 'Adversaires';

  @override
  String get playersLabel => 'Joueurs';

  @override
  String get outcomeMoved => 'Ton cheval avance !';

  @override
  String get outcomeStayed => 'Ton cheval reste sur place. Rien n\'est perdu.';

  @override
  String get outcomeCaptured => 'Tu captures un cheval adverse !';

  @override
  String get outcomeExited => 'Ton cheval sort de l\'écurie !';

  @override
  String get outcomeNoLegalMove =>
      'Cette carte ne peut bouger aucun cheval. Tour suivant !';

  @override
  String get noExitHint => 'Il faut un 6 pour sortir un cheval de l\'écurie.';

  @override
  String get bonusTurnHint => 'Tour bonus : le 6 te fait rejouer !';

  @override
  String get celebrateSixTitle => 'SIX !';

  @override
  String get celebrateSixBody => 'Tu rejoueras après ce tour.';

  @override
  String get celebrateSixExitBody =>
      'Un cheval peut sortir — et tu rejoueras !';

  @override
  String get celebrateExitTitle => 'Sortie !';

  @override
  String get celebrateExitBody => 'Un cheval peut quitter l\'écurie.';

  @override
  String get celebrateCaptureTitle => 'Capture !';

  @override
  String get celebrateCaptureBody => 'Le cheval adverse rentre à son écurie.';

  @override
  String get celebrateCapturedTitle => 'Capturé…';

  @override
  String get celebrateCapturedBody =>
      'Ton cheval rentre à l\'écurie. Il repartira sur un 6.';

  @override
  String get celebrateArrivalTitle => 'La Mecque !';

  @override
  String get celebrateArrivalBody =>
      'Ton cheval est arrivé. Une dernière question pour valider !';

  @override
  String get freeLimitTitle => 'Fin de la course gratuite';

  @override
  String freeLimitLeader(String name) {
    return 'En tête : $name';
  }

  @override
  String freeLimitBody(int count) {
    return 'La version gratuite s\'arrête après $count pioches. Avec Premium, la course va jusqu\'à La Mecque.';
  }

  @override
  String get freeLimitCta => 'Débloquer la course illimitée';

  @override
  String drawsCounter(int count, int max) {
    return 'Pioches : $count sur $max';
  }

  @override
  String moveChoiceTitle(int count) {
    return 'Que fais-tu de ce $count ?';
  }

  @override
  String get moveChoiceExit => 'Sortir un cheval de l\'écurie';

  @override
  String moveChoiceAdvance(int number, int count) {
    return 'Cheval $number : avancer de $count';
  }

  @override
  String moveHintCapture(int value) {
    return 'capture ! +$value';
  }

  @override
  String get moveHintFinish => 'arrivée !';

  @override
  String get moveHintOasis => 'oasis';

  @override
  String opponentExits(String name) {
    return '$name sort un cheval !';
  }

  @override
  String opponentNoMove(String name) {
    return '$name ne peut rien bouger.';
  }

  @override
  String opponentReplays(String name) {
    return '$name a fait un 6 et rejoue !';
  }

  @override
  String opponentCaptured(String name) {
    return '$name capture un cheval !';
  }

  @override
  String get outcomeShieldBlocked => 'Le bouclier a protégé le cheval.';

  @override
  String get playerProfile => 'Niveau des questions';

  @override
  String get levelEasy => 'Facile';

  @override
  String get levelIntermediate => 'Intermédiaire';

  @override
  String get levelExpert => 'Expert';

  @override
  String get levelMixed => 'Mixte';

  @override
  String get levelMixedHint =>
      'Mixte : chaque carte tire son niveau — facile, intermédiaire ou expert.';

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
  String get ruleGoalTitle => 'Gagner la course';

  @override
  String get ruleGoalBody =>
      'Chaque joueur mène quatre chevaux vers La Mecque, au centre du plateau. Avant la partie, la table choisit combien doivent y arriver : un seul pour une course rapide, deux pour une course en duo, les quatre pour la partie classique. Le premier joueur qui y parvient gagne.';

  @override
  String get ruleKnowledgeTitle => 'Les points de savoir';

  @override
  String get ruleKnowledgeBody =>
      'L\'étoile du bandeau compte tes points de savoir : un par bonne réponse, et un de plus sur une case Connaissance. Ils ne font pas avancer ton cheval — ils disent ce que tu as appris, et départagent les joueurs si la partie s\'arrête avant l\'arrivée.';

  @override
  String get ruleSpecialCellsTitle => 'Les cases spéciales';

  @override
  String get ruleSpecialCellsBody =>
      'Le circuit choisi porte des cases qui font quelque chose, les mêmes dans ses quatre quarts : l\'Oasis protège des captures, la Connaissance donne un point de savoir, le Défi propose une question plus dure pour +2 galops, le Raccourci une question dure pour couper devant, et la Sagesse offre un fait à garder. Un Défi ou un Raccourci raté ne coûte que le bonus : ton cheval reste où il est.';

  @override
  String get ruleDrawCardTitle => 'Pioche une carte';

  @override
  String get ruleDrawCardBody =>
      'À ton tour, pioche une carte. Elle se retourne sur son enjeu — « Carte à 5 galops » — puis sa question s\'ouvre, toujours à ton niveau, choisi au départ : facile, intermédiaire, expert ou mixte. Tu sais donc ce que vaut une bonne réponse avant de répondre.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Réponds pour avancer';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Une bonne réponse te fait gagner les galops de la carte : un galop, une case. Choisis alors le cheval qui les prend — touche-le pour voir où il arriverait, puis glisse-le jusqu\'à sa case dorée. Le dépôt vaut validation : rien ne bouge avant, rien ne demande de confirmer après. Une mauvaise réponse laisse tout sur place : tu ne recules jamais.';

  @override
  String get ruleEscalierTitle => 'L\'escalier vers La Mecque';

  @override
  String get ruleEscalierBody =>
      'Après un tour complet du plateau, ton cheval monte les cinq marches de son escalier jusqu\'à La Mecque. Là, personne ne peut plus le rattraper.';

  @override
  String get ruleExitTitle => 'Sortir de l\'écurie';

  @override
  String get ruleExitBody =>
      'Chaque joueur a quatre chevaux, et le premier est déjà sur sa case de départ : tu joues dès la première carte, sans attendre. Les trois autres sortent de l\'écurie sur un 6 — réponds juste et le cheval se place sur la case de départ. Deux de tes chevaux ne peuvent jamais partager une case : un cheval à toi posé sur ta case de départ en bloque la sortie jusqu\'à ce qu\'il avance.';

  @override
  String get ruleSixTitle => 'Le 6 fait rejouer';

  @override
  String get ruleSixBody =>
      'Comme au dé : quand tu pioches un 6, tu rejoues après ton tour, que ta réponse soit bonne ou non.';

  @override
  String get ruleCaptureTitle => 'Capturer et renvoyer';

  @override
  String get ruleCaptureBody =>
      'Arriver exactement sur un cheval adverse le renvoie tranquillement à son écurie — sauf si la case est une oasis ou si ce cheval porte un bouclier du savoir. La capture se paie : ton cheval bondit aussitôt de 20 galops. Un cheval qui sort de l\'écurie capture toujours sur sa case de départ.';

  @override
  String get ruleStreakTitle => 'La série de bonnes réponses';

  @override
  String get ruleStreakBody =>
      'Trois bonnes réponses d\'affilée offrent un bouclier, cinq le Grand Galop et dix un badge de maîtrise. Le Grand Galop se dépense tout seul, et seulement quand ses +2 galops suffisent à franchir l\'arrivée. Les bonus s\'obtiennent uniquement par la connaissance.';

  @override
  String get ruleArrivalTitle => 'L\'arrivée';

  @override
  String get ruleArrivalBody =>
      'La ligne d\'arrivée se gagne au compte exact : à trois cases de La Mecque, il te faut exactement un 3. Un 4, un 5 ou un 6 laisse le cheval où il est, et tu attends la bonne carte. Une fois arrivé, réponds à la Question du voyage pour valider ton arrivée ; une erreur ne te fait jamais reculer, tu réessaies au tour suivant.';

  @override
  String get hapticFeedback => 'Vibrations';

  @override
  String squaresWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gagné $count galops',
      one: 'Gagné $count galop',
    );
    return '$_temp0';
  }

  @override
  String get chooseHorseToMove => 'Choisissez un cheval';

  @override
  String get touchHorseHint => 'Touchez un cheval pour voir où il irait';

  @override
  String get dragHorseToDestination =>
      'Glissez le cheval jusqu\'à sa case dorée';

  @override
  String get bonusLabel => 'BONUS';

  @override
  String bonusPlus(int value) {
    return '+$value galops';
  }

  @override
  String get captureBonusLabel => 'CAPTURE';

  @override
  String captureBonusRide(int value) {
    return 'Capture ! Votre cheval bondit de $value galops.';
  }

  @override
  String bonusRide(int value) {
    return 'Case bonus ! Votre cheval avance encore de $value cases.';
  }

  @override
  String cardWasWorth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cette carte valait $count galops.',
      one: 'Cette carte valait $count galop.',
    );
    return '$_temp0';
  }

  @override
  String get answerToReveal => 'Répondez pour découvrir sa valeur';

  @override
  String opponentPlaces(String name) {
    return '$name choisit un cheval…';
  }

  @override
  String opponentBonus(String name, int value) {
    return '$name décroche un bonus +$value !';
  }

  @override
  String get leaderLabel => 'En tête';

  @override
  String tookTheLead(String name) {
    return '$name passe en tête !';
  }

  @override
  String bonusSquareSemantics(int value) {
    return 'Case bonus +$value';
  }

  @override
  String moveHintBonus(int value) {
    return 'Bonus +$value';
  }

  @override
  String get bonusSquaresTeaser =>
      '16 cases bonus sont cachées sur le plateau : +5, +10 et la rare +20.';

  @override
  String get ridersSubtitle =>
      'Chaque cavalier choisit son niveau ; la carte ne décide que la distance.';

  @override
  String get ruleBonusTitle => 'Les cases bonus';

  @override
  String get ruleBonusBody =>
      'Si la table les garde, seize cases bonus sont réparties sur le plateau à chaque partie, quatre par quart. Un cheval qui s\'arrête exactement dessus repart aussitôt de +5, +10 ou +20 galops — et si ce bond le pose pile sur une autre case bonus, elle part à son tour : les bonus s\'enchaînent. Chaque case ne sert qu\'une fois par tour et reste en jeu pour tous. Sans elles, une carte vaut exactement ses galops.';
}
