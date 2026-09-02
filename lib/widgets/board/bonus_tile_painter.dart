import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// The three bonus medallions, drawn as inlays on the plate.
///
/// They are told apart by **shape and number**, never by colour alone:
/// a round emerald coin for +5, a sapphire octagon with a double ring
/// for +10, and the eight-point star (the *khatim*) in crimson for the
/// rare +20 — the same star the plate's frame carries at every corner,
/// so the bonus reads as part of the board's own ornament rather than a
/// sticker on it. All three wear the plate's gold rim and a small dome
/// crowning the number, after the owner's reference sheets. Every
/// medallion has an engraved edge and an embossed, high-contrast number
/// that stays legible at the size of one square on a phone.
class BonusTileArt {
  const BonusTileArt._();

  static const Color _emeraldLight = Color(0xFF4FC27A);
  static const Color _emeraldDeep = Color(0xFF0E6B3A);
  static const Color _sapphireLight = Color(0xFF5FA6F2);
  static const Color _sapphireDeep = Color(0xFF16408F);
  static const Color _crimsonLight = Color(0xFFF2604E);
  static const Color _crimsonDeep = Color(0xFF8E1424);
  static const Color _rim = Color(0xFFEED38A);
  static const Color _rimDeep = Color(0xFF8A6420);
  static const Color _ink = Color(0xFF1A1206);
  static const Color _ivory = Color(0xFFFFF6E0);

  /// Paints one medallion of [value] centred on [center], [diameter]
  /// wide. [glow] (0..1) adds the lit halo of a square that just fired
  /// or that a horse is about to stop on.
  static void paint(
    Canvas canvas,
    Offset center,
    double diameter,
    int value, {
    double glow = 0,
    double shimmer = 0,
  }) {
    final r = diameter / 2;
    if (glow > 0) {
      canvas.drawCircle(
        center,
        r * (1.35 + 0.5 * glow),
        Paint()
          ..color = const Color(0xFFFFE08A).withValues(alpha: 0.55 * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5),
      );
    }
    // Cast shadow: the inlay sits a hair proud of the plate.
    canvas.drawCircle(
      center + Offset(0, r * 0.12),
      r * 0.98,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.18),
    );

    final Path shape;
    final Color light, deep;
    switch (value) {
      case 20:
        shape = _starPath(center, r, points: 8, inner: 0.66);
        light = _crimsonLight;
        deep = _crimsonDeep;
      case 10:
        shape = _polygonPath(center, r * 0.96, sides: 8);
        light = _sapphireLight;
        deep = _sapphireDeep;
      default:
        shape = Path()..addOval(Rect.fromCircle(center: center, radius: r * 0.92));
        light = _emeraldLight;
        deep = _emeraldDeep;
    }

