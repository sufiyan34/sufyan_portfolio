import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/skills_controller.dart';
import 'package:sufyan_portfolio/widgets/public_navbar.dart';
import 'package:sufyan_portfolio/widgets/skill_card.dart';
import 'package:sufyan_portfolio/widgets/skill_skeletons.dart';

class SkillsScreen extends StatelessWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SkillsController());
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1200;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PublicNavbar(activeRoute: AppRoutes.skills),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: controller.loadSkills,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 64.w : 20.w,
            vertical: isDesktop ? 62.h : 40.h,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1320.w),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const SkillsPageSkeleton();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro()
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 400))
                        .slideY(begin: 0.04, end: 0, curve: Curves.easeOut),
                    SizedBox(height: 28.h),
                    _CategoryRow(controller: controller),
                    SizedBox(height: 30.h),
                    if (controller.filteredSkills.isEmpty)
                      const _EmptySkillsState()
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 1120
                              ? 3
                              : constraints.maxWidth >= 700
                              ? 2
                              : 1;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.filteredSkills.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 18.w,
                              mainAxisSpacing: 18.h,
                              childAspectRatio: columns == 1 ? 1.5 : 1.28,
                            ),
                            itemBuilder: (_, index) {
                              return SkillCard(skill: controller.filteredSkills[index])
                                  .animate()
                                  .fadeIn(
                                    delay: Duration(milliseconds: 55 * (index % 6)),
                                    duration: const Duration(milliseconds: 360),
                                  )
                                  .slideY(
                                    begin: 0.03,
                                    end: 0,
                                    curve: Curves.easeOut,
                                  );
                            },
                          );
                        },
                      ),
                    SizedBox(height: 40.h),
                    _buildBottomNote(),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CAPABILITIES', style: AppTextStyles.overline()),
              SizedBox(height: 10.h),
              Text('Skills & Expertise', style: AppTextStyles.h1()),
              SizedBox(height: 10.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 700.w),
                child: Text(
                  'A practical toolkit for building polished digital products — from Flutter interfaces and Firebase backends to scalable application architecture.',
                  style: AppTextStyles.body(),
                ),
              ),
            ],
          );

          final aside = Container(
            constraints: BoxConstraints(maxWidth: 290.w),
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 9.w,
                  height: 9.w,
                  margin: EdgeInsets.only(top: 5.h),
                  decoration: const BoxDecoration(
                    color: AppColors.accentGold,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Clean implementation, thoughtful UX, and maintainable code.',
                    style: AppTextStyles.small(color: AppColors.textPrimary).copyWith(
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, SizedBox(height: 20.h), aside],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: copy),
              SizedBox(width: 26.w),
              aside,
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomNote() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Need a specific stack or capability?',
              style: AppTextStyles.bodyMedium(color: AppColors.textOnPrimary).copyWith(fontSize: 14.sp),
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.hireUs),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Let\'s Talk',
                style: AppTextStyles.bodyMedium(color: AppColors.textPrimary).copyWith(fontSize: 13.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final SkillsController controller;
  const _CategoryRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Wrap(
        spacing: 9.w,
        runSpacing: 9.h,
        children: controller.categories.map((category) {
          final selected = controller.selectedCategory.value == category;
          return _FilterPill(
            label: category,
            selected: selected,
            onTap: () => controller.selectCategory(category),
          );
        }).toList(),
      );
    });
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            boxShadow: selected ? AppColors.cardShadow : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium(
              color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
            ).copyWith(fontSize: 13.sp),
          ),
        ),
      ),
    );
  }
}

class _EmptySkillsState extends StatelessWidget {
  const _EmptySkillsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 80.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome_mosaic_outlined, size: 46.sp, color: AppColors.textMuted),
          SizedBox(height: 14.h),
          Text('Skills will appear here soon.', style: AppTextStyles.h3()),
          SizedBox(height: 6.h),
          Text('Check another category or refresh the page.', style: AppTextStyles.small()),
        ],
      ),
    );
  }
}
