import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
/// a tile the art does not have.
///
/// Every piece on it is a [_Piece] that *rides*: a move of n squares is n
/// hops along the actual track, a horse leaving the stable leaps onto
/// its start square, and a captured horse flies home once the rider that
/// caught it has landed. A piece that teleported across the plate was
/// the single most-reported confusion of the first playtests — a child
/// cannot follow what they did not see.
class CrossBoardScene extends StatefulWidget {
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

  /// `'<playerId>:<horseIndex>'` for every horse the player may pick
  /// right now; each gets the gold ring.
  final Set<String> selectableHorses;
  final void Function(int playerIndex, int horseIndex)? onHorseTap;

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

  @override
  State<CrossBoardScene> createState() => _CrossBoardSceneState();
}

class _CrossBoardSceneState extends State<CrossBoardScene> {
  /// Pieces in the middle of a ride: painted last, so a rider crosses
  /// *over* the horses it passes rather than under them.
  final Set<String> _riding = {};
  Timer? _ridingTimer;

  /// Puffs of dust where hooves just landed, by id.
  final List<_Puff> _puffs = [];
  int _puffSeq = 0;

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
  }

  @override
  void dispose() {
    _ridingTimer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = widget.state;

    return LayoutBuilder(
      builder: (context, constraints) {
        // The plate is square; it is laid out centred and contained so
        // no square is ever cropped off the edge of a phone.
        final side = constraints.biggest.shortestSide;
        final left = (constraints.maxWidth - side) / 2;
        final top = (constraints.maxHeight - side) / 2;
        Offset toScreen(SceneAnchor a) =>
            Offset(left + a.x * side, top + a.y * side);
        final pieceSize = side * 0.072;

        // Paint order: higher on the plate first, so a horse standing
        // lower overlaps the base of the one behind it (the 2x2 stable
        // reads as a little herd, not a stack of discs); riders last.
        final pieces = <({int p, int h, double y, bool riding})>[];
        for (var pi = 0; pi < state.players.length; pi++) {
          final player = state.players[pi];
          for (var hi = 0; hi < player.horses.length; hi++) {
            final a = CrossBoardScene.anchorFor(
              player.horses[hi].position,
              pi,
              hi,
            );
            pieces.add((
              p: pi,
              h: hi,
              y: a.y,
              riding: _riding.contains('${player.id}:$hi'),
            ));
          }
        }
        pieces.sort((a, b) {
          if (a.riding != b.riding) return a.riding ? 1 : -1;
          return a.y.compareTo(b.y);
        });

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

            if (widget.preview != null)
              Positioned(
                key: const ValueKey('preview'),
                left:
                    toScreen(
                      CrossBoardScene.anchorFor(
                        widget.preview!.destination,
                        widget.preview!.teamIndex,
                        0,
                      ),
                    ).dx -
                    pieceSize * 0.72,
                top:
                    toScreen(
                      CrossBoardScene.anchorFor(
                        widget.preview!.destination,
                        widget.preview!.teamIndex,
                        0,
                      ),
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
                left: left,
                top: top,
                side: side,
                pieceSize: pieceSize,
                selectable: widget.selectableHorses.contains(
                  '${state.players[piece.p].id}:${piece.h}',
                ),
                onTap: widget.onHorseTap == null
                    ? null
                    : () => widget.onHorseTap!(piece.p, piece.h),
                onLanding: _puffAt,
              ),
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
/// wherever the game now says it is.
class _Piece extends StatefulWidget {
  const _Piece({
    super.key,
    required this.playerIndex,
    required this.horseIndex,
    required this.player,
    required this.position,
    required this.circuit,
    required this.left,
    required this.top,
    required this.side,
    required this.pieceSize,
    required this.selectable,
    required this.onTap,
    required this.onLanding,
  });

  final int playerIndex;
  final int horseIndex;
  final Player player;
  final PawnPosition position;
  final Circuit circuit;
  final double left;
  final double top;
  final double side;
  final double pieceSize;
  final bool selectable;
  final VoidCallback? onTap;

  /// Called where hooves touch down, in screen coordinates, with the
  /// size a puff of dust should have there.
  final void Function(Offset at, double size) onLanding;

  @override
  State<_Piece> createState() => _PieceState();
}

class _PieceState extends State<_Piece> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    value: 1,
  );

  /// The waypoints of the current journey, first = where it started.
  late List<SceneAnchor> _path = [_anchor(widget.position)];
  _Ride _ride = _Ride.hops;
  Timer? _delay;
  int _landed = 0;
  bool _faceLeft = false;

  SceneAnchor _anchor(PawnPosition p) =>
      CrossBoardScene.anchorFor(p, widget.playerIndex, widget.horseIndex);

  Offset _toScreen(SceneAnchor a) =>
      Offset(widget.left + a.x * widget.side, widget.top + a.y * widget.side);

  @override
  void dispose() {
    _delay?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_Piece old) {
    super.didUpdateWidget(old);
    if (old.position == widget.position) return;
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

  @override
  Widget build(BuildContext context) {
    final team = widget.player.team;
    final size = widget.pieceSize;
    final label = '${widget.player.name} — ${widget.horseIndex + 1}';

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final n = _path.length - 1;
        final t = _c.value;
        var at = _toScreen(_path.last);
        var lift = 0.0;
        var bump = 1.0;
        var settled = true;
        if (n > 0 && t < 1) {
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
            (settled
                ? stableScale
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
            button: widget.onTap != null,
            label: label,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: [
                  // The shadow stays on the ground while the horse is up.
                  Positioned(
                    left: size * 0.10,
                    right: size * 0.10,
                    bottom: -size * 0.02 + lift * 0.9,
                    height: size * 0.24,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(size, size * 0.3),
                        ),
                        color: Colors.black.withValues(alpha: shadowAlpha),
                      ),
                    ),
                  ),
                  if (widget.selectable)
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
