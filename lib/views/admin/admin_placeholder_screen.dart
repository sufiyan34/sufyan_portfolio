import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/widgets/admin_shell.dart';

class AdminPlaceholderScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const AdminPlaceholderScreen({
    super.key,
    required this.title,
    required this.description,
    this.icon = Iconsax.code_1,
  });

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: title,
      eyebrow: 'Admin workspace',
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(28.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 560.w),
            child: Container(
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  Container(
                    width: 66.w,
                    height: 66.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 28.sp),
                  ).animate().scale(duration: 450.ms, curve: Curves.easeOutBack),
                  SizedBox(height: 22.h),
                  Text(title, style: AppTextStyles.h2().copyWith(fontSize: 26.sp))
                      .animate(delay: 70.ms)
                      .fadeIn(duration: 400.ms),
                  SizedBox(height: 9.h),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body().copyWith(fontSize: 13.5.sp),
                  ).animate(delay: 120.ms).fadeIn(duration: 400.ms),
                  SizedBox(height: 24.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Module scheduled for the next implementation step',
                      style: AppTextStyles.small(color: AppColors.textSecondary)
                          .copyWith(fontSize: 10.5.sp),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.offAllNamed(AppRoutes.adminDashboard),
                      icon: const Icon(Iconsax.arrow_left_2),
                      label: const Text('Back to Dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: Size(double.infinity, 52.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
