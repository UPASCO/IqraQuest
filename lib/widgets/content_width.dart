import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The widest a column of reading matter or controls is ever allowed to
/// get, whatever the screen behind it.
///
/// A phone layout dropped onto a tablet does not break — it *strands*: a
/// circuit card stretches to eleven hundred points around a 76-point
/// thumbnail, a line of body text runs past the eye's comfortable
/// measure, and a composition designed to fill a phone huddles at the top
/// of a screen twice its height. Capping the measure and centring it is
/// what turns the same layout into a tablet layout — no second design to
/// keep in step, and nothing about the phone changes, because a phone is
/// narrower than this cap.
const double kMaxContentWidth = 600;

/// Whether this screen is a tablet-sized one. The shortest side is the
/// honest test: it does not change when the device is rotated, so a
/// layout cannot flip identity mid-turn.
bool isTabletSize(BuildContext context) =>
    MediaQuery.sizeOf(context).shortestSide >= 600;

/// Page padding that keeps the content at [kMaxContentWidth] on a wide
/// screen by growing the side margins, and leaves narrow screens exactly
/// as they were.
///
/// For a scrolling list this is better than wrapping every row: the
/// scrollbar and the scroll gesture stay at the edges of the screen,
/// where the thumb is, while the rows themselves stay readable.
EdgeInsets pagePadding(
  BuildContext context, {
  double horizontal = 20,
  double top = 0,
  double bottom = 0,
}) {
  final width = MediaQuery.sizeOf(context).width;
  // max, not clamp: a screen narrower than the cap gives a negative
  // half-margin, and a width of zero — which does happen for a frame
  // during layout — would make clamp's upper limit smaller than its
  // lower one and throw.
  final side = math.max(horizontal, (width - kMaxContentWidth) / 2);
  return EdgeInsets.fromLTRB(side, top, side, bottom);
}

/// Centres its child and holds it to [kMaxContentWidth].
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = kMaxContentWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    // heightFactor 1, not a plain Center: a Center under loose height
    // constraints — a bottom bar, a sheet — grows to fill the screen and
    // takes the room the page needed. This stays exactly as tall as its
    // child and only centres it sideways.
    alignment: Alignment.center,
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
