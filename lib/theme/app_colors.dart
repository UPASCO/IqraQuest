import 'package:flutter/material.dart';

/// IqraQuest design tokens — color palette.
///
/// Do not use raw color literals in feature/widget code. Reference these
/// tokens (or [AppTheme.of(context)] semantic aliases) so the palette stays
/// centrally editable. See DESIGN_SYSTEM.md for rationale.
class AppColors {
  const AppColors._();

  // Base palette (see DESIGN_SYSTEM.md §Palette)
  static const Color emerald = Color(0xFF0E6B52);
  static const Color deepEmerald = Color(0xFF084C3A);
  static const Color midnightBlue = Color(0xFF14283D);
  static const Color deepNight = Color(0xFF0D1A29);
  static const Color softGold = Color(0xFFC89B45);
  static const Color sand = Color(0xFFD9BD82);
  static const Color warmCream = Color(0xFFF7F0DF);
  static const Color desertIvory = Color(0xFFFFF9ED);
  static const Color terracotta = Color(0xFFA86443);
  static const Color datePalm = Color(0xFF497351);

  // Feedback
  static const Color success = Color(0xFF2E8B57);
  static const Color successDark = Color(0xFF1F5C3A);
  static const Color error = Color(0xFFB3432D);
  static const Color errorDark = Color(0xFF7A2C1D);
  static const Color warning = Color(0xFFC17D2E);

  // Player team colors — paired with a distinct symbol, never color-only
  // (see AppTeam), keeping the palette colorblind-safe.
  static const Color player1Emerald = Color(0xFF0E6B52); // Team Émeraude
  static const Color player2Saphir = Color(0xFF1E5B8C); // Team Saphir
  static const Color player3Grenat = Color(0xFF8C2A3D); // Team Grenat
  static const Color player4Safran = Color(0xFFC17A1F); // Team Safran

  static const Color neutralInk = Color(0xFF1B1712);
  static const Color neutralMist = Color(0xFF8A8072);
}
