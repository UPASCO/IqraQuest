import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/horse_painter.dart';
import '../../game/application/game_controller.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(gameControllerProvider);
    final state = session?.gameState;

    final winner = state == null
        ? null
        : state.players.where((p) => p.id == state.winnerId).firstOrNull ?? state.players.first;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (winner != null)
                HorseToken(
                  coat: winner.team.coat,
                  team: winner.team,
                  pose: HorsePose.rearingProud,
                  size: 160,
                  color: winner.team.color(context.colors),
                ),
              const SizedBox(height: 16),
              Text(l10n.victory, style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              if (winner != null) Text(winner.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 40),
              ElevatedButton(onPressed: () => context.go('/home'), child: Text(l10n.backToHome)),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () => context.go('/home'), child: Text(l10n.playAgain)),
            ],
          ),
        ),
      ),
    );
  }
}
