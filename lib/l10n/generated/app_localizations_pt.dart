// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'IqraQuest';

  @override
  String get appTagline => 'A jornada do conhecimento';

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao IqraQuest';

  @override
  String get onboardingWelcomeSubtitle =>
      'Responda perguntas, escolha seu passo e guie seu cavalo de Meca a Medina.';

  @override
  String get getStarted => 'Começar';

  @override
  String get chooseLanguage => 'Escolher idioma';

  @override
  String get play => 'Jogar';

  @override
  String get soloMode => 'Solo';

  @override
  String get familyMode => 'Família';

  @override
  String get dailyChallenge => 'Desafio diário';

  @override
  String get progress => 'Progresso';

  @override
  String get settings => 'Configurações';

  @override
  String get premium => 'Premium';

  @override
  String get continueGame => 'Continuar jogo';

  @override
  String get quickGame => 'Jogo rápido';

  @override
  String get classicGame => 'Jogo clássico';

  @override
  String get chooseDifficulty => 'Escolher dificuldade';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Intermediário';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get playerName => 'Nome';

  @override
  String get chooseTeam => 'Escolher equipe';

  @override
  String get addPlayer => 'Adicionar jogador';

  @override
  String get startGame => 'Iniciar jogo';

  @override
  String get yourTurn => 'Sua vez';

  @override
  String get categoryProphets => 'Profetas';

  @override
  String get categorySira => 'Sira';

  @override
  String get categoryQuran => 'Alcorão';

  @override
  String get categoryFaith => 'Fé';

  @override
  String get categoryVirtues => 'Virtudes';

  @override
  String get category => 'Categoria';

  @override
  String get correctAnswer => 'Resposta correta!';

  @override
  String get incorrectAnswer => 'Não exatamente…';

  @override
  String get explanationLabel => 'Explicação';

  @override
  String get sourceLabel => 'Fonte';

  @override
  String get nextPlayer => 'Próximo jogador';

  @override
  String get rolledSix => 'Um seis! Outra rodada — nova pergunta.';

  @override
  String get playAgain => 'Jogar novamente';

  @override
  String get protectedSquareLabel => 'Casa protegida';

  @override
  String get freeBankExhaustedMessage =>
      'Todas as perguntas da edição gratuita foram usadas nesta partida.';

  @override
  String get victory => 'Vitória!';

  @override
  String get gameOver => 'Fim de jogo';

  @override
  String get backToHome => 'Voltar ao início';

  @override
  String get gamesPlayed => 'Partidas jogadas';

  @override
  String get winRate => 'Taxa de vitórias';

  @override
  String get questionsAnswered => 'Perguntas respondidas';

  @override
  String get streak => 'Sequência de dias';

  @override
  String get premiumTitle => 'IqraQuest Premium';

  @override
  String get premiumUnlockAll =>
      'Desbloqueie todo o banco de perguntas e todas as dificuldades';

  @override
  String get premiumOneTime => 'Pagamento único — sem assinatura';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get purchaseSuccess => 'Obrigado! O Premium está ativo.';

  @override
  String get purchaseError =>
      'Não foi possível concluir a compra. Tente novamente mais tarde.';

  @override
  String get language => 'Idioma';

  @override
  String get reduceMotion => 'Reduzir movimento';

  @override
  String get soundEffects => 'Efeitos sonoros';

  @override
  String get howToPlay => 'Como jogar';

  @override
  String get privacySummary =>
      'O IqraQuest funciona inteiramente no seu dispositivo: sem conta, sem anúncios, sem rastreamento, e nada é enviado pela Internet.';

  @override
  String defaultPlayerName(num number) {
    return 'Jogador $number';
  }

  @override
  String aiPlayerName(num number) {
    return 'Cavaleiro $number';
  }

  @override
  String opponentWins(String name) {
    return '$name vence a corrida!';
  }

  @override
  String get wellRidden => 'Bela cavalgada — cada pergunta aprendida conta.';

  @override
  String horseSemantics(String color, num number) {
    return 'Cavalo $color $number';
  }

  @override
  String get teamEmerald => 'esmeralda';

  @override
  String get teamSaphir => 'safira';

  @override
  String get teamGrenat => 'grená';

  @override
  String get teamSafran => 'açafrão';

  @override
  String premiumCta(String price) {
    return 'Desbloquear tudo — $price';
  }

  @override
  String premiumQuestionsIncluded(num count) {
    return '$count perguntas verificadas, cada uma com sua fonte — e o banco continua crescendo.';
  }

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get about => 'Sobre';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get genericError => 'Algo deu errado.';

  @override
  String get parentalGateTitle => 'Uma pergunta para os pais';

  @override
  String get parentalGateInstruction => 'Resolva isto para continuar.';

  @override
  String get chooseYourGait => 'Escolha seu passo';

  @override
  String get placeMecca => 'Meca';

  @override
  String get placeMedina => 'Medina';

  @override
  String get placeJerusalem => 'Jerusalém';

  @override
  String get placeArafat => 'Monte Arafat';

  @override
  String get placeMina => 'Mina';

  @override
  String get drawCard => 'Puxar uma carta';

  @override
  String get drawnCardTitle => 'Carta puxada';

  @override
  String cardWorth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vale $count casas',
      one: 'Vale $count casa',
    );
    return '$_temp0';
  }

  @override
  String gaitSquares(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count casas',
      one: '$count casa',
    );
    return '$_temp0';
  }

  @override
  String get gaitNameWalk => 'Passo';

  @override
  String get gaitNameTrot => 'Trote';

  @override
  String get gaitNameCanter => 'Meio galope';

  @override
  String get gaitNameGallop => 'Galope';

  @override
  String get gaitNameFullGallop => 'Galope largo';

  @override
  String get gaitNameCharge => 'Carga';

  @override
  String get chooseFormat => 'Formato de jogo';

  @override
  String get gaitAlreadyUsed => 'Já usado neste ciclo';

  @override
  String gaitSemanticLabel(int steps, String difficulty, int points) {
    return 'Avançar $steps casas, pergunta $difficulty, $points pontos de saber';
  }

  @override
  String get selectHorse => 'Escolha seu cavalo';

  @override
  String get confirmBoldGait =>
      'Este passo pede uma pergunta mais difícil. Continuar?';

  @override
  String get knowledgeStreak => 'Impulso do saber';

  @override
  String get knowledgePointsLabel => 'Pontos de saber';

  @override
  String get shieldEarned => 'Escudo conquistado! Seu cavalo está protegido.';

  @override
  String get grandGallopEarned =>
      'Grande Galope desbloqueado! +2 casas quando quiser.';

  @override
  String get masteryBadgeEarned => 'Emblema de maestria conquistado!';

  @override
  String get useGrandGallop => 'Usar o Grande Galope (+2)';

  @override
  String get chooseCircuit => 'Escolha seu percurso';

  @override
  String get circuitOasisRoute => 'A Rota dos Oásis';

  @override
  String get circuitCaravanTrail => 'A Trilha das Caravanas';

  @override
  String get circuitGreatRide => 'A Grande Cavalgada do Saber';

  @override
  String get circuitOasisRouteDescription =>
      'Percurso curto e luminoso. Perfeito para um jogo rápido.';

  @override
  String get circuitCaravanTrailDescription =>
      'Acampamentos e lanternas. Um percurso mais estratégico.';

  @override
  String get circuitGreatRideDescription =>
      'Do dia ao céu estrelado. A grande viagem.';

  @override
  String get cellOasis => 'Oásis';

  @override
  String get cellKnowledge => 'Conhecimento';

  @override
  String get cellChallenge => 'Desafio';

  @override
  String get cellShortcut => 'Atalho';

  @override
  String get cellDuel => 'Duelo';

  @override
  String get cellWisdom => 'Sabedoria';

  @override
  String get cellRelay => 'Revezamento';

  @override
  String get cellOasisDescription =>
      'Seu cavalo está a salvo de capturas aqui.';

  @override
  String get cellChallengeOffer =>
      'Responder a uma pergunta mais difícil para avançar mais 2 casas?';

  @override
  String get acceptChallenge => 'Aceitar o desafio';

  @override
  String get declineChallenge => 'Manter meu movimento';

  @override
  String get saveFact => 'Guardar este facto';

  @override
  String get journeyQuestion => 'Pergunta da viagem';

  @override
  String get journeyQuestionIntro =>
      'Uma última pergunta para validar sua chegada.';

  @override
  String get outcomeMoved => 'Seu cavalo avança!';

  @override
  String get outcomeStayed => 'Seu cavalo fica parado. Nada se perde.';

  @override
  String get outcomeCaptured => 'Você ultrapassa um adversário!';

  @override
  String get outcomeShieldBlocked => 'O escudo protegeu o cavalo.';

  @override
  String get playerProfile => 'Nível do jogador';

  @override
  String get profileChild => 'Criança';

  @override
  String get profileDiscovery => 'Descoberta';

  @override
  String get profileIntermediate => 'Intermediário';

  @override
  String get profileAdvanced => 'Avançado';

  @override
  String get raceRulesUpdatedTitle => 'As regras da corrida foram melhoradas';

  @override
  String get raceRulesUpdatedBody =>
      'O dado acabou: agora você escolhe seu passo e, com ele, seu nível de risco. Seu progresso, emblemas e compras são mantidos — apenas o jogo em andamento não pode continuar com as novas regras.';

  @override
  String get startNewRace => 'Começar uma nova corrida';

  @override
  String get rulesTitle => 'As regras';

  @override
  String get ruleChooseGaitTitle => 'Escolha seu passo';

  @override
  String get ruleChooseGaitBody =>
      'Você decide quantas casas avançar, de 1 a 6. Quanto mais longe for, mais difícil a pergunta: 1-2 fácil, 3-4 média, 5-6 difícil.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Responda para avançar';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Uma resposta certa move seu cavalo exatamente a distância escolhida. Uma resposta errada o deixa onde está — você nunca retrocede.';

  @override
  String get ruleGaitCycleTitle => 'Um passo por ciclo';

  @override
  String get ruleGaitCycleBody =>
      'Cada passo só pode ser usado uma vez. Quando os seis se esgotam, todos voltam — planeje com antecedência.';

  @override
  String get ruleCaptureTitle => 'Ultrapassar e mandar de volta';

  @override
  String get ruleCaptureBody =>
      'Cair exatamente sobre o cavalo de um adversário o manda calmamente de volta ao estábulo — a menos que a casa seja um oásis ou que o cavalo tenha um escudo do saber.';

  @override
  String get ruleStreakTitle => 'O impulso do saber';

  @override
  String get ruleStreakBody =>
      'Três respostas certas seguidas dão um escudo, cinco dão o Grande Galope (+2 casas) e dez, um emblema de maestria. Os bônus vêm apenas do conhecimento.';

  @override
  String get ruleArrivalTitle => 'A chegada';

  @override
  String get ruleArrivalBody =>
      'Chegue ao fim do percurso — passar da linha é permitido — e responda à Pergunta da viagem para validar sua chegada. Um erro nunca faz você recuar: basta tentar de novo na próxima vez.';
}
