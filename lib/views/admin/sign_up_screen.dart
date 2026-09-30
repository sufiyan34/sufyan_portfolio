import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/admin_auth_controller.dart';
import 'package:sufyan_portfolio/widgets/admin_auth_skeletons.dart';

class AdminSignUpScreen extends StatelessWidget {
  const AdminSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AdminAuthController>()
        ? Get.find<AdminAuthController>()
        : Get.put(AdminAuthController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 980;

            return Row(
              children: [
                Expanded(
                  flex: desktop ? 5 : 1,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: desktop ? 58.w : 24.w,
                        vertical: 36.h,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: desktop ? 480.w : 520.w),
                        child: _SignUpForm(controller: controller),
                      ),
                    ),
                  ),
                ),
                if (desktop) const Expanded(flex: 6, child: _SignUpEditorialPanel()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SignUpEditorialPanel extends StatelessWidget {
  const _SignUpEditorialPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(18.w),
      padding: EdgeInsets.all(46.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  'MS',
                  style: AppTextStyles.bodyMedium(color: Colors.white)
                      .copyWith(fontSize: 15.sp, letterSpacing: 0.6),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Admin onboarding',
                style: AppTextStyles.bodyMedium(color: Colors.white)
                    .copyWith(fontSize: 13.sp),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.22)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.shield_tick, color: AppColors.accentGold, size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Bootstrap account · Firebase Authentication + Realtime Database',
                    style: AppTextStyles.small(color: Colors.white.withValues(alpha: 0.78))
                        .copyWith(fontSize: 11.sp),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 450.ms),
          SizedBox(height: 22.h),
          Text(
            'Create the account\nthat runs the workspace.',
            style: AppTextStyles.h1(color: Colors.white).copyWith(
              fontSize: 42.sp,
              height: 1.06,
            ),
          )
              .animate(delay: 80.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: .12, end: 0, curve: Curves.easeOutCubic),
          SizedBox(height: 20.h),
          Text(
            'Your account controls portfolio content, client requests and future site settings.',
            style: AppTextStyles.body(color: Colors.white.withValues(alpha: 0.68))
                .copyWith(fontSize: 15.sp),
          ).animate(delay: 160.ms).fadeIn(duration: 450.ms),
        ],
      ),
    );
  }
}

class _SignUpForm extends StatelessWidget {
  final AdminAuthController controller;
  const _SignUpForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Create Admin Account', style: AppTextStyles.h2())
            .animate()
            .fadeIn(duration: 450.ms),
        SizedBox(height: 7.h),
        Text(
          'Set up the first administrator for your portfolio.',
          style: AppTextStyles.body().copyWith(fontSize: 14.sp),
        ).animate(delay: 70.ms).fadeIn(duration: 450.ms),
        SizedBox(height: 30.h),
        Obx(() {
          if (controller.isLoading.value) return const AuthFormSkeleton();

          return Column(
            children: [
              _Field(
                controller: controller.nameController,
                label: 'Full name',
                hint: 'Muhammad Sufyan',
                icon: Iconsax.user,
              ),
              SizedBox(height: 14.h),
              _Field(
                controller: controller.signUpEmailController,
                label: 'Email address',
                hint: 'admin@example.com',
                icon: Iconsax.sms,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 14.h),
              _PasswordField(
                controller: controller.signUpPasswordController,
                label: 'Password',
                hint: 'Minimum 6 characters',
                obscure: controller.obscurePassword,
              ),
              SizedBox(height: 14.h),
              _PasswordField(
                controller: controller.confirmPasswordController,
                label: 'Confirm password',
                hint: 'Repeat your password',
                obscure: controller.obscureConfirmPassword,
              ),
              SizedBox(height: 14.h),
              Obx(() {
                final message = controller.errorMessage.value;
                if (message == null || message.isEmpty) return const SizedBox.shrink();
                return _ErrorBanner(message: message);
              }),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: Size(double.infinity, 54.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: const Text('Create Admin Account'),
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have access?', style: AppTextStyles.small().copyWith(fontSize: 11.5.sp)),
                  TextButton(
                    onPressed: () => Get.offNamed(AppRoutes.login),
                    child: Text(
                      'Sign in',
                      style: AppTextStyles.small(color: AppColors.primary)
                          .copyWith(fontSize: 11.5.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'For production, lock down sign-up after your bootstrap administrator is created.',
                textAlign: TextAlign.center,
                style: AppTextStyles.small(color: AppColors.textMuted).copyWith(fontSize: 10.5.sp),
              ),
            ],
          ).animate(delay: 120.ms).fadeIn(duration: 350.ms);
        }),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.small(color: AppColors.textPrimary).copyWith(fontSize: 11.5.sp)),
        SizedBox(height: 7.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.body(color: AppColors.textPrimary).copyWith(fontSize: 13.sp),
          decoration: _decoration(hint: hint, icon: icon),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final RxBool obscure;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.small(color: AppColors.textPrimary).copyWith(fontSize: 11.5.sp)),
        SizedBox(height: 7.h),
        Obx(
          () => TextField(
            controller: controller,
            obscureText: obscure.value,
            style: AppTextStyles.body(color: AppColors.textPrimary).copyWith(fontSize: 13.sp),
            decoration: _decoration(
              hint: hint,
              icon: Iconsax.lock_1,
              suffix: IconButton(
                onPressed: obscure.toggle,
                icon: Icon(
                  obscure.value ? Iconsax.eye_slash : Iconsax.eye,
                  size: 18.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

InputDecoration _decoration({
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.small().copyWith(fontSize: 12.sp),
    prefixIcon: Icon(icon, size: 18.sp),
    suffixIcon: suffix,
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
  );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEAE3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.warning_2, size: 17.sp, color: AppColors.danger),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.small(color: AppColors.danger).copyWith(fontSize: 11.sp),
            ),
          ),
        ],
      ),
    );
  }
}
