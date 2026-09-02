import 'package:flutter/material.dart';

import '../models/circuit.dart';

/// The bitmap illustration layer (spec §17): painterly concept art shipped
/// as WebP in assets/images/, sitting on top of the procedural world.
/// Every consumer goes through [ArtPanel], which degrades to a quiet
/// gradient if an asset ever fails to decode — the UI never breaks on art.
abstract final class AppArt {
  static const regionDawn = 'assets/images/region_dawn.webp';
  static const regionOasis = 'assets/images/region_oasis.webp';
  static const regionMountains = 'assets/images/region_mountains.webp';
  static const chestGlow = 'assets/images/chest_glow.webp';
  static const oasisFalls = 'assets/images/oasis_falls.webp';
  static const oasisArrival = 'assets/images/oasis_arrival.webp';
  static const worldBand = 'assets/images/world_band.webp';

  /// The home screen's key art: the icon's three galloping horses over
  /// the painted board laid on its table (tool/art/bake_home_hero.py).
  static const homeHero = 'assets/images/home_hero.webp';

  /// Each circuit rides through its own region; the card art must match
  /// the world the player will actually see in game.
  static String forCircuit(CircuitId id) => switch (id) {
    CircuitId.oasisRoute => regionDawn,
    CircuitId.caravanTrail => regionMountains,
    CircuitId.greatRide => regionOasis,
  };
}

/// A rounded, gold-rimmed illustration. The frame is part of the game's
/// visual language (navy night + gold), so it lives here rather than
/// being re-styled at each call site.
class ArtPanel extends StatelessWidget {
  const ArtPanel({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.radius = 16,
    this.rimmed = true,
    this.glow = false,
  });

  final String asset;
  final double? width;
  final double? height;
  final double radius;
  final bool rimmed;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: rimmed
            ? Border.all(color: const Color(0xFFEBC06A).withValues(alpha: 0.55), width: 1.2)
            : null,
        boxShadow: [
          if (glow)
            const BoxShadow(color: Color(0x66F3D68A), blurRadius: 26, spreadRadius: 2)
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - (rimmed ? 1.2 : 0)),
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E4A38), Color(0xFF10281E)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
