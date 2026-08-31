import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_team.dart';
import '../../theme/app_theme.dart';
import '../horse_painter.dart';
import '../geometric_motif_painter.dart';
import '../landmarks/hijaz_landmark_painter.dart';
import '../team_symbol_painter.dart';
import 'board_layout.dart';

/// The full game board: shared track, 4 stables, 4 final lanes, and the
/// narrative Makkah→Madinah zone backdrop (spec §14). Purely presentational
/// — reads a [GameState] and renders it; all game logic stays in
/// [GameEngine].
class BoardWidget extends StatelessWidget {
  const BoardWidget({
    super.key,
    required this.state,
    this.selectableHorses = const {},
    this.onHorseTap,
  });

  final GameState state;

  /// Set of "playerId:horseIndex" keys the player may act on this turn.
  final Set<String> selectableHorses;
  final void Function(int playerIndex, int horseIndex)? onHorseTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final circuit = state.circuit;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        final size = Size(side, side);
        final layout = BoardLayout(size, circuit);
        return SizedBox.fromSize(
          size: size,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _BoardPainter(layout: layout, colors: colors, circuit: circuit),
                ),
              ),
              for (final entry in _horseEntries())
                _HorseMarker(
                  layout: layout,
                  playerIndex: entry.$1,
                  horseIndex: entry.$2,
                  team: state.players[entry.$1].team,
                  horse: state.players[entry.$1].horses[entry.$2],
                  selectable: selectableHorses.contains(
                    '${state.players[entry.$1].id}:${entry.$2}',
                  ),
                  onTap: onHorseTap == null ? null : () => onHorseTap!(entry.$1, entry.$2),
                ),
            ],
          ),
        );
      },
    );
  }

  List<(int, int)> _horseEntries() {
    final entries = <(int, int)>[];
    for (var p = 0; p < state.players.length; p++) {
      for (var i = 0; i < state.players[p].horses.length; i++) {
        entries.add((p, i));
      }
    }
    return entries;
  }
}

class _BoardPainter extends CustomPainter {
  const _BoardPainter({required this.layout, required this.colors, required this.circuit});

  final BoardLayout layout;
  final AppSemanticColors colors;
  final Circuit circuit;

  @override
  void paint(Canvas canvas, Size size) {
    _paintGround(canvas, size);
    _paintCornerLandmarks(canvas, size);
    _paintCaravanRoute(canvas, size);
    _paintFinalLanes(canvas, size);
    _paintTrack(canvas, size);
    _paintStables(canvas, size);
    _paintFinishEmblem(canvas, size);
    _paintVignette(canvas, size);
  }

  // -------------------------------------------------------------------
  // Ground: the Makkah → Madinah narrative wash, on the same diagonal as
  // the two corner landmarks, with a low-contrast geometric texture over
  // it (DESIGN_SYSTEM.md §7: texture, never foreground decoration).
  // -------------------------------------------------------------------

