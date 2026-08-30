import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_team.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/geometric_motif_painter.dart';
import '../../../widgets/horse_painter.dart';
import '../../../widgets/landmarks/hijaz_landmark_painter.dart';
import '../../game/application/game_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final saveService = ref.watch(gameSaveServiceProvider);
    final isPremium = ref.watch(premiumControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: HijazLandmarkPainter(
                scene: LandmarkScene.hijazMountains,
                skyTop: colors.primaryDark,
                skyBottom: colors.background,
                landPrimary: colors.secondary,
                landShade: colors.primaryDark,
              ),
            ),
          ),
          SafeArea(
            child: GeometricMotifBackground(
              opacity: 0.04,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(l10n.appName, style: Theme.of(context).textTheme.headlineLarge),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            isPremium ? Icons.workspace_premium : Icons.workspace_premium_outlined,
                            color: colors.goldAccent,
                          ),
                          onPressed: () => context.push('/premium'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () => context.push('/settings'),
                        ),
                      ],
                    ),
                    Text(
                      l10n.appTagline,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    const Expanded(
                      child: Center(
                        child: HorseToken(
                          coat: HorseCoat.bay,
                          team: AppTeam.saphir,
                          pose: HorsePose.standing,
                          size: 180,
                        ),
                      ),
                    ),
                    if (saveService.hasSave) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
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
                    Row(
                      children: [
                        Expanded(
                          child: _HomeActionButton(
                            icon: Icons.person,
                            label: l10n.soloMode,
                            onTap: () => context.push('/mode-selection', extra: 'solo'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HomeActionButton(
                            icon: Icons.groups,
                            label: l10n.familyMode,
                            onTap: () => context.push('/mode-selection', extra: 'family'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _HomeActionButton(
                            icon: Icons.calendar_today,
                            label: l10n.dailyChallenge,
                            onTap: () => context.push('/daily-challenge'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HomeActionButton(
                            icon: Icons.bar_chart,
                            label: l10n.progress,
                            onTap: () => context.push('/progress'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeActionButton extends StatelessWidget {
  const _HomeActionButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surfaceElevated,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, color: colors.primary, size: 28),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
