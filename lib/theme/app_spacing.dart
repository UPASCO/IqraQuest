/// Spacing scale, in logical pixels. 4pt base grid.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;

  /// Minimum touch target edge, per WCAG 2.5.5 / platform HIGs.
  static const double minTouchTarget = 48;
}
