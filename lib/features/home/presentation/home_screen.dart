import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../services/legacy_game_migration_service.dart';
import '../../../theme/app_team.dart';
import '../../../widgets/horse_painter.dart';
import '../../game/application/game_controller.dart';

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
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.startNewRace)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saveService = ref.watch(gameSaveServiceProvider);
    final isPremium = ref.watch(premiumControllerProvider);

    // The hero scene commits to one look in both themes — it is the
    // brand image (same language as the launcher icon), not a surface.
    const onScene = Color(0xFFF4ECDC);
    const onSceneDim = Color(0xCCE9DFC8);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _HomeBackdropPainter())),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          isPremium ? Icons.workspace_premium : Icons.workspace_premium_outlined,
                          color: const Color(0xFFE3B354),
                        ),
                        onPressed: () => context.push('/premium'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: onSceneDim),
                        onPressed: () => context.push('/settings'),
                      ),
                    ],
                  ),
                  Text(
                    l10n.appName,
                    style: Theme.of(context).textTheme.displaySmall
                        ?.copyWith(color: onScene, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.appTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: onSceneDim),
                  ),
                  // The horse stands on the dune line painted by the
                  // backdrop; the soft ellipse anchors it to the ground.
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HorseToken(
                            coat: HorseCoat.bay,
                            team: AppTeam.saphir,
                            pose: HorsePose.standing,
                            size: 190,
                          ),
                          Transform.translate(
                            offset: const Offset(0, -8),
                            child: Container(
                              width: 130,
                              height: 18,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.30),
                                    Colors.black.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (saveService.hasSave) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          backgroundColor: onScene.withValues(alpha: 0.14),
                          foregroundColor: onScene,
                        ),
                        icon: const Icon(Icons.play_circle_outline),
                        label: Text(l10n.continueGame),
                        onPressed: () {
                          ref.read(gameControllerProvider.notifier).loadSaved();
                          context.push('/game');
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Play is the reason the screen exists: two big, warm
                  // primary cards. Everything else is a quieter shelf.
                  Row(
                    children: [
                      Expanded(
                        child: _PlayCard(
                          icon: Icons.person,
                          label: l10n.soloMode,
                          onTap: () => context.push('/mode-selection', extra: 'solo'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PlayCard(
                          icon: Icons.groups,
                          label: l10n.familyMode,
                          onTap: () => context.push('/mode-selection', extra: 'family'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ShelfButton(
                          icon: Icons.calendar_today,
                          label: l10n.dailyChallenge,
                          onTap: () => context.push('/daily-challenge'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ShelfButton(
                          icon: Icons.bar_chart,
                          label: l10n.progress,
                          onTap: () => context.push('/progress'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A big warm invitation to play: sand-to-ivory gradient, emerald icon
/// chip, bold label.
class _PlayCard extends StatelessWidget {
  const _PlayCard({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFAF3E3), Color(0xFFEFDFBC)],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF11573F)),
                  child: Icon(icon, color: const Color(0xFFF4ECDC), size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: const Color(0xFF1E2B1F), fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Quieter secondary destinations, translucent over the dunes.
class _ShelfButton extends StatelessWidget {
  const _ShelfButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const onScene = Color(0xFFF4ECDC);
    return Material(
      color: Colors.white.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: onScene, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: onScene),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dawn over the Hijaz, in the launcher icon's exact visual language:
/// emerald night sky, gold crescent and faint stars, a warm glow rising
/// from the horizon, and layered dunes for the horse to stand on.
/// Deliberately identical in light and dark themes — it is brand art.
class _HomeBackdropPainter extends CustomPainter {
  const _HomeBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 0.45, 0.62, 1],
          colors: [Color(0xFF0B3D2E), Color(0xFF11573F), Color(0xFF1B6B4C), Color(0xFF0A3B2A)],
        ).createShader(rect),
    );

    // Warm dawn glow where the sky meets the dunes.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.28),
          radius: 0.9,
          colors: [
            const Color(0xFFE9B84F).withValues(alpha: 0.38),
            const Color(0xFFE9B84F).withValues(alpha: 0.10),
            const Color(0x00E9B84F),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );

    // Stars: fixed, calm scatter high in the sky.
    final star = Paint()..color = const Color(0xFFF4ECDC).withValues(alpha: 0.55);
    for (var i = 0; i < 14; i++) {
      final x = (math.sin(i * 12.9898) * 0.5 + 0.5) * w;
      final y = (math.sin(i * 78.233) * 0.5 + 0.5) * h * 0.30;
      canvas.drawCircle(Offset(x, y + 8), i % 3 == 0 ? 1.8 : 1.1, star);
    }

    // Crescent, top right — clear of the title block on the left.
    final crescent = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: Offset(w * 0.82, h * 0.10), radius: w * 0.055)),
      Path()..addOval(Rect.fromCircle(center: Offset(w * 0.845, h * 0.088), radius: w * 0.047)),
    );
    canvas.drawPath(crescent, Paint()..color = const Color(0xFFEBC06A));

    // Three layered dunes: smooth, calm curves — never jagged peaks.
    void dune(double top, double amp, double phase, Color color) {
      final path = Path()..moveTo(0, h);
      path.lineTo(0, h * top + math.sin(phase) * amp);
      for (var x = 0.0; x <= w; x += w / 40) {
        path.lineTo(x, h * top + math.sin(x / w * math.pi * 1.6 + phase) * amp);
      }
      path.lineTo(w, h);
      path.close();
      canvas.drawPath(path, Paint()..color = color);
    }

    dune(0.60, h * 0.030, 0.4, const Color(0xFF14523C));
    dune(0.66, h * 0.026, 2.6, const Color(0xFF0F4432));
    dune(0.73, h * 0.020, 4.8, const Color(0xFF0A3627));
  }

  @override
  bool shouldRepaint(covariant _HomeBackdropPainter oldDelegate) => false;
}
