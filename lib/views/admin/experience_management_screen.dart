import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/experience_management_controller.dart';
import 'package:sufyan_portfolio/models/experience_model.dart';
import 'package:sufyan_portfolio/widgets/experience_form_dialog.dart';
import 'package:sufyan_portfolio/widgets/experience_skeletons.dart';

/// Admin experience management — add / edit / delete the public timeline.
class ExperienceManagementScreen extends StatelessWidget {
  const ExperienceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExperienceManagementController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width >= 1200 ? 48.w : 20.w,
            vertical: 30.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(controller: controller),
              SizedBox(height: 22.h),
              _Toolbar(controller: controller),
              SizedBox(height: 20.h),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const ExperienceAdminSkeleton();
                  }

                  final items = controller.filteredExperiences;
                  if (items.isEmpty) {
                    return _EmptyState(
                      hasFilters: controller.searchQuery.value.trim().isNotEmpty ||
                          controller.selectedType.value != 'All',
                      onAdd: () => _openForm(context, controller),
                      onClear: () {
                        controller.setSearch('');
                        controller.selectType('All');
                      },
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: controller.loadExperiences,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 820;
                        return GridView.builder(
                          padding: EdgeInsets.only(bottom: 28.h),
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: compact ? 680.w : 440.w,
                            mainAxisSpacing: 18.h,
                            crossAxisSpacing: 18.w,
                            childAspectRatio: compact ? 1.28 : 1.04,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final experience = items[index];
                            return _AdminExperienceCard(
                              experience: experience,
                              onEdit: () => _openForm(
                                context,
                                controller,
                                existing: experience,
                              ),
                              onDelete: () => _confirmDelete(
                                context,
                                controller,
                                experience,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 350.ms, delay: (index * 55).ms)
                                .slideY(begin: 0.04, end: 0);
                          },
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

  static Future<void> _openForm(
    BuildContext context,
    ExperienceManagementController controller, {
    ExperienceModel? existing,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ExperienceFormDialog(
        existing: existing,
        onSave: controller.saveExperience,
      ),
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    ExperienceManagementController controller,
    ExperienceModel experience,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        title: Text(
          'Delete “${experience.role}”?',
          style: AppTextStyles.h3().copyWith(fontSize: 20.sp),
        ),
        content: Text(
          'This permanently removes this timeline entry from Firebase and the public Experience page.',
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteExperience(experience);
    }
  }
}

class _Header extends StatelessWidget {
  final ExperienceManagementController controller;

  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;

        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Experience Management', style: AppTextStyles.h2()),
            SizedBox(height: 4.h),
            Text(
              'Add, edit, publish, or remove the experience entries shown to clients.',
              style: AppTextStyles.body(),
            ),
          ],
        );

        final action = ElevatedButton.icon(
          onPressed: controller.isSaving.value
              ? null
              : () => ExperienceManagementScreen._openForm(context, controller),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 13.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Experience'),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              SizedBox(height: 14.h),
              Align(alignment: Alignment.centerLeft, child: action),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            SizedBox(width: 16.w),
            action,
          ],
        );
      },
    );
  }
}

