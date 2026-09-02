import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/button_label.dart';
import '../../../widgets/fit_or_scroll.dart';
import '../../../widgets/gold_rule.dart';
import '../../../widgets/illustration.dart';
import '../../../widgets/ornate_frame.dart';

/// The first screen after install, and the first impression of the game.
/// It stands on the same baked key art as the home screen
/// (tool/art/bake_home_hero.py): the app icon's three horses above, the
/// painted board laid on its table below. Opening on a flat picture of
/// the plate made the welcome look like a different, poorer product than
/// the screen right behind it.
///
/// Everything here is drawn on that dark art, so every colour comes from
/// the `onScene` tokens or the plate palette. Reaching for `textTheme`'s
/// default ink (meant for the light surface) is what once made this
/// screen unreadable.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = Theme.of(context).textTheme;

    const onScene = Color(0xFFF4ECDC);

    return Scaffold(
      backgroundColor: OrnatePalette.groundDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // The same one baked picture the home screen opens on, so the
          // welcome and the hub are visibly the same world.
          Positioned.fill(
            child: Image.asset(
              AppArt.homeHero,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.medium,
              // Art must never be the reason the screen fails to render.
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: OrnatePalette.groundDeep),
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
                    colors: [
                      Color(0xCC03151A),
                      Color(0x6603151A),
                      Color(0x0003151A),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: FitOrScroll(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // The game's name over its own horses, exactly as
                        // the home screen wears it.
                        Text(
                          l10n.appName,
                          textAlign: TextAlign.center,
                          style: text.displaySmall?.copyWith(
                            color: onScene,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            shadows: const [
                              Shadow(
                                color: Color(0x66000000),
                                blurRadius: 12,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Center(child: GoldRule(width: 168)),
                        // The key art is the background: the column only
                        // has to leave it room, and give it up first on a
                        // small phone at a large text size.
                        const Spacer(),
                        // Kept compact on purpose: the plaque must sit on
                        // the picture's calm foot, not climb over the
                        // board it is introducing.
                        OrnateFrame(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.onboardingWelcomeTitle,
                                textAlign: TextAlign.center,
                                style: text.titleLarge?.copyWith(
                                  color: OrnatePalette.gold,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.onboardingWelcomeSubtitle,
                                textAlign: TextAlign.center,
                                style: text.bodyMedium?.copyWith(
                                  color: colors.onSceneDim,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
                // Pinned under the scroll, never inside it: the one way
                // into the app must be on screen on the smallest phone
                // at the largest text — a welcome that has to be
                // scrolled for is a door the child cannot find.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  // Gold, not the theme's green: a green button on a
                  // green scene is the button the player could not find.
                  child: FilledButton(
                    onPressed: () => _finish(context, ref),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.goldAccent,
                      foregroundColor: const Color(0xFF231705),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    child: ButtonLabel(l10n.getStarted),
                  ),
                ),
              ],
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
