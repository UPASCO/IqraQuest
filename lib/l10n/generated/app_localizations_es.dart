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
  String get onboardingHowTo => 'Cómo se juega';

  @override
  String get onboardingStepDraw => 'Roba una carta: anuncia sus galopes';

  @override
  String get onboardingStepAnswer => 'Acierta: los galopes son tuyos';

  @override
  String get onboardingStepRide => 'Coloca tu caballo y galopa hasta el oasis';

  @override
  String get onboardingLanguageHint => 'Podrás cambiarla luego en los ajustes.';

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
  String noMoveOvershoot(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Carta demasiado grande: tu caballo está a $count casillas de La Meca y necesita exactamente $count.',
      one:
          'Carta demasiado grande: tu caballo está a $count casilla de La Meca y necesita exactamente 1.',
    );
    return '$_temp0';
  }

  @override
  String get hudArrivedHeading => 'Caballos llegados';

  @override
  String get hudKnowledgeShort => 'saber';

  @override
  String get hudStreakShort => 'racha';

  @override
  String get hudCardsShort => 'cartas';

  @override
  String get boardMenuTitle => 'Menú de la partida';

  @override
  String get boardMenuOpen => 'Abrir el menú de la partida';

  @override
  String get autoPlaySingleMove => 'Movimiento automático';

  @override
  String get autoPlaySingleMoveHint =>
      'Cuando solo un caballo puede jugar la carta, avanza solo.';

  @override
  String get testerMode => 'Modo de prueba';

  @override
  String testerModeHint(int total) {
    return 'Desbloquea las $total preguntas en este dispositivo, sin compra. Este ajuste solo existe en las versiones de prueba.';
  }

  @override
  String testerBankPlayable(int count, int total) {
    return '$count de $total preguntas jugables';
  }

  @override
  String get restartRace => 'Reiniciar la carrera';

  @override
  String get restartRaceConfirm =>
      'Se perderá la carrera en curso. Los mismos jinetes vuelven a salir del establo.';

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String get backToHomeHint => 'La partida se guarda; podrás retomarla.';

  @override
  String get duoGame => 'Partida en dúo';

  @override
  String horsesToMecca(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caballos a La Meca',
      one: '$count caballo a La Meca',
    );
    return '$_temp0';
  }

  @override
  String get formatQuickHint => 'La carrera más corta.';

  @override
  String get formatDuoHint => 'Una carrera de una tarde.';

  @override
  String get formatClassicHint =>
      'La partida completa, como en el juego original.';

  @override
  String get bonusSquaresOption => 'Casillas de bonificación en el recorrido';

  @override
  String get bonusSquaresOn =>
      '16 casillas dan una cabalgada extra: +5, +10 o +20.';

  @override
  String get bonusSquaresOff =>
      'Recorrido puro: una carta vale exactamente sus galopes.';

  @override
  String get muteSound => 'Silenciar';

  @override
  String get unmuteSound => 'Activar sonido';

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
  String get aboutDialogTitle => 'Acerca de IqraQuest';

  @override
  String versionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String copyrightNotice(String year) {
    return '© $year IqraQuest. Todos los derechos reservados.';
  }

  @override
  String get originalWorkNotice =>
      'IqraQuest, su concepto de juego, sus reglas, sus ilustraciones, su nombre y su contenido son obras originales protegidas por derechos de autor. Queda prohibida toda reproducción, imitación o adaptación, total o parcial, sin autorización escrita.';

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
      other: 'Carta de $count galopes',
      one: 'Carta de $count galope',
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
  String get knowledgeStreak => 'Respuestas correctas seguidas';

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
  String moveHintCapture(int value) {
    return '¡captura! +$value';
  }

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
  String get outcomeShelteredByOasis =>
      'El Oasis protege a ese caballo: nadie vuelve al establo.';

  @override
  String get playerProfile => 'Nivel de las preguntas';

  @override
  String get levelEasy => 'Fácil';

  @override
  String get levelIntermediate => 'Intermedio';

  @override
  String get levelExpert => 'Experto';

  @override
  String get levelMixed => 'Mixto';

  @override
  String get levelMixedHint =>
      'Mixto: cada carta saca su propio nivel: fácil, intermedio o experto.';

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
  String get ruleGoalTitle => 'Ganar la carrera';

  @override
  String get ruleGoalBody =>
      'Cada jugador lleva cuatro caballos hacia La Meca, en el centro del tablero. Antes de la partida, la mesa elige cuántos deben llegar: uno para una carrera rápida, dos para una carrera en dúo, los cuatro para la partida clásica. Gana el primero que lo consigue.';

  @override
  String get ruleKnowledgeTitle => 'Puntos de saber';

  @override
  String get ruleKnowledgeBody =>
      'La estrella de la barra cuenta tus puntos de saber: uno por cada respuesta correcta y uno más en una casilla de Conocimiento. No hacen avanzar a tu caballo — dicen lo que has aprendido y desempatan a los jugadores si la partida termina antes de la llegada.';

  @override
  String get ruleSpecialCellsTitle => 'Las casillas especiales';

  @override
  String get ruleSpecialCellsBody =>
      'El circuito que elegiste tiene casillas que hacen algo, las mismas en sus cuatro cuartos: el Oasis protege de las capturas, Conocimiento da un punto de saber, el Desafío ofrece una pregunta más difícil por +2 galopes, el Atajo una pregunta difícil para adelantarse, y Sabiduría regala un dato para guardar. Fallar un Desafío o un Atajo solo cuesta el bono: tu caballo se queda donde está.';

  @override
  String get ruleDrawCardTitle => 'Roba una carta';

  @override
  String get ruleDrawCardBody =>
      'En tu turno, roba una carta. Se vuelve mostrando su valor — «Carta de 5 galopes» — y luego se abre su pregunta, siempre a tu nivel, elegido al principio: fácil, intermedio, experto o mixto. Así sabes lo que vale una respuesta correcta antes de responder.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Responde para avanzar';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Una respuesta correcta te gana los galopes de la carta: un galope, una casilla. Elige entonces el caballo que los toma — tócalo para ver dónde llegaría y arrástralo a su casilla dorada. Soltarlo es la jugada: nada se mueve antes, nada pide confirmar después. Una respuesta incorrecta no mueve nada: nunca retrocedes.';

  @override
  String get ruleEscalierTitle => 'La escalera hacia La Meca';

  @override
  String get ruleEscalierBody =>
      'Tras una vuelta completa al tablero, tu caballo sube los cinco escalones de su escalera hacia La Meca. Allí ya nadie puede alcanzarlo.';

  @override
  String get ruleExitTitle => 'Salir del establo';

  @override
  String get ruleExitBody =>
      'Cada jugador tiene cuatro caballos, y el primero ya está en su casilla de salida: juegas desde la primera carta, sin esperar. Los otros tres salen del establo con un 6 — acierta y el caballo ocupa la casilla de salida. Dos de tus caballos nunca comparten casilla: uno tuyo sobre tu casilla de salida cierra la puerta hasta que avance.';

  @override
  String get ruleSixTitle => 'El 6 repite turno';

  @override
  String get ruleSixBody =>
      'Como con el dado: si sacas un 6, vuelves a jugar después de tu turno, aciertes o no.';

  @override
  String get ruleCaptureTitle => 'Capturar y enviar a casa';

  @override
  String get ruleCaptureBody =>
      'Caer exactamente sobre el caballo de un rival lo devuelve con calma a su establo, salvo que la casilla sea un oasis o ese caballo lleve un escudo del saber. La captura se paga: tu caballo salta al instante 20 galopes. Un caballo que sale del establo siempre captura en su casilla de salida.';

  @override
  String get ruleStreakTitle => 'La serie de respuestas correctas';

  @override
  String get ruleStreakBody =>
      'Tres respuestas correctas seguidas dan un escudo, cinco el Gran Galope y diez una insignia de maestría. El Gran Galope se gasta solo, y únicamente cuando sus +2 galopes bastan para llegar a la meta. Las bonificaciones vienen solo del conocimiento.';

  @override
  String get ruleArrivalTitle => 'La llegada';

  @override
  String get ruleArrivalBody =>
      'La meta se alcanza con el número exacto: a tres casillas de La Meca necesitas justo un 3. Un 4, un 5 o un 6 deja el caballo donde está, esperando la carta correcta. Al llegar, responde la Pregunta del viaje para validar tu llegada; un error nunca te hace retroceder, lo intentas de nuevo en el siguiente turno.';

  @override
  String get hapticFeedback => 'Vibración';

  @override
  String squaresWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¡$count galopes ganados!',
      one: '¡$count galope ganado!',
    );
    return '$_temp0';
  }

  @override
  String get chooseHorseToMove => 'Elige un caballo';

  @override
  String get touchHorseHint => 'Toca un caballo para ver adónde iría';

  @override
  String get dragHorseToDestination =>
      'Arrastra el caballo hasta su casilla dorada';

  @override
  String get bonusLabel => 'BONUS';

  @override
  String bonusPlus(int value) {
    return '+$value galopes';
  }

  @override
  String get captureBonusLabel => 'CAPTURA';

  @override
  String captureBonusRide(int value) {
    return '¡Captura! Tu caballo salta $value galopes.';
  }

  @override
  String bonusRide(int value) {
    return '¡Casilla bonus! Tu caballo avanza $value casillas más.';
  }

  @override
  String cardWasWorth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esta carta valía $count galopes.',
      one: 'Esta carta valía $count galope.',
    );
    return '$_temp0';
  }

  @override
  String get bonusMissedNote =>
      'Bonus fallado: tu caballo se queda donde está.';

  @override
  String get answerToReveal => 'Responde para descubrir su valor';

  @override
  String opponentPlaces(String name) {
    return '$name elige un caballo…';
  }

  @override
  String opponentBonus(String name, int value) {
    return '¡$name consigue un bonus +$value!';
  }

  @override
  String get leaderLabel => 'En cabeza';

  @override
  String tookTheLead(String name) {
    return '¡$name se pone en cabeza!';
  }

  @override
  String bonusSquareSemantics(int value) {
    return 'Casilla bonus +$value';
  }

  @override
  String moveHintBonus(int value) {
    return 'Bonus +$value';
  }

  @override
  String get bonusSquaresTeaser =>
      '16 casillas bonus te esperan en el tablero: +5, +10 y la rara +20.';

  @override
  String get ridersSubtitle =>
      'Cada jinete elige su nivel; la carta solo marca la distancia.';

  @override
  String get ruleBonusTitle => 'Las casillas bonus';

  @override
  String get ruleBonusBody =>
      'Si la mesa las conserva, dieciséis casillas de bonificación se reparten en el tablero cada partida, cuatro por cuarto. Un caballo que se detiene exactamente en una sigue de inmediato +5, +10 o +20 galopes — y si esa cabalgada lo deja justo en otra casilla de bonificación, esa también se dispara: las bonificaciones se encadenan. Cada casilla paga una vez por turno y sigue en juego para todos. Sin ellas, una carta vale exactamente sus galopes.';
}
