import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_team.dart';
import 'board_widget.dart' show BoardPreview;
import 'scene_anchors.g.dart';

/// The playable board as a pre-rendered 2.5D diorama.
///
/// The world itself (terrain, causeway, camps, centre oasis, lighting)
/// is baked offline by `tool/art/bake_scene.py` into one full-screen
/// image; this widget draws that scene and composites the LIVE pieces —
/// figurine horses, selection rings, destination previews — onto the
/// baked anchor points, so the game plays inside the illustration
/// rather than beside it.
class BakedBoardScene extends StatelessWidget {
  const BakedBoardScene({
    super.key,
    required this.state,
    this.selectableHorses = const {},
    this.selectedHorseKey,
    this.onHorseTap,
    this.preview,
  });

  final GameState state;
  final Set<String> selectableHorses;
  final String? selectedHorseKey;
  final void Function(int playerIndex, int horseIndex)? onHorseTap;
  final BoardPreview? preview;

  static const _sceneAspect = 1170 / 2340;

  /// Where a pawn stands, in normalized scene coordinates.
  static SceneAnchor anchorFor(GameState state, int playerIndex, int horseIndex) {
    final player = state.players[playerIndex];
    final team = player.team.index;
    final position = player.horses[horseIndex].position;
    return switch (position) {
      HomePosition() => sceneCampAnchors[team]![horseIndex % 4],
      TrackPosition(:final index) => sceneTrackAnchors[index % sceneTrackAnchors.length],
      FinalLanePosition(:final step) =>
        sceneLaneAnchors[team]![(step - 1).clamp(0, sceneLaneAnchors[team]!.length - 1)],
      FinishedPosition() => SceneAnchor(
        sceneCenterAnchor.x + 0.03 * math.cos(team * math.pi / 2),
        sceneCenterAnchor.y + 0.015 * math.sin(team * math.pi / 2),
        sceneCenterAnchor.scale,
      ),
    };
  }

  static SceneAnchor _anchorForPosition(PawnPosition pos, int team, int horseIndex) =>
      switch (pos) {
        HomePosition() => sceneCampAnchors[team]![horseIndex % 4],
        TrackPosition(:final index) => sceneTrackAnchors[index % sceneTrackAnchors.length],
        FinalLanePosition(:final step) =>
          sceneLaneAnchors[team]![(step - 1).clamp(0, sceneLaneAnchors[team]!.length - 1)],
        FinishedPosition() => sceneCenterAnchor,
      };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sw = constraints.maxWidth;
        final sh = constraints.maxHeight;
        // BoxFit.cover mapping from normalized scene space to screen.
        final scale = math.max(sw / _sceneAspect, sh) / 1.0;
        final imgW = _sceneAspect * scale;
        final imgH = scale;
        final dx = (sw - imgW) / 2;
        final dy = (sh - imgH) / 2;
        Offset toScreen(SceneAnchor a) => Offset(dx + a.x * imgW, dy + a.y * imgH);

        final pieces = <Widget>[];
        final sorted = <(double, Widget)>[];

