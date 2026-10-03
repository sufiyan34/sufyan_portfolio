import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/skill_model.dart';
import 'package:sufyan_portfolio/widgets/skill_icon.dart';

/// Card colour + a deliberately *different* border colour.
/// The palette is picked from the skill category so every skill in the same
/// category shares a look.
class _Palette {
  final Color background;
  final Color backgroundAlt;
  final Color border;
  final Color foreground;
  final Color secondary;
  final Color accent;
  final Color onAccent;

  const _Palette({
    required this.background,
    required this.backgroundAlt,
    required this.border,
    required this.foreground,
    required this.secondary,
    required this.accent,
    required this.onAccent,
  });

  static const _ink = Color(0xFF111413);

  static _Palette forKey(String key) {
    var sum = 0;
    for (final unit in key.trim().toLowerCase().codeUnits) {
      sum += unit;
    }
    switch (sum % 4) {
      case 0: // green card, golden border
        return _Palette(
          background: AppColors.primary,
          backgroundAlt: AppColors.primaryDark,
          border: AppColors.accentGold,
          foreground: Colors.white,
          secondary: Colors.white.withValues(alpha: 0.74),
          accent: AppColors.accentGold,
          onAccent: AppColors.textPrimary,
        );
      case 1: // golden card, green border
        return _Palette(
          background: AppColors.accentGoldSoft,
          backgroundAlt: const Color(0xFFEBD28F),
          border: AppColors.primary,
          foreground: AppColors.textPrimary,
          secondary: AppColors.textPrimary.withValues(alpha: 0.72),
          accent: AppColors.primary,
          onAccent: Colors.white,
        );
      case 2: // ivory card, black border
        return _Palette(
          background: const Color(0xFFFBFAF6),
          backgroundAlt: const Color(0xFFE9EAE6),
          border: _ink,
          foreground: AppColors.textPrimary,
          secondary: AppColors.textSecondary,
          accent: _ink,
          onAccent: Colors.white,
        );
      default: // black card, mint border
        return _Palette(
          background: _ink,
          backgroundAlt: const Color(0xFF1E2523),
          border: const Color(0xFF3FB68B),
          foreground: Colors.white,
          secondary: Colors.white.withValues(alpha: 0.72),
          accent: const Color(0xFF3FB68B),
          onAccent: _ink,
        );
    }
  }
}

class SkillCard extends StatefulWidget {
  final SkillModel skill;

  /// Optional grid position, only used to stagger the entrance animation.
  final int index;

  const SkillCard({super.key, required this.skill, this.index = 0});

