import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/button_label.dart';
import '../../../widgets/fit_or_scroll.dart';
import '../../../widgets/illustration.dart';
import '../../game/application/game_controller.dart';

/// The end of the journey is the game's biggest hero moment: the rider
/// has actually ARRIVED somewhere — at the palace oasis — so the screen
/// shows that place, not a dialog that says "victory".
///
/// Under the arrival sits the race board: every rider's stars, right
/// answers and best streak. The rematch is one tap and keeps the same
/// riders — "again!" is the whole reason a family game gets replayed.
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
      child: _body(context, ref, l10n, state, winner, aiWon),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    GameState? state,
    Player? winner,
    bool aiWon,
  ) {
    final colors = context.colors;
    // Finished horses first, then stars: the podium order players expect.
    final ranked = [...?state?.players]..sort((a, b) {
        final byArrivals = _arrivals(b).compareTo(_arrivals(a));
        if (byArrivals != 0) return byArrivals;
        return b.rewards.knowledgePoints.compareTo(a.rewards.knowledgePoints);
      });

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
            child: FitOrScroll(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      height: 210,
                      radius: 26,
                      glow: true,
                    ),
                  ),
                  const SizedBox(height: 18),
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
                    const SizedBox(height: 4),
                    Text(
                      aiWon ? l10n.wellRidden : winner.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFF4ECDC),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (ranked.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _Scoreboard(
                      players: ranked,
                      winnerId: winner?.id,
                      l10n: l10n,
                      teamColor: (p) => p.team.color(colors),
                    ),
                  ],
                  const Spacer(),
                  const SizedBox(height: 18),
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
                          key: const Key('race-again'),
                          onTap: () {
                            final again =
                                ref.read(gameControllerProvider.notifier).restartSameSetup();
                            context.go(again ? '/game' : '/home');
                          },
                          child: Center(
                            child: Text(
                              l10n.playAgainSameRiders.toUpperCase(),
                              textAlign: TextAlign.center,
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
                    child: ButtonLabel(l10n.backToHome),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static int _arrivals(Player p) =>
      p.horses.where((h) => h.position is FinishedPosition).length;
}

/// One row per rider: colour, name, stars, right answers, best streak.
/// Three numbers, three icons — readable by a child who cannot yet read
/// the words.
class _Scoreboard extends StatelessWidget {
  const _Scoreboard({
    required this.players,
    required this.winnerId,
    required this.l10n,
    required this.teamColor,
  });

  final List<Player> players;
  final String? winnerId;
  final AppLocalizations l10n;
  final Color Function(Player) teamColor;

  @override
  Widget build(BuildContext context) {
    final label = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: const Color(0xB3E9DFC8),
      letterSpacing: 0.8,
    );
    final row = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: const Color(0xFFF4ECDC),
      fontWeight: FontWeight.w600,
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0x8010283F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.scoreboardTitle.toUpperCase(), style: label),
          const SizedBox(height: 8),
          for (final p in players)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  if (p.id == winnerId)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.emoji_events, size: 16, color: Color(0xFFF3D68A)),
                    ),
                  CircleAvatar(radius: 6, backgroundColor: teamColor(p)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: row,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Stat(
                    icon: Icons.auto_awesome,
                    color: const Color(0xFFEBC06A),
                    text: '${p.rewards.knowledgePoints}',
                    semantics: '${p.rewards.knowledgePoints}',
                    style: row,
                  ),
                  const SizedBox(width: 10),
                  _Stat(
                    icon: Icons.check_circle,
                    color: const Color(0xFF7ED09A),
                    text: '${_correct(p)}',
                    semantics: l10n.scoreboardCorrect(_correct(p)),
                    style: row,
                  ),
                  const SizedBox(width: 10),
                  _Stat(
                    icon: Icons.local_fire_department,
                    color: const Color(0xFFF0A24B),
                    text: '${p.streak.best}',
                    semantics: l10n.scoreboardBestStreak(p.streak.best),
                    style: row,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static int _correct(Player p) => p.answersByCategory.values.fold(0, (a, b) => a + b);
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.color,
    required this.text,
    required this.semantics,
    required this.style,
  });

  final IconData icon;
  final Color color;
  final String text;
  final String semantics;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantics,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 3),
          Text(text, style: style),
        ],
      ),
    );
  }
}
