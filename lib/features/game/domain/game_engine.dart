import '../../../models/circuit.dart';
import '../../../models/game_mode.dart';
import '../../../models/game_state.dart';
import '../../../models/knowledge_streak.dart';
import '../../../models/move_outcome.dart';
import '../../../models/movement_choice.dart';
import '../../../models/pawn_position.dart';
import '../../../models/player.dart';
import '../../../models/turn_phase.dart';

/// The single source of truth for IqraQuest's rules: the classic *jeu
/// des petits chevaux*, with the deck of question cards in place of the
/// die.
///
/// A turn: draw a card (1–6). A 6 may bring a horse out of the stable
/// onto its start square; any value rides a horse already on the
/// course that many squares. Landing exactly on an opponent sends it home;
/// two of your own horses never share a square. A 6 earns a second draw.
/// Whether the chosen move actually happens is decided by answering the
/// card's question — that is the one place this game differs from the
/// original, and the whole point of it.
///
/// There is no randomness anywhere in this class: the card is drawn by
/// the controller's deck and handed in. Every board effect is fixed and
/// previewable before the player commits (see [previewGait]).
///
/// Pure, deterministic, platform-independent — no widgets, no I/O. The
/// same instance drives human players and every AI difficulty.
class GameEngine {
  const GameEngine();

  // ---------------------------------------------------------------------
  // Reading the current options
  // ---------------------------------------------------------------------

  /// Every card value the deck can put on the table.
  ///
  /// A turn's distance comes from drawing a question card, so nothing is
  /// ever "spent": a draw may legitimately produce the same value twice
  /// in a row, exactly as a die may roll the same face twice.
  List<MovementChoice> availableGaits(Player player) => const [
    MovementChoice(1),
    MovementChoice(2),
    MovementChoice(3),
    MovementChoice(4),
    MovementChoice(5),
    MovementChoice(6),
  ];

  /// Indices of horses still in play: anything not already arrived. What
  /// each can do with a given card is [legalMoves]' business.
  List<int> movableHorses(Player player) => [
    for (var i = 0; i < player.horses.length; i++)
      if (!player.horses[i].isFinished) i,
  ];

  /// Everything the current player may do with [card] — the classic
  /// rules, applied to every horse:
  ///
  /// * a horse in the stable comes out only on a 6, and lands on its
  ///   start square (the move is the exit itself);
  /// * a horse on the course rides exactly the card's value;
  /// * a horse that has arrived is done;
  /// * no move may end on a square held by one of the player's own
  ///   horses — the destination is simply not available.
  ///
  /// Returns an empty list when nothing can move: the turn then passes.
  List<LegalMove> legalMoves(GameState state, MovementChoice card) {
    final player = state.currentPlayer;
    final circuit = state.circuit;
    final teamIndex = state.currentPlayerIndex;
    final entry = circuit.entryIndexForTeam(teamIndex);
    final moves = <LegalMove>[];

    for (var i = 0; i < player.horses.length; i++) {
      final horse = player.horses[i];
      if (horse.isFinished) continue;
      final exits = horse.isHome;
      if (exits && !card.opensStable) continue;

      final destination = _destinationFor(
        horse.position,
        card.steps,
        entry,
        circuit,
      );
      if (_ownHorseAt(player, destination, except: i)) continue;

      final capture = _captureAt(
        state,
        player.id,
        destination,
        fromStable: exits,
      );
      moves.add(
        LegalMove(
          horseIndex: i,
          exitsStable: exits,
          destination: destination,
          effect: destination is TrackPosition
              ? circuit.effectAt(destination.index)
              : CellEffect.plain,
          capturesOpponent: capture != null,
          reachesFinish: destination is FinishedPosition,
        ),
      );
    }
    return moves;
  }

  /// Step 1 of a turn: the card is on the table. Decides what kind of
  /// turn this is — a choice between horses, a single obvious move, or
  /// nothing at all — and records the 6's second draw right away, so it
  /// is earned by the draw and never lost to a wrong answer.
  ///
  /// Committing the move itself is [commitGait]; a turn with several
  /// options waits in [TurnPhase.choosingHorse] for it, a turn with one
  /// option is committed by the caller straight away, and a turn with
  /// none sits in [TurnPhase.noMove] until [endTurn].
  GameState drawCard(GameState state, MovementChoice card) {
    final moves = legalMoves(state, card);
    return state.copyWith(
      drawnCard: card,
      drawCount: state.drawCount + 1,
      extraTurn: state.extraTurn || card.grantsExtraTurn,
      turnPhase: moves.isEmpty ? TurnPhase.noMove : TurnPhase.choosingHorse,
      lastMoveOutcome: moves.isEmpty ? MoveOutcome.noLegalMove : null,
      updatedAt: DateTime.now(),
    );
  }

