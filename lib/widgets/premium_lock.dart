import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Premium on a free device is shown, never hidden: a locked course, a
/// locked level, a locked save keep their place on the screen, greyed
/// and marked with this gold lock, and a tap on any of them opens the
/// one screen that sells the unlock. What is for sale is visible from
/// every place it would be used — which is where a family decides.
///
/// A tester build's switch (Settings › Tester mode) grants the same
/// entitlement locally, so everything below reads the one
/// `premiumControllerProvider` and nothing checks the build flag.

/// The single way to the paywall, so every locked thing goes to the
/// same place and the route lives in one line.
void openPremium(BuildContext context) => context.push('/premium');

/// The gold lock, sized for a tile corner or a chip.
class LockBadge extends StatelessWidget {
  const LockBadge({super.key, this.size = 20});

  final double size;

  static const Color gold = Color(0xFFE3B354);
  static const Color ink = Color(0xFF4A3410);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: gold,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Icon(Icons.lock, size: size * 0.6, color: ink),
    );
  }
}

/// Greys what it wraps, the way a locked tile reads at a glance, and
/// pins the lock at the top end corner. The child stays laid out at its
/// full size so a locked tile is exactly as big as an open one.
class LockedOverlay extends StatelessWidget {
  const LockedOverlay({
    super.key,
    required this.locked,
    required this.child,
    this.badgeSize = 20,
    this.inset = 6,
  });

  final bool locked;
  final Widget child;
  final double badgeSize;
  final double inset;

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(opacity: 0.55, child: child),
        PositionedDirectional(
          top: inset,
          end: inset,
          child: LockBadge(size: badgeSize),
        ),
      ],
    );
  }
}
