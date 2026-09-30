import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/skill_model.dart';
import 'package:sufyan_portfolio/widgets/skill_icon.dart';

class SkillFormDialog extends StatefulWidget {
  final SkillModel? existing;
  final Future<bool> Function(SkillModel draft) onSave;

  const SkillFormDialog({
    super.key,
    this.existing,
    required this.onSave,
  });

  @override
  State<SkillFormDialog> createState() => _SkillFormDialogState();
}

class _SkillFormDialogState extends State<SkillFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _sortOrderCtrl;

  late int _proficiency;
  late String _icon;
  late bool _published;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  static const _icons = <String, IconData>{
    'code': Icons.code_rounded,
    'phone': Icons.phone_android_rounded,
    'web': Icons.language_rounded,
    'backend': Icons.dns_rounded,
    'database': Icons.storage_rounded,
    'firebase': Icons.local_fire_department_rounded,
    'design': Icons.auto_awesome_rounded,
    'api': Icons.integration_instructions_rounded,
    'git': Icons.account_tree_rounded,
    'cloud': Icons.cloud_queue_rounded,
    'testing': Icons.verified_rounded,
    'architecture': Icons.account_tree_outlined,
    'tools': Icons.build_circle_outlined,
  };

  @override
  void initState() {
    super.initState();
    final skill = widget.existing;
    _nameCtrl = TextEditingController(text: skill?.name ?? '');
    _categoryCtrl = TextEditingController(text: skill?.category ?? 'Development');
    _descriptionCtrl = TextEditingController(text: skill?.description ?? '');
    _sortOrderCtrl = TextEditingController(text: (skill?.sortOrder ?? 0).toString());
    _proficiency = skill?.proficiency ?? 80;
    _icon = skill?.icon ?? 'code';
    _published = skill?.published ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _descriptionCtrl.dispose();
    _sortOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _saving) return;

    setState(() => _saving = true);

    final draft = (widget.existing ?? SkillModel.empty()).copyWith(
      name: _nameCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      proficiency: _proficiency,
      icon: _icon,
      sortOrder: int.tryParse(_sortOrderCtrl.text.trim()) ?? 0,
      published: _published,
    );

    final success = await widget.onSave(draft);
    if (!mounted) return;

    if (success) Navigator.of(context).pop(true);
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 620.w, maxHeight: height * 0.9),
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
                            _isEditing ? 'Edit Skill' : 'Add Skill',
                            style: AppTextStyles.h3(),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'Keep the skill short, specific, and client-friendly.',
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
              Divider(height: 1, color: AppColors.border),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _field(_nameCtrl, 'Skill name', 'e.g. Flutter Development', required: true)),
                          SizedBox(width: 12.w),
                          Expanded(child: _field(_categoryCtrl, 'Category', 'e.g. Mobile', required: true)),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _field(
                        _descriptionCtrl,
                        'Description',
                        'One or two lines describing what you can deliver.',
                        maxLines: 3,
                      ),
                      SizedBox(height: 18.h),
                      Text('Icon', style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
                      SizedBox(height: 10.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _icons.entries.map((entry) {
                          final selected = entry.key == _icon;
                          return InkWell(
                            onTap: _saving ? null : () => setState(() => _icon = entry.key),
                            borderRadius: BorderRadius.circular(14.r),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              width: 48.w,
                              height: 48.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected ? AppColors.primary : AppColors.surfaceSoft,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: selected ? AppColors.primary : AppColors.border,
                                ),
                              ),
                              child: Icon(
                                entry.value,
                                size: 20.sp,
                                color: selected ? AppColors.textOnPrimary : AppColors.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 22.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Proficiency',
                              style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
                            ),
                          ),
                          Text(
                            '$_proficiency%',
                            style: AppTextStyles.bodyMedium(color: AppColors.primary),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.surfaceMuted,
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withValues(alpha: 0.08),
                          trackHeight: 4.h,
                        ),
                        child: Slider(
                          value: _proficiency.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 20,
                          onChanged: _saving
                              ? null
                              : (value) => setState(() => _proficiency = value.round()),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(child: _field(_sortOrderCtrl, 'Display order', '0', keyboardType: TextInputType.number)),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                                        Text('Published', style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
                                        SizedBox(height: 2.h),
                                        Text(
                                          _published ? 'Visible on the public site' : 'Hidden from clients',
                                          style: AppTextStyles.small(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: _published,
                                    activeThumbColor: AppColors.primary,
                                    onChanged: _saving ? null : (value) => setState(() => _published = value),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                        onPressed: _saving ? null : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 13.h),
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
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
                            : Text(_isEditing ? 'Save Changes' : 'Add Skill'),
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
          ? (value) => value == null || value.trim().isEmpty ? '$label is required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.small(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.small(),
        filled: true,
        fillColor: AppColors.surfaceSoft,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
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
      ),
    );
  }
}
