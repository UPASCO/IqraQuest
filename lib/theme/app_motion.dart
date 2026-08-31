import 'package:flutter/material.dart';

/// The motion vocabulary of IqraQuest (DESIGN_SYSTEM.md §6).
///
/// Every animated widget picks its timing from here, never ad hoc, so
/// the whole app moves at one rhythm. Durations follow mobile game
/// practice: taps are instant, feedback is quick, only rewards are
/// allowed to breathe.
class AppMotion {
  const AppMotion._();

  /// Pressing something: 80-120ms.
  static const Duration tap = Duration(milliseconds: 100);

  /// Micro feedback (a selection ring, a chip appearing): 150-250ms.
  static const Duration micro = Duration(milliseconds: 200);

  /// Answer resolution (tile turns correct/incorrect): 300-500ms.
  static const Duration answer = Duration(milliseconds: 400);

  /// A reward moment (points chip, streak unlock): 500-900ms.
  static const Duration reward = Duration(milliseconds: 700);

  /// Screen-to-screen transition: 250-400ms.
  static const Duration screen = Duration(milliseconds: 300);

  /// One hop of the horse from square to square. A move of n squares
  /// takes n hops, capped by [moveMax] so long moves stay brisk.
  static const Duration hopPerCell = Duration(milliseconds: 170);
  static const Duration moveMax = Duration(milliseconds: 950);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve settle = Curves.easeOutBack;

  /// Honors the OS/app Reduce Motion setting: a zero duration makes any
  /// implicit animation snap.
  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}
