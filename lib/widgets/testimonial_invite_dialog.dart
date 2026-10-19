import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/testimonial_invite_model.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';

/// Two-step dialog: 1) who is the invite for, 2) copy the private link / a
/// ready-to-send message.
class TestimonialInviteDialog extends StatefulWidget {
  final Future<TestimonialInviteModel?> Function({
    required String clientName,
    required String projectName,
    required int validDays,
  })
  onCreate;
  final String Function(String token) linkOf;
  final String Function(TestimonialInviteModel invite) messageOf;

  const TestimonialInviteDialog({
    super.key,
    required this.onCreate,
    required this.linkOf,
    required this.messageOf,
  });

  @override
  State<TestimonialInviteDialog> createState() => _TestimonialInviteDialogState();
}

class _TestimonialInviteDialogState extends State<TestimonialInviteDialog> {
  final _name = TextEditingController();
  final _project = TextEditingController();
  int _days = 30;
  bool _creating = false;
  TestimonialInviteModel? _invite;

  @override
  void dispose() {
    _name.dispose();
    _project.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() => _creating = true);
    final invite = await widget.onCreate(
      clientName: _name.text,
      projectName: _project.text,
      validDays: _days,
    );
    if (!mounted) return;
    setState(() {
      _creating = false;
      _invite = invite;
    });
  }

  Future<void> _copy(String text, String what) async {
    await Clipboard.setData(ClipboardData(text: text));
    adminSnack('$what copied', 'Paste it into an email or chat.');
  }

  @override
  Widget build(BuildContext context) {
    final invite = _invite;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560.w),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      invite == null ? 'Invite a client' : 'Invite link ready',
                      style: AppTextStyles.h3(),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, size: 22.sp),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                invite == null
                    ? 'Creates a private, one-time link. The client writes their own testimonial and you approve it before it goes live.'
                    : 'Send this to the client. It works once and then stops.',
                style: AppTextStyles.small(),
              ),
              SizedBox(height: 20.h),
              if (invite == null) ..._form() else ..._result(invite),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _form() {
    return [
      AdminTextField(
        controller: _name,
        label: 'Client name (optional)',
        hint: 'Used to greet them and pre-fill the form',
      ),
      SizedBox(height: 14.h),
      AdminTextField(
        controller: _project,
        label: 'Project (optional)',
        hint: 'e.g. Delivery app',
      ),
      SizedBox(height: 18.h),
      Text('Link stays valid for', style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
      SizedBox(height: 10.h),
      AdminFilterChips(
        values: const ['7', '14', '30', '90'],
        selected: '$_days',
        labelOf: (v) => '$v days',
        onSelected: (v) => setState(() => _days = int.parse(v)),
      ),
      SizedBox(height: 24.h),
      AdminPrimaryButton(
        label: 'Create invite link',
        icon: Iconsax.link_2,
        loading: _creating,
        expand: true,
        onPressed: _create,
      ),
    ];
  }

  List<Widget> _result(TestimonialInviteModel invite) {
    final link = widget.linkOf(invite.token);

    return [
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: SelectableText(link, style: AppTextStyles.small().copyWith(height: 1.5)),
      ),
      SizedBox(height: 16.h),
      Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: [
          AdminPrimaryButton(
            label: 'Copy link',
            icon: Iconsax.copy,
            onPressed: () => _copy(link, 'Link'),
          ),
          AdminOutlineButton(
            label: 'Copy ready-to-send message',
            icon: Iconsax.message_text,
            onPressed: () => _copy(widget.messageOf(invite), 'Message'),
          ),
        ],
      ),
      SizedBox(height: 14.h),
      Text(
        'You can find this link again under Invites. Revoking it there stops it working.',
        style: AppTextStyles.small(),
      ),
    ];
  }
}
