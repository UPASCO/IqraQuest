import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_team.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/horse_painter.dart';
import '../../../widgets/landmarks/hijaz_landmark_painter.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: HijazLandmarkPainter(
                scene: LandmarkScene.hijazDesert,
                skyTop: colors.primaryDark,
                skyBottom: colors.background,
                landPrimary: colors.secondary,
                landShade: colors.primaryDark,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  const HorseToken(
                    coat: HorseCoat.grayWhite,
                    team: AppTeam.emerald,
                    pose: HorsePose.rearingProud,
                    showSaddle: false,
                    size: 200,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.onboardingWelcomeTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.onboardingWelcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _finish(context, ref),
                      child: Text(l10n.getStarted),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('iqraquest.onboarding.complete', true);
    await ref
        .read(settingsControllerProvider.notifier)
        .setLanguage(ref.read(effectiveLanguageProvider));
    if (context.mounted) context.go('/home');
  }
}
