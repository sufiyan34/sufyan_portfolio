import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/hire_request_details_controller.dart';
import 'package:sufyan_portfolio/models/hire_request_model.dart';
import 'package:sufyan_portfolio/widgets/admin_shell.dart';

class HireRequestDetailsScreen extends StatelessWidget {
  const HireRequestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HireRequestDetailsController>();
    return AdminShell(
      title: 'Hire Request',
      eyebrow: 'Request details',
      showBackButton: true,
      trailing: Obx(() {
        final item = controller.request.value;
        if (item == null) return const SizedBox.shrink();
        return IconButton(
          tooltip: 'Email client',
          onPressed: () => _emailClient(controller),
          icon: const Icon(Iconsax.sms, size: 19),
        );
      }),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final request = controller.request.value;
        if (request == null) {
          return Center(
            child: Text(controller.errorMessage.value, style: AppTextStyles.body()),
          );
        }
        return _Body(controller: controller, request: request);
      }),
    );
  }

  Future<void> _emailClient(HireRequestDetailsController controller) async {
    final request = controller.request.value;
    if (request == null || request.email.isEmpty) return;
    final uri = Uri(
      scheme: 'mailto',
      path: request.email,
      queryParameters: {
        'subject': 'Regarding your project request — ${request.projectName}',
        'body': controller.buildEmailBody(),
      },
    );
    await launchUrl(uri);
  }
}

class _Body extends StatelessWidget {
  final HireRequestDetailsController controller;
  final HireRequestModel request;

  const _Body({required this.controller, required this.request});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1000;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(22.w, 20.h, 22.w, 32.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1200.w),
          child: desktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _RequestInfo(request: request)),
                    SizedBox(width: 18.w),
                    Expanded(flex: 4, child: _ResponsePanel(controller: controller)),
                  ],
                )
              : Column(
                  children: [
                    _RequestInfo(request: request),
                    SizedBox(height: 18.h),
                    _ResponsePanel(controller: controller),
                  ],
                ),
        ),
      ),
    );
  }
}

class _RequestInfo extends StatelessWidget {
  final HireRequestModel request;
  const _RequestInfo({required this.request});

