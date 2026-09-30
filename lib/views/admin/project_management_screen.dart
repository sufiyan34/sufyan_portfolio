import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/project_management_controller.dart';
import 'package:sufyan_portfolio/models/project_model.dart';
import 'package:sufyan_portfolio/widgets/project_form_dialog.dart';

/// Admin "Project Management" screen — add / edit / delete the portfolio
/// showcase projects that populate the public Projects grid.
///
/// This is a self-contained screen (its own Scaffold) so it can be dropped
/// straight into an admin shell/sidebar layout later without changes —
/// that shell isn't built yet, so for now this registers as a standalone
/// route (AppRoutes.projectManagement).
class ProjectManagementScreen extends StatelessWidget {
  const ProjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProjectManagementController());
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48.w : 20.w,
            vertical: 32.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, controller),
              SizedBox(height: 24.h),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (controller.projects.isEmpty) {
                    return _buildEmptyState(context, controller);
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: controller.loadProjects,
                    child: GridView.builder(
                      padding: EdgeInsets.only(bottom: 32.h),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 360.w,
                        mainAxisSpacing: 20.h,
                        crossAxisSpacing: 20.w,
                        childAspectRatio: 0.98,
                      ),
                      itemCount: controller.projects.length,
                      itemBuilder: (context, index) {
                        final project = controller.projects[index];
                        return _AdminProjectCard(
                          project: project,
                          onEdit: () =>
                              _openForm(context, controller, existing: project),
                          onDelete: () =>
                              _confirmDelete(context, controller, project),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ProjectManagementController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Project Management', style: AppTextStyles.h2()),
              SizedBox(height: 4.h),
              Text(
                'Add, edit, or remove the projects shown on your public Projects page.',
                style: AppTextStyles.body(),
              ),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        ElevatedButton.icon(
          onPressed: () => _openForm(context, controller),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Project'),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ProjectManagementController controller,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 56.sp,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 16.h),
          Text('No projects yet', style: AppTextStyles.h3()),
          SizedBox(height: 6.h),
          Text(
            'Add your first project to have it appear on the public site.',
            style: AppTextStyles.body(),
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: () => _openForm(context, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Project'),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context,
    ProjectManagementController controller, {
    ProjectModel? existing,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProjectFormDialog(
        existing: existing,
        onSave: (draft) => controller.saveProject(draft),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProjectManagementController controller,
    ProjectModel project,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Delete "${project.title}"?', style: AppTextStyles.h3()),
        content: Text(
          'This permanently removes it from Firebase and the public Projects page. '
          'This can\'t be undone.',
          style: AppTextStyles.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteProject(project);
    }
  }
}

class _AdminProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminProjectCard({
    required this.project,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: project.coverImageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: project.coverImageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _coverFallback(),
                  )
                : _coverFallback(),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: AppTextStyles.h3().copyWith(fontSize: 17.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!project.published)
                        _StatusPill(label: 'Draft', color: AppColors.warning),
                      if (project.featured) ...[
                        SizedBox(width: 6.w),
                        _StatusPill(
                          label: 'Featured',
                          color: AppColors.accentGold,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    project.shortDescription,
                    style: AppTextStyles.small(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  if (project.technologies.isNotEmpty)
                    Text(
                      project.technologies.join(' \u00b7 '),
                      style: AppTextStyles.small(color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEdit,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: BorderSide(color: AppColors.border),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          icon: Icon(Icons.edit_outlined, size: 16.sp),
                          label: const Text('Edit'),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        onPressed: onDelete,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.danger.withValues(
                            alpha: 0.1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.danger,
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverFallback() {
    return Container(
      color: AppColors.surfaceSoft,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        color: AppColors.textMuted,
        size: 32.sp,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.small(color: color)
            .copyWith(fontSize: 10.sp, fontWeight: FontWeight.w700),
      ),
    );
  }
}
