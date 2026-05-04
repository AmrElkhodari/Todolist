/// Shared design constants (spacing, radii, durations).
class AppDimens {
  AppDimens._();

  // ── Spacing ────────────────────────────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ── Border Radius ──────────────────────────────────────────────────────────
  static const double radiusSm = 10.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;
  static const double radiusFull = 999.0;

  // ── Icon Sizes ─────────────────────────────────────────────────────────────
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;

  // ── Animation Durations ────────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  // ── Bottom Nav Bar ─────────────────────────────────────────────────────────
  static const double bottomNavHeight = 72.0;

  // ── App Bar ────────────────────────────────────────────────────────────────
  static const double appBarHeight = 60.0;
}
