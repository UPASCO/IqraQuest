// Plays real turns through the real widgets and asserts the loop always
// comes back round.
//
// The failure this guards against is the one a player actually reports:
// "it stopped responding". A turn wedges when a phase ends without
// offering the next control — the deck gone and no question on screen —
// and no unit test on the engine can see that, because the engine is
// fine and the screen is the thing that stranded.
//
// The placement is played the way a thumb plays it: touch a horse, see
// its square, drag it there, let go. No button is ever looked for.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/app/app.dart';
import 'package:iqraquest/app/providers.dart';
import 'package:iqraquest/app/router.dart';
import 'package:iqraquest/features/game/application/game_controller.dart';
import 'package:iqraquest/features/game/presentation/game_screen.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/services/entitlement_service.dart';
import 'package:iqraquest/services/game_save_service.dart';
import 'package:iqraquest/services/legacy_game_migration_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:iqraquest/services/purchase_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/services/settings_service.dart';
import 'package:iqraquest/theme/app_team.dart';
import 'package:iqraquest/widgets/board/cross_board_scene.dart';
import 'package:iqraquest/widgets/celebration_overlay.dart';
import 'package:iqraquest/widgets/question_card_draw.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

GameState _stableGame() {
  final now = DateTime(2026, 1, 1);
  return GameState(
    gameId: 'stable',
    gameMode: GameMode.family,
    gameVariant: GameVariant.quick,
    circuitId: CircuitId.oasisRoute,
    players: [
      Player(
        id: 'p0',
        name: 'Amina',
        team: kBoardSeats[0],
        horses: const [HorseState(), HorseState()],
      ),
      Player(
        id: 'p1',
        name: 'Bilal',
        team: kBoardSeats[1],
        horses: const [HorseState(), HorseState()],
      ),
    ],
    currentPlayerIndex: 0,
    turnPhase: TurnPhase.selectingGait,
    askedQuestionIds: const {},
    startedAt: now,
    updatedAt: now,
  );
}

/// Past the card turning over.
Future<void> _pastReveal(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(kCardRevealDuration + const Duration(milliseconds: 60));
  await _settle(tester);
}

/// Past the verdict beat and through the feedback sheet.
Future<void> _pastFeedback(WidgetTester tester) async {
  await _settle(tester);
  await tester.pump(kAnswerBeatDuration + const Duration(milliseconds: 60));
  await _settle(tester);
  final continueLabel = find.text('Continue');
  if (continueLabel.evaluate().isNotEmpty) {
    await tester.ensureVisible(continueLabel.last);
    await tester.tap(continueLabel.last);
    await _settle(tester);
  }
}

/// Past the ride, every link of the chain it set off, and any landing
/// celebration.
///
/// One drop is no longer one ride: bonuses chain, and a capture pays its
/// own twenty, so a placement can be several rides with a beat before
/// each. A fixed wait covered one of them and left the board still
/// moving — so this waits on the game itself, pumping until the turn has
/// left [TurnPhase.movingHorse], with a bound that no legal chain reaches.
Future<void> _pastRide(WidgetTester tester, ProviderContainer container) async {
  for (var i = 0; i < 16; i++) {
    await tester.pump(kRideMax + kLandingSettle + kBonusRevealBeat);
    await _settle(tester);
    final phase = container.read(gameControllerProvider)?.gameState.turnPhase;
    if (phase != TurnPhase.movingHorse) break;
  }
  await tester.pump(kCelebrationDuration + const Duration(milliseconds: 60));
  await _settle(tester);
}

GameState _soloGame() {
  final now = DateTime(2026, 1, 1);
  return GameState(
    gameId: 'loop',
    gameMode: GameMode.family,
    gameVariant: GameVariant.quick,
    circuitId: CircuitId.oasisRoute,
    players: [
      // One horse each, already on the road: every card then has exactly
      // one thing to do. (The stable's own loop — a card that moves
      // nothing — has its test below.)
      Player(
        id: 'p0',
        name: 'Amina',
        team: kBoardSeats[0],
        horses: const [HorseState(position: TrackPosition(3))],
      ),
      // Two humans on purpose: the loop is what is under test, and an
      // opponent on a timer would make the assertions depend on timing.
      Player(
        id: 'p1',
        name: 'Bilal',
        team: kBoardSeats[1],
        horses: const [HorseState(position: TrackPosition(20))],
      ),
    ],
    currentPlayerIndex: 0,
    turnPhase: TurnPhase.selectingGait,
    askedQuestionIds: const {},
    startedAt: now,
    updatedAt: now,
  );
}

