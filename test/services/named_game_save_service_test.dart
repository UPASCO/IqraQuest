// The shelf of games kept under a name: what a family relies on when it
// puts a race aside for the week. A save must come back exactly as it
// was, a name must mean one game, a full shelf must refuse rather than
// drop, and a bad row must never hide the good ones.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/game/application/game_controller.dart';
import 'package:iqraquest/features/game/domain/game_engine.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/services/game_save_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/named_game_save_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/theme/app_team.dart';
import 'package:shared_preferences/shared_preferences.dart';

GameState _game({
  String id = 'g1',
  DateTime? updatedAt,
  List<HorseState>? horses,
  GameMode mode = GameMode.solo,
}) {
  final now = DateTime(2026, 9, 7, 14, 32);
  return GameState(
    gameId: id,
    gameMode: mode,
    gameVariant: GameVariant.duo,
    circuitId: CircuitId.caravanTrail,
    players: [
      Player(
        id: 'human_0',
        name: 'Amina',
        team: AppTeam.emerald,
        horses: horses ?? const [HorseState(), HorseState()],
      ),
      Player(
        id: 'ai_0',
        name: 'Ordi 1',
        team: AppTeam.saphir,
        aiDifficulty: AiDifficulty.easy,
        horses: const [HorseState(), HorseState()],
      ),
    ],
    currentPlayerIndex: 0,
    turnPhase: TurnPhase.selectingGait,
    askedQuestionIds: const {'q1', 'q2'},
    bonusTiles: const [BonusTile(trackIndex: 5, value: 10)],
    bonusSeed: 4,
    drawCount: 7,
    startedAt: now,
    updatedAt: updatedAt ?? now,
  );
}

