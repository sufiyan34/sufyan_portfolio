import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/consultation_controller.dart';
import 'package:sufyan_portfolio/widgets/app_footer.dart';
import 'package:sufyan_portfolio/widgets/consultation_file_drop_zone.dart';
import 'package:sufyan_portfolio/widgets/public_navbar.dart';

class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConsultationController>();
    final desktop = MediaQuery.sizeOf(context).width >= 1000;

    return Scaffold(
      backgroundColor: AppColors.background,
      // The reference highlights "Packages" on this page (it's reached from
      // the packages "Book Consultation" strip). Change here if you'd rather
      // have no active item.
      appBar: const PublicNavbar(activeRoute: AppRoutes.packages),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          desktop ? 64.w : 20.w,
          desktop ? 44.h : 28.h,
          desktop ? 64.w : 20.w,
          72.h,
        ),
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1240.w),
                child: desktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _FormCard(controller: controller),
                          ),
                          SizedBox(width: 28.w),
                          Expanded(
                            flex: 4,
                            child: _SideColumn(controller: controller),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _FormCard(controller: controller),
                          SizedBox(height: 22.h),
                          _SideColumn(controller: controller),
                        ],
                      ),
              ),
            ),
            AppFooter(),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// FORM CARD
// ============================================================================

class _FormCard extends StatelessWidget {
  final ConsultationController controller;

  const _FormCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Obx(
        () => controller.submitted.value
            ? _SuccessState(controller: controller)
            : _FormBody(controller: controller),
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.03);
  }
}

class _FormBody extends StatelessWidget {
  final ConsultationController controller;

  const _FormBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consult With Me',
            style: AppTextStyles.h2().copyWith(fontSize: 34.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'Have an idea or need technical guidance? Book a consultation and let’s discuss your project.',
            style: AppTextStyles.body().copyWith(fontSize: 13.5.sp),
          ),
          SizedBox(height: 24.h),
          _label('Your Name *'),
          _textField(
            controller: controller.nameController,
            hint: 'John Doe',
            validator: _required,
          ),
          SizedBox(height: 15.h),
          _label('Email Address *'),
          _textField(
            controller: controller.emailController,
            hint: 'example@domain.com',
            keyboardType: TextInputType.emailAddress,
            validator: _email,
          ),
          SizedBox(height: 15.h),
          _label('Consultation Type *'),
          Obx(() {
            final current = controller.selectedType.value;
            return DropdownButtonFormField<String>(
              value: current.isEmpty ? null : current,
              isExpanded: true,
              onChanged: (value) {
                if (value != null) controller.selectType(value);
              },
              validator: (value) =>
                  value == null ? 'Please select a consultation type.' : null,
              hint: Text(
                'Select Type',
                style: AppTextStyles.small(color: AppColors.textMuted),
              ),
              style: AppTextStyles.body(color: AppColors.textPrimary)
                  .copyWith(fontSize: 13.5.sp),
              decoration: _decoration('').copyWith(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 4.h,
                ),
              ),
              items: ConsultationController.consultationTypes
                  .map(
                    (type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
            );
          }),
          SizedBox(height: 15.h),
          _label('Message *'),
          _textField(
            controller: controller.messageController,
            hint: 'Tell me about your idea or question…',
            minLines: 4,
            maxLines: 6,
            validator: (value) {
              final error = _required(value);
              if (error != null) return error;
              if ((value ?? '').trim().length < 15) {
                return 'Please add a little more detail (15+ characters).';
              }
              return null;
            },
          ),
          SizedBox(height: 15.h),
          _label('Preferred Date & Time'),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final date = controller.preferredDate.value;
                  return _PickerField(
                    icon: Iconsax.calendar_1,
                    label: date == null
                        ? 'Select Date'
                        : controller.preferredDateLabel,
                    filled: date != null,
                    onTap: () => _pickDate(context),
                  );
                }),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Obx(() {
                  final time = controller.preferredTime.value;
                  return _PickerField(
                    icon: Iconsax.clock,
                    label: time.isEmpty ? 'Select Time' : time,
                    filled: time.isNotEmpty,
                    onTap: () => _pickTime(context),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          ConsultationFileDropZone(controller: controller),
          SizedBox(height: 20.h),
          Obx(() {
            final error = controller.errorMessage.value;
            if (error.isEmpty) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 14.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.18),
                ),
              ),
              child: Text(
                error,
                style: AppTextStyles.small(color: AppColors.danger),
              ),
            );
          }),
          Obx(() {
            final submitting = controller.isSubmitting.value;
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitting ? null : controller.submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.55,
                  ),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: Size(double.infinity, 52.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: submitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 17.w,
                            height: 17.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          const Text('Submitting…'),
                        ],
                      )
                    : const Text('Submit Request'),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---- pickers ---------------------------------------------------------------

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          controller.preferredDate.value ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) controller.setDate(picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null && context.mounted) {
      controller.setTime(picked.format(context));
    }
  }

  // ---- field helpers ---------------------------------------------------------

  Widget _label(String text) => Padding(
    padding: EdgeInsets.only(bottom: 7.h),
    child: Text(
      text,
      style: AppTextStyles.bodyMedium().copyWith(fontSize: 12.5.sp),
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int minLines = 1,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines ?? minLines,
      style: AppTextStyles.body(color: AppColors.textPrimary)
          .copyWith(fontSize: 13.5.sp),
      decoration: _decoration(hint),
    );
  }

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.small(color: AppColors.textMuted),
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
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.danger.withValues(alpha: 0.55)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: AppColors.danger),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
  );

  String? _required(String? value) {
    if ((value ?? '').trim().isEmpty) return 'This field is required.';
    return null;
  }

  String? _email(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }
}