  @override
  Widget build(BuildContext context) {
    final created = request.createdAt > 0
        ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(request.createdAt))
        : 'Unknown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(request.projectName, style: AppTextStyles.h2().copyWith(fontSize: 28.sp))),
                  _StatusBadge(status: request.status),
                ],
              ),
              SizedBox(height: 6.h),
              Text('$created • ${request.id}', style: AppTextStyles.small()),
              SizedBox(height: 20.h),
              _InfoGrid(items: [
                ('Client', request.name),
                ('Company', request.company.isEmpty ? '—' : request.company),
                ('Email', request.email),
                ('Phone', request.phone.isEmpty ? '—' : request.phone),
                ('Project type', request.projectType),
                ('Service', request.serviceTitle.isEmpty ? '—' : request.serviceTitle),
                ('Package', request.packageTitle.isEmpty ? 'Custom / none' : request.packageTitle),
                ('Budget', request.budgetRange),
                ('Timeline', request.timeline),
                ('Platform', request.preferredPlatform),
                ('Contact method', request.preferredContact),
                ('Priority', HireRequestPriorities.label(request.priority)),
              ]),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _Card(
          title: 'Project description',
          child: SelectableText(request.description, style: AppTextStyles.body().copyWith(height: 1.65)),
        ),
        if (request.referenceLinks.isNotEmpty) ...[
          SizedBox(height: 16.h),
          _Card(
            title: 'Reference links',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: request.referenceLinks
                  .map((link) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: InkWell(
                          onTap: () => launchUrl(Uri.tryParse(link) ?? Uri()),
                          child: Text(link, style: AppTextStyles.bodyMedium(color: AppColors.primary).copyWith(decoration: TextDecoration.underline, fontSize: 12.5.sp)),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _ResponsePanel extends StatelessWidget {
  final HireRequestDetailsController controller;
  const _ResponsePanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Card(
          title: 'Workflow',
          child: Column(
            children: [
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedStatus.value,
                    isExpanded: true,
                    onChanged: (value) {
                      if (value != null) controller.selectedStatus.value = value;
                    },
                    items: HireRequestStatuses.all
                        .map((item) => DropdownMenuItem(value: item, child: Text(HireRequestStatuses.label(item))))
                        .toList(),
                    decoration: _inputDecoration('Status'),
                  )),
              SizedBox(height: 13.h),
              _textField(controller.replyController, 'Client reply', 'Write the response the client may receive.'),
              SizedBox(height: 13.h),
              _textField(controller.notesController, 'Internal notes', 'Private admin notes — not intended for the client.', minLines: 3),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _Card(
          title: 'Offer',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _textField(controller.offerAmountController, 'Amount', 'e.g. 150000', keyboardType: TextInputType.number)),
                  SizedBox(width: 10.w),
                  Expanded(child: _textField(controller.offerDeliveryDaysController, 'Delivery days', 'e.g. 30', keyboardType: TextInputType.number)),
                ],
              ),
              SizedBox(height: 13.h),
              _textField(controller.offerMessageController, 'Offer message', 'Scope, assumptions, inclusions, payment milestones…', minLines: 4),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() {
          if (controller.errorMessage.value.isEmpty) return const SizedBox.shrink();
          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 14.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(controller.errorMessage.value, style: AppTextStyles.small(color: AppColors.danger)),
          );
        }),
        Obx(() {
          final saving = controller.isSaving.value;
          return Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: saving ? null : () => controller.save(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: Size(double.infinity, 50.h),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text(saving ? 'Saving…' : 'Save Response'),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: saving
                      ? null
                      : () async {
                          final saved = await controller.save(sendOffer: true);
                          if (saved) {
                            final request = controller.request.value;
                            if (request != null && request.email.isNotEmpty) {
                              final uri = Uri(
                                scheme: 'mailto',
                                path: request.email,
                                queryParameters: {
                                  'subject': 'Project proposal — ${request.projectName}',
                                  'body': controller.buildEmailBody(),
                                },
                              );
                              await launchUrl(uri);
                            }
                          }
                        },
                  icon: saving ? SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Iconsax.send_2, size: 17),
                  label: Text(saving ? 'Saving…' : 'Save & Email Client'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                ),
              ),
            ],
          );
        }),
        SizedBox(height: 9.h),
        Text(
          'Use the email button in the page header to send the saved response and offer through your email client.',
          style: AppTextStyles.small().copyWith(fontSize: 10.5.sp, height: 1.5),
        ),
      ],
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    String hint, {
    int minLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium().copyWith(fontSize: 12.5.sp)),
        SizedBox(height: 7.h),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: minLines == 1 ? 1 : null,
          keyboardType: keyboardType,
          style: AppTextStyles.body().copyWith(fontSize: 13.sp),
          decoration: _inputDecoration(hint),
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 12.h),
      );
}

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
            Text(title!, style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
            SizedBox(height: 13.h),
          ],
          child,
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final List<(String, String)> items;
  const _InfoGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16.w,
      runSpacing: 15.h,
      children: items.map((item) {
        return SizedBox(
          width: 220.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.$1.toUpperCase(), style: AppTextStyles.overline(color: AppColors.textMuted).copyWith(fontSize: 9.5.sp, letterSpacing: 1.1)),
              SizedBox(height: 4.h),
              SelectableText(item.$2, style: AppTextStyles.bodyMedium().copyWith(fontSize: 12.5.sp)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = HireRequestStatuses.normalize(status);
    final color = switch (normalized) {
      HireRequestStatuses.completed || HireRequestStatuses.approved => AppColors.success,
      HireRequestStatuses.rejected || HireRequestStatuses.cancelled => AppColors.danger,
      HireRequestStatuses.proposalSent || HireRequestStatuses.negotiation => AppColors.accentGold,
      _ => AppColors.info,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        HireRequestStatuses.label(status),
        style: AppTextStyles.small(color: color).copyWith(fontSize: 10.sp, fontWeight: FontWeight.w800),
      ),
    );
  }
}
