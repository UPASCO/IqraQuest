import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'ornate_frame.dart';

/// The prize of a right answer, shown as an event rather than a number.
///
/// The card announced its stake when it turned over; this is that stake
/// paid out, as a moment rather than a number. It arrives here: a shaft
/// of light opens, a gold medallion drops onto the table and turns as it
/// lands, a shockwave rides out through a crown of rays, sparks fly, and
/// the number **counts up** to its value under a ribbon that reads
/// "Gagné 5 galops". Nothing else on the screen moves during it.
///
/// One beat long (the reward duration), then the board takes over: the
/// player is already looking for a horse to give the gallops to.
class EarnedStepsMedallion extends StatefulWidget {
  const EarnedStepsMedallion({
    super.key,
    required this.value,
    required this.caption,
    this.size = 150,
  });

  final int value;
  final String caption;
  final double size;

  @override
  State<EarnedStepsMedallion> createState() => _EarnedStepsMedallionState();
}

class _EarnedStepsMedallionState extends State<EarnedStepsMedallion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppMotion.of(context, const Duration(milliseconds: 1250)),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return Semantics(
      liveRegion: true,
      label: widget.caption,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final t = _c.value;
            // The landing: an overshoot that settles, so the medallion
            // reads as a struck object and not a fading image.
            final land = Curves.easeOutCubic.transform(
              (t / 0.42).clamp(0.0, 1.0),
            );
            final pop = Curves.easeOutBack.transform(land);
            final rotation = (1 - land) * -0.55;
            // A short shiver right after it lands — the table taking the
            // weight — then perfectly still.
            final settle = ((t - 0.42) / 0.22).clamp(0.0, 1.0);
            final shiver = settle < 1
                ? math.sin(settle * math.pi * 3) * (1 - settle) * size * 0.012
                : 0.0;
            // The number climbs to its value: a count-up makes 5 feel
            // like more than 2 without any extra copy.
            final counted = (widget.value * Curves.easeOutCubic.transform(
              ((t - 0.18) / 0.34).clamp(0.0, 1.0),
            )).round().clamp(t < 0.18 ? 0 : 1, widget.value);

            return SizedBox(
              width: size * 2.1,
              height: size * 2.1 + 52,
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    child: SizedBox(
                      width: size * 2.1,
                      height: size * 2.1,
                      child: CustomPaint(painter: _RewardBurstPainter(t: t)),
                    ),
                  ),
                  Positioned(
                    top: size * 0.55 + shiver,
                    child: Opacity(
                      opacity: land.clamp(0.0, 1.0),
                      child: Transform.rotate(
                        angle: rotation,
                        child: Transform.scale(
                          scale: 0.25 + 0.75 * pop,
                          child: SizedBox(
                            width: size,
                            height: size,
                            child: CustomPaint(
                              painter: _MedallionFacePainter(shine: t),
                              child: Center(
                                child: Text(
                                  '$counted',
                                  style: TextStyle(
                                    fontSize: size * 0.5,
                                    height: 1,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFFFF0C2),
                                    shadows: const [
                                      Shadow(
                                        color: Color(0xCC000000),
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // The ribbon: the words arrive after the object, so the
                  // eye reads the medallion first and the sentence second.
                  Positioned(
                    top: size * 1.72,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: ((t - 0.40) / 0.24).clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          (1 - ((t - 0.40) / 0.24).clamp(0.0, 1.0)) * 14,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          child: Center(child: _Ribbon(text: widget.caption)),
        ),
      ),
    );
  }
}

/// The caption on a gold-ruled plaque, so the sentence is part of the
/// object rather than type floating over the board.
class _Ribbon extends StatelessWidget {
  const _Ribbon({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xF20C2B22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEBC06A), width: 1.4),
        boxShadow: const [
          BoxShadow(color: Color(0x99000000), blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: OrnatePalette.gold,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// The medallion itself: brushed gold, an engraved double ring, eight
/// small stars round the rim — the plate's own frame motif — with a
/// highlight that sweeps across it once as it lands.
class _MedallionFacePainter extends CustomPainter {
  const _MedallionFacePainter({required this.shine});

  /// 0..1 through the whole beat; drives the sweeping highlight.
  final double shine;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(
      c + Offset(0, r * 0.08),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.16),
    );
    // A gold ring around a deep sapphire heart — the result shield of
    // the owner's reference sheets — so the number sits on blue and the
    // rim catches the light.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.linear(
          c + Offset(-r, -r),
          c + Offset(r, r),
          const [Color(0xFFFFEDB4), Color(0xFFE2B75B), Color(0xFFB7862A)],
          const [0, 0.55, 1],
        ),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..color = const Color(0xFF5A3D10),
    );
    canvas.drawCircle(
      c,
      r * 0.78,
      Paint()
        ..shader = ui.Gradient.radial(
          c + Offset(-r * 0.2, -r * 0.25),
          r * 0.9,
          const [Color(0xFF2F6BC4), Color(0xFF16408F), Color(0xFF0B2350)],
          const [0, 0.55, 1],
        ),
    );
    canvas.drawCircle(
      c,
      r * 0.78,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.035
        ..color = const Color(0xFF6B4A14).withValues(alpha: 0.8),
    );
    canvas.drawCircle(
      c,
      r * 0.72,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.02
        ..color = const Color(0xFFFFF6DC).withValues(alpha: 0.5),
    );
    final star = Paint()..color = const Color(0xFF6B4A14).withValues(alpha: 0.75);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final p = Offset(c.dx + math.cos(a) * r * 0.93, c.dy + math.sin(a) * r * 0.93);
      _star(canvas, p, r * 0.045, star);
    }
    // A highlight arc, top-left.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.92),
      math.pi * 1.1,
      math.pi * 0.55,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.05
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.5),
    );
    // One pass of light across the face, once the medallion has landed.
    final sweep = ((shine - 0.45) / 0.35).clamp(0.0, 1.0);
    if (sweep > 0 && sweep < 1) {
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
      final x = c.dx + (sweep * 2.6 - 1.3) * r;
      canvas.drawRect(
        Rect.fromLTWH(x - r * 0.35, c.dy - r * 1.2, r * 0.7, r * 2.4),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(x - r * 0.35, 0),
            Offset(x + r * 0.35, 0),
            [
              const Color(0x00FFFFFF),
              Colors.white.withValues(alpha: 0.42 * math.sin(sweep * math.pi)),
              const Color(0x00FFFFFF),
            ],
            const [0, 0.5, 1],
          ),
      );
      canvas.restore();
    }
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final radius = i.isEven ? r : r * 0.45;
      final a = -math.pi / 2 + i * math.pi / 4;
      final p = Offset(c.dx + radius * math.cos(a), c.dy + radius * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path..close(), paint);
  }

  @override
  bool shouldRepaint(_MedallionFacePainter old) => old.shine != shine;
}

/// Everything thrown as the medallion lands: a warm pool of light, a
/// slowly turning crown of rays, a shockwave ring and a spray of sparks
/// that fall back under their own weight.
class _RewardBurstPainter extends CustomPainter {
  const _RewardBurstPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.5);
    final r = size.shortestSide / 2;

    // The pool of light: up fast, then held.
    final glow = Curves.easeOut.transform((t / 0.3).clamp(0.0, 1.0));
    canvas.drawCircle(
      c,
      r * 0.85,
      Paint()
        ..shader = ui.Gradient.radial(c, r * 0.85, [
          const Color(0xFFF3D68A).withValues(alpha: 0.60 * glow),
          const Color(0xFFF3D68A).withValues(alpha: 0.16 * glow),
          const Color(0x00F3D68A),
        ], const [0, 0.55, 1]),
    );

    // A crown of rays, opening out and turning a few degrees: the light
    // behind the object, not another object.
    final rays = Curves.easeOutCubic.transform((t / 0.5).clamp(0.0, 1.0));
    if (rays > 0) {
      final fade = (1 - ((t - 0.55) / 0.45).clamp(0.0, 1.0));
      final spin = t * 0.22;
      final paint = Paint()..color = const Color(0xFFFFE9AE).withValues(alpha: 0.28 * rays * fade);
      for (var i = 0; i < 16; i++) {
        final a = spin + i * math.pi / 8;
        final long = i.isEven ? 1.0 : 0.66;
        final inner = r * 0.30;
        final outer = r * (0.34 + 0.62 * rays * long);
        final w = (i.isEven ? 0.055 : 0.032) * math.pi;
        final path = Path()
          ..moveTo(c.dx + math.cos(a - w) * inner, c.dy + math.sin(a - w) * inner)
          ..lineTo(c.dx + math.cos(a) * outer, c.dy + math.sin(a) * outer)
          ..lineTo(c.dx + math.cos(a + w) * inner, c.dy + math.sin(a + w) * inner)
          ..close();
        canvas.drawPath(path, paint);
      }
    }

    // The shockwave: one ring riding out and thinning to nothing.
    final ring = ((t - 0.28) / 0.55).clamp(0.0, 1.0);
    if (ring > 0 && ring < 1) {
      canvas.drawCircle(
        c,
        r * (0.30 + 0.68 * Curves.easeOutCubic.transform(ring)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.07 * (1 - ring) + 1
          ..color = const Color(0xFFFFE9AE).withValues(alpha: 0.85 * (1 - ring)),
      );
    }

    // Sparks: out on an arc, then falling — gravity is what stops them
    // reading as a ring of dots.
    final sparkT = ((t - 0.24) / 0.70).clamp(0.0, 1.0);
    if (sparkT > 0) {
      final eased = Curves.easeOutCubic.transform(sparkT);
      for (var i = 0; i < 18; i++) {
        final a = i * math.pi / 9 + (i.isEven ? 0.17 : -0.11);
        final reach = (i % 3 == 0 ? 1.0 : i.isEven ? 0.84 : 0.70);
        final d = r * (0.34 + 0.62 * eased) * reach;
        final fall = r * 0.34 * sparkT * sparkT * reach;
        final p = Offset(c.dx + math.cos(a) * d, c.dy + math.sin(a) * d + fall);
        canvas.drawCircle(
          p,
          r * 0.026 * (1 - sparkT * 0.55) + 0.6,
          Paint()
            ..color = (i % 4 == 0
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFFFFE7A6))
                .withValues(alpha: (1 - sparkT).clamp(0.0, 1.0)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RewardBurstPainter old) => old.t != t;
}