        // Preview: breadcrumb rings along the path + a beacon at the
        // destination, drawn under the horses.
        if (preview != null) {
          final p = preview!;
          final team = state.players[p.teamIndex].team.index;
          final crumbs = <SceneAnchor>[];
          final from = p.from;
          final circuit = state.circuit;
          final p0 = from == null ? null : circuit.progressOf(from, p.teamIndex);
          final p1 = circuit.progressOf(p.destination, p.teamIndex);
          if (p0 != null && p1 != null && p1 > p0) {
            for (var s = p0 + 1; s < p1; s++) {
              crumbs.add(_anchorForPosition(circuit.positionAt(s, p.teamIndex), team, 0));
            }
          }
          pieces.add(
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _PreviewPainter(
                    crumbs: [for (final a in crumbs) toScreen(a)],
                    beacon: toScreen(_anchorForPosition(p.destination, team, 0)),
                    beaconScale: _anchorForPosition(p.destination, team, 0).scale * imgH / 2340,
                  ),
                ),
              ),
            ),
          );
        }

        for (var pi = 0; pi < state.players.length; pi++) {
          final player = state.players[pi];
          for (var hi = 0; hi < player.horses.length; hi++) {
            final key = '${player.id}:$hi';
            final anchor = anchorFor(state, pi, hi);
            final pos = toScreen(anchor);
            // Piece height in screen px: sized to the baked scene's own
            // pixel density so pieces match the reference board's scale.
            final h = 168.0 * anchor.scale * imgH / 2340;
            sorted.add((
              pos.dy,
              _SceneHorse(
                key: ValueKey('scene-$key'),
                team: player.team,
                horse: player.horses[hi],
                horseIndex: hi,
                teamIndex: player.team.index,
                gameTeamIndex: pi,
                circuit: state.circuit,
                target: pos,
                height: h,
                // The knight sprites face LEFT natively: flip pieces on
                // the board's left half so every piece faces inward.
                faceLeft: anchor.x <= 0.5,
                selectable: selectableHorses.contains(key),
                selected: selectedHorseKey == key,
                toScreen: toScreen,
                onTap: onHorseTap == null ? null : () => onHorseTap!(pi, hi),
              ),
            ));
          }
        }
        // Painter's order: pieces lower on screen draw in front.
        sorted.sort((a, b) => a.$1.compareTo(b.$1));

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/board/scene_oasis.webp',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.medium,
            ),
            ...pieces,
            ...sorted.map((e) => e.$2),
          ],
        );
      },
    );
  }
}

/// One live figurine on the diorama: rides hop-by-hop between anchors,
/// with a gold selection ring when it can be played.
class _SceneHorse extends StatefulWidget {
  const _SceneHorse({
    super.key,
    required this.team,
    required this.horse,
    required this.horseIndex,
    required this.teamIndex,
    required this.gameTeamIndex,
    required this.circuit,
    required this.target,
    required this.height,
    required this.faceLeft,
    required this.selectable,
    required this.selected,
    required this.toScreen,
    required this.onTap,
  });

  final AppTeam team;
  final HorseState horse;
  final int horseIndex;
  final int teamIndex;
  final int gameTeamIndex;
  final Circuit circuit;
  final Offset target;
  final double height;
  final bool faceLeft;
  final bool selectable;
  final bool selected;
  final Offset Function(SceneAnchor) toScreen;
  final VoidCallback? onTap;

  @override
  State<_SceneHorse> createState() => _SceneHorseState();
}

class _SceneHorseState extends State<_SceneHorse> with SingleTickerProviderStateMixin {
  late final AnimationController _move = AnimationController(vsync: this, value: 1);
  List<Offset> _waypoints = const [];

  @override
  void didUpdateWidget(covariant _SceneHorse old) {
    super.didUpdateWidget(old);
    if (old.horse.position != widget.horse.position) {
      _startMove(old.horse.position, widget.horse.position);
    } else if (old.target != widget.target && !_move.isAnimating) {
      _move.value = 1;
    }
  }

  void _startMove(PawnPosition from, PawnPosition to) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final circuit = widget.circuit;
    final p0 = circuit.progressOf(from, widget.gameTeamIndex);
    final p1 = circuit.progressOf(to, widget.gameTeamIndex);
    if (!reduceMotion && p1 != null && (p0 ?? -1) < p1) {
      _waypoints = [
        _screenOf(from),
        for (var p = (p0 ?? -1) + 1; p <= p1; p++)
          _screenOf(circuit.positionAt(p, widget.gameTeamIndex)),
      ];
    } else {
      _waypoints = [_screenOf(from), widget.target];
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

  Offset _screenOf(PawnPosition pos) => widget.toScreen(
    BakedBoardScene._anchorForPosition(pos, widget.teamIndex, widget.horseIndex),
  );

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
    return (widget.target, 0);
  }

