import 'package:flutter/material.dart';

import 'button_label.dart';

/// A short label that wraps onto a second line when it can, and only
/// scales down when it must.
///
/// [ButtonLabel] keeps one line and shrinks whatever does not fit; on a
/// row of four tiles that made "Daily Challenge" the one small label of
/// the four. This one lays the words out at full size first: if they
/// fit in [maxLines] with no word broken in two, they wrap; otherwise —
/// "Tagesherausforderung" on a narrow tile — it falls back to the
/// one-line scale-down, so every one of the twelve languages stays
/// whole and readable.
///
/// It measures with a [LayoutBuilder], so it cannot sit under an
/// [IntrinsicHeight]; give it a box of [linesHeight] instead when its
/// neighbours must match.
class WrappedLabel extends StatelessWidget {
  const WrappedLabel(
    this.text, {
    super.key,
    required this.style,
    this.maxLines = 2,
  });

  final String text;
  final TextStyle style;
  final int maxLines;

  /// The height [maxLines] lines take at the viewer's text size — what a
  /// row of these should reserve so its tiles stay level.
  static double linesHeight(
    BuildContext context,
    TextStyle style, {
    int maxLines = 2,
  }) {
    final size = MediaQuery.textScalerOf(context).scale(style.fontSize ?? 14);
    return size * (style.height ?? 1.2) * maxLines;
  }

  bool _fits(BuildContext context, double width) {
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final whole = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: maxLines,
    )..layout(maxWidth: width);
    final exceeded = whole.didExceedMaxLines;
    whole.dispose();
    if (exceeded) return false;
    // No word broken in two: a word wider than the tile would be split
    // mid-letter by the wrap, which reads worse than a smaller label.
    for (final word in text.split(RegExp(r'\s+'))) {
      final one = TextPainter(
        text: TextSpan(text: word, style: style),
        textDirection: direction,
        textScaler: scaler,
      )..layout();
      final tooWide = one.width > width;
      one.dispose();
      if (tooWide) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width.isFinite && _fits(context, width)) {
          return Text(
            text,
            textAlign: TextAlign.center,
            maxLines: maxLines,
            style: style,
          );
        }
        return ButtonLabel(text, style: style);
      },
    );
  }
}
