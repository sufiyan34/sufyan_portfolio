import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';

/// Shown by the admin upload fields when Cloudinary isn't configured, so the
/// missing drag-and-drop / browse zone is explained instead of silently
/// replaced by a plain URL box.
class CloudinarySetupNote extends StatelessWidget {
  const CloudinarySetupNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.accentGoldSoft,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Iconsax.info_circle, size: 18.sp, color: AppColors.warning),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Uploads need a Cloudinary account. Cloudinary isn\'t configured yet, so '
              'files you add here will not upload. Run the app with\n'
              '--dart-define=CLOUDINARY_CLOUD_NAME=<your cloud name>\n'
              '--dart-define=CLOUDINARY_UNSIGNED_PRESET=<your unsigned preset>\n'
              'or set kCloudinaryCloudName / kCloudinaryUnsignedPreset in '
              'services/cloudinary/cloudinary_config.dart, then restart.',
              style: AppTextStyles.small(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