  /// Horses that have reached the finish and still owe their "Question du
  /// voyage" before the arrival counts (spec §10).
  List<int> horsesAwaitingJourneyQuestion(Player player) => [
    for (var i = 0; i < player.horses.length; i++)
      if (player.horses[i].awaitingJourneyQuestion) i,
  ];

  /// What *would* happen — shown before the player commits, so the choice
  /// is always informed and never a gamble (spec §7).
  GaitPreview previewGait(
    GameState state,
    int horseIndex,
    MovementChoice choice, {
    bool useGrandGallop = false,
  }) {
    final circuit = state.circuit;
    final player = state.currentPlayer;
    final teamIndex = state.players.indexOf(player);
    final entry = circuit.entryIndexForTeam(teamIndex);
    final horse = player.horses[horseIndex];

    final bonus = useGrandGallop && player.rewards.hasGrandGallop ? 2 : 0;
    final destination = _destinationFor(
      horse.position,
      choice.steps + bonus,
      entry,
      circuit,
    );

    final capture = _captureAt(state, player.id, destination);
    return GaitPreview(
      choice: choice,
      horseIndex: horseIndex,
      destination: destination,
      effect: destination is TrackPosition
          ? circuit.effectAt(destination.index)
          : CellEffect.plain,
      capturesOpponent: capture != null,
      reachesFinish: destination is FinishedPosition,
      usesGrandGallop: bonus > 0,
    );
  }

  // ---------------------------------------------------------------------
  // Turn flow
  // ---------------------------------------------------------------------

  /// Step 2 of a turn: the player commits the drawn card to one horse.
  /// This only *locks in* the choice — the card's question is answered
  /// next, and nothing moves until it is.
  ///
  /// A horse in the stable is committed as an exit: the card's value has
  /// opened the gate, and the horse will stand on its start square.
  GameState commitGait(
    GameState state,
    int horseIndex,
    MovementChoice choice, {
    bool useGrandGallop = false,
  }) {
    final horse = state.currentPlayer.horses[horseIndex];
    return state.copyWith(
      pendingGait: PendingGait(
        horseIndex: horseIndex,
        choice: choice,
        usesGrandGallop:
            useGrandGallop && state.currentPlayer.rewards.hasGrandGallop,
        exitsStable: horse.isHome,
      ),
      drawnCard: choice,
      // A card committed without a draw (the direct path the tests and
      // the empty-deck fallback use) still counts as one.
      drawCount: state.drawnCard == null
          ? state.drawCount + 1
          : state.drawCount,
      extraTurn: state.extraTurn || choice.grantsExtraTurn,
      turnPhase: TurnPhase.answeringQuestion,
      updatedAt: DateTime.now(),
    );
  }

  /// Step 3: resolves the answer. A correct answer makes the committed
  /// move happen — the horse comes out of the stable, or rides exactly
  /// the card's value; a wrong one leaves it where it stands. Either way
  /// the streak is updated.
  GameState applyAnswer(
    GameState state, {
    required bool correct,
    required String questionId,
  }) {
    final pending = state.pendingGait;
    if (pending == null) return state;

    final players = [...state.players];
    final playerIndex = state.currentPlayerIndex;
    var player = players[playerIndex];

    // The gait is consumed whether the answer was right or wrong.
    var rewards = player.rewards;
    var streak = player.streak;
    final unlocked = <StreakReward>[];

    if (correct) {
      final result = streak.recordCorrect();
      streak = result.streak;
      unlocked.addAll(result.unlocked);
      // Points follow the level the rider plays at, not the card: an
      // expert answer is worth three whatever distance it bought.
      rewards = rewards.copyWith(
        knowledgePoints:
            rewards.knowledgePoints + player.profile.knowledgePoints,
      );
    } else {
      streak = streak.recordIncorrect();
    }

    player = player.copyWith(streak: streak, rewards: rewards);
    players[playerIndex] = player;

    var next = state.copyWith(
      players: players,
      currentQuestionId: questionId,
      askedQuestionIds: {...state.askedQuestionIds, questionId},
      lastAnswerCorrect: correct,
      turnPhase: TurnPhase.showingFeedback,
      updatedAt: DateTime.now(),
    );

    if (!correct) {
      // The horse stays exactly where it was; nothing else to resolve.
      return next.copyWith(
        pendingGait: null,
        lastMoveOutcome: MoveOutcome.stayed,
      );
    }

    next = _moveHorse(next, pending);
    next = _grantStreakRewards(next, unlocked, pending.horseIndex);
    return next;
  }

