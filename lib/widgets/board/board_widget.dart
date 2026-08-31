import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_team.dart';
import '../../theme/app_theme.dart';
import '../horse_painter.dart';
import '../team_symbol_painter.dart';
import 'board_layout.dart';

/// The full game board: shared track, 4 stables, 4 final lanes, and the
/// narrative Makkah→Madinah zone backdrop (spec §14). Purely presentational
/// — reads a [GameState] and renders it; all game logic stays in
/// [GameEngine].
/// What an armed gait would do, for the on-board destination preview.
class BoardPreview {
  const BoardPreview({required this.teamIndex, required this.from, required this.destination});

  final int teamIndex;
  final PawnPosition? from;
  final PawnPosition destination;
}

class BoardWidget extends StatelessWidget {
  const BoardWidget({
    super.key,
    required this.state,
    this.selectableHorses = const {},
    this.onHorseTap,
    this.preview,
    this.billboardAngle = 0,
  });

  final GameState state;
  final BoardPreview? preview;

  /// When the board is tilted into the landscape by rotateX(angle), pass
  /// the same angle here: the horses counter-rotate about their feet so
  /// they STAND on the receding ground instead of lying flat on it —
  /// the difference between "a tilted board" and "a world".
  final double billboardAngle;

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
                  painter: _BoardPainter(
                    layout: layout,
                    colors: colors,
                    circuit: circuit,
                    preview: preview,
                  ),
                ),
              ),
              for (final entry in _horseEntries())
                _HorseMarker(
                  key: ValueKey('horse:${state.players[entry.$1].id}:${entry.$2}'),
                  layout: layout,
                  circuit: circuit,
                  billboardAngle: billboardAngle,
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
  const _BoardPainter({
    required this.layout,
    required this.colors,
    required this.circuit,
    this.preview,
  });

  final BoardLayout layout;
  final AppSemanticColors colors;
  final Circuit circuit;
  final BoardPreview? preview;

  @override
  void paint(Canvas canvas, Size size) {
    // The environment (BoardEnvironmentPainter) owns sky and ground; the
    // board paints only the journey itself, sitting on that landscape.
    _paintCaravanRoute(canvas, size);
    _paintFinalLanes(canvas, size);
    _paintTrack(canvas, size);
    _paintCamps(canvas, size);
    _paintOasisDestination(canvas, size);
    _paintOccluders(canvas, size);
    _paintPreview(canvas, size);
  }

  /// Breadcrumbs from the horse to where the armed gait would land, plus
  /// a gold beacon on the destination: "if I choose 4, I arrive HERE".
  void _paintPreview(Canvas canvas, Size size) {
    final preview = this.preview;
    if (preview == null) return;
    final from = preview.from;
    final p0 = from == null ? -1 : (circuit.progressOf(from, preview.teamIndex) ?? -1);
    final p1 = circuit.progressOf(preview.destination, preview.teamIndex);
    if (p1 == null) return;

    final dot = Paint()..color = const Color(0xFFFFE9AE);
    final dotEdge = Paint()
      ..color = const Color(0xFF8A6526).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var p = p0 + 1; p < p1; p++) {
      final pos = circuit.positionAt(p, preview.teamIndex);
      final o = layout.pointFor(preview.teamIndex, pos);
      canvas.drawCircle(o, size.shortestSide * 0.011, dot);
      canvas.drawCircle(o, size.shortestSide * 0.011, dotEdge);
    }

    final dest = layout.pointFor(preview.teamIndex, preview.destination);
    final r = size.shortestSide * 0.045;
    canvas.drawCircle(
      dest,
      r * 1.9,
      Paint()
        ..shader = ui.Gradient.radial(dest, r * 1.9, [
          const Color(0xAAFFD873),
          const Color(0x00FFD873),
        ]),
    );
    canvas.drawCircle(
      dest,
      r,
      Paint()
        ..color = const Color(0xFFFFE9AE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.24,
    );
    canvas.drawCircle(
      dest,
      r * 0.66,
      Paint()
        ..color = const Color(0xFFB8893A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.13,
    );
  }

  void _paintPalm(Canvas canvas, Offset base, double h) {
    final trunk = Paint()
      ..color = const Color(0xFF6B4F2E)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = h * 0.14;
    final top = Offset(base.dx + h * 0.18, base.dy - h);
    canvas.drawPath(
      Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(base.dx + h * 0.02, base.dy - h * 0.6, top.dx, top.dy),
      trunk,
    );
    final frond = Paint()
      ..color = const Color(0xFF3E7048)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = h * 0.12;
    for (final (dx, dy) in [
      (-0.55, -0.18),
      (-0.30, -0.42),
      (0.10, -0.48),
      (0.48, -0.30),
      (0.60, -0.02),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(top.dx, top.dy)
          ..quadraticBezierTo(
            top.dx + h * dx * 0.6,
            top.dy + h * dy * 1.2,
            top.dx + h * dx,
            top.dy + h * dy + h * 0.16,
          ),
        frond,
      );
    }
  }

  // -------------------------------------------------------------------
  // The route itself. Drawing a broad sand-colored road under the squares
  // is what turns 52 loose tiles into a journey you can follow with a
  // finger — the single biggest legibility win on the board.
  // -------------------------------------------------------------------

  void _paintCaravanRoute(Canvas canvas, Size size) {
    final path = layout.trackPath;
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
    final r = Radius.circular(sq * 0.34);
    for (var i = 0; i < circuit.trackLength; i++) {
      final p = layout.trackPoint(i);
      final effect = circuit.effectAt(i);
      final protected = effect == CellEffect.oasis;

      // A plain square is just a worn stepping stone on the trail — quiet
      // ground, not a UI element. Only the special places stand out.
      if (effect == CellEffect.plain) {
        final stoneW = sq * 0.66;
        final stoneH = sq * 0.46;
        canvas.save();
        canvas.translate(p.dx, p.dy);
        canvas.rotate(math.sin(i * 3.7) * 0.35);
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(0, 1.5), width: stoneW, height: stoneH),
          Paint()..color = const Color(0xFF8A6F45).withValues(alpha: 0.35),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: stoneW, height: stoneH),
          Paint()
            ..shader = ui.Gradient.linear(Offset(0, -stoneH / 2), Offset(0, stoneH / 2), [
              const Color(0xFFF6EBD2),
              const Color(0xFFDDC69B),
            ]),
        );
        canvas.restore();
        continue;
      }

      if (effect == CellEffect.challenge) {
        _paintChest(canvas, p, sq * 0.95);
        continue;
      }

      final rect = Rect.fromCenter(center: p, width: sq, height: sq);
      final rrect = RRect.fromRectAndRadius(rect, r);

      // Contact shadow, then a top-lit face: the landmarks sit *on* the
      // trail rather than being printed into it.
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.translate(0, sq * 0.09), r),
        Paint()
          ..color = const Color(0xFF5A4526).withValues(alpha: 0.26)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, sq * 0.1),
      );

      if (protected) {
        // The oasis is a place, not a marking: a small pool with a palm.
        canvas.drawRRect(
          rrect,
          Paint()
            ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
              const Color(0xFFBFE3DC),
              const Color(0xFF8FC7BC),
            ]),
        );
        canvas.drawOval(
          Rect.fromCenter(center: p.translate(0, sq * 0.18), width: sq * 0.62, height: sq * 0.30),
          Paint()..color = const Color(0xFF4E93A8).withValues(alpha: 0.85),
        );
        _paintPalm(canvas, p.translate(-sq * 0.10, sq * 0.26), sq * 0.52);
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = const Color(0xFF3E7C71).withValues(alpha: 0.55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = sq * 0.05,
        );
      } else {
        // A special square owns its whole tile: a colored face with a
        // bold white glyph, readable at a glance and without any text —
        // this is what lets a player spot "the chest two squares ahead"
        // and want to reach it.
        final tint = _effectTint(effect);
        canvas.drawRRect(
          rrect,
          Paint()
            ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
              Color.lerp(tint, Colors.white, 0.28)!,
              tint,
            ]),
        );
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = Color.lerp(tint, Colors.black, 0.28)!.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = sq * 0.05,
        );
        _paintEffectGlyph(canvas, p, sq * 0.26, effect);
      }
    }
  }

  void _paintChest(Canvas canvas, Offset p, double w) => paintChestLandmark(canvas, p, w);

  Color _effectTint(CellEffect effect) => switch (effect) {
    CellEffect.knowledge => const Color(0xFF1F7A5C),
    CellEffect.challenge => const Color(0xFFC06B3E),
    CellEffect.shortcut => const Color(0xFF3E8FA8),
    CellEffect.duel => const Color(0xFFA84E55),
    CellEffect.wisdom => const Color(0xFFC79A3F),
    CellEffect.relay => const Color(0xFF5C6BA8),
    _ => const Color(0xFF8A7A5C),
  };

  /// One distinct silhouette per interactive square. Shape carries the
  /// meaning; the tile's tint is only reinforcement.
  void _paintEffectGlyph(Canvas canvas, Offset c, double r, CellEffect effect) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.46
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
        // A hand-off: circulating arc with an arrowhead.
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: r * 0.75),
          -math.pi * 0.75,
          math.pi * 1.5,
          false,
          paint,
        );
        final tip = Offset(
          c.dx + r * 0.75 * math.cos(-math.pi * 0.75),
          c.dy + r * 0.75 * math.sin(-math.pi * 0.75),
        );
        canvas.drawPath(
          Path()
            ..moveTo(tip.dx - r * 0.42, tip.dy - r * 0.02)
            ..lineTo(tip.dx + r * 0.10, tip.dy - r * 0.38)
            ..lineTo(tip.dx + r * 0.16, tip.dy + r * 0.30)
            ..close(),
          Paint()..color = Colors.white,
        );
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
    final sq = size.shortestSide * 0.034;
    final r = Radius.circular(sq * 0.32);
    for (var t = 0; t < 4; t++) {
      final tint = teamColors[t];

      // A worn trail from the track to the centre, drawn under the
      // stepping stones: without it the four lanes read as loose confetti
      // scattered across the middle of the board.
      final exit = (circuit.entryIndexForTeam(t) - 1 + circuit.trackLength) % circuit.trackLength;
      final start = layout.trackPoint(exit);
      final pts = [
        start,
        for (var step = 1; step <= circuit.finalLaneLength; step++) layout.finalLanePoint(t, step),
        layout.center,
      ];
      final trail = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 1; i < pts.length; i++) {
        final prev = pts[i - 1];
        final mid = Offset.lerp(prev, pts[i], 0.5)!;
        trail.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
      }
      trail.lineTo(pts.last.dx, pts.last.dy);
      canvas.drawPath(
        trail,
        Paint()
          ..color = const Color(0xFFF6ECD6).withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = sq * 0.52,
      );
      canvas.drawPath(
        trail,
        Paint()
          ..color = tint.withValues(alpha: 0.30)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = sq * 0.10,
      );
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
  // Camps: each team's stable is a caravan camp pitched just off the
  // trail at its own entry — part of the journey, not a board corner.
  // -------------------------------------------------------------------

  void _paintCamps(Canvas canvas, Size size) {
    final teamColors = [colors.player1, colors.player2, colors.player3, colors.player4];
    final campSize = size.shortestSide * 0.115;
    for (var t = 0; t < 4; t++) {
      final tint = teamColors[t];
      final c = layout.campCenter(t);

      // Trodden ground under the camp.
      canvas.drawOval(
        Rect.fromCenter(
          center: c.translate(0, campSize * 0.18),
          width: campSize * 1.5,
          height: campSize * 0.62,
        ),
        Paint()..color = const Color(0xFF8A6F45).withValues(alpha: 0.28),
      );

      final tentW = campSize * 0.94;
      final tentH = campSize * 0.62;
      final baseY = c.dy + campSize * 0.24;
      final apex = Offset(c.dx, baseY - tentH);
      final tent = Path()
        ..moveTo(c.dx - tentW / 2, baseY)
        ..quadraticBezierTo(c.dx - tentW * 0.16, baseY - tentH * 0.74, apex.dx, apex.dy)
        ..quadraticBezierTo(c.dx + tentW * 0.16, baseY - tentH * 0.74, c.dx + tentW / 2, baseY)
        ..close();
      canvas.drawPath(
        tent,
        Paint()
          ..shader = ui.Gradient.linear(apex, Offset(apex.dx, baseY), [
            Color.lerp(tint, Colors.white, 0.42)!,
            Color.lerp(tint, Colors.white, 0.02)!,
          ]),
      );
      canvas.drawPath(
        Path()
          ..moveTo(c.dx - tentW * 0.11, baseY)
          ..lineTo(c.dx, baseY - tentH * 0.40)
          ..lineTo(c.dx + tentW * 0.11, baseY)
          ..close(),
        Paint()..color = Color.lerp(tint, Colors.black, 0.45)!,
      );
      final poleTop = apex.translate(0, -campSize * 0.20);
      canvas.drawLine(
        apex,
        poleTop,
        Paint()
          ..color = const Color(0xFF6B4F2E)
          ..strokeWidth = campSize * 0.030
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(
        Path()
          ..moveTo(poleTop.dx, poleTop.dy)
          ..lineTo(poleTop.dx + campSize * 0.22, poleTop.dy + campSize * 0.07)
          ..lineTo(poleTop.dx, poleTop.dy + campSize * 0.14)
          ..close(),
        Paint()..color = tint,
      );
      paintTeamSymbol(
        canvas,
        Offset(c.dx, baseY + campSize * 0.14),
        campSize * 0.11,
        AppTeam.values[t].symbol,
        color: tint.withValues(alpha: 0.85),
        embossed: false,
      );
    }
  }

  // -------------------------------------------------------------------
  // The destination is a real place: a small oasis at the heart of the
  // land — water, palms, a golden glow. "I want to reach THAT."
  // -------------------------------------------------------------------

  void _paintOasisDestination(Canvas canvas, Size size) {
    final c = layout.center;
    final s = size.shortestSide;

    canvas.drawCircle(
      c,
      s * 0.13,
      Paint()
        ..shader = ui.Gradient.radial(c, s * 0.13, [
          colors.goldAccent.withValues(alpha: 0.35),
          colors.goldAccent.withValues(alpha: 0),
        ]),
    );

    // Soft green ground around the water.
    canvas.drawOval(
      Rect.fromCenter(center: c.translate(0, s * 0.008), width: s * 0.20, height: s * 0.115),
      Paint()..color = const Color(0xFF8FAF6C).withValues(alpha: 0.8),
    );

    // The pond, rimmed with wet sand.
    final pond = Rect.fromCenter(
      center: c.translate(0, s * 0.012),
      width: s * 0.145,
      height: s * 0.078,
    );
    canvas.drawOval(pond.inflate(s * 0.006), Paint()..color = const Color(0xFFCBB284));
    canvas.drawOval(
      pond,
      Paint()
        ..shader = ui.Gradient.linear(pond.topCenter, pond.bottomCenter, [
          const Color(0xFF9FD4CD),
          const Color(0xFF4E93A8),
        ]),
    );
    // A wavering highlight on the water.
    canvas.drawPath(
      Path()
        ..moveTo(pond.left + pond.width * 0.22, pond.center.dy)
        ..quadraticBezierTo(
          pond.center.dx,
          pond.center.dy - pond.height * 0.28,
          pond.right - pond.width * 0.22,
          pond.center.dy - pond.height * 0.06,
        ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = s * 0.006
        ..color = Colors.white.withValues(alpha: 0.65),
    );

    // Palms leaning over the water.
    _paintPalm(canvas, c.translate(-s * 0.070, -s * 0.008), s * 0.052);
    _paintPalm(canvas, c.translate(s * 0.062, -s * 0.016), s * 0.062);
    _paintPalm(canvas, c.translate(s * 0.012, -s * 0.030), s * 0.040);

    // The brand's star, small and golden at the water's edge.
    canvas.drawPath(
      eightPointStar(c.translate(-s * 0.012, s * 0.036), s * 0.013),
      Paint()..color = colors.goldAccent,
    );
  }

  // -------------------------------------------------------------------
  // Terrain crossing OVER the trail: two dune shoulders and a palm
  // cluster that occlude short quiet stretches of the route. This is
  // what breaks the "shape drawn on top of the ground" reading.
  // -------------------------------------------------------------------

  void _paintOccluders(Canvas canvas, Size size) {
    final s = size.shortestSide;

    int quietIndex(int from) {
      for (var k = from; k < from + circuit.trackLength; k++) {
        if (circuit.effectAt(k % circuit.trackLength) == CellEffect.plain &&
            circuit.effectAt((k + 1) % circuit.trackLength) == CellEffect.plain) {
          return k % circuit.trackLength;
        }
      }
      return from % circuit.trackLength;
    }

    void mound(Offset p, double r, double tiltSeed) {
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(math.sin(tiltSeed) * 0.3);
      final body = Rect.fromCenter(center: Offset.zero, width: r * 2.4, height: r * 1.1);
      canvas.drawOval(
        body.translate(0, r * 0.10),
        Paint()..color = const Color(0xFF8A6F45).withValues(alpha: 0.30),
      );
      canvas.drawOval(
        body,
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, -r * 0.55), Offset(0, r * 0.55), [
            const Color(0xFFEFD6A4),
            const Color(0xFFC9A671),
          ]),
      );
      canvas.drawPath(
        Path()
          ..moveTo(-r * 0.9, -r * 0.18)
          ..quadraticBezierTo(0, -r * 0.62, r * 0.9, -r * 0.10),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = r * 0.10
          ..color = Colors.white.withValues(alpha: 0.35),
      );
      canvas.restore();
    }

    final a = quietIndex((circuit.trackLength * 0.38).round());
    final b = quietIndex((circuit.trackLength * 0.815).round());
    final pa = Offset.lerp(layout.trackPoint(a), layout.trackPoint(a + 1), 0.5)!;
    final pb = Offset.lerp(layout.trackPoint(b), layout.trackPoint(b + 1), 0.5)!;
    mound(pa, s * 0.052, 1.3);
    mound(pb, s * 0.058, 4.1);
    // Palms rising over the trail edge by the second mound.
    _paintPalm(canvas, pb.translate(s * 0.028, -s * 0.012), s * 0.055);
    _paintPalm(canvas, pb.translate(-s * 0.030, s * 0.004), s * 0.042);
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) => true;
}

