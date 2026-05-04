import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Reusable shadow presets.
/// The uiux_theme.png uses soft, multi-layered neumorphic shadows —
/// not harsh, but visible enough to lift elements off the background.
class AppShadows {
  AppShadows._();

  /// Subtle shadow for cards and list tiles.
  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.07),
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.04),
          blurRadius: 6,
          spreadRadius: 0,
          offset: const Offset(0, 1),
        ),
      ];

  /// Stronger shadow for floating action buttons and bottom sheets.
  static List<BoxShadow> get floating => [
        BoxShadow(
          color: AppColors.primaryLight.withValues(alpha: 0.22),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
      ];

  /// Very light shadow for input fields (gives a lifted feel).
  static List<BoxShadow> get input => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.06),
          blurRadius: 10,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        ),
      ];

  /// Dark mode equivalents — slightly more transparent.
  static List<BoxShadow> get cardDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];
}
