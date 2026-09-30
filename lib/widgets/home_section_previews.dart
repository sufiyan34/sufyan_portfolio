import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/packages_controller.dart';
import 'package:sufyan_portfolio/controllers/projects_controller.dart';
import 'package:sufyan_portfolio/controllers/services_controller.dart';
import 'package:sufyan_portfolio/controllers/skills_controller.dart';
import 'package:sufyan_portfolio/widgets/package_card.dart';
import 'package:sufyan_portfolio/widgets/project_card.dart';
import 'package:sufyan_portfolio/widgets/service_card.dart';
import 'package:sufyan_portfolio/widgets/skill_card.dart';

class HomeSectionPreviews extends StatelessWidget {
  const HomeSectionPreviews({super.key});

  @override
  Widget build(BuildContext context) {
    final maxWidth = 1320.w;

    return Column(
      children: [
        _SkillsPreview(maxWidth: maxWidth),
        _ServicesPreview(maxWidth: maxWidth),
        _PackagesPreview(maxWidth: maxWidth),
        _ProjectsPreview(maxWidth: maxWidth),
      ],
    );
  }
}

class _HomeSectionShell extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final String route;
  final Widget child;
  final double maxWidth;

  const _HomeSectionShell({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.child,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 52.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(eyebrow, style: AppTextStyles.overline().copyWith(fontSize: 10.5.sp)),
                        SizedBox(height: 7.h),
                        Text(title, style: AppTextStyles.h2().copyWith(fontSize: 29.sp)),
                        SizedBox(height: 6.h),
                        Text(subtitle, style: AppTextStyles.body().copyWith(fontSize: 12.5.sp)),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  _SeeAllButton(route: route),
                ],
              ),
              SizedBox(height: 22.h),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _SeeAllButton extends StatelessWidget {
  final String route;
  const _SeeAllButton({required this.route});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => Get.toNamed(route),
      icon: Icon(Icons.arrow_forward_rounded, size: 14.sp),
      label: Text('See All', style: AppTextStyles.bodyMedium().copyWith(fontSize: 11.5.sp)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.border),
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999.r)),
      ),
    );
  }
}

class _SkillsPreview extends StatelessWidget {
  final double maxWidth;
  const _SkillsPreview({required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SkillsController());
    return _HomeSectionShell(
      eyebrow: 'CAPABILITIES',
      title: 'Skills',
      subtitle: 'The tools and technologies I use to build reliable digital products.',
      route: AppRoutes.skills,
      maxWidth: maxWidth,
      child: Obx(() {
        if (controller.isLoading.value) return const _PreviewLoading();
        final items = controller.skills.take(6).toList();
        if (items.isEmpty) return const _PreviewEmpty(label: 'Skills will appear here.');
        return _ResponsiveGrid<Widget>(
          count: items.length,
          builder: (index) => SkillCard(skill: items[index]),
          mobileAspect: 1.35,
          desktopAspect: 1.12,
        );
      }),
    );
  }
}

class _ServicesPreview extends StatelessWidget {
  final double maxWidth;
  const _ServicesPreview({required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServicesController());
    return _HomeSectionShell(
      eyebrow: 'WHAT I DO',
      title: 'Services',
      subtitle: 'Focused development services for mobile, web and business applications.',
      route: AppRoutes.services,
      maxWidth: maxWidth,
      child: Obx(() {
        if (controller.isLoading.value) return const _PreviewLoading();
        final items = controller.services.take(6).toList();
        if (items.isEmpty) return const _PreviewEmpty(label: 'Services will appear here.');
        return _ResponsiveGrid<Widget>(
          count: items.length,
          builder: (index) => ServiceCard(service: items[index]),
          mobileAspect: 1.05,
          desktopAspect: 1.15,
        );
      }),
    );
  }
}

class _PackagesPreview extends StatelessWidget {
  final double maxWidth;
  const _PackagesPreview({required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PackagesController());
    return _HomeSectionShell(
      eyebrow: 'WAYS TO WORK TOGETHER',
      title: 'Packages',
      subtitle: 'Choose a clear scope or start a custom conversation around your project.',
      route: AppRoutes.packages,
      maxWidth: maxWidth,
      child: Obx(() {
        if (controller.isLoading.value) return const _PreviewLoading();
        final items = controller.packages.take(4).toList();
        if (items.isEmpty) return const _PreviewEmpty(label: 'Packages will appear here.');
        return _ResponsiveGrid<Widget>(
          count: items.length,
          builder: (index) => PackageCard(package: items[index]),
          mobileAspect: 0.64,
          desktopAspect: 0.61,
        );
      }),
    );
  }
}

class _ProjectsPreview extends StatelessWidget {
  final double maxWidth;
  const _ProjectsPreview({required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProjectsController());
    return _HomeSectionShell(
      eyebrow: 'SELECTED WORK',
      title: 'Projects',
      subtitle: 'A few recent builds across Flutter, web, Firebase and business systems.',
      route: AppRoutes.projects,
      maxWidth: maxWidth,
      child: Obx(() {
        if (controller.isLoading.value) return const _PreviewLoading();
        final items = controller.filteredProjects.take(6).toList();
        if (items.isEmpty) return const _PreviewEmpty(label: 'Projects will appear here.');
        return _ResponsiveGrid<Widget>(
          count: items.length,
          builder: (index) => ProjectCard(
            project: items[index],
            onTap: () => Get.toNamed(AppRoutes.projectDetails, arguments: items[index].slug),
          ),
          mobileAspect: 0.93,
          desktopAspect: 0.86,
        );
      }),
    );
  }
}

class _ResponsiveGrid<T> extends StatelessWidget {
  final int count;
  final Widget Function(int index) builder;
  final double mobileAspect;
  final double desktopAspect;

  const _ResponsiveGrid({
    required this.count,
    required this.builder,
    required this.mobileAspect,
    required this.desktopAspect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1180 ? 3 : width >= 780 ? 2 : 1;
        final aspect = columns == 1 ? mobileAspect : desktopAspect;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 18.w,
            mainAxisSpacing: 18.h,
            childAspectRatio: aspect,
          ),
          itemBuilder: (_, index) => builder(index)
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 45 * (index % 6)),
                duration: const Duration(milliseconds: 320),
              )
              .slideY(begin: 0.025, end: 0, curve: Curves.easeOut),
        );
      },
    );
  }
}

class _PreviewLoading extends StatelessWidget {
  const _PreviewLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
      ),
      child: const CircularProgressIndicator(strokeWidth: 2.2),
    );
  }
}

class _PreviewEmpty extends StatelessWidget {
  final String label;
  const _PreviewEmpty({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 20.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppTextStyles.body()),
    );
  }
}