    // Body: a lit metal gradient, top-left to bottom-right.
    canvas.drawPath(
      shape,
      Paint()
        ..shader = ui.Gradient.linear(
          center + Offset(-r, -r),
          center + Offset(r, r),
          [light, deep],
        ),
    );
    if (shimmer > 0) {
      // A band of light sweeping across the gold star, for the +20 only.
      final x = -1.4 + 2.8 * shimmer;
      canvas.save();
      canvas.clipPath(shape);
      canvas.drawRect(
        Rect.fromCenter(center: center, width: r * 4, height: r * 4),
        Paint()
          ..shader = ui.Gradient.linear(
            center + Offset(r * (x - 0.5), -r),
            center + Offset(r * (x + 0.5), r),
            [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.55),
              Colors.white.withValues(alpha: 0),
            ],
            const [0, 0.5, 1],
          ),
      );
      canvas.restore();
    }
    // The gold rim, on a darker gold shadow line: the plate's own frame.
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.4, r * 0.16)
        ..color = _rimDeep,
    );
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, r * 0.10)
        ..color = _rim,
    );
    // Inner rule: a second ring on the +10 and +20, one on the +5.
    final inset = value == 5 ? r * 0.74 : r * 0.70;
    canvas.drawCircle(
      center,
      inset,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.8, r * 0.06)
        ..color = _rim.withValues(alpha: 0.55),
    );
    if (value >= 10) {
      canvas.drawCircle(
        center,
        inset - r * 0.11,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.6, r * 0.04)
          ..color = _ivory.withValues(alpha: 0.45),
      );
    }
    // A small gold dome over the number: the bonus is a place, a gate.
    _dome(canvas, center + Offset(0, -r * 0.52), r * 0.22);

    // The number, embossed: a dark shadow under an ivory face, and a
    // small "+" so the value reads as a gain even at a glance.
    _number(canvas, center, r, value);
  }

  static void _dome(Canvas canvas, Offset c, double r) {
    final path = Path()
      ..moveTo(c.dx - r, c.dy + r * 0.5)
      ..lineTo(c.dx - r, c.dy)
      ..arcToPoint(Offset(c.dx + r, c.dy), radius: Radius.circular(r), clockwise: true)
      ..lineTo(c.dx + r, c.dy + r * 0.5)
      ..close();
    canvas.drawPath(path, Paint()..color = _rim);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, r * 0.12)
        ..color = _rimDeep,
    );
    // The finial.
    canvas.drawCircle(c + Offset(0, -r * 1.15), r * 0.16, Paint()..color = _rim);
  }

  static void _number(Canvas canvas, Offset center, double r, int value) {
    final size = value >= 10 ? r * 0.78 : r * 0.90;
    final plus = size * 0.55;
    void line(Color color) {
      final b = ui.ParagraphBuilder(
        ui.ParagraphStyle(textAlign: TextAlign.center, maxLines: 1),
      )
        ..pushStyle(ui.TextStyle(color: color, fontSize: plus, fontWeight: FontWeight.w900))
        ..addText('+')
        ..pop()
        ..pushStyle(ui.TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w900, letterSpacing: -size * 0.04))
        ..addText('$value');
      final p = b.build()..layout(ui.ParagraphConstraints(width: r * 4));
      canvas.drawParagraph(p, Offset(center.dx - r * 2, center.dy - p.height / 2 + r * 0.14));
    }
    canvas.save();
    canvas.translate(0, r * 0.06);
    line(_ink.withValues(alpha: 0.85));
    canvas.restore();
    line(_ivory);
  }

  static Path _polygonPath(Offset c, double r, {required int sides}) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final a = -math.pi / 2 + math.pi / sides + i * 2 * math.pi / sides;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  static Path _starPath(Offset c, double r, {required int points, required double inner}) {
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? r : r * inner;
      final a = -math.pi / 2 + i * math.pi / points;
      final p = Offset(c.dx + radius * math.cos(a), c.dy + radius * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }
}

/// One medallion as a widget, for the callout and the rules.
class BonusMedallion extends StatelessWidget {
  const BonusMedallion({
    super.key,
    required this.value,
    required this.size,
    this.glow = 0,
    this.shimmer = 0,
  });

  final int value;
  final double size;
  final double glow;
  final double shimmer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MedallionPainter(value: value, glow: glow, shimmer: shimmer),
      ),
    );
  }
}

class _MedallionPainter extends CustomPainter {
  const _MedallionPainter({required this.value, required this.glow, required this.shimmer});

  final int value;
  final double glow;
  final double shimmer;

  @override
  void paint(Canvas canvas, Size size) {
    BonusTileArt.paint(
      canvas,
      size.center(Offset.zero),
      size.shortestSide * 0.72,
      value,
      glow: glow,
      shimmer: shimmer,
    );
  }

  @override
  bool shouldRepaint(_MedallionPainter old) =>
      old.value != value || old.glow != glow || old.shimmer != shimmer;
}

/// The whole layout of a game painted in one pass over the plate.
/// Static: it repaints only when the layout or the plate's size changes,
/// so a horse riding across it costs nothing here.
class BonusLayerPainter extends CustomPainter {
  const BonusLayerPainter({
    required this.tiles,
    required this.diameter,
  });

  /// (screen centre, value) per bonus square.
  final List<({Offset at, int value})> tiles;
  final double diameter;

  @override
  void paint(Canvas canvas, Size size) {
    for (final t in tiles) {
      BonusTileArt.paint(canvas, t.at, diameter, t.value);
    }
  }

  @override
  bool shouldRepaint(BonusLayerPainter old) =>
      old.diameter != diameter || !_same(old.tiles, tiles);

  static bool _same(List<({Offset at, int value})> a, List<({Offset at, int value})> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].at != b[i].at || a[i].value != b[i].value) return false;
    }
    return true;
  }
}
