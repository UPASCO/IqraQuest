import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_team.dart';
import '../../theme/app_theme.dart';
import '../horse_painter.dart';
import '../landmarks/hijaz_landmark_painter.dart';
import 'board_layout.dart';

/// The full game board: shared track, 4 stables, 4 final lanes, and the
/// narrative Makkah→Madinah zone backdrop (spec §14). Purely presentational
/// — reads a [GameState] and renders it; all game logic stays in
/// [GameEngine].
class BoardWidget extends StatelessWidget {
  const BoardWidget({
    super.key,
    required this.state,
    this.selectablePawns = const {},
    this.onPawnTap,
  });

  final GameState state;

  /// Set of "playerId:pawnIndex" keys currently offered as legal moves —
  /// used to highlight only movable pawns (spec §42).
  final Set<String> selectablePawns;
  final void Function(int playerIndex, int pawnIndex)? onPawnTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        final size = Size(side, side);
        final layout = BoardLayout(size);
        return SizedBox.fromSize(
          size: size,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _BoardPainter(layout: layout, colors: colors),
                ),
              ),
              for (final entry in _pawnEntries())
                _PawnMarker(
                  layout: layout,
                  playerIndex: entry.$1,
                  pawnIndex: entry.$2,
                  team: state.players[entry.$1].team,
                  position: state.players[entry.$1].pawns[entry.$2],
                  selectable: selectablePawns.contains('${state.players[entry.$1].id}:${entry.$2}'),
                  onTap: onPawnTap == null ? null : () => onPawnTap!(entry.$1, entry.$2),
                ),
            ],
          ),
        );
      },
    );
  }

  List<(int, int)> _pawnEntries() {
    final entries = <(int, int)>[];
    for (var p = 0; p < state.players.length; p++) {
      for (var i = 0; i < state.players[p].pawns.length; i++) {
        entries.add((p, i));
      }
    }
    return entries;
  }
}

class _BoardPainter extends CustomPainter {
  const _BoardPainter({required this.layout, required this.colors});

  final BoardLayout layout;
  final AppSemanticColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    // Zone wash: Makkah (warm stone) → desert → mountains → oasis →
    // Madinah (green), left to right — a narrative gradient, not a claim
    // of geographic accuracy (spec §15).
    final zoneRect = Offset.zero & size;
    canvas.drawRect(
      zoneRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFEBD9B8),
            Color(0xFFE3C99B),
            Color(0xFFCBB48C),
            Color(0xFFB9C79E),
            Color(0xFF9DBE8C),
          ],
        ).createShader(zoneRect),
    );

    // Quiet corner landmarks (never on the track itself).
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * 0.22, size.height * 0.22));
    HijazLandmarkPainter(
      scene: LandmarkScene.makkahValley,
      skyTop: const Color(0x00000000),
      skyBottom: const Color(0x00000000),
      landPrimary: const Color(0xFFCBB48C),
      landShade: const Color(0xFFAE9670),
    ).paint(canvas, Size(size.width * 0.22, size.height * 0.22));
    canvas.restore();

    canvas.save();
    canvas.translate(size.width * 0.78, size.height * 0.78);
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * 0.22, size.height * 0.22));
    HijazLandmarkPainter(
      scene: LandmarkScene.madinahOasis,
      skyTop: const Color(0x00000000),
      skyBottom: const Color(0x00000000),
      landPrimary: const Color(0xFF9DBE8C),
      landShade: const Color(0xFF7FA173),
    ).paint(canvas, Size(size.width * 0.22, size.height * 0.22));
    canvas.restore();

    _paintFinalLanes(canvas);
    _paintTrack(canvas);
    _paintStables(canvas, size);
    _paintFinishEmblem(canvas);
  }

  void _paintTrack(Canvas canvas) {
    final squareSize = layout.size.shortestSide * 0.052;
    for (var i = 0; i < BoardGeometry.trackLength; i++) {
      final p = layout.trackPoint(i);
      final protected = BoardGeometry.protectedSquares.contains(i);
      final rect = Rect.fromCenter(center: p, width: squareSize, height: squareSize);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(squareSize * 0.25)),
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
      if (protected) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(squareSize * 0.25)),
          Paint()
            ..color = colors.protectedSquare
            ..style = PaintingStyle.stroke
            ..strokeWidth = squareSize * 0.12,
        );
      }
    }
  }

  void _paintFinalLanes(Canvas canvas) {
    final teamColors = [colors.player1, colors.player2, colors.player3, colors.player4];
    for (var t = 0; t < 4; t++) {
      final paint = Paint()
        ..color = teamColors[t].withValues(alpha: 0.55)
        ..strokeWidth = layout.size.shortestSide * 0.03
        ..strokeCap = StrokeCap.round;
      for (var step = 1; step < BoardGeometry.finalLaneLength; step++) {
        canvas.drawLine(layout.finalLanePoint(t, step), layout.finalLanePoint(t, step + 1), paint);
      }
    }
  }

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
      final rect = Rect.fromCenter(center: positions[t], width: stableSize, height: stableSize);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(stableSize * 0.2)),
        Paint()..color = teamColors[t].withValues(alpha: 0.16),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(stableSize * 0.2)),
        Paint()
          ..color = teamColors[t].withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }

  void _paintFinishEmblem(Canvas canvas) {
    canvas.drawCircle(
      layout.center,
      layout.size.shortestSide * 0.05,
      Paint()..color = colors.goldAccent.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) => true;
}

class _PawnMarker extends StatelessWidget {
  const _PawnMarker({
    required this.layout,
    required this.playerIndex,
    required this.pawnIndex,
    required this.team,
    required this.position,
    required this.selectable,
    this.onTap,
  });

  final BoardLayout layout;
  final int playerIndex;
  final int pawnIndex;
  final AppTeam team;
  final PawnPosition position;
  final bool selectable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final center = position is HomePosition
        ? layout.homeSlot(playerIndex, pawnIndex)
        : layout.pointFor(playerIndex, position);
    final tokenSize = layout.size.shortestSide * 0.075;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      left: center.dx - tokenSize / 2,
      top: center.dy - tokenSize / 2,
      child: Semantics(
        label:
            '${team.name} horse ${pawnIndex + 1}, '
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
            child: HorseToken(
              coat: team.coat,
              team: team,
              size: tokenSize,
              color: team.color(colors),
            ),
          ),
        ),
      ),
    );
  }
}
