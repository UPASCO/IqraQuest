import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/illustration.dart';
import '../../game/application/game_controller.dart';

/// The end of the journey is the game's biggest hero moment: the rider
/// has actually ARRIVED somewhere — at the palace oasis — so the screen
/// shows that place, not a dialog that says "victory".
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
    // A losing child must not get a full victory fanfare for the AI:
    // the tone shifts to a warm "well ridden" when the winner is a bot.
    final aiWon = winner?.isAi ?? false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: _body(context, l10n, winner, aiWon),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n, Player? winner, bool aiWon) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1D33),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Night-sky gradient behind the illuminated arrival scene.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF102A47), Color(0xFF0B1D33), Color(0xFF081422)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
              child: Column(
                children: [
                  const Spacer(),
                  // The destination itself, glowing in the night.
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: AppMotion.of(context, AppMotion.reward),
                    curve: AppMotion.settle,
                    builder: (context, t, child) => Transform.scale(
                      scale: 0.85 + 0.15 * t.clamp(0.0, 1.0),
                      child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
                    ),
                    child: const ArtPanel(
                      asset: AppArt.oasisArrival,
                      width: double.infinity,
                      height: 300,
                      radius: 26,
                      glow: true,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    aiWon && winner != null ? l10n.opponentWins(winner.name) : l10n.victory,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: const Color(0xFFF3D68A),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      shadows: const [
                        Shadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0, 3)),
                      ],
                    ),
                  ),
                  if (winner != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      aiWon ? l10n.wellRidden : winner.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFF4ECDC),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Material(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFF3D68A), Color(0xFFD8A032)],
                          ),
                        ),
                        child: InkWell(
                          onTap: () => context.go('/home'),
                          child: Center(
                            child: Text(
                              l10n.playAgain.toUpperCase(),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF4A3410),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xCCE9DFC8),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: Text(l10n.backToHome),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
