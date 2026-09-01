import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import 'button_label.dart';
import 'geometric_motif_painter.dart';

/// How long the turned card is held on screen before the question
/// arrives. Long enough to read the value, short enough that a four
/// player game never drags.
const Duration kCardRevealDuration = Duration(milliseconds: 1150);

/// The face-down deck the player taps to start a turn.
///
/// A turn no longer begins with picking a distance: the player draws a
/// question card, and the value on it is both the distance and the
/// difficulty. So this is one target, not six — the fastest possible
/// turn opening.
class DrawDeck extends StatelessWidget {
  const DrawDeck({super.key, required this.onDraw, this.horseHint, this.enabled = true});

  final VoidCallback onDraw;

  /// "Cheval 2" and the like, shown only when the player has a choice.
  final String? horseHint;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    // Deliberately no idle animation: a deck that pulses forever costs
    // battery on every turn and never lets a widget test settle. The
    // motion in this flow belongs to the draw itself.
    return Semantics(
      button: true,
      enabled: enabled,
      label: l10n.drawCard,
      child: Material(
        color: const Color(0xE60B2A20),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: enabled ? onDraw : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Row(
              children: [
                const _DeckStack(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.drawCard,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colors.onScene,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (horseHint != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          horseHint!,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colors.onSceneDim),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.touch_app, color: colors.goldAccent, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Three stacked card backs, so the deck reads as a deck at a glance.
class _DeckStack extends StatelessWidget {
  const _DeckStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final i in const [2, 1, 0])
            Transform.translate(
              offset: Offset(i * 3.0, i * -3.0),
              child: Transform.rotate(
                angle: i * 0.055,
                child: const _CardBack(width: 46, height: 62),
              ),
            ),
        ],
      ),
    );
  }
}

/// The back of a card: deep green, gold rim, the app's geometric motif.
class _CardBack extends StatelessWidget {
  const _CardBack({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF11543E), Color(0xFF06251C)],
        ),
        border: Border.all(color: colors.goldAccent.withValues(alpha: 0.75), width: 1.4),
        boxShadow: const [
          BoxShadow(color: Color(0x73000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: GeometricMotifBackground(
        opacity: 0.22,
        color: colors.goldAccent,
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// The freshly drawn card, turning over to show what it is worth.
///
/// This is the moment the die used to be: the player has no more
/// decisions to make about distance, so the reveal has to carry the
/// weight — the card lifts, flips, and lands on its value.
class DrawnCardReveal extends StatefulWidget {
  const DrawnCardReveal({super.key, required this.value, required this.difficultyPips});

  /// 1..6 — the squares earned and the tier of the question.
  final int value;

  /// How hard the question is, 1..3, shown as filled pips.
  final int difficultyPips;

  @override
  State<DrawnCardReveal> createState() => _DrawnCardRevealState();
}

class _DrawnCardRevealState extends State<DrawnCardReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: MediaQuery.maybeDisableAnimationsOf(context) ?? false
        ? Duration.zero
        : const Duration(milliseconds: 720),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(_c.value);
          // Half a turn: the back faces the player until the midpoint,
          // then the face swings into view.
          final angle = t * math.pi;
          final showingFace = angle > math.pi / 2;
          final lift = (1 - t) * 90;
          final scale = 0.72 + 0.28 * t;

          return Transform.translate(
            offset: Offset(0, lift),
            child: Transform.scale(
              scale: scale,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(angle),
                child: showingFace
                    // The face is drawn behind the flip, so it has to be
                    // turned back over or it renders mirrored.
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: _CardFace(
                          value: widget.value,
                          difficultyPips: widget.difficultyPips,
                          title: l10n.drawnCardTitle,
                          worth: l10n.cardWorth(widget.value),
                        ),
                      )
                    : const _CardBack(width: 190, height: 256),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.value,
    required this.difficultyPips,
    required this.title,
    required this.worth,
  });

  final int value;
  final int difficultyPips;
  final String title;
  final String worth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 190,
      height: 256,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: colors.surfaceElevated,
        border: Border.all(color: colors.goldAccent, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x8C000000), blurRadius: 30, offset: Offset(0, 12)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: GeometricMotifBackground(
        opacity: 0.06,
        color: colors.goldAccent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonLabel(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.textSecondary,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              Text(
                '$value',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const Spacer(),
              // Difficulty is not a separate fact to learn: on this card
              // the value IS the tier, so the pips only restate it.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < difficultyPips
                              ? colors.goldAccent
                              : colors.divider,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ButtonLabel(
                worth,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