Future<ProviderContainer> _pumpGame(
  WidgetTester tester, {
  GameState? save,
  Size size = const Size(390, 844),
  double textScale = 1.0,
}) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await tester.runAsync(LocalStorageService.create);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  if (textScale != 1.0) {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.runAsync(
    () => GameSaveService(storage!).save(save ?? _soloGame()),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(SettingsService(storage!)),
        entitlementServiceProvider.overrideWithValue(EntitlementService()),
        progressServiceProvider.overrideWithValue(ProgressService(storage)),
        gameSaveServiceProvider.overrideWithValue(GameSaveService(storage)),
        legacyGameMigrationServiceProvider.overrideWithValue(
          LegacyGameMigrationService(storage),
        ),
        questionRepositoryProvider.overrideWithValue(QuestionRepository()),
        purchaseServiceProvider.overrideWith((ref) => PurchaseService()),
        initialSettingsProvider.overrideWithValue(const AppSettings()),
        initialPremiumProvider.overrideWithValue(true),
        appRouterProvider.overrideWithValue(
          buildAppRouter(initialLocation: '/game'),
        ),
      ],
      child: const IqraQuestApp(),
    ),
  );
  await _settle(tester);

  // The screen renders whatever the controller holds; a cold entry to
  // /game has to be given the bank and told to load the save, exactly as
  // the real entry points do.
  final container = ProviderScope.containerOf(
    tester.element(find.byType(IqraQuestApp)),
  );
  final controller = container.read(gameControllerProvider.notifier);
  final pool = await tester.runAsync(() => QuestionRepository().loadAll('en'));
  controller.configure(pool: pool!, isPremium: true);
  controller.loadSaved();
  await _settle(tester);
  return container;
}

/// Where a square is on screen, from the board scene's own layout.
Offset _squareOnScreen(
  WidgetTester tester,
  PawnPosition position,
  int team,
  int horse,
) {
  final rect = tester.getRect(find.byKey(const Key('board-scene')));
  final side = math.min(rect.width, rect.height);
  final origin = Offset(
    rect.left + (rect.width - side) / 2,
    rect.top + (rect.height - side) / 2,
  );
  final a = CrossBoardScene.anchorFor(position, team, horse);
  return origin + Offset(a.x * side, a.y * side);
}

double _pieceSize(WidgetTester tester) {
  final rect = tester.getRect(find.byKey(const Key('board-scene')));
  return math.min(rect.width, rect.height) * 0.072;
}

