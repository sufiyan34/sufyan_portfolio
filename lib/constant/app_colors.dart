import 'package:flutter/material.dart';

/// Sufyan Portfolio brand tokens — warm ivory / deep forest green / muted
/// gold, per PORTFOLIO_UI_DESIGN_SPEC.md. Editorial, calm, premium — not
/// neon, not glassy.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------
  // Public / client surfaces
  // ---------------------------------------------------------------------
  static const Color background = Color(0xFFF8F6F0);
  static const Color surface = Color(0xFFFFFEFB);
  static const Color surfaceSoft = Color(0xFFF3F0E8);
  static const Color surfaceMuted = Color(0xFFECE9DF);

  // ---------------------------------------------------------------------
  // Brand — deep forest green
  // ---------------------------------------------------------------------
  static const Color primary = Color(0xFF0D3B36);
  static const Color primaryDark = Color(0xFF082F2B);
  static const Color primarySoft = Color(0xFFE2ECE9);

  // ---------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------
  static const Color textPrimary = Color(0xFF17201F);
  static const Color textSecondary = Color(0xFF66706C);
  static const Color textMuted = Color(0xFF8A918D);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------
  // Accent — used sparingly, never as a second brand color
  // ---------------------------------------------------------------------
  static const Color accentGold = Color(0xFFD5A43A);
  static const Color accentGoldSoft = Color(0xFFF4E8C8);

  // ---------------------------------------------------------------------
  // Status
  // ---------------------------------------------------------------------
  static const Color success = Color(0xFF2F7D59);
  static const Color warning = Color(0xFFC98B26);
  static const Color danger = Color(0xFFB14A43);
  static const Color info = Color(0xFF47756F);

  // ---------------------------------------------------------------------
  // Borders
  // ---------------------------------------------------------------------
  static const Color border = Color(0xFFE6E2D9);
  static const Color borderDarkAdmin = Color(
    0x14FFFFFF,
  ); // rgba(255,255,255,0.08)

  // ---------------------------------------------------------------------
  // Admin sidebar surface
  // ---------------------------------------------------------------------
  static const Color adminSidebar = primary;
  static const Color adminSidebarDeep = primaryDark;

  // ---------------------------------------------------------------------
  // Shadows — soft, never colored/glowing
  // ---------------------------------------------------------------------
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF222A27).withValues(alpha: 0.06),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> featureShadow = [
    BoxShadow(
      color: const Color(0xFF222A27).withValues(alpha: 0.08),
      blurRadius: 50,
      offset: const Offset(0, 16),
    ),
  ];
}
