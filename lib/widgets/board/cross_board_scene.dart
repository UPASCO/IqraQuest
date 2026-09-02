import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/models.dart';
import '../../theme/app_team.dart';
import '../../theme/app_theme.dart';
import 'bonus_tile_painter.dart';
import 'cross_anchors.g.dart';

/// One thing the won squares can do on the board: which horse, where it
/// would land, and what the board should say about it.
@immutable
class PlacementOption {
  const PlacementOption({
    required this.horseIndex,
    required this.destination,
    this.exitsStable = false,
    this.bonusValue,
    this.capturesOpponent = false,
    this.reachesFinish = false,
    this.tag,
  });

  final int horseIndex;
  final PawnPosition destination;
  final bool exitsStable;
  final int? bonusValue;
  final bool capturesOpponent;
  final bool reachesFinish;

  /// A short localized note shown at the destination ("Bonus +10",
  /// "Capture", "Arrivée"), or null for a plain square.
  final String? tag;
}

/// The placement turn as the board sees it: the current team and every
/// horse that may be picked up, with its destination.
@immutable
class BoardPlacement {
  const BoardPlacement({required this.teamIndex, required this.options});

  final int teamIndex;
  final List<PlacementOption> options;

  PlacementOption? optionFor(int horseIndex) {
    for (final o in options) {
      if (o.horseIndex == horseIndex) return o;
    }
    return null;
  }
}

/// The classic cross board of the *jeu des petits chevaux*, set among the
/// four holy places with Mecca at the centre.
///
/// The plate and the anchor table come from one grid
/// (`tool/art/bake_cross_board.py`), so a square index can never address
/// a tile the art does not have. The sixteen bonus medallions of the
/// game are inlaid on it from the state's own layout.
///
/// Every piece on it is a [_Piece] that *rides*: a move of n squares is n
/// hops along the actual track, a horse leaving the stable leaps onto
/// its start square, and a captured horse flies home once the rider that
/// caught it has landed. A piece that teleported across the plate was
/// the single most-reported confusion of the first playtests — a child
/// cannot follow what they did not see.
///
/// During a [placement] the board is the control: the horses that can
/// ride wear a breathing halo; touching one lights its destination and
/// the squares between; picking it up and setting it down on that square
/// *is* the move — the scene reports the drop through [onHorseDropped]
/// and the game validates it, with no button and no second tap. A horse
/// dropped anywhere else glides back where it was.
class CrossBoardScene extends StatefulWidget {
  const CrossBoardScene({
    super.key,
    required this.state,
    this.placement,
    this.onHorseSelected,
    this.onDragStarted,
    this.onHorseDropped,
    this.onBadDrop,
  });

  final GameState state;

  /// Non-null while the current player is choosing which horse rides.
  final BoardPlacement? placement;

  /// A horse was touched (or picked up): its destination is now shown.
  /// Null when the selection is cleared.
  final ValueChanged<int?>? onHorseSelected;

  /// A horse left the plate under the finger.
  final ValueChanged<int>? onDragStarted;

  /// A horse was set down on its destination. Returns whether the game
  /// accepted the move; a refused drop glides back like a bad one.
  final bool Function(int horseIndex)? onHorseDropped;

  /// A horse was dropped off its destination and is gliding back.
  final ValueChanged<int>? onBadDrop;

  /// The normalized plate coordinate of a logical position.
  static SceneAnchor anchorFor(
    PawnPosition position,
    int team,
    int horseIndex,
  ) => switch (position) {
    HomePosition() => crossCampAnchors[team]![horseIndex % 4],
    TrackPosition(:final index) =>
      crossTrackAnchors[index % crossTrackAnchors.length],
    FinalLanePosition(:final step) =>
      crossLaneAnchors[team]![(step - 1).clamp(
        0,
        crossLaneAnchors[team]!.length - 1,
      )],
    FinishedPosition() => crossCenterAnchor,
  };

  /// How far a horse may be set down from its square and still count
  /// as on it, in piece sizes. Generous: the finger hides the tile.
  static const double dropRadius = 0.95;

  /// Within this distance the square pulls the horse in, in piece sizes.
  static const double magnetRadius = 1.4;

  @override
  State<CrossBoardScene> createState() => _CrossBoardSceneState();
}