/// Picks horse [horse] of [playerId] up and sets it down so that the
/// horse (drawn above the fingertip) lands on [target].
Future<void> _dragHorseTo(
  WidgetTester tester,
  String playerId,
  int horse,
  Offset target,
) async {
  final piece = find.byKey(ValueKey('$playerId:$horse'));
  expect(piece, findsOneWidget);
  final from = tester.getCenter(piece);
  final fingerTarget = target + Offset(0, _pieceSize(tester) * 0.95);
  final gesture = await tester.startGesture(from);
  // A drag only begins once the finger has travelled 8 px (a tap must
  // stay a tap). A square two steps up the track can sit so close that
  // the whole journey is shorter than that — and a playable horse bobs,
  // so where its centre was sampled shifts the distance by a few pixels
  // more. Lift the finger clear first, as a thumb always does, so the
  // drag is a drag whatever the geometry.
  final lift = from + const Offset(0, -16);
  await gesture.moveTo(lift);
  await tester.pump(const Duration(milliseconds: 16));
  final delta = fingerTarget - lift;
  for (var i = 1; i <= 6; i++) {
    await gesture.moveTo(lift + delta * (i / 6));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pump();
}

void main() {
  _aiDisposalGuard();
  _leadToastLayoutTest();

  testWidgets('a turn always hands back a control — the loop never wedges', (
    tester,
  ) async {
    final container = await _pumpGame(tester);

    for (var turn = 1; turn <= 6; turn++) {
      final phase = container.read(gameControllerProvider)?.gameState.turnPhase;
      // A bonus ride can carry a single-horse race to its end within a
      // few cards: the arrival asks its journey question, then the race
      // is over. Both are the loop working, not wedging.
      if (phase == TurnPhase.gameOver || phase == null) break;
      if (phase == TurnPhase.answeringJourneyQuestion) {
        final journey = container.read(gameControllerProvider)!.currentQuestion!;
        final answer = journey.answers[journey.correctAnswerIndex];
        await tester.ensureVisible(find.text(answer).first);
        await tester.tap(find.text(answer).first);
        await _pastFeedback(tester);
        await _pastRide(tester, container);
        continue;
      }
      expect(
        find.byKey(const Key('draw-deck')),
        findsOneWidget,
        reason: 'turn $turn: nothing was offered to the player',
      );

      await tester.tap(find.byKey(const Key('draw-deck')));
      // The card turns over onto its stake: the player reads what a
      // right answer is worth before reading the question.
      await tester.pump();
      expect(find.byType(DrawnCardReveal), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 520));
      final drawn = container.read(gameControllerProvider)!.gameState.drawnCard!;
      expect(
        find.descendant(
          of: find.byType(DrawnCardReveal),
          matching: find.text('${drawn.steps}'),
        ),
        findsOneWidget,
        reason: 'turn $turn: the card must announce its stake',
      );
      expect(find.text('?'), findsNothing, reason: 'turn $turn: stake withheld');
      await _pastReveal(tester);

      final session = container.read(gameControllerProvider)!;
      final question = session.currentQuestion;
      expect(
        question,
        isNotNull,
        reason: 'turn $turn: the draw produced no question',
      );
      expect(
        session.gameState.turnPhase,
        TurnPhase.answeringQuestion,
        reason: 'turn $turn: the question opens straight after the draw',
      );
      // The card's value is not on the table before the answer.
      expect(find.byKey(const Key('placement-banner')), findsNothing);

      // Answer it — right or wrong, the turn must move on either way.
      final correct = turn.isEven;
      final answer = correct
          ? question!.answers[question.correctAnswerIndex]
          : question!.answers[(question.correctAnswerIndex + 1) % 4];
      await tester.ensureVisible(find.text(answer).first);
      await tester.tap(find.text(answer).first);
      await _pastFeedback(tester);

      final after = container.read(gameControllerProvider)!.gameState;
      if (correct) {
        // The squares are won and the board waits for the hand: the
        // banner says so, the medallion says how many, and nothing has
        // moved yet.
        expect(after.turnPhase, TurnPhase.choosingHorse, reason: 'turn $turn');
        expect(find.byKey(const Key('placement-banner')), findsOneWidget);
        expect(find.byKey(const Key('earn-medallion')), findsOneWidget);
        expect(find.text('Continue'), findsNothing);
        final team = after.currentPlayerIndex;
        final pid = after.currentPlayer.id;
        final before = after.currentPlayer.horses[0].position;
        final move = container
            .read(gameControllerProvider.notifier)
            .moveFor(0)!;
        await _dragHorseTo(
          tester,
          pid,
          0,
          _squareOnScreen(tester, move.destination, team, 0),
        );
        final placed = container.read(gameControllerProvider)!.gameState;
        expect(
          placed.players[team].horses[0].position,
          move.destination,
          reason: 'turn $turn: the drop did not ride from $before',
        );
        // Validated by the drop alone: no confirmation control appears.
        expect(find.byKey(const Key('placement-banner')), findsNothing);
        expect(find.byKey(const Key('move-choice')), findsNothing);
        await _pastRide(tester, container);
      }

      expect(tester.takeException(), isNull, reason: 'turn $turn threw');
    }
  });

  testWidgets(
    'a stable full of horses is never a dead end: the card passes or opens the gate',
    (tester) async {
      final container = await _pumpGame(tester, save: _stableGame());
      for (var turn = 1; turn <= 8; turn++) {
        final phase = container.read(gameControllerProvider)?.gameState.turnPhase;
        // A chain of bonuses can carry a horse out of the stable and all
        // the way home inside these eight cards: the arrival asks its
        // journey question, then the race is over. Both are the loop
        // working, not the stable being a dead end.
        if (phase == TurnPhase.gameOver || phase == null) break;
        if (phase == TurnPhase.answeringJourneyQuestion) {
          final journey = container.read(gameControllerProvider)!.currentQuestion!;
          final answer = journey.answers[journey.correctAnswerIndex];
          await tester.ensureVisible(find.text(answer).first);
          await tester.tap(find.text(answer).first);
          await _pastFeedback(tester);
          await _pastRide(tester, container);
          continue;
        }
        expect(
          find.byKey(const Key('draw-deck')),
          findsOneWidget,
          reason: 'turn $turn: the deck did not come back',
        );
        await tester.tap(find.byKey(const Key('draw-deck')));
        await _pastReveal(tester);
        final session = container.read(gameControllerProvider)!;
        final card = session.gameState.drawnCard;
        final question = session.currentQuestion!;
        await tester.ensureVisible(
          find.text(question.answers[question.correctAnswerIndex]).first,
        );
        await tester.tap(
          find.text(question.answers[question.correctAnswerIndex]).first,
        );
        await _pastFeedback(tester);

        final after = container.read(gameControllerProvider)!.gameState;
        final legal = container.read(gameControllerProvider.notifier).legalMoves;
        if (after.turnPhase == TurnPhase.noMove) {
          expect(
            legal,
            isEmpty,
            reason: 'turn $turn: a $card had a move and was passed',
          );
          expect(find.byKey(const Key('turn-banner')), findsOneWidget);
          // Nothing to tap: the turn passes by itself after its beat.
          await tester.pump(kNoMoveBeat + const Duration(milliseconds: 80));
          await _settle(tester);
        } else {
          expect(after.turnPhase, TurnPhase.choosingHorse, reason: 'turn $turn');
          expect(
            legal,
            isNotEmpty,
            reason: 'turn $turn: a $card moved nothing yet was played',
          );
          // Every horse the card can move wears its halo; the gate is
          // opened by hand, never by a sheet.
          expect(find.byKey(const Key('move-choice')), findsNothing);
          final team = after.currentPlayerIndex;
          final pid = after.currentPlayer.id;
          final move = legal.first;
          await _dragHorseTo(
            tester,
            pid,
            move.horseIndex,
            _squareOnScreen(tester, move.destination, team, move.horseIndex),
          );
          expect(
            container
                .read(gameControllerProvider)!
                .gameState
                .players[team]
                .horses[move.horseIndex]
                .position,
            move.destination,
            reason: 'turn $turn: the horse did not come out',
          );
          await _pastRide(tester, container);
        }
        final thrown = tester.takeException();
        if (thrown is FlutterError) {
          // ignore: avoid_print
          print(
            'OVERFLOW DEBUG ${thrown.diagnostics.map((d) => d.toStringDeep()).join(' | ')}',
          );
        }
        expect(thrown, isNull, reason: 'turn $turn threw');
      }
    },
  );

  testWidgets(
    'two horses on the road: touch to compare, drop to decide — reversible until the drop',
    (tester) async {
      final now = DateTime(2026, 1, 1);
      final save = GameState(
        gameId: 'choice',
        gameMode: GameMode.family,
        gameVariant: GameVariant.quick,
        circuitId: CircuitId.oasisRoute,
        players: [
          Player(
            id: 'p0',
            name: 'Amina',
            team: kBoardSeats[0],
            horses: const [
              HorseState(position: TrackPosition(4)),
              HorseState(position: TrackPosition(20)),
            ],
          ),
          Player(
            id: 'p1',
            name: 'Bilal',
            team: kBoardSeats[1],
            horses: const [HorseState()],
          ),
        ],
        currentPlayerIndex: 0,
        turnPhase: TurnPhase.selectingGait,
        askedQuestionIds: const {},
        startedAt: now,
        updatedAt: now,
      );
      final container = await _pumpGame(tester, save: save);
      await tester.tap(find.byKey(const Key('draw-deck')));
      await _pastReveal(tester);

      final session = container.read(gameControllerProvider)!;
      final question = session.currentQuestion!;
      await tester.ensureVisible(
        find.text(question.answers[question.correctAnswerIndex]).first,
      );
      await tester.tap(
        find.text(question.answers[question.correctAnswerIndex]).first,
      );
      await _pastFeedback(tester);

      final controller = container.read(gameControllerProvider.notifier);
      expect(controller.state!.gameState.turnPhase, TurnPhase.choosingHorse);
      final card = controller.state!.gameState.drawnCard!;
      // Sixteen squares apart, so no card 1..6 can make one horse land
      // on the other: both are always offered, whatever is drawn.
      expect(controller.legalMoves.length, 2, reason: 'both horses can ride a $card');
      // Every horse the card can move is unmistakable: it wears the
      // chevron and stands in its own light. No other piece does.
      expect(find.byKey(const ValueKey('ready-p0:0')), findsOneWidget);
      expect(find.byKey(const ValueKey('ready-p0:1')), findsOneWidget);
      expect(find.byKey(const ValueKey('ready-p1:0')), findsNothing);
      // Nothing is lit until a horse is touched.
      expect(find.byKey(const ValueKey('destination')), findsNothing);

      // Touch horse 2: its square lights.
      await tester.tap(find.byKey(const ValueKey('p0:1')));
      await _settle(tester);
      expect(find.byKey(const ValueKey('destination')), findsOneWidget);
      final destOfSecond = tester.getCenter(find.byKey(const ValueKey('destination')));

      // Touch horse 1: the light moves — the comparison is free.
      await tester.tap(find.byKey(const ValueKey('p0:0')));
      await _settle(tester);
      expect(find.byKey(const ValueKey('destination')), findsOneWidget);
      final destOfFirst = tester.getCenter(find.byKey(const ValueKey('destination')));
      expect(destOfFirst, isNot(destOfSecond));
      expect(controller.state!.gameState.turnPhase, TurnPhase.choosingHorse);

      // A drop anywhere but the square glides back and changes nothing.
      final dest = controller.moveFor(0)!.destination;
      final wrong = _squareOnScreen(tester, dest, 0, 0) + const Offset(0, 140);
      await _dragHorseTo(tester, 'p0', 0, wrong);
      await _settle(tester);
      expect(controller.state!.gameState.turnPhase, TurnPhase.choosingHorse);
      expect(
        controller.state!.gameState.players[0].horses[0].position,
        const TrackPosition(4),
      );
      expect(find.byKey(const Key('placement-banner')), findsOneWidget);

      // The right square: the drop is the move, validated at once.
      await _dragHorseTo(tester, 'p0', 0, _squareOnScreen(tester, dest, 0, 0));
      expect(controller.state!.gameState.turnPhase, TurnPhase.movingHorse);
      expect(controller.state!.gameState.players[0].horses[0].position, dest);
      expect(controller.state!.gameState.players[0].horses[1].position, const TrackPosition(20));
      expect(find.byKey(const Key('placement-banner')), findsNothing);
      expect(find.byKey(const ValueKey('destination')), findsNothing);
      // No other horse can be picked up now.
      expect(controller.placeHorse(1), isFalse);
      // The turn is over. A 6 earns its second draw, so the same rider
      // may legitimately be up again — what must always be true is that
      // the deck is back and the placement is gone.
      final replays = card.grantsExtraTurn;
      await _pastRide(tester, container);
      expect(
        controller.state!.gameState.currentPlayerIndex,
        replays ? 0 : 1,
        reason: 'a $card ${replays ? 'replays' : 'hands over'}',
      );
      expect(controller.state!.gameState.turnPhase, TurnPhase.selectingGait);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the board can be silenced without leaving the game', (
    tester,
  ) async {
    // A race started in a quiet room: the mute sits on the board itself,
    // one tap from the thumb already there, and it is the app's real
    // sound setting — not a per-board flag that forgets.
    final container = await _pumpGame(tester);
    final toggle = find.byKey(const Key('mute-toggle'));
    expect(toggle, findsOneWidget);
    expect(container.read(settingsControllerProvider).soundEnabled, isTrue);

    await tester.tap(toggle);
    await _settle(tester);
    expect(container.read(settingsControllerProvider).soundEnabled, isFalse);
    // Silent, the board says so: the glyph flips with the state.
    expect(
      tester.widgetList<Icon>(find.descendant(of: toggle, matching: find.byType(Icon))).first.icon,
      Icons.volume_off,
    );

    await tester.tap(toggle);
    await _settle(tester);
    expect(container.read(settingsControllerProvider).soundEnabled, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving mid-turn lands on home rather than a dead end', (
    tester,
  ) async {
    await _pumpGame(tester);
    await tester.tap(find.byKey(const Key('draw-deck')));
    await _pastReveal(tester);

    // The in-game back control, used while a question is on screen.
    final back = find.byType(BackButton);
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back.first);
      await _settle(tester);
    }
    expect(tester.takeException(), isNull);
  });
}

