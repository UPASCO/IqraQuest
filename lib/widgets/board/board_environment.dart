import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// The three lands of the journey. A player must recognise the region
/// from color and light alone, before reading any name.
enum WorldRegion { dawn, solar, fertile }

class _RegionPalette {
  const _RegionPalette({
    required this.sky,
    required this.glow,
    required this.terrain,
    required this.contour,
    required this.fgTop,
    required this.fgBottom,
    required this.ridgeFar,
    required this.ridgeNear,
  });

  final List<Color> sky;
  final Color glow;
  final List<Color> terrain;
  final Color contour;
  final Color fgTop;
  final Color fgBottom;
  final Color ridgeFar;
  final Color ridgeNear;
}

const _palettes = {
  // Aube du Hijaz: cool night greens breaking into first light.
  WorldRegion.dawn: _RegionPalette(
    sky: [Color(0xFF0A3327), Color(0xFF135C43), Color(0xFF6E9A6B), Color(0xFFE8C182)],
    glow: Color(0xFFFFDC9A),
    terrain: [Color(0xFFEDD3A2), Color(0xFFDDBC85), Color(0xFFC29E6A), Color(0xFF97794E)],
    contour: Color(0xFF7A5F38),
    fgTop: Color(0xFF6B5232),
    fgBottom: Color(0xFF4A3820),
    ridgeFar: Color(0x8CB99B78),
    ridgeNear: Color(0xBF8E7452),
  ),
  // Désert solaire: hot noon light, rock and dust.
  WorldRegion.solar: _RegionPalette(
    sky: [Color(0xFF1E5E63), Color(0xFF4E8C7A), Color(0xFFD9B36A), Color(0xFFF4D08A)],
    glow: Color(0xFFFFE6A8),
    terrain: [Color(0xFFF4DCA4), Color(0xFFE8C583), Color(0xFFCE9F5E), Color(0xFFA37844)],
    contour: Color(0xFF8A5F2E),
    fgTop: Color(0xFF7A5426),
    fgBottom: Color(0xFF52371A),
    ridgeFar: Color(0x8CC79A66),
    ridgeNear: Color(0xBFA1703E),
  ),
  // Oasis / vallée fertile: shade, water and green.
  WorldRegion.fertile: _RegionPalette(
    sky: [Color(0xFF0A2E38), Color(0xFF14554E), Color(0xFF5E9A78), Color(0xFFD9CE8E)],
    glow: Color(0xFFEFE3A0),
    terrain: [Color(0xFFD7D49E), Color(0xFFB3C388), Color(0xFF8CA96A), Color(0xFF5F7C48)],
    contour: Color(0xFF4A6238),
    fgTop: Color(0xFF3E5A30),
    fgBottom: Color(0xFF283E1F),
    ridgeFar: Color(0x8C7FA075),
    ridgeNear: Color(0xBF5C7C54),
  ),
};

/// The living world the race takes place in: a full-screen dawn over the
/// Hijaz with real depth — sky, far mountains in haze, terrain sweeping
/// toward the viewer, and dark foreground dunes framing the bottom.
///
/// The board no longer paints its own ground; it sits ON this landscape,
/// so the whole screen is the game world and the UI floats above it.
class BoardEnvironmentPainter extends CustomPainter {
  const BoardEnvironmentPainter({
    this.horizon = 0.26,
    this.region = WorldRegion.dawn,
    this.heroPath = false,
  });

  /// Where the sky meets the land, as a fraction of screen height.
  final double horizon;
  final WorldRegion region;

  /// Home hero mode: a winding trail leads from the viewer's feet to a
  /// tiny oasis on the horizon — the journey is visible before a single
  /// tap.
  final bool heroPath;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final hy = h * horizon;
    final pal = _palettes[region]!;

