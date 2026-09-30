import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/service_management_controller.dart';
import 'package:sufyan_portfolio/models/service_model.dart';
import 'package:sufyan_portfolio/widgets/service_form_dialog.dart';
import 'package:sufyan_portfolio/widgets/service_icon.dart';
import 'package:sufyan_portfolio/widgets/service_skeletons.dart';

/// Admin CRUD screen for the `services/` Firebase node.
///
/// Standalone by design, so it can later sit inside the dark admin shell
/// without rewriting its content and interactions.
class ServiceManagementScreen extends StatelessWidget {
  const ServiceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceManagementController());
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1200;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48.w : 20.w,
            vertical: 30.h,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1440.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(controller: controller),
                  SizedBox(height: 22.h),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const ServicesPageSkeleton(admin: true);
                      }

                      return Column(
                        children: [
                          _Toolbar(controller: controller),
                          SizedBox(height: 20.h),
                          Expanded(
                            child: RefreshIndicator(
                              color: AppColors.primary,
                              backgroundColor: AppColors.surface,
                              onRefresh: controller.loadServices,
                              child: controller.filteredServices.isEmpty
                                  ? _EmptyState(controller: controller)
                                  : LayoutBuilder(
                                      builder: (context, constraints) {
                                        final columns = constraints.maxWidth >= 1180
                                            ? 3
                                            : constraints.maxWidth >= 780
                                            ? 2
                                            : 1;
                                        return GridView.builder(
                                          padding: EdgeInsets.only(bottom: 30.h),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: columns,
                                            crossAxisSpacing: 18.w,
                                            mainAxisSpacing: 18.h,
                                            childAspectRatio: columns == 1 ? 1.42 : 1.10,
                                          ),
                                          itemCount: controller.filteredServices.length,
                                          itemBuilder: (_, index) {
                                            final service = controller.filteredServices[index];
                                            return _AdminServiceCard(
                                              service: service,
                                              onEdit: () => _openForm(
                                                context,
                                                controller,
                                                existing: service,
                                              ),
                                              onDelete: () => _confirmDelete(
                                                context,
                                                controller,
                                                service,
                                              ),
                                            ).animate().fadeIn(
                                              delay: Duration(milliseconds: 55 * (index % 6)),
                                              duration: const Duration(milliseconds: 320),
                                            );
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context,
    ServiceManagementController controller, {
    ServiceModel? existing,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ServiceFormDialog(
        existing: existing,
        onSave: controller.saveService,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ServiceManagementController controller,
    ServiceModel service,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Delete “${service.title}”?',
          style: AppTextStyles.h3().copyWith(fontSize: 21.sp),
        ),
        content: Text(
          'This permanently removes the service from Firebase and the public Services page.',
          style: AppTextStyles.body(),
        ),
        actionsPadding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 16.h),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) await controller.deleteService(service);
  }
}

class _Header extends StatelessWidget {
  final ServiceManagementController controller;

  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service Management', style: AppTextStyles.h2()),
            SizedBox(height: 5.h),
            Text(
              'Manage the services and capabilities shown on your public portfolio.',
              style: AppTextStyles.body(),
            ),
          ],
        );

        final action = ElevatedButton.icon(
          onPressed: controller.isSaving.value ? null : () => _openAdd(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 13.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Service'),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, SizedBox(height: 16.h), action],
          );
        }

        return Row(children: [Expanded(child: title), action]);
      },
    );
  }

  Future<void> _openAdd(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ServiceFormDialog(onSave: controller.saveService),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final ServiceManagementController controller;

  const _Toolbar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 680;
          final search = SizedBox(
            width: compact ? double.infinity : 330.w,
            child: TextField(
              onChanged: controller.setSearch,
              style: AppTextStyles.body().copyWith(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Search services...',
                hintStyle: AppTextStyles.small(),
                prefixIcon: Icon(Icons.search_rounded, size: 20.sp, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
              ),
            ),
          );

          final filters = Obx(() => Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: controller.categories.map((category) {
                  final selected = controller.selectedCategory.value == category;
                  return _MiniFilter(
                    label: category,
                    selected: selected,
                    onTap: () => controller.selectCategory(category),
                  );
                }).toList(),
              ));

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [search, SizedBox(height: 12.h), filters],
            );
          }

          return Row(children: [search, SizedBox(width: 14.w), Expanded(child: filters)]);
        },
      ),
    );
  }
}

class _MiniFilter extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MiniFilter({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.small(
            color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
          ).copyWith(fontSize: 11.5.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _AdminServiceCard extends StatefulWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_AdminServiceCard> createState() => _AdminServiceCardState();
}

class _AdminServiceCardState extends State<_AdminServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: _hovered
                ? AppColors.primary.withValues(alpha: 0.30)
                : AppColors.border,
          ),
          boxShadow: _hovered ? AppColors.featureShadow : AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ServiceIconBadge(iconKey: service.icon, compact: true, size: 48),
                const Spacer(),
                _StatusPill(
                  label: service.published ? 'Published' : 'Draft',
                  active: service.published,
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Text(service.category.toUpperCase(), style: AppTextStyles.overline().copyWith(fontSize: 10.sp)),
            SizedBox(height: 7.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(service.title, style: AppTextStyles.h3().copyWith(fontSize: 20.sp))),
                if (service.featured) ...[
                  SizedBox(width: 8.w),
                  Icon(Icons.star_rounded, color: AppColors.accentGold, size: 18.sp),
                ],
              ],
            ),
            SizedBox(height: 7.h),
            Text(
              service.shortDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body().copyWith(fontSize: 12.5.sp, height: 1.55),
            ),
            SizedBox(height: 12.h),
            if (service.technologies.isNotEmpty)
              Wrap(
                spacing: 7.w,
                runSpacing: 7.h,
                children: service.technologies.take(3).map((tech) => ServiceMetaPill(label: tech)).toList(),
              )
            else
              Text('No technologies added', style: AppTextStyles.small()),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.border),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
                SizedBox(width: 9.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: AppColors.danger.withValues(alpha: 0.28)),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final bool active;

  const _StatusPill({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: active ? AppColors.primarySoft : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTextStyles.small(
          color: active ? AppColors.primary : AppColors.textSecondary,
        ).copyWith(fontSize: 10.sp, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ServiceManagementController controller;

  const _EmptyState({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasFilters = controller.searchQuery.value.trim().isNotEmpty ||
        controller.selectedCategory.value != 'All';

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Container(
          constraints: BoxConstraints(maxWidth: 520.w),
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              ServiceIconBadge(iconKey: 'business', size: 58),
              SizedBox(height: 16.h),
              Text(
                hasFilters ? 'No matching services' : 'No services yet',
                style: AppTextStyles.h3().copyWith(fontSize: 20.sp),
              ),
              SizedBox(height: 7.h),
              Text(
                hasFilters
                    ? 'Try a different search or category filter.'
                    : 'Add your first service to start building the public Services page.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body().copyWith(fontSize: 13.5.sp),
              ),
              SizedBox(height: 18.h),
              if (hasFilters)
                OutlinedButton(
                  onPressed: () {
                    controller.setSearch('');
                    controller.selectCategory('All');
                  },
                  child: const Text('Clear Filters'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
