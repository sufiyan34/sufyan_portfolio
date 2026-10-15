import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_models.dart';
import 'package:sufyan_portfolio/utills/cloudinary_registry.dart';
import 'package:sufyan_portfolio/utills/media_upload_zone.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// "Current file + upload zone" field for documents such as a resume PDF.
/// Writes the uploaded file's URL into [controller]; falls back to a plain URL
/// field when Cloudinary isn't configured.
class AdminFileField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String folder;
  final String hint;

  const AdminFileField({
    super.key,
    required this.label,
    required this.controller,
    required this.folder,
    this.hint = '',
  });

  @override
  State<AdminFileField> createState() => _AdminFileFieldState();
}

class _AdminFileFieldState extends State<AdminFileField> {
  final bool _ready = ensureCloudinaryService() != null;

  @override
  Widget build(BuildContext context) {
    final url = widget.controller.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (url.isNotEmpty)
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Iconsax.document, size: 20.sp, color: AppColors.primary),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small(),
                  ),
                ),
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: const Text('Open'),
                ),
                TextButton(
                  onPressed: () => setState(widget.controller.clear),
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                  child: const Text('Remove'),
                ),
              ],
            ),
          ),
        if (_ready)
          MediaUploadZone(
            folder: widget.folder,
            kind: MediaUploadKind.any,
            multiple: false,
            maxFiles: 1,
            maxFileBytes: 10 * 1024 * 1024,
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
              widget.label,
              hint: widget.hint.isEmpty
                  ? 'Cloudinary is not configured — paste a file URL'
                  : widget.hint,
            ),
          ),
      ],
    );
  }
}