  @override
  void dispose() {
    _move.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = switch (widget.team) {
      AppTeam.emerald => 'assets/board/horses/horse_emerald.webp',
      AppTeam.saphir => 'assets/board/horses/horse_saphir.webp',
      AppTeam.grenat => 'assets/board/horses/horse_grenat.webp',
      AppTeam.safran => 'assets/board/horses/horse_safran.webp',
    };
    return AnimatedBuilder(
      animation: _move,
      builder: (context, _) {
        final (center, lift) = _sample();
        final h = widget.height;
        final w = h *
            switch (widget.team) {
              AppTeam.emerald => 74 / 106,
              AppTeam.saphir || AppTeam.grenat => 79 / 96,
              AppTeam.safran => 82 / 93,
            };
        // The knight's feet stand on the anchor.
        final left = center.dx - w / 2;
        final top = center.dy - h * 0.97 - lift * h * 0.24;
        Widget sprite = Image.asset(asset, height: h, filterQuality: FilterQuality.medium);
        if (widget.faceLeft) {
          sprite = Transform.flip(flipX: true, child: sprite);
        }
        if (widget.selected) {
          sprite = Transform.scale(scale: 1.08, child: sprite);
        }
        return Positioned(
          left: left,
          top: top,
          width: w,
          height: h,
          child: GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.translucent,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (widget.selectable)
                  Positioned(
                    left: -w * 0.22,
                    right: -w * 0.22,
                    bottom: -h * 0.06,
                    height: h * 0.34,
                    child: IgnorePointer(
                      child: _PulsingRing(gold: widget.selected),
                    ),
                  ),
                Semantics(
                  button: widget.onTap != null,
                  label: 'horse',
                  child: sprite,
                ),
                if (widget.horse.hasShield)
                  Positioned(
                    top: -h * 0.06,
                    right: w * 0.10,
                    child: IgnorePointer(
                      child: Icon(
                        Icons.shield,
                        size: h * 0.22,
                        color: const Color(0xFFEAF2FF),
                        shadows: const [Shadow(color: Color(0x99000000), blurRadius: 6)],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PulsingRing extends StatefulWidget {
  const _PulsingRing({required this.gold});

  final bool gold;

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) _c.stop();
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(
        painter: _RingPainter(
          t: 0.5 + 0.5 * _c.value,
          color: widget.gold ? const Color(0xFFFFE08A) : const Color(0xE6FFF2C8),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.t, required this.color});

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 + 1.5 * t
      ..color = color.withValues(alpha: 0.55 + 0.4 * t);
    canvas.drawOval(rect.deflate(2), paint);
    canvas.drawOval(
      rect.deflate(2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = color.withValues(alpha: 0.18 * t)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.t != t || old.color != color;
}

class _PreviewPainter extends CustomPainter {
  const _PreviewPainter({required this.crumbs, required this.beacon, required this.beaconScale});

  final List<Offset> crumbs;
  final Offset beacon;
  final double beaconScale;

  @override
  void paint(Canvas canvas, Size size) {
    final crumbPaint = Paint()..color = const Color(0xD9FFE9AE);
    final crumbGlow = Paint()
      ..color = const Color(0x66FFC94D)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    for (final c in crumbs) {
      canvas.drawCircle(c, 8, crumbGlow);
      canvas.drawCircle(c, 4, crumbPaint);
    }
    // Roughly one slab wide in scene pixels, projected to screen.
    final r = 165 * beaconScale;
    canvas.drawOval(
      Rect.fromCenter(center: beacon, width: r, height: r * 0.55),
      Paint()
        ..color = const Color(0x59FFC94D)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawOval(
      Rect.fromCenter(center: beacon, width: r, height: r * 0.55),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = const Color(0xFFFFE08A),
    );
    canvas.drawOval(
      Rect.fromCenter(center: beacon, width: r * 0.62, height: r * 0.34),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xCCFFF4CE),
    );
    // A gold marker arrow floating above the destination.
    final tip = beacon.translate(0, -r * 0.42);
    final arrow = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - r * 0.16, tip.dy - r * 0.30)
      ..lineTo(tip.dx, tip.dy - r * 0.22)
      ..lineTo(tip.dx + r * 0.16, tip.dy - r * 0.30)
      ..close();
    canvas.drawPath(
      arrow,
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(arrow, Paint()..color = const Color(0xFFFFD873));
  }

  @override
  bool shouldRepaint(covariant _PreviewPainter old) =>
      old.beacon != beacon || old.crumbs.length != crumbs.length;
}
