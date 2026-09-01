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
      'Responde preguntas, elige tu paso y guía tu caballo de La Meca a Medina.';

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
  String get difficultyMedium => 'Intermedio';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get playerName => 'Nombre';

  @override
  String get chooseTeam => 'Elegir equipo';

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
      'Desbloquea las 500 preguntas y todas las dificultades';

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
  String get chooseYourGait => 'Elige tu paso';

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
  String get confirmBoldGait =>
      'Este paso pide una pregunta más difícil. ¿Continuamos?';

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
      'Recorrido corto y luminoso. Perfecto para una partida rápida.';

  @override
  String get circuitCaravanTrailDescription =>
      'Campamentos y faroles. Un recorrido más estratégico.';

  @override
  String get circuitGreatRideDescription =>
      'Del día al cielo estrellado. El gran viaje.';

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
  String get outcomeMoved => '¡Tu caballo avanza!';

  @override
  String get outcomeStayed => 'Tu caballo se queda. No pierdes nada.';

  @override
  String get outcomeCaptured => '¡Adelantas a un rival!';

  @override
  String get outcomeShieldBlocked => 'El escudo protegió al caballo.';

  @override
  String get playerProfile => 'Nivel del jugador';

  @override
  String get profileChild => 'Niño';

  @override
  String get profileDiscovery => 'Descubrimiento';

  @override
  String get profileIntermediate => 'Intermedio';

  @override
  String get profileAdvanced => 'Avanzado';

  @override
  String get raceRulesUpdatedTitle => 'Las reglas de la carrera han mejorado';

  @override
  String get raceRulesUpdatedBody =>
      'El dado ha desaparecido: ahora eliges tu paso y, con él, tu nivel de riesgo. Tu progreso, insignias y compras se conservan; solo la partida en curso no puede continuar con las nuevas reglas.';

  @override
  String get startNewRace => 'Empezar una nueva carrera';

  @override
  String get rulesTitle => 'Las reglas';

  @override
  String get ruleChooseGaitTitle => 'Elige tu paso';

  @override
  String get ruleChooseGaitBody =>
      'Tú decides cuántas casillas avanzar, de 1 a 6. Cuanto más lejos vayas, más difícil será la pregunta: 1-2 fácil, 3-4 media, 5-6 difícil.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Responde para avanzar';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Una respuesta correcta mueve tu caballo exactamente la distancia elegida. Una respuesta incorrecta lo deja donde está: nunca retrocedes.';

  @override
  String get ruleGaitCycleTitle => 'Un paso por ciclo';

  @override
  String get ruleGaitCycleBody =>
      'Cada paso solo se usa una vez. Cuando se agotan los seis, vuelven todos: planifica con antelación.';

  @override
  String get ruleCaptureTitle => 'Adelantar y enviar a casa';

  @override
  String get ruleCaptureBody =>
      'Caer exactamente sobre el caballo de un rival lo devuelve con calma a su establo, salvo que la casilla sea un oasis o ese caballo lleve un escudo del saber.';

  @override
  String get ruleStreakTitle => 'El impulso del saber';

  @override
  String get ruleStreakBody =>
      'Tres respuestas correctas seguidas dan un escudo, cinco dan el Gran Galope (+2 casillas) y diez, una insignia de maestría. Los bonus solo se ganan con conocimiento.';

  @override
  String get ruleArrivalTitle => 'La llegada';

  @override
  String get ruleArrivalBody =>
      'Llega al final del recorrido —pasarse de la línea está permitido— y responde la Pregunta del viaje para validar tu llegada. Un error nunca te hace retroceder: lo intentas de nuevo en el siguiente turno.';
}
