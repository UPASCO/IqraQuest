import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'board/bonus_tile_painter.dart';
import 'ornate_frame.dart';

/// "BONUS +10" — shouted the moment a horse stops on a bonus square,
/// before it rides on. The medallion of the square itself scales in
/// over a burst of rays, the word BONUS above it and the value under it;
/// a +20 throws more rays, a second ring and a sweep of light across its
/// star. Elegant and short: one beat, then the ride.
class BonusCallout extends StatelessWidget {
  const BonusCallout({
    super.key,
    required this.value,
    required this.label,
    required this.valueText,
  });

  final int value;

  /// "BONUS", localized.
  final String label;

  /// "+10 cases", localized.
  final String valueText;

  @override
  Widget build(BuildContext context) {
    final big = value >= 20;
    final medal = big ? 132.0 : 108.0;
    return Semantics(
      liveRegion: true,
      label: '$label $valueText',
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppMotion.of(context, Duration(milliseconds: big ? 1000 : 800)),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) {
            final pop = Curves.easeOutBack.transform(t.clamp(0.0, 1.0));
            return SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: const Size(300, 300),
                    painter: _BonusBurstPainter(t: t, big: big),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: ((t - 0.15) / 0.35).clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, (1 - t) * -12),
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: OrnatePalette.ivory,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              shadows: const [
                                Shadow(color: Color(0xCC000000), blurRadius: 12),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Transform.scale(
                        scale: 0.2 + 0.8 * pop,
                        child: Transform.rotate(
                          angle: (1 - t) * (big ? 0.8 : 0.4),
                          child: BonusMedallion(
                            value: value,
                            size: medal,
                            glow: 1,
                            shimmer: big ? (t * 1.6).clamp(0.0, 1.0) : 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Opacity(
                        opacity: ((t - 0.35) / 0.35).clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, (1 - t) * 12),
                          child: Text(
                            valueText,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: const Color(0xFFFFE9AE),
                              fontWeight: FontWeight.w900,
                              shadows: const [
                                Shadow(color: Color(0xCC000000), blurRadius: 12),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BonusBurstPainter extends CustomPainter {
  const _BonusBurstPainter({required this.t, required this.big});

  final double t;
  final bool big;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.radial(c, r, [
          const Color(0xFFF3D68A).withValues(alpha: (big ? 0.7 : 0.5) * t),
          const Color(0x00F3D68A),
        ]),
    );
    final rays = big ? 16 : 10;
    final ray = Paint()..color = const Color(0xFFFFE9AE).withValues(alpha: (big ? 0.55 : 0.4) * t);
    final spin = (1 - t) * 0.6;
    for (var i = 0; i < rays; i++) {
      final a = i * 2 * math.pi / rays + spin;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(a);
      final len = r * (0.5 + 0.5 * t) * (i.isEven ? 1.0 : 0.78);
      canvas.drawPath(
        Path()
          ..moveTo(0, -r * 0.28)
          ..lineTo(r * 0.045, -len)
          ..lineTo(-r * 0.045, -len)
          ..close(),
        ray,
      );
      canvas.restore();
    }
    final ring = ((t - 0.25) / 0.75).clamp(0.0, 1.0);
    if (ring > 0) {
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.05 * (1 - ring) + 1
        ..color = const Color(0xFFFFF0C2).withValues(alpha: 0.85 * (1 - ring));
      canvas.drawCircle(c, r * (0.35 + 0.65 * ring), ringPaint);
      if (big) {
        final ring2 = ((t - 0.45) / 0.55).clamp(0.0, 1.0);
        canvas.drawCircle(
          c,
          r * (0.3 + 0.7 * ring2),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.04 * (1 - ring2) + 1
            ..color = const Color(0xFFFFE08A).withValues(alpha: 0.7 * (1 - ring2)),
        );
      }
    }
    final sparkT = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
    if (sparkT > 0) {
      final n = big ? 20 : 10;
      final paint = Paint()..color = const Color(0xFFFFF6DC).withValues(alpha: 1 - sparkT);
      for (var i = 0; i < n; i++) {
        final a = i * 2 * math.pi / n + (i.isEven ? 0.2 : -0.15);
        final d = r * (0.4 + 0.6 * Curves.easeOut.transform(sparkT)) * (i % 3 == 0 ? 1.0 : 0.8);
        canvas.drawCircle(
          Offset(c.dx + math.cos(a) * d, c.dy + math.sin(a) * d),
          r * 0.025 * (1 - sparkT * 0.5) + 0.5,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BonusBurstPainter old) => old.t != t || old.big != big;
}
