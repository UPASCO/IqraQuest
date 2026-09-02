// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'IqraQuest';

  @override
  String get appTagline => 'El viaje del conocimiento';

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a IqraQuest';

  @override
  String get onboardingWelcomeSubtitle =>
      'Roba una carta, responde, avanza: lleva tu caballo hasta La Meca.';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get chooseLanguage => 'Elegir idioma';

  @override
  String get play => 'Jugar';

  @override
  String get soloMode => 'Individual';

  @override
  String get familyMode => 'Familia';

  @override
  String get dailyChallenge => 'Reto diario';

  @override
  String get progress => 'Progreso';

  @override
  String get settings => 'Ajustes';

  @override
  String get premium => 'Premium';

  @override
  String get continueGame => 'Continuar partida';

  @override
  String get quickGame => 'Partida rápida';

  @override
  String get classicGame => 'Partida clásica';

  @override
  String get chooseDifficulty => 'Elegir dificultad';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Medio';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get playerName => 'Nombre';

  @override
  String get chooseTeam => 'Elegir equipo';

  @override
  String get ridersTitle => 'Los jinetes';

  @override
  String get storeLoading => 'Conectando con la tienda…';

  @override
  String get storeUnavailableCta => 'Tienda no disponible';

  @override
  String get premiumBenefitBank =>
      'Todo el banco de preguntas, cada una con su fuente';

  @override
  String premiumBenefitUnlimited(int count) {
    return 'Partidas ilimitadas, hasta La Meca (la versión gratuita se detiene tras $count robos)';
  }

  @override
  String get premiumBenefitFamily =>
      'Una sola compra para toda la familia, sin anuncios';

  @override
  String get progressEmpty =>
      'Juega una primera partida: tu progreso aparecerá aquí.';

  @override
  String get addPlayer => 'Añadir jugador';

  @override
  String get startGame => 'Empezar partida';

  @override
  String get yourTurn => 'Tu turno';

  @override
  String get categoryProphets => 'Profetas';

  @override
  String get categorySira => 'Sira';

  @override
  String get categoryQuran => 'Corán';

  @override
  String get categoryFaith => 'Fe';

  @override
  String get categoryVirtues => 'Virtudes';

  @override
  String get category => 'Categoría';

  @override
  String get correctAnswer => '¡Respuesta correcta!';

  @override
  String get incorrectAnswer => 'No exactamente…';

  @override
  String get learnMore => 'Saber más';

  @override
  String get questionDetailsTitle => 'Para saber más';

  @override
  String get theQuestionLabel => 'La pregunta';

  @override
  String get theAnswerLabel => 'La respuesta correcta';

  @override
  String get explanationLabel => 'Explicación';

  @override
  String get sourceLabel => 'Fuente';

  @override
  String get nextPlayer => 'Siguiente jugador';

  @override
  String get rolledSix => '¡Un seis! Otro turno — nueva pregunta.';

  @override
  String get playAgain => 'Jugar de nuevo';

  @override
  String get protectedSquareLabel => 'Casilla protegida';

  @override
  String get freeBankExhaustedMessage =>
      'Se han usado todas las preguntas de la edición gratuita en esta partida.';

  @override
  String get victory => '¡Victoria!';

  @override
  String get gameOver => 'Partida terminada';

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String get gamesPlayed => 'Partidas jugadas';

  @override
  String get winRate => 'Tasa de victorias';

  @override
  String get questionsAnswered => 'Preguntas respondidas';

  @override
  String get streak => 'Racha de días';

  @override
  String get premiumTitle => 'IqraQuest Premium';

  @override
  String get premiumUnlockAll =>
      'Desbloquea todo el banco de preguntas y todas las dificultades';

  @override
  String get premiumOneTime => 'Pago único — sin suscripción';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get purchaseSuccess => '¡Gracias! Premium ya está activo.';

  @override
  String get purchaseError =>
      'No se pudo completar la compra. Inténtalo más tarde.';

  @override
  String get language => 'Idioma';

  @override
  String get reduceMotion => 'Reducir movimiento';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get howToPlay => 'Cómo jugar';

  @override
  String get privacySummary =>
      'IqraQuest funciona íntegramente en tu dispositivo: sin cuenta, sin anuncios, sin rastreo, y nada se envía por Internet.';

  @override
  String defaultPlayerName(num number) {
    return 'Jugador $number';
  }

  @override
  String aiPlayerName(num number) {
    return 'Jinete $number';
  }

  @override
  String opponentWins(String name) {
    return '¡$name gana la carrera!';
  }

  @override
  String get wellRidden => 'Buena cabalgada: cada pregunta aprendida cuenta.';

  @override
  String horseSemantics(String color, num number) {
    return 'Caballo $color $number';
  }

  @override
  String get teamEmerald => 'esmeralda';

  @override
  String get teamSaphir => 'zafiro';

  @override
  String get teamGrenat => 'granate';

  @override
  String get teamSafran => 'azafrán';

  @override
  String premiumCta(String price) {
    return 'Desbloquear todo — $price';
  }

  @override
  String premiumQuestionsIncluded(num count) {
    return '$count preguntas verificadas, cada una con su fuente — y el banco sigue creciendo.';
  }

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get about => 'Acerca de';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get genericError => 'Algo salió mal.';

  @override
  String get parentalGateTitle => 'Una pregunta para los padres';

  @override
  String get parentalGateInstruction => 'Resuelve esto para continuar.';

  @override
  String get placeMecca => 'La Meca';

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
      other: '$count casillas especiales',
      one: '$count casilla especial',
    );
    return '$_temp0';
  }

  @override
  String get drawCard => 'Roba una carta';

  @override
  String get drawnCardTitle => 'Carta robada';

  @override
  String cardWorth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vale $count casillas',
      one: 'Vale $count casilla',
    );
    return '$_temp0';
  }

  @override
  String gaitSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count casillas',
      one: '$count casilla',
    );
    return '$_temp0';
  }

  @override
  String get gaitNameWalk => 'Paso';

  @override
  String get gaitNameTrot => 'Trote';

  @override
  String get gaitNameCanter => 'Medio galope';

  @override
  String get gaitNameGallop => 'Galope';

  @override
  String get gaitNameFullGallop => 'Galope tendido';

  @override
  String get gaitNameCharge => 'Carga';

  @override
  String get chooseFormat => 'Formato de partida';

  @override
  String get gaitAlreadyUsed => 'Ya usado en este ciclo';

  @override
  String gaitSemanticLabel(int steps, String difficulty, int points) {
    return 'Avanzar $steps casillas, pregunta $difficulty, $points puntos de saber';
  }

  @override
  String get selectHorse => 'Elige tu caballo';

  @override
  String get knowledgeStreak => 'Impulso del saber';

  @override
  String get knowledgePointsLabel => 'Puntos de saber';

  @override
  String get shieldEarned => '¡Escudo obtenido! Tu caballo está protegido.';

  @override
  String get grandGallopEarned =>
      '¡Gran Galope desbloqueado! +2 casillas cuando quieras.';

  @override
  String get masteryBadgeEarned => '¡Insignia de maestría obtenida!';

  @override
  String get useGrandGallop => 'Usar el Gran Galope (+2)';

  @override
  String get chooseCircuit => 'Elige tu recorrido';

  @override
  String get circuitOasisRoute => 'La Ruta de los Oasis';

  @override
  String get circuitCaravanTrail => 'La Pista de las Caravanas';

  @override
  String get circuitGreatRide => 'La Gran Cabalgada del Saber';

  @override
  String get circuitOasisRouteDescription =>
      'El recorrido más tranquilo: oasis y pocas sorpresas.';

  @override
  String get circuitCaravanTrailDescription =>
      'Desafíos y relevos por el camino. Más táctico.';

  @override
  String get circuitGreatRideDescription =>
      'El recorrido más animado: desafíos, atajos y duelos.';

  @override
  String get cellOasis => 'Oasis';

  @override
  String get cellKnowledge => 'Conocimiento';

  @override
  String get cellChallenge => 'Desafío';

  @override
  String get cellShortcut => 'Atajo';

  @override
  String get cellDuel => 'Duelo';

  @override
  String get cellWisdom => 'Sabiduría';

  @override
  String get cellRelay => 'Relevo';

  @override
  String get cellOasisDescription =>
      'Tu caballo está a salvo de capturas aquí.';

  @override
  String get cellChallengeOffer =>
      '¿Responder una pregunta más difícil para avanzar 2 casillas más?';

  @override
  String get acceptChallenge => 'Aceptar el desafío';

  @override
  String get declineChallenge => 'Conservar mi movimiento';

  @override
  String get saveFact => 'Guardar este dato';

  @override
  String get journeyQuestion => 'Pregunta del viaje';

  @override
  String get journeyQuestionIntro =>
      'Una última pregunta para validar tu llegada.';

  @override
  String opponentThinking(String name) {
    return '$name está pensando…';
  }

  @override
  String opponentDrew(String name, int count) {
    return '$name saca un $count';
  }

  @override
  String correctAnswerWas(String answer) {
    return 'La respuesta correcta: $answer';
  }

  @override
  String get scoreboardTitle => 'Tablero de la carrera';

  @override
  String scoreboardCorrect(int count) {
    return '$count aciertos';
  }

  @override
  String scoreboardBestStreak(int count) {
    return 'racha de $count';
  }

  @override
  String get playAgainSameRiders => '¡Otra carrera!';

  @override
  String opponentMoved(String name) {
    return '¡$name avanza!';
  }

  @override
  String opponentStayed(String name) {
    return '$name se queda.';
  }

  @override
  String get shareScore => 'Compartir';

  @override
  String shareVictoryText(String name, int points) {
    return '¡$name ganó la carrera IqraQuest con $points ⭐! ¿Te animas?';
  }

  @override
  String shareDailyText(int score, int total) {
    return '¡$score/$total en el reto del día de IqraQuest! ¿Lo superas?';
  }

  @override
  String get dailyChallengeDone => 'Reto del día completado';

  @override
  String dailyChallengeScore(num score, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score aciertos de $total',
      one: '$score acierto de $total',
      zero: 'Ningún acierto de $total',
    );
    return '$_temp0';
  }

  @override
  String get dailyChallengeComeBack => 'Vuelve mañana para un nuevo reto.';

  @override
  String get aiOpponentsLabel => 'Rivales';

  @override
  String get playersLabel => 'Jugadores';

  @override
  String get outcomeMoved => '¡Tu caballo avanza!';

  @override
  String get outcomeStayed => 'Tu caballo se queda. No pierdes nada.';

  @override
  String get outcomeCaptured => '¡Capturas un caballo rival!';

  @override
  String get outcomeExited => '¡Tu caballo sale del establo!';

  @override
  String get outcomeNoLegalMove =>
      'Esta carta no puede mover ningún caballo. ¡Siguiente turno!';

  @override
  String get noExitHint => 'Necesitas un 6 para sacar un caballo del establo.';

  @override
  String get bonusTurnHint => 'Turno extra: ¡el 6 te deja jugar otra vez!';

  @override
  String get celebrateSixTitle => '¡SEIS!';

  @override
  String get celebrateSixBody => 'Volverás a robar después de este turno.';

  @override
  String get celebrateSixExitBody =>
      'Un caballo puede salir, ¡y volverás a jugar!';

  @override
  String get celebrateExitTitle => '¡Salida!';

  @override
  String get celebrateExitBody => 'Un caballo puede salir del establo.';

  @override
  String get celebrateCaptureTitle => '¡Captura!';

  @override
  String get celebrateCaptureBody => 'El caballo rival vuelve a su establo.';

  @override
  String get celebrateCapturedTitle => 'Capturado…';

  @override
  String get celebrateCapturedBody =>
      'Tu caballo vuelve al establo. Saldrá otra vez con un 6.';

  @override
  String get celebrateArrivalTitle => '¡La Meca!';

  @override
  String get celebrateArrivalBody =>
      'Tu caballo ha llegado. ¡Una última pregunta para validarlo!';

  @override
  String get freeLimitTitle => 'Fin de la carrera gratuita';

  @override
  String freeLimitLeader(String name) {
    return 'En cabeza: $name';
  }

  @override
  String freeLimitBody(int count) {
    return 'La versión gratuita se detiene tras $count robos. Con Premium, la carrera llega hasta La Meca.';
  }

  @override
  String get freeLimitCta => 'Desbloquear la carrera ilimitada';

  @override
  String drawsCounter(int count, int max) {
    return 'Robos: $count de $max';
  }

  @override
  String moveChoiceTitle(int count) {
    return '¿Qué haces con este $count?';
  }

  @override
  String get moveChoiceExit => 'Sacar un caballo del establo';

  @override
  String moveChoiceAdvance(int number, int count) {
    return 'Caballo $number: avanzar $count';
  }

  @override
  String get moveHintCapture => '¡captura!';

  @override
  String get moveHintFinish => '¡llegada!';

  @override
  String get moveHintOasis => 'oasis';

  @override
  String opponentExits(String name) {
    return '¡$name saca un caballo!';
  }

  @override
  String opponentNoMove(String name) {
    return '$name no puede mover nada.';
  }

  @override
  String opponentReplays(String name) {
    return '¡$name sacó un 6 y vuelve a jugar!';
  }

  @override
  String opponentCaptured(String name) {
    return '¡$name captura un caballo!';
  }

  @override
  String get outcomeShieldBlocked => 'El escudo protegió al caballo.';

  @override
  String get playerProfile => 'Nivel de las preguntas';

  @override
  String get levelEasy => 'Fácil';

  @override
  String get levelIntermediate => 'Intermedio';

  @override
  String get levelExpert => 'Experto';

  @override
  String get raceRulesUpdatedTitle => 'Las reglas de la carrera han mejorado';

  @override
  String get raceRulesUpdatedBody =>
      'Las reglas han cambiado: ahora robas una carta y su valor da a la vez la distancia y la dificultad. Tu progreso, tus insignias y tus compras se conservan; solo la partida en curso no puede continuar con las nuevas reglas.';

  @override
  String get startNewRace => 'Empezar una nueva carrera';

  @override
  String get rulesTitle => 'Las reglas';

  @override
  String get ruleDrawCardTitle => 'Roba una carta';

  @override
  String get ruleDrawCardBody =>
      'En tu turno, roba una carta. Su valor, de 1 a 6, es cuántas casillas avanzas. La pregunta siempre es de tu nivel —fácil, intermedio o experto—, elegido al principio para todas tus cartas.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Responde para avanzar';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Una respuesta correcta avanza tu caballo exactamente las casillas indicadas en la carta. Una incorrecta lo deja donde está: nunca retrocedes.';

  @override
  String get ruleEscalierTitle => 'La escalera hacia La Meca';

  @override
  String get ruleEscalierBody =>
      'Tras una vuelta completa al tablero, tu caballo sube los cinco escalones de su escalera hacia La Meca. Allí ya nadie puede alcanzarlo.';

  @override
  String get ruleExitTitle => 'Salir del establo';

  @override
  String get ruleExitBody =>
      'Cada jugador tiene cuatro caballos en el establo. Un caballo solo sale con un 6: responde bien y ocupará su casilla de salida; y como el 6 repite turno, arranca enseguida. Si ya tienes un caballo en carrera, eliges: sacar otro o avanzar.';

  @override
  String get ruleSixTitle => 'El 6 repite turno';

  @override
  String get ruleSixBody =>
      'Como con el dado: cuando robas un 6, vuelves a jugar después de tu turno, acertaras o no. Y dos de tus caballos nunca pueden compartir casilla.';

  @override
  String get ruleCaptureTitle => 'Capturar y enviar a casa';

  @override
  String get ruleCaptureBody =>
      'Caer exactamente sobre el caballo de un rival lo devuelve con calma a su establo, salvo que la casilla sea un oasis o ese caballo lleve un escudo del saber. Un caballo que sale del establo siempre captura en su casilla de salida.';

  @override
  String get ruleStreakTitle => 'El impulso del saber';

  @override
  String get ruleStreakBody =>
      'Tres respuestas correctas seguidas dan un escudo, cinco el Gran Galope y diez una insignia de maestría. El Gran Galope se gasta solo, y únicamente cuando sus +2 casillas bastan para llegar a la meta. Las bonificaciones vienen solo del conocimiento.';

  @override
  String get ruleArrivalTitle => 'La llegada';

  @override
  String get ruleArrivalBody =>
      'Llega al final del recorrido —pasarse de la línea está permitido— y responde la Pregunta del viaje para validar tu llegada. Un error nunca te hace retroceder: lo intentas de nuevo en el siguiente turno.';
}
