import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A procedurally generated eight-point star lattice — the app's one
/// recurring geometric-motif texture (spec §21: "subtle, secondary, low
/// contrast"). Never traced from a copyrighted source; pure math.
///
/// Always paint this at low opacity (≤ ~8%) via the [opacity] parameter —
/// it is a texture, not a foreground illustration (spec §22: avoid
/// "orientalist" over-decoration).
class GeometricMotifPainter extends CustomPainter {
  const GeometricMotifPainter({required this.color, this.opacity = 0.06, this.cellSize = 28});

  final Color color;
  final double opacity;
  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final cols = (size.width / cellSize).ceil() + 1;
    final rows = (size.height / cellSize).ceil() + 1;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final center = Offset(col * cellSize, row * cellSize);
        canvas.drawPath(_eightPointStar(center, cellSize * 0.42), paint);
      }
    }
  }

  Path _eightPointStar(Offset center, double r) {
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final angle = (math.pi / 8) * i;
      final radius = i.isEven ? r : r * 0.55;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant GeometricMotifPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity ||
      oldDelegate.cellSize != cellSize;
}

/// Convenience widget: paints the motif behind [child], clipped to its
/// bounds.
class GeometricMotifBackground extends StatelessWidget {
  const GeometricMotifBackground({super.key, required this.child, this.opacity = 0.06, this.color});

  final Widget child;
  final double opacity;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.onSurface;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: GeometricMotifPainter(color: tint, opacity: opacity),
          ),
        ),
        child,
      ],
    );
  }
}