Future<NamedGameSaveService> _shelf() async =>
    NamedGameSaveService(await LocalStorageService.create(), random: Random(1));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a saved game comes back exactly as it was, with its card', () async {
    final shelf = await _shelf();
    final game = _game();

    final entry = await shelf.save(game, name: '  Papa   et Amina ');
    expect(entry, isNotNull);
    expect(entry!.name, 'Papa et Amina', reason: 'spacing is folded');
    expect(entry.gameId, 'g1');
    expect(entry.mode, GameMode.solo);
    expect(entry.variant, GameVariant.duo);
    expect(entry.circuitId, CircuitId.caravanTrail);
    expect(entry.riderNames, ['Amina', 'Ordi 1']);
    expect(entry.drawCount, 7);
    expect(entry.progress, 0, reason: 'every horse is still in the stable');

    final listed = shelf.list();
    expect(listed.map((s) => s.id), [entry.id]);

    final loaded = shelf.load(entry.id);
    expect(loaded, isNotNull);
    expect(loaded!.toJson(), game.toJson(), reason: 'nothing is lost in the round trip');
    expect(shelf.holds(game), isTrue);
  });

  test('the same name, however typed, is one save — not two', () async {
    final shelf = await _shelf();
    final first = await shelf.save(_game(), name: 'Papa');
    final later = _game(updatedAt: DateTime(2026, 9, 8));
    final second = await shelf.save(later, name: 'papa ');

    expect(second!.id, first!.id, reason: 'the row is replaced, not added');
    expect(shelf.list(), hasLength(1));
    expect(shelf.load(first.id)!.updatedAt, DateTime(2026, 9, 8));
    expect(shelf.byName('PAPA')?.id, first.id);
  });

  test('different names sit side by side, the latest first', () async {
    final shelf = await _shelf();
    final a = await shelf.save(_game(id: 'a'), name: 'Lundi');
    // A later clock, so the order does not depend on the same instant.
    await Future<void>.delayed(const Duration(milliseconds: 2));
    final b = await shelf.save(_game(id: 'b'), name: 'Mardi');

    expect(shelf.list().map((s) => s.id), [b!.id, a!.id]);
    expect(shelf.byGame('a')?.name, 'Lundi');
    expect(shelf.byGame('zzz'), isNull);
  });

  test('a game that moved on since it was kept is no longer held', () async {
    final shelf = await _shelf();
    final game = _game();
    await shelf.save(game, name: 'Papa');
    expect(shelf.holds(game), isTrue);

    final movedOn = game.copyWith(updatedAt: DateTime(2026, 9, 7, 15));
    expect(
      shelf.holds(movedOn),
      isFalse,
      reason: 'replacing it now would lose the turns since the save',
    );
  });

  test('deleting a save removes its row and its game', () async {
    final shelf = await _shelf();
    final entry = await shelf.save(_game(), name: 'Papa');
    await shelf.delete(entry!.id);

    expect(shelf.list(), isEmpty);
    expect(shelf.load(entry.id), isNull);
    expect(shelf.byName('Papa'), isNull);
  });

  test('a full shelf refuses a new name and still takes an old one', () async {
    final shelf = await _shelf();
    for (var i = 0; i < NamedGameSaveService.maxSaves; i++) {
      expect(await shelf.save(_game(id: 'g$i'), name: 'Partie $i'), isNotNull);
    }
    expect(shelf.isFull, isTrue);
    expect(shelf.list(), hasLength(NamedGameSaveService.maxSaves));

    expect(
      await shelf.save(_game(id: 'extra'), name: 'Une de trop'),
      isNull,
      reason: 'nothing is dropped to make room',
    );
    expect(shelf.list(), hasLength(NamedGameSaveService.maxSaves));

    final replaced = await shelf.save(_game(id: 'extra'), name: 'Partie 3');
    expect(replaced, isNotNull, reason: 'replacing an existing name is always allowed');
    expect(shelf.byName('Partie 3')!.gameId, 'extra');
  });

  test('a blank name is a programming error, never a nameless row', () async {
    final shelf = await _shelf();
    expect(() => shelf.save(_game(), name: '   '), throwsArgumentError);
    expect(shelf.list(), isEmpty);
  });

  test('a row this version cannot read hides nothing else', () async {
    final storage = await LocalStorageService.create();
    final shelf = NamedGameSaveService(storage, random: Random(1));
    final good = await shelf.save(_game(), name: 'Papa');

    // A future version's row, and a torn one, alongside the good one.
    final index = storage.getJson('iqraquest.saves.named.index.v1')!;
    final rows = (index['saves'] as List).toList();
    rows.add({'id': 'future', 'name': 'Demain', 'mode': 'coop'});
    rows.add('not even a map');
    await storage.setJson('iqraquest.saves.named.index.v1', {'saves': rows});

    expect(shelf.list().map((s) => s.id), [good!.id]);

    // And a torn game under a good row is reported, not thrown.
    await storage.setJson('iqraquest.saves.named.${good.id}.v1', {'gameId': 1});
    expect(shelf.load(good.id), isNull);
  });

  test('the progress on the card is the furthest human horse', () async {
    final shelf = await _shelf();
    final arrived = _game(
      horses: const [
        HorseState(position: FinishedPosition()),
        HorseState(),
      ],
    );
    final entry = await shelf.save(arrived, name: 'Presque');
    expect(entry!.progress, 1.0);
    expect(NamedGameSaveService.journeyProgress(_game()), 0);
  });

  test('a named save is rejoined by the controller and becomes the autosave', () async {
    final storage = await LocalStorageService.create();
    final saveService = GameSaveService(storage);
    final repo = QuestionRepository();
    final pool = await repo.loadAll('en');
    final controller = GameController(
      engine: const GameEngine(),
      questionRepository: repo,
      saveService: saveService,
      progressService: ProgressService(storage),
      random: Random(3),
      animate: false,
    );
    controller.configure(pool: pool, isPremium: true);

    final kept = _game(id: 'kept', mode: GameMode.family);
    final entry = await saveService.named.save(kept, name: 'Soirée');
    // Another game is under way meanwhile.
    controller.startNewGame(
      mode: GameMode.solo,
      variant: GameVariant.quick,
      circuitId: CircuitId.oasisRoute,
      players: kept.players,
    );
    expect(saveService.load()!.gameId, isNot('kept'));

    final ok = controller.resumeFrom(
      saveService.named.load(entry!.id)!,
      schema: entry.schemaVersion,
    );
    expect(ok, isTrue);
    expect(controller.state!.gameState.gameId, 'kept');
    expect(controller.state!.gameState.gameMode, GameMode.family);
    expect(
      saveService.load()!.gameId,
      'kept',
      reason: 'the loaded game is now the one the home screen continues',
    );
    // The shelf's copy is untouched: loading is not moving.
    expect(saveService.named.load(entry.id)!.gameId, 'kept');

    // A finished game is not rejoined.
    final over = kept.copyWith(turnPhase: TurnPhase.gameOver);
    expect(controller.resumeFrom(over), isFalse);
    controller.dispose();
  });
}