class _HorseMarker extends StatefulWidget {
  const _HorseMarker({
    super.key,
    required this.layout,
    required this.circuit,
    required this.billboardAngle,
    required this.playerIndex,
    required this.horseIndex,
    required this.team,
    required this.horse,
    required this.selectable,
    this.onTap,
  });

  final BoardLayout layout;
  final Circuit circuit;
  final double billboardAngle;
  final int playerIndex;
  final int horseIndex;
  final AppTeam team;
  final HorseState horse;
  final bool selectable;
  final VoidCallback? onTap;

  @override
  State<_HorseMarker> createState() => _HorseMarkerState();
}

/// Moves square by square with a small hop per square — the Monopoly-GO
/// discipline: a move is a journey you watch, not a teleport. Kept brisk
/// (capped under a second) and skipped entirely under Reduce Motion.
class _HorseMarkerState extends State<_HorseMarker> with SingleTickerProviderStateMixin {
  late final AnimationController _move = AnimationController(vsync: this, value: 1);

  List<Offset> _waypoints = const [];

  Offset _pointOf(PawnPosition pos) => pos is HomePosition
      ? widget.layout.homeSlot(widget.playerIndex, widget.horseIndex)
      : widget.layout.pointFor(widget.playerIndex, pos);

  @override
  void didUpdateWidget(covariant _HorseMarker old) {
    super.didUpdateWidget(old);
    if (old.horse.position != widget.horse.position) {
      _startMove(from: old.horse.position, to: widget.horse.position);
    }
  }

