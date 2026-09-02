import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'ornate_frame.dart';

/// The prize of a right answer, shown as an object rather than a number:
/// a gold medallion that drops onto the table, turns a quarter as it
/// lands, throws a ring of light and a few sparks, and holds the value
/// large enough to read across a room. Under it, the caption says what
/// the value is — "5 cases gagnées" — so the number is never bare.
///
/// One beat long (the reward duration), then the board takes over: the
/// player is already looking for a horse.
class EarnedStepsMedallion extends StatelessWidget {
  const EarnedStepsMedallion({
    super.key,
    required this.value,
    required this.caption,
    this.size = 168,
  });

  final int value;
  final String caption;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: caption,
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppMotion.of(context, const Duration(milliseconds: 820)),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) {
            final pop = Curves.easeOutBack.transform(t.clamp(0.0, 1.0));
            final rotation = (1 - t) * -0.45;
            return SizedBox(
              width: size * 1.9,
              height: size * 1.9 + 44,
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    child: SizedBox(
                      width: size * 1.9,
                      height: size * 1.9,
                      child: CustomPaint(
                        painter: _MedallionBurstPainter(t: t),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size * 0.45,
                    child: Opacity(
                      opacity: t.clamp(0.0, 1.0),
                      child: Transform.rotate(
                        angle: rotation,
                        child: Transform.scale(
                          scale: 0.3 + 0.7 * pop,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size * 1.55,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: ((t - 0.45) / 0.4).clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, (1 - t) * 10),
                        child: Text(
                          caption,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: OrnatePalette.ivory,
                            fontWeight: FontWeight.w800,
                            shadows: const [
                              Shadow(color: Color(0xCC000000), blurRadius: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _MedallionFacePainter(),
              child: Center(
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: size * 0.5,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFF0C2),
                    shadows: const [
                      Shadow(color: Color(0xCC000000), offset: Offset(0, 2), blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The medallion itself: brushed gold, an engraved double ring, eight
/// small stars round the rim — the plate's own frame motif.
class _MedallionFacePainter extends CustomPainter {
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
  bool shouldRepaint(_MedallionFacePainter old) => false;
}

/// The ring of light and the sparks thrown as the medallion lands.
class _MedallionBurstPainter extends CustomPainter {
  const _MedallionBurstPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.5);
    final r = size.shortestSide / 2;
    // Glow behind.
    canvas.drawCircle(
      c,
      r * 0.7,
      Paint()
        ..shader = ui.Gradient.radial(c, r * 0.7, [
          const Color(0xFFF3D68A).withValues(alpha: 0.55 * t),
          const Color(0x00F3D68A),
        ]),
    );
    // Expanding ring.
    final ring = ((t - 0.2) / 0.8).clamp(0.0, 1.0);
    if (ring > 0) {
      canvas.drawCircle(
        c,
        r * (0.35 + 0.65 * ring),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.06 * (1 - ring) + 1
          ..color = const Color(0xFFFFE9AE).withValues(alpha: 0.8 * (1 - ring)),
      );
    }
    // Sparks.
    final sparkT = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
    if (sparkT > 0) {
      final paint = Paint()..color = const Color(0xFFFFF0C2).withValues(alpha: 1 - sparkT);
      for (var i = 0; i < 12; i++) {
        final a = i * math.pi / 6 + (i.isEven ? 0.15 : -0.1);
        final d = r * (0.45 + 0.55 * Curves.easeOut.transform(sparkT)) * (i % 3 == 0 ? 1.0 : 0.82);
        final p = Offset(c.dx + math.cos(a) * d, c.dy + math.sin(a) * d);
        canvas.drawCircle(p, r * 0.03 * (1 - sparkT * 0.6) + 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_MedallionBurstPainter old) => old.t != t;
}
