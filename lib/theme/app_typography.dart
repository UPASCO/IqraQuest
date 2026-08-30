import 'package:flutter/material.dart';

/// Font families bundled with IqraQuest (see THIRD_PARTY_NOTICES.md for
/// licensing — both are SIL Open Font License, redistributable and free
/// for commercial use).
class AppFonts {
  const AppFonts._();

  /// Latin/Cyrillic/Vietnamese script UI text — fr, en, es, pt, de, tr, id,
  /// ms, it, nl.
  static const String latin = 'NotoSans';

  /// Arabic-script UI text — ar, ur. Naskh style: legible, non-decorative,
  /// respectful of religious content (no faux calligraphy).
  static const String arabic = 'NotoNaskhArabic';

  static const Set<String> rtlLocales = {'ar', 'ur'};

  static bool isRtl(String languageCode) => rtlLocales.contains(languageCode);

  static String familyFor(String languageCode) => isRtl(languageCode) ? arabic : latin;
}

/// Type scale. Sizes are logical pixels; line heights are ratios.
class AppTypography {
  const AppTypography._();

  static TextTheme textThemeFor(String languageCode) {
    final family = AppFonts.familyFor(languageCode);
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: family,
        fontSize: 40,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontFamily: family,
        fontSize: 32,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: TextStyle(
        fontFamily: family,
        fontSize: 26,
        height: 1.25,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        fontFamily: family,
        fontSize: 22,
        height: 1.28,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: family,
        fontSize: 19,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontFamily: family,
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontFamily: family,
        fontSize: 17,
        height: 1.45,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        fontFamily: family,
        fontSize: 15,
        height: 1.45,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        fontFamily: family,
        fontSize: 13,
        height: 1.4,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        fontFamily: family,
        fontSize: 16,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: TextStyle(
        fontFamily: family,
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      labelSmall: TextStyle(
        fontFamily: family,
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    );
  }
}
