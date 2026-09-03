import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Light status- and navigation-bar icons, for the screens drawn on the
/// app's dark ground.
///
/// Android decides the colour of the clock, the battery and the nav bar
/// glyphs from what the app declares, not from what it paints — and it
/// declares nothing by default. On a deep green board that means the
/// system's dark icons on a dark ground: a clock nobody can read, and on
/// Android 15, where every app is edge-to-edge, a navigation bar sitting
/// in its own opaque strip instead of over the art.
///
/// Material sets this for screens that have an AppBar. The screens that
/// do not — the home, the welcome, the board, the results — wrap
/// themselves in this instead. iOS reads the same declaration for its
/// status bar, so one line serves both platforms.
class DarkSystemBars extends StatelessWidget {
  const DarkSystemBars({super.key, required this.child});

  final Widget child;

  static const SystemUiOverlayStyle style = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, // Android
    statusBarBrightness: Brightness.dark, // iOS
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  @override
  Widget build(BuildContext context) =>
      AnnotatedRegion<SystemUiOverlayStyle>(value: style, child: child);
}
