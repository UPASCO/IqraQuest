import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The plate's own colours, so every framed panel reads as one object
/// with the board: deep teal ground, pale gold hairline, deeper gold
/// shadow line.
class OrnatePalette {
  const OrnatePalette._();

  static const ground = Color(0xFF0F3A3E);
  static const groundDeep = Color(0xFF0A2A2E);
  static const gold = Color(0xFFEED38A);
  static const goldDeep = Color(0xFFC59F4A);
  static const ivory = Color(0xFFF4ECDC);
  static const ivoryDim = Color(0xB3F4ECDC);
}

/// The board plate's frame, lifted off the artwork: a double gold rule
/// with an eight-point star riding each corner. One motif, reused on the
/// hero panels (welcome, journey card, deck, score card) so the app's
/// screens and its board belong to the same set.
class OrnateFrame extends StatelessWidget {
  const OrnateFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.inset = 10,
    this.radius = 6,
    this.fill = OrnatePalette.ground,
    this.gradient,
    this.starSize = 14,
  });

  final Widget child;

  /// Room between the frame lines and the content.
  final EdgeInsets padding;

  /// Distance from the panel edge to the outer gold rule; the inner rule
  /// sits a hair inside it and the star rides on their crossing.
  final double inset;
  final double radius;
  final Color fill;
  final Gradient? gradient;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? fill : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: OrnateFramePainter(inset: inset, starSize: starSize),
        child: Padding(
          padding: EdgeInsets.all(inset + 6) + padding,
          child: child,
        ),
      ),
    );
  }
}

/// The double rule and corner stars alone, for surfaces that bring their
/// own fill (the card back, the score card).
class OrnateFramePainter extends CustomPainter {
  const OrnateFramePainter({required this.inset, required this.starSize, this.gap = 4, this.thin = 1.2, this.thick = 2.2});

  final double inset;
  final double starSize;
  final double gap;
  final double thin;
  final double thick;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Rect.fromLTWH(inset, inset, size.width - 2 * inset, size.height - 2 * inset);
    final inner = outer.deflate(gap);

    final thinRule = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thin
      ..color = OrnatePalette.goldDeep;
    final thickRule = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thick
      ..color = OrnatePalette.gold;

    canvas.drawRect(outer, thinRule);
    canvas.drawRect(inner, thickRule);

    // One star per corner, seated on the rules' crossing exactly as on
    // the plate. Drawn last so it hides the mitre underneath.
    final fill = Paint()..color = OrnatePalette.gold;
    final shade = Paint()..color = OrnatePalette.goldDeep;
    for (final c in [outer.topLeft, outer.topRight, outer.bottomLeft, outer.bottomRight]) {
      _star(canvas, c, starSize, shade, offset: const Offset(0.8, 1.2));
      _star(canvas, c, starSize, fill);
    }
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint, {Offset offset = Offset.zero}) {
    final path = Path();
    const points = 8;
    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? r : r * 0.42;
      final a = -math.pi / 2 + i * math.pi / points;
      final p = Offset(c.dx + offset.dx + radius * math.cos(a), c.dy + offset.dy + radius * math.sin(a));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(OrnateFramePainter old) =>
      old.inset != inset || old.starSize != starSize || old.gap != gap;
}
