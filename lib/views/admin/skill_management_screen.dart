import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/skill_management_controller.dart';
import 'package:sufyan_portfolio/models/skill_model.dart';
import 'package:sufyan_portfolio/widgets/skill_form_dialog.dart';
import 'package:sufyan_portfolio/widgets/skill_icon.dart';
import 'package:sufyan_portfolio/widgets/skill_skeletons.dart';

/// Admin CRUD screen for the `skills/` Firebase node.
///
/// Standalone by design, matching the existing ProjectManagementScreen, so it
/// can later be placed inside the dark admin sidebar shell without rewriting
/// the actual page.
class SkillManagementScreen extends StatelessWidget {
  const SkillManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SkillManagementController());
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
                        return const SingleChildScrollView(
                          child: SkillsPageSkeleton(admin: true),
                        );
                      }

                      return Column(
                        children: [
                          _Toolbar(controller: controller),
                          SizedBox(height: 20.h),
                          Expanded(
                            child: RefreshIndicator(
                              color: AppColors.primary,
                              backgroundColor: AppColors.surface,
                              onRefresh: controller.loadSkills,
                              child: controller.filteredSkills.isEmpty
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
                                            childAspectRatio: columns == 1 ? 1.55 : 1.32,
                                          ),
                                          itemCount: controller.filteredSkills.length,
                                          itemBuilder: (_, index) {
                                            final skill = controller.filteredSkills[index];
                                            return _AdminSkillCard(
                                              skill: skill,
                                              onEdit: () => _openForm(
                                                context,
                                                controller,
                                                existing: skill,
                                              ),
                                              onDelete: () => _confirmDelete(
                                                context,
                                                controller,
                                                skill,
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
    SkillManagementController controller, {
    SkillModel? existing,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SkillFormDialog(
        existing: existing,
        onSave: controller.saveSkill,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SkillManagementController controller,
    SkillModel skill,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('Delete “${skill.name}”?', style: AppTextStyles.h3().copyWith(fontSize: 21.sp)),
        content: Text(
          'This permanently removes the skill from Firebase and the public Skills page.',
          style: AppTextStyles.body(),
        ),
        actionsPadding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 16.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: AppTextStyles.bodyMedium(color: AppColors.textSecondary)),
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

    if (confirmed == true) await controller.deleteSkill(skill);
  }
}

class _Header extends StatelessWidget {
  final SkillManagementController controller;

  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skill Management', style: AppTextStyles.h2()),
            SizedBox(height: 5.h),
            Text(
              'Manage the expertise cards shown on your public portfolio.',
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
          label: const Text('Add Skill'),
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
      builder: (_) => SkillFormDialog(
        onSave: controller.saveSkill,
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final SkillManagementController controller;

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
                hintText: 'Search skills...',
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

class _AdminSkillCard extends StatefulWidget {
  final SkillModel skill;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminSkillCard({required this.skill, required this.onEdit, required this.onDelete});

  @override
  State<_AdminSkillCard> createState() => _AdminSkillCardState();
}

class _AdminSkillCardState extends State<_AdminSkillCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final skill = widget.skill;

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
            color: _hovered ? AppColors.primary.withValues(alpha: 0.30) : AppColors.border,
          ),
          boxShadow: _hovered ? AppColors.featureShadow : AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkillIconBadge(iconKey: skill.icon, compact: true, size: 48),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill.name,
                        style: AppTextStyles.bodyMedium().copyWith(fontSize: 16.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          _Pill(label: skill.category, color: AppColors.primary),
                          SizedBox(width: 6.w),
                          _Pill(
                            label: skill.published ? 'Live' : 'Draft',
                            color: skill.published ? AppColors.success : AppColors.warning,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${skill.proficiency}%',
                  style: AppTextStyles.bodyMedium(color: AppColors.primary).copyWith(fontSize: 13.sp),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              skill.description.isEmpty ? 'No description added yet.' : skill.description,
              style: AppTextStyles.small(color: AppColors.textSecondary).copyWith(height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            SizedBox(height: 14.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(999.r),
              child: Stack(
                children: [
                  Container(height: 5.h, color: AppColors.surfaceMuted),
                  FractionallySizedBox(
                    widthFactor: skill.proficiency / 100,
                    child: Container(
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: AppColors.border),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    icon: Icon(Icons.edit_outlined, size: 16.sp),
                    label: const Text('Edit'),
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: widget.onDelete,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.danger.withValues(alpha: 0.10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  icon: Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 19.sp),
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
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.small(color: color).copyWith(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final SkillManagementController controller;

  const _EmptyState({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasFilter = controller.searchQuery.value.trim().isNotEmpty ||
        controller.selectedCategory.value != 'All';

    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: constraints.maxHeight - 30.h,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasFilter ? Icons.search_off_rounded : Icons.auto_awesome_mosaic_outlined,
                      size: 50.sp,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      hasFilter ? 'No matching skills' : 'No skills yet',
                      style: AppTextStyles.h3(),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      hasFilter
                          ? 'Try another search or category.'
                          : 'Add your first skill to build the public expertise section.',
                      style: AppTextStyles.body(),
                      textAlign: TextAlign.center,
                    ),
                    if (!hasFilter) ...[
                      SizedBox(height: 18.h),
                      ElevatedButton.icon(
                        onPressed: () => showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => SkillFormDialog(onSave: controller.saveSkill),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Skill'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
