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
        final pieceSize = side * 0.072;

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
                key: const ValueKey('preview'),
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
      key: ValueKey('corner-$teamIndex'),
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

    // The ride is the one thing a child must be able to watch: a piece
    // that jumps from square to square is a teleport, and a teleport
    // is exactly what made the moves "unclear". Keyed per horse so
    // Flutter animates this piece, not whichever child now sits at
    // its index once the preview ring comes and goes.
    return AnimatedPositioned(
      key: ValueKey('${player.id}:$horseIndex'),
      duration: AppMotion.of(context, AppMotion.moveMax),
      curve: Curves.easeInOutCubic,
      left: at.dx - pieceSize / 2,
      top: at.dy - pieceSize * 1.15,
      width: pieceSize,
      height: pieceSize * 1.4,
      child: Semantics(
        button: onHorseTap != null,
        label: '${player.name} — ${horseIndex + 1}',
        child: GestureDetector(
          onTap: onHorseTap == null ? null : () => onHorseTap!(playerIndex, horseIndex),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (selectable)
                CustomPaint(painter: _SelectRingPainter(context.colors.goldAccent)),
              Image.asset(
                'assets/board/horses/horse_${team.name}.webp',
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The gold ring under a horse the player may pick this turn. The knight
/// itself is the baked sprite from the board pack, one per team.
class _SelectRingPainter extends CustomPainter {
  const _SelectRingPainter(this.gold);

  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Rect.fromLTWH(w * 0.02, h * 0.70, w * 0.96, h * 0.26);
    canvas.drawOval(
      rect,
      Paint()
        ..color = gold.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.08
        ..color = gold,
    );
  }

  @override
  bool shouldRepaint(_SelectRingPainter old) => old.gold != gold;
}
