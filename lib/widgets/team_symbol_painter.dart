import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_team.dart';

/// Draws a [TeamSymbol] glyph centred on [center], sized to fit a circle
/// of radius [radius].
///
/// This is the non-color identity channel that keeps teams distinguishable
/// for colorblind players (DESIGN_SYSTEM.md §2: a team is always
/// color + symbol + horse coat, never color alone). It is shared by the
/// horse's saddle cloth, the board's stables and the player badges so a
/// team's mark is literally the same shape everywhere.
///
/// When [embossed] is true the glyph is drawn twice — a soft dark drop
/// first — which is what makes it read as woven into a saddle cloth
/// rather than pasted on top of it.
void paintTeamSymbol(
  Canvas canvas,
  Offset center,
  double radius,
  TeamSymbol symbol, {
  Color color = Colors.white,
  bool embossed = true,
  double strokeScale = 1.0,
}) {
  void draw(Color c, MaskFilter? blur) {
    final stroke = Paint()
      ..color = c
      ..maskFilter = blur
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.23 * strokeScale
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = c
      ..maskFilter = blur;

    switch (symbol) {
      case TeamSymbol.star:
        canvas.drawPath(_star(center, radius), fill);
      case TeamSymbol.compass:
        canvas.drawCircle(center, radius * 0.88, stroke);
        canvas.drawPath(
          Path()
            ..moveTo(center.dx, center.dy - radius * 0.7)
            ..lineTo(center.dx + radius * 0.25, center.dy)
            ..lineTo(center.dx, center.dy + radius * 0.7)
            ..lineTo(center.dx - radius * 0.25, center.dy)
            ..close(),
          fill,
        );
      case TeamSymbol.lantern:
        canvas.drawPath(
          Path()
            ..moveTo(center.dx, center.dy - radius)
            ..lineTo(center.dx + radius * 0.57, center.dy - radius * 0.39)
            ..lineTo(center.dx + radius * 0.45, center.dy + radius * 0.64)
            ..lineTo(center.dx - radius * 0.45, center.dy + radius * 0.64)
            ..lineTo(center.dx - radius * 0.57, center.dy - radius * 0.39)
            ..close(),
          fill,
        );
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + radius * 0.87),
            width: radius * 1.05,
            height: radius * 0.27,
          ),
          fill,
        );
      case TeamSymbol.book:
        final w = radius * 1.05;
        final h = radius * 0.6;
        canvas.drawPath(
          Path()
            ..moveTo(center.dx, center.dy - h * 0.95)
            ..quadraticBezierTo(
              center.dx - w * 0.5,
              center.dy - h * 1.4,
              center.dx - w,
              center.dy - h,
            )
            ..lineTo(center.dx - w, center.dy + h)
            ..quadraticBezierTo(
              center.dx - w * 0.5,
              center.dy + h * 0.6,
              center.dx,
              center.dy + h * 1.05,
            )
            ..quadraticBezierTo(
              center.dx + w * 0.5,
              center.dy + h * 0.6,
              center.dx + w,
              center.dy + h,
            )
            ..lineTo(center.dx + w, center.dy - h)
            ..quadraticBezierTo(
              center.dx + w * 0.5,
              center.dy - h * 1.4,
              center.dx,
              center.dy - h * 0.95,
            )
            ..close(),
          stroke,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - h * 0.95),
          Offset(center.dx, center.dy + h * 1.05),
          stroke,
        );
    }
  }

  if (embossed) {
    canvas.save();
    canvas.translate(0, radius * 0.16);
    draw(Colors.black.withValues(alpha: 0.30), MaskFilter.blur(BlurStyle.normal, radius * 0.14));
    canvas.restore();
  }
  draw(color, null);
}

/// The app's recurring eight-point star, also used as the geometric-motif
/// unit and the board's finish medallion.
Path eightPointStar(Offset center, double r, {double innerRatio = 0.55}) {
  final path = Path();
  for (var i = 0; i < 16; i++) {
    final angle = (math.pi / 8) * i - math.pi / 2;
    final radius = i.isEven ? r : r * innerRatio;
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

Path _star(Offset center, double radius) {
  final path = Path();
  for (var i = 0; i < 8; i++) {
    final angle = (math.pi / 4) * i - math.pi / 2;
    final r = i.isEven ? radius : radius * 0.42;
    final point = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  path.close();
  return path;
}
