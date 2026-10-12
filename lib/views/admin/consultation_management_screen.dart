import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/consultation_management_controller.dart';
import 'package:sufyan_portfolio/models/consultation_request_model.dart';
import 'package:sufyan_portfolio/widgets/admin_shell.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';

/// Admin > Consultations. Lists every request from the public
/// "Consult With Me" form and lets the admin triage them.
class ConsultationManagementScreen extends StatelessWidget {
  const ConsultationManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConsultationManagementController());

    return AdminShell(
      title: 'Consultations',
      eyebrow: 'Client requests',
      trailing: IconButton(
        tooltip: 'Refresh',
        onPressed: controller.load,
        icon: const Icon(Iconsax.refresh, size: 19),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = controller.filtered;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.load,
          child: ListView(
            padding: EdgeInsets.fromLTRB(22.w, 20.h, 22.w, 32.h),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1200.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminStatsGrid(
                        items: [
                          ('Total', '${controller.total}', Iconsax.calendar_1),
                          (
                            'New',
                            '${controller.countOf(ConsultationStatuses.newRequest)}',
                            Iconsax.notification,
                          ),
                          (
                            'Scheduled',
                            '${controller.countOf(ConsultationStatuses.scheduled)}',
                            Iconsax.calendar_tick,
                          ),
                          (
                            'Completed',
                            '${controller.countOf(ConsultationStatuses.completed)}',
                            Iconsax.tick_circle,
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      AdminSearchField(
                        hint: 'Search by name, email, topic or message',
                        onChanged: controller.setSearch,
                      ),
                      SizedBox(height: 12.h),
                      AdminFilterChips(
                        values: ['all', ...ConsultationStatuses.all],
                        selected: controller.statusFilter.value,
                        labelOf: (v) =>
                            v == 'all' ? 'All' : ConsultationStatuses.label(v),
                        onSelected: controller.setStatusFilter,
                      ),
                      SizedBox(height: 18.h),
                      if (list.isEmpty)
                        const AdminEmptyState(
                          icon: Iconsax.calendar_search,
                          title: 'No consultations found',
                          message:
                              'New requests from the Consult With Me page will show up here.',
                        )
                      else
                        for (final item in list)
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _ConsultationCard(
                              item: item,
                              onTap: () => _openDetails(context, controller, item),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _openDetails(
    BuildContext context,
    ConsultationManagementController controller,
    ConsultationRequestModel item,
  ) {
    showDialog(
      context: context,
      builder: (_) => _ConsultationDetailsDialog(
        controller: controller,
        itemId: item.id,
      ),
    );
  }
}

Color consultationStatusColor(String status) {
  switch (status) {
    case ConsultationStatuses.contacted:
      return AppColors.info;
    case ConsultationStatuses.scheduled:
      return AppColors.warning;
    case ConsultationStatuses.completed:
      return AppColors.success;
    case ConsultationStatuses.cancelled:
      return AppColors.danger;
    default:
      return AppColors.primary;
  }
}

String _formatDate(int millis) => millis > 0
    ? DateFormat('dd MMM yyyy, hh:mm a').format(
        DateTime.fromMillisecondsSinceEpoch(millis),
      )
    : 'Unknown';

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

class _ConsultationCard extends StatelessWidget {
  final ConsultationRequestModel item;
  final VoidCallback onTap;
  const _ConsultationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isNew = item.status == ConsultationStatuses.newRequest;
    final preferred = [
      item.preferredDate,
      item.preferredTime,
    ].where((e) => e.isNotEmpty).join(' · ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isNew ? AppColors.primary.withValues(alpha: 0.35) : AppColors.border,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Text(
                _initials(item.name),
                style: AppTextStyles.bodyMedium(color: AppColors.primary),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name.isEmpty ? 'Unnamed visitor' : item.name,
                          style: AppTextStyles.bodyMedium().copyWith(fontSize: 15.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AdminPill(
                        text: ConsultationStatuses.label(item.status),
                        color: consultationStatusColor(item.status),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(item.email, style: AppTextStyles.small()),
                  SizedBox(height: 10.h),
                  Text(
                    item.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 14.w,
                    runSpacing: 6.h,
                    children: [
                      if (item.consultationType.isNotEmpty)
                        _Meta(icon: Iconsax.message_question, text: item.consultationType),
                      if (preferred.isNotEmpty)
                        _Meta(icon: Iconsax.clock, text: preferred),
                      if (item.attachments.isNotEmpty)
                        _Meta(
                          icon: Iconsax.attach_circle,
                          text: '${item.attachments.length} file${item.attachments.length == 1 ? '' : 's'}',
                        ),
                      _Meta(icon: Iconsax.calendar_1, text: _formatDate(item.createdAt)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textMuted),
        SizedBox(width: 5.w),
        Text(text, style: AppTextStyles.small()),
      ],
    );
  }
}

class _ConsultationDetailsDialog extends StatefulWidget {
  final ConsultationManagementController controller;
  final String itemId;
  const _ConsultationDetailsDialog({
    required this.controller,
    required this.itemId,
  });

  @override
  State<_ConsultationDetailsDialog> createState() =>
      _ConsultationDetailsDialogState();
}

class _ConsultationDetailsDialogState
    extends State<_ConsultationDetailsDialog> {
  late final TextEditingController _notes;

  ConsultationRequestModel? get _item {
    final index = widget.controller.items.indexWhere((e) => e.id == widget.itemId);
    return index == -1 ? null : widget.controller.items[index];
  }

  @override
  void initState() {
    super.initState();
    _notes = TextEditingController(text: _item?.adminNotes ?? '');
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _email(ConsultationRequestModel item) async {
    final uri = Uri(
      scheme: 'mailto',
      path: item.email,
      queryParameters: {
        'subject': 'Re: your consultation request',
        'body': 'Hi ${item.name},\n\nThanks for reaching out about "${item.consultationType}".\n\n',
      },
    );
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 680.w, maxHeight: height * 0.92),
        child: Obx(() {
          final item = _item;
          if (item == null) {
            return SizedBox(
              height: 160.h,
              child: Center(child: Text('Consultation not found', style: AppTextStyles.body())),
            );
          }
          final preferred = [
            item.preferredDate,
            item.preferredTime,
          ].where((e) => e.isNotEmpty).join(' · ');

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 18.h, 10.w, 14.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: AppTextStyles.h3()),
                          SizedBox(height: 2.h),
                          Text('Received ${_formatDate(item.createdAt)}', style: AppTextStyles.small()),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Email visitor',
                      onPressed: () => _email(item),
                      icon: const Icon(Iconsax.sms, size: 19),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, size: 22.sp),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 18.w,
                        runSpacing: 8.h,
                        children: [
                          _Meta(icon: Iconsax.sms, text: item.email),
                          if (item.consultationType.isNotEmpty)
                            _Meta(icon: Iconsax.message_question, text: item.consultationType),
                          if (preferred.isNotEmpty)
                            _Meta(icon: Iconsax.clock, text: 'Prefers $preferred'),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      Text('Message', style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: SelectableText(item.message, style: AppTextStyles.body()),
                      ),
                      if (item.attachments.isNotEmpty) ...[
                        SizedBox(height: 18.h),
                        Text('Reference files', style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
                        SizedBox(height: 8.h),
                        for (final file in item.attachments)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: InkWell(
                              onTap: file.url.isEmpty ? null : () => _open(file.url),
                              borderRadius: BorderRadius.circular(12.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Iconsax.document, size: 18.sp, color: AppColors.primary),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        file.name.isEmpty ? file.publicId : file.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodyMedium().copyWith(fontSize: 13.sp),
                                      ),
                                    ),
                                    Text(_formatBytes(file.bytes), style: AppTextStyles.small()),
                                    SizedBox(width: 8.w),
                                    Icon(Iconsax.export_3, size: 15.sp, color: AppColors.textMuted),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                      SizedBox(height: 18.h),
                      Text('Status', style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
                      SizedBox(height: 10.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: ConsultationStatuses.all.map((status) {
                          final selected = item.status == status;
                          final color = consultationStatusColor(status);
                          return ChoiceChip(
                            selected: selected,
                            showCheckmark: false,
                            label: Text(ConsultationStatuses.label(status)),
                            onSelected: (_) => widget.controller.setStatus(item, status),
                            selectedColor: color,
                            backgroundColor: AppColors.surface,
                            side: BorderSide(color: selected ? color : AppColors.border),
                            labelStyle: AppTextStyles.small(
                              color: selected ? Colors.white : AppColors.textSecondary,
                            ).copyWith(fontWeight: FontWeight.w700),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 18.h),
                      TextField(
                        controller: _notes,
                        maxLines: 4,
                        style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
                        decoration: adminInputDecoration(
                          'Private notes',
                          hint: 'Only you can see these — call outcome, agreed time, follow-ups…',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 18.h),
                child: Row(
                  children: [
                    AdminOutlineButton(
                      label: 'Delete',
                      icon: Iconsax.trash,
                      color: AppColors.danger,
                      onPressed: () async {
                        final ok = await confirmAdminDelete(
                          context,
                          title: 'Delete this consultation?',
                          message: 'The request from ${item.name} will be permanently removed from Firebase.',
                        );
                        if (!ok) return;
                        final deleted = await widget.controller.delete(item);
                        if (deleted && context.mounted) Navigator.of(context).pop();
                      },
                    ),
                    const Spacer(),
                    Obx(
                      () => AdminPrimaryButton(
                        label: 'Save notes',
                        loading: widget.controller.isSaving.value,
                        onPressed: () => widget.controller.saveNotes(item, _notes.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
