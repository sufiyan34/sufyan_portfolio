import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';

/// Manrope-based type scale, per PORTFOLIO_UI_DESIGN_SPEC.md section 4.
/// Sizes are authored at desktop scale and passed through .sp so
/// ScreenUtil scales them down on tablet/mobile automatically.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.manrope(
      fontSize: size.sp,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Hero / display — 72px desktop, weight 700-800, tight line height.
  static TextStyle display({Color color = AppColors.textPrimary}) => _base(
    size: 72,
    weight: FontWeight.w800,
    color: color,
    letterSpacing: -2.0,
    height: 1.04,
  );

  /// H1 — 52px desktop, weight 700.
  static TextStyle h1({Color color = AppColors.textPrimary}) => _base(
    size: 52,
    weight: FontWeight.w700,
    color: color,
    letterSpacing: -1.0,
    height: 1.08,
  );

  /// H2 — 38px desktop, weight 700.
  static TextStyle h2({Color color = AppColors.textPrimary}) => _base(
    size: 38,
    weight: FontWeight.w700,
    color: color,
    letterSpacing: -0.5,
    height: 1.12,
  );

  /// H3 — 24px desktop, weight 700.
  static TextStyle h3({Color color = AppColors.textPrimary}) =>
      _base(size: 24, weight: FontWeight.w700, color: color, height: 1.2);

  /// Body — 16px, weight 400, line height ~1.65.
  static TextStyle body({Color color = AppColors.textSecondary}) =>
      _base(size: 16, weight: FontWeight.w400, color: color, height: 1.65);

  /// Body, medium weight — for labels/nav items.
  static TextStyle bodyMedium({Color color = AppColors.textPrimary}) =>
      _base(size: 16, weight: FontWeight.w600, color: color, height: 1.4);

  /// Small — 13-14px, line height ~1.45.
  static TextStyle small({Color color = AppColors.textMuted}) =>
      _base(size: 13, weight: FontWeight.w500, color: color, height: 1.45);

  /// Eyebrow / overline label — small, wide letter-spacing, uppercase by convention.
  static TextStyle overline({Color color = AppColors.primary}) => _base(
    size: 13,
    weight: FontWeight.w700,
    color: color,
    letterSpacing: 1.6,
  );

  /// Stat number — used in hero stat row.
  static TextStyle statNumber({Color color = AppColors.textPrimary}) =>
      _base(size: 28, weight: FontWeight.w800, color: color, height: 1.0);
}
