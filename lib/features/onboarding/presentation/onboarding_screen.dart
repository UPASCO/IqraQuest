import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/button_label.dart';
import '../../../widgets/fit_or_scroll.dart';
import '../../../widgets/ornate_frame.dart';

/// The first screen after install. It has one job: show, in a single
/// glance, that this is a board game raced on horseback — so it opens on
/// the actual board the family will play on, not on an illustration of
/// one, framed in the plate's own gold.
///
/// Everything here is drawn on the plate's dark ground, so every colour
/// comes from the `onScene` tokens or the plate palette. Reaching for
/// `textTheme`'s default ink (meant for the light surface) is what once
/// made this screen unreadable.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: OrnatePalette.groundDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // The plate's own ground, so the board sits on the colour it
          // was painted for and the screen reads as part of the set.
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
            child: FitOrScroll(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  // The real board, the one the family will play on —
                  // not an illustration of a board.
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x80000000),
                                blurRadius: 30,
                                offset: Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/board/cross_board.webp',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.medium,
                            // Art must never be the reason the screen
                            // fails to render.
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  OrnateFrame(
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.onboardingWelcomeTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: OrnatePalette.gold,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.onboardingWelcomeSubtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colors.onSceneDim,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Gold, not the theme's green: a green button on a
                        // green scene is the button the player could not find.
                        FilledButton(
                          onPressed: () => _finish(context, ref),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.goldAccent,
                            foregroundColor: const Color(0xFF231705),
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          child: ButtonLabel(l10n.getStarted),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
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
