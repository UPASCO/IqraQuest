import 'package:flutter/material.dart';

import '../theme/app_team.dart';

/// A team's knight piece as the baked sprite from the board pack — the
/// very figurine that rides the track, so a rider recognises their horse
/// in the setup screen and on the board alike.
class KnightSprite extends StatelessWidget {
  const KnightSprite({super.key, required this.team, this.height = 56, this.semanticLabel});

  final AppTeam team;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    // The sprite is 64×89; keep its aspect so the base disc stays round.
    return SizedBox(
      height: height,
      width: height * 64 / 89,
      child: Image.asset(
        'assets/board/horses/horse_${team.name}.webp',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        semanticLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
      ),
    );
  }
}
