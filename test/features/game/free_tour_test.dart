// Le « tour des cartes gratuites » : quand un joueur gratuit a vu passer
// chacune des cartes gratuites, la partie le lui dit — une fois — et lui
// montre la porte de Premium. Un joueur Premium n'a pas de tour à faire.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/game/application/game_controller.dart';
import 'package:iqraquest/features/game/domain/game_engine.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/services/game_save_service.dart';
import 'package:iqraquest/services/local_storage_service.dart';
import 'package:iqraquest/services/progress_service.dart';
import 'package:iqraquest/services/question_repository.dart';
import 'package:iqraquest/theme/app_team.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<({GameController controller, ProgressService progress, Set<String> freeIds})>
harness({required bool premium, Set<String> seen = const {}}) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await LocalStorageService.create();
  final repo = QuestionRepository();
  final pool = await repo.loadAll('en');
  final progress = ProgressService(storage);
  await progress.markSeen(seen);
  final controller = GameController(
    engine: const GameEngine(),
    questionRepository: repo,
    saveService: GameSaveService(storage),
    progressService: progress,
    random: Random(7),
    animate: false,
  );
  controller.configure(pool: pool, isPremium: premium);
  controller.startNewGame(
    mode: GameMode.family,
    variant: GameVariant.classic,
    circuitId: CircuitId.oasisRoute,
    players: [
      Player(
        id: 'p0',
        name: 'A',
        team: AppTeam.emerald,
        horses: const [HorseState(), HorseState()],
      ),
      Player(
        id: 'p1',
        name: 'B',
        team: AppTeam.saphir,
        horses: const [HorseState(), HorseState()],
      ),
    ],
  );
  return (
    controller: controller,
    progress: progress,
    freeIds: {for (final q in pool) if (q.isFree) q.id},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('la banque gratuite existe, et elle est plus petite que la banque', () async {
    final h = await harness(premium: false);
    expect(h.freeIds.length, greaterThan(0));
    expect(h.controller.freeBankSize, h.freeIds.length);
    expect(h.controller.bankSize, greaterThan(h.controller.freeBankSize));
    h.controller.dispose();
  });

  test('tout vu : le signal part à la première carte, une seule fois', () async {
    final h0 = await harness(premium: false);
    final h = await harness(premium: false, seen: h0.freeIds);
    expect(h.controller.state!.freeTourJustCompleted, isFalse, reason: 'rien avant la première carte');
    h.controller.drawCard();
    expect(h.controller.state!.freeTourJustCompleted, isTrue);
    h.controller.acknowledgeFreeTour();
    expect(h.controller.state!.freeTourJustCompleted, isFalse);
    // La partie continue ; le signal ne revient pas à chaque carte.
    h.controller.answerQuestion(0);
    h.controller.continueAfterFeedback();
    expect(h.controller.state!.freeTourJustCompleted, isFalse);
    h0.controller.dispose();
    h.controller.dispose();
  });

  test('une carte jamais vue manque : pas de signal, et la carte est retenue', () async {
    final h0 = await harness(premium: false);
    final missing = h0.freeIds.first;
    final h = await harness(premium: false, seen: h0.freeIds.difference({missing}));
    h.controller.drawCard();
    final drawn = h.controller.state!.currentQuestion!.id;
    expect(h.progress.seenQuestionIds(), contains(drawn), reason: 'la carte tirée est retenue');
    expect(
      h.controller.state!.freeTourJustCompleted,
      drawn == missing,
      reason: 'le signal ne part que si la carte manquante vient d\'être vue',
    );
    h0.controller.dispose();
    h.controller.dispose();
  });

  test('un joueur Premium ne voit jamais le signal, et rien n\'est retenu', () async {
    final h0 = await harness(premium: false);
    final h = await harness(premium: true, seen: h0.freeIds);
    h.controller.drawCard();
    expect(h.controller.state!.freeTourJustCompleted, isFalse);
    expect(h.progress.seenQuestionIds(), h0.freeIds, reason: 'Premium ne compte pas ses cartes');
    h0.controller.dispose();
    h.controller.dispose();
  });
}