    // --- Sky: night emerald fading into a warm dawn band ---
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, hy + h * 0.05),
      Paint()
        ..shader = ui.Gradient.linear(Offset(w / 2, 0), Offset(w / 2, hy), pal.sky, [
          0,
          0.45,
          0.80,
          1,
        ]),
    );

    // Stars, high in the sky.
    final star = Paint()..color = const Color(0xFFF4ECDC).withValues(alpha: 0.6);
    for (var i = 0; i < 12; i++) {
      final x = (math.sin(i * 12.9898) * 0.5 + 0.5) * w;
      final y = (math.sin(i * 78.233) * 0.5 + 0.5) * hy * 0.55;
      canvas.drawCircle(Offset(x, y + 6), i % 3 == 0 ? 1.6 : 1.0, star);
    }
    // Crescent, hung low enough in the sky to clear the title block the
    // home screen lays over this scene — at hy * 0.32 it sat right
    // against the wordmark and threw the whole header off balance.
    final crescent = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: Offset(w * 0.82, hy * 0.66), radius: w * 0.040)),
      Path()..addOval(Rect.fromCircle(center: Offset(w * 0.838, hy * 0.645), radius: w * 0.034)),
    );
    canvas.drawPath(crescent, Paint()..color = const Color(0xFFEBC06A));

    // Rising-sun glow on the horizon.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, hy + h * 0.1),
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(w * 0.5, hy),
          w * 0.65,
          [
            pal.glow.withValues(alpha: 0.70),
            pal.glow.withValues(alpha: 0.20),
            pal.glow.withValues(alpha: 0),
          ],
          [0, 0.5, 1],
        ),
    );

    // --- Far mountains: two hazy silhouettes just above the horizon ---
    void ridge(double base, double amp, double phase, Color color) {
      final path = Path()..moveTo(0, hy);
      for (var x = 0.0; x <= w; x += w / 36) {
        final t = x / w * math.pi;
        final y =
            base -
            amp * (0.55 * math.sin(t * 2.1 + phase) + 0.45 * math.sin(t * 4.7 + phase * 1.7)).abs();
        path.lineTo(x, y);
      }
      path
        ..lineTo(w, hy + 4)
        ..lineTo(0, hy + 4)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }

    ridge(hy, h * 0.055, 0.8, pal.ridgeFar);
    ridge(hy, h * 0.032, 2.9, pal.ridgeNear);

    // --- Terrain: warm near the horizon, deeper and richer toward the
    // viewer (atmospheric perspective) ---
    final ground = Rect.fromLTWH(0, hy, w, h - hy);
    canvas.drawRect(
      ground,
      Paint()
        ..shader = ui.Gradient.linear(Offset(w / 2, hy), Offset(w / 2, h), pal.terrain, [
          0,
          0.30,
          0.68,
          1,
        ]),
    );

    // Dune contour lines sweeping across the terrain, wider apart as they
    // come closer — the ground recedes.
    final contour = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = pal.contour.withValues(alpha: 0.14);
    for (var i = 0; i < 5; i++) {
      final t = i / 4.0;
      final y = hy + (h - hy) * (0.10 + t * t * 0.85);
      contour.strokeWidth = 1.2 + t * 2.4;
      canvas.drawPath(
        Path()
          ..moveTo(-w * 0.05, y + math.sin(i * 1.7) * 10)
          ..quadraticBezierTo(
            w * (0.3 + 0.12 * math.sin(i * 2.9)),
            y - (10 + t * 26),
            w * 0.62,
            y + math.sin(i * 1.3) * 8,
          )
          ..quadraticBezierTo(w * 0.85, y + (8 + t * 18), w * 1.05, y - 6),
        contour,
      );
    }

    if (heroPath) _paintHeroPath(canvas, size, hy, pal);

    // --- Foreground: dark dune shoulders framing the bottom corners,
    // with a few grass tufts. This is what puts the player IN the scene. ---
    final fgLeft = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.86)
      ..quadraticBezierTo(w * 0.16, h * 0.83, w * 0.34, h * 0.905)
      ..quadraticBezierTo(w * 0.46, h * 0.955, w * 0.52, h)
      ..close();
    final fgRight = Path()
      ..moveTo(w, h)
      ..lineTo(w, h * 0.885)
      ..quadraticBezierTo(w * 0.86, h * 0.862, w * 0.70, h * 0.925)
      ..quadraticBezierTo(w * 0.60, h * 0.965, w * 0.56, h)
      ..close();
    for (final (path, top, bottom) in [
      (fgLeft, pal.fgTop, pal.fgBottom),
      (fgRight, Color.lerp(pal.fgTop, Colors.white, 0.06)!, pal.fgBottom),
    ]) {
      canvas.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(Offset(w / 2, h * 0.83), Offset(w / 2, h), [top, bottom]),
      );
    }
    final tuft = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF57683C).withValues(alpha: 0.9);
    for (final (bx, by, s) in [
      (0.09, 0.878, 1.0),
      (0.13, 0.888, 0.7),
      (0.80, 0.905, 1.0),
      (0.85, 0.898, 0.75),
    ]) {
      final b = Offset(w * bx, h * by);
      for (var k = -2; k <= 2; k++) {
        canvas.drawPath(
          Path()
            ..moveTo(b.dx, b.dy)
            ..quadraticBezierTo(b.dx + k * 3.4 * s, b.dy - 9 * s, b.dx + k * 7 * s, b.dy - 15 * s),
          tuft,
        );
      }
    }

    // Mid-ground props: a distant caravanserai on the right, weathered
    // rocks on the left — the land is inhabited.
    _paintCaravanserai(canvas, Offset(w * 0.845, hy + (h - hy) * 0.585), w * 0.115);
    _paintRocks(canvas, Offset(w * 0.115, hy + (h - hy) * 0.615), w * 0.075);

    // Drifting dust motes over the mid-ground.
    final dust = Paint()..color = const Color(0xFFF4E7C8).withValues(alpha: 0.35);
    for (var i = 0; i < 8; i++) {
      final x = (math.sin(i * 41.7) * 0.5 + 0.5) * w;
      final y = hy + (math.sin(i * 17.3) * 0.5 + 0.5) * (h - hy) * 0.7;
      canvas.drawCircle(Offset(x, y), 1.4 + (i % 3) * 0.7, dust);
    }
  }

  void _paintHeroPath(Canvas canvas, Size size, double hy, _RegionPalette pal) {
    final w = size.width, h = size.height;
    // A trail that snakes to the horizon, narrowing with distance.
    Offset centerAt(double t) =>
        Offset(w * (0.5 + 0.16 * math.sin(t * math.pi * 1.35 + 0.4) * (1 - t)), h - (h - hy) * t);
    double halfWidth(double t) => w * (0.20 * (1 - t) * (1 - t) + 0.006);

    final left = <Offset>[], right = <Offset>[];
    for (var i = 0; i <= 24; i++) {
      final t = i / 24;
      final c = centerAt(t);
      final hw = halfWidth(t);
      left.add(c.translate(-hw, 0));
      right.add(c.translate(hw, 0));
    }
    final band = Path()..moveTo(left.first.dx, left.first.dy);
    for (final o in left) {
      band.lineTo(o.dx, o.dy);
    }
    for (final o in right.reversed) {
      band.lineTo(o.dx, o.dy);
    }
    band.close();
    canvas.drawPath(
      band,
      Paint()
        ..shader = ui.Gradient.linear(Offset(w / 2, h), Offset(w / 2, hy), [
          const Color(0xE8F2E3BE),
          const Color(0x66F2E3BE),
        ]),
    );
    // Hoof-worn edges.
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = pal.contour.withValues(alpha: 0.28);
    final le = Path()..moveTo(left.first.dx, left.first.dy);
    for (final o in left) {
      le.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(le, edge);
    final re = Path()..moveTo(right.first.dx, right.first.dy);
    for (final o in right) {
      re.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(re, edge);

    // The destination: a tiny oasis right on the horizon, glowing.
    final dest = centerAt(0.985);
    canvas.drawCircle(
      dest,
      w * 0.085,
      Paint()
        ..shader = ui.Gradient.radial(dest, w * 0.085, [
          pal.glow.withValues(alpha: 0.85),
          pal.glow.withValues(alpha: 0),
        ]),
    );
    canvas.drawOval(
      Rect.fromCenter(center: dest.translate(0, 3), width: w * 0.045, height: w * 0.014),
      Paint()..color = const Color(0xFF4E93A8),
    );
    _paintPalmSilhouette(canvas, dest.translate(-w * 0.016, 2), w * 0.030);
    _paintPalmSilhouette(canvas, dest.translate(w * 0.014, 3), w * 0.024);
  }

  /// A small desert inn: walls, one dome, an arched door, warm-lit.
  void _paintCaravanserai(Canvas canvas, Offset base, double w) {
    final h = w * 0.52;
    final wall = Rect.fromLTWH(base.dx - w / 2, base.dy - h, w, h);
    canvas.drawRect(
      wall,
      Paint()
        ..shader = ui.Gradient.linear(wall.topCenter, wall.bottomCenter, [
          const Color(0xFFD9BD8C),
          const Color(0xFFB39463),
        ]),
    );
    // Dome on the left third.
    final domeC = Offset(wall.left + w * 0.26, wall.top);
    canvas.drawArc(
      Rect.fromCircle(center: domeC, radius: w * 0.17),
      3.14159,
      3.14159,
      true,
      Paint()..color = const Color(0xFFC7A671),
    );
    // Crenellation hints.
    final teeth = Paint()..color = const Color(0xFFC7A671);
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(wall.left + w * (0.48 + i * 0.13), wall.top - h * 0.10, w * 0.07, h * 0.10),
        teeth,
      );
    }
    // Arched door, glowing warm.
    final door = Path()
      ..moveTo(base.dx - w * 0.075, base.dy)
      ..lineTo(base.dx - w * 0.075, base.dy - h * 0.42)
      ..quadraticBezierTo(base.dx, base.dy - h * 0.66, base.dx + w * 0.075, base.dy - h * 0.42)
      ..lineTo(base.dx + w * 0.075, base.dy)
      ..close();
    canvas.drawPath(door, Paint()..color = const Color(0xFFE9B84F));
    // Contact shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(base.dx, base.dy + 2), width: w * 1.12, height: w * 0.10),
      Paint()..color = Colors.black.withValues(alpha: 0.16),
    );
    // A palm leaning by the wall.
    _paintPalmSilhouette(canvas, Offset(wall.right + w * 0.10, base.dy), h * 0.9);
  }

  void _paintRocks(Canvas canvas, Offset base, double w) {
    for (final (dx, scale, color) in [
      (-0.30, 1.0, const Color(0xFFA8895C)),
      (0.25, 0.72, const Color(0xFF97794E)),
      (0.62, 0.45, const Color(0xFFB39463)),
    ]) {
      final r = w * scale;
      final c = Offset(base.dx + w * dx, base.dy);
      canvas.drawPath(
        Path()
          ..moveTo(c.dx - r * 0.6, c.dy)
          ..quadraticBezierTo(c.dx - r * 0.45, c.dy - r * 0.62, c.dx + r * 0.05, c.dy - r * 0.55)
          ..quadraticBezierTo(c.dx + r * 0.5, c.dy - r * 0.48, c.dx + r * 0.55, c.dy)
          ..close(),
        Paint()..color = color,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(base.dx + w * 0.1, base.dy + 2),
        width: w * 2,
        height: w * 0.16,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );
  }

  void _paintPalmSilhouette(Canvas canvas, Offset base, double h) {
    final trunk = Paint()
      ..color = const Color(0xFF6B4F2E)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = h * 0.10;
    final top = Offset(base.dx + h * 0.14, base.dy - h);
    canvas.drawPath(
      Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(base.dx, base.dy - h * 0.6, top.dx, top.dy),
      trunk,
    );
    final frond = Paint()
      ..color = const Color(0xFF456A46)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = h * 0.085;
    for (final (dx, dy) in [
      (-0.5, -0.14),
      (-0.24, -0.4),
      (0.14, -0.44),
      (0.5, -0.22),
      (0.55, 0.02),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(top.dx, top.dy)
          ..quadraticBezierTo(
            top.dx + h * dx * 0.6,
            top.dy + h * dy * 1.2,
            top.dx + h * dx,
            top.dy + h * dy + h * 0.12,
          ),
        frond,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BoardEnvironmentPainter old) =>
      old.horizon != horizon || old.region != region || old.heroPath != heroPath;
}
