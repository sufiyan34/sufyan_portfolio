import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/testimonial_management_controller.dart';
import 'package:sufyan_portfolio/models/testimonial_invite_model.dart';
import 'package:sufyan_portfolio/models/testimonial_model.dart';
import 'package:sufyan_portfolio/models/testimonial_submission_model.dart';
import 'package:sufyan_portfolio/widgets/admin_shell.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';
import 'package:sufyan_portfolio/widgets/testimonial_form_dialog.dart';
import 'package:sufyan_portfolio/widgets/testimonial_invite_dialog.dart';

/// Admin > Testimonials.
///
/// Three views:
///  * Testimonials: what is (or isn't) shown on the public site
///  * Submissions:  what clients wrote through their invite link, to review
///  * Invites:      the private one-time links you've sent out
class TestimonialManagementScreen extends StatelessWidget {
  const TestimonialManagementScreen({super.key});

  static const _filterLabels = {
    'all': 'All',
    'published': 'Published',
    'hidden': 'Hidden',
    'featured': 'Featured',
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TestimonialManagementController());

    return AdminShell(
      title: 'Testimonials',
      eyebrow: 'Social proof',
      trailing: Padding(
        padding: EdgeInsets.only(right: 4.w),
        child: AdminPrimaryButton(
          label: 'Invite client',
          icon: Iconsax.send_2,
          onPressed: () => _openInvite(context, controller),
        ),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

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
                      AdminFilterChips(
                        values: const ['testimonials', 'submissions', 'invites'],
                        selected: controller.view.value,
                        labelOf: (v) => switch (v) {
                          'submissions' => controller.pendingCount > 0
                              ? 'Submissions (${controller.pendingCount} new)'
                              : 'Submissions',
                          'invites' => 'Invites',
                          _ => 'Testimonials',
                        },
                        onSelected: controller.setView,
                      ),
                      SizedBox(height: 18.h),
                      switch (controller.view.value) {
                        'submissions' => _SubmissionsView(controller: controller),
                        'invites' => _InvitesView(
                            controller: controller,
                            onInvite: () => _openInvite(context, controller),
                          ),
                        _ => _TestimonialsView(
                            controller: controller,
                            filterLabels: _filterLabels,
                          ),
                      },
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

  static void _openInvite(
    BuildContext context,
    TestimonialManagementController controller,
  ) {
    final before = controller.invites.length;
    showDialog(
      context: context,
      builder: (_) => TestimonialInviteDialog(
        onCreate: ({required clientName, required projectName, required validDays}) =>
            controller.createInvite(
              clientName: clientName,
              projectName: projectName,
              validDays: validDays,
            ),
        linkOf: controller.inviteLink,
        messageOf: controller.inviteMessage,
      ),
    ).then((_) {
      if (controller.invites.length > before) controller.setView('invites');
    });
  }
}

// =============================================================================
// TESTIMONIALS VIEW
// =============================================================================

class _TestimonialsView extends StatelessWidget {
  final TestimonialManagementController controller;
  final Map<String, String> filterLabels;
  const _TestimonialsView({required this.controller, required this.filterLabels});

  // Child views read Rx values, so they need their own Obx (the parent
  // Obx can't track reads made inside another widget's build).
  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final list = controller.filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminStatsGrid(
          items: [
            ('Total', '${controller.items.length}', Iconsax.quote_up),
            ('Published', '${controller.publishedCount}', Iconsax.eye),
            ('Featured', '${controller.featuredCount}', Iconsax.star),
            ('Avg. rating', controller.averageRating, Iconsax.like_1),
          ],
        ),
        SizedBox(height: 18.h),
        Row(
          children: [
            Expanded(
              child: AdminSearchField(
                hint: 'Search by client, company or quote',
                onChanged: controller.setSearch,
              ),
            ),
            SizedBox(width: 10.w),
            AdminOutlineButton(
              label: 'Add manually',
              icon: Icons.add_rounded,
              onPressed: () => _openForm(context, controller),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        AdminFilterChips(
          values: filterLabels.keys.toList(),
          selected: controller.filter.value,
          labelOf: (v) => filterLabels[v] ?? v,
          onSelected: controller.setFilter,
        ),
        SizedBox(height: 18.h),
        if (list.isEmpty)
          const AdminEmptyState(
            icon: Iconsax.quote_down,
            title: 'No testimonials yet',
            message:
                'Use “Invite client” to send a private link, and approved testimonials will appear here.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 2 : 1;
              final gap = 16.w;
              final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final item in list)
                    SizedBox(
                      width: width,
                      child: _TestimonialCard(
                        item: item,
                        onEdit: () => _openForm(context, controller, existing: item),
                        onToggle: () => controller.togglePublished(item),
                        onDelete: () async {
                          final ok = await confirmAdminDelete(
                            context,
                            title: 'Delete testimonial from “${item.clientName}”?',
                            message:
                                'This permanently removes it from Firebase and the public site.',
                          );
                          if (ok) await controller.delete(item);
                        },
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  Future<void> _openForm(
    BuildContext context,
    TestimonialManagementController controller, {
    TestimonialModel? existing,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TestimonialFormDialog(
        existing: existing,
        onSave: controller.save,
        // Changing a client's words removes their "Verified client" badge.
        originalQuote:
            existing != null && existing.source == TestimonialSources.client
                ? existing.quote
                : null,
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final TestimonialModel item;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TestimonialCard({
    required this.item,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fromClient = item.source == TestimonialSources.client;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: AdminNetworkImage(
                  url: item.avatarUrl,
                  width: 48.w,
                  height: 48.w,
                  fallbackIcon: Iconsax.user,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.clientName,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium().copyWith(fontSize: 15.sp),
                    ),
                    if (item.roleLine.isNotEmpty)
                      Text(item.roleLine, overflow: TextOverflow.ellipsis, style: AppTextStyles.small()),
                  ],
                ),
              ),
              _Stars(rating: item.rating),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            '“${item.quote}”',
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body().copyWith(height: 1.55, fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              AdminPill(
                text: item.published ? 'PUBLISHED' : 'HIDDEN',
                color: item.published ? AppColors.success : AppColors.textMuted,
              ),
              AdminPill(
                text: fromClient
                    ? (item.quoteEdited ? 'CLIENT · EDITED BY ME' : 'CLIENT SUBMITTED')
                    : 'ADDED BY ME',
                color: fromClient && !item.quoteEdited ? AppColors.primary : AppColors.warning,
              ),
              if (item.featured) const AdminPill(text: 'FEATURED', color: AppColors.accentGold),
              if (item.projectName.isNotEmpty)
                AdminPill(text: item.projectName.toUpperCase(), color: AppColors.info),
            ],
          ),
          SizedBox(height: 10.h),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: 6.h),
          Row(
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Iconsax.edit_2, size: 16),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: onToggle,
                icon: Icon(item.published ? Iconsax.eye_slash : Iconsax.eye, size: 16),
                label: Text(item.published ? 'Hide' : 'Publish'),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: Icon(Iconsax.trash, size: 18.sp, color: AppColors.danger),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUBMISSIONS VIEW
// =============================================================================

class _SubmissionsView extends StatelessWidget {
  final TestimonialManagementController controller;
  const _SubmissionsView({required this.controller});

  static const _labels = {
    'pending': 'Pending',
    'approved': 'Approved',
    'rejected': 'Rejected',
    'all': 'All',
  };

  // Child views read Rx values, so they need their own Obx (the parent
  // Obx can't track reads made inside another widget's build).
  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final list = controller.filteredSubmissions;
    int count(String s) => controller.submissions.where((e) => e.status == s).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminStatsGrid(
          items: [
            ('Pending', '${count(SubmissionStatuses.pending)}', Iconsax.timer_1),
            ('Approved', '${count(SubmissionStatuses.approved)}', Iconsax.tick_circle),
            ('Rejected', '${count(SubmissionStatuses.rejected)}', Iconsax.close_circle),
          ],
        ),
        SizedBox(height: 16.h),
        AdminFilterChips(
          values: _labels.keys.toList(),
          selected: controller.submissionFilter.value,
          labelOf: (v) => _labels[v] ?? v,
          onSelected: controller.setSubmissionFilter,
        ),
        SizedBox(height: 18.h),
        if (list.isEmpty)
          AdminEmptyState(
            icon: Iconsax.message_text,
            title: controller.submissionFilter.value == 'pending'
                ? 'Nothing waiting for review'
                : 'No submissions here',
            message:
                'When a client uses their invite link, their testimonial lands here for you to approve.',
          )
        else
          for (final submission in list)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _SubmissionCard(
                submission: submission,
                onReview: () => _review(context, submission),
                onReject: () => controller.reject(submission),
                onDelete: () async {
                  final ok = await confirmAdminDelete(
                    context,
                    title: 'Delete this submission?',
                    message: 'The submission from ${submission.clientName} will be permanently removed.',
                  );
                  if (ok) await controller.deleteSubmission(submission);
                },
              ),
            ),
      ],
    );
  }

  void _review(BuildContext context, TestimonialSubmissionModel submission) {
    final draft = TestimonialModel.empty().copyWith(
      clientName: submission.clientName,
      clientRole: submission.clientRole,
      company: submission.company,
      projectName: submission.projectName,
      quote: submission.quote,
      rating: submission.rating,
      source: TestimonialSources.client,
      published: true,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TestimonialFormDialog(
        existing: draft,
        bannerNote:
            'Submitted by the client through a private invite link. Check it over before approving. If you change their wording, the “Verified client” badge is removed.',
        submitLabel: 'Approve & publish',
        originalQuote: submission.quote,
        onSave: (edited) => controller.approve(submission, edited),
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final TestimonialSubmissionModel submission;
  final VoidCallback onReview;
  final VoidCallback onReject;
  final VoidCallback onDelete;

  const _SubmissionCard({
    required this.submission,
    required this.onReview,
    required this.onReject,
    required this.onDelete,
  });

  Color get _statusColor => switch (submission.status) {
    SubmissionStatuses.approved => AppColors.success,
    SubmissionStatuses.rejected => AppColors.danger,
    _ => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    final date = submission.createdAt > 0
        ? DateFormat('dd MMM yyyy, hh:mm a').format(
            DateTime.fromMillisecondsSinceEpoch(submission.createdAt),
          )
        : '';

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: submission.isPending ? AppColors.warning.withValues(alpha: .45) : AppColors.border,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.clientName,
                      style: AppTextStyles.bodyMedium().copyWith(fontSize: 15.sp),
                    ),
                    if (submission.roleLine.isNotEmpty)
                      Text(submission.roleLine, style: AppTextStyles.small()),
                  ],
                ),
              ),
              _Stars(rating: submission.rating),
              SizedBox(width: 10.w),
              AdminPill(text: SubmissionStatuses.label(submission.status).toUpperCase(), color: _statusColor),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '“${submission.quote}”',
            style: AppTextStyles.body().copyWith(height: 1.55, fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 14.w,
            runSpacing: 6.h,
            children: [
              if (submission.projectName.isNotEmpty)
                _Meta(icon: Iconsax.folder_2, text: submission.projectName),
              if (date.isNotEmpty) _Meta(icon: Iconsax.calendar_1, text: date),
            ],
          ),
          SizedBox(height: 10.h),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 8.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (submission.isPending) ...[
                AdminPrimaryButton(
                  label: 'Review & approve',
                  icon: Iconsax.tick_circle,
                  onPressed: onReview,
                ),
                AdminOutlineButton(
                  label: 'Reject',
                  icon: Iconsax.close_circle,
                  color: AppColors.danger,
                  onPressed: onReject,
                ),
              ],
              TextButton.icon(
                onPressed: onDelete,
                icon: Icon(Iconsax.trash, size: 16.sp),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// INVITES VIEW
// =============================================================================

class _InvitesView extends StatelessWidget {
  final TestimonialManagementController controller;
  final VoidCallback onInvite;
  const _InvitesView({required this.controller, required this.onInvite});

  // Child views read Rx values, so they need their own Obx (the parent
  // Obx can't track reads made inside another widget's build).
  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final list = controller.invites;
    int count(String s) => list.where((e) => e.status == s).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminStatsGrid(
          items: [
            ('Active', '${count('active')}', Iconsax.link_2),
            ('Used', '${count('used')}', Iconsax.tick_circle),
            ('Expired', '${count('expired')}', Iconsax.timer_pause),
          ],
        ),
        SizedBox(height: 18.h),
        if (list.isEmpty)
          Column(
            children: [
              const AdminEmptyState(
                icon: Iconsax.send_2,
                title: 'No invite links yet',
                message:
                    'Create a private one-time link for a client who finished a project with you.',
              ),
              SizedBox(height: 16.h),
              AdminPrimaryButton(label: 'Invite a client', icon: Iconsax.send_2, onPressed: onInvite),
            ],
          )
        else
          for (final invite in list)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _InviteCard(
                invite: invite,
                onCopyLink: () async {
                  await Clipboard.setData(ClipboardData(text: controller.inviteLink(invite.token)));
                  adminSnack('Link copied', invite.clientName.isEmpty ? 'Invite link' : invite.clientName);
                },
                onCopyMessage: () async {
                  await Clipboard.setData(ClipboardData(text: controller.inviteMessage(invite)));
                  adminSnack('Message copied', 'Paste it into an email or chat.');
                },
                onRevoke: () async {
                  final ok = await confirmAdminDelete(
                    context,
                    title: 'Revoke this invite?',
                    message: invite.used
                        ? 'This only removes the record. The testimonial already submitted is not affected.'
                        : 'The link will stop working immediately.',
                  );
                  if (ok) await controller.deleteInvite(invite);
                },
              ),
            ),
      ],
    );
  }
}

class _InviteCard extends StatelessWidget {
  final TestimonialInviteModel invite;
  final VoidCallback onCopyLink;
  final VoidCallback onCopyMessage;
  final VoidCallback onRevoke;

  const _InviteCard({
    required this.invite,
    required this.onCopyLink,
    required this.onCopyMessage,
    required this.onRevoke,
  });

  String _date(int millis) =>
      millis > 0 ? DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(millis)) : '–';

  @override
  Widget build(BuildContext context) {
    final active = invite.status == 'active';
    final color = switch (invite.status) {
      'used' => AppColors.success,
      'expired' => AppColors.textMuted,
      _ => AppColors.primary,
    };

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Iconsax.link_2, size: 18.sp, color: color),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.clientName.isEmpty ? 'Unnamed invite' : invite.clientName,
                      style: AppTextStyles.bodyMedium().copyWith(fontSize: 15.sp),
                    ),
                    if (invite.projectName.isNotEmpty)
                      Text(invite.projectName, style: AppTextStyles.small()),
                  ],
                ),
              ),
              AdminPill(text: invite.status.toUpperCase(), color: color),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 14.w,
            runSpacing: 6.h,
            children: [
              _Meta(icon: Iconsax.calendar_1, text: 'Created ${_date(invite.createdAt)}'),
              _Meta(
                icon: Iconsax.timer_1,
                text: invite.used
                    ? 'Used ${_date(invite.usedAt)}'
                    : 'Expires ${_date(invite.expiresAt)}',
              ),
            ],
          ),
          SizedBox(height: 10.h),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 8.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (active) ...[
                AdminPrimaryButton(label: 'Copy link', icon: Iconsax.copy, onPressed: onCopyLink),
                AdminOutlineButton(
                  label: 'Copy message',
                  icon: Iconsax.message_text,
                  onPressed: onCopyMessage,
                ),
              ],
              TextButton.icon(
                onPressed: onRevoke,
                icon: Icon(Iconsax.trash, size: 16.sp),
                label: Text(invite.used ? 'Remove' : 'Revoke'),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared bits
// =============================================================================

class _Stars extends StatelessWidget {
  final int rating;
  const _Stars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 17.sp,
          color: i < rating ? AppColors.accentGold : AppColors.textMuted,
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
