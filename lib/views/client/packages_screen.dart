import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/packages_controller.dart';
import 'package:sufyan_portfolio/models/package_model.dart';
import 'package:sufyan_portfolio/widgets/package_card.dart';
import 'package:sufyan_portfolio/widgets/package_skeletons.dart';
import 'package:sufyan_portfolio/widgets/public_navbar.dart';

class PackagesScreen extends StatelessWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PackagesController());
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1200;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PublicNavbar(activeRoute: AppRoutes.packages),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: controller.loadPackages,
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
                if (controller.isLoading.value) return const PackagesPageSkeleton();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(),
                    SizedBox(height: 26.h),
                    _TypeFilters(controller: controller),
                    SizedBox(height: 30.h),
                    if (controller.filteredPackages.isEmpty)
                      const _EmptyPackagesState()
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 1180
                              ? 4
                              : constraints.maxWidth >= 760
                                  ? 2
                                  : 1;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.filteredPackages.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 18.w,
                              mainAxisSpacing: 18.h,
                              childAspectRatio: columns == 1 ? 0.66 : 0.58,
                            ),
                            itemBuilder: (_, index) {
                              final package = controller.filteredPackages[index];
                              return PackageCard(package: package)
                                  .animate()
                                  .fadeIn(
                                    delay: Duration(milliseconds: 65 * (index % 6)),
                                    duration: const Duration(milliseconds: 360),
                                  )
                                  .slideY(begin: 0.03, end: 0, curve: Curves.easeOut);
                            },
                          );
                        },
                      ),
                    SizedBox(height: 40.h),
                    _buildCustomCta(),
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
              Text('WAYS TO WORK TOGETHER', style: AppTextStyles.overline()),
              SizedBox(height: 10.h),
              Text('Our Packages', style: AppTextStyles.h1()),
              SizedBox(height: 10.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 735.w),
                child: Text(
                  'Choose a focused package for a defined scope, or use a custom package when the project needs a more tailored mix of design, development, support, and delivery.',
                  style: AppTextStyles.body(),
                ),
              ),
            ],
          );

          final aside = Container(
            constraints: BoxConstraints(maxWidth: 320.w),
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
                    'Transparent scope, human communication, and room for the technical details that matter.',
                    style: AppTextStyles.small(color: AppColors.textPrimary).copyWith(height: 1.55),
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
              SizedBox(width: 28.w),
              aside,
            ],
          );
        },
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildCustomCta() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 19.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need a package that does not fit the tiers?',
                  style: AppTextStyles.bodyMedium(color: AppColors.textOnPrimary).copyWith(fontSize: 15.sp),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Let’s shape a custom scope around your actual project requirements.',
                  style: AppTextStyles.small(color: AppColors.textOnPrimary.withValues(alpha: 0.72)),
                ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.hireUs),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Request Custom',
                style: AppTextStyles.bodyMedium(color: AppColors.textPrimary).copyWith(fontSize: 12.5.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeFilters extends StatelessWidget {
  final PackagesController controller;

  const _TypeFilters({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Wrap(
        spacing: 9.w,
        runSpacing: 9.h,
        children: controller.filters.map((type) {
          final selected = controller.selectedType.value == type;
          final label = type == kAllPackagesFilter ? 'All Packages' : PackageTypes.label(type);
          return InkWell(
            onTap: () => controller.selectType(type),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
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
                ).copyWith(fontSize: 11.8.sp, fontWeight: FontWeight.w700),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _EmptyPackagesState extends StatelessWidget {
  const _EmptyPackagesState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 52.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.layers_clear_rounded, size: 34.sp, color: AppColors.textMuted),
          SizedBox(height: 12.h),
          Text('No packages are published yet.', style: AppTextStyles.h3()),
          SizedBox(height: 7.h),
          Text(
            'Published packages will appear here once they are added from the admin area.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(),
          ),
        ],
      ),
    );
  }
}
