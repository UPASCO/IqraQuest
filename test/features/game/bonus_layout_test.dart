import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/features/game/domain/bonus_layout.dart';
import 'package:iqraquest/features/game/domain/game_engine.dart';
import 'package:iqraquest/models/models.dart';
import 'package:iqraquest/theme/app_team.dart';

/// The bonus squares: dealt once per game, balanced by construction.
void main() {
  const seeds = [1, 2, 3, 7, 42, 99, 1234, 98765, 2026, 31337];

  group('BonusLayout.generate', () {
    for (final circuit in Circuit.all) {
      test('${circuit.id.name}: exactly 16 squares, 4 per quadrant', () {
        for (final seed in seeds) {
          final tiles = BonusLayout.generate(circuit, seed);
          expect(tiles.length, BonusLayout.tileCount, reason: 'seed $seed');
          for (var q = 0; q < 4; q++) {
            final inQuadrant = tiles.where(
              (t) => t.trackIndex ~/ circuit.squaresPerQuadrant == q,
            );
            expect(
              inQuadrant.length,
              BonusLayout.tilesPerQuadrant,
              reason: '${circuit.id.name} seed $seed quadrant $q',
            );
          }
          // Every index is a real square, and no square carries two.
          expect(tiles.map((t) => t.trackIndex).toSet().length, 16);
          for (final t in tiles) {
            expect(t.trackIndex, inInclusiveRange(0, circuit.trackLength - 1));
          }
        }
      });

      test('${circuit.id.name}: values are only 5, 10 or 20, and balanced', () {
        for (final seed in seeds) {
          final tiles = BonusLayout.generate(circuit, seed);
          for (final t in tiles) {
            expect(BonusTile.values, contains(t.value), reason: 'seed $seed');
          }
          int count(int v) => tiles.where((t) => t.value == v).length;
          expect(count(5), 8, reason: '+5 is the frequent one (seed $seed)');
          expect(count(10), 6, reason: '+10 is intermediate (seed $seed)');
          expect(count(20), 2, reason: '+20 is rare (seed $seed)');
          // Every quadrant is worth the same total: no corner is favoured.
          for (var q = 0; q < 4; q++) {
            final sum = tiles
                .where((t) => t.trackIndex ~/ circuit.squaresPerQuadrant == q)
                .fold<int>(0, (a, t) => a + t.value);
            expect(sum, 35, reason: 'seed $seed quadrant $q');
          }
        }
      });

      test('${circuit.id.name}: the two +20 sit in opposite quadrants', () {
        for (final seed in seeds) {
          final big = BonusLayout.generate(circuit, seed)
              .where((t) => t.value == 20)
              .map((t) => t.trackIndex ~/ circuit.squaresPerQuadrant)
              .toList();
          expect(big.length, 2);
          expect((big[0] - big[1]).abs(), 2, reason: 'seed $seed: $big');
        }
      });

      test('${circuit.id.name}: no two bonus squares are adjacent', () {
        for (final seed in seeds) {
          final indices = BonusLayout.generate(circuit, seed)
              .map((t) => t.trackIndex)
              .toList()
            ..sort();
          for (var i = 1; i < indices.length; i++) {
            expect(
              indices[i] - indices[i - 1],
              greaterThanOrEqualTo(2),
              reason: 'seed $seed: ${indices[i - 1]} and ${indices[i]} touch',
            );
          }
          // Across the end of the circuit too.
          final wrap = indices.first + circuit.trackLength - indices.last;
          expect(wrap, greaterThanOrEqualTo(2), reason: 'seed $seed wraps');
        }
      });

      test('${circuit.id.name}: never on a start square or an effect square', () {
        for (final seed in seeds) {
          for (final t in BonusLayout.generate(circuit, seed)) {
            expect(
              t.trackIndex % circuit.squaresPerQuadrant,
              isNot(0),
              reason: 'seed $seed: a bonus on a start square',
            );
            expect(
              circuit.effectAt(t.trackIndex),
              CellEffect.plain,
              reason: 'seed $seed: a bonus on ${circuit.effectAt(t.trackIndex)}',
            );
          }
        }
      });
    }

    test('the same seed always gives the same layout', () {
      for (final seed in seeds) {
        final a = BonusLayout.generate(Circuit.oasisRoute, seed);
        final b = BonusLayout.generate(Circuit.oasisRoute, seed);
        expect(a, b);
      }
    });

    test('different games get different layouts', () {
      final layouts = {
        for (final seed in seeds)
          BonusLayout.generate(Circuit.oasisRoute, seed)
              .map((t) => '${t.trackIndex}:${t.value}')
              .join(','),
      };
      expect(layouts.length, greaterThan(seeds.length ~/ 2));
    });

    test('a seed derives from the game id, and only from it', () {
      expect(BonusLayout.seedFor('g_1'), BonusLayout.seedFor('g_1'));
      expect(BonusLayout.seedFor('g_1'), isNot(BonusLayout.seedFor('g_2')));
      expect(BonusLayout.seedFor('g_1'), greaterThanOrEqualTo(0));
    });
  });

  group('The layout lives in the game state', () {
    GameState game() {
      final now = DateTime(2026, 1, 1);
      return GameState(
        gameId: 'g_layout',
        gameMode: GameMode.family,
        gameVariant: GameVariant.classic,
        circuitId: CircuitId.oasisRoute,
        players: [
          Player(
            id: 'p0',
            name: 'A',
            team: AppTeam.emerald,
            horses: const [HorseState()],
          ),
          Player(
            id: 'p1',
            name: 'B',
            team: AppTeam.saphir,
            horses: const [HorseState()],
          ),
        ],
        currentPlayerIndex: 0,
        turnPhase: TurnPhase.selectingGait,
        askedQuestionIds: const {},
        startedAt: now,
        updatedAt: now,
      );
    }

    test('the engine deals the squares once and never again', () {
      const engine = GameEngine();
      final dealt = engine.ensureBonusLayout(game());
      expect(dealt.bonusTiles.length, 16);
      expect(dealt.bonusSeed, BonusLayout.seedFor('g_layout'));
      // A second call — a rebuild, a resume — returns the very same list.
      expect(identical(engine.ensureBonusLayout(dealt), dealt), isTrue);
      // And the squares stay put through every turn of the game.
      var state = engine.drawCard(dealt, const MovementChoice(6));
      state = engine.applyAnswer(state, correct: true, questionId: 'q');
      state = engine.openPlacement(state);
      state = engine.placeHorse(state, 0);
      state = engine.endTurn(state);
      expect(state.bonusTiles, dealt.bonusTiles);
    });

    test('the squares survive a save, exactly', () {
      const engine = GameEngine();
      final dealt = engine.ensureBonusLayout(game());
      final restored = GameState.fromJson(dealt.toJson());
      expect(restored.bonusTiles, dealt.bonusTiles);
      expect(restored.bonusSeed, dealt.bonusSeed);
      expect(restored.bonusAt(dealt.bonusTiles.first.trackIndex), dealt.bonusTiles.first);
    });

    test('a save without a layout gets one from its own id', () {
      const engine = GameEngine();
      final json = game().toJson()..remove('bonusTiles')..remove('bonusSeed');
      final old = GameState.fromJson(json);
      expect(old.bonusTiles, isEmpty);
      final upgraded = engine.ensureBonusLayout(old);
      expect(upgraded.bonusTiles, BonusLayout.generate(Circuit.oasisRoute, BonusLayout.seedFor('g_layout')));
    });
  });
}
