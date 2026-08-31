import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_team.dart';
import 'team_symbol_painter.dart';

// =====================================================================
// IqraQuest — signature Arabian-horse illustration (pure vector).
//
// Art direction (DESIGN_SYSTEM.md §"Horse token", VISUAL_REFERENCE_NOTES.md):
// a refined, noble Arabian in profile — long arched crest, concave
// "dished" nasal bridge, deep clean throatlatch, fine tapered limbs, high
// tail carriage, large expressive eye. Warm, saturated, luminous coats and
// energetic poses, so it reads as delightful to a 7-year-old and premium
// to an adult — never a chibi/toy cartoon, never a unicorn, never a
// racing/jockey aesthetic, and never carrying a rider (the app depicts no
// human figures at all).
//
// Everything is drawn in a 100x100 local box, facing right, ground at
// y = 94, so it scales losslessly from a 24dp board pawn to a full-bleed
// hero illustration.
//
// Shading budget: volume comes from cheap gradient fills, not large
// MaskFilter blurs — this runs per frame behind an idle animation on
// low-end phones, and a blurred 40x20 oval is far more expensive than an
// elliptical radial shader covering the same area.
// =====================================================================

/// Naturalistic coat tones. Deliberately *not* brand tokens — these are
/// horse-coat colors, kept local to this file so they can be tuned as art
/// without touching the palette in `lib/theme/`.
@immutable
class _Coat {
  const _Coat({
    required this.hi,
    required this.light,
    required this.body,
    required this.shade,
    required this.deep,
    required this.points,
    required this.mane,
    required this.maneLight,
    required this.rim,
    required this.hoof,
  });

  /// Brightest top-lit sheen.
  final Color hi;
  final Color light;
  final Color body;
  final Color shade;

  /// Deepest core shadow / underline.
  final Color deep;

  /// Muzzle, knees, hocks — the coat's "points".
  final Color points;
  final Color mane;
  final Color maneLight;

  /// Rim-light hue along the lit contour: the single biggest contributor
  /// to the "premium 3D art" read.
  final Color rim;
  final Color hoof;
}

const Map<HorseCoat, _Coat> _coats = {
  // Grey Arabian: luminous pearl-ivory coat over dark skin, silver mane.
  HorseCoat.grayWhite: _Coat(
    hi: Color(0xFFFFFDF7),
    light: Color(0xFFF7EFDE),
    body: Color(0xFFE6D9C1),
    shade: Color(0xFFC0B094),
    deep: Color(0xFF8E7F6B),
    points: Color(0xFF7C7164),
    mane: Color(0xFFEDE3D0),
    maneLight: Color(0xFFFFFFFA),
    rim: Color(0xFFFFEFC2),
    hoof: Color(0xFF4B433A),
  ),
  // Bay: warm mahogany body with true black points.
  HorseCoat.bay: _Coat(
    hi: Color(0xFFE0A059),
    light: Color(0xFFC07B3E),
    body: Color(0xFF98572A),
    shade: Color(0xFF6A3818),
    deep: Color(0xFF3C1D0C),
    points: Color(0xFF2A1C15),
    mane: Color(0xFF1E1512),
    maneLight: Color(0xFF60483D),
    rim: Color(0xFFFFD289),
    hoof: Color(0xFF2A211B),
  ),
  // Flaxen chestnut: glowing copper with a pale gold mane and tail.
  HorseCoat.chestnut: _Coat(
    hi: Color(0xFFF7B268),
    light: Color(0xFFE28C43),
    body: Color(0xFFC5672B),
    shade: Color(0xFF97461B),
    deep: Color(0xFF5F290E),
    points: Color(0xFFA8541F),
    mane: Color(0xFFEED396),
    maneLight: Color(0xFFFFF4D8),
    rim: Color(0xFFFFDDA4),
    hoof: Color(0xFF5A3A22),
  ),
  // Black: blue-black with a cool moonlit sheen.
  HorseCoat.black: _Coat(
    hi: Color(0xFF7C8291),
    light: Color(0xFF525869),
    body: Color(0xFF313540),
    shade: Color(0xFF1C1F26),
    deep: Color(0xFF0B0C10),
    points: Color(0xFF171920),
    mane: Color(0xFF14161D),
    maneLight: Color(0xFF8A93A8),
    rim: Color(0xFFCADCF2),
    hoof: Color(0xFF101115),
  ),
};

/// The pose driving leg / tail / neck geometry. Idle head-bob and dust
/// are layered on top by the widget, not the painter (spec §24–25: motion
/// lives in the presentation layer so it can be muted for Reduce Motion).
enum HorsePose { standing, trot, gallop, rearingProud }

// ---------------------------------------------------------------------
// Path helpers.
// ---------------------------------------------------------------------

/// Appends a smooth polyline through [pts] (the path must already sit at
/// `pts.first`), using the standard "quadratic through midpoints" trick.
void _smoothTo(Path path, List<Offset> pts) {
  for (var i = 1; i < pts.length - 1; i++) {
    final mid = (pts[i] + pts[i + 1]) / 2;
    path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
  }
  path.lineTo(pts.last.dx, pts.last.dy);
}

Path _polyline(List<Offset> pts) {
  final p = Path()..moveTo(pts.first.dx, pts.first.dy);
  _smoothTo(p, pts);
  return p;
}

/// A closed shape between two smooth edges — the workhorse for the mane
/// mass and the tail mass.
Path _band(List<Offset> outer, List<Offset> inner) {
  final p = Path()..moveTo(outer.first.dx, outer.first.dy);
  _smoothTo(p, outer);
  final rev = inner.reversed.toList();
  p.lineTo(rev.first.dx, rev.first.dy);
  _smoothTo(p, rev);
  p.close();
  return p;
}

