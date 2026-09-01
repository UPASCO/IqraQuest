// Measures the contrast of every text colour against the surface it is
// actually drawn on, in both themes.
//
// "Looks fine to me" is not a check: contrast is a number, and a pairing
// that reads on a bright studio monitor can be unreadable on a phone in
// daylight. WCAG 2.1 asks for 4.5:1 for body text and 3:1 for large or
// bold text; this holds the palette to that.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iqraquest/theme/app_semantic_colors.dart';

double _channel(int v) {
  final c = v / 255.0;
  return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}

double _luminance(Color c) =>
    0.2126 * _channel((c.r * 255).round()) +
    0.7152 * _channel((c.g * 255).round()) +
    0.0722 * _channel((c.b * 255).round());

/// Flattens a possibly translucent foreground over its background first —
/// several tokens are deliberately semi-transparent, and judging them at
/// full opacity would report a contrast the reader never sees.
Color _flatten(Color fg, Color bg) {
  final a = fg.a;
  return Color.fromARGB(
    255,
    ((fg.r * a + bg.r * (1 - a)) * 255).round(),
    ((fg.g * a + bg.g * (1 - a)) * 255).round(),
    ((fg.b * a + bg.b * (1 - a)) * 255).round(),
  );
}

double contrast(Color fg, Color bg) {
  final f = _luminance(_flatten(fg, bg));
  final b = _luminance(bg);
  final hi = math.max(f, b), lo = math.min(f, b);
  return (hi + 0.05) / (lo + 0.05);
}

/// The scene the board and the hero screens are painted on. `onScene`
/// tokens are read against this, not against the theme's surface.
const _scene = Color(0xFF0A3327);

void main() {
  for (final (themeName, c) in [
    ('day', AppSemanticColors.day),
    ('night', AppSemanticColors.night),
  ]) {
    group('$themeName theme', () {
      final bodyPairs = <String, (Color, Color)>{
        'textPrimary on background': (c.textPrimary, c.background),
        'textPrimary on surface': (c.textPrimary, c.surface),
        'textPrimary on surfaceElevated': (c.textPrimary, c.surfaceElevated),
        'textSecondary on background': (c.textSecondary, c.background),
        'textSecondary on surface': (c.textSecondary, c.surface),
        'textSecondary on surfaceElevated': (c.textSecondary, c.surfaceElevated),
        'onScene on the painted scene': (c.onScene, _scene),
        'onSceneDim on the painted scene': (c.onSceneDim, _scene),
      };

      bodyPairs.forEach((name, pair) {
        test('$name meets 4.5:1', () {
          final ratio = contrast(pair.$1, pair.$2);
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$name is ${ratio.toStringAsFixed(2)}:1',
          );
        });
      });

      // Large or bold: headings, the gold call to action, status text.
      final largePairs = <String, (Color, Color)>{
        'primary on surface': (c.primary, c.surface),
        'error on surface': (c.error, c.surface),
        'success on surface': (c.success, c.surface),
        'goldAccent on the painted scene': (c.goldAccent, _scene),
      };

      largePairs.forEach((name, pair) {
        test('$name meets 3:1', () {
          final ratio = contrast(pair.$1, pair.$2);
          expect(
            ratio,
            greaterThanOrEqualTo(3.0),
            reason: '$name is ${ratio.toStringAsFixed(2)}:1',
          );
        });
      });
    });
  }
}
