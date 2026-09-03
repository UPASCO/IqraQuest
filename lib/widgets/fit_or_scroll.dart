import 'package:flutter/material.dart';

import 'content_width.dart';

/// Centres its child when there is room, and lets it scroll when there
/// is not.
///
/// A screen laid out as a plain [Column] looks right on the phone it was
/// designed on and overflows on a small one — or on any phone once the
/// reader turns text size up. Making such a screen permanently
/// scrollable would be worse: short content would drift to the top and
/// lose its composition. This keeps the centred layout while guaranteeing
/// nothing is ever cut off or unreachable.
class FitOrScroll extends StatelessWidget {
  const FitOrScroll({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.maxWidth = kMaxContentWidth,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// How wide the composition may get. On a phone this is never reached;
  /// on a tablet it is what keeps a column of controls from stretching
  /// across eleven hundred points.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            // The child still gets the full height to lay out against, so
            // Spacer and centring behave exactly as before when it fits —
            // and the width cap only ever bites on a tablet.
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - padding.vertical,
              maxWidth: maxWidth,
            ),
            child: IntrinsicHeight(child: child),
          ),
        ),
      ),
    );
  }
}
