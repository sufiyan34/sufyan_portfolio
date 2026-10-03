import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/services_controller.dart';
import 'package:sufyan_portfolio/widgets/app_footer.dart';
import 'package:sufyan_portfolio/widgets/public_navbar.dart';
import 'package:sufyan_portfolio/widgets/service_card.dart';
import 'package:sufyan_portfolio/widgets/service_icon.dart';
import 'package:sufyan_portfolio/widgets/service_skeletons.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServicesController());
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1200;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PublicNavbar(activeRoute: AppRoutes.services),
      body: ListView(
        shrinkWrap: true,
        children: [
          RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: controller.loadServices,
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              // const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64.w : 20.w,
                vertical: isDesktop ? 62.h : 40.h,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1320.w),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const ServicesPageSkeleton();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIntro(),
                        SizedBox(height: 26.h),
                        _CategoryRow(controller: controller),
                        SizedBox(height: 30.h),
                        if (controller.filteredServices.isEmpty)
                          const _EmptyServicesState()
                        else
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = constraints.maxWidth >= 1120
                                  ? 3
                                  : constraints.maxWidth >= 700
                                  ? 2
                                  : 1;

                              final spacing = 18.w;

                              final cardWidth = columns == 1
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth -
                                            (spacing * (columns - 1))) /
                                        columns;

                              return Wrap(
                                spacing: spacing,
                                runSpacing: 18.h,
                                children: List.generate(
                                  controller.filteredServices.length,
                                  (index) {
                                    return SizedBox(
                                      width: cardWidth,
                                      child:
                                          ServiceCard(
                                                service: controller
                                                    .filteredServices[index],
                                              )
                                              .animate()
                                              .fadeIn(
                                                delay: Duration(
                                                  milliseconds:
                                                      60 * (index % 6),
                                                ),
                                                duration: const Duration(
                                                  milliseconds: 360,
                                                ),
                                              )
                                              .slideY(
                                                begin: 0.03,
                                                end: 0,
                                                curve: Curves.easeOut,
                                              ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        SizedBox(height: 40.h),
                        _buildBottomCta(),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
          AppFooter(),
        ],
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
              Text('WHAT I DO', style: AppTextStyles.overline()),
              SizedBox(height: 10.h),
              Text('My Services', style: AppTextStyles.h1()),
              SizedBox(height: 10.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 720.w),
                child: Text(
                  'Focused digital services for products that need to feel clear, dependable, and genuinely useful — from polished Flutter apps to practical backend integrations.',
                  style: AppTextStyles.body(),
                ),
              ),
            ],
          );

          final aside = Container(
            constraints: BoxConstraints(maxWidth: 310.w),
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
                    'Human-centered delivery, technical clarity, and build-ready implementation.',
                    style: AppTextStyles.small(color: AppColors.textPrimary)
                        .copyWith(height: 1.55),
                  ),
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                SizedBox(height: 20.h),
                aside,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: copy),
              SizedBox(width: 28.w),
              aside,
            ],
          );
        },
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildBottomCta() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have a project in mind?',
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.textOnPrimary,
                  ).copyWith(fontSize: 15.sp),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Let\'s turn the right service mix into something useful.',
                  style: AppTextStyles.small(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.hireUs),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Hire Me',
                style: AppTextStyles.bodyMedium(color: AppColors.textPrimary)
                    .copyWith(fontSize: 13.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final ServicesController controller;

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

  const _FilterPill({
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
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

class _EmptyServicesState extends StatelessWidget {
  const _EmptyServicesState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 42.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ServiceIconBadge(iconKey: 'support', size: 56),
          SizedBox(height: 16.h),
          Text(
            'No services in this category',
            style: AppTextStyles.h3().copyWith(fontSize: 20.sp),
          ),
          SizedBox(height: 7.h),
          Text(
            'Try another filter to explore the services currently available.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body().copyWith(fontSize: 13.5.sp),
          ),
        ],
      ),
    );
  }
}