class _CrossBoardSceneState extends State<CrossBoardScene>
    with TickerProviderStateMixin {
  /// Pieces in the middle of a ride: painted last, so a rider crosses
  /// *over* the horses it passes rather than under them.
  final Set<String> _riding = {};
  Timer? _ridingTimer;

  /// Puffs of dust where hooves just landed, by id.
  final List<_Puff> _puffs = [];
  int _puffSeq = 0;

  /// The placement in progress: the horse whose destination is shown,
  /// the one under the finger, and where the finger is (plate-local).
  int? _selected;
  int? _dragHorse;
  Offset? _dragPiece;
  bool _dragHover = false;

  /// A horse gliding to a square after a drop: which, and from where.
  ({String key, Offset from})? _snap;
  Timer? _snapTimer;

  /// The horse just set down on its destination: its position change
  /// is not a ride to animate — it is already there.
  ({String key, PawnPosition at})? _dropped;

  /// The breathing of halos and markers, running only while something
  /// on the plate breathes.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  /// The light sweeping across the +20 stars, slow and rare.
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTickers();
  }

  @override
  void didUpdateWidget(CrossBoardScene old) {
    super.didUpdateWidget(old);
    final moved = <String>{};
    for (
      var p = 0;
      p < widget.state.players.length && p < old.state.players.length;
      p++
    ) {
      final now = widget.state.players[p];
      final before = old.state.players[p];
      for (var h = 0; h < now.horses.length && h < before.horses.length; h++) {
        if (now.horses[h].position != before.horses[h].position) {
          moved.add('${now.id}:$h');
        }
      }
    }
    if (moved.isNotEmpty) {
      _riding
        ..clear()
        ..addAll(moved);
      _ridingTimer?.cancel();
      _ridingTimer = Timer(const Duration(milliseconds: 2400), () {
        if (mounted) setState(_riding.clear);
      });
    }
    // The placement ended (the drop was accepted, the phase changed, the
    // game was left): nothing stays lit or held.
    if (widget.placement == null && old.placement != null) {
      _selected = null;
      _dragHorse = null;
      _dragPiece = null;
      _dragHover = false;
    } else if (widget.placement != null &&
        !identical(widget.placement, old.placement) &&
        _selected != null &&
        widget.placement!.optionFor(_selected!) == null) {
      _selected = null;
    }
    if (widget.placement != null && old.placement == null) {
      _dropped = null;
    }
    _syncTickers();
  }

  void _syncTickers() {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final breathing =
        !reduce &&
        (widget.placement != null || widget.state.pendingBonus != null);
    if (breathing && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!breathing && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
    final hasBig = widget.state.bonusTiles.any((t) => t.value >= 20);
    if (hasBig && !reduce && !_shimmer.isAnimating) {
      _shimmer.repeat();
    } else if ((!hasBig || reduce) && _shimmer.isAnimating) {
      _shimmer.stop();
    }
  }

  @override
  void dispose() {
    _ridingTimer?.cancel();
    _snapTimer?.cancel();
    _pulse.dispose();
    _shimmer.dispose();
    for (final p in _puffs) {
      p.timer.cancel();
    }
    super.dispose();
  }

  void _puffAt(Offset at, double size) {
    // Landings are reported from inside a piece's build; the puff is
    // added once this frame is done, never mid-build.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final id = _puffSeq++;
      late final _Puff puff;
      puff = _Puff(
        id: id,
        at: at,
        size: size,
        timer: Timer(const Duration(milliseconds: 650), () {
          if (mounted) setState(() => _puffs.remove(puff));
        }),
      );
      setState(() => _puffs.add(puff));
    });
  }

  // ---- Placement gestures ---------------------------------------------

  Offset _toLocal(Offset global) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return global;
    return box.globalToLocal(global);
  }

  void _onPieceTap(int horseIndex) {
    final placement = widget.placement;
    if (placement == null || placement.optionFor(horseIndex) == null) return;
    if (_selected == horseIndex) return;
    setState(() => _selected = horseIndex);
    widget.onHorseSelected?.call(horseIndex);
  }

  void _onDragStart(int horseIndex, Offset global, double pieceSize) {
    final placement = widget.placement;
    if (placement == null || placement.optionFor(horseIndex) == null) return;
    final changed = _selected != horseIndex;
    setState(() {
      _selected = horseIndex;
      _dragHorse = horseIndex;
      _dragPiece = _piecePointFor(_toLocal(global), pieceSize, horseIndex);
    });
    if (changed) widget.onHorseSelected?.call(horseIndex);
    widget.onDragStarted?.call(horseIndex);
  }

  void _onDragUpdate(int horseIndex, Offset global, double pieceSize) {
    if (_dragHorse != horseIndex) return;
    setState(() {
      _dragPiece = _piecePointFor(_toLocal(global), pieceSize, horseIndex);
    });
  }

  /// Where the horse under the finger is drawn: a little above the
  /// fingertip, so the thumb never hides it, and pulled onto its square
  /// once within reach of it.
  Offset _piecePointFor(Offset finger, double pieceSize, int horseIndex) {
    var point = finger - Offset(0, pieceSize * 0.95);
    final target = _destinationPoint(horseIndex);
    if (target != null) {
      final d = (point - target).distance;
      final magnet = pieceSize * CrossBoardScene.magnetRadius;
      final hover = d < magnet;
      if (hover) {
        final pull = 1 - (d / magnet);
        point = Offset.lerp(point, target, 0.45 + 0.45 * pull)!;
      }
      _dragHover = hover;
    }
    return point;
  }

  Offset? _destinationPoint(int horseIndex) {
    final placement = widget.placement;
    final option = placement?.optionFor(horseIndex);
    if (placement == null || option == null || _layout == null) return null;
    return _layout!.toScreen(
      CrossBoardScene.anchorFor(
        option.destination,
        placement.teamIndex,
        horseIndex,
      ),
    );
  }

  void _onDragEnd(int horseIndex, double pieceSize, {bool cancelled = false}) {
    if (_dragHorse != horseIndex) return;
    final placement = widget.placement;
    final option = placement?.optionFor(horseIndex);
    final from = _dragPiece;
    final key = '${widget.state.players[placement?.teamIndex ?? 0].id}:$horseIndex';
    var accepted = false;
    if (!cancelled && option != null && from != null) {
      final target = _destinationPoint(horseIndex);
      final onSquare =
          target != null &&
          (from - target).distance <= pieceSize * CrossBoardScene.dropRadius;
      if (onSquare) {
        // Set optimistically so the position change that follows is
        // not animated as a ride: the horse is already on its square.
        _dropped = (key: key, at: option.destination);
        accepted = widget.onHorseDropped?.call(horseIndex) ?? false;
        if (!accepted) _dropped = null;
      }
    }
    setState(() {
      _dragHorse = null;
      _dragPiece = null;
      _dragHover = false;
      if (from != null) _snap = (key: key, from: from);
    });
    _snapTimer?.cancel();
    _snapTimer = Timer(const Duration(milliseconds: 420), () {
      if (mounted) setState(() => _snap = null);
    });
    if (!accepted && !cancelled) widget.onBadDrop?.call(horseIndex);
  }

  _PlateLayout? _layout;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = widget.state;
    final placement = widget.placement;

    return LayoutBuilder(
      builder: (context, constraints) {
        // The plate is square; it is laid out centred and contained so
        // no square is ever cropped off the edge of a phone.
        final side = constraints.biggest.shortestSide;
        final left = (constraints.maxWidth - side) / 2;
        final top = (constraints.maxHeight - side) / 2;
        final layout = _PlateLayout(left: left, top: top, side: side);
        _layout = layout;
        final toScreen = layout.toScreen;
        final pieceSize = side * 0.072;
        final tileDiameter = side * 0.056;

        // Paint order: higher on the plate first, so a horse standing
        // lower overlaps the base of the one behind it (the 2x2 stable
        // reads as a little herd, not a stack of discs); riders last,
        // the one under the finger above everything.
        final pieces = <({int p, int h, double y, int layer})>[];
        for (var pi = 0; pi < state.players.length; pi++) {
          final player = state.players[pi];
          for (var hi = 0; hi < player.horses.length; hi++) {
            final a = CrossBoardScene.anchorFor(
              player.horses[hi].position,
              pi,
              hi,
            );
            final dragging =
                placement != null &&
                placement.teamIndex == pi &&
                _dragHorse == hi;
            pieces.add((
              p: pi,
              h: hi,
              y: a.y,
              layer: dragging
                  ? 2
                  : _riding.contains('${player.id}:$hi')
                  ? 1
                  : 0,
            ));
          }
        }
        pieces.sort((a, b) {
          if (a.layer != b.layer) return a.layer.compareTo(b.layer);
          return a.y.compareTo(b.y);
        });

        final bonusTiles = <({Offset at, int value})>[
          for (final t in state.bonusTiles)
            (
              at: toScreen(
                crossTrackAnchors[t.trackIndex % crossTrackAnchors.length],
              ),
              value: t.value,
            ),
        ];
        final pending = state.pendingBonus;
        final selectedOption = placement != null && _selected != null
            ? placement.optionFor(_selected!)
            : null;

        return Stack(
          children: [
            // The table under the plate. A square board on a tall phone
            // leaves a band above and below it; dressed as cloth, halo
            // and cast shadow they read as the scene, not as leftover.
            Positioned.fill(
              child: CustomPaint(
                painter: _TableBackdropPainter(
                  plate: Rect.fromLTWH(left, top, side, side),
                ),
              ),
            ),
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

            // The sixteen bonus medallions, inlaid once per layout.
            if (bonusTiles.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: BonusLayerPainter(
                      tiles: bonusTiles,
                      diameter: tileDiameter,
                    ),
                  ),
                ),
              ),
            for (final t in state.bonusTiles)
              if (t.value >= 20)
                Positioned(
                  key: ValueKey('shimmer-${t.trackIndex}'),
                  left:
                      toScreen(crossTrackAnchors[t.trackIndex]).dx -
                      tileDiameter,
                  top:
                      toScreen(crossTrackAnchors[t.trackIndex]).dy -
                      tileDiameter,
                  width: tileDiameter * 2,
                  height: tileDiameter * 2,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _shimmer,
                      builder: (context, _) => CustomPaint(
                        painter: _ShimmerTilePainter(
                          value: t.value,
                          diameter: tileDiameter,
                          // A sweep, then a rest: the star flashes once
                          // every few seconds, not constantly.
                          shimmer: (_shimmer.value * 3).clamp(0.0, 1.0),
                        ),
                      ),
                    ),
                  ),
                ),
            for (final t in state.bonusTiles)
              Positioned(
                key: ValueKey('bonus-${t.trackIndex}'),
                left: toScreen(crossTrackAnchors[t.trackIndex]).dx - tileDiameter / 2,
                top: toScreen(crossTrackAnchors[t.trackIndex]).dy - tileDiameter / 2,
                width: tileDiameter,
                height: tileDiameter,
                child: Semantics(
                  label: AppLocalizations.of(context).bonusSquareSemantics(t.value),
                  child: const SizedBox.expand(),
                ),
              ),

            // The square a horse just stopped on, flaring before it
            // rides the bonus.
            if (pending != null)
              Positioned(
                key: const ValueKey('bonus-flare'),
                left: toScreen(crossTrackAnchors[pending.trackIndex]).dx - pieceSize * 1.6,
                top: toScreen(crossTrackAnchors[pending.trackIndex]).dy - pieceSize * 1.6,
                width: pieceSize * 3.2,
                height: pieceSize * 3.2,
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) => CustomPaint(
                      painter: _BonusFlarePainter(
                        pulse: _pulse.value,
                        big: pending.value >= 20,
                      ),
                    ),
                  ),
                ),
              ),

            // The place each corner stands for, named in the reader's
            // own language rather than baked into the plate.
            for (var t = 0; t < 4; t++)
              _cornerLabel(context, t, toScreen, side),

            // ---- Placement: halos, path and destination ----
            if (placement != null)
              for (final option in placement.options)
                if (_dragHorse != option.horseIndex)
                  _candidateHalo(placement, option, toScreen, pieceSize),
            if (placement != null && selectedOption != null) ...[
              _pathDots(placement, selectedOption, toScreen, pieceSize),
              _destinationMarker(
                placement,
                selectedOption,
                toScreen,
                pieceSize,
                colors,
              ),
            ],

            for (final puff in _puffs)
              Positioned(
                key: ValueKey('puff-${puff.id}'),
                left: puff.at.dx - puff.size,
                top: puff.at.dy - puff.size * 0.7,
                width: puff.size * 2,
                height: puff.size * 1.4,
                child: const IgnorePointer(child: _DustPuff()),
              ),

            for (final piece in pieces)
              _Piece(
                key: ValueKey('${state.players[piece.p].id}:${piece.h}'),
                playerIndex: piece.p,
                horseIndex: piece.h,
                player: state.players[piece.p],
                position: state.players[piece.p].horses[piece.h].position,
                circuit: state.circuit,
                layout: layout,
                pieceSize: pieceSize,
                interactive:
                    placement != null &&
                    placement.teamIndex == piece.p &&
                    placement.optionFor(piece.h) != null,
                selected:
                    placement != null &&
                    placement.teamIndex == piece.p &&
                    _selected == piece.h,
                dragAt:
                    placement != null &&
                        placement.teamIndex == piece.p &&
                        _dragHorse == piece.h
                    ? _dragPiece
                    : null,
                snapFrom:
                    _snap != null &&
                        _snap!.key == '${state.players[piece.p].id}:${piece.h}'
                    ? _snap!.from
                    : null,
                dropped:
                    _dropped != null &&
                    _dropped!.key == '${state.players[piece.p].id}:${piece.h}' &&
                    _dropped!.at ==
                        state.players[piece.p].horses[piece.h].position,
                onTap: () => _onPieceTap(piece.h),
                onDragStart: (g) => _onDragStart(piece.h, g, pieceSize),
                onDragUpdate: (g) => _onDragUpdate(piece.h, g, pieceSize),
                onDragEnd: () => _onDragEnd(piece.h, pieceSize),
                onDragCancel: () =>
                    _onDragEnd(piece.h, pieceSize, cancelled: true),
                onLanding: _puffAt,
              ),
          ],
        );
      },
    );
  }

  /// The breathing ring under a horse that could ride: it says "me?"
  /// without shouting. The selected one wears a steady, brighter ring.
  Widget _candidateHalo(
    BoardPlacement placement,
    PlacementOption option,
    Offset Function(SceneAnchor) toScreen,
    double pieceSize,
  ) {
    final team = placement.teamIndex;
    final position = widget.state.players[team].horses[option.horseIndex].position;
    final at = toScreen(
      CrossBoardScene.anchorFor(position, team, option.horseIndex),
    );
    final selected = _selected == option.horseIndex;
    final w = pieceSize * 1.5;
    return Positioned(
      key: ValueKey('halo-${option.horseIndex}'),
      left: at.dx - w / 2,
      top: at.dy - w * 0.32,
      width: w,
      height: w * 0.5,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) => CustomPaint(
            painter: _HaloPainter(
              pulse: _pulse.value,
              selected: selected,
            ),
          ),
        ),
      ),
    );
  }

  /// Small gold dots on the squares between the horse and its
  /// destination, so the ride is read before it is made.
  Widget _pathDots(
    BoardPlacement placement,
    PlacementOption option,
    Offset Function(SceneAnchor) toScreen,
    double pieceSize,
  ) {
    final team = placement.teamIndex;
    final circuit = widget.state.circuit;
    final from = widget.state.players[team].horses[option.horseIndex].position;
    final points = <Offset>[];
    final p0 = circuit.progressOf(from, team);
    final p1 = circuit.progressOf(option.destination, team);
    if (p0 != null && p1 != null && p1 > p0 && p1 - p0 <= 12) {
      for (var p = p0 + 1; p < p1; p++) {
        points.add(
          toScreen(
            CrossBoardScene.anchorFor(
              circuit.positionAt(p, team),
              team,
              option.horseIndex,
            ),
          ),
        );
      }
    }
    return Positioned.fill(
      key: const ValueKey('path'),
      child: IgnorePointer(
        child: CustomPaint(
          painter: _PathPainter(points: points, radius: pieceSize * 0.11),
        ),
      ),
    );
  }

  /// The destination: a lit ring with a rotating gold dash and, above
  /// it, what the square holds. Stronger while the horse hovers over it.
  Widget _destinationMarker(
    BoardPlacement placement,
    PlacementOption option,
    Offset Function(SceneAnchor) toScreen,
    double pieceSize,
    AppSemanticColors colors,
  ) {
    final at = toScreen(
      CrossBoardScene.anchorFor(
        option.destination,
        placement.teamIndex,
        option.horseIndex,
      ),
    );
    final hover = _dragHorse == option.horseIndex && _dragHover;
    final w = pieceSize * 2.4;
    final tag = option.tag;
    return Positioned(
      key: const ValueKey('destination'),
      left: at.dx - w / 2,
      top: at.dy - w / 2 - (tag == null ? 0 : pieceSize * 0.9),
      width: w,
      height: w + (tag == null ? 0 : pieceSize * 0.9),
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tag != null)
              Container(
                height: pieceSize * 0.9,
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: pieceSize * 0.22,
                    vertical: pieceSize * 0.08,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xF2102B22),
                    borderRadius: BorderRadius.circular(pieceSize),
                    border: Border.all(color: const Color(0xFFEED38A), width: 1),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      tag,
                      maxLines: 1,
                      style: TextStyle(
                        color: const Color(0xFFFFE9AE),
                        fontWeight: FontWeight.w800,
                        fontSize: pieceSize * 0.34,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(
              width: w,
              height: w,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) => CustomPaint(
                  painter: _DestinationPainter(
                    pulse: _pulse.value,
                    hover: hover,
                    finish: option.reachesFinish,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
}

/// Where the plate sits inside the scene, and the mapping from plate
/// coordinates to scene pixels.
@immutable
class _PlateLayout {
  const _PlateLayout({required this.left, required this.top, required this.side});

  final double left;
  final double top;
  final double side;

  Offset toScreen(SceneAnchor a) => Offset(left + a.x * side, top + a.y * side);
}

class _Puff {
  const _Puff({
    required this.id,
    required this.at,
    required this.size,
    required this.timer,
  });

  final int id;
  final Offset at;
  final double size;
  final Timer timer;
}

/// What kind of journey a piece is on, which decides how high it goes
/// and how long it takes.
enum _Ride {
  /// Square to square along the track: a hop per square.
  hops,

  /// Out of the stable onto the start square: one high leap.
  leap,

  /// Caught and sent home: one long arc back to the stable.
  flight,
}

/// One knight on the plate, animating itself from wherever it was to
/// wherever the game now says it is — or following the finger that
/// holds it.
class _Piece extends StatefulWidget {
  const _Piece({
    super.key,
    required this.playerIndex,
    required this.horseIndex,
    required this.player,
    required this.position,
    required this.circuit,
    required this.layout,
    required this.pieceSize,
    required this.interactive,
    required this.selected,
    required this.dragAt,
    required this.snapFrom,
    required this.dropped,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
    required this.onLanding,
  });

  final int playerIndex;
  final int horseIndex;
  final Player player;
  final PawnPosition position;
  final Circuit circuit;
  final _PlateLayout layout;
  final double pieceSize;

  /// The horse may be picked up right now.
  final bool interactive;
  final bool selected;

  /// Where the horse is being held, plate-local; null when not held.
  final Offset? dragAt;

  /// Where the horse was let go, so it can glide to where it belongs.
  final Offset? snapFrom;

  /// The horse was set down on its square: its new position is not a
  /// ride to animate.
  final bool dropped;

  final VoidCallback onTap;
  final ValueChanged<Offset> onDragStart;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onDragCancel;

  /// Called where hooves touch down, in screen coordinates, with the
  /// size a puff of dust should have there.
  final void Function(Offset at, double size) onLanding;

  @override
  State<_Piece> createState() => _PieceState();
}

class _PieceState extends State<_Piece> with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    value: 1,
  );

  /// The glide after a drop: from where the finger let go to the square.
  late final AnimationController _snap = AnimationController(
    vsync: this,
    value: 1,
    duration: const Duration(milliseconds: 340),
  );
  Offset? _snapFrom;

  /// The waypoints of the current journey, first = where it started.
  late List<SceneAnchor> _path = [_anchor(widget.position)];
  _Ride _ride = _Ride.hops;
  Timer? _delay;
  int _landed = 0;
  bool _faceLeft = false;

  // Raw pointer handling: a Listener never competes with the zoom
  // viewer's gestures, so a horse under the finger is never mistaken for
  // a pan of the board.
  int? _pointer;
  Offset? _pressAt;
  bool _dragging = false;

  SceneAnchor _anchor(PawnPosition p) =>
      CrossBoardScene.anchorFor(p, widget.playerIndex, widget.horseIndex);

  Offset _toScreen(SceneAnchor a) => widget.layout.toScreen(a);

  @override
  void dispose() {
    _delay?.cancel();
    _c.dispose();
    _snap.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_Piece old) {
    super.didUpdateWidget(old);
    if (widget.snapFrom != null && old.snapFrom == null) {
      _snapFrom = widget.snapFrom;
      final reduce = MediaQuery.disableAnimationsOf(context);
      if (reduce) {
        _snap.value = 1;
      } else {
        _snap.forward(from: 0).whenComplete(() {
          if (!mounted) return;
          if (widget.dropped) {
            widget.onLanding(
              _toScreen(_anchor(widget.position)) +
                  Offset(0, widget.pieceSize * 0.05),
              widget.pieceSize * 0.6,
            );
          }
        });
      }
    }
    if (old.position == widget.position) return;
    if (widget.dropped) {
      // Set down by hand: it is already on its square.
      _delay?.cancel();
      _path = [_anchor(widget.position)];
      _landed = 0;
      _c.value = 1;
      return;
    }
    _startJourney(old.position, widget.position);
  }

  void _startJourney(PawnPosition from, PawnPosition to) {
    _delay?.cancel();
    // A move arriving mid-ride starts from where the piece visibly is.
    final start = _c.isAnimating ? _currentAnchor() : _anchor(from);
    final team = widget.playerIndex;
    final circuit = widget.circuit;

    List<SceneAnchor> waypoints;
    if (to is HomePosition) {
      _ride = _Ride.flight;
      waypoints = [_anchor(to)];
    } else if (from is HomePosition) {
      _ride = _Ride.leap;
      waypoints = [_anchor(to)];
    } else {
      final p0 = circuit.progressOf(from, team);
      final p1 = circuit.progressOf(to, team);
      if (p0 != null && p1 != null && p1 > p0 && p1 - p0 <= 12) {
        _ride = _Ride.hops;
        waypoints = [
          for (var p = p0 + 1; p <= p1; p++)
            _anchor(circuit.positionAt(p, team)),
        ];
      } else {
        _ride = _Ride.leap;
        waypoints = [_anchor(to)];
      }
    }
    _path = [start, ...waypoints];
    _landed = 0;

    final reduce = MediaQuery.disableAnimationsOf(context);
    final hops = waypoints.length;
    final duration = reduce
        ? Duration.zero
        : switch (_ride) {
            _Ride.hops => Duration(
              milliseconds: math.min(
                hops * AppMotion.hopPerCell.inMilliseconds,
                AppMotion.moveMax.inMilliseconds,
              ),
            ),
            _Ride.leap => const Duration(milliseconds: 640),
            _Ride.flight => const Duration(milliseconds: 780),
          };
    _c.duration = duration;

    void go() {
      if (!mounted) return;
      if (duration == Duration.zero) {
        _c.value = 1;
        setState(() {});
        return;
      }
      _c.forward(from: 0);
    }

    // A caught horse waits for the rider that caught it to land: the
    // capture is *seen* as cause and effect, not as two things at once.
    if (_ride == _Ride.flight && !reduce) {
      _c.value = 0;
      _delay = Timer(AppMotion.moveMax, go);
    } else {
      go();
    }
  }

  SceneAnchor _currentAnchor() {
    final n = _path.length - 1;
    if (n <= 0 || _c.value >= 1) return _path.last;
    final x = _c.value * n;
    final seg = math.min(x.floor(), n - 1);
    final u = Curves.easeInOut.transform(x - seg);
    final a = _path[seg], b = _path[seg + 1];
    return SceneAnchor(a.x + (b.x - a.x) * u, a.y + (b.y - a.y) * u);
  }

  // ---- Pointer handling ------------------------------------------------

  void _onPointerDown(PointerDownEvent e) {
    if (_pointer != null) return;
    _pointer = e.pointer;
    _pressAt = e.position;
    _dragging = false;
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (e.pointer != _pointer) return;
    if (!widget.interactive) return;
    if (!_dragging) {
      if ((e.position - _pressAt!).distance < 8) return;
      _dragging = true;
      widget.onDragStart(e.position);
    }
    widget.onDragUpdate(e.position);
  }

  void _onPointerUp(PointerUpEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    if (_dragging) {
      _dragging = false;
      widget.onDragEnd();
    } else if (widget.interactive) {
      widget.onTap();
    }
  }

  void _onPointerCancel(PointerCancelEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    if (_dragging) {
      _dragging = false;
      widget.onDragCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.player.team;
    final size = widget.pieceSize;
    final label = '${widget.player.name} — ${widget.horseIndex + 1}';

    return AnimatedBuilder(
      animation: Listenable.merge([_c, _snap]),
      builder: (context, child) {
        final n = _path.length - 1;
        final t = _c.value;
        var at = _toScreen(_path.last);
        var lift = 0.0;
        var bump = 1.0;
        var settled = true;
        final held = widget.dragAt != null;
        if (held) {
          settled = false;
          at = widget.dragAt!;
          lift = size * 0.45;
        } else if (_snapFrom != null && _snap.value < 1) {
          settled = false;
          final u = Curves.easeOutCubic.transform(_snap.value);
          at = Offset.lerp(_snapFrom, at, u)!;
          lift = size * 0.45 * (1 - u);
        } else if (n > 0 && t < 1) {
          settled = false;
          final x = t * n;
          final seg = math.min(x.floor(), n - 1);
          final u = x - seg;
          final a = _toScreen(_path[seg]);
          final b = _toScreen(_path[seg + 1]);
          final eu = Curves.easeInOut.transform(u);
          at = Offset.lerp(a, b, eu)!;
          final arc = math.sin(math.pi * u);
          lift =
              arc *
              switch (_ride) {
                _Ride.hops => size * 0.42,
                _Ride.leap => size * 1.35,
                _Ride.flight => size * 1.6,
              };
          bump = 1 + 0.10 * arc;
          // Face the way we ride; a vertical hop keeps the last facing.
          final dx = b.dx - a.dx;
          if (dx.abs() > 1) _faceLeft = dx < 0;
          // Hooves down: one puff per square, where the square is.
          if (seg > _landed) {
            _landed = seg;
            widget.onLanding(a + Offset(0, size * 0.05), size * 0.5);
          }
        } else if (n > 0 && t >= 1 && _landed < n) {
          _landed = n;
          if (_ride != _Ride.flight) {
            widget.onLanding(at + Offset(0, size * 0.05), size * 0.6);
          }
        }

        // The herd in the stable stands a touch smaller than the rider on
        // the road, so four of them fit their pad; the leap out grows it.
        final stableScale = widget.position is HomePosition ? 0.84 : 1.0;
        final scale =
            (held
                ? 1.18
                : settled
                ? stableScale
                : _snapFrom != null && _snap.value < 1
                ? 1.18 - 0.18 * Curves.easeOutCubic.transform(_snap.value)
                : switch (_ride) {
                    _Ride.leap => 0.84 + 0.16 * t,
                    _Ride.flight => 1.0 - 0.16 * t,
                    _Ride.hops => 1.0,
                  }) *
            bump;
        final shadowAlpha = 0.30 * (1 - (lift / (size * 1.6)).clamp(0.0, 0.7));

        return Positioned(
          left: at.dx - size / 2,
          top: at.dy - size * 1.15 - lift,
          width: size,
          height: size * 1.4,
          child: Semantics(
            button: widget.interactive,
            selected: widget.selected,
            label: label,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              onPointerCancel: _onPointerCancel,
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: [
                  // The shadow stays on the ground while the horse is up;
                  // a held horse throws a wider, softer one.
                  Positioned(
                    left: size * (held ? 0.0 : 0.10),
                    right: size * (held ? 0.0 : 0.10),
                    bottom: -size * 0.02 + lift * 0.9,
                    height: size * (held ? 0.30 : 0.24),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(size, size * 0.3),
                        ),
                        color: Colors.black.withValues(
                          alpha: held ? 0.22 : shadowAlpha,
                        ),
                      ),
                    ),
                  ),
                  if (widget.selected && !held)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: lift * 0.9,
                      height: size * 1.4,
                      child: CustomPaint(
                        painter: _SelectRingPainter(context.colors.goldAccent),
                      ),
                    ),
                  Transform.scale(
                    scale: scale,
                    alignment: Alignment.bottomCenter,
                    child: Transform.flip(flipX: _faceLeft, child: child),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Image.asset(
        'assets/board/horses/horse_${team.name}.webp',
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
      ),
    );
  }
}

/// A soft cloud of sand, blooming and fading where hooves touched.
class _DustPuff extends StatelessWidget {
  const _DustPuff();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.of(context, const Duration(milliseconds: 600)),
      curve: Curves.easeOut,
      builder: (context, t, _) => Opacity(
        opacity: (0.55 * (1 - t)).clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.5 + 0.9 * t,
          alignment: Alignment.bottomCenter,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFE9D4A6), Color(0x00E9D4A6)],
                stops: [0.25, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The gold ring under the horse the player is holding in mind. The
/// knight itself is the baked sprite from the board pack, one per team.
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

/// The breathing halo under a horse that could ride: a soft gold pool
/// that swells and fades. The selected horse's halo holds bright.
class _HaloPainter extends CustomPainter {
  const _HaloPainter({required this.pulse, required this.selected});

  final double pulse;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final breathe = selected ? 1.0 : 0.55 + 0.45 * pulse;
    final rx = size.width * (0.36 + 0.10 * breathe);
    final ry = size.height * (0.55 + 0.15 * breathe);
    final rect = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          c,
          rx,
          [
            const Color(0xFFFFE08A).withValues(alpha: (selected ? 0.55 : 0.42) * breathe),
            const Color(0x00FFE08A),
          ],
        ),
    );
    canvas.drawOval(
      rect.deflate(size.width * 0.06),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * (selected ? 0.05 : 0.035)
        ..color = const Color(0xFFEED38A).withValues(alpha: (selected ? 0.95 : 0.7) * breathe),
    );
  }

  @override
  bool shouldRepaint(_HaloPainter old) => old.pulse != pulse || old.selected != selected;
}

/// Gold dots on the squares the horse would pass.
class _PathPainter extends CustomPainter {
  const _PathPainter({required this.points, required this.radius});

  final List<Offset> points;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = const Color(0xFFFFE08A).withValues(alpha: 0.45)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius);
    final dot = Paint()..color = const Color(0xFFFFF0C2);
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF6B4A14).withValues(alpha: 0.6);
    for (final p in points) {
      canvas.drawCircle(p, radius * 1.8, glow);
      canvas.drawCircle(p, radius, dot);
      canvas.drawCircle(p, radius, rim);
    }
  }

  @override
  bool shouldRepaint(_PathPainter old) =>
      old.radius != radius || !listEquals(old.points, points);

  static bool listEquals(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// The destination square: a pool of gold light, a breathing ring and
/// eight dashes turning slowly round it. Hovering the horse over it
/// makes it brighter and larger; an arrival gets a star in the middle.
class _DestinationPainter extends CustomPainter {
  const _DestinationPainter({
    required this.pulse,
    required this.hover,
    required this.finish,
  });

  final double pulse;
  final bool hover;
  final bool finish;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final k = hover ? 1.0 : 0.72 + 0.14 * pulse;
    canvas.drawCircle(
      c,
      r * (0.75 + 0.2 * k),
      Paint()
        ..shader = ui.Gradient.radial(c, r * 0.95, [
          const Color(0xFFFFE08A).withValues(alpha: hover ? 0.72 : 0.5),
          const Color(0x00FFE08A),
        ]),
    );
    canvas.drawCircle(
      c,
      r * (0.42 + 0.06 * k),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * (hover ? 0.12 : 0.09)
        ..color = const Color(0xFFFFD86A).withValues(alpha: hover ? 1 : 0.95),
    );
    canvas.drawCircle(
      c,
      r * (0.42 + 0.06 * k),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.02
        ..color = const Color(0xFF6B4A14).withValues(alpha: 0.7),
    );
    // Turning dashes.
    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.06
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFEED38A).withValues(alpha: hover ? 0.95 : 0.7);
    final ring = Rect.fromCircle(center: c, radius: r * (0.62 + 0.08 * k));
    final spin = pulse * math.pi / 4;
    for (var i = 0; i < 8; i++) {
      canvas.drawArc(ring, spin + i * math.pi / 4, math.pi / 14, false, dash);
    }
    if (finish) {
      final star = Path();
      for (var i = 0; i < 16; i++) {
        final radius = i.isEven ? r * 0.26 : r * 0.11;
        final a = -math.pi / 2 + i * math.pi / 8;
        final p = Offset(c.dx + radius * math.cos(a), c.dy + radius * math.sin(a));
        i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(star..close(), Paint()..color = const Color(0xFFFFF0C2));
    }
  }

  @override
  bool shouldRepaint(_DestinationPainter old) =>
      old.pulse != pulse || old.hover != hover || old.finish != finish;
}

