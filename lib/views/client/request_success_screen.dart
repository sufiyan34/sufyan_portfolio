import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/widgets/app_footer.dart';

class RequestSuccessScreen extends StatelessWidget {
  const RequestSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments is Map
        ? Map<String, dynamic>.from(Get.arguments as Map)
        : <String, dynamic>{};
    final requestId = args['requestId']?.toString() ?? '';
    final projectName = args['projectName']?.toString() ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(22.w),
            child: Column(
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 620.w),
                  padding: EdgeInsets.all(32.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(26.r),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.featureShadow,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 78.w,
                        height: 78.w,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.tick_circle,
                          color: AppColors.primary,
                          size: 40.sp,
                        ),
                      ).animate().scale(
                        curve: Curves.easeOutBack,
                        duration: 500.ms,
                      ),
                      SizedBox(height: 22.h),
                      Text(
                        'Request received',
                        style: AppTextStyles.h1().copyWith(fontSize: 38.sp),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 9.h),
                      Text(
                        projectName.isEmpty
                            ? 'Thanks for sending your project brief.'
                            : 'Thanks for sending the brief for “$projectName”.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body().copyWith(height: 1.65),
                      ),
                      SizedBox(height: 22.h),
                      if (requestId.isNotEmpty)
                        InkWell(
                          borderRadius: BorderRadius.circular(14.r),
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(text: requestId),
                            );
                            Get.snackbar(
                              'Copied',
                              'Your request reference has been copied.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.primary,
                              colorText: Colors.white,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSoft,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'REQUEST REFERENCE',
                                        style: AppTextStyles.overline()
                                            .copyWith(fontSize: 10.sp),
                                      ),
                                      SizedBox(height: 4.h),
                                      SelectableText(
                                        requestId,
                                        style: AppTextStyles.bodyMedium()
                                            .copyWith(fontSize: 13.sp),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Iconsax.copy,
                                  size: 18.sp,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 18.h),
                      Text(
                        'I’ll review the requirements and contact you using your preferred contact method. Keep the reference above for your records.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.small().copyWith(height: 1.6),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.offAllNamed(AppRoutes.home),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.border),
                                minimumSize: Size(double.infinity, 48.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: const Text('Back Home'),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  Get.offAllNamed(AppRoutes.projects),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: Size(double.infinity, 48.h),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: const Text('View Projects'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