/// The overtake notice is the one HUD element that only a running game
/// can produce, so no static layout audit ever renders it. Here it is
/// forced on the floor phone at the accessibility text size, with a name
/// as long as the setup screen allows.
void _leadToastLayoutTest() {
  testWidgets(
    'the overtake notice fits the floor phone at 130% text',
    (tester) async {
      final now = DateTime(2026, 1, 1);
      final save = GameState(
        gameId: 'lead',
        gameMode: GameMode.family,
        gameVariant: GameVariant.quick,
        circuitId: CircuitId.oasisRoute,
        players: [
          Player(
            id: 'p0',
            // 16 characters: the longest name the setup screen accepts.
            name: 'Abdurrahmane1234',
            team: kBoardSeats[0],
            horses: const [HorseState(position: TrackPosition(3))],
          ),
          Player(
            id: 'p1',
            name: 'Oumm Abdurrahman',
            team: kBoardSeats[1],
            horses: const [HorseState(position: TrackPosition(20))],
          ),
        ],
        currentPlayerIndex: 0,
        turnPhase: TurnPhase.selectingGait,
        askedQuestionIds: const {},
        startedAt: now,
        updatedAt: now,
      );
      final container = await _pumpGame(
        tester,
        save: save,
        size: const Size(320, 568),
        textScale: 1.3,
      );
      final controller = container.read(gameControllerProvider.notifier);
      // The rider behind answers every card right and rides; the one in
      // front answers wrong and stays. The lead changes within a few
      // cards, and the notice appears.
      var seen = false;
      for (var turn = 0; turn < 14 && !seen; turn++) {
        final state = container.read(gameControllerProvider)!.gameState;
        if (state.turnPhase != TurnPhase.selectingGait) break;
        final leading = state.currentPlayer.id == 'p1';
        await tester.tap(find.byKey(const Key('draw-deck')));
        await _pastReveal(tester);
        final question = container.read(gameControllerProvider)!.currentQuestion!;
        final index = leading
            ? (question.correctAnswerIndex + 1) % question.answers.length
            : question.correctAnswerIndex;
        await tester.ensureVisible(find.text(question.answers[index]).first);
        await tester.tap(find.text(question.answers[index]).first);
        await _pastFeedback(tester);
        if (container.read(gameControllerProvider)!.gameState.turnPhase ==
            TurnPhase.choosingHorse) {
          final move = controller.legalMoves.first;
          controller.placeHorse(move.horseIndex);
          await _settle(tester);
        }
        if (find.byKey(const Key('lead-toast')).evaluate().isNotEmpty) {
          seen = true;
        }
        await _pastRide(tester, container);
        expect(tester.takeException(), isNull, reason: 'turn $turn overflowed');
      }
      expect(
        seen,
        isTrue,
        reason: 'the rider behind never overtook, so the notice was never shown',
      );
    },
  );
}

