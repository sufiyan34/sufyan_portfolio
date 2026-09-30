import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/experience_model.dart';

class ExperienceTimelineCard extends StatefulWidget {
  final ExperienceModel experience;
  final bool isLast;
  final int index;

  const ExperienceTimelineCard({
    super.key,
    required this.experience,
    required this.isLast,
    required this.index,
  });

  @override
  State<ExperienceTimelineCard> createState() => _ExperienceTimelineCardState();
}

class _ExperienceTimelineCardState extends State<ExperienceTimelineCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final experience = widget.experience;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: isWide ? 120.w : 66.w,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: _hovered ? AppColors.primary : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _hovered ? AppColors.primary : AppColors.border,
                      ),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Icon(
                      experience.isCurrent ? Iconsax.flash_1 : Iconsax.briefcase,
                      size: 18.sp,
                      color: _hovered
                          ? AppColors.textOnPrimary
                          : AppColors.primary,
                    ),
                  ),
                  if (!widget.isLast)
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 7.h),
                        width: 1.5.w,
                        color: AppColors.border,
                      ),
                    ),
                ],
              ),
            ),
            if (isWide)
              SizedBox(
                width: 18.w,
                child: Padding(
                  padding: EdgeInsets.only(top: 13.h),
                  child: Text(
                    experience.startDate,
                    style: AppTextStyles.small(color: AppColors.textMuted)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            SizedBox(width: 12.w),
            Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
              margin: EdgeInsets.only(bottom: 20.h),
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: _hovered
                      ? AppColors.primary.withValues(alpha: 0.28)
                      : AppColors.border,
                ),
                boxShadow: _hovered
                    ? AppColors.featureShadow
                    : AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _Pill(
                        label: experience.employmentType,
                        background: AppColors.primarySoft,
                        foreground: AppColors.primary,
                      ),
                      if (experience.isCurrent)
                        _Pill(
                          label: 'Current',
                          background: AppColors.accentGoldSoft,
                          foreground: AppColors.primary,
                        ),
                      if (experience.featured)
                        _Pill(
                          label: 'Featured',
                          background: AppColors.surfaceSoft,
                          foreground: AppColors.textSecondary,
                        ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              experience.role,
                              style: AppTextStyles.h3().copyWith(fontSize: 22.sp),
                            ),
                            SizedBox(height: 5.h),
                            Row(
                              children: [
                                Icon(
                                  Iconsax.building_4,
                                  size: 15.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 5.w),
                                Flexible(
                                  child: Text(
                                    experience.company,
                                    style: AppTextStyles.bodyMedium(
                                      color: AppColors.primary,
                                    ).copyWith(fontSize: 14.sp),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isWide && experience.location.isNotEmpty)
                        _LocationPill(location: experience.location),
                    ],
                  ),
                  if (!isWide && experience.dateRange.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    Text(
                      experience.dateRange,
                      style: AppTextStyles.small(color: AppColors.textMuted)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                  if (experience.description.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    Text(
                      experience.description,
                      style: AppTextStyles.body().copyWith(height: 1.7),
                    ),
                  ],
                  if (experience.achievements.isNotEmpty) ...[
                    SizedBox(height: 18.h),
                    Text(
                      'Key contributions',
                      style: AppTextStyles.bodyMedium().copyWith(fontSize: 13.sp),
                    ),
                    SizedBox(height: 9.h),
                    ...experience.achievements.take(4).map(
                          (item) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  margin: EdgeInsets.only(top: 7.h),
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentGold,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: AppTextStyles.small(
                                      color: AppColors.textSecondary,
                                    ).copyWith(height: 1.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                  if (experience.technologies.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 7.w,
                      runSpacing: 7.h,
                      children: experience.technologies
                          .take(8)
                          .map(
                            (technology) => _TechChip(label: technology),
                          )
                          .toList(),
                    ),
                  ],
                  if (experience.location.isNotEmpty && isWide == false) ...[
                    SizedBox(height: 12.h),
                    _LocationPill(location: experience.location),
                  ],
                ],
              ),
            )
                .animate()
                .fadeIn(
                  duration: 500.ms,
                  delay: (widget.index * 80).ms,
                )
                .slideY(begin: 0.04, end: 0),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.small(color: foreground).copyWith(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LocationPill extends StatelessWidget {
  final String location;
  const _LocationPill({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.location, size: 13.sp, color: AppColors.textMuted),
          SizedBox(width: 5.w),
          Text(
            location,
            style: AppTextStyles.small(color: AppColors.textSecondary).copyWith(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  const _TechChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTextStyles.small(color: AppColors.textSecondary).copyWith(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
