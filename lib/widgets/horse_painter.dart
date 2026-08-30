import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_team.dart';

/// Coat color values. Kept separate from [AppColors] — these are
/// naturalistic horse-coat tones, not brand tokens. See
/// VISUAL_REFERENCE_NOTES.md for the art brief this implements.
class _CoatPalette {
  const _CoatPalette(this.body, this.shade, this.points, this.mane);
  final Color body;
  final Color shade; // darker body tone for form/shadow
  final Color points; // legs/mane/tail "points" color
  final Color mane;
}

const Map<HorseCoat, _CoatPalette> _coatPalettes = {
  HorseCoat.grayWhite: _CoatPalette(
    Color(0xFFEDE7DA),
    Color(0xFFD3CAB6),
    Color(0xFFB9AF9C),
    Color(0xFFCFC6B4),
  ),
  HorseCoat.bay: _CoatPalette(
    Color(0xFF7B4B32),
    Color(0xFF5E3A26),
    Color(0xFF241C17),
    Color(0xFF241C17),
  ),
  HorseCoat.chestnut: _CoatPalette(
    Color(0xFFA85C32),
    Color(0xFF8A4A28),
    Color(0xFF6B3A22),
    Color(0xFF6B3A22),
  ),
  HorseCoat.black: _CoatPalette(
    Color(0xFF2B2620),
    Color(0xFF1B1712),
    Color(0xFF14110D),
    Color(0xFF14110D),
  ),
};

/// The pose driving leg/tail/neck geometry. Idle head-bob and dust are
/// layered on top by the widget, not the painter (spec §24–25: motion
/// lives in the presentation layer so it can be muted for Reduce Motion).
enum HorsePose { standing, trot, gallop, rearingProud }