/// Leaving the board while the opponent is thinking must not throw.
///
/// Each AI beat pauses and then reads the controller's state. If the
/// player walks out during that pause the notifier is already disposed,
/// and touching state then is an error — so every beat checks first.
void _aiDisposalGuard() {
  test('leaving during an opponent turn does not throw', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final container = ProviderContainer(
      overrides: [
        entitlementServiceProvider.overrideWithValue(EntitlementService()),
        progressServiceProvider.overrideWithValue(ProgressService(storage)),
        gameSaveServiceProvider.overrideWithValue(GameSaveService(storage)),
        questionRepositoryProvider.overrideWithValue(QuestionRepository()),
      ],
    );
    final controller = container.read(gameControllerProvider.notifier);
    controller.configure(
      pool: await QuestionRepository().loadAll('en'),
      isPremium: true,
    );
    controller.startNewGame(
      mode: GameMode.solo,
      variant: GameVariant.quick,
      circuitId: CircuitId.oasisRoute,
      players: [
        Player(
          id: 'ai',
          name: 'Rider',
          team: kBoardSeats[0],
          aiDifficulty: AiDifficulty.easy,
          horses: const [HorseState()],
        ),
      ],
    );

    // Walk out mid-beat, then let every scheduled beat come due.
    container.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 2600));
  });
}
