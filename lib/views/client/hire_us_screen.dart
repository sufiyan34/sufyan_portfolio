import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/hire_request_controller.dart';
import 'package:sufyan_portfolio/widgets/public_navbar.dart';

class HireUsScreen extends StatelessWidget {
  const HireUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HireRequestController>();
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 1100;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PublicNavbar(activeRoute: AppRoutes.hireUs),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            desktop ? 64.w : 20.w,
            desktop ? 54.h : 36.h,
            desktop ? 64.w : 20.w,
            72.h,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1240.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Hero()
                      .animate()
                      .fadeIn(duration: 450.ms)
                      .slideY(begin: 0.03),
                  SizedBox(height: 34.h),
                  if (desktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 330.w,
                          child: _ProjectBrief(controller: controller),
                        ),
                        SizedBox(width: 26.w),
                        Expanded(child: _RequestForm(controller: controller)),
                      ],
                    )
                  else ...[
                    _ProjectBrief(controller: controller),
                    SizedBox(height: 20.h),
                    _RequestForm(controller: controller),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 900;

    return Container(
      padding: EdgeInsets.all(desktop ? 34.w : 24.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(26.r),
      ),
      child: desktop
          ? Row(
              children: [
                Expanded(child: _heroCopy()),
                SizedBox(width: 34.w),
                _heroVisual(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroCopy(),
                SizedBox(height: 24.h),
                Align(alignment: Alignment.centerRight, child: _heroVisual()),
              ],
            ),
    );
  }

  Widget _heroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'START A PROJECT',
          style: AppTextStyles.overline(color: AppColors.accentGold),
        ),
        SizedBox(height: 12.h),
        Text(
          'Let’s build something\nworth shipping.',
          style: AppTextStyles.h1(color: Colors.white)
              .copyWith(fontSize: 48.sp, height: 1.02),
        ),
        SizedBox(height: 14.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 640.w),
          child: Text(
            'Tell me what you want to build, what success looks like, and when you need it. I’ll review the brief and come back with the next steps.',
            style: AppTextStyles.body(
              color: Colors.white.withValues(alpha: 0.78),
            ).copyWith(height: 1.65),
          ),
        ),
      ],
    );
  }

  Widget _heroVisual() {
    return Container(
      width: 150.w,
      height: 150.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Center(
        child: Container(
          width: 104.w,
          height: 104.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accentGold,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.briefcase,
            color: AppColors.primaryDark,
            size: 42.sp,
          ),
        ),
      ),
    );
  }
}

class _ProjectBrief extends StatelessWidget {
  final HireRequestController controller;

