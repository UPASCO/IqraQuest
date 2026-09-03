import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/button_label.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/system_bars.dart';
import '../../../widgets/fit_or_scroll.dart';
import '../../../widgets/gold_rule.dart';
import '../../../widgets/illustration.dart';
import '../../../widgets/board/bonus_tile_painter.dart';
import '../../../widgets/ornate_frame.dart';
import '../../../widgets/question_card_draw.dart';

/// The first screen after install — seen once, and it has three jobs
/// the home screen does not:
///
/// 1. **pick the language**, live: every chip re-renders the screen in
///    that language at once, so the choice is understood without a word
///    of explanation, and the game's questions load in it from the
///    first card;
/// 2. **show how the game plays** in the three gestures a turn is made
///    of — draw a card that announces its gallops, answer right to win
///    them, set a horse down and ride — with the game's own pieces as
///    the pictures, so the board is already familiar on arrival;
/// 3. **one way in.**
///
/// It therefore does not wear the home screen's key art: the home is the
/// race, the welcome is the *destination* — the oasis every horse rides
/// to — framed like the arrival it foreshadows. A first screen identical
/// to the second reads as a glitch; this one reads as a threshold.
///
/// Everything here is drawn on the plate's dark ground, so every colour
/// comes from the `onScene` tokens or the plate palette.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  static const _languages = [
    ('fr', 'Français'),
    ('en', 'English'),
    ('ar', 'العربية'),
    ('es', 'Español'),
    ('pt', 'Português'),
    ('de', 'Deutsch'),
    ('tr', 'Türkçe'),
    ('id', 'Indonesia'),
    ('ur', 'اردو'),
    ('ms', 'Melayu'),
    ('it', 'Italiano'),
    ('nl', 'Nederlands'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final current = ref.watch(effectiveLanguageProvider);

    const onScene = Color(0xFFF4ECDC);

    return Scaffold(
      backgroundColor: OrnatePalette.groundDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // The plate's own cloth, not the key art: a different ground
          // from the home screen on purpose.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.45, 1.0],
                colors: [Color(0xFF0E3F36), OrnatePalette.ground, OrnatePalette.groundDeep],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: FitOrScroll(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                    child: Column(
                      // Centred, not stacked from the top: on a phone
                      // the column fills the screen and this changes
                      // nothing, but on a tablet it stops the whole
                      // composition huddling under the status bar with
                      // half the screen empty below it.
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ---- Name, small: this is not the hub ----
                        Text(
                          l10n.appName,
                          textAlign: TextAlign.center,
                          style: text.titleLarge?.copyWith(
                            color: onScene,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Center(child: GoldRule(width: 120)),
                        const SizedBox(height: 12),

                        // ---- The destination, framed ----
                        const ArtPanel(
                          key: Key('onboarding-destination'),
                          asset: AppArt.oasisArrival,
                          width: double.infinity,
                          height: 148,
                          radius: 18,
                          glow: true,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.onboardingWelcomeTitle,
                          textAlign: TextAlign.center,
                          style: text.headlineSmall?.copyWith(
                            color: OrnatePalette.gold,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.onboardingWelcomeSubtitle,
                          textAlign: TextAlign.center,
                          style: text.bodyMedium?.copyWith(color: colors.onSceneDim, height: 1.35),
                        ),
                        const SizedBox(height: 14),

                        // ---- Language: the one setting worth asking here ----
                        _SectionLabel(l10n.chooseLanguage),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final (code, name) in _languages)
                              _LanguageChip(
                                key: ValueKey('lang-$code'),
                                label: name,
                                selected: code == current,
                                onTap: () =>
                                    ref.read(settingsControllerProvider.notifier).setLanguage(code),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.onboardingLanguageHint,
                          textAlign: TextAlign.center,
                          style: text.labelSmall?.copyWith(color: colors.onSceneDim),
                        ),
                        const SizedBox(height: 14),

                        // ---- The three gestures of a turn ----
                        _SectionLabel(l10n.onboardingHowTo),
                        const SizedBox(height: 8),
                        OrnateFrame(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // A hairline gutter between the columns: the
                            // three lines of copy must never touch, at any
                            // text size or in any language.
                            spacing: 10,
                            children: [
                              // The game's own pieces, not icons: the
                              // deck's card back, the board's bonus
                              // medallion, and a horse from the plate.
                              _Step(
                                number: 1,
                                picture: const CardBack(width: 36, height: 50),
                                label: l10n.onboardingStepDraw,
                              ),
                              _Step(
                                number: 2,
                                picture: const BonusMedallion(value: 5, size: 46, glow: 0.6),
                                label: l10n.onboardingStepAnswer,
                              ),
                              _Step(
                                number: 3,
                                picture: Image.asset(
                                  'assets/board/horses/horse_emerald.webp',
                                  height: 52,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.medium,
                                  errorBuilder: (_, _, _) => const SizedBox(width: 40, height: 52),
                                ),
                                label: l10n.onboardingStepRide,
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
                // at the largest text.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: ContentWidth(
                    child: FilledButton(
                      onPressed: () => _finish(context, ref),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.goldAccent,
                        foregroundColor: const Color(0xFF231705),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      child: ButtonLabel(l10n.getStarted),
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

  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('iqraquest.onboarding.complete', true);
    await ref
        .read(settingsControllerProvider.notifier)
        .setLanguage(ref.read(effectiveLanguageProvider));
    if (context.mounted) context.go('/home');
  }
}

/// A small gold eyebrow over a section.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelMedium
          ?.copyWith(color: OrnatePalette.gold, fontWeight: FontWeight.w800, letterSpacing: 1.6),
    );
  }
}

/// One language, as a pill. The chosen one is solid gold on dark ink;
/// the others are outlined, so the current choice is read at a glance.
class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFEBC06A);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? gold : const Color(0x3300231A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: selected ? gold : gold.withValues(alpha: 0.55), width: 1.1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? const Color(0xFF231705) : const Color(0xFFF4ECDC),
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One of the three gestures: a numbered gold disc, the game's own piece
/// for it, and one line of copy — read in a glance, left to right.
class _Step extends StatelessWidget {
  const _Step({required this.number, required this.picture, required this.label});

  final int number;
  final Widget picture;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 58,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                picture,
                Positioned(
                  top: -4,
                  left: 4,
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFF3D68A), Color(0xFFDBA83E)],
                      ),
                      boxShadow: [BoxShadow(color: Color(0x80000000), blurRadius: 6)],
                    ),
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Color(0xFF3A2A08),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // The copy is kept inside its own column: a gutter here plus
          // the row's spacing means two neighbouring lines can never
          // run into each other, however long the translation.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              label,
              key: ValueKey('step-label-$number'),
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: colors.onScene, height: 1.25, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
