import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'ornate_frame.dart';

/// The plate's frame motif reduced to one line: a gold rule tapering to
/// nothing on both sides with the eight-point star riding its middle.
/// Used under a title, where a full frame would be too much.
class GoldRule extends StatelessWidget {
  const GoldRule({super.key, this.width = 160});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 14,
      child: CustomPaint(painter: _GoldRulePainter()),
    );
  }
}

class _GoldRulePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final gap = size.height * 0.75;
    final rule = Paint()
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        Offset(0, y),
        Offset(size.width, y),
        [
          OrnatePalette.goldDeep.withValues(alpha: 0),
          OrnatePalette.gold,
          OrnatePalette.gold,
          OrnatePalette.goldDeep.withValues(alpha: 0),
        ],
        const [0, 0.25, 0.75, 1],
      );
    canvas.drawLine(Offset(0, y), Offset(size.width / 2 - gap, y), rule);
    canvas.drawLine(Offset(size.width / 2 + gap, y), Offset(size.width, y), rule);

    final c = Offset(size.width / 2, y);
    final r = size.height * 0.44;
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final radius = i.isEven ? r : r * 0.42;
      final a = -math.pi / 2 + i * math.pi / 8;
      final p = Offset(c.dx + radius * math.cos(a), c.dy + radius * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(
      path.shift(const Offset(0.8, 1)),
      Paint()..color = OrnatePalette.goldDeep,
    );
    canvas.drawPath(path, Paint()..color = OrnatePalette.gold);
  }

  @override
  bool shouldRepaint(_GoldRulePainter old) => false;
}