  const _ProjectBrief({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WHAT HAPPENS NEXT', style: AppTextStyles.overline()),
          SizedBox(height: 12.h),
          _Step(
            number: '01',
            title: 'You send the brief',
            description: 'Share your idea, scope, budget and timeline.',
          ),
          _Step(
            number: '02',
            title: 'I review it',
            description:
                'I’ll review the requirements and identify the best approach.',
          ),
          _Step(
            number: '03',
            title: 'We discuss details',
            description:
                'We can clarify the scope, priorities and delivery plan.',
          ),
          _Step(
            number: '04',
            title: 'Proposal / next step',
            description:
                'You receive a clear response, offer or follow-up request.',
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Iconsax.clock, size: 18.sp, color: AppColors.primary),
                SizedBox(width: 9.w),
                Expanded(
                  child: Text(
                    'A thoughtful brief helps me respond faster and more accurately.',
                    style: AppTextStyles.small(color: AppColors.primary)
                        .copyWith(height: 1.55),
                  ),
                ),
              ],
            ),
          ),
          if (controller.selectedPackageId.value.isNotEmpty)
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _Step({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 17.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              number,
              style: AppTextStyles.small(color: AppColors.primary)
                  .copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium().copyWith(fontSize: 13.5.sp),
                ),
                SizedBox(height: 3.h),
                Text(
                  description,
                  style: AppTextStyles.small().copyWith(height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestForm extends StatelessWidget {
  final HireRequestController controller;

  const _RequestForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PROJECT DETAILS', style: AppTextStyles.overline()),
          SizedBox(height: 8.h),
          Text(
            'Tell me about your project',
            style: AppTextStyles.h2().copyWith(fontSize: 30.sp),
          ),
          SizedBox(height: 7.h),
          Text(
            'Required fields are kept focused so the form stays quick to complete.',
            style: AppTextStyles.body().copyWith(fontSize: 13.5.sp),
          ),
          SizedBox(height: 22.h),
          _FieldRow(
            first: _field(
              controller: controller.nameController,
              label: 'Your name *',
              hint: 'Muhammad Ali',
              validator: _required,
            ),
            second: _field(
              controller: controller.emailController,
              label: 'Email *',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: _email,
            ),
          ),
          SizedBox(height: 15.h),
          _FieldRow(
            first: _field(
              controller: controller.companyController,
              label: 'Company / organization',
              hint: 'Optional',
            ),
            second: _field(
              controller: controller.phoneController,
              label: 'Phone / WhatsApp',
              hint: '+92 ...',
              keyboardType: TextInputType.phone,
            ),
          ),
          SizedBox(height: 15.h),
          _field(
            controller: controller.projectNameController,
            label: 'Project name *',
            hint: 'e.g. E-commerce mobile app',
            validator: _required,
          ),
          SizedBox(height: 15.h),
          _ResponsiveDropdown(
            label: 'Project type *',
            value: controller.selectedProjectType,
            items: HireRequestController.projectTypes,
            onChanged: controller.selectProjectType,
          ),
          SizedBox(height: 15.h),
          Obx(() {
            return _FieldRow(
              first: _ResponsiveDropdown(
                label: 'Service',
                value: controller.selectedServiceId,
                items: controller.services.map((item) => item.id).toList(),
                labels: {
                  for (final service in controller.services)
                    service.id: service.title,
                },
                enabled: controller.services.isNotEmpty,
                onChanged: controller.selectService,
                emptyLabel: controller.isLoadingOptions.value
                    ? 'Loading services...'
                    : 'Select a service',
              ),
              second: _ResponsiveDropdown(
                label: 'Package',
                value: controller.selectedPackageId,
                items: controller.packages.map((item) => item.id).toList(),
                labels: {
                  for (final package in controller.packages)
                    package.id: package.title,
                },
                enabled: controller.packages.isNotEmpty,
                onChanged: controller.selectPackage,
                emptyLabel: controller.isLoadingOptions.value
                    ? 'Loading packages...'
                    : 'Custom / no package',
              ),
            );
          }),
          SizedBox(height: 15.h),
          _FieldRow(
            first: Obx(
              () => _ResponsiveDropdown(
                label: 'Budget range *',
                value: controller.selectedBudget,
                items: HireRequestController.budgetRanges,
                onChanged: controller.selectBudget,
              ),
            ),
            second: Obx(
              () => _ResponsiveDropdown(
                label: 'Timeline *',
                value: controller.selectedTimeline,
                items: HireRequestController.timelines,
                onChanged: controller.selectTimeline,
              ),
            ),
          ),
          SizedBox(height: 15.h),
          _FieldRow(
            first: Obx(
              () => _ResponsiveDropdown(
                label: 'Preferred platform *',
                value: controller.selectedPlatform,
                items: HireRequestController.platforms,
                onChanged: controller.selectPlatform,
              ),
            ),
            second: Obx(
              () => _ResponsiveDropdown(
                label: 'Preferred contact',
                value: controller.selectedContactMethod,
                items: HireRequestController.contactMethods,
                onChanged: controller.selectContactMethod,
              ),
            ),
          ),
          SizedBox(height: 15.h),
          _field(
            controller: controller.descriptionController,
            label: 'Project description *',
            hint: 'What are you building? What problem should it solve? What are the most important features?',
            minLines: 6,
            maxLines: 8,
            validator: (value) {
              final error = _required(value);
              if (error != null) return error;
              if ((value ?? '').trim().length < 30)
                return 'Please provide at least 30 characters.';
              return null;
            },
          ),
          SizedBox(height: 15.h),
          _field(
            controller: controller.referenceLinksController,
            label: 'Reference links',
            hint: 'Figma, inspiration, existing website, GitHub… (one per line or separated by commas)',
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: 18.h),
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
              child: ElevatedButton.icon(
                onPressed: submitting ? null : controller.submit,
                icon: submitting
                    ? SizedBox(
                        width: 17.w,
                        height: 17.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Iconsax.send_2),
                label: Text(submitting ? 'Submitting…' : 'Submit Hire Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.55,
                  ),
                  elevation: 0,
                  minimumSize: Size(double.infinity, 52.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: 10.h),
          Center(
            child: Text(
              'No payment is taken through this form.',
              style: AppTextStyles.small().copyWith(fontSize: 11.5.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int minLines = 1,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium().copyWith(fontSize: 12.5.sp),
        ),
        SizedBox(height: 7.h),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines ?? minLines,
          style: AppTextStyles.body().copyWith(fontSize: 13.5.sp),
          decoration: _decoration(hint),
        ),
      ],
    );
  }

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.small(color: AppColors.textMuted),
    filled: true,
    fillColor: AppColors.surfaceSoft,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.primary, width: 1.3),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.danger.withValues(alpha: 0.55)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.danger),
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
    final email = value!.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }
}

class _FieldRow extends StatelessWidget {
  final Widget first;
  final Widget second;

  const _FieldRow({required this.first, required this.second});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 800;
    if (!desktop) {
      return Column(
        children: [
          first,
          SizedBox(height: 15.h),
          second,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        SizedBox(width: 14.w),
        Expanded(child: second),
      ],
    );
  }
}

class _ResponsiveDropdown extends StatelessWidget {
  final String label;
  final RxString value;
  final List<String> items;
  final Map<String, String>? labels;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String emptyLabel;

  const _ResponsiveDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labels,
    this.enabled = true,
    this.emptyLabel = 'Select',
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = items.contains(value.value) ? value.value : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium().copyWith(fontSize: 12.5.sp),
          ),
          SizedBox(height: 7.h),
          DropdownButtonFormField<String>(
            value: current,
            isExpanded: true,
            onChanged: enabled && items.isNotEmpty
                ? (selected) {
                    if (selected != null) onChanged(selected);
                  }
                : null,
            hint: Text(emptyLabel, style: AppTextStyles.small()),
            style: AppTextStyles.body().copyWith(
              fontSize: 13.5.sp,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceSoft,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 2.h,
              ),
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.3,
                ),
              ),
            ),
            items: items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      labels?[item] ?? item,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      );
    });
  }
}
