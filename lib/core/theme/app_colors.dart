import 'package:flutter/material.dart';

/// All color tokens for the app.
/// Inspired by the uiux_theme.png: soft whites, deep purple primaries,
/// and pastel mint/pink/blue accents.
class AppColors {
  AppColors._();

  // ── Primary ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF3D3A7C);       // Deep indigo-purple
  static const Color primaryLight = Color(0xFF6C63FF);  // Vibrant purple accent
  static const Color primaryPastel = Color(0xFFEBEAFF); // Soft lavender tint

  // ── Pastel Accents (folder/tag colours) ───────────────────────────────────
  static const Color accentMint = Color(0xFF72D9C7);    // Mint green
  static const Color accentMintPastel = Color(0xFFDFF7F3);
  static const Color accentPink = Color(0xFFF07C8A);    // Soft coral-pink
  static const Color accentPinkPastel = Color(0xFFFFE8EB);
  static const Color accentBlue = Color(0xFF6BB5F8);    // Sky blue
  static const Color accentBluePastel = Color(0xFFE1F1FF);
  static const Color accentOrange = Color(0xFFFFA552);  // Warm orange
  static const Color accentOrangePastel = Color(0xFFFFF0E0);

  // ── Light Mode Surface ─────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF6F5FF); // Airy lavender-white
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFECEBF5);

  // ── Dark Mode Surface ──────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF12111E); // Deep near-black
  static const Color surfaceDark = Color(0xFF1D1C2E);
  static const Color cardDark = Color(0xFF252438);
  static const Color dividerDark = Color(0xFF2E2D42);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF1E1B4B);
  static const Color textSecondaryLight = Color(0xFF6B6B8A);
  static const Color textPrimaryDark = Color(0xFFF0EFFB);
  static const Color textSecondaryDark = Color(0xFF9896B8);

  // ── Utility ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4ECBA8);
  static const Color warning = Color(0xFFFFC84A);
  static const Color error = Color(0xFFFF5C72);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
