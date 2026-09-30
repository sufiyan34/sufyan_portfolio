import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/package_management_controller.dart';
import 'package:sufyan_portfolio/models/package_model.dart';
import 'package:sufyan_portfolio/widgets/package_form_dialog.dart';
import 'package:sufyan_portfolio/widgets/package_skeletons.dart';

class PackageManagementScreen extends StatelessWidget {
  const PackageManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PackageManagementController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 18.h),
          child: Obx(() {
            if (controller.isLoading.value) return const PackageManagementSkeleton();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(controller: controller),
                SizedBox(height: 18.h),
                _Toolbar(controller: controller),
                SizedBox(height: 18.h),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    onRefresh: controller.loadPackages,
                    child: controller.filteredPackages.isEmpty
                        ? const _EmptyAdminState()
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = constraints.maxWidth >= 1120
                                  ? 3
                                  : constraints.maxWidth >= 720
                                      ? 2
                                      : 1;
                              return GridView.builder(
                                padding: EdgeInsets.only(bottom: 24.h),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 18.w,
                                  mainAxisSpacing: 18.h,
                                  childAspectRatio: columns == 1 ? 1.13 : 0.98,
                                ),
                                itemCount: controller.filteredPackages.length,
                                itemBuilder: (_, index) {
                                  final package = controller.filteredPackages[index];
                                  return _AdminPackageCard(
                                    package: package,
                                    onEdit: () => _openForm(context, controller, existing: package),
                                    onDelete: () => _confirmDelete(context, controller, package),
                                  )
                                      .animate()
                                      .fadeIn(
                                        delay: Duration(milliseconds: 55 * (index % 6)),
                                        duration: const Duration(milliseconds: 320),
                                      )
                                      .slideY(begin: 0.02, end: 0, curve: Curves.easeOut);
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
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context,
    PackageManagementController controller, {
    PackageModel? existing,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PackageFormDialog(
        existing: existing,
        onSave: controller.savePackage,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PackageManagementController controller,
    PackageModel package,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Delete “${package.title}”?',
          style: AppTextStyles.h3().copyWith(fontSize: 21.sp),
        ),
        content: Text(
          'This permanently removes the package from Firebase and the public Packages page.',
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
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) await controller.deletePackage(package);
  }
}

class _Header extends StatelessWidget {
  final PackageManagementController controller;

  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 680;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Package Management', style: AppTextStyles.h2()),
            SizedBox(height: 5.h),
            Text(
              'Create tiered offers or tailor any package into a custom scope.',
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
            elevation: 0,
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Package'),
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
      builder: (_) => PackageFormDialog(onSave: controller.savePackage),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final PackageManagementController controller;

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
                hintText: 'Search packages...',
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

          final filters = Obx(
            () => Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: controller.types.map((type) {
                final selected = controller.selectedType.value == type;
                final label = type == kAllAdminPackagesFilter ? 'All' : PackageTypes.label(type);
                return _MiniFilter(
                  label: label,
                  selected: selected,
                  onTap: () => controller.selectType(type),
                );
              }).toList(),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [search, SizedBox(height: 12.h), filters],
            );
          }

          return Row(
            children: [search, SizedBox(width: 14.w), Expanded(child: filters)],
          );
        },
      ),
    );
  }
}

class _MiniFilter extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MiniFilter({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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

class _AdminPackageCard extends StatefulWidget {
  final PackageModel package;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminPackageCard({
    required this.package,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_AdminPackageCard> createState() => _AdminPackageCardState();
}

class _AdminPackageCardState extends State<_AdminPackageCard> {
  bool _hovered = false;

  Color get _typeAccent {
    switch (PackageTypes.normalize(widget.package.type)) {
      case PackageTypes.gold:
        return AppColors.accentGold;
      case PackageTypes.platinum:
        return AppColors.primary;
      case PackageTypes.custom:
        return AppColors.info;
      case PackageTypes.silver:
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final package = widget.package;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: _hovered ? _typeAccent.withValues(alpha: 0.35) : AppColors.border,
          ),
          boxShadow: _hovered ? AppColors.featureShadow : AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _typeAccent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    PackageTypes.label(package.type).toUpperCase(),
                    style: AppTextStyles.small(color: _typeAccent).copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 10.sp,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                _StatusDot(
                  active: package.published,
                  label: package.published ? 'Published' : 'Draft',
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Text(
              package.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.h3(),
            ),
            SizedBox(height: 6.h),
            Text(
              package.shortDescription,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body().copyWith(fontSize: 13.sp),
            ),
            SizedBox(height: 13.h),
            Row(
              children: [
                Text(
                  package.price <= 0 ? 'Custom' : '${package.currency} ${package.price % 1 == 0 ? package.price.toInt() : package.price.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
                ),
                SizedBox(width: 8.w),
                Text(package.pricingNote, style: AppTextStyles.small()),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 7.w,
              runSpacing: 7.h,
              children: [
                _InfoPill(icon: Icons.schedule_rounded, label: '${package.deliveryDays}d'),
                _InfoPill(icon: Icons.refresh_rounded, label: '${package.revisions} rev.'),
                if (package.featured)
                  const _InfoPill(icon: Icons.star_rounded, label: 'Featured'),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: widget.onDelete,
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    backgroundColor: AppColors.surfaceSoft,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool active;
  final String label;

  const _StatusDot({required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.warning;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7.w,
          height: 7.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 5.w),
        Text(label, style: AppTextStyles.small(color: color).copyWith(fontSize: 10.5.sp, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: AppColors.textSecondary),
          SizedBox(width: 4.w),
          Text(label, style: AppTextStyles.small(color: AppColors.textSecondary).copyWith(fontSize: 10.5.sp)),
        ],
      ),
    );
  }
}

class _EmptyAdminState extends StatelessWidget {
  const _EmptyAdminState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 110.h),
        Icon(Icons.inventory_2_outlined, size: 38.sp, color: AppColors.textMuted),
        SizedBox(height: 13.h),
        Center(child: Text('No packages match this view.', style: AppTextStyles.h3())),
        SizedBox(height: 7.h),
        Center(
          child: Text(
            'Add a package or change the current search/filter.',
            style: AppTextStyles.body(),
          ),
        ),
      ],
    );
  }
}
