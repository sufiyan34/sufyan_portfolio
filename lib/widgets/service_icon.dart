import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';

/// Maps JSON-safe icon keys from Firebase to Material icons.
class ServiceIconBadge extends StatelessWidget {
  final String iconKey;
  final bool compact;
  final double size;

  const ServiceIconBadge({
    super.key,
    required this.iconKey,
    this.compact = false,
    this.size = 52,
  });

  static const _icons = <String, IconData>{
    'phone_android': Icons.phone_android_rounded,
    'web': Icons.language_rounded,
    'backend': Icons.dns_rounded,
    'api': Icons.api_rounded,
    'business': Icons.business_center_rounded,
    'design': Icons.auto_awesome_rounded,
    'firebase': Icons.local_fire_department_rounded,
    'database': Icons.storage_rounded,
    'code': Icons.code_rounded,
    'cloud': Icons.cloud_rounded,
    'security': Icons.shield_rounded,
    'support': Icons.handshake_rounded,
  };

  static IconData resolve(String key) => _icons[key] ?? Icons.design_services_rounded;

  @override
  Widget build(BuildContext context) {
    final boxSize = (compact ? size * 0.88 : size).w;
    final iconSize = (compact ? 21 : 24).sp;

    return Container(
      width: boxSize,
      height: boxSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular((compact ? 14 : 16).r),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(
        resolve(iconKey),
        size: iconSize,
        color: AppColors.primary,
      ),
    );
  }

  static List<String> get options => _icons.keys.toList(growable: false);
}

class ServiceIconOption extends StatelessWidget {
  final String iconKey;
  final bool selected;
  final VoidCallback onTap;

  const ServiceIconOption({
    super.key,
    required this.iconKey,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: iconKey.replaceAll('_', ' '),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 54.w,
          height: 54.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Icon(
            ServiceIconBadge.resolve(iconKey),
            size: 21.sp,
            color: selected ? AppColors.textOnPrimary : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class ServiceMetaPill extends StatelessWidget {
  final String label;
  final IconData? icon;

  const ServiceMetaPill({
    super.key,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14.sp, color: AppColors.textMuted),
            SizedBox(width: 6.w),
          ],
          Text(
            label,
            style: AppTextStyles.small(color: AppColors.textSecondary).copyWith(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
