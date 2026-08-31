import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/gait_cycle.dart';
import '../models/movement_choice.dart';
import '../models/question_category.dart';
import '../theme/app_theme.dart';

/// The six gaits, drawn as horseshoes.
///
/// This is what replaced the dice, so it deliberately looks nothing like
/// one: no cube, no wheel, no spinner, nothing that reads as a gamble
/// (spec §25). Each shoe states exactly what the player is signing up for
/// — how far they move, how hard the question will be, and what it is
/// worth — because the whole point of the mechanic is that the trade-off
/// is known before you commit.
///
/// Nothing here relies on color alone: the number is the primary label,
/// difficulty is a count of filled pips, and used shoes are visibly
/// hollowed out as well as dimmed.
class GaitSelector extends StatelessWidget {
  const GaitSelector({
    super.key,
    required this.cycle,
    required this.onSelected,
    this.selected,
    this.enabled = true,
    this.difficultyFor,
  });

  final GaitCycle cycle;
  final ValueChanged<MovementChoice> onSelected;
  final MovementChoice? selected;
  final bool enabled;

  /// Resolves the difficulty actually drawn for this player, which varies
  /// by profile (a child's "bold" gait stays age-appropriate).
  final QuestionDifficulty Function(MovementChoice)? difficultyFor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Six across on a wide screen, two rows of three when narrow.
        final perRow = constraints.maxWidth > 460 ? 6 : 3;
        final spacing = 8.0;
        final tile = (constraints.maxWidth - spacing * (perRow - 1)) / perRow;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final choice in MovementChoice.all)
              SizedBox(
                width: tile,
                child: _GaitTile(
                  choice: choice,
                  available: cycle.isAvailable(choice),
                  selected: selected == choice,
                  enabled: enabled,
                  difficulty: difficultyFor?.call(choice) ?? choice.difficulty,
                  onTap: () => onSelected(choice),
                  l10n: l10n,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GaitTile extends StatefulWidget {
  const _GaitTile({
    required this.choice,
    required this.available,
    required this.selected,
    required this.enabled,
    required this.difficulty,
    required this.onTap,
    required this.l10n,
  });

  final MovementChoice choice;
  final bool available;
  final bool selected;
  final bool enabled;
  final QuestionDifficulty difficulty;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  @override
  State<_GaitTile> createState() => _GaitTileState();
}

class _GaitTileState extends State<_GaitTile> with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    lowerBound: 0,
    upperBound: 1,
  );

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final interactive = widget.enabled && widget.available;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final difficultyLabel = switch (widget.difficulty) {
      QuestionDifficulty.easy => widget.l10n.difficultyEasy,
      QuestionDifficulty.medium => widget.l10n.difficultyMedium,
      QuestionDifficulty.hard => widget.l10n.difficultyHard,
    };
    final pips = switch (widget.difficulty) {
      QuestionDifficulty.easy => 1,
      QuestionDifficulty.medium => 2,
      QuestionDifficulty.hard => 3,
    };

    return Semantics(
      button: true,
      enabled: interactive,
      selected: widget.selected,
      // Screen readers get the whole trade-off in one sentence, in order:
      // distance, difficulty, reward, availability.
      label: widget.l10n.gaitSemanticLabel(
        widget.choice.steps,
        difficultyLabel,
        widget.choice.knowledgePoints,
      ),
      hint: widget.available ? null : widget.l10n.gaitAlreadyUsed,
      child: GestureDetector(
        onTapDown: interactive && !reduceMotion ? (_) => _press.forward() : null,
        onTapUp: interactive && !reduceMotion ? (_) => _press.reverse() : null,
        onTapCancel: interactive && !reduceMotion ? () => _press.reverse() : null,
        onTap: interactive ? widget.onTap : null,
        child: AnimatedBuilder(
          animation: _press,
          builder: (context, child) =>
              Transform.scale(scale: 1 - _press.value * 0.06, child: child),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: widget.available ? 1 : 0.42,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 0.92,
                  child: CustomPaint(
                    painter: HorseshoePainter(
                      steps: widget.choice.steps,
                      used: !widget.available,
                      selected: widget.selected,
                      shoe: colors.goldAccent,
                      face: colors.surfaceElevated,
                      ink: colors.textPrimary,
                      accent: colors.primary,
                      // The number is text, so it must be set in the
                      // app's own face, not the platform default.
                      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.l10n.gaitSquares(widget.choice.steps),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 3),
                // Difficulty as a pip count: readable without color.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < pips ? colors.secondary : colors.divider,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A horseshoe with the gait number set in its opening.
///
/// Drawn rather than iconified so the "used" state can hollow the shoe out
/// (a real state change in the silhouette, not just a tint) and so the
/// whole selector scales cleanly on any density.
class HorseshoePainter extends CustomPainter {
  const HorseshoePainter({
    required this.steps,
    required this.used,
    required this.selected,
    required this.shoe,
    required this.face,
    required this.ink,
    required this.accent,
    this.fontFamily,
  });

  final int steps;
  final bool used;
  final bool selected;
  final Color shoe;
  final Color face;
  final Color ink;
  final Color accent;
  final String? fontFamily;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.5);
    final r = size.shortestSide * 0.36;
    final band = size.shortestSide * 0.155;

    if (selected) {
      canvas.drawCircle(
        c,
        r * 1.32,
        Paint()
          ..color = accent.withValues(alpha: 0.18)
          ..style = PaintingStyle.fill,
      );
    }

    // The shoe: a thick arc open at the bottom, with the heels flared.
    final rect = Rect.fromCircle(center: c, radius: r);
    final shoePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = band
      ..strokeCap = StrokeCap.round
      ..color = used ? shoe.withValues(alpha: 0.45) : shoe;

    if (used) {
      shoePaint.strokeWidth = band * 0.42;
    }

    // From 150° round the top to 30° — an upright U.
    canvas.drawArc(rect, math.pi * 0.82, math.pi * 1.36, false, shoePaint);

    if (!used) {
      // Inner highlight so the metal reads as forged, not as a flat ring.
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r - band * 0.28),
        math.pi * 0.9,
        math.pi * 1.2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = band * 0.16
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.4),
      );

      // Nail holes along the band.
      final holePaint = Paint()..color = ink.withValues(alpha: 0.28);
      for (var i = 0; i < 6; i++) {
        final t = math.pi * 0.92 + (math.pi * 1.16) * (i / 5);
        final p = Offset(c.dx + r * math.cos(t), c.dy + r * math.sin(t));
        canvas.drawCircle(p, band * 0.11, holePaint);
      }
    }

    // The number, set in the shoe's opening — the primary label.
    final painter = TextPainter(
      text: TextSpan(
        text: '$steps',
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: size.shortestSide * 0.36,
          fontWeight: FontWeight.w700,
          color: used ? ink.withValues(alpha: 0.5) : ink,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, c - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant HorseshoePainter old) =>
      old.steps != steps ||
      old.used != used ||
      old.selected != selected ||
      old.shoe != shoe ||
      old.ink != ink;
}
