import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Which end of the board's narrative journey this backdrop represents
/// (spec §14: Makkah → desert track → Hijaz mountains → oasis → Madinah).
enum LandmarkScene { makkahValley, hijazDesert, hijazMountains, madinahOasis }

/// Purely decorative, non-interactive background art for the two ends of
/// the board and the home screen. **Never** placed on an interactive
/// board square, never tappable, never resized in response to game state
/// (spec §8: the Kaaba is a landmark, never a capturable/ownable/animated
/// game object).
///
/// The Makkah backdrop renders a distant, deliberately abstract dark
/// cuboid silhouette low in the composition — a landmark shape, not a
/// detailed reconstruction — surrounded by a rocky valley. No contemporary
/// Makkah imagery (no towers, no modern lighting) appears anywhere (spec
/// §9). The Madinah backdrop is an oasis of palms and low earthen
/// buildings; per spec §11 this deliberately does not attempt to depict
/// the first mosque at all, to avoid asserting any specific unestablished
/// architectural detail — see VISUAL_REFERENCE_NOTES.md.
class HijazLandmarkPainter extends CustomPainter {
  const HijazLandmarkPainter({
    required this.scene,
    required this.skyTop,
    required this.skyBottom,
    required this.landPrimary,
    required this.landShade,
    this.accent = const Color(0xFFC89B45),
  });

  final LandmarkScene scene;
  final Color skyTop;
  final Color skyBottom;
  final Color landPrimary;
  final Color landShade;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyBottom],
        ).createShader(rect),
    );

    switch (scene) {
      case LandmarkScene.makkahValley:
        _paintValleyRidges(canvas, size);
        _paintDistantCuboidLandmark(canvas, size);
      case LandmarkScene.hijazDesert:
        _paintDunes(canvas, size);
      case LandmarkScene.hijazMountains:
        _paintMountainRidges(canvas, size);
      case LandmarkScene.madinahOasis:
        _paintOasis(canvas, size);
    }
  }

  void _paintValleyRidges(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final depth = i / 3;
      final h = size.height * (0.55 + depth * 0.18);
      final path = Path()..moveTo(0, size.height);
      path.lineTo(0, h);
      final segs = 6;
      for (var s = 0; s <= segs; s++) {
        final x = size.width * s / segs;
        final jitter = math.sin((s + i) * 1.7) * size.height * 0.05;
        path.lineTo(x, h - jitter - depth * 10);
      }
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, Paint()..color = Color.lerp(landPrimary, landShade, depth)!);
    }
  }

  void _paintDistantCuboidLandmark(Canvas canvas, Size size) {
    // Deliberately small, abstract, and low in the frame — a silhouette
    // landmark, never a focal illustration (spec §8–§9).
    final w = size.width * 0.045;
    final h = w * 1.05;
    final left = size.width * 0.5 - w / 2;
    final top = size.height * 0.62;
    final rect = Rect.fromLTWH(left, top, w, h);
    canvas.drawRect(rect, Paint()..color = const Color(0xFF14110D));
    // A single quiet gold band, evoking cloth without depicting script.
    canvas.drawRect(
      Rect.fromLTWH(left, top + h * 0.62, w, h * 0.08),
      Paint()..color = accent.withValues(alpha: 0.85),
    );
  }

  void _paintDunes(Canvas canvas, Size size) {
    for (var i = 0; i < 4; i++) {
      final depth = i / 4;
      final baseY = size.height * (0.6 + depth * 0.12);
      final path = Path()..moveTo(0, size.height);
      path.lineTo(0, baseY);
      path.quadraticBezierTo(
        size.width * 0.3,
        baseY - size.height * 0.06,
        size.width * 0.55,
        baseY + 6,
      );
      path.quadraticBezierTo(size.width * 0.8, baseY + size.height * 0.05, size.width, baseY - 4);
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, Paint()..color = Color.lerp(landPrimary, landShade, depth)!);
    }
  }

  void _paintMountainRidges(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final depth = i / 3;
      final path = Path()..moveTo(0, size.height);
      final peaks = 4;
      final baseH = size.height * (0.5 + depth * 0.2);
      path.lineTo(0, baseH);
      for (var p = 0; p <= peaks; p++) {
        final x = size.width * p / peaks;
        final peak = p.isOdd ? baseH - size.height * 0.22 : baseH - 6;
        path.lineTo(x, peak);
      }
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, Paint()..color = Color.lerp(landPrimary, landShade, depth)!);
    }
  }

  void _paintOasis(Canvas canvas, Size size) {
    // Low earthen buildings, deliberately simple (spec §10, §95 — no
    // domes/minarets asserted as VIIth-century architecture).
    final groundY = size.height * 0.74;
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      Paint()..color = landShade,
    );
    final buildingPaint = Paint()..color = landPrimary;
    for (var i = 0; i < 3; i++) {
      final w = size.width * 0.14;
      final h = size.height * (0.08 + 0.02 * (i % 2));
      final left = size.width * (0.12 + i * 0.22);
      canvas.drawRect(Rect.fromLTWH(left, groundY - h, w, h), buildingPaint);
    }
    // Palm trees.
    for (var i = 0; i < 4; i++) {
      final x = size.width * (0.08 + i * 0.26);
      _paintPalm(canvas, Offset(x, groundY), size.height * 0.22);
    }
  }

  void _paintPalm(Canvas canvas, Offset base, double height) {
    final trunkPaint = Paint()..color = const Color(0xFF6B4A2E);
    final trunk = Path()
      ..moveTo(base.dx - 2, base.dy)
      ..quadraticBezierTo(base.dx + 3, base.dy - height * 0.5, base.dx, base.dy - height)
      ..lineTo(base.dx + 2.5, base.dy - height)
      ..quadraticBezierTo(base.dx + 6, base.dy - height * 0.5, base.dx + 2, base.dy)
      ..close();
    canvas.drawPath(trunk, trunkPaint);

    final frondPaint = Paint()..color = const Color(0xFF497351);
    final top = Offset(base.dx + 1, base.dy - height);
    for (var i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + (i - 2.5) * 0.45;
      final end = top + Offset(math.cos(angle), math.sin(angle)) * height * 0.4;
      final ctrl = top + Offset(math.cos(angle), math.sin(angle) - 0.3) * height * 0.22;
      final frond = Path()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
      canvas.drawPath(
        frond,
        Paint()
          ..color = frondPaint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HijazLandmarkPainter oldDelegate) => oldDelegate.scene != scene;
}