/// Draws IqraQuest's signature arabian-horse token: a refined, noble
/// silhouette (arched neck, fine legs, high tail) — never a cartoon toy,
/// never a jockey/racing aesthetic (spec §3–§5). Pure vector, so it scales
/// losslessly from a 24dp board pawn to a full-bleed hero illustration.
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

  @override
  void paint(Canvas canvas, Size size) {
    final palette = _coatPalettes[coat]!;
    canvas.save();
    // Normalize to a 100x64 viewBox, then scale + optionally mirror.
    final scale = math.min(size.width / 100, size.height / 64);
    canvas.translate((size.width - 100 * scale) / 2, (size.height - 64 * scale) / 2);
    if (!facingRight) {
      canvas.translate(100 * scale, 0);
      canvas.scale(-scale, scale);
    } else {
      canvas.scale(scale, scale);
    }

    _paintLegs(canvas, palette);
    _paintTail(canvas, palette);
    _paintBody(canvas, palette);
    _paintNeckAndHead(canvas, palette);
    if (showSaddle) _paintSaddle(canvas);

    canvas.restore();
  }

  void _paintLegs(Canvas canvas, _CoatPalette p) {
    final paint = Paint()..color = p.points;
    final bend = switch (pose) {
      HorsePose.standing => 0.0,
      HorsePose.trot => 8.0,
      HorsePose.gallop => 14.0,
      HorsePose.rearingProud => 0.0,
    };
    // Four fine legs: back-left, front-left, front-right, back-right.
    final legsX = pose == HorsePose.rearingProud
        ? [22.0, 40.0, 62.0, 78.0]
        : [24.0, 42.0, 58.0, 76.0];
    final legLift = pose == HorsePose.rearingProud
        ? [0.0, 0.0, 10.0, 6.0]
        : [0.0, bend, bend * .6, 0.0];

    for (var i = 0; i < 4; i++) {
      final x = legsX[i];
      final lift = legLift[i];
      final topY = 34.0;
      final bottomY = (pose == HorsePose.rearingProud && i >= 2) ? 60.0 - lift : 60.0;
      final path = Path()
        ..moveTo(x - 2.2, topY)
        ..lineTo(x - 1.4, bottomY - lift)
        ..lineTo(x + 1.4, bottomY - lift)
        ..lineTo(x + 2.2, topY)
        ..close();
      canvas.drawPath(path, paint);
      // small hoof
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 2.4, bottomY - lift - 1.5, 4.8, 3),
          const Radius.circular(1),
        ),
        Paint()..color = p.shade,
      );
    }
  }

  void _paintTail(Canvas canvas, _CoatPalette p) {
    final paint = Paint()
      ..color = p.mane
      ..style = PaintingStyle.fill;
    final high = pose == HorsePose.gallop || pose == HorsePose.rearingProud;
    final start = const Offset(20, 30);
    final path = Path()..moveTo(start.dx, start.dy - 2);
    if (high) {
      path.cubicTo(4, 18, 0, 6, 10, 2);
      path.cubicTo(4, 10, 6, 22, start.dx + 3, start.dy + 6);
    } else {
      path.cubicTo(6, 34, 2, 48, 8, 60);
      path.cubicTo(4, 46, 8, 34, start.dx + 4, start.dy + 4);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _paintBody(Canvas canvas, _CoatPalette p) {
    final rect = Rect.fromLTWH(20, 26, 46, 20);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: const Radius.elliptical(14, 10),
      topRight: const Radius.elliptical(18, 12),
      bottomLeft: const Radius.elliptical(10, 8),
      bottomRight: const Radius.elliptical(14, 10),
    );
    canvas.drawRRect(rrect, Paint()..color = p.body);
    // subtle form shadow along the underside
    final shadow = Path()
      ..moveTo(24, 42)
      ..quadraticBezierTo(44, 48, 62, 40)
      ..quadraticBezierTo(44, 44, 24, 42)
      ..close();
    canvas.drawPath(shadow, Paint()..color = p.shade.withValues(alpha: 0.55));
  }

  void _paintNeckAndHead(Canvas canvas, _CoatPalette p) {
    final bob = headBob * 2.2;
    final rearing = pose == HorsePose.rearingProud;

    final neckBase = const Offset(58, 30);
    final headTop = Offset(78 + (rearing ? 4 : 0), (rearing ? 4 : 12) + bob);

    final neck = Path()
      ..moveTo(neckBase.dx - 6, neckBase.dy + 6)
      ..cubicTo(
        neckBase.dx + 2,
        neckBase.dy - (rearing ? 22 : 12),
        headTop.dx - 10,
        headTop.dy + 10,
        headTop.dx - 2,
        headTop.dy + 4,
      )
      ..lineTo(headTop.dx + 12, headTop.dy + 10)
      ..cubicTo(
        headTop.dx - 2,
        headTop.dy + 18,
        neckBase.dx + 10,
        neckBase.dy + 2,
        neckBase.dx + 12,
        neckBase.dy + 10,
      )
      ..close();
    canvas.drawPath(neck, Paint()..color = p.body);

    // Mane crest along the top of the neck.
    final mane = Path()
      ..moveTo(neckBase.dx - 4, neckBase.dy + 4)
      ..cubicTo(
        neckBase.dx + 4,
        neckBase.dy - (rearing ? 24 : 14),
        headTop.dx - 12,
        headTop.dy + 6,
        headTop.dx - 3,
        headTop.dy + 2,
      )
      ..lineTo(headTop.dx - 1, headTop.dy + 6)
      ..cubicTo(
        headTop.dx - 12,
        headTop.dy + 10,
        neckBase.dx + 1,
        neckBase.dy - (rearing ? 18 : 8),
        neckBase.dx - 1,
        neckBase.dy + 8,
      )
      ..close();
    canvas.drawPath(mane, Paint()..color = p.mane);

    // Head: refined, elongated, with a fine muzzle taper — never
    // caricatured/oversized (spec §3).
    final head = Path()
      ..moveTo(headTop.dx - 3, headTop.dy + 3)
      ..cubicTo(
        headTop.dx + 8,
        headTop.dy - 3,
        headTop.dx + 20,
        headTop.dy + 2,
        headTop.dx + 26,
        headTop.dy + 9,
      )
      ..cubicTo(
        headTop.dx + 28,
        headTop.dy + 11,
        headTop.dx + 27,
        headTop.dy + 13,
        headTop.dx + 24,
        headTop.dy + 13,
      )
      ..lineTo(headTop.dx + 20, headTop.dy + 12.5)
      ..cubicTo(
        headTop.dx + 16,
        headTop.dy + 17,
        headTop.dx + 6,
        headTop.dy + 19,
        headTop.dx,
        headTop.dy + 16,
      )
      ..cubicTo(
        headTop.dx - 4,
        headTop.dy + 14,
        headTop.dx - 5,
        headTop.dy + 6,
        headTop.dx - 3,
        headTop.dy + 3,
      )
      ..close();
    canvas.drawPath(head, Paint()..color = p.body);

    // Ear — small, alert, pointed (not a rounded "toy" ear).
    final ear = Path()
      ..moveTo(headTop.dx - 1, headTop.dy + 3)
      ..lineTo(headTop.dx + 3, headTop.dy - 6)
      ..lineTo(headTop.dx + 7, headTop.dy + 4)
      ..close();
    canvas.drawPath(ear, Paint()..color = p.body);
    canvas.drawPath(
      ear,
      Paint()
        ..color = p.shade
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    // Eye — large enough to read as expressive at token scale, without
    // becoming a cartoon dot (spec §3: "grands yeux expressifs").
    canvas.drawCircle(
      Offset(headTop.dx + 13, headTop.dy + 9),
      1.8,
      Paint()..color = const Color(0xFF1B1712),
    );
    canvas.drawCircle(
      Offset(headTop.dx + 13.5, headTop.dy + 8.5),
      0.6,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    // Nostril.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(headTop.dx + 23, headTop.dy + 11), width: 2.4, height: 1.4),
      Paint()..color = p.shade,
    );
  }

  void _paintSaddle(Canvas canvas) {
    final saddleColor = colors ?? const Color(0xFFC89B45);
    final rect = Rect.fromLTWH(30, 27, 22, 11);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = saddleColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
    _paintSymbol(canvas, rect.center, team.symbol);
  }

  void _paintSymbol(Canvas canvas, Offset center, TeamSymbol symbol) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    switch (symbol) {
      case TeamSymbol.star:
        canvas.drawPath(_starPath(center, 3.4), paint);
      case TeamSymbol.compass:
        canvas.drawCircle(
          center,
          3,
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
        canvas.drawCircle(center, 0.8, paint..style = PaintingStyle.fill);
      case TeamSymbol.lantern:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: 3.6, height: 5),
            const Radius.circular(1),
          ),
          paint,
        );
      case TeamSymbol.book:
        canvas.drawRect(
          Rect.fromCenter(center: center, width: 5, height: 3.6),
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - 1.8),
          Offset(center.dx, center.dy + 1.8),
          paint,
        );
    }
  }

  Path _starPath(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = (math.pi / 4) * i;
      final r = i.isEven ? radius : radius * 0.45;
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
      height: widget.size * 0.64,
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
