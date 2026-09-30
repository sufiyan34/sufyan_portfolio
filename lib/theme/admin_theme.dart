import 'package:flutter/material.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';

/// Admin-screen tokens, kept as their own small API (`AdminColors`,
/// `AdminText`) so existing admin widgets (e.g. MediaUploadZone) don't need
/// call-site changes, but every value below now points at the SAME brand
/// tokens as the public site (`AppColors` / `AppTextStyles`) instead of an
/// unrelated palette. Prefer `AppColors`/`AppTextStyles` directly in new
/// admin screens; this file exists for the handful of older widgets still
/// written against `AdminColors`/`AdminText`.
class AdminColors {
  AdminColors._();

  static const ink = AppColors.textPrimary;
  static const inkSoft = AppColors.textSecondary;
  static const muted = AppColors.textMuted;
  static const line = AppColors.border;
  static const canvas = AppColors.surfaceSoft;
  static const surface = AppColors.surface;

  static const brass = AppColors.primary;
  static const brassDark = AppColors.primaryDark;
  static const brassTint = AppColors.primarySoft;

  static const success = AppColors.success;
  static const successTint = Color(0xFFE4F2E9);
  static const danger = AppColors.danger;
  static const dangerTint = Color(0xFFFBEAE3);
  static const warn = AppColors.warning;
  static const warnTint = Color(0xFFFBF1DD);

  /// On-brand swatches (forest green / gold / muted earth) for
  /// deterministic thumbnail placeholders — replaces the old
  /// purple/plum swatch set.
  static const swatches = <Color>[
    AppColors.primary,
    AppColors.accentGold,
    Color(0xFF47756F),
    Color(0xFF8A6D3B),
    AppColors.primaryDark,
    Color(0xFF6E7F6B),
    Color(0xFFB08D3E),
    Color(0xFF3F5A4E),
  ];

  /// Deterministic colour for a thumbnail swatch, so the same name always
  /// gets the same colour without needing real photography.
  static Color swatchFor(String seed) {
    var hash = 0;
    for (final unit in seed.codeUnits) {
      hash = (hash * 31 + unit) % swatches.length;
    }
    return swatches[hash.abs() % swatches.length];
  }
}

/// Manrope throughout — same family as the public site
/// (see AppTextStyles) — no second display typeface for admin.
class AdminText {
  AdminText._();

  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w700,
    Color color = AdminColors.ink,
  }) => AppTextStyles.h3(color: color).copyWith(fontSize: size, fontWeight: weight);

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AdminColors.ink,
  }) => AppTextStyles.body(color: color).copyWith(fontSize: size, fontWeight: weight);
}

/// Small helper for initials shown inside a colour swatch when there's no
/// product/category photo yet.
String initialsFor(String name) =>
    name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
