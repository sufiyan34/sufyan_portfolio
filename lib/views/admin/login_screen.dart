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

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

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
                if (desktop) const Expanded(flex: 6, child: _LoginEditorialPanel()),
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
                        child: _LoginForm(controller: controller),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoginEditorialPanel extends StatelessWidget {
  const _LoginEditorialPanel();

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
                'Sufyan Portfolio',
                style: AppTextStyles.bodyMedium(color: Colors.white)
                    .copyWith(fontSize: 13.sp),
              ),
            ],
          ),
          const Spacer(),
          Text(
            'Private workspace\nfor a public-facing portfolio.',
            style: AppTextStyles.h1(color: Colors.white).copyWith(
              fontSize: 42.sp,
              height: 1.06,
            ),
          )
              .animate()
              .fadeIn(duration: 650.ms)
              .slideY(begin: .12, end: 0, curve: Curves.easeOutCubic),
          SizedBox(height: 20.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 540.w),
            child: Text(
              'Manage projects, services, skills, packages and client requests from one calm, focused control center.',
              style: AppTextStyles.body(
                color: Colors.white.withValues(alpha: 0.68),
              ).copyWith(fontSize: 15.sp),
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 500.ms),
          SizedBox(height: 30.h),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Pill(icon: Iconsax.lock_1, label: 'Private admin access'),
              _Pill(icon: Iconsax.cloud, label: 'Firebase powered'),
              _Pill(icon: Iconsax.shield_tick, label: 'Role protected'),
            ],
          ).animate(delay: 200.ms).fadeIn(duration: 450.ms),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: Colors.white.withValues(alpha: 0.72)),
          SizedBox(width: 7.w),
          Text(
            label,
            style: AppTextStyles.small(color: Colors.white.withValues(alpha: 0.72))
                .copyWith(fontSize: 10.5.sp),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final AdminAuthController controller;
  const _LoginForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Admin Login', style: AppTextStyles.h2()).animate().fadeIn(duration: 450.ms),
        SizedBox(height: 7.h),
        Text(
          'Sign in to manage your portfolio.',
          style: AppTextStyles.body().copyWith(fontSize: 14.sp),
        ).animate(delay: 80.ms).fadeIn(duration: 450.ms),
        SizedBox(height: 30.h),
        Obx(() {
          if (controller.isLoading.value) return const AuthFormSkeleton();
          return Column(
            children: [
              _AuthField(
                controller: controller.loginEmailController,
                label: 'Email address',
                hint: 'admin@example.com',
                icon: Iconsax.sms,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 14.h),
              _AuthField(
                controller: controller.loginPasswordController,
                label: 'Password',
                hint: 'Enter your password',
                icon: Iconsax.lock_1,
                obscure: controller.obscurePassword,
              ),
              SizedBox(height: 14.h),
              Obx(() {
                final message = controller.errorMessage.value;
                if (message == null || message.isEmpty) return const SizedBox.shrink();
                return _ErrorBanner(message: message);
              }),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: Size(double.infinity, 54.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: const Text('Sign In'),
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Iconsax.info_circle, size: 17.sp, color: AppColors.primary),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Use an account with an active admin profile in Firebase Realtime Database.',
                        style: AppTextStyles.small(color: AppColors.textSecondary)
                            .copyWith(fontSize: 11.sp),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Need to create the first admin?', style: AppTextStyles.small().copyWith(fontSize: 11.5.sp)),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.signUP),
                    child: Text(
                      'Sign up',
                      style: AppTextStyles.small(color: AppColors.primary)
                          .copyWith(fontSize: 11.5.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 350.ms);
        }),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final RxBool? obscure;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.small(color: AppColors.textPrimary).copyWith(fontSize: 11.5.sp)),
        SizedBox(height: 7.h),
        if (obscure != null)
          Obx(() => _field(obscure?.value ?? false))
        else
          _field(false),
      ],
    );
  }

  Widget _field(bool isObscured) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      keyboardType: keyboardType,
      style: AppTextStyles.body(color: AppColors.textPrimary).copyWith(fontSize: 13.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.small().copyWith(fontSize: 12.sp),
        prefixIcon: Icon(icon, size: 18.sp),
        suffixIcon: obscure == null
            ? null
            : IconButton(
                onPressed: () => obscure!.toggle(),
                icon: Icon(
                  isObscured ? Iconsax.eye_slash : Iconsax.eye,
                  size: 18.sp,
                ),
              ),
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
      ),
    );
  }
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
