import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_team.dart';

/// Coat color values. Kept separate from [AppColors] — these are
/// naturalistic horse-coat tones, not brand tokens. See
/// VISUAL_REFERENCE_NOTES.md for the art brief this implements.
class _CoatPalette {
  const _CoatPalette(this.highlight, this.body, this.shade, this.points, this.mane);
  final Color highlight; // top-lit sheen
  final Color body;
  final Color shade; // darker body tone for form/shadow
  final Color points; // legs/muzzle "points" color
  final Color mane;
}

const Map<HorseCoat, _CoatPalette> _coatPalettes = {
  HorseCoat.grayWhite: _CoatPalette(
    Color(0xFFFAF6EC),
    Color(0xFFEDE4D3),
    Color(0xFFC9BCA1),
    Color(0xFFAFA189),
    Color(0xFFDCD0B9),
  ),
  HorseCoat.bay: _CoatPalette(
    Color(0xFF9A6440),
    Color(0xFF7B4B2E),
    Color(0xFF4E3018),
    Color(0xFF241812),
    Color(0xFF241812),
  ),
  HorseCoat.chestnut: _CoatPalette(
    Color(0xFFC17A45),
    Color(0xFFA05A2C),
    Color(0xFF6E3A1B),
    Color(0xFF5A3018),
    Color(0xFF5A3018),
  ),
  HorseCoat.black: _CoatPalette(
    Color(0xFF4A443C),
    Color(0xFF2B2620),
    Color(0xFF14110D),
    Color(0xFF0D0B08),
    Color(0xFF0D0B08),
  ),
};

/// The pose driving leg/tail/neck geometry. Idle head-bob and dust are
/// layered on top by the widget, not the painter (spec §24–25: motion
/// lives in the presentation layer so it can be muted for Reduce Motion).
enum HorsePose { standing, trot, gallop, rearingProud }