/// A closed, smoothly tapered ribbon along the spine [pts], with per-node
/// half-widths [halfW]. This is what turns "stick limbs" into anatomical,
/// tapering ones, and what gives wind-blown locks their point.
Path _ribbon(List<Offset> pts, List<double> halfW) {
  final left = <Offset>[];
  final right = <Offset>[];
  for (var i = 0; i < pts.length; i++) {
    final prev = pts[i == 0 ? 0 : i - 1];
    final next = pts[i == pts.length - 1 ? i : i + 1];
    var t = next - prev;
    t = t.distance < 1e-6 ? const Offset(0, 1) : t / t.distance;
    final n = Offset(-t.dy, t.dx);
    left.add(pts[i] + n * halfW[i]);
    right.add(pts[i] - n * halfW[i]);
  }
  final path = Path()..moveTo(left.first.dx, left.first.dy);
  _smoothTo(path, left);
  path.lineTo(right.last.dx, right.last.dy);
  _smoothTo(path, right.reversed.toList());
  path.close();
  return path;
}

Offset _rotate(Offset p, Offset pivot, double a) {
  final d = p - pivot;
  final c = math.cos(a);
  final s = math.sin(a);
  return pivot + Offset(d.dx * c - d.dy * s, d.dx * s + d.dy * c);
}

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

