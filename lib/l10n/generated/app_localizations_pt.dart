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
      'Puxe uma carta, responda, avance — e leve seu cavalo até Meca.';

  @override
  String get getStarted => 'Começar';

  @override
  String get onboardingHowTo => 'Como se joga';

  @override
  String get onboardingStepDraw => 'Compre uma carta: ela anuncia seus galopes';

  @override
  String get onboardingStepAnswer => 'Acerte: os galopes são seus';

  @override
  String get onboardingStepRide => 'Coloque seu cavalo e galope até o oásis';

  @override
  String get onboardingLanguageHint =>
      'Você poderá mudá-la depois nas configurações.';

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
  String noMoveOvershoot(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Carta grande demais: o teu cavalo está a $count casas de Meca e precisa de exatamente $count.',
      one:
          'Carta grande demais: o teu cavalo está a $count casa de Meca e precisa de exatamente 1.',
    );
    return '$_temp0';
  }

  @override
  String get hudArrivedHeading => 'Cavalos chegados';

  @override
  String get hudKnowledgeShort => 'saber';

  @override
  String get hudStreakShort => 'sequência';

  @override
  String get hudCardsShort => 'cartas';

  @override
  String get boardMenuTitle => 'Menu do jogo';

  @override
  String get boardMenuOpen => 'Abrir o menu do jogo';

  @override
  String get autoPlaySingleMove => 'Movimento automático';

  @override
  String get autoPlaySingleMoveHint =>
      'Quando só um cavalo pode jogar a carta, ele avança sozinho.';

  @override
  String get testerMode => 'Modo de teste';

  @override
  String testerModeHint(int total) {
    return 'Desbloqueia as $total perguntas neste aparelho, sem compra. Esta opção só existe nas versões de teste.';
  }

  @override
  String testerBankPlayable(int count, int total) {
    return '$count de $total perguntas jogáveis';
  }

  @override
  String get restartRace => 'Recomeçar a corrida';

  @override
  String get restartRaceConfirm =>
      'A corrida em curso será perdida. Os mesmos cavaleiros recomeçam do estábulo.';

  @override
  String get backToHome => 'Voltar ao início';

  @override
  String get backToHomeHint => 'O jogo fica guardado; poderás retomá-lo.';

  @override
  String get duoGame => 'Jogo em dupla';

  @override
  String horsesToMecca(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cavalos até Meca',
      one: '$count cavalo até Meca',
    );
    return '$_temp0';
  }

  @override
  String get formatQuickHint => 'A corrida mais curta.';

  @override
  String get formatDuoHint => 'Uma corrida de uma noite.';

  @override
  String get formatClassicHint => 'O jogo completo, como no original.';

  @override
  String get bonusSquaresOption => 'Casas de bónus no percurso';

  @override
  String get bonusSquaresOn =>
      '16 casas dão uma cavalgada extra: +5, +10 ou +20.';

  @override
  String get bonusSquaresOff =>
      'Percurso puro: uma carta vale exatamente os seus galopes.';

  @override
  String get muteSound => 'Silenciar';

  @override
  String get unmuteSound => 'Ativar som';

  @override
  String get chooseDifficulty => 'Escolher dificuldade';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Médio';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get playerName => 'Nome';

  @override
  String get chooseTeam => 'Escolher equipe';

  @override
  String get ridersTitle => 'Os cavaleiros';

  @override
  String get storeLoading => 'Ligando à loja…';

  @override
  String get storeUnavailableCta => 'Loja indisponível';

  @override
  String get premiumBenefitBank =>
      'Todo o banco de perguntas, cada uma com a sua fonte';

  @override
  String premiumBenefitUnlimited(int count) {
    return 'Partidas ilimitadas, até Meca (a versão gratuita para após $count puxadas)';
  }

  @override
  String get premiumBenefitFamily =>
      'Uma única compra para toda a família, sem anúncios';

  @override
  String get progressEmpty =>
      'Joga uma primeira partida: o teu progresso aparece aqui.';

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
  String get learnMore => 'Saber mais';

  @override
  String get questionDetailsTitle => 'Para saber mais';

  @override
  String get theQuestionLabel => 'A pergunta';

  @override
  String get theAnswerLabel => 'A resposta certa';

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
  String get aboutDialogTitle => 'Sobre o IqraQuest';

  @override
  String versionLabel(String version) {
    return 'Versão $version';
  }

  @override
  String copyrightNotice(String year) {
    return '© $year IqraQuest. Todos os direitos reservados.';
  }

  @override
  String get originalWorkNotice =>
      'IqraQuest, o seu conceito de jogo, as suas regras, as suas ilustrações, o seu nome e o seu conteúdo são obras originais protegidas por direitos de autor. É proibida qualquer reprodução, imitação ou adaptação, total ou parcial, sem autorização escrita.';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get genericError => 'Algo deu errado.';

  @override
  String get parentalGateTitle => 'Uma pergunta para os pais';

  @override
  String get parentalGateInstruction => 'Resolva isto para continuar.';

  @override
  String get placeMecca => 'Meca';

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
      other: '$count casas especiais',
      one: '$count casa especial',
    );
    return '$_temp0';
  }

  @override
  String get drawCard => 'Puxar uma carta';

  @override
  String get drawnCardTitle => 'Carta puxada';

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
  String get knowledgeStreak => 'Respostas certas seguidas';

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
      'O percurso mais calmo: oásis e poucas surpresas.';

  @override
  String get circuitCaravanTrailDescription =>
      'Desafios e revezamentos pelo caminho. Mais tático.';

  @override
  String get circuitGreatRideDescription =>
      'O percurso mais movimentado: desafios, atalhos e duelos.';

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
  String opponentThinking(String name) {
    return '$name está pensando…';
  }

  @override
  String opponentDrew(String name, int count) {
    return '$name tira um $count';
  }

  @override
  String correctAnswerWas(String answer) {
    return 'A resposta certa: $answer';
  }

  @override
  String get scoreboardTitle => 'Quadro da corrida';

  @override
  String scoreboardCorrect(int count) {
    return '$count acertos';
  }

  @override
  String scoreboardBestStreak(int count) {
    return 'sequência de $count';
  }

  @override
  String get playAgainSameRiders => 'Mais uma corrida!';

  @override
  String opponentMoved(String name) {
    return '$name avança!';
  }

  @override
  String opponentStayed(String name) {
    return '$name fica parado.';
  }

  @override
  String get shareScore => 'Partilhar';

  @override
  String shareVictoryText(String name, int points) {
    return '$name venceu a corrida IqraQuest com $points ⭐! E tu?';
  }

  @override
  String shareDailyText(int score, int total) {
    return '$score/$total no desafio do dia IqraQuest! Consegues melhor?';
  }

  @override
  String get dailyChallengeDone => 'Desafio do dia concluído';

  @override
  String dailyChallengeScore(num score, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score certas em $total',
      one: '$score certa em $total',
      zero: 'Nenhuma certa em $total',
    );
    return '$_temp0';
  }

  @override
  String get dailyChallengeComeBack => 'Volta amanhã para um novo desafio.';

  @override
  String get aiOpponentsLabel => 'Adversários';

  @override
  String get playersLabel => 'Jogadores';

  @override
  String get outcomeMoved => 'Seu cavalo avança!';

  @override
  String get outcomeStayed => 'Seu cavalo fica parado. Nada se perde.';

  @override
  String get outcomeCaptured => 'Você captura um cavalo adversário!';

  @override
  String get outcomeExited => 'Seu cavalo sai do estábulo!';

  @override
  String get outcomeNoLegalMove =>
      'Esta carta não move nenhum cavalo. Próxima vez!';

  @override
  String get noExitHint =>
      'Você precisa de um 6 para tirar um cavalo do estábulo.';

  @override
  String get bonusTurnHint => 'Vez extra: o 6 deixa você jogar de novo!';

  @override
  String get celebrateSixTitle => 'SEIS!';

  @override
  String get celebrateSixBody => 'Você vai puxar de novo depois desta vez.';

  @override
  String get celebrateSixExitBody =>
      'Um cavalo pode sair — e você joga de novo!';

  @override
  String get celebrateExitTitle => 'Saída!';

  @override
  String get celebrateExitBody => 'Um cavalo pode sair do estábulo.';

  @override
  String get celebrateCaptureTitle => 'Captura!';

  @override
  String get celebrateCaptureBody => 'O cavalo adversário volta ao estábulo.';

  @override
  String get celebrateCapturedTitle => 'Capturado…';

  @override
  String get celebrateCapturedBody =>
      'Seu cavalo volta ao estábulo. Um 6 o traz de volta.';

  @override
  String get celebrateArrivalTitle => 'Meca!';

  @override
  String get celebrateArrivalBody =>
      'Seu cavalo chegou. Uma última pergunta para confirmar!';

  @override
  String get freeLimitTitle => 'Fim da corrida gratuita';

  @override
  String freeLimitLeader(String name) {
    return 'Na frente: $name';
  }

  @override
  String freeLimitBody(int count) {
    return 'A versão gratuita para após $count puxadas. Com o Premium, a corrida vai até Meca.';
  }

  @override
  String get freeLimitCta => 'Desbloquear a corrida ilimitada';

  @override
  String drawsCounter(int count, int max) {
    return 'Puxadas: $count de $max';
  }

  @override
  String moveChoiceTitle(int count) {
    return 'O que você faz com este $count?';
  }

  @override
  String get moveChoiceExit => 'Tirar um cavalo do estábulo';

  @override
  String moveChoiceAdvance(int number, int count) {
    return 'Cavalo $number: avançar $count';
  }

  @override
  String moveHintCapture(int value) {
    return 'captura! +$value';
  }

  @override
  String get moveHintFinish => 'chegada!';

  @override
  String get moveHintOasis => 'oásis';

  @override
  String opponentExits(String name) {
    return '$name tira um cavalo!';
  }

  @override
  String opponentNoMove(String name) {
    return '$name não pode mover nada.';
  }

  @override
  String opponentReplays(String name) {
    return '$name tirou um 6 e joga de novo!';
  }

  @override
  String opponentCaptured(String name) {
    return '$name captura um cavalo!';
  }

  @override
  String get outcomeShieldBlocked => 'O escudo protegeu o cavalo.';

  @override
  String get outcomeShelteredByOasis =>
      'O Oásis abriga aquele cavalo: ninguém volta para o estábulo.';

  @override
  String get playerProfile => 'Nível das perguntas';

  @override
  String get levelBeginner => 'Primeiros passos';

  @override
  String get levelBeginnerHint =>
      'Primeiros passos: o básico dos básicos, o que toda a gente já sabe.';

  @override
  String get levelEasy => 'Fácil';

  @override
  String get levelIntermediate => 'Intermediário';

  @override
  String get levelExpert => 'Especialista';

  @override
  String get levelMixed => 'Misto';

  @override
  String get levelMixedHint =>
      'Misto: cada carta tira o seu nível, dos primeiros passos a especialista.';

  @override
  String get raceRulesUpdatedTitle => 'As regras da corrida foram melhoradas';

  @override
  String get raceRulesUpdatedBody =>
      'As regras mudaram: agora você puxa uma carta, e o valor dela dá ao mesmo tempo a distância e a dificuldade. Seu progresso, suas medalhas e suas compras são mantidos — só a partida em andamento não pode continuar com as novas regras.';

  @override
  String get startNewRace => 'Começar uma nova corrida';

  @override
  String get rulesTitle => 'As regras';

  @override
  String get ruleGoalTitle => 'Ganhar a corrida';

  @override
  String get ruleGoalBody =>
      'Cada jogador leva quatro cavalos até Meca, no centro do tabuleiro. Antes do jogo, a mesa escolhe quantos têm de chegar: um para uma corrida rápida, dois para uma corrida em dupla, os quatro para o jogo clássico. Ganha o primeiro que o conseguir.';

  @override
  String get ruleKnowledgeTitle => 'Pontos de saber';

  @override
  String get ruleKnowledgeBody =>
      'A estrela da barra conta os teus pontos de saber: um por cada resposta certa e um a mais numa casa de Conhecimento. Não fazem o cavalo avançar — dizem o que aprendeste e desempatam os jogadores se o jogo acabar antes da chegada.';

  @override
  String get ruleSpecialCellsTitle => 'As casas especiais';

  @override
  String get ruleSpecialCellsBody =>
      'O percurso que escolheste tem casas que fazem algo, as mesmas nos seus quatro quartos: o Oásis protege das capturas, Conhecimento dá um ponto de saber, o Desafio propõe uma pergunta mais difícil por +2 galopes, o Atalho uma pergunta difícil para cortar à frente, e Sabedoria oferece um facto para guardar. Falhar um Desafio ou um Atalho custa só o bónus: o teu cavalo fica onde está.';

  @override
  String get ruleDrawCardTitle => 'Puxe uma carta';

  @override
  String get ruleDrawCardBody =>
      'Na tua vez, tira uma carta. Ela vira mostrando o seu valor — «Carta de 5 galopes» — e depois abre a pergunta, sempre ao teu nível, escolhido no início: fácil, intermédio, especialista ou misto. Assim sabes o que vale uma resposta certa antes de responder.';

  @override
  String get ruleAnswerToAdvanceTitle => 'Responda para avançar';

  @override
  String get ruleAnswerToAdvanceBody =>
      'Uma resposta certa dá-te os galopes da carta: um galope, uma casa. Escolhe então o cavalo que os leva — toca-lhe para ver onde chegaria e arrasta-o até à sua casa dourada. Largar é jogar: nada se move antes, nada pede confirmação depois. Uma resposta errada não move nada: nunca recuas.';

  @override
  String get ruleEscalierTitle => 'A escada até Meca';

  @override
  String get ruleEscalierBody =>
      'Depois de uma volta completa no tabuleiro, seu cavalo sobe os cinco degraus da sua escada até Meca. Ali ninguém mais o alcança.';

  @override
  String get ruleExitTitle => 'Sair do estábulo';

  @override
  String get ruleExitBody =>
      'Cada jogador tem quatro cavalos, e o primeiro já está na sua casa de partida: jogas desde a primeira carta, sem esperar. Os outros três saem do estábulo com um 6 — acerta e o cavalo ocupa a casa de partida. Dois dos teus cavalos nunca partilham uma casa: um teu na casa de partida fecha o portão até avançar.';

  @override
  String get ruleSixTitle => 'O 6 joga de novo';

  @override
  String get ruleSixBody =>
      'Como no dado: se tirares um 6, jogas outra vez depois da tua vez, tenhas acertado ou não.';

  @override
  String get ruleCaptureTitle => 'Capturar e mandar de volta';

  @override
  String get ruleCaptureBody =>
      'Cair exatamente sobre o cavalo de um adversário o manda calmamente de volta ao estábulo — a menos que a casa seja um oásis ou que o cavalo tenha um escudo do saber. A captura paga: o seu cavalo salta na hora 20 galopes. Um cavalo que sai do estábulo sempre captura na sua casa de partida.';

  @override
  String get ruleStreakTitle => 'A série de respostas certas';

  @override
  String get ruleStreakBody =>
      'Três respostas certas seguidas dão um escudo, cinco o Grande Galope e dez uma medalha de maestria. O Grande Galope é gasto sozinho, e só quando seus +2 galopes bastam para chegar ao fim. Os bônus vêm apenas do conhecimento.';

  @override
  String get ruleArrivalTitle => 'A chegada';

  @override
  String get ruleArrivalBody =>
      'A chegada exige o número exato: a três casas de Meca você precisa de exatamente 3. Um 4, um 5 ou um 6 deixa o cavalo onde está, esperando a carta certa. Ao chegar, responda à Pergunta da viagem para validar sua chegada; um erro nunca faz você recuar, basta tentar de novo na próxima vez.';

  @override
  String get hapticFeedback => 'Vibração';

  @override
  String squaresWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count galopes ganhos',
      one: '$count galope ganho',
    );
    return '$_temp0';
  }

  @override
  String get chooseHorseToMove => 'Escolha um cavalo';

  @override
  String get touchHorseHint => 'Toque num cavalo para ver aonde iria';

  @override
  String get dragHorseToDestination => 'Arraste o cavalo até a casa dourada';

  @override
  String get bonusLabel => 'BÔNUS';

  @override
  String bonusPlus(int value) {
    return '+$value galopes';
  }

  @override
  String get captureBonusLabel => 'CAPTURA';

  @override
  String captureBonusRide(int value) {
    return 'Captura! O seu cavalo salta $value galopes.';
  }

  @override
  String bonusRide(int value) {
    return 'Casa bônus! Seu cavalo avança mais $value casas.';
  }

  @override
  String cardWasWorth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esta carta valia $count galopes.',
      one: 'Esta carta valia $count galope.',
    );
    return '$_temp0';
  }

  @override
  String get bonusMissedNote => 'Bónus falhado: o teu cavalo fica onde está.';

  @override
  String get answerToReveal => 'Responda para descobrir o valor';

  @override
  String opponentPlaces(String name) {
    return '$name está escolhendo um cavalo…';
  }

  @override
  String opponentBonus(String name, int value) {
    return '$name ganha um bônus +$value!';
  }

  @override
  String get leaderLabel => 'Na frente';

  @override
  String tookTheLead(String name) {
    return '$name assume a liderança!';
  }

  @override
  String bonusSquareSemantics(int value) {
    return 'Casa bônus +$value';
  }

  @override
  String moveHintBonus(int value) {
    return 'Bônus +$value';
  }

  @override
  String get bonusSquaresTeaser =>
      '16 casas bônus esperam no tabuleiro: +5, +10 e a rara +20.';

  @override
  String get ridersSubtitle =>
      'Cada cavaleiro escolhe seu nível; a carta só define a distância.';

  @override
  String get ruleBonusTitle => 'As casas bônus';

  @override
  String get ruleBonusBody =>
      'Se a mesa as mantiver, dezesseis casas de bónus são distribuídas no tabuleiro em cada jogo, quatro por quarto. Um cavalo que pare exatamente numa segue logo +5, +10 ou +20 galopes — e se essa cavalgada o deixar em cima de outra casa de bónus, essa também dispara: os bónus encadeiam-se. Cada casa paga uma vez por turno e fica em jogo para todos. Sem elas, uma carta vale exatamente os seus galopes.';

  @override
  String get newGameTitle => 'Novo jogo';

  @override
  String get setupWhoPlays => 'Quem joga?';

  @override
  String get soloTileCaption => 'contra o computador';

  @override
  String get computerLevelLabel => 'Nível do computador';

  @override
  String get setupRaceLength => 'Duração do jogo';

  @override
  String get raceLengthShort => 'Jogo curto';

  @override
  String get raceLengthMedium => 'Jogo médio';

  @override
  String get raceLengthFull => 'Jogo completo';

  @override
  String get setupCourse => 'Percurso';

  @override
  String get courseCalm => 'Tranquilo';

  @override
  String get courseLively => 'Animado';

  @override
  String get courseIntense => 'Intenso';

  @override
  String get courseSquareOasis => 'Oásis: o teu cavalo está a salvo';

  @override
  String get courseSquareKnowledge => 'Conhecimento: +1 ponto de saber';

  @override
  String get courseSquareChallenge =>
      'Desafio: uma pergunta extra por +2 casas';

  @override
  String get courseSquareShortcut =>
      'Atalho: uma pergunta difícil para saltar em frente';

  @override
  String get courseSquareWisdom =>
      'Sabedoria: um facto para descobrir e guardar';

  @override
  String get levelEasyHint =>
      'Fácil: perguntas simples sobre o que se aprende primeiro.';

  @override
  String get levelIntermediateHint =>
      'Intermédio: para quem já conhece bem as histórias e as regras.';

  @override
  String get levelExpertHint =>
      'Especialista: as perguntas mais precisas, com versículos e hadiths.';
}
