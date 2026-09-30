import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/package_model.dart';

class PackageCard extends StatefulWidget {
  final PackageModel package;

  const PackageCard({super.key, required this.package});

  @override
  State<PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<PackageCard> {
  bool _hovered = false;

  bool get _isDark => PackageTypes.normalize(widget.package.type) == PackageTypes.platinum;
  bool get _isGold => PackageTypes.normalize(widget.package.type) == PackageTypes.gold;
  bool get _isCustom => PackageTypes.normalize(widget.package.type) == PackageTypes.custom;

  Color get _background {
    if (_isDark) return AppColors.primary;
    if (_isGold) return AppColors.accentGoldSoft;
    if (_isCustom) return AppColors.surfaceSoft;
    return AppColors.surface;
  }

  Color get _foreground => _isDark ? AppColors.textOnPrimary : AppColors.textPrimary;
  Color get _secondary => _isDark
      ? AppColors.textOnPrimary.withValues(alpha: 0.72)
      : AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    final package = widget.package;
    final type = PackageTypes.normalize(package.type);

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -5 : 0, 0),
        padding: EdgeInsets.all(23.w),
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: _isDark
                ? AppColors.primary
                : _isGold
                    ? AppColors.accentGold.withValues(alpha: 0.55)
                    : _isCustom
                        ? AppColors.primary.withValues(alpha: 0.22)
                        : AppColors.border,
            width: _isCustom ? 1.2 : 1,
          ),
          boxShadow: _hovered ? AppColors.featureShadow : AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PackageTypes.label(type).toUpperCase(),
                        style: AppTextStyles.overline(
                          color: _isDark ? AppColors.accentGold : AppColors.primary,
                        ).copyWith(fontSize: 10.5.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        package.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h3(color: _foreground),
                      ),
                    ],
                  ),
                ),
                if (package.featured)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _isDark
                          ? AppColors.accentGold
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _isDark ? AppColors.accentGold : AppColors.border,
                      ),
                    ),
                    child: Text(
                      'Featured',
                      style: AppTextStyles.small(color: AppColors.textPrimary)
                          .copyWith(fontSize: 10.sp, fontWeight: FontWeight.w800),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              PackageTypes.descriptor(type),
              style: AppTextStyles.small(color: _secondary).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 14.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_isCustom && package.price <= 0)
                  Text(
                    'Custom quote',
                    style: AppTextStyles.h3(color: _foreground).copyWith(fontSize: 22.sp),
                  )
                else ...[
                  Text(
                    _formatPrice(package.price),
                    style: AppTextStyles.h2(color: _foreground).copyWith(fontSize: 32.sp),
                  ),
                  SizedBox(width: 7.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(
                      package.currency.toUpperCase(),
                      style: AppTextStyles.small(color: _secondary).copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 4.h),
            Text(package.pricingNote, style: AppTextStyles.small(color: _secondary)),
            SizedBox(height: 17.h),
            Text(
              package.shortDescription,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(color: _secondary).copyWith(fontSize: 13.2.sp),
            ),
            SizedBox(height: 18.h),
            _MetaRow(
              icon: Icons.schedule_rounded,
              label: package.deliveryDays <= 0
                  ? 'Timeline discussed'
                  : '${package.deliveryDays} day delivery',
              foreground: _foreground,
              secondary: _secondary,
            ),
            SizedBox(height: 8.h),
            _MetaRow(
              icon: Icons.refresh_rounded,
              label: package.revisions <= 0
                  ? 'Revision scope discussed'
                  : '${package.revisions} revisions',
              foreground: _foreground,
              secondary: _secondary,
            ),
            SizedBox(height: 18.h),
            if (package.features.isNotEmpty) ...[
              Text(
                'Included',
                style: AppTextStyles.bodyMedium(color: _foreground).copyWith(fontSize: 13.5.sp),
              ),
              SizedBox(height: 10.h),
              ...package.features.take(5).map(
                    (feature) => Padding(
                      padding: EdgeInsets.only(bottom: 9.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 16.sp,
                            color: _isGold ? AppColors.primary : AppColors.accentGold,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              feature,
                              style: AppTextStyles.small(color: _secondary).copyWith(height: 1.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
            const Spacer(),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(
                  AppRoutes.hireUs,
                  arguments: {
                    'packageId': package.id,
                    'packageTitle': package.title,
                    'packageType': package.type,
                  },
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDark ? AppColors.accentGold : AppColors.primary,
                  foregroundColor: _isDark ? AppColors.textPrimary : AppColors.textOnPrimary,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  package.ctaLabel.isEmpty ? 'Choose Package' : package.ctaLabel,
                  style: AppTextStyles.bodyMedium(
                    color: _isDark ? AppColors.textPrimary : AppColors.textOnPrimary,
                  ).copyWith(fontSize: 13.2.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color foreground;
  final Color secondary;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17.sp, color: foreground.withValues(alpha: 0.74)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(label, style: AppTextStyles.small(color: secondary)),
        ),
      ],
    );
  }
}