/// The bonus square under a stopped horse, lit and breathing for the
/// beat before the extra ride.
class _BonusFlarePainter extends CustomPainter {
  const _BonusFlarePainter({required this.pulse, required this.big});

  final double pulse;
  final bool big;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final k = 0.7 + 0.3 * pulse;
    canvas.drawCircle(
      c,
      r * k,
      Paint()
        ..shader = ui.Gradient.radial(c, r * k, [
          const Color(0xFFFFE08A).withValues(alpha: big ? 0.75 : 0.6),
          const Color(0x00FFE08A),
        ]),
    );
    canvas.drawCircle(
      c,
      r * (0.35 + 0.25 * pulse),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.05 * (1.3 - pulse)
        ..color = const Color(0xFFFFF0C2).withValues(alpha: 0.9 * (1 - pulse * 0.7)),
    );
    if (big) {
      canvas.drawCircle(
        c,
        r * (0.5 + 0.35 * pulse),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.03
          ..color = const Color(0xFFFFE08A).withValues(alpha: 0.7 * (1 - pulse)),
      );
    }
  }

  @override
  bool shouldRepaint(_BonusFlarePainter old) => old.pulse != pulse || old.big != big;
}

/// The +20 star repainted with its light sweep, over the static layer.
class _ShimmerTilePainter extends CustomPainter {
  const _ShimmerTilePainter({
    required this.value,
    required this.diameter,
    required this.shimmer,
  });

