import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';

/// JSON-safe icon registry used by both admin and public skill UIs.
IconData skillIconFor(String key) {
  switch (key) {
    case 'phone':
      return Icons.phone_android_rounded;
    case 'web':
      return Icons.language_rounded;
    case 'backend':
      return Icons.dns_rounded;
    case 'database':
      return Icons.storage_rounded;
    case 'firebase':
      return Icons.local_fire_department_rounded;
    case 'design':
      return Icons.auto_awesome_rounded;
    case 'api':
      return Icons.integration_instructions_rounded;
    case 'git':
      return Icons.account_tree_rounded;
    case 'cloud':
      return Icons.cloud_queue_rounded;
    case 'testing':
      return Icons.verified_rounded;
    case 'architecture':
      return Icons.account_tree_outlined;
    case 'tools':
      return Icons.build_circle_outlined;
    default:
      return Icons.code_rounded;
  }
}

class SkillIconBadge extends StatelessWidget {
  final String iconKey;
  final double size;
  final bool compact;

  const SkillIconBadge({
    super.key,
    required this.iconKey,
    this.size = 48,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final dimension = compact ? size * 0.82 : size;
    return Container(
      width: dimension.w,
      height: dimension.w,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(compact ? 12.r : 14.r),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Icon(
        skillIconFor(iconKey),
        color: AppColors.primary,
        size: (compact ? 20 : 22).sp,
      ),
    );
  }
}