  /// Applies the committed movement, any capture, and the arrival rule.
  GameState _moveHorse(GameState state, PendingGait pending) {
    final circuit = state.circuit;
    final players = [...state.players];
    final playerIndex = state.currentPlayerIndex;
    var player = players[playerIndex];
    final teamIndex = playerIndex;
    final entry = circuit.entryIndexForTeam(teamIndex);

    final bonus = pending.usesGrandGallop ? 2 : 0;
    final horse = player.horses[pending.horseIndex];
    final destination = _destinationFor(
      horse.position,
      pending.choice.steps + bonus,
      entry,
      circuit,
    );

    final horses = [...player.horses];
    final reachedFinish = destination is FinishedPosition;
    horses[pending.horseIndex] = horse.copyWith(
      position: destination,
      awaitingJourneyQuestion: reachedFinish
          ? true
          : horse.awaitingJourneyQuestion,
    );

    var rewards = player.rewards;
    if (pending.usesGrandGallop) {
      rewards = rewards.copyWith(hasGrandGallop: false);
    }
    player = player.copyWith(horses: horses, rewards: rewards);
    players[playerIndex] = player;

    var outcome = reachedFinish
        ? MoveOutcome.reachedFinish
        : pending.exitsStable
        ? MoveOutcome.exitedStable
        : MoveOutcome.moved;

    // Capture: landing exactly on an opponent sends it home, unless the
    // square is an Oasis or the opponent carries a knowledge shield. A
    // horse leaving its stable captures on its own start square whatever
    // the square is: the oasis shelters riders passing through, never a
    // horse parked at somebody else's gate.
    final capture = _captureAt(
      state,
      player.id,
      destination,
      fromStable: pending.exitsStable,
    );
    if (capture != null) {
      final (opponentIndex, opponentHorseIndex) = capture;
      final opponent = players[opponentIndex];
      final opponentHorses = [...opponent.horses];
      final target = opponentHorses[opponentHorseIndex];
      if (target.hasShield) {
        // The shield absorbs the capture and is spent; the horse stays.
        opponentHorses[opponentHorseIndex] = target.copyWith(hasShield: false);
        outcome = MoveOutcome.blockedByShield;
      } else {
        opponentHorses[opponentHorseIndex] = target.copyWith(
          position: const HomePosition(),
          awaitingJourneyQuestion: false,
        );
        outcome = MoveOutcome.captured;
      }
      players[opponentIndex] = opponent.copyWith(horses: opponentHorses);
    }

    final effect = destination is TrackPosition
        ? circuit.effectAt(destination.index)
        : CellEffect.plain;

    final interactive = _isInteractive(effect);
    return state.copyWith(
      players: players,
      pendingGait: null,
      lastMoveOutcome: outcome,
      pendingCellEffect: interactive ? effect : null,
      pendingCellHorseIndex: interactive ? pending.horseIndex : null,
      landedEffect: effect,
      updatedAt: DateTime.now(),
    );
  }

  /// Cells that ask the player something. The rest apply silently.
  bool _isInteractive(CellEffect effect) => switch (effect) {
    CellEffect.challenge ||
    CellEffect.shortcut ||
    CellEffect.relay ||
    CellEffect.duel => true,
    _ => false,
  };