  @override
  State<SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<SkillCard> with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _meter;
  late final AnimationController _shimmer;

  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _meter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    Future.delayed(Duration(milliseconds: 80 * (widget.index % 6)), () {
      if (!mounted) return;
      _entrance.forward();
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) _meter.forward();
      });
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _meter.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  void _setHover(bool value) {
    setState(() => _hovered = value);
    if (value) {
      _shimmer.forward(from: 0);
      _meter.forward(from: 0); // re-sweep the meter
    }
  }

  static String _level(int p) {
    if (p >= 90) return 'EXPERT';
    if (p >= 75) return 'ADVANCED';
    if (p >= 50) return 'PROFICIENT';
    return 'LEARNING';
  }

  @override
  Widget build(BuildContext context) {
    final skill = widget.skill;
    final palette = _Palette.forKey(skill.category);
    final borderWidth = 4.w;

    // Mirror of the package card: top-right + bottom-left are the big corners.
    final big = 34.r;
    final small = 7.r;

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => _setHover(true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -7 : 0, 0),
        child: AnimatedBuilder(
          animation: _entrance,
          builder: (context, child) {
            final enter = Curves.easeOutBack.transform(_entrance.value);
            final angle = (1 - enter) * (math.pi / 2.4);
            return Opacity(
              opacity: _entrance.value.clamp(0.0, 1.0),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0011)
                  ..rotateX(angle),
                child: child,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(big),
                bottomLeft: Radius.circular(big),
                topLeft: Radius.circular(small),
                bottomRight: Radius.circular(small),
              ),
              border: Border.all(color: palette.border, width: borderWidth),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [palette.background, palette.backgroundAlt],
              ),
              boxShadow: [
                BoxShadow(
                  color: palette.border.withValues(
                    alpha: _hovered ? 0.38 : 0.15,
                  ),
                  blurRadius: _hovered ? 30 : 18,
                  offset: Offset(_hovered ? -7 : -4, _hovered ? 14 : 9),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(math.max(0, big - borderWidth)),
                bottomLeft: Radius.circular(math.max(0, big - borderWidth)),
                topLeft: Radius.circular(math.max(0, small - borderWidth)),
                bottomRight: Radius.circular(math.max(0, small - borderWidth)),
              ),
              child: Stack(
                children: [
                  // Oversized icon watermark.
                  Positioned(
                    right: -8.w,
                    bottom: -10.h,
                    child: IgnorePointer(
                      child: Icon(
                        skillIconFor(skill.icon),
                        size: 110.sp,
                        color: palette.foreground.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // Light sweep on hover.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _shimmer,
                        builder: (context, _) {
                          final t = _shimmer.value;
                          if (t == 0 || t == 1) return const SizedBox.shrink();
                          final pos = -0.4 + t * 1.8;
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.22),
                                  Colors.white.withValues(alpha: 0),
                                ],
                                stops: [
                                  (pos - 0.12).clamp(0.0, 1.0),
                                  pos.clamp(0.0, 1.0),
                                  (pos + 0.12).clamp(0.0, 1.0),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 22.w, 18.h),
                    child: _content(skill, palette),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(SkillModel skill, _Palette palette) {
    final proficiency = skill.proficiency.clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge tilts on hover.
            AnimatedRotation(
              turns: _hovered ? -0.03 : 0,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              child: AnimatedScale(
                scale: _hovered ? 1.1 : 1,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                child: Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: palette.accent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                      topRight: Radius.circular(4.r),
                      bottomLeft: Radius.circular(4.r),
                    ),
                  ),
                  child: Icon(
                    skillIconFor(skill.icon),
                    color: palette.onAccent,
                    size: 22.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.name,
                    style: AppTextStyles.h3(color: palette.foreground)
                        .copyWith(fontSize: 19.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: palette.accent, width: 1.3),
                    ),
                    child: Text(
                      skill.category,
                      style: AppTextStyles.small(color: palette.foreground)
                          .copyWith(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Text(
          skill.description.isEmpty
              ? 'Practical, production-focused implementation with clean and maintainable code.'
              : skill.description,
          style: AppTextStyles.small(color: palette.secondary)
              .copyWith(height: 1.55),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        SizedBox(height: 12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: palette.accent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(9.r),
                  bottomRight: Radius.circular(9.r),
                  topRight: Radius.circular(2.r),
                  bottomLeft: Radius.circular(2.r),
                ),
              ),
              child: Text(
                _level(proficiency),
                style: AppTextStyles.small(color: palette.onAccent).copyWith(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _meter,
              builder: (context, _) {
                final shown =
                    (proficiency * Curves.easeOut.transform(_meter.value))
                        .round();
                return Text(
                  '$shown%',
                  style: AppTextStyles.h3(color: palette.foreground)
                      .copyWith(fontSize: 22.sp, fontWeight: FontWeight.w900),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 9.h),
        // 10-segment meter that lights up one block at a time.
        AnimatedBuilder(
          animation: _meter,
          builder: (context, _) {
            final lit = proficiency / 10.0;
            final progress = _meter.value * 10.0;
            return Row(
              children: List.generate(10, (i) {
                final target = (lit - i).clamp(0.0, 1.0);
                final reveal = (progress - i).clamp(0.0, 1.0);
                final fill = target * reveal;
                return Expanded(
                  child: Container(
                    height: 9.h,
                    margin: EdgeInsets.only(right: i == 9 ? 0 : 3.w),
                    decoration: BoxDecoration(
                      color: palette.foreground.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4.r),
                        bottomRight: Radius.circular(4.r),
                        topRight: Radius.circular(1.r),
                        bottomLeft: Radius.circular(1.r),
                      ),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: fill,
                      heightFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: palette.accent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4.r),
                            bottomRight: Radius.circular(4.r),
                            topRight: Radius.circular(1.r),
                            bottomLeft: Radius.circular(1.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}