/// Paints an elliptical radial falloff from [color] at [at] to fully
/// transparent at the ellipse edge — the cheap building block for every
/// sheen and core shadow. The ellipse is produced by scaling the canvas
/// rather than by a gradient local-matrix: shader matrices are applied in
/// the inverse direction and are easy to get subtly, invisibly wrong.
void _glow(Canvas canvas, Offset at, double rx, double ry, Color color, double alpha) {
  canvas.save();
  canvas
    ..translate(at.dx, at.dy)
    ..scale(1, ry / rx)
    ..translate(-at.dx, -at.dy);
  canvas.drawCircle(
    at,
    rx,
    Paint()
      ..shader = ui.Gradient.radial(
        at,
        rx,
        [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
        const [0.0, 1.0],
      ),
  );
  canvas.restore();
}

/// One limb: a spine and its per-node half widths.
@immutable
class _Limb {
  const _Limb(this.spine, this.widths);
  final List<Offset> spine;
  final List<double> widths;
}

// Fine bone: an Arabian's cannon is barely thicker than its own hoof.
const List<double> _foreW = [5.2, 4.2, 2.7, 1.8, 1.65];
const List<double> _hindW = [7.4, 5.4, 3.0, 1.9, 1.75];

/// Draws IqraQuest's signature Arabian-horse token.
class HorsePainter extends CustomPainter {
  const HorsePainter({
    required this.coat,
    required this.team,
    this.pose = HorsePose.standing,
    this.facingRight = true,
    this.headBob = 0,
    this.showSaddle = true,
    this.colors,
  });

  final HorseCoat coat;
  final AppTeam team;
  final HorsePose pose;
  final bool facingRight;

  /// -1..1, a gentle idle head/neck bob driven by the caller's
  /// AnimationController.
  final double headBob;
  final bool showSaddle;

  /// Team color for the saddle cloth; a neutral gold is used when null
  /// (e.g. onboarding art, where no team is chosen yet).
  final Color? colors;

  static const double boxW = 100;
  static const double boxH = 100;
  static const double _groundY = 94;

  bool get _flying => pose == HorsePose.gallop || pose == HorsePose.rearingProud;
  bool get _rearing => pose == HorsePose.rearingProud;

  // ------------------------------------------------------------------
  // Pose transform. Only gallop and rearing move the whole body; the
  // other poses change legs / tail / mane only.
  // ------------------------------------------------------------------

  double get _angle => switch (pose) {
    HorsePose.gallop => -0.11,
    HorsePose.rearingProud => -0.50,
    _ => 0.0,
  };

  Offset get _pivot => switch (pose) {
    HorsePose.rearingProud => const Offset(30, 62),
    _ => const Offset(50, 60),
  };

  double get _scale => switch (pose) {
    HorsePose.gallop => 0.94,
    HorsePose.rearingProud => 0.74,
    _ => 1.0,
  };

  Offset get _shift => switch (pose) {
    HorsePose.gallop => const Offset(-3, -6),
    HorsePose.rearingProud => const Offset(7, 5),
    _ => Offset.zero,
  };

  static const Offset _scaleCenter = Offset(50, 52);

  /// Maps a body-local point into world (box) space.
  Offset _p(Offset local) {
    final r = _rotate(local, _pivot, _angle);
    return _scaleCenter + (r - _scaleCenter) * _scale + _shift;
  }

  void _applyBodyTransform(Canvas canvas) {
    canvas
      ..translate(_shift.dx, _shift.dy)
      ..translate(_scaleCenter.dx, _scaleCenter.dy)
      ..scale(_scale)
      ..translate(-_scaleCenter.dx, -_scaleCenter.dy)
      ..translate(_pivot.dx, _pivot.dy)
      ..rotate(_angle)
      ..translate(-_pivot.dx, -_pivot.dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = _coats[coat]!;
    final scale = math.min(size.width / boxW, size.height / boxH);

    canvas.save();
    canvas.translate((size.width - boxW * scale) / 2, (size.height - boxH * scale) / 2);
    if (facingRight) {
      canvas.scale(scale, scale);
    } else {
      canvas
        ..translate(boxW * scale, 0)
        ..scale(-scale, scale);
    }

    final bob = Offset(0, headBob * 1.4);

    _paintGroundShadow(canvas);

    // Rearing planted hind legs live in world space so their hooves meet
    // the ground even though the body is rotated up off it.
    if (_rearing) {
      final hind = _rearingHindLegs();
      _paintLeg(canvas, c, hind.first, far: true);
      _paintLeg(canvas, c, hind.last, far: false);
    }

    canvas.save();
    _applyBodyTransform(canvas);

    // Far side first (atmospheric perspective: darker, in the body's own
    // shadow), then the body, then the near side over it.
    if (!_rearing) _paintLeg(canvas, c, _leg(_Leg.farHind), far: true);
    _paintLeg(canvas, c, _leg(_Leg.farFore), far: true);
    _paintTail(canvas, c);

    final body = _bodySilhouette(bob);
    _paintBody(canvas, c, body);

    if (!_rearing) _paintLeg(canvas, c, _leg(_Leg.nearHind), far: false);
    _paintLeg(canvas, c, _leg(_Leg.nearFore), far: false);

    // Re-assert the contour so shoulder and haunch read in front of the
    // near legs, and so the silhouette stays crisp at 24dp.
    _paintContour(canvas, c, body);

    if (showSaddle) _paintSaddleCloth(canvas, body);
    _paintMane(canvas, c, bob);
    _paintHead(canvas, c, bob);

    canvas.restore();
    canvas.restore();
  }

  // ------------------------------------------------------------------
  // Ground.
  // ------------------------------------------------------------------

  void _paintGroundShadow(Canvas canvas) {
    final airborne = pose == HorsePose.gallop;
    final center = Offset(_rearing ? 30 : 44, _groundY + (airborne ? 3 : 1.5));
    final w = airborne
        ? 44.0
        : _rearing
        ? 34.0
        : 64.0;
    _glow(canvas, center, w / 2, (airborne ? 6 : 8.5) / 2, Colors.black, airborne ? 0.14 : 0.28);
  }

  // ------------------------------------------------------------------
  // Legs.
  // ------------------------------------------------------------------

  List<_Limb> _rearingHindLegs() {
    // Anchored to the *rotated* hip so the leg grows out of the body, but
    // reaching the world ground line: a rearing horse is coiled over its
    // hocks, so the flex is deep.
    final nearHip = _p(const Offset(25, 45));
    final farHip = _p(const Offset(20, 45));
    _Limb build(Offset hip, double dx) => _Limb([
      hip,
      hip + Offset(7.0 + dx, 12),
      Offset(hip.dx - 2.5 + dx, 73),
      Offset(hip.dx + 4.0 + dx, 86.5),
      Offset(hip.dx + 3.7 + dx, 90.5),
    ], _hindW);
    return [build(farHip, -2.0), build(nearHip, 0)];
  }

  _Limb _leg(_Leg which) {
    final s = _legSpines[pose]![which]!;
    final fore = which == _Leg.nearFore || which == _Leg.farFore;
    return _Limb(s, fore ? _foreW : _hindW);
  }

  void _paintLeg(Canvas canvas, _Coat c, _Limb limb, {required bool far}) {
    final pts = limb.spine;
    final top = pts.first;
    final foot = pts.last;
    final upper = far ? _mix(c.body, c.deep, 0.52) : c.light;
    final lower = far ? _mix(c.points, c.deep, 0.5) : c.points;

    final path = _ribbon(pts, limb.widths);
    // The top of the spine sits *inside* the barrel so the limb grows out
    // of the body rather than being pinned to it — so fade that end to
    // transparent, or its rounded cap prints a slab across the flank.
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          top,
          foot,
          [upper.withValues(alpha: 0), upper, far ? _mix(c.shade, c.deep, 0.55) : c.body, lower],
          const [0, 0.22, 0.55, 1],
        ),
    );

    if (!far) {
      canvas.save();
      canvas.clipPath(path);
      final knee = pts[2];
      // Light down the front of the cannon: makes the fine bone read.
      canvas.drawPath(
        _ribbon(
          [
            pts[1] + const Offset(1.1, 0),
            knee + const Offset(1.0, 0),
            pts[3] + const Offset(0.6, 0),
          ],
          [limb.widths[1] * 0.34, limb.widths[2] * 0.38, limb.widths[3] * 0.38],
        ),
        Paint()..color = c.hi.withValues(alpha: 0.30),
      );
      // Joint definition at knee / hock.
      final r = limb.widths[2] * 2.0;
      _glow(canvas, knee, r, r, c.deep, 0.30);
      canvas.restore();
    }

    // Hoof: a small angled block with a lit coronet band above it.
    final dir = foot - pts[pts.length - 2];
    final ang = math.atan2(dir.dy, dir.dx) - math.pi / 2;
    canvas.save();
    canvas
      ..translate(foot.dx, foot.dy)
      ..rotate(ang);
    final hoofRect = Rect.fromLTWH(-2.2, -0.3, 4.4, 4.0);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        hoofRect,
        topLeft: const Radius.circular(1.5),
        topRight: const Radius.circular(1.5),
        bottomLeft: const Radius.circular(0.8),
        bottomRight: const Radius.circular(0.8),
      ),
      Paint()
        ..shader = ui.Gradient.linear(hoofRect.topLeft, hoofRect.bottomRight, [
          far ? _mix(c.hoof, Colors.black, 0.4) : _mix(c.hoof, c.hi, 0.26),
          far ? Colors.black : c.hoof,
        ]),
    );
    if (!far) {
      canvas.drawLine(
        const Offset(-1.6, 0.8),
        const Offset(-0.8, 2.9),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.24)
          ..strokeWidth = 0.6
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();
  }

  // ------------------------------------------------------------------
  // Body + neck + head: one continuous outline, so there are no seams.
  // ------------------------------------------------------------------

  Path _bodySilhouette(Offset bob) {
    // A gentle idle bob lifts the head/neck without shearing the barrel;
    // `w` is how much of the bob a given anchor inherits.
    Offset h(double x, double y, double w) => Offset(x, y) + bob * w;

    final p = Path();
    final poll = h(76.4, 12.0, 1);
    p.moveTo(poll.dx, poll.dy);

    // --- Head: profile from the poll down to the muzzle ---
    final brow = h(82.8, 14.4, 0.98);
    p.cubicTo(78.6 + bob.dx, poll.dy - 2.0, 81.0, brow.dy - 1.6, brow.dx, brow.dy);
    // THE DISH. The control points sit well behind the brow→muzzle chord,
    // so the nasal bridge bows *inward*. This concave profile is the
    // defining Arabian trait — never a convex Roman nose.
    final bridge = h(87.6, 24.4, 0.9);
    p.cubicTo(85.2, brow.dy + 3.4, 84.6, bridge.dy - 3.4, bridge.dx, bridge.dy);
    // A small convex flare over the nostril, then a fine tapered muzzle.
    final nose = h(90.2, 29.4, 0.86);
    p.cubicTo(89.6, bridge.dy + 1.2, 90.6, nose.dy - 1.6, nose.dx, nose.dy);
    final lip = h(88.6, 32.0, 0.84);
    p.cubicTo(90.0, nose.dy + 1.6, 89.6, lip.dy - 0.2, lip.dx, lip.dy);
    final chin = h(85.2, 32.0, 0.82);
    p.cubicTo(87.4, lip.dy + 0.9, 86.4, chin.dy + 0.8, chin.dx, chin.dy);
    // Round jowl — the deep cheek of an Arabian.
    final jowl = h(79.4, 29.6, 0.72);
    p.cubicTo(82.8, chin.dy + 0.5, 81.0, jowl.dy + 1.5, jowl.dx, jowl.dy);
    // Throatlatch: cut back sharply, giving the clean notch that separates
    // an Arabian's head from its neck.
    final throat = h(73.2, 23.2, 0.58);
    p.cubicTo(77.2, jowl.dy - 1.6, 75.0, throat.dy + 2.0, throat.dx, throat.dy);

    // --- Front of the neck: a long, clean concave sweep to the chest ---
    final shoulderPt = Offset(66.0, 50.0) + bob * 0.12;
    p.cubicTo(
      69.0 + bob.dx * 0.5,
      throat.dy + 6.4,
      64.8,
      shoulderPt.dy - 9.4,
      shoulderPt.dx,
      shoulderPt.dy,
    );

    // --- Chest, girth, belly, tucked-up flank ---
    p.cubicTo(67.0, 54.6, 65.4, 58.6, 63.0, 61.6);
    p.cubicTo(60.8, 64.2, 59.0, 65.2, 56.4, 65.6);
    p.cubicTo(50.6, 66.6, 45.4, 66.6, 40.0, 65.6);
    p.cubicTo(34.6, 64.6, 30.0, 63.4, 26.0, 61.6);

    // --- Hindquarter: full, rounded, powerful ---
    p.cubicTo(21.2, 59.4, 15.8, 57.0, 12.4, 53.2);
    p.cubicTo(9.4, 49.8, 8.2, 46.0, 8.8, 42.0);
    p.cubicTo(9.3, 38.6, 10.8, 36.2, 13.2, 34.6);

    // --- Topline: croup, a shallow back dip, then the withers ---
    p.cubicTo(16.6, 32.2, 20.8, 32.2, 25.6, 33.2);
    p.cubicTo(31.6, 34.4, 36.4, 36.0, 41.6, 36.6);
    p.cubicTo(47.2, 37.2, 51.6, 36.4, 55.2, 34.2);

    // --- Crest: a high, proudly arched neck back up to the poll ---
    final crest = Offset(67.8, 21.6) + bob * 0.55;
    p.cubicTo(
      59.6 + bob.dx * 0.3,
      31.4 + bob.dy * 0.3,
      63.6 + bob.dx * 0.5,
      25.8 + bob.dy * 0.5,
      crest.dx,
      crest.dy,
    );
    p.cubicTo(71.0 + bob.dx, 18.0 + bob.dy * 0.8, 73.8 + bob.dx, 14.4 + bob.dy, poll.dx, poll.dy);
    p.close();
    return p;
  }

  void _paintBody(Canvas canvas, _Coat c, Path body) {
    final b = body.getBounds();

    // 1. Base form: top-lit vertical gradient.
    canvas.drawPath(
      body,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(b.center.dx, b.top),
          Offset(b.center.dx, b.bottom),
          [c.hi, c.light, c.body, c.shade, c.deep],
          const [0.0, 0.20, 0.48, 0.76, 1.0],
        ),
    );

    canvas.save();
    canvas.clipPath(body);

    void glow(Offset at, double rx, double ry, Color col, double a) =>
        _glow(canvas, at, rx, ry, col, a);

    // 2. Volume: sheens on barrel, haunch, shoulder and crest.
    glow(const Offset(41, 45), 19, 11, c.hi, 0.42); // barrel
    glow(const Offset(19, 43), 12, 10, c.hi, 0.34); // haunch
    glow(const Offset(59, 47), 9, 10, c.hi, 0.26); // shoulder
    glow(const Offset(70, 21), 7, 10, c.hi, 0.30); // crest

    // 3. Core shadow: underline, behind the shoulder, under the jowl.
    glow(const Offset(44, 70), 27, 10, c.deep, 0.44);
    glow(const Offset(65, 60), 8, 10, c.deep, 0.32);
    glow(const Offset(18, 60), 12, 7, c.deep, 0.36);
    glow(const Offset(74.5, 27), 6, 8, c.deep, 0.26);

    // 4. Muscle definition — soft, never a hard cartoon outline.
    void crease(List<Offset> pts, double width, double alpha) {
      canvas.drawPath(
        _polyline(pts),
        Paint()
          ..color = c.deep.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }

    // Shoulder blade, stifle division, neck muscle.
    crease(const [Offset(63, 40), Offset(58.5, 47), Offset(59.5, 57)], 1.8, 0.26);
    crease(const [Offset(24, 35), Offset(26.5, 46), Offset(24, 58)], 2.0, 0.24);
    crease(const [Offset(70.5, 27), Offset(66.5, 36), Offset(63.5, 45)], 1.4, 0.18);

    // 5. Rim light. Stroking the silhouette offset down-right leaves only
    // its inner half after the clip — a lit contour along the top/left.
    canvas.save();
    canvas.translate(1.4, 2.0);
    canvas.drawPath(
      body,
      Paint()
        ..color = c.rim.withValues(alpha: 0.62)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
    canvas.restore();

    // 6. The same trick mirrored: contact shade on the bottom/right edge.
    canvas.save();
    canvas.translate(-1.5, -1.8);
    canvas.drawPath(
      body,
      Paint()
        ..color = c.deep.withValues(alpha: 0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8),
    );
    canvas.restore();

    canvas.restore();
  }

  void _paintContour(Canvas canvas, _Coat c, Path body) {
    canvas.drawPath(
      body,
      Paint()
        ..color = _mix(c.deep, Colors.black, 0.3).withValues(alpha: 0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
  }

  // ------------------------------------------------------------------
  // Tail — a flowing mass of hair, carried high (Arabian), with locks
  // suggested by internal strokes rather than separate spiky shapes.
  // ------------------------------------------------------------------

  void _paintTail(Canvas canvas, _Coat c) {
    final moving = pose == HorsePose.trot;

    // (outer edge incl. a ragged tip fringe, inner edge, strand guides)
    final (outer, inner, strands) = _flying
        ? (
            const [
              Offset(15.6, 32.4),
              Offset(10.4, 25.4),
              Offset(5.8, 17.4),
              Offset(2.2, 8.6),
              Offset(5.6, 10.4),
              Offset(5.4, 4.6),
              Offset(9.0, 9.0),
              Offset(10.2, 4.0),
            ],
            const [Offset(17.2, 39.0), Offset(15.4, 30.6), Offset(14.0, 21.6), Offset(13.2, 11.0)],
            const [
              [Offset(15.8, 34.6), Offset(11.6, 25.6), Offset(6.4, 12.0)],
              [Offset(16.4, 37.0), Offset(13.2, 28.6), Offset(9.6, 15.0)],
            ],
          )
        : moving
        ? (
            const [
              Offset(15.2, 33.4),
              Offset(8.0, 43.0),
              Offset(3.4, 57.0),
              Offset(1.8, 71.0),
              Offset(4.4, 78.0),
              Offset(4.0, 84.0),
              Offset(7.4, 79.5),
              Offset(8.6, 85.5),
              Offset(11.4, 79.0),
            ],
            const [
              Offset(16.8, 38.6),
              Offset(14.0, 47.0),
              Offset(12.2, 60.0),
              Offset(12.6, 72.0),
              Offset(13.8, 78.0),
            ],
            const [
              [Offset(15.4, 35.6), Offset(9.8, 47.0), Offset(6.0, 70.0)],
              [Offset(16.0, 37.6), Offset(12.0, 50.0), Offset(9.6, 73.0)],
            ],
          )
        : (
            const [
              Offset(15.2, 33.4),
              Offset(9.0, 44.0),
              Offset(5.2, 59.0),
              Offset(4.0, 74.0),
              Offset(6.0, 81.0),
              Offset(5.8, 87.0),
              Offset(9.0, 82.5),
              Offset(10.2, 88.0),
              Offset(13.0, 82.0),
            ],
            const [
              Offset(16.8, 38.6),
              Offset(14.6, 48.0),
              Offset(13.6, 62.0),
              Offset(13.8, 74.0),
              Offset(14.8, 80.5),
            ],
            const [
              [Offset(15.4, 35.6), Offset(10.8, 49.0), Offset(8.2, 76.0)],
              [Offset(16.0, 37.6), Offset(12.6, 52.0), Offset(11.2, 79.0)],
            ],
          );

    final mass = _band(outer, inner);
    canvas.drawPath(
      mass,
      Paint()
        ..shader = ui.Gradient.linear(outer.first, outer.last, [
          _mix(c.mane, c.maneLight, 0.42),
          _mix(c.mane, Colors.black, 0.18),
        ]),
    );
    // Cross-lit edge so the mass has a near/far side.
    canvas.save();
    canvas.clipPath(mass);
    canvas.drawPath(
      _polyline(inner),
      Paint()
        ..color = _mix(c.mane, Colors.black, 0.35).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6),
    );
    for (var i = 0; i < strands.length; i++) {
      canvas.drawPath(
        _polyline(strands[i]),
        Paint()
          ..color = c.maneLight.withValues(alpha: i == 0 ? 0.55 : 0.34)
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 0 ? 1.3 : 0.9
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();

    // The dock, coat-colored, tying the tail to the croup.
    canvas.drawPath(
      _ribbon(
        const [Offset(16.0, 34.0), Offset(13.8, 36.6), Offset(12.6, 39.6)],
        const [3.4, 3.1, 2.2],
      ),
      Paint()
        ..shader = ui.Gradient.linear(const Offset(16, 33), const Offset(12, 40), [
          c.light,
          c.shade,
        ]),
    );
  }

  // ------------------------------------------------------------------
  // Mane — a single flowing mass hugging the crest and draping down the
  // near side of the neck. Deliberately NOT a row of separate locks:
  // shapes that straddle the crest line read as a sawtooth crest, not
  // as hair.
  // ------------------------------------------------------------------

  void _paintMane(Canvas canvas, _Coat c, Offset bob) {
    final drift = _flying ? -7.0 : (pose == HorsePose.trot ? -2.5 : 0.0);
    final lift = _flying ? -2.5 : 0.0;

    // Attachment edge: rides the crest from poll to withers.
    final attach = <Offset>[
      const Offset(76.6, 12.6) + bob,
      const Offset(72.8, 15.0) + bob * 0.9,
      const Offset(68.6, 19.4) + bob * 0.72,
      const Offset(64.2, 24.6) + bob * 0.55,
      const Offset(60.0, 29.6) + bob * 0.38,
      const Offset(55.8, 34.0) + bob * 0.2,
    ];
    // Free edge: hangs down the near side of the neck. The nodes
    // alternate deep / shallow so the smoothed edge breaks into soft
    // lobes — a straight edge here reads as a scarf, not as hair.
    const raw = <(Offset, double)>[
      (Offset(75.8, 17.8), 0.95),
      (Offset(73.4, 22.8), 0.85),
      (Offset(70.6, 25.2), 0.75),
      (Offset(68.8, 30.6), 0.65),
      (Offset(66.0, 30.2), 0.55),
      (Offset(63.8, 35.6), 0.45),
      (Offset(61.0, 34.4), 0.35),
      (Offset(58.6, 38.8), 0.28),
      (Offset(55.4, 36.4), 0.18),
    ];
    final free = <Offset>[
      for (final (pt, w) in raw) pt + bob * w + Offset(drift * (1.05 - w), lift * (1.05 - w)),
    ];

    final mass = _band(attach, free);
    canvas.drawPath(
      mass,
      Paint()
        ..shader = ui.Gradient.linear(attach.first, free.last, [
          _mix(c.mane, c.maneLight, 0.45),
          _mix(c.mane, c.maneLight, 0.05),
        ]),
    );

    canvas.save();
    canvas.clipPath(mass);
    // Strand texture, always running with the hair, never across it.
    for (var i = 0; i < 5; i++) {
      final t = (i + 0.6) / 5.6;
      final line = <Offset>[
        for (var k = 0; k < attach.length; k++)
          Offset.lerp(attach[k], free[k], t)! + Offset(math.sin((k + i) * 1.5) * 0.8, 0),
      ];
      canvas.drawPath(
        _polyline(line),
        Paint()
          ..color = (i.isEven ? c.maneLight : Colors.black).withValues(
            alpha: i.isEven ? 0.40 : 0.20,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = i.isEven ? 1.2 : 0.9
          ..strokeCap = StrokeCap.round,
      );
    }
    // Bright edge right where the mane meets the lit crest.
    canvas.drawPath(
      _polyline(attach),
      Paint()
        ..color = c.maneLight.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8),
    );
    canvas.restore();

    // In motion, long wind-blown locks stream back off the crest. These
    // are directional and tapered, so they read as wind rather than as
    // spikes.
    if (_flying) {
      const spread = <(Offset, double, double, double)>[
        (Offset(75.6, 13.8), 18.0, -8.0, 4.2),
        (Offset(72.6, 16.4), 24.0, -3.5, 4.6),
        (Offset(69.4, 19.8), 26.0, 1.0, 4.6),
        (Offset(66.2, 23.4), 23.0, 5.5, 4.1),
        (Offset(63.0, 27.0), 18.0, 9.5, 3.4),
      ];
      for (var i = 0; i < spread.length; i++) {
        final (a0, len, rise, w) = spread[i];
        final a = a0 + bob * (0.9 - i * 0.15);
        final tip = a + Offset(-len, rise);
        // A control point well above the chord curves each lock, and the
        // wide overlapping bases fuse them into one wind-blown flag
        // rather than a row of blades.
        final ctrl = Offset.lerp(a, tip, 0.45)! + const Offset(2.0, -5.5);
        canvas.drawPath(
          _ribbon([a, ctrl, tip], [w, w * 0.72, 0.35]),
          Paint()
            ..shader = ui.Gradient.linear(a, tip, [
              _mix(c.mane, c.maneLight, 0.5),
              _mix(c.mane, c.maneLight, 0.05),
            ]),
        );
      }
    }
  }

  // ------------------------------------------------------------------
  // Head details: ears (two of them — a single spike reads as a horn),
  // eye, nostril, muzzle shading, forelock.
  // ------------------------------------------------------------------

  void _paintHead(Canvas canvas, _Coat c, Offset bob) {
    // --- Ears: short, fine, tips curving toward each other. An Arabian's
    // ear is a slim crescent, not a triangle.
    void ear(Offset base, Offset tip, double curl, {required bool near}) {
      final axis = tip - base;
      final outer = base + axis * 0.55 + Offset(curl.abs() * 0.9, 0);
      final inner = base + axis * 0.42 + Offset(-1.5 + curl, 0.4);
      final path = Path()
        ..moveTo(base.dx - 1.9, base.dy + 0.4)
        ..quadraticBezierTo(inner.dx, inner.dy, tip.dx, tip.dy)
        ..quadraticBezierTo(outer.dx, outer.dy, base.dx + 2.0, base.dy + 1.4)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(tip, base, [
            near ? c.hi : _mix(c.shade, c.deep, 0.45),
            near ? c.body : c.deep,
          ]),
      );
      if (near) {
        canvas.drawPath(
          Path()
            ..moveTo(base.dx - 0.9, base.dy)
            ..quadraticBezierTo(inner.dx + 0.5, inner.dy + 0.4, tip.dx - 0.1, tip.dy + 2.2)
            ..quadraticBezierTo(outer.dx - 0.9, outer.dy + 0.8, base.dx + 1.0, base.dy + 0.8)
            ..close(),
          Paint()..color = _mix(c.deep, c.points, 0.55).withValues(alpha: 0.6),
        );
      }
    }

    ear(const Offset(72.8, 14.6) + bob, const Offset(73.8, 6.2) + bob, -0.9, near: false);
    ear(const Offset(76.6, 12.8) + bob, const Offset(79.0, 4.6) + bob, -1.2, near: true);

    // --- Jowl and cheekbone: a soft shadow that carves the jaw out of
    // the neck behind it.
    canvas.drawPath(
      _polyline([
        const Offset(80.2, 19.8) + bob * 0.9,
        const Offset(78.6, 24.2) + bob * 0.8,
        const Offset(80.2, 28.2) + bob * 0.74,
      ]),
      Paint()
        ..color = c.deep.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4),
    );

    // --- Muzzle: greys and bays both darken toward the nose.
    final muzzle = const Offset(87.6, 29.6) + bob * 0.86;
    _glow(canvas, muzzle, 6.0, 5.2, c.points, 0.34);

    // --- Forelock, falling from between the ears over the brow.
    for (var i = 0; i < 3; i++) {
      final a = const Offset(75.4, 13.2) + bob + Offset(i * 1.2, i * 0.5);
      final tip = a + Offset(3.6 + i * 1.5, 6.8 + i * 1.6);
      canvas.drawPath(
        _ribbon([a, (a + tip) / 2 + const Offset(1.3, -0.5), tip], const [1.7, 1.3, 0.3]),
        Paint()..shader = ui.Gradient.linear(a, tip, [_mix(c.mane, c.maneLight, 0.4), c.mane]),
      );
    }

    // --- Eye. Large, almond, low-set and slightly tilted: the feature
    // that gives the horse its character. A warm iris and two catchlights
    // read as alive and friendly without tipping into cartoon.
    final eye = const Offset(81.4, 19.6) + bob * 0.94;
    canvas.save();
    canvas
      ..translate(eye.dx, eye.dy)
      ..rotate(-0.36);

    _glow(canvas, const Offset(0, -2.2), 4.0, 1.8, c.deep, 0.28);

    final socket = Path()
      ..moveTo(-2.7, 0.3)
      ..quadraticBezierTo(-1.1, -2.4, 2.1, -1.4)
      ..quadraticBezierTo(3.1, -1.0, 2.9, 0.2)
      ..quadraticBezierTo(1.5, 2.3, -1.3, 1.6)
      ..quadraticBezierTo(-2.5, 1.2, -2.7, 0.3)
      ..close();
    canvas.drawPath(socket, Paint()..color = const Color(0xFF241A12));
    canvas.save();
    canvas.clipPath(socket);
    canvas.drawCircle(
      const Offset(0.4, 0),
      2.3,
      Paint()
        ..shader = ui.Gradient.radial(const Offset(-0.1, -0.7), 2.5, const [
          Color(0xFF8A5527),
          Color(0xFF1A1009),
        ]),
    );
    canvas.restore();
    canvas.drawCircle(
      const Offset(-0.7, -0.7),
      0.9,
      Paint()..color = Colors.white.withValues(alpha: 0.94),
    );
    canvas.drawCircle(
      const Offset(1.4, 0.85),
      0.38,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-2.8, 0.1)
        ..quadraticBezierTo(-1.1, -2.8, 2.5, -1.3),
      Paint()
        ..color = _mix(c.points, Colors.black, 0.35).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    // --- Nostril: a fine comma, flared. Never a round blob.
    final n = const Offset(88.2, 27.8) + bob * 0.87;
    canvas.drawPath(
      Path()
        ..moveTo(n.dx - 1.4, n.dy - 0.9)
        ..quadraticBezierTo(n.dx + 1.3, n.dy - 1.5, n.dx + 1.5, n.dy + 0.4)
        ..quadraticBezierTo(n.dx + 0.9, n.dy + 1.4, n.dx - 0.4, n.dy + 0.6)
        ..quadraticBezierTo(n.dx - 1.2, n.dy + 0.1, n.dx - 1.4, n.dy - 0.9)
        ..close(),
      Paint()..color = _mix(c.points, Colors.black, 0.4),
    );

    // --- Mouth line.
    final m = const Offset(88.4, 31.4) + bob * 0.84;
    canvas.drawPath(
      Path()
        ..moveTo(m.dx + 0.4, m.dy - 0.4)
        ..quadraticBezierTo(m.dx - 1.4, m.dy + 0.4, m.dx - 3.2, m.dy - 0.5),
      Paint()
        ..color = c.deep.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.65
        ..strokeCap = StrokeCap.round,
    );
  }

  // ------------------------------------------------------------------
  // Saddle cloth: a draped woven blanket carrying the team symbol — the
  // colorblind-safe non-color identity channel (DESIGN_SYSTEM.md §2).
  // No saddle tree, no stirrups, no reins: nothing implies a rider.
  // ------------------------------------------------------------------

  void _paintSaddleCloth(Canvas canvas, Path body) {
    final base = colors ?? const Color(0xFFC89B45);
    const gold = Color(0xFFE9CB84);

    // Top edge rides the back; the cloth then drapes down the flank.
    final hem = Path()
      ..moveTo(57.6, 42.4)
      ..cubicTo(54.4, 45.6, 49.6, 47.8, 44.0, 48.8)
      ..cubicTo(38.4, 49.8, 33.4, 49.6, 29.6, 48.6);

    final cloth = Path()
      ..moveTo(30.6, 33.8)
      ..cubicTo(36.0, 35.2, 43.2, 36.6, 50.6, 36.0)
      ..cubicTo(52.8, 35.8, 54.4, 35.2, 55.6, 34.4)
      ..lineTo(57.6, 42.4)
      ..cubicTo(54.4, 45.6, 49.6, 47.8, 44.0, 48.8)
      ..cubicTo(38.4, 49.8, 33.4, 49.6, 29.6, 48.6)
      ..close();

    canvas.save();
    canvas.clipPath(body);

    canvas.drawPath(
      cloth,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(44, 33),
          const Offset(44, 49),
          [_mix(base, Colors.white, 0.24), base, _mix(base, Colors.black, 0.30)],
          const [0, 0.45, 1],
        ),
    );

    // Woven border along the hanging hem, plus a lit top seam.
    canvas.drawPath(
      hem,
      Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(31.4, 34.7)
        ..cubicTo(36.6, 36.0, 43.2, 37.3, 50.5, 36.7),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    paintTeamSymbol(canvas, const Offset(43.0, 41.4), 4.5, team.symbol);
    canvas.restore();

    // Tassel at the rear corner, hanging just past the cloth.
    canvas.drawPath(
      _ribbon(
        const [Offset(29.9, 48.4), Offset(28.6, 51.4), Offset(29.0, 54.0)],
        const [1.2, 1.0, 0.35],
      ),
      Paint()..color = gold,
    );
  }

  @override
  bool shouldRepaint(covariant HorsePainter oldDelegate) {
    return oldDelegate.coat != coat ||
        oldDelegate.team != team ||
        oldDelegate.pose != pose ||
        oldDelegate.facingRight != facingRight ||
        oldDelegate.headBob != headBob ||
        oldDelegate.showSaddle != showSaddle ||
        oldDelegate.colors != colors;
  }
}

enum _Leg { farHind, farFore, nearHind, nearFore }

/// Per-pose leg spines: hip/shoulder, elbow/stifle, knee/hock, fetlock,
/// pastern. Hand-posed rather than procedurally derived — a trot needs a
/// crisp lifted knee and a gallop needs real extension, and interpolating
/// between them makes both look mushy.
const Map<HorsePose, Map<_Leg, List<Offset>>> _legSpines = {
  HorsePose.standing: {
    _Leg.farHind: [
      Offset(19.0, 45.0),
      Offset(23.5, 61.0),
      Offset(16.0, 75.0),
      Offset(17.6, 87.5),
      Offset(17.4, 90.8),
    ],
    _Leg.farFore: [
      Offset(54.0, 46.0),
      Offset(55.2, 61.0),
      Offset(56.0, 73.5),
      Offset(56.2, 87.0),
      Offset(55.9, 90.6),
    ],
    _Leg.nearHind: [
      Offset(25.0, 45.0),
      Offset(30.2, 61.5),
      Offset(21.8, 75.5),
      Offset(23.6, 87.5),
      Offset(23.4, 90.8),
    ],
    _Leg.nearFore: [
      Offset(62.0, 46.0),
      Offset(63.4, 61.5),
      Offset(64.2, 73.5),
      Offset(64.4, 87.0),
      Offset(64.1, 90.6),
    ],
  },
  // Diagonal pairs: near fore + far hind swing, far fore + near hind bear.
  HorsePose.trot: {
    _Leg.farHind: [
      Offset(19.0, 45.0),
      Offset(24.6, 60.0),
      Offset(22.4, 72.0),
      Offset(28.4, 81.0),
      Offset(30.0, 83.8),
    ],
    _Leg.farFore: [
      Offset(54.0, 46.0),
      Offset(54.0, 61.0),
      Offset(51.8, 73.5),
      Offset(49.0, 87.0),
      Offset(48.4, 90.6),
    ],
    _Leg.nearHind: [
      Offset(25.0, 45.0),
      Offset(29.6, 61.5),
      Offset(19.4, 75.5),
      Offset(14.8, 87.5),
      Offset(14.2, 90.8),
    ],
    _Leg.nearFore: [
      Offset(62.0, 46.0),
      Offset(65.2, 59.0),
      Offset(70.4, 67.5),
      Offset(66.6, 75.5),
      Offset(64.8, 79.0),
    ],
  },
  // Full extension: forelegs reaching, hindquarters driving out behind.
  HorsePose.gallop: {
    _Leg.farHind: [
      Offset(19.0, 45.0),
      Offset(21.6, 59.0),
      Offset(13.0, 68.0),
      Offset(16.4, 77.0),
      Offset(17.6, 80.0),
    ],
    _Leg.farFore: [
      Offset(54.0, 46.0),
      Offset(57.0, 58.0),
      Offset(62.4, 63.5),
      Offset(57.6, 68.5),
      Offset(55.4, 70.2),
    ],
    _Leg.nearHind: [
      Offset(25.0, 45.0),
      Offset(26.2, 59.5),
      Offset(13.0, 67.0),
      Offset(4.6, 75.0),
      Offset(2.2, 78.0),
    ],
    _Leg.nearFore: [
      Offset(62.0, 46.0),
      Offset(66.6, 56.5),
      Offset(74.4, 61.0),
      Offset(81.0, 66.5),
      Offset(82.8, 69.4),
    ],
  },
  // Rearing: forelegs curled in tight and held high; the hind legs are
  // drawn separately in world space so they stay planted (see
  // _rearingHindLegs).
  HorsePose.rearingProud: {
    _Leg.farHind: [
      Offset(19.0, 45.0),
      Offset(23.0, 60.0),
      Offset(17.0, 72.0),
      Offset(19.0, 82.0),
      Offset(19.0, 85.0),
    ],
    _Leg.farFore: [
      Offset(54.0, 46.0),
      Offset(59.4, 52.0),
      Offset(67.0, 54.6),
      Offset(63.6, 62.0),
      Offset(60.6, 64.4),
    ],
    _Leg.nearHind: [
      Offset(25.0, 45.0),
      Offset(29.0, 60.0),
      Offset(22.0, 72.0),
      Offset(24.0, 82.0),
      Offset(24.0, 85.0),
    ],
    _Leg.nearFore: [
      Offset(62.0, 46.0),
      Offset(68.6, 51.0),
      Offset(76.4, 54.0),
      Offset(72.6, 62.0),
      Offset(69.2, 64.8),
    ],
  },
};

/// Convenience widget wrapping [HorsePainter] with an idle head-bob,
/// automatically disabled under Reduce Motion (spec §25).
class HorseToken extends StatefulWidget {
  const HorseToken({
    super.key,
    required this.coat,
    required this.team,
    this.pose = HorsePose.standing,
    this.facingRight = true,
    this.showSaddle = true,
    this.color,
    this.size = 48,
  });

  final HorseCoat coat;
  final AppTeam team;
  final HorsePose pose;
  final bool facingRight;
  final bool showSaddle;
  final Color? color;
  final double size;

  @override
  State<HorseToken> createState() => _HorseTokenState();
}

class _HorseTokenState extends State<HorseToken> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      width: widget.size,
      height: widget.size * (HorsePainter.boxH / HorsePainter.boxW),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final bob = reduceMotion ? 0.0 : Curves.easeInOut.transform(_controller.value) * 2 - 1;
          return CustomPaint(
            painter: HorsePainter(
              coat: widget.coat,
              team: widget.team,
              pose: widget.pose,
              facingRight: widget.facingRight,
              headBob: widget.pose == HorsePose.standing ? bob : 0,
              showSaddle: widget.showSaddle,
              colors: widget.color,
            ),
          );
        },
      ),
    );
  }
}
