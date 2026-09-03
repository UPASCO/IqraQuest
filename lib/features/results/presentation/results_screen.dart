import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../services/sound_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/button_label.dart';
import '../../../widgets/fit_or_scroll.dart';
import '../../../widgets/illustration.dart';
import '../../../widgets/ornate_frame.dart';
import '../../../widgets/share_capture.dart';
import '../../../widgets/system_bars.dart';
import '../../game/application/game_controller.dart';

/// The end of the journey is the game's biggest hero moment: the rider
/// has actually ARRIVED somewhere — at the palace oasis — so the screen
/// shows that place, not a dialog that says "victory".
///
/// The arrival and the race board (every rider's stars, right answers
/// and best streak) sit together on one ornate score card, framed like
/// the board plate: that card is what gets shared as an image. The
/// rematch is one tap and keeps the same riders — "again!" is the whole
/// reason a family game gets replayed.
class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  final _cardKey = GlobalKey();
  final _shareKey = GlobalKey();
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    // The fanfare belongs to the score card, not to the last hop on the
    // board: it starts as the card is revealed. A losing child must not
    // get a full victory fanfare for the AI — the short warm flourish
    // covers "well ridden".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(gameControllerProvider)?.gameState;
      final winner = _winnerOf(state);
      if (winner == null) return;
      final sound = ref.read(soundServiceProvider);
      // A race the free edition stopped short is not a victory either:
      // the short warm flourish, and the pitch for the rest of the ride.
      if (winner.isAi || (state?.endedByDrawLimit ?? false)) {
        sound.play(Sfx.victory);
      } else {
        sound.play(Sfx.fanfare);
        HapticFeedback.heavyImpact();
      }
    });
  }

  static Player? _winnerOf(GameState? state) {
    if (state == null || state.players.isEmpty) return null;
    return state.players.where((p) => p.id == state.winnerId).firstOrNull ??
        state.players.first;
  }

  static int _arrivals(Player p) =>
      p.horses.where((h) => h.position is FinishedPosition).length;

  Future<void> _share(AppLocalizations l10n, Player winner) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final image = await captureBoundaryPng(_cardKey);
      if (!mounted) return;
      final origin = shareOriginOf(_shareKey);
      final shown = await ref
          .read(shareServiceProvider)
          .shareScore(
            text: l10n.shareVictoryText(
              winner.name,
              winner.rewards.knowledgePoints,
            ),
            subject: l10n.appName,
            image: image,
            origin: origin,
          );
      if (!shown && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.shareVictoryText(
                winner.name,
                winner.rewards.knowledgePoints,
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(gameControllerProvider);
    final state = session?.gameState;
    final winner = _winnerOf(state);
    // A losing child must not get a full victory fanfare for the AI:
    // the tone shifts to a warm "well ridden" when the winner is a bot.
    final aiWon = winner?.isAi ?? false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: _body(context, l10n, state, winner, aiWon),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    GameState? state,
    Player? winner,
    bool aiWon,
  ) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    // Finished horses first, then stars: the podium order players expect.
    final ranked = [...?state?.players]
      ..sort((a, b) {
        final byArrivals = _arrivals(b).compareTo(_arrivals(a));
        if (byArrivals != 0) return byArrivals;
        return b.rewards.knowledgePoints.compareTo(a.rewards.knowledgePoints);
      });

    final card = RepaintBoundary(
      key: _cardKey,
      child: OrnateFrame(
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF14484C),
            OrnatePalette.ground,
            OrnatePalette.groundDeep,
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // The destination itself, glowing in the night.
            const ArtPanel(
              asset: AppArt.oasisArrival,
              width: double.infinity,
              height: 150,
              radius: 14,
              glow: true,
            ),
            const SizedBox(height: 12),
            Text(
              state?.endedByDrawLimit ?? false
                  ? l10n.freeLimitTitle
                  : aiWon && winner != null
                  ? l10n.opponentWins(winner.name)
                  : l10n.victory,
              textAlign: TextAlign.center,
              style: text.headlineMedium?.copyWith(
                color: OrnatePalette.gold,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                shadows: const [
                  Shadow(
                    color: Color(0x88000000),
                    blurRadius: 12,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            if (winner != null) ...[
              const SizedBox(height: 2),
              Text(
                state?.endedByDrawLimit ?? false
                    ? l10n.freeLimitLeader(winner.name)
                    : aiWon
                    ? l10n.wellRidden
                    : winner.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleLarge?.copyWith(
                  color: OrnatePalette.ivory,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (ranked.isNotEmpty) ...[
              const SizedBox(height: 12),
              _Scoreboard(
                players: ranked,
                winnerId: winner?.id,
                l10n: l10n,
                teamColor: (p) => p.team.color(colors),
              ),
            ],
            if (state?.endedByDrawLimit ?? false) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  l10n.freeLimitBody(
                    state!.maxDraws ?? GameState.freeDrawLimit,
                  ),
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    color: OrnatePalette.ivoryDim,
                    height: 1.35,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Wordmark so the shared picture says where it came from.
            Text(
              l10n.appName.toUpperCase(),
              textAlign: TextAlign.center,
              style: text.labelSmall?.copyWith(
                color: OrnatePalette.goldDeep,
                letterSpacing: 2.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: OrnatePalette.groundDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [OrnatePalette.ground, OrnatePalette.groundDeep],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: FitOrScroll(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: AppMotion.of(context, AppMotion.reward),
                          curve: AppMotion.settle,
                          builder: (context, t, child) => Transform.scale(
                            scale: 0.9 + 0.1 * t.clamp(0.0, 1.0),
                            child: Opacity(
                              opacity: t.clamp(0.0, 1.0),
                              child: child,
                            ),
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 460),
                              child: card,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                // Pinned under the board, never at the end of a scroll:
                // "again!" is said in the second after the race, and the
                // button must be under the thumb on the smallest phone.
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // A race the free edition stopped leads to what
                          // removes the stop; a finished race, to another.
                          if (state?.endedByDrawLimit ?? false) ...[
                            _GoldButton(
                              key: const Key('unlock-unlimited'),
                              label: l10n.freeLimitCta,
                              onTap: () => context.push('/premium'),
                            ),
                            const SizedBox(height: 10),
                          ],
                          _GoldButton(
                            key: const Key('race-again'),
                            label: l10n.playAgainSameRiders,
                            onTap: () {
                              final again = ref
                                  .read(gameControllerProvider.notifier)
                                  .restartSameSetup();
                              context.go(again ? '/game' : '/home');
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: KeyedSubtree(
                                  key: _shareKey,
                                  child: OutlinedButton.icon(
                                    key: const Key('share-score'),
                                    onPressed: winner == null || _sharing
                                        ? null
                                        : () => _share(l10n, winner),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: OrnatePalette.gold,
                                      disabledForegroundColor:
                                          OrnatePalette.ivoryDim,
                                      side: const BorderSide(
                                        color: OrnatePalette.goldDeep,
                                        width: 1.4,
                                      ),
                                      minimumSize: const Size.fromHeight(48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: const Icon(Icons.ios_share, size: 20),
                                    label: ButtonLabel(l10n.shareScore),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextButton(
                                  onPressed: () => context.go('/home'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: OrnatePalette.ivoryDim,
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                  child: ButtonLabel(l10n.backToHome),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Light system-bar icons over the dark ground: Android
          // paints the clock, the battery and the nav-bar glyphs from
          // what the app declares, not from what it draws, and declares
          // nothing by default. Front-most and invisible, so it wins the
          // annotation without touching a pixel or a gesture.
          const Positioned.fill(
            child: IgnorePointer(
              child: DarkSystemBars(child: SizedBox.expand()),
            ),
          ),
        ],
      ),
    );
  }
}

/// The gold plate button shared by the rematch action: gradient gold on
/// a dark ground, the same metal as the frame.
class _GoldButton extends StatelessWidget {
  const _GoldButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [OrnatePalette.gold, Color(0xFFD8A032)],
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  label.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
    );
  }
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
    final label = Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: OrnatePalette.ivoryDim, letterSpacing: 0.8);
    final row = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: OrnatePalette.ivory, fontWeight: FontWeight.w600);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: BoxDecoration(
        color: const Color(0x66061F22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x66C59F4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.scoreboardTitle.toUpperCase(), style: label),
          const SizedBox(height: 6),
          for (final p in players)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  if (p.id == winnerId)
                    const Padding(
                      padding: EdgeInsetsDirectional.only(end: 4),
                      child: Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: OrnatePalette.gold,
                      ),
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

  static int _correct(Player p) =>
      p.answersByCategory.values.fold(0, (a, b) => a + b);
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
