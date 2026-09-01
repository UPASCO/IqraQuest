import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic color tokens (light + dark "night oasis" variant), exposed as a
/// [ThemeExtension] so widgets never reach for raw [AppColors] values.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.goldAccent,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.error,
    required this.warning,
    required this.player1,
    required this.player2,
    required this.player3,
    required this.player4,
    required this.divider,
    required this.protectedSquare,
    required this.onScene,
    required this.onSceneDim,
  });

  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color goldAccent;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color error;
  final Color warning;
  final Color player1;
  final Color player2;
  final Color player3;
  final Color player4;
  final Color divider;
  final Color protectedSquare;

  /// Text and icons drawn directly on a painted scene (the board diorama,
  /// the onboarding hero). A scene is dark in BOTH themes, so these do
  /// not flip with day/night the way [textPrimary] does — using
  /// [textPrimary] over a scene is what made those screens unreadable.
  final Color onScene;
  final Color onSceneDim;

  static const AppSemanticColors day = AppSemanticColors(
    primary: AppColors.emerald,
    primaryDark: AppColors.deepEmerald,
    secondary: AppColors.terracotta,
    goldAccent: AppColors.softGold,
    background: AppColors.desertIvory,
    surface: AppColors.warmCream,
    surfaceElevated: Colors.white,
    textPrimary: AppColors.neutralInk,
    textSecondary: AppColors.neutralMist,
    success: AppColors.success,
    error: AppColors.error,
    warning: AppColors.warning,
    player1: AppColors.player1Emerald,
    player2: AppColors.player2Saphir,
    player3: AppColors.player3Grenat,
    player4: AppColors.player4Safran,
    divider: Color(0x1F1B1712),
    protectedSquare: AppColors.softGold,
    onScene: Color(0xFFF6EFE0),
    onSceneDim: Color(0xCCE4D9BF),
  );

  static const AppSemanticColors night = AppSemanticColors(
    primary: AppColors.emerald,
    primaryDark: AppColors.deepEmerald,
    secondary: AppColors.sand,
    goldAccent: AppColors.softGold,
    background: AppColors.deepNight,
    surface: AppColors.midnightBlue,
    surfaceElevated: Color(0xFF1C3348),
    textPrimary: AppColors.desertIvory,
    textSecondary: Color(0xFFAEB9C4),
    success: Color(0xFF4CAF77),
    error: Color(0xFFE07056),
    warning: Color(0xFFD99A4C),
    player1: Color(0xFF35A583),
    player2: Color(0xFF4A87C4),
    player3: Color(0xFFC1546A),
    player4: Color(0xFFDDA24C),
    divider: Color(0x24F7F0DF),
    protectedSquare: AppColors.softGold,
    onScene: Color(0xFFF6EFE0),
    onSceneDim: Color(0xCCE4D9BF),
  );

  @override
  AppSemanticColors copyWith({
    Color? primary,
    Color? primaryDark,
    Color? secondary,
    Color? goldAccent,
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? error,
    Color? warning,
    Color? player1,
    Color? player2,
    Color? player3,
    Color? player4,
    Color? divider,
    Color? protectedSquare,
    Color? onScene,
    Color? onSceneDim,
  }) {
    return AppSemanticColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      secondary: secondary ?? this.secondary,
      goldAccent: goldAccent ?? this.goldAccent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      player1: player1 ?? this.player1,
      player2: player2 ?? this.player2,
      player3: player3 ?? this.player3,
      player4: player4 ?? this.player4,
      divider: divider ?? this.divider,
      protectedSquare: protectedSquare ?? this.protectedSquare,
      onScene: onScene ?? this.onScene,
      onSceneDim: onSceneDim ?? this.onSceneDim,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      player1: Color.lerp(player1, other.player1, t)!,
      player2: Color.lerp(player2, other.player2, t)!,
      player3: Color.lerp(player3, other.player3, t)!,
      player4: Color.lerp(player4, other.player4, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      protectedSquare: Color.lerp(protectedSquare, other.protectedSquare, t)!,
      onScene: Color.lerp(onScene, other.onScene, t)!,
      onSceneDim: Color.lerp(onSceneDim, other.onSceneDim, t)!,
    );
  }
}
