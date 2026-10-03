import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/admin_profile_controller.dart';
import 'package:sufyan_portfolio/widgets/admin_shell.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminProfileController>();

    return AdminShell(
      title: 'Profile & Settings',
      eyebrow: 'Account',
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return _Body(controller: controller);
      }),
    );
  }
}

class _Body extends StatelessWidget {
  final AdminProfileController controller;

  const _Body({required this.controller});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1000;

    final left = Column(
      children: [
        _SummaryCard(controller: controller),
        SizedBox(height: 16.h),
        _AccountCard(controller: controller),
      ],
    );

    final right = Column(
      children: [
        _PersonalInfoCard(controller: controller),
        SizedBox(height: 16.h),
        _SecurityCard(controller: controller),
        SizedBox(height: 16.h),
        _SessionCard(controller: controller),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(22.w, 20.h, 22.w, 32.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1200.w),
          child: Column(
            children: [
              Obx(() {
                final message = controller.loadError.value;
                if (message.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _Banner(message: message, color: AppColors.warning),
                );
              }),
              desktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: left),
                        SizedBox(width: 18.w),
                        Expanded(flex: 6, child: right),
                      ],
                    )
                  : Column(
                      children: [
                        left,
                        SizedBox(height: 16.h),
                        right,
                      ],
                    ),
            ],
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.02),
        ),
      ),
    );
  }
}

// ============================================================================
// SUMMARY (avatar + name + photo actions)
// ============================================================================

class _SummaryCard extends StatelessWidget {
  final AdminProfileController controller;

  const _SummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Obx(() {
        final profile = controller.profile.value;
        final uploading = controller.isUploadingPhoto.value;

        final name = (profile?.displayName ?? '').isEmpty
            ? 'Administrator'
            : profile!.displayName;
        final photoUrl = profile?.photoUrl ?? '';
        final jobTitle = profile?.jobTitle ?? '';

        return Column(
          children: [
            _Avatar(name: name, photoUrl: photoUrl, uploading: uploading),
            SizedBox(height: 14.h),
            Text(
              name,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3().copyWith(fontSize: 19.sp),
            ),
            if (jobTitle.isNotEmpty) ...[
              SizedBox(height: 3.h),
              Text(
                jobTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.small().copyWith(fontSize: 12.sp),
              ),
            ],
            SizedBox(height: 4.h),
            Text(
              controller.email,
              textAlign: TextAlign.center,
              style: AppTextStyles.small().copyWith(fontSize: 12.sp),
            ),
            SizedBox(height: 10.h),
            _Pill(
              label: profile?.roleLabel ?? 'Administrator',
              color: AppColors.primary,
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: uploading ? null : controller.changePhoto,
                    icon: Icon(Iconsax.camera, size: 16.sp),
                    label: Text(photoUrl.isEmpty ? 'Add photo' : 'Change'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.border),
                      minimumSize: Size(0, 44.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                if (photoUrl.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  IconButton(
                    tooltip: 'Remove photo',
                    onPressed: uploading ? null : controller.removePhoto,
                    icon: Icon(Iconsax.trash, size: 18.sp),
                    color: AppColors.danger,
                  ),
                ],
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Square image, up to 5 MB. JPG, PNG or WebP.',
              textAlign: TextAlign.center,
              style: AppTextStyles.small().copyWith(fontSize: 10.5.sp),
            ),
          ],
        );
      }),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String photoUrl;
  final bool uploading;

  const _Avatar({
    required this.name,
    required this.photoUrl,
    required this.uploading,
  });

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'AD';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final size = 104.w;

    Widget fallback() => Container(
      color: AppColors.primarySoft,
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: AppTextStyles.h2(color: AppColors.primary)
            .copyWith(fontSize: 32.sp),
      ),
    );

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (photoUrl.isEmpty)
              fallback()
            else
              CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => fallback(),
                errorWidget: (_, __, ___) => fallback(),
              ),
            if (uploading)
              Container(
                color: Colors.black.withValues(alpha: 0.42),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 26.w,
                  height: 26.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ACCOUNT DETAILS (read-only)
// ============================================================================

class _AccountCard extends StatelessWidget {
  final AdminProfileController controller;

  const _AccountCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Account details',
      child: Obx(() {
        final profile = controller.profile.value;
        final active = profile?.active ?? true;
        final verified = controller.emailVerified;

        return Column(
          children: [
            _InfoRow(
              label: 'Role',
              value: profile?.roleLabel ?? 'Administrator',
            ),
            _InfoRow(
              label: 'Status',
              valueWidget: _Pill(
                label: active ? 'Active' : 'Inactive',
                color: active ? AppColors.success : AppColors.danger,
              ),
            ),
            _InfoRow(
              label: 'Email',
              valueWidget: _Pill(
                label: verified ? 'Verified' : 'Not verified',
                color: verified ? AppColors.success : AppColors.warning,
              ),
            ),
            _InfoRow(label: 'Created', value: controller.createdLabel),
            _InfoRow(label: 'Last sign-in', value: controller.lastSignInLabel),
            _InfoRow(
              label: 'User ID',
              value: controller.uid,
              mono: true,
              onCopy: () async {
                await Clipboard.setData(ClipboardData(text: controller.uid));
                Get.snackbar(
                  'Copied',
                  'Your user ID has been copied.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primary,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  maxWidth: 420,
                );
              },
              last: true,
            ),
          ],
        );
      }),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool mono;
  final bool last;
  final VoidCallback? onCopy;

  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.mono = false,
    this.last = false,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 11.h),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 96.w,
            child: Text(
              label.toUpperCase(),
              style: AppTextStyles.overline(color: AppColors.textMuted)
                  .copyWith(fontSize: 9.5.sp, letterSpacing: 1.1),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child:
                  valueWidget ??
                  Text(
                    (value == null || value!.isEmpty) ? '—' : value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium().copyWith(
                      fontSize: mono ? 11.sp : 12.5.sp,
                    ),
                  ),
            ),
          ),
          if (onCopy != null)
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  Iconsax.copy,
                  size: 16.sp,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// PERSONAL INFORMATION
