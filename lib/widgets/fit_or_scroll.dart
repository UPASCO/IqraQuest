import 'package:flutter/material.dart';

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
  const FitOrScroll({super.key, required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          // The child still gets the full height to lay out against, so
          // Spacer and centring behave exactly as before when it fits.
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight - padding.vertical,
          ),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }
}
