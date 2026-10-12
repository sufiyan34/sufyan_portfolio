import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/media_management_controller.dart';
import 'package:sufyan_portfolio/models/media_asset_model.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_service.dart';
import 'package:sufyan_portfolio/utills/cloudinary_registry.dart';
import 'package:sufyan_portfolio/utills/media_upload_zone.dart';
import 'package:sufyan_portfolio/widgets/admin_shell.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';

/// Admin > Media Management: upload to Cloudinary and browse everything that
/// was uploaded through the admin panel.
class MediaManagementScreen extends StatelessWidget {
  const MediaManagementScreen({super.key});

  static const _typeLabels = {
    'all': 'All',
    'image': 'Images',
    'video': 'Videos',
    'file': 'Files',
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MediaManagementController());
    final cloudinary = ensureCloudinaryService();

    return AdminShell(
      title: 'Media Library',
      eyebrow: 'Files & uploads',
      trailing: IconButton(
        tooltip: 'Refresh',
        onPressed: controller.load,
        icon: const Icon(Iconsax.refresh, size: 19),
      ),
      child: Obx(() {
        final list = controller.filtered;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.load,
          child: ListView(
            padding: EdgeInsets.fromLTRB(22.w, 20.h, 22.w, 32.h),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1200.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _UploadPanel(controller: controller, ready: cloudinary != null),
                      SizedBox(height: 18.h),
                      AdminStatsGrid(
                        items: [
                          ('Files', '${controller.items.length}', Iconsax.folder_2),
                          ('Images', '${controller.imageCount}', Iconsax.gallery),
                          ('Videos', '${controller.videoCount}', Iconsax.video),
                          ('Storage', _formatBytes(controller.totalBytes), Iconsax.cloud),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      AdminSearchField(
                        hint: 'Search by file name, folder or format',
                        onChanged: controller.setSearch,
                      ),
                      SizedBox(height: 12.h),
                      AdminFilterChips(
                        values: _typeLabels.keys.toList(),
                        selected: controller.typeFilter.value,
                        labelOf: (v) => _typeLabels[v] ?? v,
                        onSelected: controller.setTypeFilter,
                      ),
                      SizedBox(height: 18.h),
                      if (controller.isLoading.value)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 60.h),
                          child: const Center(child: CircularProgressIndicator()),
                        )
                      else if (list.isEmpty)
                        const AdminEmptyState(
                          icon: Iconsax.gallery_slash,
                          title: 'Nothing here yet',
                          message: 'Files you upload above will show up in the library.',
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth >= 1000
                                ? 4
                                : constraints.maxWidth >= 700
                                ? 3
                                : 2;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: list.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 14.w,
                                mainAxisSpacing: 14.h,
                                childAspectRatio: 0.86,
                              ),
                              itemBuilder: (_, index) => _MediaTile(
                                asset: list[index],
                                cloudinary: cloudinary,
                                onCopy: () => controller.copyUrl(list[index]),
                                onOpen: () => launchUrl(
                                  Uri.parse(list[index].url),
                                  mode: LaunchMode.externalApplication,
                                ),
                                onDelete: () async {
                                  final ok = await confirmAdminDelete(
                                    context,
                                    title: 'Remove “${list[index].name}”?',
                                    message:
                                        'This removes it from the library. The file stays on Cloudinary, so any page already using its link keeps working.',
                                  );
                                  if (ok) await controller.delete(list[index]);
                                },
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

class _UploadPanel extends StatelessWidget {
  final MediaManagementController controller;
  final bool ready;
  const _UploadPanel({required this.controller, required this.ready});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: 'Upload files',
      subtitle: 'Drag & drop, paste or browse. Images are compressed before upload.',
      child: ready
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Save to folder', style: AppTextStyles.small()),
                SizedBox(height: 8.h),
                Obx(
                  () => AdminFilterChips(
                    values: MediaManagementController.folders,
                    selected: controller.uploadFolder.value,
                    labelOf: (v) => v[0].toUpperCase() + v.substring(1),
                    onSelected: controller.setUploadFolder,
                  ),
                ),
                SizedBox(height: 14.h),
                Obx(
                  () => MediaUploadZone(
                    folder: controller.cloudinaryFolder,
                    kind: MediaUploadKind.any,
                    maxFiles: 20,
                    onUploaded: controller.recordUpload,
                  ),
                ),
              ],
            )
          : Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.warning_2, color: AppColors.danger, size: 20.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Cloudinary isn’t configured. Run the app with '
                      '--dart-define=CLOUDINARY_CLOUD_NAME=… and '
                      '--dart-define=CLOUDINARY_UNSIGNED_PRESET=… to enable uploads.',
                      style: AppTextStyles.body(color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  final MediaAssetModel asset;
  final CloudinaryService? cloudinary;
  final VoidCallback onCopy;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _MediaTile({
    required this.asset,
    required this.cloudinary,
    required this.onCopy,
    required this.onOpen,
    required this.onDelete,
  });

  String get _thumbUrl {
    final service = cloudinary;
    if (asset.isImage) {
      if (service != null && asset.publicId.isNotEmpty) {
        return service.imageUrl(asset.publicId, width: 480, height: 360, crop: 'fill');
      }
      return asset.url;
    }
    if (asset.isVideo && service != null && asset.publicId.isNotEmpty) {
      return service.videoThumbnailUrl(asset.publicId, width: 480, height: 360);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final hasThumb = _thumbUrl.isNotEmpty;
    final meta = [
      if (asset.format.isNotEmpty) asset.format.toUpperCase(),
      _formatBytes(asset.bytes),
      if (asset.width > 0 && asset.height > 0) '${asset.width}×${asset.height}',
    ].join(' · ');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: onOpen,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  hasThumb
                      ? AdminNetworkImage(url: _thumbUrl)
                      : Container(
                          color: AppColors.surfaceMuted,
                          alignment: Alignment.center,
                          child: Icon(
                            Iconsax.document_text,
                            size: 34.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                  if (asset.isVideo)
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24.sp),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 6.w, 6.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium().copyWith(fontSize: 13.sp),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.small().copyWith(fontSize: 10.5.sp),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Copy link',
                  visualDensity: VisualDensity.compact,
                  onPressed: onCopy,
                  icon: Icon(Iconsax.copy, size: 17.sp),
                ),
                IconButton(
                  tooltip: 'Remove from library',
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                  icon: Icon(Iconsax.trash, size: 17.sp, color: AppColors.danger),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
