import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/contact_message_management_controller.dart';
import 'package:sufyan_portfolio/models/contact_content_model.dart';
import 'package:sufyan_portfolio/widgets/admin_shell.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';

/// Admin > Contact Messages: the inbox for the public Contact form.
class ContactMessageManagementScreen extends StatelessWidget {
  const ContactMessageManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContactMessageManagementController());

    return AdminShell(
      title: 'Contact Messages',
      eyebrow: 'Inbox',
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
                          ('Total', '${controller.messages.length}', Iconsax.message),
                          (
                            'Unread',
                            '${controller.countOf(ContactMessageStatuses.newMessage)}',
                            Iconsax.message_notif,
                          ),
                          (
                            'Replied',
                            '${controller.countOf(ContactMessageStatuses.replied)}',
                            Iconsax.message_tick,
                          ),
                          (
                            'Archived',
                            '${controller.countOf(ContactMessageStatuses.archived)}',
                            Iconsax.archive_1,
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      AdminSearchField(
                        hint: 'Search by name, email, subject or message',
                        onChanged: controller.setSearch,
                      ),
                      SizedBox(height: 12.h),
                      AdminFilterChips(
                        values: ['all', ...ContactMessageStatuses.all],
                        selected: controller.statusFilter.value,
                        labelOf: (v) =>
                            v == 'all' ? 'Inbox' : ContactMessageStatuses.label(v),
                        onSelected: controller.setStatusFilter,
                      ),
                      SizedBox(height: 18.h),
                      if (list.isEmpty)
                        const AdminEmptyState(
                          icon: Iconsax.message_search,
                          title: 'No messages here',
                          message:
                              'Messages sent from the public Contact page will appear in this inbox.',
                        )
                      else
                        for (final message in list)
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: _MessageTile(
                              message: message,
                              onTap: () => _open(context, controller, message),
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

  void _open(
    BuildContext context,
    ContactMessageManagementController controller,
    ContactMessageModel message,
  ) {
    controller.markOpened(message);
    showDialog(
      context: context,
      builder: (_) => _MessageDialog(controller: controller, messageId: message.id),
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case ContactMessageStatuses.read:
      return AppColors.info;
    case ContactMessageStatuses.replied:
      return AppColors.success;
    case ContactMessageStatuses.archived:
      return AppColors.textMuted;
    default:
      return AppColors.primary;
  }
}

String _date(int millis) => millis > 0
    ? DateFormat('dd MMM yyyy, hh:mm a').format(
        DateTime.fromMillisecondsSinceEpoch(millis),
      )
    : 'Unknown';

class _MessageTile extends StatelessWidget {
  final ContactMessageModel message;
  final VoidCallback onTap;
  const _MessageTile({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = message.status == ContactMessageStatuses.newMessage;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: unread ? AppColors.primary.withValues(alpha: 0.35) : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 9.w,
              height: 9.w,
              margin: EdgeInsets.only(top: 6.h, right: 12.w),
              decoration: BoxDecoration(
                color: unread ? AppColors.accentGold : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.subject.isEmpty ? '(No subject)' : message.subject,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium().copyWith(
                            fontSize: 15.sp,
                            fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      AdminPill(
                        text: ContactMessageStatuses.label(message.status),
                        color: _statusColor(message.status),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${message.name} · ${message.email}',
                    style: AppTextStyles.small(),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    message.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(),
                  ),
                  SizedBox(height: 8.h),
                  Text(_date(message.createdAt), style: AppTextStyles.small()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageDialog extends StatelessWidget {
  final ContactMessageManagementController controller;
  final String messageId;
  const _MessageDialog({required this.controller, required this.messageId});

  Future<void> _reply(ContactMessageModel m) async {
    final uri = Uri(
      scheme: 'mailto',
      path: m.email,
      queryParameters: {
        'subject': m.subject.toLowerCase().startsWith('re:') ? m.subject : 'Re: ${m.subject}',
        'body': 'Hi ${m.name},\n\n',
      },
    );
    await launchUrl(uri);
    await controller.setStatus(m, ContactMessageStatuses.replied, silent: true);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 640.w, maxHeight: height * 0.9),
        child: Obx(() {
          final index = controller.messages.indexWhere((m) => m.id == messageId);
          if (index == -1) {
            return SizedBox(
              height: 140.h,
              child: Center(child: Text('Message not found', style: AppTextStyles.body())),
            );
          }
          final m = controller.messages[index];
          final archived = m.status == ContactMessageStatuses.archived;

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
                          Text(
                            m.subject.isEmpty ? '(No subject)' : m.subject,
                            style: AppTextStyles.h3(),
                          ),
                          SizedBox(height: 3.h),
                          Text(_date(m.createdAt), style: AppTextStyles.small()),
                        ],
                      ),
                    ),
                    AdminPill(
                      text: ContactMessageStatuses.label(m.status),
                      color: _statusColor(m.status),
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
                      Row(
                        children: [
                          Icon(Iconsax.user, size: 16.sp, color: AppColors.textMuted),
                          SizedBox(width: 8.w),
                          Text(m.name, style: AppTextStyles.bodyMedium()),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Iconsax.sms, size: 16.sp, color: AppColors.textMuted),
                          SizedBox(width: 8.w),
                          Expanded(child: SelectableText(m.email, style: AppTextStyles.body())),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: SelectableText(
                          m.message,
                          style: AppTextStyles.body().copyWith(height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 18.h),
                child: Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AdminOutlineButton(
                      label: 'Delete',
                      icon: Iconsax.trash,
                      color: AppColors.danger,
                      onPressed: () async {
                        final ok = await confirmAdminDelete(
                          context,
                          title: 'Delete this message?',
                          message: 'The message from ${m.name} will be permanently removed.',
                        );
                        if (!ok) return;
                        final deleted = await controller.delete(m);
                        if (deleted && context.mounted) Navigator.of(context).pop();
                      },
                    ),
                    AdminOutlineButton(
                      label: archived ? 'Unarchive' : 'Archive',
                      icon: archived ? Iconsax.box_remove : Iconsax.archive_add,
                      onPressed: () => controller.setStatus(
                        m,
                        archived ? ContactMessageStatuses.read : ContactMessageStatuses.archived,
                      ),
                    ),
                    AdminPrimaryButton(
                      label: 'Reply by email',
                      icon: Iconsax.send_2,
                      onPressed: () => _reply(m),
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