class _PickerField extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _PickerField({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.textMuted),
            SizedBox(width: 9.w),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: filled
                    ? AppTextStyles.body(color: AppColors.textPrimary)
                          .copyWith(fontSize: 13.5.sp)
                    : AppTextStyles.small(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SUCCESS STATE
// ============================================================================

class _SuccessState extends StatelessWidget {
  final ConsultationController controller;

  const _SuccessState({required this.controller});

  @override
  Widget build(BuildContext context) {
    final reference = controller.referenceId.value;

    return Column(
      children: [
        SizedBox(height: 18.h),
        Container(
          width: 78.w,
          height: 78.w,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.tick_circle,
            color: AppColors.primary,
            size: 40.sp,
          ),
        ).animate().scale(curve: Curves.easeOutBack, duration: 500.ms),
        SizedBox(height: 20.h),
        Text(
          'Consultation requested',
          textAlign: TextAlign.center,
          style: AppTextStyles.h2().copyWith(fontSize: 30.sp),
        ),
        SizedBox(height: 9.h),
        Text(
          'Thanks for reaching out. I’ll review your message and any files you attached, then get back to you with a time that works.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body().copyWith(fontSize: 13.5.sp, height: 1.65),
        ),
        if (reference.isNotEmpty) ...[
          SizedBox(height: 20.h),
          InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: reference));
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REQUEST REFERENCE',
                          style: AppTextStyles.overline().copyWith(
                            fontSize: 10.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        SelectableText(
                          reference,
                          style: AppTextStyles.bodyMedium().copyWith(
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Iconsax.copy, size: 18.sp, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
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
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: const Text('Back Home'),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: ElevatedButton(
                onPressed: controller.startAnotherRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: const Text('Send Another'),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

// ============================================================================
// RIGHT COLUMN — photo + what-I-can-help-with cards
// ============================================================================

class _SideColumn extends StatelessWidget {
  final ConsultationController controller;

  const _SideColumn({required this.controller});

  static const _topics = [
    _Topic(Iconsax.calendar_1, 'Project Planning', 'Get expert guidance'),
    _Topic(
      Iconsax.setting_2,
      'Technical Consultation',
      'Solve your technical problems',
    ),
    _Topic(Iconsax.layer, 'Architecture Review', 'Build scalable solutions'),
    _Topic(Iconsax.teacher, 'Career Guidance', 'Grow your development career'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroPhoto(controller: controller),
        SizedBox(height: 18.h),
        for (final topic in _topics) ...[
          _TopicCard(topic: topic),
          SizedBox(height: 12.h),
        ],
      ],
    ).animate().fadeIn(duration: 450.ms, delay: 120.ms).slideY(begin: 0.03);
  }
}

class _HeroPhoto extends StatelessWidget {
  final ConsultationController controller;

  const _HeroPhoto({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22.r),
      child: SizedBox(
        width: double.infinity,
        height: 210.h,
        child: Obx(() {
          final url = controller.heroImageUrl.value;
          if (url.isEmpty) return _fallback();
          return CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            placeholder: (_, __) => _fallback(),
            errorWidget: (_, __, ___) => _fallback(),
          );
        }),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.primary,
      alignment: Alignment.center,
      child: Icon(
        Iconsax.message_question,
        size: 46.sp,
        color: AppColors.accentGold,
      ),
    );
  }
}

class _Topic {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Topic(this.icon, this.title, this.subtitle);
}

class _TopicCard extends StatelessWidget {
  final _Topic topic;

  const _TopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(topic.icon, size: 19.sp, color: Colors.white),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: AppTextStyles.bodyMedium().copyWith(fontSize: 13.5.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  topic.subtitle,
                  style: AppTextStyles.small().copyWith(fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