  GameState _grantStreakRewards(
    GameState state,
    List<StreakReward> unlocked,
    int horseIndex,
  ) {
    if (unlocked.isEmpty) return state;
    final players = [...state.players];
    final index = state.currentPlayerIndex;
    var player = players[index];
    var rewards = player.rewards;
    var horses = [...player.horses];

    for (final reward in unlocked) {
      switch (reward) {
        case StreakReward.shield:
          // Attach it straight to the horse that just moved — no extra
          // decision screen for a bonus that has only one sensible target.
          horses[horseIndex] = horses[horseIndex].copyWith(hasShield: true);
        case StreakReward.grandGallop:
          rewards = rewards.copyWith(hasGrandGallop: true);
        case StreakReward.masteryBadge:
          // The category is decided by the caller (it needs answer
          // history); the engine only records that one was earned.
          break;
      }
    }

    players[index] = player.copyWith(horses: horses, rewards: rewards);
    return state.copyWith(
      players: players,
      justUnlocked: unlocked,
      updatedAt: DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------
  // Interactive cells (all deterministic — the player always knows the
  // stake before accepting, and failing never causes a setback)
  // ---------------------------------------------------------------------

  /// The player declined the optional challenge/shortcut, or finished
  /// resolving a cell. Moves the turn along.
  GameState declineCellOffer(GameState state) => state.copyWith(
    pendingCellEffect: null,
    pendingCellHorseIndex: null,
    turnPhase: TurnPhase.turnComplete,
  );

  /// A Défi (challenge) cell: the player answered the optional harder
  /// question. Success adds 2 squares; failure costs only the bonus.
  GameState resolveChallenge(
    GameState state, {
    required bool correct,
    required String questionId,
  }) {
    var next = state.copyWith(
      askedQuestionIds: {...state.askedQuestionIds, questionId},
      pendingCellEffect: null,
      pendingCellHorseIndex: null,
    );
    if (!correct) {
      return next.copyWith(
        lastMoveOutcome: MoveOutcome.bonusMissed,
        turnPhase: TurnPhase.turnComplete,
      );
    }
    next = _advanceCurrentHorse(
      next,
      2,
      horseIndex: state.pendingCellHorseIndex,
    );
    return next.copyWith(
      lastMoveOutcome: MoveOutcome.bonusEarned,
      turnPhase: TurnPhase.turnComplete,
    );
  }

  /// A Raccourci (shortcut) cell: a hard question buys a jump forward.
  /// Failing leaves the horse exactly where it already stood.
  GameState resolveShortcut(
    GameState state, {
    required bool correct,
    required String questionId,
    required int horseIndex,
  }) {
    var next = state.copyWith(
      askedQuestionIds: {...state.askedQuestionIds, questionId},
      pendingCellEffect: null,
      pendingCellHorseIndex: null,
    );
    if (!correct) {
      return next.copyWith(
        lastMoveOutcome: MoveOutcome.bonusMissed,
        turnPhase: TurnPhase.turnComplete,
      );
    }
    next = _advanceCurrentHorse(
      next,
      state.circuit.shortcutJump,
      horseIndex: horseIndex,
    );
    return next.copyWith(
      lastMoveOutcome: MoveOutcome.bonusEarned,
      turnPhase: TurnPhase.turnComplete,
    );
  }

  /// A Relais cell: the player hands the squares they just earned to
  /// another of their own horses instead.
  GameState resolveRelay(
    GameState state, {
    required int fromHorseIndex,
    required int toHorseIndex,
    required int steps,
  }) {
    final circuit = state.circuit;
    final players = [...state.players];
    final index = state.currentPlayerIndex;
    final player = players[index];
    final entry = circuit.entryIndexForTeam(index);
    final horses = [...player.horses];

    // Give back the squares from the horse that moved…
    final from = horses[fromHorseIndex];
    final fromProgress = _progressOf(from.position, entry, circuit);
    if (fromProgress != null) {
      horses[fromHorseIndex] = from.copyWith(
        position: _positionAt(
          (fromProgress - steps).clamp(0, circuit.journeyLength),
          entry,
          circuit,
        ),
        awaitingJourneyQuestion: false,
      );
    }
    // …and hand them to the chosen one.
    final to = horses[toHorseIndex];
    final destination = _destinationFor(to.position, steps, entry, circuit);
    horses[toHorseIndex] = to.copyWith(
      position: destination,
      awaitingJourneyQuestion: destination is FinishedPosition
          ? true
          : to.awaitingJourneyQuestion,
    );

    players[index] = player.copyWith(horses: horses);
    return state.copyWith(
      players: players,
      pendingCellEffect: null,
      turnPhase: TurnPhase.turnComplete,
      updatedAt: DateTime.now(),
    );
  }

  /// A Duel cell: both players have answered a question of equal
  /// difficulty. The winner earns a shield; a tie changes nothing.
  GameState resolveDuel(
    GameState state, {
    required bool challengerCorrect,
    required bool opponentCorrect,
    required int opponentIndex,
    required int challengerHorseIndex,
  }) {
    if (challengerCorrect == opponentCorrect) {
      return state.copyWith(
        pendingCellEffect: null,
        turnPhase: TurnPhase.turnComplete,
      );
    }
    final players = [...state.players];
    final winnerIndex = challengerCorrect
        ? state.currentPlayerIndex
        : opponentIndex;
    final winner = players[winnerIndex];
    final horses = [...winner.horses];
    final horseIndex = challengerCorrect
        ? challengerHorseIndex
        : _mostAdvancedHorse(winner, state.circuit, winnerIndex);
    horses[horseIndex] = horses[horseIndex].copyWith(hasShield: true);
    players[winnerIndex] = winner.copyWith(horses: horses);

    return state.copyWith(
      players: players,
      pendingCellEffect: null,
      turnPhase: TurnPhase.turnComplete,
      updatedAt: DateTime.now(),
    );
  }

  /// Knowledge and Wisdom cells: the player keeps a sourced fact. Purely
  /// additive — no gameplay advantage beyond the knowledge point.
  GameState collectFact(GameState state, String factId, {int bonusPoints = 0}) {
    final players = [...state.players];
    final index = state.currentPlayerIndex;
    final player = players[index];
    players[index] = player.copyWith(
      rewards: player.rewards.copyWith(
        collectedFactIds: {...player.rewards.collectedFactIds, factId},
        knowledgePoints: player.rewards.knowledgePoints + bonusPoints,
      ),
    );
    return state.copyWith(players: players, updatedAt: DateTime.now());
  }

  // ---------------------------------------------------------------------
  // Arrival
  // ---------------------------------------------------------------------

  /// The "Question du voyage" that makes an arrival official (spec §10).
  /// A wrong answer never pushes the horse back — the player simply tries
  /// again on a later turn.
  GameState answerJourneyQuestion(
    GameState state, {
    required bool correct,
    required String questionId,
    required int horseIndex,
  }) {
    final players = [...state.players];
    final index = state.currentPlayerIndex;
    final player = players[index];

    var next = state.copyWith(
      askedQuestionIds: {...state.askedQuestionIds, questionId},
      currentQuestionId: questionId,
      lastAnswerCorrect: correct,
      updatedAt: DateTime.now(),
    );
    if (!correct) {
      return next.copyWith(turnPhase: TurnPhase.showingFeedback);
    }

    final horses = [...player.horses];
    horses[horseIndex] = horses[horseIndex].copyWith(
      awaitingJourneyQuestion: false,
    );
    players[index] = player.copyWith(horses: horses);
    next = next.copyWith(players: players);

    final winner = players[index];
    if (hasWon(next, winner)) {
      return next.copyWith(winnerId: winner.id, turnPhase: TurnPhase.gameOver);
    }
    return next.copyWith(turnPhase: TurnPhase.showingFeedback);
  }

  /// Whether [player] has brought home what the format asks for: one
  /// horse in a quick race, all four in the classic and family games —
  /// or every horse they have, for a table set with fewer.
  bool hasWon(GameState state, Player player) {
    final asked = state.gameVariant.horsesToWin;
    final owned = player.horses.length;
    return player.arrivedCount >= (asked < owned ? asked : owned);
  }

  // ---------------------------------------------------------------------
  // Turn hand-off
  // ---------------------------------------------------------------------

  /// Ends the current turn and hands over to the next player, unless the
  /// game is already won — or unless a 6 was drawn, in which case the
  /// same player draws again, exactly as a 6 on the die replays.
  ///
  /// A free-edition game also ends here once its [GameState.maxDraws]
  /// cards have been drawn: the leader wins, and the results board says
  /// what Premium removes. The last card is always played out first —
  /// nobody is cut off mid-ride.
  GameState endTurn(GameState state) {
    if (state.turnPhase == TurnPhase.gameOver) return state;

    final winner = state.players.where((p) => hasWon(state, p)).firstOrNull;
    if (winner != null) {
      return state.copyWith(
        winnerId: winner.id,
        turnPhase: TurnPhase.gameOver,
        updatedAt: DateTime.now(),
      );
    }

    final limit = state.maxDraws;
    if (limit != null && state.drawCount >= limit) {
      return state.copyWith(
        winnerId: leader(state).id,
        turnPhase: TurnPhase.gameOver,
        endedByDrawLimit: true,
        drawnCard: null,
        extraTurn: false,
        updatedAt: DateTime.now(),
      );
    }

    final replays = state.extraTurn;
    final nextIndex = replays
        ? state.currentPlayerIndex
        : (state.currentPlayerIndex + 1) % state.players.length;
    return state.copyWith(
      currentPlayerIndex: nextIndex,
      turnPhase: TurnPhase.selectingGait,
      currentQuestionId: null,
      pendingGait: null,
      pendingCellEffect: null,
      pendingCellHorseIndex: null,
      landedEffect: null,
      lastAnswerCorrect: null,
      lastMoveOutcome: null,
      justUnlocked: const [],
      drawnCard: null,
      extraTurn: false,
      isBonusTurn: replays,
      updatedAt: DateTime.now(),
    );
  }

  /// Who is ahead right now: most horses arrived, then the longest total
  /// ride, then the most knowledge points. Decides a game the free
  /// edition stops before anyone reaches Mecca.
  Player leader(GameState state) {
    final circuit = state.circuit;
    int arrived(Player p) => p.horses.where((h) => h.hasArrived).length;
    int ridden(Player p, int team) {
      var total = 0;
      for (final h in p.horses) {
        total += circuit.progressOf(h.position, team) ?? 0;
      }
      return total;
    }

    var best = state.players.first;
    var bestKey = (
      arrived(best),
      ridden(best, 0),
      best.rewards.knowledgePoints,
    );
    for (var i = 1; i < state.players.length; i++) {
      final p = state.players[i];
      final key = (arrived(p), ridden(p, i), p.rewards.knowledgePoints);
      if (key.$1 > bestKey.$1 ||
          (key.$1 == bestKey.$1 && key.$2 > bestKey.$2) ||
          (key.$1 == bestKey.$1 &&
              key.$2 == bestKey.$2 &&
              key.$3 > bestKey.$3)) {
        best = p;
        bestKey = key;
      }
    }
    return best;
  }

  // ---------------------------------------------------------------------
  // Geometry helpers — progress along a horse's own journey
  // ---------------------------------------------------------------------

  GameState _advanceCurrentHorse(
    GameState state,
    int steps, {
    int? horseIndex,
  }) {
    final circuit = state.circuit;
    final players = [...state.players];
    final index = state.currentPlayerIndex;
    var player = players[index];
    final entry = circuit.entryIndexForTeam(index);
    final target = horseIndex ?? _mostAdvancedHorse(player, circuit, index);
    // A finished arrival is final: a bonus can never touch (or worse,
    // un-validate) a horse that already reached the oasis.
    if (target < 0 || player.horses[target].position is FinishedPosition) {
      return state;
    }

    final horses = [...player.horses];
    final destination = _destinationFor(
      horses[target].position,
      steps,
      entry,
      circuit,
    );
    horses[target] = horses[target].copyWith(
      position: destination,
      awaitingJourneyQuestion: destination is FinishedPosition
          ? true
          : horses[target].awaitingJourneyQuestion,
    );
    player = player.copyWith(horses: horses);
    players[index] = player;
    var next = state.copyWith(players: players, updatedAt: DateTime.now());

    // Bonus movement obeys the same board rules as a normal move:
    // landing on an unprotected opponent captures it.
    final capture = _captureAt(next, player.id, destination);
    if (capture != null) {
      final (oi, ohi) = capture;
      final opponent = players[oi];
      final oh = [...opponent.horses];
      if (oh[ohi].hasShield) {
        oh[ohi] = oh[ohi].copyWith(hasShield: false);
      } else {
        oh[ohi] = oh[ohi].copyWith(
          position: const HomePosition(),
          awaitingJourneyQuestion: false,
        );
      }
      players[oi] = opponent.copyWith(horses: oh);
      next = next.copyWith(players: players, updatedAt: DateTime.now());
    }
    return next;
  }

  /// The farthest horse still on the road; -1 if every horse is home dry.
  int _mostAdvancedHorse(Player player, Circuit circuit, int teamIndex) {
    final entry = circuit.entryIndexForTeam(teamIndex);
    var best = -1;
    var bestProgress = -1;
    for (var i = 0; i < player.horses.length; i++) {
      if (player.horses[i].position is FinishedPosition) continue;
      final p = _progressOf(player.horses[i].position, entry, circuit) ?? -1;
      if (p > bestProgress) {
        bestProgress = p;
        best = i;
      }
    }
    return best;
  }

  /// Where a horse ends up after [steps] squares. A horse leaving the
  /// stable lands on its start square whatever the card: the exit IS the
  /// move, as in the original game. Overshooting the finish is allowed —
  /// the horse simply arrives (spec §10).
  PawnPosition _destinationFor(
    PawnPosition from,
    int steps,
    int entry,
    Circuit circuit,
  ) {
    final progress = _progressOf(from, entry, circuit);
    if (progress == null) return _positionAt(0, entry, circuit);
    return _positionAt(progress + steps, entry, circuit);
  }

  /// Whether one of [player]'s own horses (other than [except]) already
  /// stands on [destination]. Arrived horses share the centre freely;
  /// everywhere else a square holds one horse of a colour.
  bool _ownHorseAt(
    Player player,
    PawnPosition destination, {
    required int except,
  }) {
    if (destination is FinishedPosition) return false;
    for (var h = 0; h < player.horses.length; h++) {
      if (h != except && player.horses[h].position == destination) return true;
    }
    return false;
  }

  /// How far along its own journey a horse stands, or null if still in the
  /// stable.
  int? _progressOf(PawnPosition position, int entry, Circuit circuit) =>
      switch (position) {
        HomePosition() => null,
        TrackPosition(:final index) => (index - entry) % circuit.trackLength,
        FinalLanePosition(:final step) => circuit.trackLength + step - 1,
        FinishedPosition() => circuit.journeyLength,
      };

  PawnPosition _positionAt(int progress, int entry, Circuit circuit) {
    if (progress >= circuit.journeyLength) return const FinishedPosition();
    if (progress >= circuit.trackLength) {
      return FinalLanePosition(progress - circuit.trackLength + 1);
    }
    return TrackPosition((entry + progress) % circuit.trackLength);
  }

  /// The opponent horse standing exactly on [destination], if it can be
  /// captured there. Oasis squares and the private final lane are safe —
  /// except from a horse coming out of its stable, whose start square is
  /// its own gate ([fromStable]).
  (int, int)? _captureAt(
    GameState state,
    String movingPlayerId,
    PawnPosition destination, {
    bool fromStable = false,
  }) {
    if (destination is! TrackPosition) return null;
    if (!fromStable && state.circuit.isSafe(destination.index)) return null;
    for (var p = 0; p < state.players.length; p++) {
      final other = state.players[p];
      if (other.id == movingPlayerId) continue;
      for (var h = 0; h < other.horses.length; h++) {
        if (other.horses[h].position == destination) return (p, h);
      }
    }
    return null;
  }
}

/// What a gait would do, shown before the player commits.
class GaitPreview {
  const GaitPreview({
    required this.choice,
    required this.horseIndex,
    required this.destination,
    required this.effect,
    required this.capturesOpponent,
    required this.reachesFinish,
    required this.usesGrandGallop,
  });

  final MovementChoice choice;
  final int horseIndex;
  final PawnPosition destination;
  final CellEffect effect;
  final bool capturesOpponent;
  final bool reachesFinish;
  final bool usesGrandGallop;
}

/// One thing the drawn card can do: which horse, where it lands, and
/// what it would meet there — enough for a player to choose, and for the
/// board to show the ride before it happens.
class LegalMove {
  const LegalMove({
    required this.horseIndex,
    required this.exitsStable,
    required this.destination,
    required this.effect,
    required this.capturesOpponent,
    required this.reachesFinish,
  });

  final int horseIndex;

  /// The horse is in the stable and the card opens the gate.
  final bool exitsStable;

  final PawnPosition destination;
  final CellEffect effect;
  final bool capturesOpponent;
  final bool reachesFinish;
}
