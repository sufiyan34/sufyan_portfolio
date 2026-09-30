import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/contact_controller.dart';
import 'package:sufyan_portfolio/widgets/contact_skeletons.dart';
import 'package:sufyan_portfolio/widgets/public_navbar.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContactController());
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PublicNavbar(activeRoute: AppRoutes.contactUs),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: controller.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48.w : 20.w,
              vertical: isDesktop ? 56.h : 36.h,
            ),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const ContactPageSkeleton();
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final desktop = constraints.maxWidth >= 1000;
                  if (!desktop) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ContactIntro(controller: controller),
                        SizedBox(height: 22.h),
                        _ContactForm(controller: controller),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _ContactIntro(controller: controller)),
                      SizedBox(width: 32.w),
                      Expanded(child: _ContactForm(controller: controller)),
                    ],
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _ContactIntro extends StatelessWidget {
  final ContactController controller;
  const _ContactIntro({required this.controller});

  @override
  Widget build(BuildContext context) {
    final content = controller.content.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(content.eyebrow, style: AppTextStyles.overline())
            .animate()
            .fadeIn(duration: 350.ms),
        SizedBox(height: 10.h),
        Text(content.title, style: AppTextStyles.h1())
            .animate()
            .fadeIn(delay: 70.ms, duration: 420.ms)
            .slideY(begin: .06, end: 0),
        SizedBox(height: 11.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600.w),
          child: Text(content.subtitle, style: AppTextStyles.body()),
        ),
        SizedBox(height: 27.h),
        _ContactDetailTile(
          icon: Icons.mail_outline_rounded,
          label: 'Email',
          value: content.email,
          onTap: () => _launch('mailto:${content.email}'),
        ),
        _ContactDetailTile(
          icon: Icons.phone_outlined,
          label: 'Phone / WhatsApp',
          value: content.phone,
          onTap: () => _launch('tel:${content.phone}'),
        ),
        _ContactDetailTile(
          icon: Icons.location_on_outlined,
          label: 'Location',
          value: content.location,
        ),
        _ContactDetailTile(
          icon: Icons.schedule_outlined,
          label: 'Working Hours',
          value: content.workingHours,
        ),
        SizedBox(height: 12.h),
        _ImageCard(imageUrl: content.imageUrl),
        SizedBox(height: 20.h),
        Text('Follow Me', style: AppTextStyles.h3().copyWith(fontSize: 18.sp)),
        SizedBox(height: 11.h),
        Wrap(
          spacing: 9.w,
          runSpacing: 9.h,
          children: [
            _SocialButton(
              icon: Icons.code_rounded,
              label: 'GitHub',
              url: content.socialLinks['github'],
            ),
            _SocialButton(
              icon: Icons.work_outline_rounded,
              label: 'LinkedIn',
              url: content.socialLinks['linkedin'],
            ),
            _SocialButton(
              icon: Icons.language_rounded,
              label: 'Website',
              url: content.socialLinks['website'],
            ),
            _SocialButton(
              icon: Icons.alternate_email_rounded,
              label: 'X / Social',
              url: content.socialLinks['x'],
            ),
          ],
        ),
      ],
    );
  }
}

class _ContactDetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactDetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 19.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.small(color: AppColors.textMuted)),
              SizedBox(height: 3.h),
              Text(
                value,
                style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 17.h),
      child: onTap == null
          ? child
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(onTap: onTap, child: child),
            ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String imageUrl;
  const _ImageCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22.r),
      child: AspectRatio(
        aspectRatio: 2.5,
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => _fallback(),
                errorWidget: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.surfaceSoft,
      alignment: Alignment.center,
      child: Icon(Icons.photo_camera_back_outlined, size: 38.sp, color: AppColors.textMuted),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? url;

  const _SocialButton({required this.icon, required this.label, this.url});

  @override
  Widget build(BuildContext context) {
    final enabled = url != null && url!.trim().isNotEmpty;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: enabled ? () => _launch(url!) : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.sp, color: enabled ? AppColors.primary : AppColors.textMuted),
              SizedBox(width: 7.w),
              Text(
                label,
                style: AppTextStyles.small(
                  color: enabled ? AppColors.textPrimary : AppColors.textMuted,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactForm extends StatelessWidget {
  final ContactController controller;
  const _ContactForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(23.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Obx(() {
        if (controller.submitted.value) {
          return _SuccessState(onAnotherMessage: controller.startAnotherMessage);
        }

        return Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Send a message', style: AppTextStyles.h3()),
              SizedBox(height: 18.h),
              _Field(
                controller: controller.nameController,
                label: 'Your Name *',
                hint: 'John Doe',
                validator: (value) => _required(value, 'Please enter your name.'),
              ),
              SizedBox(height: 13.h),
              _Field(
                controller: controller.emailController,
                label: 'Email Address *',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final required = _required(value, 'Please enter your email.');
                  if (required != null) return required;
                  final email = value!.trim();
                  if (!GetUtils.isEmail(email)) return 'Enter a valid email address.';
                  return null;
                },
              ),
              SizedBox(height: 13.h),
              _Field(
                controller: controller.subjectController,
                label: 'Subject *',
                hint: 'Project inquiry',
                validator: (value) => _required(value, 'Please enter a subject.'),
              ),
              SizedBox(height: 13.h),
              _Field(
                controller: controller.messageController,
                label: 'Message *',
                hint: 'Tell me a little about your project...',
                maxLines: 6,
                validator: (value) => _required(value, 'Please enter your message.'),
              ),
              SizedBox(height: 18.h),
              Obx(() {
                if (controller.errorMessage.value.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(bottom: 13.h),
                  child: Text(
                    controller.errorMessage.value,
                    style: AppTextStyles.small(color: AppColors.danger).copyWith(fontWeight: FontWeight.w700),
                  ),
                );
              }),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : controller.submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: .45),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: controller.isSubmitting.value
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnPrimary),
                        )
                      : Text('Send Message', style: AppTextStyles.bodyMedium(color: AppColors.textOnPrimary).copyWith(fontSize: 13.5.sp)),
                ),
              ),
            ],
          ),
        );
      }),
    ).animate().fadeIn(delay: 160.ms, duration: 500.ms).slideX(begin: .04, end: 0);
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.small(color: AppColors.textPrimary).copyWith(fontSize: 13.5.sp),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.small(color: AppColors.textSecondary).copyWith(fontSize: 12.sp),
        hintStyle: AppTextStyles.small(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
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
          borderSide: BorderSide(color: AppColors.primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AppColors.danger, width: 1.2),
        ),
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  final VoidCallback onAnotherMessage;
  const _SuccessState({required this.onAnotherMessage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 34.h, horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(17.r),
            ),
            child: Icon(Icons.check_rounded, size: 28.sp, color: AppColors.primary),
          ),
          SizedBox(height: 18.h),
          Text('Message sent.', style: AppTextStyles.h2().copyWith(fontSize: 32.sp)),
          SizedBox(height: 8.h),
          Text(
            'Thanks for reaching out. Your message is in my inbox and I’ll get back to you as soon as possible.',
            style: AppTextStyles.body(),
          ),
          SizedBox(height: 20.h),
          OutlinedButton(
            onPressed: onAnotherMessage,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.border),
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 13.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text('Send another message', style: AppTextStyles.bodyMedium(color: AppColors.primary).copyWith(fontSize: 13.sp)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: .04, end: 0);
  }
}

String? _required(String? value, String message) {
  if (value == null || value.trim().isEmpty) return message;
  return null;
}

Future<void> _launch(String rawUrl) async {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.platformDefault);
}