  final int value;
  final double diameter;
  final double shimmer;

  @override
  void paint(Canvas canvas, Size size) {
    if (shimmer <= 0 || shimmer >= 1) return;
    BonusTileArt.paint(
      canvas,
      size.center(Offset.zero),
      diameter,
      value,
      shimmer: shimmer,
    );
  }

  @override
  bool shouldRepaint(_ShimmerTilePainter old) =>
      old.shimmer != shimmer || old.diameter != diameter || old.value != value;
}

/// The cloth the plate lies on, filling whatever the phone's aspect
/// leaves around a square board: a vignetted emerald ground with a
/// faint eight-point lattice, a warm halo spilling from under the
/// plate, and the plate's own cast shadow. Painted once per layout —
/// the pieces animate above it without ever repainting this layer.
class _TableBackdropPainter extends CustomPainter {
  const _TableBackdropPainter({required this.plate});

  final Rect plate;

  static const _clothLight = Color(0xFF0F4B39);
  static const _clothDark = Color(0xFF07281F);
  static const _gold = Color(0xFFE3B354);

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    final unit = size.shortestSide;

    canvas.drawRect(
      full,
      Paint()
        ..shader = ui.Gradient.radial(
          plate.center,
          size.longestSide * 0.72,
          const [_clothLight, _clothDark],
        ),
    );