  void _startMove({required PawnPosition from, required PawnPosition to}) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final circuit = widget.circuit;
    final team = widget.playerIndex;
    final p0 = circuit.progressOf(from, team);
    final p1 = circuit.progressOf(to, team);

    if (!reduceMotion && p1 != null && (p0 ?? -1) < p1) {
      // Forward along the journey: visit every square in between.
      _waypoints = [
        _pointOf(from),
        for (var p = (p0 ?? -1) + 1; p <= p1; p++) _pointOf(circuit.positionAt(p, team)),
      ];
    } else {
      // A capture sending the horse home (one calm glide, spec: never a
      // violent capture), or Reduce Motion.
      _waypoints = [_pointOf(from), _pointOf(to)];
    }

    final hops = _waypoints.length - 1;
    if (reduceMotion || hops <= 0) {
      _move.value = 1;
      setState(() {});
      return;
    }
    final ms = (AppMotion.hopPerCell.inMilliseconds * hops).clamp(
      AppMotion.micro.inMilliseconds,
      AppMotion.moveMax.inMilliseconds,
    );
    _move.duration = Duration(milliseconds: ms);
    _move.forward(from: 0);
  }

  /// Where the token is right now, plus 0..1 "in the air" lift.
  (Offset, double) _sample() {
    if (_move.isAnimating && _waypoints.length >= 2) {
      final hops = _waypoints.length - 1;
      final s = _move.value * hops;
      final i = s.floor().clamp(0, hops - 1);
      final frac = (s - i).clamp(0.0, 1.0);
      final eased = Curves.easeInOut.transform(frac);
      final base = Offset.lerp(_waypoints[i], _waypoints[i + 1], eased)!;
      return (base, math.sin(frac * math.pi));
    }
    return (_pointOf(widget.horse.position), 0);
  }

  @override
  void dispose() {
    _move.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tokenSize = widget.layout.size.shortestSide * 0.088;

    return AnimatedBuilder(
      animation: _move,
      builder: (context, child) {
        final (center, lift) = _sample();
        return Positioned(
          left: center.dx - tokenSize / 2,
          top: center.dy - tokenSize - lift * tokenSize * 0.28,
          child: Transform(
            // Stand upright on the tilted ground, feet at the square.
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..rotateX(-widget.billboardAngle)
              ..scaleByDouble(1 + lift * 0.05, 1 + lift * 0.05, 1, 1),
            child: child,
          ),
        );
      },
      child: Semantics(
        label:
            '${widget.team.name} horse ${widget.horseIndex + 1}'
            '${widget.horse.hasShield ? ', shielded' : ''}, '
            '${widget.selectable ? 'selectable' : 'not selectable'}',
        button: widget.selectable,
        child: GestureDetector(
          onTap: widget.selectable ? widget.onTap : null,
          child: AnimatedContainer(
            duration: AppMotion.micro,
            width: tokenSize,
            height: tokenSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: widget.selectable
                  ? [
                      BoxShadow(
                        color: widget.team.color(colors).withValues(alpha: 0.55),
                        blurRadius: tokenSize * 0.4,
                        spreadRadius: tokenSize * 0.08,
                      ),
                    ]
                  : const [],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: tokenSize * 0.12,
                  right: tokenSize * 0.12,
                  bottom: -tokenSize * 0.02,
                  child: Container(
                    height: tokenSize * 0.14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: RadialGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                HorseToken(
                  coat: widget.team.coat,
                  team: widget.team,
                  size: tokenSize,
                  color: widget.team.color(colors),
                ),
                // A knowledge shield is drawn as a ring around the horse,
                // so protection is visible on the board itself.
                if (widget.horse.hasShield)
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

/// A wooden chest with gold banding and a soft glow — the trail's most
/// desirable landmark, shared between the board and the chest-offer
/// sheet so the reward moment shows the exact object the player rode to.
void paintChestLandmark(Canvas canvas, Offset p, double w) {
  final h = w * 0.78;
  canvas.drawCircle(
    p,
    w * 0.95,
    Paint()
      ..shader = ui.Gradient.radial(p, w * 0.95, [
        const Color(0x66FFD873),
        const Color(0x00FFD873),
      ]),
  );
  canvas.drawOval(
    Rect.fromCenter(center: p.translate(0, h * 0.42), width: w * 1.15, height: h * 0.30),
    Paint()..color = const Color(0xFF6B4F2E).withValues(alpha: 0.35),
  );
  final body = RRect.fromRectAndRadius(
    Rect.fromCenter(center: p.translate(0, h * 0.12), width: w, height: h * 0.62),
    Radius.circular(w * 0.10),
  );
  canvas.drawRRect(
    body,
    Paint()
      ..shader = ui.Gradient.linear(Offset(p.dx, p.dy - h * 0.2), Offset(p.dx, p.dy + h * 0.45), [
        const Color(0xFF9A6636),
        const Color(0xFF6E4522),
      ]),
  );
  // Domed lid.
  final lid = Path()
    ..moveTo(p.dx - w / 2, p.dy - h * 0.18)
    ..quadraticBezierTo(p.dx, p.dy - h * 0.62, p.dx + w / 2, p.dy - h * 0.18)
    ..close();
  canvas.drawPath(
    lid,
    Paint()
      ..shader = ui.Gradient.linear(Offset(p.dx, p.dy - h * 0.62), Offset(p.dx, p.dy - h * 0.14), [
        const Color(0xFFB07A42),
        const Color(0xFF7E5128),
      ]),
  );
  final band = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w * 0.085
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFFE3B354);
  canvas.drawLine(p.translate(0, -h * 0.52), p.translate(0, h * 0.40), band);
  canvas.drawRRect(
    body,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..color = const Color(0xFFE3B354).withValues(alpha: 0.8),
  );
  canvas.drawCircle(p.translate(0, h * 0.02), w * 0.11, Paint()..color = const Color(0xFFF3D68A));
}
