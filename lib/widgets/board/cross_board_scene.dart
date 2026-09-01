import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../theme/app_team.dart';
import '../../theme/app_theme.dart';
import 'cross_anchors.g.dart';

/// The classic cross board of the *jeu des petits chevaux*, set among the
/// four holy places with Mecca at the centre.
///
/// The plate and the anchor table come from one grid
/// (`tool/art/bake_cross_board.py`), so a square index can never address
/// a tile the art does not have. That is the whole reason this replaced
/// the previous plate, which had 24 painted tiles under a 56-square
/// circuit and drew two different squares on the same tile.
class CrossBoardScene extends StatelessWidget {
  const CrossBoardScene({
    super.key,
    required this.state,
    this.preview,
    this.selectableHorses = const {},
    this.onHorseTap,
  });

  final GameState state;

  /// Where the drawn card sends the moving horse, so the ride is shown
  /// before it happens.
  final ({int teamIndex, PawnPosition destination})? preview;

  final Set<String> selectableHorses;
  final void Function(int playerIndex, int horseIndex)? onHorseTap;

  static SceneAnchor _anchorFor(PawnPosition position, int team, int horseIndex) =>
      switch (position) {
        HomePosition() => crossCampAnchors[team]![horseIndex % 4],
        TrackPosition(:final index) => crossTrackAnchors[index % crossTrackAnchors.length],
        FinalLanePosition(:final step) => crossLaneAnchors[team]![(step - 1).clamp(
          0,
          crossLaneAnchors[team]!.length - 1,
        )],
        FinishedPosition() => crossCenterAnchor,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        // The plate is square; it is laid out centred and contained so
        // no square is ever cropped off the edge of a phone.
        final side = constraints.biggest.shortestSide;
        final left = (constraints.maxWidth - side) / 2;
        final top = (constraints.maxHeight - side) / 2;
        Offset toScreen(SceneAnchor a) => Offset(left + a.x * side, top + a.y * side);
        final pieceSize = side * 0.052;

        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: side,
              height: side,
              child: Image.asset(
                'assets/board/cross_board.webp',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),

            if (preview != null)
              Positioned(
                left: toScreen(
                      _anchorFor(preview!.destination, preview!.teamIndex, 0),
                    ).dx -
                    pieceSize * 0.72,
                top: toScreen(
                      _anchorFor(preview!.destination, preview!.teamIndex, 0),
                    ).dy -
                    pieceSize * 0.72,
                width: pieceSize * 1.44,
                height: pieceSize * 1.44,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.goldAccent, width: 3),
                      color: colors.goldAccent.withValues(alpha: 0.22),
                    ),
                  ),
                ),
              ),

            // The place each corner stands for, named in the reader's
            // own language rather than baked into the plate.
            for (var t = 0; t < 4; t++)
              _cornerLabel(context, t, toScreen, side),

            for (var pi = 0; pi < state.players.length; pi++)
              for (var hi = 0; hi < state.players[pi].horses.length; hi++)
                _piece(context, pi, hi, toScreen, pieceSize),
          ],
        );
      },
    );
  }

  Widget _cornerLabel(
    BuildContext context,
    int teamIndex,
    Offset Function(SceneAnchor) toScreen,
    double side,
  ) {
    final l10n = AppLocalizations.of(context);
    // A corner names its place whether or not anyone is sitting there,
    // so this reads the seat order, never the players list.
    final place = kBoardSeats[teamIndex].place;
    final name = switch (place) {
      HolyPlace.medina => l10n.placeMedina,
      HolyPlace.alAqsa => l10n.placeAlAqsa,
      HolyPlace.arafat => l10n.placeArafat,
      HolyPlace.mina => l10n.placeMina,
    };
    final medallion = crossCornerAnchors[teamIndex]!;
    // Away from the middle of the board: the name sits on the coloured
    // panel outside the illustration, never over a dark sky where it
    // could not be read.
    final outX = medallion.x < 0.5 ? -1.0 : 1.0;
    final outY = medallion.y < 0.5 ? -1.0 : 1.0;
    final at = toScreen(
      SceneAnchor(medallion.x + outX * 0.052, medallion.y + outY * 0.086),
    );
    final width = side * 0.19;

    return Positioned(
      left: at.dx - width / 2,
      top: at.dy - side * 0.020,
      width: width,
      child: IgnorePointer(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: side * 0.012,
            vertical: side * 0.006,
          ),
          decoration: BoxDecoration(
            color: const Color(0xF2F6F0DF),
            borderRadius: BorderRadius.circular(side * 0.016),
            border: Border.all(color: const Color(0xB3C69E4A), width: 1.2),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                color: const Color(0xFF3A2F1E),
                fontWeight: FontWeight.w700,
                fontSize: side * 0.028,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _piece(
    BuildContext context,
    int playerIndex,
    int horseIndex,
    Offset Function(SceneAnchor) toScreen,
    double pieceSize,
  ) {
    final player = state.players[playerIndex];
    final team = player.team;
    final anchor = _anchorFor(player.horses[horseIndex].position, playerIndex, horseIndex);
    final at = toScreen(anchor);
    final selectable = selectableHorses.contains('${player.id}:$horseIndex');
    final color = team.color(context.colors);

    return Positioned(
      left: at.dx - pieceSize / 2,
      top: at.dy - pieceSize * 0.86,
      width: pieceSize,
      height: pieceSize * 1.4,
      child: Semantics(
        button: onHorseTap != null,
        label: '${player.name} — ${horseIndex + 1}',
        child: GestureDetector(
          onTap: onHorseTap == null ? null : () => onHorseTap!(playerIndex, horseIndex),
          child: CustomPaint(
            painter: _KnightPainter(
              color: color,
              rimmed: selectable,
              gold: context.colors.goldAccent,
            ),
          ),
        ),
      ),
    );
  }
}

/// A knight in the team's colour, in the silhouette the reference board
/// uses for its pieces: a turned base under a horse's head.
class _KnightPainter extends CustomPainter {
  const _KnightPainter({required this.color, required this.rimmed, required this.gold});

  final Color color;
  final bool rimmed;
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = Paint()..color = color;
    final shade = Paint()..color = Color.lerp(color, Colors.black, 0.32)!;
    final light = Paint()..color = Color.lerp(color, Colors.white, 0.30)!;

    // base
    final baseRect = Rect.fromLTWH(w * 0.14, h * 0.74, w * 0.72, h * 0.20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, Radius.circular(w * 0.10)),
      shade,
    );
    canvas.drawOval(Rect.fromLTWH(w * 0.10, h * 0.70, w * 0.80, h * 0.14), body);

    // neck and head
    final head = Path()
      ..moveTo(w * 0.34, h * 0.74)
      ..lineTo(w * 0.30, h * 0.36)
      ..quadraticBezierTo(w * 0.30, h * 0.12, w * 0.56, h * 0.10)
      ..quadraticBezierTo(w * 0.86, h * 0.12, w * 0.80, h * 0.34)
      ..lineTo(w * 0.60, h * 0.42)
      ..lineTo(w * 0.66, h * 0.74)
      ..close();
    canvas.drawPath(head, body);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.56, h * 0.12)
        ..quadraticBezierTo(w * 0.84, h * 0.14, w * 0.78, h * 0.34)
        ..lineTo(w * 0.62, h * 0.40)
        ..close(),
      light,
    );

    if (rimmed) {
      canvas.drawOval(
        Rect.fromLTWH(w * 0.06, h * 0.66, w * 0.88, h * 0.22),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.07
          ..color = gold,
      );
    }
  }

  @override
  bool shouldRepaint(_KnightPainter old) =>
      old.color != color || old.rimmed != rimmed || old.gold != gold;
}
