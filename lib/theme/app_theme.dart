import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart' show AppRadius;
import 'app_semantic_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

export 'app_colors.dart';
export 'app_radius.dart';
export 'app_semantic_colors.dart';
export 'app_spacing.dart';
export 'app_typography.dart';

/// Builds IqraQuest's [ThemeData] for a given brightness + UI language.
class AppTheme {
  const AppTheme._();

  static ThemeData light(String languageCode) => _build(
    brightness: Brightness.light,
    semantic: AppSemanticColors.day,
    languageCode: languageCode,
  );

  static ThemeData dark(String languageCode) => _build(
    brightness: Brightness.dark,
    semantic: AppSemanticColors.night,
    languageCode: languageCode,
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppSemanticColors semantic,
    required String languageCode,
  }) {
    final textTheme = AppTypography.textThemeFor(languageCode)
        .apply(bodyColor: semantic.textPrimary, displayColor: semantic.textPrimary);

    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.emerald, brightness: brightness)
        .copyWith(
          primary: semantic.primary,
          secondary: semantic.secondary,
          error: semantic.error,
          surface: semantic.surface,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: semantic.background,
      textTheme: textTheme,
      fontFamily: AppFonts.familyFor(languageCode),
      extensions: [semantic],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: semantic.textPrimary,
        titleTextStyle: textTheme.titleLarge,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: semantic.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget + 8),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: semantic.primary,
          minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget + 8),
          side: BorderSide(color: semantic.primary, width: 1.5),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: semantic.primary,
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
          textStyle: textTheme.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        color: semantic.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: semantic.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
      ),
      dividerTheme: DividerThemeData(color: semantic.divider, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: semantic.surfaceElevated,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

/// Convenience accessor: `AppTheme.of(context)` → current semantic tokens.
extension AppSemanticColorsContext on BuildContext {
  AppSemanticColors get colors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.day;
}