  void _paintGround(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0DFC0),
            Color(0xFFE6CD9F),
            Color(0xFFD3BB92),
            Color(0xFFBBC79C),
            Color(0xFF9CBE8A),
          ],
          stops: [0.0, 0.28, 0.52, 0.76, 1.0],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipRect(rect);
    GeometricMotifPainter(
      color: const Color(0xFF4A3A22),
      opacity: 0.05,
      cellSize: size.shortestSide * 0.085,
    ).paint(canvas, size);
    canvas.restore();
  }

  void _paintCornerLandmarks(Canvas canvas, Size size) {
    final s = size.shortestSide * 0.24;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, s, s));
    HijazLandmarkPainter(
      scene: LandmarkScene.makkahValley,
      skyTop: const Color(0x00000000),
      skyBottom: const Color(0x00000000),
      landPrimary: const Color(0xFFCFB88E),
      landShade: const Color(0xFFA98F66),
    ).paint(canvas, Size(s, s));
    canvas.restore();

    canvas.save();
    canvas.translate(size.width - s, size.height - s);
    canvas.clipRect(Rect.fromLTWH(0, 0, s, s));
    HijazLandmarkPainter(
      scene: LandmarkScene.madinahOasis,
      skyTop: const Color(0x00000000),
      skyBottom: const Color(0x00000000),
      landPrimary: const Color(0xFF9EC08C),
      landShade: const Color(0xFF77996B),
    ).paint(canvas, Size(s, s));
    canvas.restore();
  }

  // -------------------------------------------------------------------
  // The route itself. Drawing a broad sand-colored road under the squares
  // is what turns 52 loose tiles into a journey you can follow with a
  // finger — the single biggest legibility win on the board.
  // -------------------------------------------------------------------

  void _paintCaravanRoute(Canvas canvas, Size size) {
    final path = Path()..addRRect(layout.trackRRect);
    final w = size.shortestSide * 0.082;

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF7A5F33).withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 1.14
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.18),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFF6ECD6).withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = colors.goldAccent.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.06,
    );
  }

  void _paintTrack(Canvas canvas, Size size) {
    final sq = size.shortestSide * 0.052;
    final r = Radius.circular(sq * 0.3);
    for (var i = 0; i < circuit.trackLength; i++) {
      final p = layout.trackPoint(i);
      final effect = circuit.effectAt(i);
      final protected = effect == CellEffect.oasis;
      final rect = Rect.fromCenter(center: p, width: sq, height: sq);
      final rrect = RRect.fromRectAndRadius(rect, r);

      // Contact shadow, then a top-lit face: the tiles sit *on* the road
      // rather than being printed into it.
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.translate(0, sq * 0.09), r),
        Paint()
          ..color = const Color(0xFF5A4526).withValues(alpha: 0.22)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, sq * 0.1),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
            Colors.white,
            protected ? const Color(0xFFFBEFD2) : const Color(0xFFF3EBDA),
          ]),
      );

      if (protected) {
        canvas.drawRRect(
          rrect.deflate(sq * 0.05),
          Paint()
            ..color = colors.protectedSquare
            ..style = PaintingStyle.stroke
            ..strokeWidth = sq * 0.11,
        );
        // A tiny eight-point star marks a safe square by shape as well as
        // by color, so it survives colorblindness and greyscale.
        canvas.drawPath(
          eightPointStar(p, sq * 0.2),
          Paint()..color = colors.goldAccent.withValues(alpha: 0.85),
        );
      } else {
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = const Color(0xFF8A7A5C).withValues(alpha: 0.16)
            ..style = PaintingStyle.stroke
            ..strokeWidth = sq * 0.05,
        );
        // Special squares announce themselves by shape, so a player can
        // plan their gait around them before committing (spec §7) — and so
        // they stay legible without relying on color alone.
        if (effect != CellEffect.plain) {
          _paintEffectGlyph(canvas, p, sq * 0.24, effect);
        }
      }
    }
  }

  /// One distinct silhouette per interactive square. Shape carries the
  /// meaning; the tint is only reinforcement.
  void _paintEffectGlyph(Canvas canvas, Offset c, double r, CellEffect effect) {
    final paint = Paint()
      ..color = switch (effect) {
        CellEffect.knowledge => colors.primary,
        CellEffect.challenge => colors.secondary,
        CellEffect.shortcut => colors.success,
        CellEffect.duel => colors.error,
        CellEffect.wisdom => colors.goldAccent,
        CellEffect.relay => colors.primaryDark,
        _ => colors.textSecondary,
      }
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.42
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (effect) {
      case CellEffect.knowledge:
        // An open book: two leaves meeting at a spine.
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - r, c.dy + r * 0.6)
            ..lineTo(c.dx, c.dy + r * 0.2)
            ..lineTo(c.dx + r, c.dy + r * 0.6)
            ..moveTo(c.dx, c.dy + r * 0.2)
            ..lineTo(c.dx, c.dy - r * 0.7),
          paint,
        );
      case CellEffect.challenge:
        // An upward chevron: raise the stakes.
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - r, c.dy + r * 0.4)
            ..lineTo(c.dx, c.dy - r * 0.5)
            ..lineTo(c.dx + r, c.dy + r * 0.4),
          paint,
        );
      case CellEffect.shortcut:
        // A double chevron: skip ahead.
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - r, c.dy - r * 0.6)
            ..lineTo(c.dx * 1 + r * 0.1, c.dy)
            ..lineTo(c.dx - r, c.dy + r * 0.6)
            ..moveTo(c.dx - r * 0.1, c.dy - r * 0.6)
            ..lineTo(c.dx + r, c.dy)
            ..lineTo(c.dx - r * 0.1, c.dy + r * 0.6),
          paint,
        );
      case CellEffect.duel:
        // Two crossed strokes.
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - r * 0.8, c.dy - r * 0.8)
            ..lineTo(c.dx + r * 0.8, c.dy + r * 0.8)
            ..moveTo(c.dx + r * 0.8, c.dy - r * 0.8)
            ..lineTo(c.dx - r * 0.8, c.dy + r * 0.8),
          paint,
        );
      case CellEffect.wisdom:
        // A diamond.
        canvas.drawPath(
          Path()
            ..moveTo(c.dx, c.dy - r)
            ..lineTo(c.dx + r * 0.8, c.dy)
            ..lineTo(c.dx, c.dy + r)
            ..lineTo(c.dx - r * 0.8, c.dy)
            ..close(),
          paint,
        );
      case CellEffect.relay:
        // A baton passed between two points.
        canvas.drawCircle(Offset(c.dx - r * 0.6, c.dy), r * 0.35, paint);
        canvas.drawCircle(Offset(c.dx + r * 0.6, c.dy), r * 0.35, paint);
        canvas.drawLine(Offset(c.dx - r * 0.2, c.dy), Offset(c.dx + r * 0.2, c.dy), paint);
      case CellEffect.plain || CellEffect.oasis:
        break;
    }
  }

  // -------------------------------------------------------------------
  // Final lanes: stepping stones in the team color rather than a fat
  // opaque bar, so they read as squares you travel, matching the track.
  // -------------------------------------------------------------------

  void _paintFinalLanes(Canvas canvas, Size size) {
    final teamColors = [colors.player1, colors.player2, colors.player3, colors.player4];
    final sq = size.shortestSide * 0.042;
    final r = Radius.circular(sq * 0.32);
    for (var t = 0; t < 4; t++) {
      final tint = teamColors[t];
      for (var step = 1; step <= circuit.finalLaneLength; step++) {
        final p = layout.finalLanePoint(t, step);
        final rect = Rect.fromCenter(center: p, width: sq, height: sq);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.translate(0, sq * 0.1), r),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.14)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, sq * 0.12),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, r),
          Paint()
            ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
              Color.lerp(tint, Colors.white, 0.55)!,
              Color.lerp(tint, Colors.white, 0.18)!,
            ]),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, r),
          Paint()
            ..color = tint.withValues(alpha: 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = sq * 0.07,
        );
      }
    }
  }

  // -------------------------------------------------------------------
  // Stables: small walled courtyards. Each carries its team's symbol, so
  // a stable is identified by shape as well as by color (DESIGN_SYSTEM.md
  // §2) — previously they were distinguished by color alone.
  // -------------------------------------------------------------------

  void _paintStables(Canvas canvas, Size size) {
    final teamColors = [colors.player1, colors.player2, colors.player3, colors.player4];
    final margin = size.shortestSide * 0.09;
    final stableSize = margin * 1.7;
    final positions = [
      Offset(margin * 0.6, margin * 0.6),
      Offset(size.width - margin * 0.6, margin * 0.6),
      Offset(size.width - margin * 0.6, size.height - margin * 0.6),
      Offset(margin * 0.6, size.height - margin * 0.6),
    ];
    for (var t = 0; t < 4; t++) {
      final tint = teamColors[t];
      final rect = Rect.fromCenter(center: positions[t], width: stableSize, height: stableSize);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(stableSize * 0.22));

      canvas.drawRRect(
        rrect.shift(Offset(0, stableSize * 0.03)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.13)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, stableSize * 0.06),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = ui.Gradient.linear(rect.topLeft, rect.bottomRight, [
            Colors.white.withValues(alpha: 0.78),
            Color.lerp(tint, Colors.white, 0.72)!,
          ]),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = tint.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stableSize * 0.035,
      );
      canvas.drawRRect(
        rrect.deflate(stableSize * 0.1),
        Paint()
          ..color = tint.withValues(alpha: 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stableSize * 0.015,
      );

      paintTeamSymbol(
        canvas,
        positions[t],
        stableSize * 0.19,
        AppTeam.values[t].symbol,
        color: tint.withValues(alpha: 0.55),
        embossed: false,
      );
    }
  }

  // -------------------------------------------------------------------
  // The destination: a gold medallion on the app's eight-point star.
  // -------------------------------------------------------------------

  void _paintFinishEmblem(Canvas canvas, Size size) {
    final c = layout.center;
    final r = size.shortestSide * 0.072;

    canvas.drawCircle(
      c,
      r * 1.7,
      Paint()
        ..shader = ui.Gradient.radial(c, r * 1.7, [
          colors.goldAccent.withValues(alpha: 0.34),
          colors.goldAccent.withValues(alpha: 0),
        ]),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.linear(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), [
          const Color(0xFFFFF3D6),
          colors.goldAccent,
        ]),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = const Color(0xFF9A7430).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.09,
    );
    canvas.drawPath(
      eightPointStar(c, r * 0.66),
      Paint()..color = const Color(0xFF8A6526).withValues(alpha: 0.55),
    );
    canvas.drawPath(
      eightPointStar(c, r * 0.4, innerRatio: 0.5),
      Paint()..color = const Color(0xFFFFF8E6).withValues(alpha: 0.9),
    );
  }

  /// A soft edge darkening. Board art without one reads as flat paper;
  /// with one it reads as a lit surface.
  void _paintVignette(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          rect.center,
          size.shortestSide * 0.72,
          [
            const Color(0x00000000),
            const Color(0x00000000),
            const Color(0xFF3A2B14).withValues(alpha: 0.18),
          ],
          const [0.0, 0.68, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) => true;
}

