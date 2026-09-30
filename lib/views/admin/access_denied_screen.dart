import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 520.w),
            child: Container(
              padding: EdgeInsets.all(34.w),
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
                    width: 68.w,
                    height: 68.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accentGoldSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Iconsax.shield_cross, size: 31.sp, color: AppColors.accentGold),
                  ).animate().scale(duration: 450.ms, curve: Curves.easeOutBack),
                  SizedBox(height: 22.h),
                  Text('Access restricted', style: AppTextStyles.h2()).animate().fadeIn(),
                  SizedBox(height: 10.h),
                  Text(
                    'Your account is authenticated, but it is not currently authorized for the admin workspace.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body().copyWith(fontSize: 14.sp),
                  ).animate(delay: 80.ms).fadeIn(),
                  SizedBox(height: 26.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.offAllNamed(AppRoutes.login),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: Size(double.infinity, 52.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: const Text('Return to Login'),
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