    // Lattice: a quiet grid of eight-point stars, the plate's own motif
    // carried onto the cloth so the bands belong to the same object.
    final cell = unit / 5;
    final lattice = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white.withValues(alpha: 0.05);
    for (var y = cell / 2; y < size.height + cell; y += cell) {
      for (var x = cell / 2; x < size.width + cell; x += cell) {
        _star(canvas, Offset(x, y), cell * 0.30, lattice);
      }
    }

    // Halo: the plate's gold frame warming the cloth around it.
    canvas.drawRect(
      plate.inflate(unit * 0.16),
      Paint()
        ..shader = ui.Gradient.radial(
          plate.center,
          plate.width * 0.82,
          [_gold.withValues(alpha: 0.22), _gold.withValues(alpha: 0)],
        ),
    );

    // Cast shadow, offset down as if lit from above.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        plate.shift(Offset(0, unit * 0.018)).inflate(unit * 0.008),
        Radius.circular(unit * 0.02),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, unit * 0.035),
    );
  }

  /// Two squares, one turned 45°, drawn as one outline.
  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final radius = i.isEven ? r : r * 0.62;
      final a = i * math.pi / 8 - math.pi / 2;
      final v = Offset(c.dx + math.cos(a) * radius, c.dy + math.sin(a) * radius);
      i == 0 ? path.moveTo(v.dx, v.dy) : path.lineTo(v.dx, v.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TableBackdropPainter old) => old.plate != plate;
}
