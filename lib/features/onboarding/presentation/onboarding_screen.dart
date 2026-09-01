import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/button_label.dart';
import '../../../widgets/fit_or_scroll.dart';

/// The first screen after install. It has one job: show, in a single
/// glance, that this is a board game raced on horseback — so it opens on
/// the actual board, not on an illustration of one.
///
/// Everything here is drawn over a dark painted scene, so every colour
/// comes from the `onScene` tokens. Reaching for `textTheme`'s default
/// ink (meant for the light surface) is what made this screen
/// unreadable: near-black type on dark green, under decorative bands
/// that ran straight through the words.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: const Color(0xFF06251C),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // The board itself, full bleed. Its top half (night sky over
          // the oasis) sits behind the title; the track and the camps
          // read underneath.
          // Pushed in past the empty night sky at the top of the plate,
          // so the camps and the track — the part that says "horses" —
          // are what fills the screen.
          ClipRect(
            child: Transform.scale(
              scale: 1.34,
              alignment: const Alignment(0, 0.46),
              child: Image.asset(
                'assets/board/scene_oasis.webp',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                // Art must never be the reason the screen fails to render.
                errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF06251C)),
              ),
            ),
          ),

          // The scrim is what makes the copy legible over painted art:
          // transparent across the scene, opaque where the words are.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                // Light across the art, heavy only under the copy: the
                // board has to stay vivid, the words have to stay legible.
                stops: [0.0, 0.30, 0.58, 0.74, 1.0],
                colors: [
                  Color(0x6606251C),
                  Color(0x0D06251C),
                  Color(0x5906251C),
                  Color(0xE006251C),
                  Color(0xFC06251C),
                ],
              ),
            ),
          ),

          SafeArea(
            child: FitOrScroll(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 5),
                  Text(
                    l10n.onboardingWelcomeTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: colors.onScene,
                      height: 1.08,
                      shadows: const [
                        Shadow(color: Color(0xB3000000), blurRadius: 18, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.onboardingWelcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.onSceneDim,
                      height: 1.45,
                      shadows: const [
                        Shadow(color: Color(0x99000000), blurRadius: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  // Gold, not the theme's green: a green button on a green
                  // scene is the button the player could not find.
                  FilledButton(
                    onPressed: () => _finish(context, ref),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.goldAccent,
                      foregroundColor: const Color(0xFF231705),
                      minimumSize: const Size.fromHeight(58),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    child: ButtonLabel(l10n.getStarted),
                  ),
                  const SizedBox(height: 8),
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
