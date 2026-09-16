import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'ornate_frame.dart';
import 'premium_lock.dart';

/// A round glass button over painted scenery: the board's HUD, the
/// home bar, the riders' back button.
///
/// The disc is drawn 38 points across so five of them fit beside a
/// name on a narrow phone; the tap area is the design system's 48-point
/// minimum ([AppSpacing.minTouchTarget]), so a small disc never means a
/// small target.
class GlassCircleButton extends StatelessWidget {
  const GlassCircleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = OrnatePalette.ivory,
    this.locked = false,
  });

  /// The tap area, and the widget's size.
  static const double hitSize = AppSpacing.minTouchTarget;

  /// The glass disc as drawn, centred in the tap area.
  static const double discSize = 38;

  final IconData icon;

  /// What this button does, for a screen reader — never guessed from
  /// the glyph: two of these can sit side by side.
  final String label;

  final VoidCallback onTap;
  final Color iconColor;

  /// A Premium action on a free device: the glyph dimmed and the gold
  /// lock on its corner; the tap still works, and opens the paywall.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final disc = Ink(
      width: discSize,
      height: discSize,
      decoration: ShapeDecoration(
        color: const Color(0xB3122E22),
        shape: CircleBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        ),
      ),
      child: Icon(
        icon,
        size: 19,
        color: locked ? iconColor.withValues(alpha: 0.6) : iconColor,
      ),
    );
    final button = Material(
      type: MaterialType.transparency,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: hitSize,
          height: hitSize,
          child: Center(child: disc),
        ),
      ),
    );
    return Semantics(
      button: true,
      label: label,
      child: locked
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                button,
                const PositionedDirectional(
                  end: 0,
                  bottom: 0,
                  child: LockBadge(size: 16),
                ),
              ],
            )
          : button,
    );
  }
}