class _HorseMarker extends StatelessWidget {
  const _HorseMarker({
    required this.layout,
    required this.playerIndex,
    required this.horseIndex,
    required this.team,
    required this.horse,
    required this.selectable,
    this.onTap,
  });

  final BoardLayout layout;
  final int playerIndex;
  final int horseIndex;
  final AppTeam team;
  final HorseState horse;
  final bool selectable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final center = horse.isHome
        ? layout.homeSlot(playerIndex, horseIndex)
        : layout.pointFor(playerIndex, horse.position);
    final tokenSize = layout.size.shortestSide * 0.075;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      left: center.dx - tokenSize / 2,
      top: center.dy - tokenSize / 2,
      child: Semantics(
        label:
            '${team.name} horse ${horseIndex + 1}'
            '${horse.hasShield ? ', shielded' : ''}, '
            '${selectable ? 'selectable' : 'not selectable'}',
        button: selectable,
        child: GestureDetector(
          onTap: selectable ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: tokenSize,
            height: tokenSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: selectable
                  ? [
                      BoxShadow(
                        color: team.color(colors).withValues(alpha: 0.55),
                        blurRadius: tokenSize * 0.4,
                        spreadRadius: tokenSize * 0.08,
                      ),
                    ]
                  : const [],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                HorseToken(coat: team.coat, team: team, size: tokenSize, color: team.color(colors)),
                // A knowledge shield is drawn as a ring around the horse,
                // so protection is visible on the board itself.
                if (horse.hasShield)
                  Positioned.fill(
                    child: CustomPaint(painter: _ShieldRingPainter(colors.goldAccent)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShieldRingPainter extends CustomPainter {
  const _ShieldRingPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.48;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.07,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.16,
    );
  }

  @override
  bool shouldRepaint(covariant _ShieldRingPainter oldDelegate) => oldDelegate.color != color;
}
