import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/testimonial_model.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_models.dart';
import 'package:sufyan_portfolio/utills/cloudinary_registry.dart';
import 'package:sufyan_portfolio/utills/media_upload_zone.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';

class TestimonialFormDialog extends StatefulWidget {
  final TestimonialModel? existing;
  final Future<bool> Function(TestimonialModel draft) onSave;

  /// Set when reviewing a client's submission: shown as a note at the top and
  /// switches the dialog to "Review testimonial" mode.
  final String? bannerNote;

  /// Overrides the confirm button label (e.g. "Approve & publish").
  final String? submitLabel;

  /// The client's original wording. If the saved quote differs, the
  /// testimonial is flagged as edited (and loses the "Verified client" badge).
  final String? originalQuote;

  const TestimonialFormDialog({
    super.key,
    this.existing,
    required this.onSave,
    this.bannerNote,
    this.submitLabel,
    this.originalQuote,
  });

  @override
  State<TestimonialFormDialog> createState() => _TestimonialFormDialogState();
}

class _TestimonialFormDialogState extends State<TestimonialFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _role;
  late final TextEditingController _company;
  late final TextEditingController _project;
  late final TextEditingController _quote;
  late final TextEditingController _order;
  late final TextEditingController _avatarUrl;

  late int _rating;
  late bool _featured;
  late bool _published;
  bool _saving = false;

  final bool _cloudinaryReady = ensureCloudinaryService() != null;

  bool get _isEditing =>
      widget.existing != null && widget.existing!.id.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final t = widget.existing ?? TestimonialModel.empty();
    _name = TextEditingController(text: t.clientName);
    _role = TextEditingController(text: t.clientRole);
    _company = TextEditingController(text: t.company);
    _project = TextEditingController(text: t.projectName);
    _quote = TextEditingController(text: t.quote);
    _order = TextEditingController(text: t.sortOrder.toString());
    _avatarUrl = TextEditingController(text: t.avatarUrl);
    _rating = t.rating;
    _featured = t.featured;
    _published = t.published;
  }

  @override
  void dispose() {
    for (final c in [_name, _role, _company, _project, _quote, _order, _avatarUrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);

    final draft = (widget.existing ?? TestimonialModel.empty()).copyWith(
      clientName: _name.text.trim(),
      clientRole: _role.text.trim(),
      company: _company.text.trim(),
      projectName: _project.text.trim(),
      quote: _quote.text.trim(),
      rating: _rating,
      avatarUrl: _avatarUrl.text.trim(),
      featured: _featured,
      published: _published,
      quoteEdited:
          (widget.originalQuote != null &&
              widget.originalQuote!.trim() != _quote.text.trim()) ||
          (widget.existing?.quoteEdited ?? false),
      sortOrder: int.tryParse(_order.text.trim()) ?? 0,
    );

    final ok = await widget.onSave(draft);
    if (!mounted) return;
    if (ok) Navigator.of(context).pop(true);
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 640.w, maxHeight: height * 0.92),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 12.w, 18.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.bannerNote != null
                                ? 'Review Testimonial'
                                : (_isEditing ? 'Edit Testimonial' : 'Add Testimonial'),
                            style: AppTextStyles.h3(),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'Real words from a real client work best.',
                            style: AppTextStyles.small(),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _saving ? null : () => Navigator.of(context).pop(false),
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
                      if (widget.bannerNote != null)
                        _Notice(
                          icon: Iconsax.verify,
                          text: widget.bannerNote!,
                          color: AppColors.primary,
                        )
                      else if (!_isEditing)
                        const _Notice(
                          icon: Iconsax.info_circle,
                          text:
                              'Only add words a client actually gave you, with their permission. Clients can also submit their own through an invite link, which is the better route.',
                          color: AppColors.warning,
                        ),
                      AdminTwoCol(
                        left: AdminTextField(
                          controller: _name,
                          label: 'Client name',
                          hint: 'e.g. Sara Khan',
                          required: true,
                        ),
                        right: AdminTextField(
                          controller: _role,
                          label: 'Role',
                          hint: 'e.g. Product Manager',
                        ),
                      ),
                      SizedBox(height: 14.h),
                      AdminTwoCol(
                        left: AdminTextField(
                          controller: _company,
                          label: 'Company',
                          hint: 'e.g. Acme Inc.',
                        ),
                        right: AdminTextField(
                          controller: _project,
                          label: 'Project (optional)',
                          hint: 'e.g. Delivery app',
                        ),
                      ),
                      SizedBox(height: 14.h),
                      AdminTextField(
                        controller: _quote,
                        label: 'Testimonial',
                        hint: 'What did the client say about working with you?',
                        maxLines: 5,
                        required: true,
                      ),
                      SizedBox(height: 18.h),
                      Text('Rating', style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
                      SizedBox(height: 8.h),
                      Row(
                        children: List.generate(5, (i) {
                          final filled = i < _rating;
                          return InkWell(
                            onTap: _saving ? null : () => setState(() => _rating = i + 1),
                            borderRadius: BorderRadius.circular(8.r),
                            child: Padding(
                              padding: EdgeInsets.all(3.w),
                              child: Icon(
                                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 30.sp,
                                color: filled ? AppColors.accentGold : AppColors.textMuted,
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 18.h),
                      Text('Client photo', style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
                      SizedBox(height: 10.h),
                      if (_avatarUrl.text.trim().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Row(
                            children: [
                              ClipOval(
                                child: AdminNetworkImage(
                                  url: _avatarUrl.text.trim(),
                                  width: 56.w,
                                  height: 56.w,
                                  fallbackIcon: Iconsax.user,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              TextButton.icon(
                                onPressed: _saving
                                    ? null
                                    : () => setState(() => _avatarUrl.clear()),
                                icon: const Icon(Iconsax.trash, size: 16),
                                label: const Text('Remove photo'),
                                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                              ),
                            ],
                          ),
                        ),
                      if (_cloudinaryReady)
                        MediaUploadZone(
                          folder: 'portfolio/testimonials',
                          kind: MediaUploadKind.image,
                          multiple: false,
                          maxFiles: 1,
                          tileSize: 88,
                          onUploaded: (CloudinaryUploadResult result) =>
                              setState(() => _avatarUrl.text = result.secureUrl),
                        )
                      else
                        AdminTextField(
                          controller: _avatarUrl,
                          label: 'Photo URL',
                          hint: 'Cloudinary is not configured — paste an image URL',
                        ),
                      SizedBox(height: 18.h),
                      AdminTwoCol(
                        left: AdminTextField(
                          controller: _order,
                          label: 'Display order',
                          hint: '0',
                          keyboardType: TextInputType.number,
                        ),
                        right: Column(
                          children: [
                            _SwitchTile(
                              title: 'Published',
                              subtitle: _published ? 'Visible on the public site' : 'Hidden from visitors',
                              value: _published,
                              onChanged: _saving ? null : (v) => setState(() => _published = v),
                            ),
                            SizedBox(height: 10.h),
                            _SwitchTile(
                              title: 'Featured',
                              subtitle: 'Highlight this one first',
                              value: _featured,
                              onChanged: _saving ? null : (v) => setState(() => _featured = v),
                            ),
                          ],
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
                    Expanded(
                      child: AdminOutlineButton(
                        label: 'Cancel',
                        onPressed: _saving ? null : () => Navigator.of(context).pop(false),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: AdminPrimaryButton(
                        label: widget.submitLabel ??
                            (_isEditing ? 'Save Changes' : 'Add Testimonial'),
                        loading: _saving,
                        expand: true,
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
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
                Text(title, style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
                SizedBox(height: 2.h),
                Text(subtitle, style: AppTextStyles.small()),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Notice({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 18.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.small(color: AppColors.textPrimary)
                  .copyWith(height: 1.5, fontSize: 12.5.sp),
            ),
          ),
        ],
      ),
    );
  }
}
