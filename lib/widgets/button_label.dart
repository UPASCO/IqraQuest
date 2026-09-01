import 'package:flutter/material.dart';

/// A button label that stays on one centred line.
///
/// Material buttons let their child wrap, so a label that is comfortable
/// in French ("Continuer") breaks mid-word once the same string is
/// German or Indonesian — the control's text then sits off its baseline
/// and reads as broken. Scaling the label down instead keeps every
/// button symmetrical and legible in all 12 locales.
///
/// [maxLines] is 1 by default; pass 2 for the rare long call to action
/// that genuinely reads better on two balanced lines.
class ButtonLabel extends StatelessWidget {
  const ButtonLabel(this.text, {super.key, this.maxLines = 1});

  final String text;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      textAlign: TextAlign.center,
      maxLines: maxLines,
      softWrap: maxLines > 1,
      overflow: TextOverflow.ellipsis,
    );
    // scaleDown only shrinks: a label that already fits is untouched, so
    // buttons keep a consistent type size across the app.
    return FittedBox(fit: BoxFit.scaleDown, child: label);
  }
}
