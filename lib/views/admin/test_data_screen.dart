import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/test_data_controller.dart';
import 'package:sufyan_portfolio/widgets/admin_shell.dart';

class TestDataScreen extends StatelessWidget {
  const TestDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TestDataController());

    return AdminShell(
      title: 'Test Data',
      eyebrow: 'Developer tools',
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 30.h),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1180.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IntroCard(controller: controller)
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 300)),
                SizedBox(height: 18.h),
                _PackageSeedCard(controller: controller)
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 70),
                      duration: const Duration(milliseconds: 320),
                    )
                    .slideY(begin: 0.02, end: 0),
                SizedBox(height: 18.h),
                _ServiceSeedCard(controller: controller)
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 120),
                      duration: const Duration(milliseconds: 320),
                    )
                    .slideY(begin: 0.02, end: 0),
                SizedBox(height: 18.h),
                _SkillSeedCard(controller: controller)
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 140),
                      duration: const Duration(milliseconds: 320),
                    )
                    .slideY(begin: 0.02, end: 0),
                SizedBox(height: 18.h),
                _ExperienceSeedCard(controller: controller)
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 160),
                      duration: const Duration(milliseconds: 320),
                    )
                    .slideY(begin: 0.02, end: 0),
                SizedBox(height: 18.h),
                _ProjectSeedCard(controller: controller)
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 180),
                      duration: const Duration(milliseconds: 320),
                    )
                    .slideY(begin: 0.02, end: 0),
                SizedBox(height: 18.h),
                _ComingSoonCard().animate().fadeIn(
                  delay: const Duration(milliseconds: 140),
                  duration: const Duration(milliseconds: 320),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final TestDataController controller;

  const _IntroCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 780;
          final actions = Obx(
            () => Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      controller.isSeedingAll.value ||
                          controller.isSeedingPackages.value ||
                          controller.isSeedingServices.value ||
                          controller.isSeedingSkills.value ||
                          controller.isSeedingExperiences.value ||
                          controller.isSeedingProjects.value
                      ? null
                      : controller.seedAllDemoData,
                  icon: controller.isSeedingAll.value
                      ? SizedBox(
                          width: 16.sp,
                          height: 16.sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Iconsax.flash_1),
                  label: Text(
                    controller.isSeedingAll.value
                        ? 'Uploading…'
                        : 'Upload All Demo Data',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 13.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          );

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DEVELOPER TESTING', style: AppTextStyles.overline()),
              SizedBox(height: 8.h),
              Text('Demo Data Center', style: AppTextStyles.h2()),
              SizedBox(height: 7.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 750.w),
                child: Text(
                  'Use this page during development to seed Firebase with realistic demo content in one click. Seeders use deterministic IDs, so running them again updates the same demo records instead of creating duplicates.',
                  style: AppTextStyles.body(),
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                SizedBox(height: 18.h),
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: copy),
              SizedBox(width: 24.w),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _PackageSeedCard extends StatelessWidget {
  final TestDataController controller;

  const _PackageSeedCard({required this.controller});

  static const _packages = [
    (
      title: 'Silver',
      subtitle: 'Focused essentials',
      price: 'PKR 75,000',
      color: AppColors.surface,
      icon: Iconsax.medal_star,
    ),
    (
      title: 'Gold',
      subtitle: 'Balanced & popular',
      price: 'PKR 150,000',
      color: AppColors.accentGoldSoft,
      icon: Iconsax.medal_star,
    ),
    (
      title: 'Premium',
      subtitle: 'Complete & premium',
      price: 'PKR 275,000',
      color: AppColors.primary,
      icon: Iconsax.crown_1,
    ),
    (
      title: 'Custom',
      subtitle: 'Built around your scope',
      price: 'Custom quote',
      color: AppColors.surfaceSoft,
      icon: Iconsax.setting_2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PACKAGES', style: AppTextStyles.overline()),
                    SizedBox(height: 7.h),
                    Text('Seed 4 demo packages', style: AppTextStyles.h3()),
                    SizedBox(height: 5.h),
                    Text(
                      'Silver, Gold, Premium and Custom will be written to the existing packages/ Firebase node.',
                      style: AppTextStyles.body(),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Obx(
                () => ElevatedButton.icon(
                  onPressed:
                      controller.isSeedingPackages.value ||
                          controller.isSeedingServices.value ||
                          controller.isSeedingAll.value
                      ? null
                      : controller.seedPackages,
                  icon: controller.isSeedingPackages.value
                      ? SizedBox(
                          width: 16.sp,
                          height: 16.sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Iconsax.cloud_add),
                  label: Text(
                    controller.isSeedingPackages.value
                        ? 'Uploading…'
                        : 'Upload Packages',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 960
                  ? 4
                  : constraints.maxWidth >= 640
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _packages.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: columns == 1 ? 2.9 : 1.7,
                ),
                itemBuilder: (_, index) {
                  final item = _packages[index];
                  final dark = item.title == 'Premium';
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(17.r),
                      border: Border.all(
                        color: dark ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: dark
                                ? Colors.white.withValues(alpha: 0.10)
                                : AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            size: 17.sp,
                            color: dark
                                ? AppColors.accentGold
                                : AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 11.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium(
                                  color: dark
                                      ? AppColors.textOnPrimary
                                      : AppColors.textPrimary,
                                ).copyWith(fontSize: 14.sp),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                item.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.small(
                                  color: dark
                                      ? AppColors.textOnPrimary.withValues(
                                          alpha: 0.68,
                                        )
                                      : AppColors.textSecondary,
                                ).copyWith(fontSize: 10.5.sp),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                item.price,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium(
                                  color: dark
                                      ? AppColors.accentGold
                                      : AppColors.primary,
                                ).copyWith(fontSize: 12.sp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(height: 16.h),
          Obx(() {
            if (controller.successMessage.value.isEmpty &&
                controller.errorMessage.value.isEmpty) {
              return const SizedBox.shrink();
            }
            final success = controller.errorMessage.value.isEmpty;
            final message = success
                ? controller.successMessage.value
                : controller.errorMessage.value;
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(13.w),
              decoration: BoxDecoration(
                color: success
                    ? AppColors.success.withValues(alpha: 0.08)
                    : AppColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(13.r),
                border: Border.all(
                  color: success
                      ? AppColors.success.withValues(alpha: 0.18)
                      : AppColors.danger.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    success ? Icons.check_circle_outline : Icons.error_outline,
                    size: 18.sp,
                    color: success ? AppColors.success : AppColors.danger,
                  ),
                  SizedBox(width: 9.w),
                  Expanded(
                    child: Text(
                      message,
                      style: AppTextStyles.small(
                        color: success ? AppColors.success : AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ServiceSeedCard extends StatelessWidget {
  final TestDataController controller;

  const _ServiceSeedCard({required this.controller});

  static const _services = [
    (
      title: 'Flutter App Development',
      subtitle: 'Android & iOS',
      icon: Icons.phone_android_rounded,
    ),
    (
      title: 'Flutter Web Development',
      subtitle: 'Websites & portals',
      icon: Icons.language_rounded,
    ),
    (
      title: 'Firebase & Backend',
      subtitle: 'Auth, data & cloud',
      icon: Icons.local_fire_department_rounded,
    ),
    (
      title: 'API Integration',
      subtitle: 'REST & third-party APIs',
      icon: Icons.api_rounded,
    ),
    (
      title: 'Business Systems',
      subtitle: 'Dashboards & workflows',
      icon: Icons.business_center_rounded,
    ),
    (
      title: 'UI/UX Implementation',
      subtitle: 'Responsive product UI',
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final heading = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SERVICES', style: AppTextStyles.overline()),
                  SizedBox(height: 7.h),
                  Text('Seed 6 demo services', style: AppTextStyles.h3()),
                  SizedBox(height: 5.h),
                  Text(
                    'Flutter, web, Firebase, APIs, business systems, and UI/UX services will be written to the existing services/ Firebase node.',
                    style: AppTextStyles.body(),
                  ),
                ],
              );

              final button = Obx(
                () => ElevatedButton.icon(
                  onPressed:
                      controller.isSeedingServices.value ||
                          controller.isSeedingPackages.value ||
                          controller.isSeedingAll.value
                      ? null
                      : controller.seedServices,
                  icon: controller.isSeedingServices.value
                      ? SizedBox(
                          width: 16.sp,
                          height: 16.sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Iconsax.cloud_add),
                  label: Text(
                    controller.isSeedingServices.value
                        ? 'Uploading…'
                        : 'Upload Services',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading,
                    SizedBox(height: 16.h),
                    button,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: heading),
                  SizedBox(width: 16.w),
                  button,
                ],
              );
            },
          ),
          SizedBox(height: 20.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 960
                  ? 3
                  : constraints.maxWidth >= 640
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _services.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: columns == 1 ? 3.4 : 2.35,
                ),
                itemBuilder: (_, index) {
                  final item = _services[index];
                  return Container(
                    padding: EdgeInsets.all(15.w),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(17.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38.w,
                          height: 38.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(
                            item.icon,
                            size: 18.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 11.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium().copyWith(
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                item.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.small().copyWith(
                                  fontSize: 10.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SkillSeedCard extends StatelessWidget {
  final TestDataController controller;

  const _SkillSeedCard({required this.controller});

  static const _groups = [
    ('Core Flutter', 'Flutter • Dart • GetX', Icons.phone_android_rounded),
    (
      'Backend & Cloud',
      'Firebase • REST • Supabase',
      Icons.cloud_queue_rounded,
    ),
    (
      'Architecture',
      'MVVM • Clean Architecture • RBAC',
      Icons.account_tree_rounded,
    ),
    (
      'Tools & Integration',
      'GitHub • Postman • ZKTeco • Gemini',
      Icons.build_circle_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SKILLS', style: AppTextStyles.overline()),
                    SizedBox(height: 7.h),
                    Text('Seed developer skills', style: AppTextStyles.h3()),
                    SizedBox(height: 5.h),
                    Text(
                      'Seeds the technologies, architecture, integrations, and tools from your current developer profile into the skills/ Firebase node.',
                      style: AppTextStyles.body(),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Obx(
                () => ElevatedButton.icon(
                  onPressed:
                      controller.isSeedingPackages.value ||
                          controller.isSeedingServices.value ||
                          controller.isSeedingSkills.value ||
                          controller.isSeedingAll.value
                      ? null
                      : controller.seedSkills,
                  icon: controller.isSeedingSkills.value
                      ? SizedBox(
                          width: 16.sp,
                          height: 16.sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    controller.isSeedingSkills.value
                        ? 'Uploading…'
                        : 'Upload Skills',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 960
                  ? 4
                  : constraints.maxWidth >= 640
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _groups.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: columns == 1 ? 3.2 : 1.85,
                ),
                itemBuilder: (_, index) {
                  final item = _groups[index];
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(17.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38.w,
                          height: 38.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.$3,
                            size: 18.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.$1,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium().copyWith(
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                item.$2,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.small(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExperienceSeedCard extends StatelessWidget {
  final TestDataController controller;

  const _ExperienceSeedCard({required this.controller});

  static const _experiences = [
    (
      role: 'Web Developer',
      company: 'Dawood Designers',
      period: 'June 2026 — Present',
      icon: Icons.business_center_rounded,
      featured: true,
    ),
    (
      role: 'Software Developer',
      company: 'Zerum Solutions',
      period: 'November 2025 — July 2026',
      icon: Icons.code_rounded,
      featured: true,
    ),
    (
      role: 'Flutter Developer',
      company: 'Squarenex Technologies',
      period: 'August 2024 — June 2025',
      icon: Icons.phone_android_rounded,
      featured: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final heading = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EXPERIENCE', style: AppTextStyles.overline()),
                  SizedBox(height: 7.h),
                  Text(
                    'Seed professional experience',
                    style: AppTextStyles.h3(),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'Seeds the three professional roles from your CV into the experiences/ Firebase node.',
                    style: AppTextStyles.body(),
                  ),
                ],
              );

              final button = Obx(
                () => ElevatedButton.icon(
                  onPressed:
                      controller.isSeedingPackages.value ||
                          controller.isSeedingServices.value ||
                          controller.isSeedingSkills.value ||
                          controller.isSeedingExperiences.value ||
                          controller.isSeedingProjects.value ||
                          controller.isSeedingAll.value
                      ? null
                      : controller.seedExperiences,
                  icon: controller.isSeedingExperiences.value
                      ? SizedBox(
                          width: 16.sp,
                          height: 16.sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.work_history_outlined),
                  label: Text(
                    controller.isSeedingExperiences.value
                        ? 'Uploading…'
                        : 'Upload Experience',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading,
                    SizedBox(height: 16.h),
                    button,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: heading),
                  SizedBox(width: 16.w),
                  button,
                ],
              );
            },
          ),
          SizedBox(height: 20.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 960
                  ? 3
                  : constraints.maxWidth >= 640
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _experiences.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: columns == 1 ? 3.6 : 2.0,
                ),
                itemBuilder: (_, index) {
                  final item = _experiences[index];
                  return Container(
                    padding: EdgeInsets.all(15.w),
                    decoration: BoxDecoration(
                      color: item.featured
                          ? AppColors.primarySoft
                          : AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(17.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(
                            item.icon,
                            size: 19.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 11.w),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.role,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium().copyWith(
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                item.company,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.small(),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                item.period,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.small(
                                  color: AppColors.primary,
                                ).copyWith(fontSize: 10.5.sp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectSeedCard extends StatelessWidget {
  final TestDataController controller;

  const _ProjectSeedCard({required this.controller});

  static const _projects = [
    (
      title: 'DDE Portal',
      subtitle: 'Flutter Web • Firebase • Business System',
      icon: Iconsax.briefcase,
      featured: true,
    ),
    (
      title: 'ZKTeco Attendance Bridge',
      subtitle: 'Python • Firebase • ZKTeco K40',
      icon: Iconsax.finger_scan,
      featured: true,
    ),
    (
      title: 'Mega Safari Zoo',
      subtitle: 'Flutter • Firebase • QR Ticketing',
      icon: Iconsax.ticket,
      featured: true,
    ),
    (
      title: 'Asaan Card',
      subtitle: 'Flutter • Firebase • Digital Wallet',
      icon: Iconsax.card,
      featured: true,
    ),
    (
      title: 'Rehma',
      subtitle: 'Flutter • Food Ordering Platform',
      icon: Iconsax.cake,
      featured: false,
    ),
    (
      title: 'BarberOnline.com',
      subtitle: 'Flutter • Booking Platform',
      icon: Iconsax.scissor,
      featured: false,
    ),
    (
      title: 'CaribSell',
      subtitle: 'Flutter • Marketplace Application',
      icon: Iconsax.shop,
      featured: false,
    ),
    (
      title: 'GaseBuddy',
      subtitle: 'Flutter • Firebase • Ordering App',
      icon: Iconsax.gas_station,
      featured: false,
    ),
    (
      title: 'Havoc CRM',
      subtitle: 'Flutter • REST API • JWT • Dio',
      icon: Iconsax.data,
      featured: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final heading = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PROJECTS', style: AppTextStyles.overline()),
                  SizedBox(height: 7.h),
                  Text('Seed portfolio projects', style: AppTextStyles.h3()),
                  SizedBox(height: 5.h),
                  Text(
                    'Seeds the selected real projects from your portfolio into the projects/ Firebase node.',
                    style: AppTextStyles.body(),
                  ),
                ],
              );

              final button = Obx(
                () => ElevatedButton.icon(
                  onPressed:
                      controller.isSeedingPackages.value ||
                          controller.isSeedingServices.value ||
                          controller.isSeedingSkills.value ||
                          controller.isSeedingExperiences.value ||
                          controller.isSeedingProjects.value ||
                          controller.isSeedingAll.value
                      ? null
                      : controller.seedProjects,
                  icon: controller.isSeedingProjects.value
                      ? SizedBox(
                          width: 16.sp,
                          height: 16.sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Iconsax.folder_cloud),
                  label: Text(
                    controller.isSeedingProjects.value
                        ? 'Uploading…'
                        : 'Upload Projects',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading,
                    SizedBox(height: 16.h),
                    button,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: heading),
                  SizedBox(width: 16.w),
                  button,
                ],
              );
            },
          ),
          SizedBox(height: 20.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 960
                  ? 3
                  : constraints.maxWidth >= 640
                  ? 2
                  : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _projects.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: columns == 1 ? 3.3 : 1.95,
                ),
                itemBuilder: (_, index) {
                  final item = _projects[index];

                  return Container(
                    padding: EdgeInsets.all(15.w),
                    decoration: BoxDecoration(
                      color: item.featured
                          ? AppColors.primarySoft
                          : AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(17.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: item.featured
                                ? AppColors.surface
                                : AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(
                            item.icon,
                            size: 19.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 11.w),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium().copyWith(
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                item.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.small(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Skills', Iconsax.flash_1),
      ('Testimonials', Iconsax.message_favorite),
      ('Experience', Iconsax.timer),
      ('Hire Requests', Iconsax.briefcase),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(21.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NEXT SEEDERS', style: AppTextStyles.overline()),
          SizedBox(height: 7.h),
          Text(
            'More one-click demo data will live here',
            style: AppTextStyles.h3(),
          ),
          SizedBox(height: 5.h),
          Text(
            'This area is reserved for the next Firebase demo datasets so the testing page stays the single place for development seeding.',
            style: AppTextStyles.body(),
          ),
          SizedBox(height: 15.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: items
                .map(
                  (item) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 11.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.$2, size: 14.sp, color: AppColors.textMuted),
                        SizedBox(width: 6.w),
                        Text(item.$1, style: AppTextStyles.small()),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
