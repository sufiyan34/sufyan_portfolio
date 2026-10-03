import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/consultation_controller.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_media_helper.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_models.dart';

/// Client-side (ivory / forest green) drop zone for consultation reference
/// files. Files are only collected here — the controller uploads them when
/// the request is submitted.
class ConsultationFileDropZone extends StatelessWidget {
  final ConsultationController controller;

  const ConsultationFileDropZone({super.key, required this.controller});

  bool get _dragDropSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reference files (optional)',
          style: AppTextStyles.bodyMedium().copyWith(fontSize: 12.5.sp),
        ),
        SizedBox(height: 7.h),
        _zone(),
        Obx(() {
          final error = controller.fileError.value;
          if (error.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              error,
              style: AppTextStyles.small(color: AppColors.danger),
            ),
          );
        }),
        Obx(() {
          // Touch the list + submitting flag so this Obx always rebuilds.
          final count = controller.attachments.length;
          final locked = controller.isSubmitting.value;
          if (count == 0) return const SizedBox.shrink();

          return Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Column(
              children: [
                for (final item in controller.attachments.toList())
                  _FileRow(
                    key: ValueKey(item.id),
                    item: item,
                    locked: locked,
                    onRemove: () => controller.removeFile(item),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _zone() {
    final body = Obx(() {
      final dragging = controller.isDragging.value;
      final full =
          controller.attachments.length >= ConsultationController.maxFiles;

      return InkWell(
        onTap: full ? null : controller.browseFiles,
        borderRadius: BorderRadius.circular(14.r),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: dragging ? AppColors.accentGold : AppColors.border,
            strokeWidth: dragging ? 1.6 : 1.2,
            radius: 14.r,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: dragging
                  ? AppColors.accentGoldSoft
                  : AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    dragging ? Iconsax.import : Iconsax.document_upload,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  dragging
                      ? 'Drop files to attach'
                      : full
                      ? 'Maximum files attached'
                      : _dragDropSupported
                      ? 'Drag & drop files here, or click to browse'
                      : 'Tap to choose files',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium().copyWith(fontSize: 13.sp),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Screenshots, PDFs, docs, Figma exports or zips · up to '
                  '${ConsultationController.maxFiles} files, '
                  '${CloudinaryMediaHelper.formatBytes(ConsultationController.maxFileBytes)} each',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.small().copyWith(fontSize: 11.5.sp),
                ),
              ],
            ),
          ),
        ),
      );
    });

    if (!_dragDropSupported) return body;

    return DropTarget(
      onDragEntered: (_) => controller.isDragging.value = true,
      onDragExited: (_) => controller.isDragging.value = false,
      onDragDone: (details) {
        controller.isDragging.value = false;
        controller.addFiles(details.files);
      },
      child: body,
    );
  }
}

class _FileRow extends StatelessWidget {
  final PendingAttachment item;
  final bool locked;
  final VoidCallback onRemove;

  const _FileRow({
    super.key,
    required this.item,
    required this.locked,
    required this.onRemove,
  });

  IconData get _icon {
    switch (CloudinaryMediaHelper.kindFromExtension(item.name)) {
      case CloudinaryMediaKind.image:
        return Iconsax.gallery;
      case CloudinaryMediaKind.video:
        return Iconsax.video;
      default:
        return Iconsax.document_text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = item.status.value;
      final progress = item.progress.value;
      final error = item.error.value;

      final failed = status == AttachmentStatus.failed;
      final uploaded = status == AttachmentStatus.uploaded;
      final uploading = status == AttachmentStatus.uploading;

      final size = CloudinaryMediaHelper.formatBytes(item.bytes);
      final subtitle = failed
          ? (error.isEmpty ? 'Upload failed' : error)
          : uploaded
          ? '$size · Uploaded'
          : uploading
          ? '$size · Uploading ${(progress * 100).round()}%'
          : size;

      return Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: failed
                ? AppColors.danger.withValues(alpha: 0.45)
                : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(_icon, size: 18.sp, color: AppColors.primary),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium().copyWith(
                          fontSize: 12.5.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.small(
                          color: failed
                              ? AppColors.danger
                              : uploaded
                              ? AppColors.success
                              : AppColors.textMuted,
                        ).copyWith(fontSize: 11.5.sp),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                if (uploaded)
                  Icon(
                    Iconsax.tick_circle,
                    size: 18.sp,
                    color: AppColors.success,
                  )
                else
                  InkWell(
                    onTap: locked ? null : onRemove,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Icon(
                        Iconsax.close_circle,
                        size: 18.sp,
                        color: locked
                            ? AppColors.textMuted.withValues(alpha: 0.5)
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
            if (uploading) ...[
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress > 0 ? progress : null,
                  minHeight: 4.h,
                  color: AppColors.primary,
                  backgroundColor: AppColors.primarySoft,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    const dashWidth = 6.0;
    const dashSpace = 4.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.radius != radius;
}
