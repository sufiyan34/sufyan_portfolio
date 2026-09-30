import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/projects_controller.dart';
import 'package:sufyan_portfolio/models/project_model.dart';
import 'package:sufyan_portfolio/widgets/project_card.dart';
import 'package:sufyan_portfolio/widgets/public_navbar.dart';

/// Public "My Projects" page — per PORTFOLIO_UI_DESIGN_SPEC.md. Filter
/// pills (All / Flutter / Web / Firebase / Business / E-Commerce / UI-UX)
/// above a responsive grid of [ProjectCard]s, reading from
/// [ProjectsController] (backed by the `projects` Firebase node).
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProjectsController());
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1200;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PublicNavbar(activeRoute: AppRoutes.projects),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48.w : 20.w,
            vertical: isDesktop ? 64.h : 40.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Projects',
                style: AppTextStyles.h1(),
              ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
              SizedBox(height: 8.h),
              Text(
                'Some of my recent work.',
                style: AppTextStyles.body(),
              ),
              SizedBox(height: 28.h),
              _CategoryFilterRow(controller: controller),
              SizedBox(height: 28.h),
              Obx(() {
                if (controller.isLoading.value) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 80.h),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                final projects = controller.filteredProjects;

                if (projects.isEmpty) {
                  return _EmptyState();
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400.w,
                    mainAxisSpacing: 24.h,
                    crossAxisSpacing: 24.w,
                    childAspectRatio: 0.86,
                  ),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return ProjectCard(
                      project: project,
                      onTap: () => Get.toNamed(
                        AppRoutes.projectDetails,
                        arguments: project.slug,
                      ),
                    ).animate().fadeIn(
                      delay: Duration(milliseconds: 60 * (index % 6)),
                      duration: const Duration(milliseconds: 350),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryFilterRow extends StatelessWidget {
  final ProjectsController controller;
  const _CategoryFilterRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final categories = [kAllCategoriesFilter, ...ProjectCategories.all];

    return Obx(() {
      return Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: [
          for (final category in categories)
            _FilterChip(
              label: category,
              selected: controller.selectedCategory.value == category,
              onTap: () => controller.selectCategory(category),
            ),
        ],
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium(
              color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
            ).copyWith(fontSize: 13.5.sp),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 80.h),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_rounded, size: 48.sp, color: AppColors.textMuted),
            SizedBox(height: 14.h),
            Text('No projects in this category yet', style: AppTextStyles.h3()),
          ],
        ),
      ),
    );
  }
}
