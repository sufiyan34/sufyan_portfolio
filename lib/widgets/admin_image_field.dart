import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_models.dart';
import 'package:sufyan_portfolio/utills/cloudinary_registry.dart';
import 'package:sufyan_portfolio/utills/media_upload_zone.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';

/// "Current image + upload zone" field. Writes the uploaded file's URL into
/// [controller]. Falls back to a plain URL field when Cloudinary isn't
/// configured, so the screen never crashes.
class AdminImageField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String folder;

  const AdminImageField({
    super.key,
    required this.label,
    required this.controller,
    required this.folder,
  });

  @override
  State<AdminImageField> createState() => _AdminImageFieldState();
}

class _AdminImageFieldState extends State<AdminImageField> {
  final bool _ready = ensureCloudinaryService() != null;

  @override
  Widget build(BuildContext context) {
    final url = widget.controller.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
        SizedBox(height: 10.h),
        if (url.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                AdminNetworkImage(
                  url: url,
                  width: 120.w,
                  height: 80.h,
                  radius: BorderRadius.circular(12.r),
                ),
                SizedBox(width: 12.w),
                TextButton.icon(
                  onPressed: () => setState(widget.controller.clear),
                  icon: const Icon(Iconsax.trash, size: 16),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                ),
              ],
            ),
          ),
        if (_ready)
          MediaUploadZone(
            folder: widget.folder,
            kind: MediaUploadKind.image,
            multiple: false,
            maxFiles: 1,
            tileSize: 88,
            onUploaded: (CloudinaryUploadResult r) =>
                setState(() => widget.controller.text = r.secureUrl),
          )
        else
          TextFormField(
            controller: widget.controller,
            onChanged: (_) => setState(() {}),
            style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
            decoration: adminInputDecoration(
              '${widget.label} URL',
              hint: 'Cloudinary is not configured — paste an image URL',
            ),
          ),
      ],
    );
  }
}