// ============================================================================

class _PersonalInfoCard extends StatelessWidget {
  final AdminProfileController controller;

  const _PersonalInfoCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Personal information',
      child: Form(
        key: controller.profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TwoCol(
              first: _field(
                controller: controller.nameController,
                label: 'Full name *',
                hint: 'Muhammad Sufyan',
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Your name is required.' : null,
              ),
              second: _field(
                controller: controller.jobTitleController,
                label: 'Job title',
                hint: 'Flutter Developer',
              ),
            ),
            SizedBox(height: 14.h),
            _TwoCol(
              first: _readOnlyField(
                label: 'Email address',
                value: controller.email,
              ),
              second: _field(
                controller: controller.phoneController,
                label: 'Phone / WhatsApp',
                hint: '+92 300 1234567',
                keyboardType: TextInputType.phone,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Your email is your sign-in and can’t be edited here.',
              style: AppTextStyles.small().copyWith(fontSize: 10.5.sp),
            ),
            SizedBox(height: 16.h),
            Obx(() {
              final error = controller.profileError.value;
              if (error.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: _Banner(message: error, color: AppColors.danger),
              );
            }),
            Obx(() {
              final saving = controller.isSavingProfile.value;
              return Align(
                alignment: Alignment.centerRight,
                child: _PrimaryButton(
                  label: 'Save Changes',
                  busyLabel: 'Saving…',
                  icon: Iconsax.tick_circle,
                  busy: saving,
                  onPressed: controller.saveProfile,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PASSWORD & SECURITY
// ============================================================================

class _SecurityCard extends StatelessWidget {
  final AdminProfileController controller;

  const _SecurityCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Password & security',
      child: Form(
        key: controller.passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _passwordField(
              controller: controller.currentPasswordController,
              obscure: controller.obscureCurrent,
              label: 'Current password *',
              validator: (v) =>
                  (v ?? '').isEmpty ? 'Enter your current password.' : null,
            ),
            SizedBox(height: 14.h),
            _TwoCol(
              first: _passwordField(
                controller: controller.newPasswordController,
                obscure: controller.obscureNew,
                label: 'New password *',
                validator: (v) {
                  final value = v ?? '';
                  if (value.length < 6) {
                    return 'Use at least 6 characters.';
                  }
                  if (value == controller.currentPasswordController.text) {
                    return 'Choose a different password.';
                  }
                  return null;
                },
              ),
              second: _passwordField(
                controller: controller.confirmPasswordController,
                obscure: controller.obscureConfirm,
                label: 'Confirm new password *',
                validator: (v) => v != controller.newPasswordController.text
                    ? 'Passwords do not match.'
                    : null,
              ),
            ),
            SizedBox(height: 14.h),
            Obx(() {
              final error = controller.passwordError.value;
              if (error.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: _Banner(message: error, color: AppColors.danger),
              );
            }),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 10.h,
              spacing: 12.w,
              children: [
                Obx(() {
                  final sending = controller.isSendingReset.value;
                  return TextButton.icon(
                    onPressed: sending ? null : controller.sendResetLink,
                    icon: sending
                        ? SizedBox(
                            width: 14.w,
                            height: 14.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(Iconsax.sms, size: 16.sp),
                    label: Text(
                      sending ? 'Sending…' : 'Email me a reset link instead',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: AppTextStyles.bodyMedium().copyWith(
                        fontSize: 12.sp,
                      ),
                    ),
                  );
                }),
                Obx(() {
                  final busy = controller.isChangingPassword.value;
                  return _PrimaryButton(
                    label: 'Update Password',
                    busyLabel: 'Updating…',
                    icon: Iconsax.lock_1,
                    busy: busy,
                    onPressed: controller.changePassword,
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required RxBool obscure,
    required String label,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        Obx(
          () => TextFormField(
            controller: controller,
            obscureText: obscure.value,
            validator: validator,
            style: AppTextStyles.body().copyWith(fontSize: 13.sp),
            decoration: _inputDecoration('••••••••').copyWith(
              suffixIcon: IconButton(
                onPressed: () => obscure.value = !obscure.value,
                icon: Icon(
                  obscure.value ? Iconsax.eye_slash : Iconsax.eye,
                  size: 18.sp,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SESSION
// ============================================================================

class _SessionCard extends StatelessWidget {
  final AdminProfileController controller;

  const _SessionCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Session',
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Sign out of the admin workspace on this device.',
              style: AppTextStyles.small().copyWith(
                fontSize: 12.sp,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          OutlinedButton.icon(
            onPressed: () => _confirmSignOut(context),
            icon: Icon(Iconsax.logout_1, size: 16.sp),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
              minimumSize: Size(0, 46.h),
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        title: Text(
          'Sign out?',
          style: AppTextStyles.h3().copyWith(fontSize: 18.sp),
        ),
        content: Text(
          'You’ll need to sign in again to reach the admin workspace.',
          style: AppTextStyles.body().copyWith(fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed == true) await controller.signOut();
  }
}

// ============================================================================
// SHARED BITS (same look as the other admin detail screens)
// ============================================================================

class _Card extends StatelessWidget {
  final String? title;
  final Widget child;

  const _Card({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
            ),
            SizedBox(height: 13.h),
          ],
          child,
        ],
      ),
    );
  }
}

class _TwoCol extends StatelessWidget {
  final Widget first;
  final Widget second;

  const _TwoCol({required this.first, required this.second});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 760;
    if (!wide) {
      return Column(
        children: [
          first,
          SizedBox(height: 14.h),
          second,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        SizedBox(width: 12.w),
        Expanded(child: second),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.small(color: color)
            .copyWith(fontSize: 10.5.sp, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String message;
  final Color color;

  const _Banner({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(message, style: AppTextStyles.small(color: color)),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final String busyLabel;
  final IconData icon;
  final bool busy;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.busyLabel,
    required this.icon,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: busy ? null : onPressed,
      icon: busy
          ? SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, size: 17.sp),
      label: Text(busy ? busyLabel : label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.55),
        disabledForegroundColor: Colors.white,
        elevation: 0,
        minimumSize: Size(0, 48.h),
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}

Widget _label(String text) => Padding(
  padding: EdgeInsets.only(bottom: 7.h),
  child: Text(
    text,
    style: AppTextStyles.bodyMedium().copyWith(fontSize: 12.5.sp),
  ),
);

Widget _field({
  required TextEditingController controller,
  required String label,
  required String hint,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        style: AppTextStyles.body().copyWith(fontSize: 13.sp),
        decoration: _inputDecoration(hint),
      ),
    ],
  );
}

Widget _readOnlyField({required String label, required String value}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      TextFormField(
        initialValue: value,
        enabled: false,
        style: AppTextStyles.body().copyWith(fontSize: 13.sp),
        decoration: _inputDecoration('').copyWith(
          fillColor: AppColors.surfaceMuted,
          prefixIcon: Icon(
            Iconsax.lock,
            size: 16.sp,
            color: AppColors.textMuted,
          ),
        ),
      ),
    ],
  );
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: AppTextStyles.small(),
  filled: true,
  fillColor: AppColors.surfaceSoft,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: const BorderSide(color: AppColors.border),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: const BorderSide(color: AppColors.border),
  ),
  disabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: const BorderSide(color: AppColors.border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: BorderSide(color: AppColors.danger.withValues(alpha: 0.55)),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: const BorderSide(color: AppColors.danger),
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 12.h),
);