/// Draws IqraQuest's signature arabian-horse token: a refined, noble
/// silhouette — a single continuous body/neck/head outline with a tall,
/// proudly arched crest, a dished profile and fine muzzle — with separate
/// fine legs and a flowing multi-strand tail/mane. Never a cartoon toy,
/// never a jockey/racing aesthetic (spec §3–§5). Pure vector, so it
/// scales losslessly from a 24dp board pawn to a full-bleed hero
/// illustration.
///
/// Internal drawing space is a 100×100 box, viewed in profile facing
/// right, ground at y=96. See VISUAL_REFERENCE_NOTES.md for the design
/// brief this silhouette follows.
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

  /// Semantic color set for the saddle/team marker; if null, a neutral
  /// gold is used (e.g. for onboarding art where no team is chosen yet).
  final Color? colors;

  static const double boxW = 100;
  static const double boxH = 100;
  static const double _groundY = 96;

  @override
  void paint(Canvas canvas, Size size) {
    final palette = _coatPalettes[coat]!;
    canvas.save();
    final scale = math.min(size.width / boxW, size.height / boxH);
    canvas.translate(
      (size.width - boxW * scale) / 2,
      (size.height - boxH * scale) / 2,
    );
    if (!facingRight) {
      canvas.translate(boxW * scale, 0);
      canvas.scale(-scale, scale);
    } else {
      canvas.scale(scale, scale);
    }

    final bob = Offset(0, headBob * 1.6);

    _paintGroundShadow(canvas);
    _paintLegs(canvas, palette);
    _paintTail(canvas, palette, bob);
    final silhouette = _buildSilhouette(bob);
    _paintSilhouette(canvas, silhouette, palette);
    _paintSaddle(canvas, bob);
    _paintMane(canvas, palette, bob);
    _paintFace(canvas, palette, bob);

    canvas.restore();
  }

  void _paintGroundShadow(Canvas canvas) {
    final rect = Rect.fromCenter(
      center: const Offset(48, _groundY + 2),
      width: 60,
      height: 7,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  // -------------------------------------------------------------------
  // Legs — long and fine, never stubby (spec §3: "jambes fines").
  // -------------------------------------------------------------------

  void _paintLegs(Canvas canvas, _CoatPalette p) {
    final rearing = pose == HorsePose.rearingProud;
    final bend = switch (pose) {
      HorsePose.standing => 0.0,
      HorsePose.trot => 7.0,
      HorsePose.gallop => 13.0,
      HorsePose.rearingProud => 0.0,
    };

    // (topX, topY, bottomXOffset, liftY) per leg: hind-back, hind-front,
    // fore-back, fore-front.
    final legs = rearing
        ? [
            (16.0, 62.0, 0.0, 0.0),
            (24.0, 64.0, 2.0, 0.0),
            (56.0, 55.0, -3.0, 26.0),
            (64.0, 52.0, 4.0, 19.0),
          ]
        : [
            (15.0, 63.0, -bend * 0.5, 0.0),
            (24.0, 64.0, bend * 0.3, 0.0),
            (56.0, 61.0, bend * 0.3, 0.0),
            (65.0, 59.0, -bend * 0.5, 0.0),
          ];

    for (final (topX, topY, bottomOffset, lift) in legs) {
      final bottomY = _groundY - lift - 1;
      final upperKnee = Offset(topX, topY + (bottomY - topY) * 0.45);
      final hoofTop = Offset(topX + bottomOffset, bottomY);

      final path = Path()
        ..moveTo(topX - 2.6, topY)
        ..quadraticBezierTo(
          topX - 1.6,
          upperKnee.dy,
          hoofTop.dx - 1.7,
          hoofTop.dy,
        )
        ..lineTo(hoofTop.dx + 1.7, hoofTop.dy)
        ..quadraticBezierTo(
          topX + 1.6,
          upperKnee.dy,
          topX + 2.6,
          topY,
        )
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(Offset(topX, topY), hoofTop, [
            p.body,
            p.points,
          ]),
      );
      // Hoof.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(hoofTop.dx - 2.2, hoofTop.dy - 1, 4.4, 3.2),
          const Radius.circular(1.2),
        ),
        Paint()..color = p.shade,
      );
    }
  }

  // -------------------------------------------------------------------
  // Tail — flowing, multi-strand, never a curl/blob.
  // -------------------------------------------------------------------

  void _paintTail(Canvas canvas, _CoatPalette p, Offset bob) {
    final high = pose == HorsePose.gallop || pose == HorsePose.rearingProud;
    final base = const Offset(13, 48) + bob * 0.2;

    final strands = high
        ? [
            [base, const Offset(0, 28), const Offset(-6, 10)],
            [base, const Offset(-4, 32), const Offset(-12, 16)],
            [base, const Offset(4, 36), const Offset(0, 18)],
          ]
        : [
            [base, const Offset(3, 64), const Offset(-1, 82)],
            [base, const Offset(-4, 62), const Offset(-9, 78)],
            [base, const Offset(7, 60), const Offset(8, 76)],
          ];

    for (var i = 0; i < strands.length; i++) {
      final s = strands[i];
      final path = Path()
        ..moveTo(s[0].dx, s[0].dy)
        ..quadraticBezierTo(s[1].dx, s[1].dy, s[2].dx, s[2].dy);
      canvas.drawPath(
        path,
        Paint()
          ..color = p.mane.withValues(alpha: 0.92 - i * 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.8 - i * 0.6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  // -------------------------------------------------------------------
  // Body + neck + head — one continuous outline (no seams). The neck is
  // deliberately long and steep (a proud, arched crest) — the single
  // most important trait for reading as "elegant Arabian horse" rather
  // than a stocky pony (spec §3).
  // -------------------------------------------------------------------

  Path _buildSilhouette(Offset bob) {
    final path = Path();
    final poll = const Offset(84, 10) + bob;
    path.moveTo(poll.dx, poll.dy);

    // Forehead: gentle convex bulge.
    final forehead = const Offset(92, 7) + bob;
    path.quadraticBezierTo(poll.dx + 4, poll.dy - 4, forehead.dx, forehead.dy);
    // The dish: the profile leans inward here — the defining Arabian
    // trait — before flaring back out at the nostril.
    final dish = const Offset(93, 15) + bob * 0.95;
    path.quadraticBezierTo(forehead.dx + 2, forehead.dy + 4, dish.dx, dish.dy);
    final noseTip = const Offset(99, 24) + bob * 0.9;
    path.quadraticBezierTo(dish.dx + 6, dish.dy + 4, noseTip.dx, noseTip.dy);
    final lip = const Offset(96, 28) + bob * 0.9;
    path.quadraticBezierTo(noseTip.dx, noseTip.dy + 3, lip.dx, lip.dy);
    final jawCorner = const Offset(88, 31) + bob * 0.85;
    path.quadraticBezierTo(lip.dx - 4, lip.dy + 1, jawCorner.dx, jawCorner.dy);
    final throatLatch = const Offset(78, 35) + bob * 0.75;
    path.quadraticBezierTo(
      jawCorner.dx - 6,
      jawCorner.dy + 2,
      throatLatch.dx,
      throatLatch.dy,
    );
    // Down the long front of the neck to the chest.
    final neckFront = const Offset(67, 45) + bob * 0.35;
    path.quadraticBezierTo(
      throatLatch.dx - 7,
      throatLatch.dy + 7,
      neckFront.dx,
      neckFront.dy,
    );
    final chestPoint = const Offset(61, 54);
    path.quadraticBezierTo(64, 50, chestPoint.dx, chestPoint.dy);
    // Girth / chest curve down to the belly.
    final girth = const Offset(59, 60);
    path.quadraticBezierTo(61, 57, girth.dx, girth.dy);
    final bellyLow = const Offset(39, 65);
    path.quadraticBezierTo(49, 65, bellyLow.dx, bellyLow.dy);
    final flank = const Offset(23, 62);
    path.quadraticBezierTo(30, 65, flank.dx, flank.dy);
    // Haunch — a full, rounded hindquarter.
    final buttock = const Offset(15, 54);
    path.quadraticBezierTo(17, 60, buttock.dx, buttock.dy);
    final hindPoint = const Offset(12, 44);
    path.quadraticBezierTo(10, 49, hindPoint.dx, hindPoint.dy);
    final croupTop = const Offset(17, 33);
    path.quadraticBezierTo(11, 38, croupTop.dx, croupTop.dy);
    // Back — a subtle dip then rise toward the withers.
    final backMid = const Offset(35, 29);
    path.quadraticBezierTo(25, 28, backMid.dx, backMid.dy);
    final withers = const Offset(55, 26);
    path.quadraticBezierTo(45, 28, withers.dx, withers.dy);
    // Crest of the neck, arching steeply up to the poll.
    final crestMid = const Offset(67, 17) + bob * 0.5;
    path.quadraticBezierTo(58, 20, crestMid.dx, crestMid.dy);
    path.quadraticBezierTo(
      crestMid.dx + 6,
      crestMid.dy - 6,
      poll.dx,
      poll.dy,
    );
    path.close();
    return path;
  }

  void _paintSilhouette(Canvas canvas, Path silhouette, _CoatPalette p) {
    final bounds = silhouette.getBounds();
    canvas.drawPath(
      silhouette,
      Paint()
        ..shader = ui.Gradient.linear(
          bounds.topCenter,
          bounds.bottomCenter,
          [p.highlight, p.body, p.shade],
          [0, 0.55, 1],
        ),
    );
    // A soft top-light sheen along the crest/back for dimensionality.
    canvas.drawPath(
      silhouette,
      Paint()
        ..color = p.shade.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  void _paintMane(Canvas canvas, _CoatPalette p, Offset bob) {
    final anchors = [
      const Offset(58, 24),
      const Offset(65, 19),
      const Offset(72, 14),
      const Offset(78, 11),
    ];
    for (var i = 0; i < anchors.length; i++) {
      final start = anchors[i] + bob * 0.5;
      final end = start + Offset(-3 - i * 1.4, 13 + i * 1.6);
      final ctrl = start + Offset(-1, 6);
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
      canvas.drawPath(
        path,
        Paint()
          ..color = p.mane.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _paintFace(Canvas canvas, _CoatPalette p, Offset bob) {
    // Ear — small, alert, triangular with a real base (never a thin
    // "horn" spike, never a rounded "toy" ear).
    final earL = const Offset(80, 12) + bob;
    final earR = const Offset(85, 11) + bob;
    final earTip = const Offset(84, 1) + bob;
    final ear = Path()
      ..moveTo(earL.dx, earL.dy)
      ..lineTo(earTip.dx, earTip.dy)
      ..lineTo(earR.dx, earR.dy)
      ..close();
    canvas.drawPath(ear, Paint()..color = p.body);
    canvas.drawPath(
      ear,
      Paint()
        ..color = p.shade.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
    // Inner ear shade.
    canvas.drawPath(
      Path()
        ..moveTo(earL.dx + 0.8, earL.dy - 1.5)
        ..lineTo(earTip.dx, earTip.dy + 2.5)
        ..lineTo(earR.dx - 0.8, earR.dy - 1.5)
        ..close(),
      Paint()..color = p.shade.withValues(alpha: 0.35),
    );

    // Eye — large enough to read as expressive at token scale (spec §3:
    // "grands yeux expressifs") without becoming a cartoon dot.
    final eyeCenter = const Offset(90, 19) + bob * 0.9;
    canvas.drawOval(
      Rect.fromCenter(center: eyeCenter, width: 4.4, height: 3.6),
      Paint()..color = const Color(0xFF1B1712),
    );
    canvas.drawCircle(
      eyeCenter + const Offset(0.8, -0.8),
      0.9,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );

    // Nostril, flared and fine.
    final nostril = const Offset(97, 26) + bob * 0.9;
    canvas.drawOval(
      Rect.fromCenter(center: nostril, width: 2.8, height: 1.9),
      Paint()..color = p.shade,
    );
  }

  void _paintSaddle(Canvas canvas, Offset bob) {
    final saddleColor = colors ?? const Color(0xFFC89B45);
    // Sits on the back, between the withers and the croup — never over
    // the belly/legs.
    final rect = Rect.fromLTWH(37, 34, 24, 11);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3.5));
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
          saddleColor.withValues(alpha: 0.96),
          saddleColor,
        ]),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
    _paintSymbol(canvas, rect.center, team.symbol);
  }

  void _paintSymbol(Canvas canvas, Offset center, TeamSymbol symbol) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    switch (symbol) {
      case TeamSymbol.star:
        canvas.drawPath(_starPath(center, 3.6), paint);
      case TeamSymbol.compass:
        canvas.drawCircle(
          center,
          3.2,
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
        canvas.drawCircle(center, 0.9, paint..style = PaintingStyle.fill);
      case TeamSymbol.lantern:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: 3.8, height: 5.2),
            const Radius.circular(1),
          ),
          paint,
        );
      case TeamSymbol.book:
        canvas.drawRect(
          Rect.fromCenter(center: center, width: 5.2, height: 3.8),
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - 1.9),
          Offset(center.dx, center.dy + 1.9),
          paint,
        );
    }
  }

  Path _starPath(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = (math.pi / 4) * i;
      final r = i.isEven ? radius : radius * 0.45;
      final point = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
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

/// Convenience widget wrapping [HorsePainter] with idle head-bob animation,
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

class _HorseTokenState extends State<HorseToken>
    with SingleTickerProviderStateMixin {
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
          final bob = reduceMotion
              ? 0.0
              : Curves.easeInOut.transform(_controller.value) * 2 - 1;
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
