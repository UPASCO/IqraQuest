import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Static ivory/bone die face — no casino red, no dot-per-corner "poker
/// dice" styling (spec §26).
class DicePainter extends CustomPainter {
  const DicePainter({required this.value, this.faceColor, this.pipColor});

  final int value;
  final Color? faceColor;
  final Color? pipColor;

  static const _pipLayouts = <int, List<Offset>>{
    1: [Offset(0.5, 0.5)],
    2: [Offset(0.28, 0.28), Offset(0.72, 0.72)],
    3: [Offset(0.28, 0.28), Offset(0.5, 0.5), Offset(0.72, 0.72)],
    4: [Offset(0.28, 0.28), Offset(0.72, 0.28), Offset(0.28, 0.72), Offset(0.72, 0.72)],
    5: [
      Offset(0.28, 0.28),
      Offset(0.72, 0.28),
      Offset(0.5, 0.5),
      Offset(0.28, 0.72),
      Offset(0.72, 0.72),
    ],
    6: [
      Offset(0.28, 0.22),
      Offset(0.72, 0.22),
      Offset(0.28, 0.5),
      Offset(0.72, 0.5),
      Offset(0.28, 0.78),
      Offset(0.72, 0.78),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.shortestSide * 0.22));

    canvas.drawShadow(Path()..addRRect(rrect), Colors.black, 3, false);
    canvas.drawRRect(rrect, Paint()..color = faceColor ?? const Color(0xFFF6EFDD));
    canvas.drawRRect(
      rrect.deflate(0.8),
      Paint()
        ..color = (pipColor ?? const Color(0xFFC89B45)).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final pipRadius = size.shortestSide * 0.07;
    final pipPaint = Paint()..color = pipColor ?? const Color(0xFF3A2E1F);
    for (final p in _pipLayouts[value.clamp(1, 6)]!) {
      canvas.drawCircle(Offset(p.dx * size.width, p.dy * size.height), pipRadius, pipPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DicePainter oldDelegate) => oldDelegate.value != value;
}

/// A tactile, quick dice-roll widget (spec §26: "≤ quelques secondes").
/// Call [DiceWidgetState.roll] to animate to a new value.
class DiceWidget extends StatefulWidget {
  const DiceWidget({
    super.key,
    required this.value,
    this.size = 72,
    this.onTap,
    this.enabled = true,
  });

  final int value;
  final double size;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<DiceWidget> createState() => DiceWidgetState();
}

class DiceWidgetState extends State<DiceWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  late Animation<double> _rotation = _controller.drive(Tween(begin: 0, end: 1));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Spins the die briefly to sell the roll, respecting Reduce Motion.
  Future<void> roll() async {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) return;
    _rotation = CurveTween(curve: Curves.easeOutBack).animate(_controller);
    _controller.reset();
    await _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Dice showing ${widget.value}',
      enabled: widget.enabled,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedBuilder(
          animation: _rotation,
          builder: (context, child) {
            final angle = _rotation.value * math.pi * 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(angle),
              child: Opacity(opacity: widget.enabled ? 1 : 0.45, child: child),
            );
          },
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: DicePainter(
                value: widget.value,
                pipColor: context.colors.textPrimary,
                faceColor: context.colors.surfaceElevated,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
