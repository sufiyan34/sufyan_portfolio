import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/experience_model.dart';

class ExperienceFormDialog extends StatefulWidget {
  final ExperienceModel? existing;
  final Future<bool> Function(ExperienceModel draft) onSave;

  const ExperienceFormDialog({
    super.key,
    this.existing,
    required this.onSave,
  });

  @override
  State<ExperienceFormDialog> createState() => _ExperienceFormDialogState();
}

class _ExperienceFormDialogState extends State<ExperienceFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _roleCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _startDateCtrl;
  late final TextEditingController _endDateCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _achievementsCtrl;
  late final TextEditingController _technologiesCtrl;
  late final TextEditingController _sortOrderCtrl;

  late String _employmentType;
  late bool _isCurrent;
  late bool _published;
  late bool _featured;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final model = widget.existing ?? ExperienceModel.empty();

    _roleCtrl = TextEditingController(text: model.role);
    _companyCtrl = TextEditingController(text: model.company);
    _locationCtrl = TextEditingController(text: model.location);
    _startDateCtrl = TextEditingController(text: model.startDate);
    _endDateCtrl = TextEditingController(text: model.endDate);
    _descriptionCtrl = TextEditingController(text: model.description);
    _achievementsCtrl = TextEditingController(text: model.achievements.join('\n'));
    _technologiesCtrl = TextEditingController(text: model.technologies.join(', '));
    _sortOrderCtrl = TextEditingController(text: model.sortOrder.toString());

    _employmentType = model.employmentType;
    _isCurrent = model.isCurrent;
    _published = model.published;
    _featured = model.featured;
  }

  @override
  void dispose() {
    _roleCtrl.dispose();
    _companyCtrl.dispose();
    _locationCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _descriptionCtrl.dispose();
    _achievementsCtrl.dispose();
    _technologiesCtrl.dispose();
    _sortOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final existing = widget.existing;
    final draft = ExperienceModel(
      id: existing?.id ?? '',
      role: _roleCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      employmentType: _employmentType,
      location: _locationCtrl.text.trim(),
      startDate: _startDateCtrl.text.trim(),
      endDate: _isCurrent ? '' : _endDateCtrl.text.trim(),
      isCurrent: _isCurrent,
      description: _descriptionCtrl.text.trim(),
      achievements: _parseLines(_achievementsCtrl.text),
      technologies: _parseCommaList(_technologiesCtrl.text),
      sortOrder: int.tryParse(_sortOrderCtrl.text.trim()) ?? 0,
      published: _published,
      featured: _featured,
      createdAt: existing?.createdAt ?? 0,
      updatedAt: existing?.updatedAt ?? 0,
    );

    final success = await widget.onSave(draft);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width.clamp(360.0, 760.0).toDouble();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26.r),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.featureShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Role details',
                            style: AppTextStyles.h3().copyWith(fontSize: 18.sp),
                          ),
                          SizedBox(height: 14.h),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final compact = constraints.maxWidth < 560;
                              if (compact) {
                                return Column(
                                  children: [
                                    _field(
                                      _roleCtrl,
                                      'Role title',
                                      'e.g. Flutter Developer',
                                      required: true,
                                    ),
                                    SizedBox(height: 13.h),
                                    _field(
                                      _companyCtrl,
                                      'Company / client',
                                      'e.g. Acme Digital',
                                      required: true,
                                    ),
                                    SizedBox(height: 13.h),
                                    _field(
                                      _locationCtrl,
                                      'Location',
                                      'e.g. Lahore, Pakistan',
                                    ),
                                    SizedBox(height: 13.h),
                                    _typeField(),
                                  ],
                                );
                              }

                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _field(
                                          _roleCtrl,
                                          'Role title',
                                          'e.g. Flutter Developer',
                                          required: true,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: _field(
                                          _companyCtrl,
                                          'Company / client',
                                          'e.g. Acme Digital',
                                          required: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 13.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _field(
                                          _locationCtrl,
                                          'Location',
                                          'e.g. Lahore, Pakistan',
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(child: _typeField()),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 22.h),
                          Text(
                            'Timeline',
                            style: AppTextStyles.h3().copyWith(fontSize: 18.sp),
                          ),
                          SizedBox(height: 14.h),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final compact = constraints.maxWidth < 560;
                              final start = _field(
                                _startDateCtrl,
                                'Start date',
                                'e.g. Jan 2024 or 2024',
                                required: true,
                              );
                              final end = _field(
                                _endDateCtrl,
                                'End date',
                                'e.g. Aug 2025 or 2025',
                                required: !_isCurrent,
                              );

                              if (compact) {
                                return Column(
                                  children: [
                                    start,
                                    SizedBox(height: 13.h),
                                    end,
                                    SizedBox(height: 13.h),
                                    _switchTile(
                                      title: 'Current role',
                                      subtitle: 'Show “Present” on the public timeline',
                                      value: _isCurrent,
                                      onChanged: (value) =>
                                          setState(() => _isCurrent = value),
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: start),
                                  SizedBox(width: 12.w),
                                  Expanded(child: end),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _switchTile(
                                      title: 'Current role',
                                      subtitle: 'Show “Present”',
                                      value: _isCurrent,
                                      onChanged: (value) =>
                                          setState(() => _isCurrent = value),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 22.h),
                          Text(
                            'Story',
                            style: AppTextStyles.h3().copyWith(fontSize: 18.sp),
                          ),
                          SizedBox(height: 14.h),
                          _field(
                            _descriptionCtrl,
                            'Summary',
                            'A concise description of your responsibilities and impact.',
                            maxLines: 4,
                          ),
                          SizedBox(height: 13.h),
                          _field(
                            _achievementsCtrl,
                            'Key contributions',
                            'One contribution per line',
                            maxLines: 5,
                          ),
                          SizedBox(height: 13.h),
                          _field(
                            _technologiesCtrl,
                            'Technologies',
                            'Comma separated — Flutter, Firebase, REST API',
                            maxLines: 2,
                          ),
                          SizedBox(height: 22.h),
                          Text(
                            'Publishing',
                            style: AppTextStyles.h3().copyWith(fontSize: 18.sp),
                          ),
                          SizedBox(height: 14.h),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final compact = constraints.maxWidth < 560;
                              final order = _field(
                                _sortOrderCtrl,
                                'Display order',
                                '0',
                                keyboardType: TextInputType.number,
                              );
                              final publish = _switchTile(
                                title: 'Published',
                                subtitle: 'Visible on the public experience page',
                                value: _published,
                                onChanged: (value) =>
                                    setState(() => _published = value),
                              );
                              final featured = _switchTile(
                                title: 'Featured',
                                subtitle: 'Emphasize this experience entry',
                                value: _featured,
                                onChanged: (value) =>
                                    setState(() => _featured = value),
                              );

                              if (compact) {
                                return Column(
                                  children: [
                                    order,
                                    SizedBox(height: 13.h),
                                    publish,
                                    SizedBox(height: 13.h),
                                    featured,
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 150.w, child: order),
                                  SizedBox(width: 12.w),
                                  Expanded(child: publish),
                                  SizedBox(width: 12.w),
                                  Expanded(child: featured),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(height: 1, color: AppColors.border),
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 18.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            padding: EdgeInsets.symmetric(vertical: 13.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            padding: EdgeInsets.symmetric(vertical: 13.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                          ),
                          child: _saving
                              ? SizedBox(
                                  width: 18.sp,
                                  height: 18.sp,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textOnPrimary,
                                  ),
                                )
                              : Text(
                                  _isEditing
                                      ? 'Save Changes'
                                      : 'Add Experience',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 22.h, 18.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.work_outline_rounded,
              size: 21.sp,
              color: AppColors.textOnPrimary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Experience' : 'Add Experience',
                  style: AppTextStyles.h3().copyWith(fontSize: 20.sp),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Build the timeline clients see on your portfolio.',
                  style: AppTextStyles.small(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
            icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _typeField() {
    final values = {
      ...ExperienceTypes.suggested,
      if (_employmentType.trim().isNotEmpty) _employmentType,
    }.toList();

    return DropdownButtonFormField<String>(
      value: _employmentType,
      items: values
          .map(
            (value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
            ),
          )
          .toList(),
      onChanged: _saving
          ? null
          : (value) {
              if (value != null) setState(() => _employmentType = value);
            },
      style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
      decoration: _decoration('Employment type', 'Select type'),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium().copyWith(fontSize: 13.sp),
                ),
                SizedBox(height: 2.h),
                Text(subtitle, style: AppTextStyles.small()),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: _saving ? null : onChanged,
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
              ? '$label is required'
              : null
          : null,
      decoration: _decoration(label, hint),
    );
  }

  InputDecoration _decoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: AppTextStyles.small(color: AppColors.textSecondary),
      hintStyle: AppTextStyles.small(),
      filled: true,
      fillColor: AppColors.surfaceSoft,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    );
  }

  static List<String> _parseLines(String value) => value
      .split(RegExp(r'\r?\n'))
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toList();

  static List<String> _parseCommaList(String value) => value
      .split(',')
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toList();
}