class _Toolbar extends StatelessWidget {
  final ExperienceManagementController controller;

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
          final compact = constraints.maxWidth < 720;
          final search = TextField(
            onChanged: controller.setSearch,
            style: AppTextStyles.body().copyWith(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Search role, company, tech...',
              hintStyle: AppTextStyles.small(),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20.sp,
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 11.h,
              ),
            ),
          );

          final filters = Obx(
            () => Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: controller.types
                  .map(
                    (type) => _MiniFilter(
                      label: type,
                      selected: controller.selectedType.value == type,
                      onTap: () => controller.selectType(type),
                    ),
                  )
                  .toList(),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                search,
                SizedBox(height: 12.h),
                filters,
              ],
            );
          }

          return Row(
            children: [
              SizedBox(width: 340.w, child: search),
              SizedBox(width: 14.w),
              Expanded(child: filters),
            ],
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
      borderRadius: BorderRadius.circular(999.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.small(
            color: selected
                ? AppColors.textOnPrimary
                : AppColors.textSecondary,
          ).copyWith(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AdminExperienceCard extends StatefulWidget {
  final ExperienceModel experience;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminExperienceCard({
    required this.experience,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_AdminExperienceCard> createState() => _AdminExperienceCardState();
}

class _AdminExperienceCardState extends State<_AdminExperienceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final experience = widget.experience;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        padding: EdgeInsets.all(19.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: _hovered
                ? AppColors.primary.withValues(alpha: 0.28)
                : AppColors.border,
          ),
          boxShadow: _hovered ? AppColors.featureShadow : AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Icon(
                    experience.isCurrent ? Iconsax.flash_1 : Iconsax.briefcase,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        experience.role,
                        style: AppTextStyles.h3().copyWith(fontSize: 18.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        experience.company,
                        style: AppTextStyles.bodyMedium(color: AppColors.primary)
                            .copyWith(fontSize: 13.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'More actions',
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') widget.onEdit();
                    if (value == 'delete') widget.onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  child: Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.textMuted,
                    size: 21.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 7.w,
              runSpacing: 7.h,
              children: [
                _Pill(
                  label: experience.employmentType,
                  foreground: AppColors.primary,
                  background: AppColors.primarySoft,
                ),
                _Pill(
                  label: experience.published ? 'Live' : 'Draft',
                  foreground: experience.published
                      ? AppColors.success
                      : AppColors.warning,
                  background: experience.published
                      ? AppColors.primarySoft
                      : AppColors.accentGoldSoft,
                ),
                if (experience.featured)
                  _Pill(
                    label: 'Featured',
                    foreground: AppColors.primary,
                    background: AppColors.surfaceSoft,
                  ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Icon(Iconsax.calendar_1, size: 14.sp, color: AppColors.textMuted),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    experience.dateRange.isEmpty
                        ? 'Date not added'
                        : experience.dateRange,
                    style: AppTextStyles.small(color: AppColors.textSecondary)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (experience.location.isNotEmpty)
                  Icon(Iconsax.location, size: 14.sp, color: AppColors.textMuted),
                if (experience.location.isNotEmpty) SizedBox(width: 5.w),
                if (experience.location.isNotEmpty)
                  Flexible(
                    child: Text(
                      experience.location,
                      style: AppTextStyles.small(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            if (experience.description.isNotEmpty) ...[
              SizedBox(height: 14.h),
              Text(
                experience.description,
                style: AppTextStyles.small(color: AppColors.textSecondary)
                    .copyWith(height: 1.55),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (experience.technologies.isNotEmpty) ...[
              const Spacer(),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: experience.technologies
                    .take(5)
                    .map((item) => _TechChip(label: item))
                    .toList(),
              ),
            ] else
              const Spacer(),
            SizedBox(height: 14.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    '#${experience.sortOrder}',
                    style: AppTextStyles.small(color: AppColors.textMuted)
                        .copyWith(fontSize: 10.5.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: widget.onEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.border),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                  icon: Icon(Iconsax.edit_2, size: 15.sp),
                  label: Text('Edit', style: TextStyle(fontSize: 12.sp)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;

  const _Pill({
    required this.label,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.small(color: foreground).copyWith(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  const _TechChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTextStyles.small(color: AppColors.textSecondary).copyWith(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onAdd;
  final VoidCallback onClear;

  const _EmptyState({
    required this.hasFilters,
    required this.onAdd,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600.w),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 54.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62.w,
              height: 62.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Icon(
                hasFilters ? Icons.search_off_rounded : Icons.timeline_rounded,
                color: AppColors.primary,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              hasFilters ? 'No matching experience' : 'No experience yet',
              style: AppTextStyles.h3(),
            ),
            SizedBox(height: 7.h),
            Text(
              hasFilters
                  ? 'Try a different search term or clear the filter.'
                  : 'Add your first timeline entry to start building the public experience page.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(),
            ),
            SizedBox(height: 18.h),
            Wrap(
              spacing: 10.w,
              children: [
                if (hasFilters)
                  OutlinedButton(
                    onPressed: onClear,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                    child: const Text('Clear filters'),
                  ),
                ElevatedButton.icon(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Experience'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
