import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../services/legacy_game_migration_service.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/system_bars.dart';
import '../../../widgets/gold_rule.dart';
import '../../../widgets/ornate_frame.dart';
import '../../../widgets/illustration.dart';
import '../../game/application/game_controller.dart';
import '../../../widgets/button_label.dart';

/// The hub of the game, answering at a glance: where am I on the
/// journey, what is my streak, and what do I do next. One dominant CTA
/// — continue the journey — over the same living Hijaz world the race
/// is played in; every other destination is a quiet shelf below it.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // A game saved under the old dice rules cannot be resumed faithfully.
    // Explain it once, archive it rather than delete it, and let the
    // player start a fresh race (spec §18).
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLegacySave());
  }

  Future<void> _checkLegacySave() async {
    final migration = ref.read(legacyGameMigrationServiceProvider);
    if (migration.inspect() != SaveCompatibility.legacy) return;

    await migration.archiveLegacySave();
    if (!mounted) return;
    setState(() {}); // the stale "Continue" button must disappear

    if (migration.hasSeenRaceRulesNotice) return;
    await migration.markRaceRulesNoticeSeen();
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.raceRulesUpdatedTitle),
        content: Text(l10n.raceRulesUpdatedBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: ButtonLabel(l10n.startNewRace)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Only a current-schema save is readable; a legacy one is left
    // untouched for the migration flow to archive.
    final compatible =
        ref.watch(legacyGameMigrationServiceProvider).inspect() == SaveCompatibility.current;
    final save = compatible ? ref.watch(gameSaveServiceProvider).load() : null;
    final stats = ref.watch(progressServiceProvider).load();
    final isPremium = ref.watch(premiumControllerProvider);

    const onScene = Color(0xFFF4ECDC);
    const onSceneDim = Color(0xCCE9DFC8);

    return Scaffold(
      backgroundColor: const Color(0xFF0A3327),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // One baked picture, not a scene painted at runtime: the app
          // icon's own three horses over the painted board laid on its
          // table (tool/art/bake_home_hero.py). The first screen and the
          // icon on the home screen are the same artwork.
          Positioned.fill(
            child: Image.asset(
              AppArt.homeHero,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF0A3327)),
            ),
          ),
          // A scrim under the title only: the horses' manes are bright,
          // and ivory type on them would not hold.
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.30, 0.55],
                    colors: [Color(0xCC03151A), Color(0x6603151A), Color(0x0003151A)],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              // Padding, not a max-width box: the column below holds a
              // Spacer, and a Center would loosen its height and make
              // that Spacer unbounded. Growing the side margins holds
              // the composition to one measure on a tablet while the
              // key art keeps the full screen behind it.
              padding: pagePadding(context, horizontal: 18, top: 8, bottom: 8),
              child: Column(
                children: [
                  // ---- Top bar: identity left, streak & points, settings ----
                  Row(
                    children: [
                      if (stats.dayStreak > 0) ...[
                        _StatPill(
                          icon: Icons.local_fire_department,
                          iconColor: const Color(0xFFF0A24B),
                          text: '${stats.dayStreak}',
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (stats.correctAnswers > 0)
                        _StatPill(
                          icon: Icons.auto_awesome,
                          iconColor: const Color(0xFFEBC06A),
                          text: '${stats.correctAnswers}',
                        ),
                      const Spacer(),
                      _RoundGlassButton(
                        icon: isPremium
                            ? Icons.workspace_premium
                            : Icons.workspace_premium_outlined,
                        iconColor: const Color(0xFFE3B354),
                        semanticLabel: l10n.premium,
                        onTap: () => context.push('/premium'),
                      ),
                      const SizedBox(width: 8),
                      _RoundGlassButton(
                        icon: Icons.settings_outlined,
                        iconColor: onSceneDim,
                        semanticLabel: l10n.settings,
                        onTap: () => context.push('/settings'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.appName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: onScene,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      shadows: const [
                        Shadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                  Text(
                    l10n.appTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: onSceneDim),
                  ),
                  const SizedBox(height: 8),
                  const GoldRule(width: 168),
                  // The key art is the background: the column only has
                  // to leave it room, and give it up first on a small
                  // phone at a large text size.
                  const Spacer(),

                  // ---- The journey card: where I am + the dominant CTA ----
                  _JourneyCard(l10n: l10n, save: save, onContinue: _continueJourney),
                  const SizedBox(height: 12),

                  // ---- The shelf: everything else, deliberately quiet ----
                  Row(
                    children: [
                      _ShelfItem(
                        icon: Icons.person,
                        label: l10n.soloMode,
                        onTap: () => context.push('/mode-selection', extra: 'solo'),
                      ),
                      _ShelfItem(
                        icon: Icons.groups,
                        label: l10n.familyMode,
                        onTap: () => context.push('/mode-selection', extra: 'family'),
                      ),
                      _ShelfItem(
                        icon: Icons.calendar_today,
                        label: l10n.dailyChallenge,
                        onTap: () => context.push('/daily-challenge'),
                      ),
                      _ShelfItem(
                        icon: Icons.bar_chart,
                        label: l10n.progress,
                        onTap: () => context.push('/progress'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
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

  Future<void> _continueJourney() async {
    final save = ref.read(gameSaveServiceProvider).load();
    if (save == null) {
      context.push('/mode-selection', extra: 'solo');
      return;
    }
    // The question bank and entitlement must be live BEFORE the game
    // resumes, or every question would silently come back null.
    final pool = await ref.read(questionPoolProvider.future);
    final controller = ref.read(gameControllerProvider.notifier);
    controller.configure(pool: pool, isPremium: ref.read(premiumControllerProvider));
    if (controller.loadSaved() && mounted) {
      context.push('/game');
    }
  }
}

/// "Where am I on the journey" + the one big golden button.
class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.l10n, required this.save, required this.onContinue});

  final AppLocalizations l10n;
  final GameState? save;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final save = this.save;

    String? circuitName;
    double progress = 0;
    if (save != null) {
      circuitName = switch (save.circuitId) {
        CircuitId.oasisRoute => l10n.circuitOasisRoute,
        CircuitId.caravanTrail => l10n.circuitCaravanTrail,
        CircuitId.greatRide => l10n.circuitGreatRide,
      };
      final circuit = save.circuit;
      var best = 0;
      for (var t = 0; t < save.players.length; t++) {
        if (save.players[t].isAi) continue;
        for (final horse in save.players[t].horses) {
          best = (circuit.progressOf(horse.position, t) ?? 0).clamp(best, circuit.journeyLength);
        }
      }
      progress = best / circuit.journeyLength;
    }

    // Framed in the plate's gold: the card on the home screen and the
    // board it leads to are one set.
    return OrnateFrame(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      inset: 8,
      starSize: 11,
      fill: const Color(0xF20F3A3E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (circuitName != null && save != null) ...[
            Row(
              children: [
                // A postcard of the region the journey rides through.
                ArtPanel(
                  asset: AppArt.forCircuit(save.circuitId),
                  width: 58,
                  height: 52,
                  radius: 12,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              circuitName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: const Color(0xFFF4ECDC),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFFEBC06A),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.02, 1.0),
                          minHeight: 9,
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          valueColor: const AlwaysStoppedAnimation(Color(0xFFE3B354)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          // The dominant golden CTA.
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
                  onTap: onContinue,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            (save != null ? l10n.continueGame : l10n.startGame).toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF4A3410),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20, color: Color(0xFF4A3410)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.iconColor, required this.text});

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xB3122E22),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: const Color(0xFFF4ECDC), fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _RoundGlassButton extends StatelessWidget {
  const _RoundGlassButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: const Color(0xB3122E22),
        shape: CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.14))),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(width: 38, height: 38, child: Icon(icon, size: 19, color: iconColor)),
        ),
      ),
    );
  }
}

class _ShelfItem extends StatelessWidget {
  const _ShelfItem({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        // Opaque, not a 9%-white veil: these tiles sit over a scene that
        // runs from night sky to pale sand, and a translucent chip with
        // pale type on it disappears completely over the light half —
        // that is what made "Défi du jour" unreadable on device.
        child: Material(
          color: const Color(0xE60B2A20),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(
                children: [
                  Icon(icon, size: 20, color: const Color(0xFFF6EFE0)),
                  const SizedBox(height: 4),
                  // Scaled down rather than ellipsised: "Défi du jour"
                  // and its 11 translations must all stay readable.
                  ButtonLabel(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      height: 1.1,
                      color: const Color(0xFFF6EFE0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
