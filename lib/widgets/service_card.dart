import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/service_model.dart';
import 'package:sufyan_portfolio/widgets/service_icon.dart';

class ServiceCard extends StatefulWidget {
  final ServiceModel service;

  const ServiceCard({super.key, required this.service});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: EdgeInsets.all(22.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: _hovered
                ? AppColors.primary.withValues(alpha: 0.32)
                : AppColors.border,
          ),
          boxShadow: _hovered ? AppColors.featureShadow : AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ServiceIconBadge(iconKey: service.icon),
                const Spacer(),
                if (service.featured)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.accentGoldSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Featured',
                      style: AppTextStyles.small(color: AppColors.textPrimary)
                          .copyWith(fontSize: 10.sp, fontWeight: FontWeight.w800),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 18.h),
            Text(
              service.category.toUpperCase(),
              style: AppTextStyles.overline().copyWith(fontSize: 10.5.sp),
            ),
            SizedBox(height: 8.h),
            Text(service.title, style: AppTextStyles.h3()),
            SizedBox(height: 7.h),
            Text(
              service.shortDescription,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body().copyWith(fontSize: 13.5.sp, height: 1.6),
            ),
            SizedBox(height: 16.h),
            if (service.features.isNotEmpty)
              ...service.features.take(3).map(
                    (feature) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            margin: EdgeInsets.only(top: 6.h),
                            decoration: const BoxDecoration(
                              color: AppColors.accentGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 9.w),
                          Expanded(
                            child: Text(
                              feature,
                              style: AppTextStyles.small(color: AppColors.textPrimary)
                                  .copyWith(height: 1.55, fontSize: 12.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            const Spacer(),
            if (service.technologies.isNotEmpty)
              Wrap(
                spacing: 7.w,
                runSpacing: 7.h,
                children: service.technologies.take(4).map((tech) {
                  return ServiceMetaPill(label: tech);
                }).toList(),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 350));
  }
}
