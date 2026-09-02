import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// How long a celebration holds the screen before play resumes. Long
/// enough to be read aloud by the child who drew the card; short enough
/// that the fourth six of the evening is still a lift, not a wait.
const Duration kCelebrationDuration = Duration(milliseconds: 1250);

/// The moments a family game shouts about.
enum CelebrationKind {
  /// The gate opens for a horse waiting in the stable (on the 6, which
  /// also replays — so this is folded into [six] whenever both apply).
  stableOpen,

  /// A 6: the same player draws again.
  six,

  /// The player's horse lands on an opponent and sends it home.
  capture,

  /// An opponent lands on the player's horse. Not a celebration — a
  /// muted notice, so the moment is understood without being rubbed in.
  captured,

  /// A horse reaches the centre.
  arrival,
}

/// A full-screen beat over the board: a burst of gold rays, a scatter of
/// stars, the title landing in big letters and one line under it.
///
/// It never blocks: it ignores pointers, so a player in a hurry can tap
/// the thing underneath, and the caller takes it down after
/// [kCelebrationDuration] (or on [onTap], which sits on a transparent
/// layer only when the caller wants tap-to-skip). Under Reduce Motion
/// the rays stand still and the stars stay home; the words still land.
class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.kind,
    required this.title,
    required this.body,
    this.onTap,
  });

  final CelebrationKind kind;
  final String title;
  final String body;

  /// Tap-to-skip. When null the overlay is transparent to touches.
  final VoidCallback? onTap;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: kCelebrationDuration + const Duration(milliseconds: 400),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  _Palette get _palette => switch (widget.kind) {
    CelebrationKind.six => const _Palette(
      ray: Color(0xFFFFE08A),
      glow: Color(0xFFF3C55A),
      title: Color(0xFFFFF1C2),
      star: Color(0xFFFFE9AE),
    ),
    CelebrationKind.stableOpen => const _Palette(
      ray: Color(0xFFBDEBC8),
      glow: Color(0xFF6FCF97),
      title: Color(0xFFF2FFF4),
      star: Color(0xFFD7F5DF),
    ),
    CelebrationKind.capture => const _Palette(
      ray: Color(0xFFFFC7A0),
      glow: Color(0xFFF08A4B),
      title: Color(0xFFFFF3E8),
      star: Color(0xFFFFD9B8),
    ),
    CelebrationKind.captured => const _Palette(
      ray: Color(0x66A9B7C6),
      glow: Color(0xFF6B7C8E),
      title: Color(0xFFE6EBF2),
      star: Color(0x00000000),
    ),
    CelebrationKind.arrival => const _Palette(
      ray: Color(0xFFFFF0B8),
      glow: Color(0xFFF7D77A),
      title: Color(0xFFFFFBEA),
      star: Color(0xFFFFF4CC),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final palette = _palette;
    final muted = widget.kind == CelebrationKind.captured;

    final content = AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        // The words land fast and stay; the light behind them keeps
        // turning until the caller takes the overlay down.
        final land = reduce
            ? 1.0
            : Curves.easeOutBack.transform((t * 2.6).clamp(0.0, 1.0));
        final fade = reduce ? 1.0 : (t * 4).clamp(0.0, 1.0);
        final spin = reduce ? 0.0 : t * math.pi * 0.35;
        return Stack(
          fit: StackFit.expand,
          children: [
            // A soft vignette, so the words read over any board.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.9,
                  colors: [
                    palette.glow.withValues(alpha: muted ? 0.10 : 0.28 * fade),
                    const Color(0x0006231A),
                    Color.fromARGB((150 * fade).round(), 6, 35, 26),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            if (!muted)
              CustomPaint(
                painter: _RaysPainter(
                  color: palette.ray,
                  rotation: spin,
                  alpha: 0.55 * fade,
                ),
              ),
            if (!reduce && !muted)
              CustomPaint(
                painter: _StarsPainter(color: palette.star, progress: t),
              ),
            Center(
              child: Transform.scale(
                scale: 0.6 + 0.4 * land,
                child: Opacity(opacity: fade, child: child),
              ),
            ),
          ],
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: palette.title,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                height: 1.05,
                shadows: [
                  Shadow(
                    color: palette.glow.withValues(alpha: 0.9),
                    blurRadius: 26,
                  ),
                  const Shadow(
                    color: Color(0xCC000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFF4ECDC),
                fontWeight: FontWeight.w600,
                height: 1.25,
                shadows: const [
                  Shadow(color: Color(0xCC000000), blurRadius: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final announced = Semantics(
      liveRegion: true,
      label: '${widget.title} ${widget.body}',
      child: ExcludeSemantics(child: content),
    );

    if (widget.onTap == null) return IgnorePointer(child: announced);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: announced,
    );
  }
}

class _Palette {
  const _Palette({
    required this.ray,
    required this.glow,
    required this.title,
    required this.star,
  });

  final Color ray;
  final Color glow;
  final Color title;
  final Color star;
}

/// Sixteen soft rays from the centre, slowly turning.
class _RaysPainter extends CustomPainter {
  const _RaysPainter({
    required this.color,
    required this.rotation,
    required this.alpha,
  });

  final Color color;
  final double rotation;
  final double alpha;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.longestSide * 0.75;
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        c,
        r,
        [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
        const [0.05, 1.0],
      );
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rotation);
    for (var i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      final w = 0.075;
      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..lineTo(r * math.cos(a - w), r * math.sin(a - w))
          ..lineTo(r * math.cos(a + w), r * math.sin(a + w))
          ..close(),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RaysPainter old) =>
      old.rotation != rotation || old.alpha != alpha || old.color != color;
}

/// A scatter of four-point stars thrown up from the centre and drifting
/// out and down — the confetti of a game that has no confetti gun.
class _StarsPainter extends CustomPainter {
  const _StarsPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  static const _count = 26;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final rng = math.Random(7);
    final paint = Paint()..color = color;
    for (var i = 0; i < _count; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final speed = 0.28 + rng.nextDouble() * 0.5;
      final delay = rng.nextDouble() * 0.25;
      final sizeStar = 5.0 + rng.nextDouble() * 9;
      final spin = rng.nextDouble() * math.pi;
      final t = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final ease = Curves.easeOutCubic.transform(t);
      final dist = ease * speed * size.shortestSide;
      final gravity = t * t * size.height * 0.18;
      final p = Offset(
        c.dx + math.cos(angle) * dist,
        c.dy + math.sin(angle) * dist * 0.75 + gravity,
      );
      final alpha = (1 - t) * (t < 0.15 ? t / 0.15 : 1);
      paint.color = color.withValues(alpha: alpha.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(spin + t * 2);
      _star(canvas, sizeStar, paint);
      canvas.restore();
    }
  }

  void _star(Canvas canvas, double s, Paint paint) {
    final path = Path();
    for (var k = 0; k < 8; k++) {
      final r = k.isEven ? s : s * 0.38;
      final a = k * math.pi / 4;
      final p = Offset(math.cos(a) * r, math.sin(a) * r);
      if (k == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarsPainter old) =>
      old.progress != progress || old.color != color;
}
