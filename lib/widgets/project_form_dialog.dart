import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/project_model.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_models.dart';
import 'package:sufyan_portfolio/utills/media_upload_zone.dart';

/// Add/Edit form for a single project. Pass [existing] to edit, or leave it
/// null to add a new one. Pops with `true` if a project was saved, so the
/// caller knows whether to refresh.
///
/// Only the fields the client Projects grid/card actually displays are
/// editable here (title, description, tech, categories, cover image,
/// links, featured/published). The case-study fields on [ProjectModel]
/// (fullDescription, features, gallery, challenge/solution/results) are
/// preserved as-is on edit and left blank on a new project — a fuller
/// case-study editor is a natural follow-up once /project-details exists.
class ProjectFormDialog extends StatefulWidget {
  final ProjectModel? existing;
  final ValueChanged<ProjectModel> onSave;

  const ProjectFormDialog({super.key, this.existing, required this.onSave});

  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _slugCtrl;
  late final TextEditingController _shortDescCtrl;
  late final TextEditingController _techCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _githubCtrl;
  late final TextEditingController _liveCtrl;

  late Set<String> _selectedCategories;
  late String _coverImageUrl;
  late bool _featured;
  late bool _published;
  bool _slugEditedManually = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _slugCtrl = TextEditingController(text: p?.slug ?? '');
    _shortDescCtrl = TextEditingController(text: p?.shortDescription ?? '');
    _techCtrl = TextEditingController(text: (p?.technologies ?? const []).join(', '));
    _yearCtrl = TextEditingController(
      text: (p?.year ?? DateTime.now().year).toString(),
    );
    _githubCtrl = TextEditingController(text: p?.githubUrl ?? '');
    _liveCtrl = TextEditingController(text: p?.liveUrl ?? '');
    _selectedCategories = {...(p?.categoryIds ?? const [])};
    _coverImageUrl = p?.coverImageUrl ?? '';
    _featured = p?.featured ?? false;
    _published = p?.published ?? true;
    _slugEditedManually = _isEditing; // don't auto-overwrite an existing slug
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _slugCtrl.dispose();
    _shortDescCtrl.dispose();
    _techCtrl.dispose();
    _yearCtrl.dispose();
    _githubCtrl.dispose();
    _liveCtrl.dispose();
    super.dispose();
  }

  static String _slugify(String input) {
    final lower = input.trim().toLowerCase();
    final dashed = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return dashed.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  void _onTitleChanged(String value) {
    if (!_slugEditedManually) {
      _slugCtrl.text = _slugify(value);
    }
  }

  List<String> _parseTechnologies() => _techCtrl.text
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final slug = _slugCtrl.text.trim().isEmpty
        ? _slugify(_titleCtrl.text)
        : _slugCtrl.text.trim();

    final draft = (widget.existing ?? ProjectModel.empty()).copyWith(
      title: _titleCtrl.text.trim(),
      slug: slug,
      shortDescription: _shortDescCtrl.text.trim(),
      technologies: _parseTechnologies(),
      categoryIds: _selectedCategories.toList(),
      year: int.tryParse(_yearCtrl.text.trim()) ?? DateTime.now().year,
      coverImageUrl: _coverImageUrl,
      githubUrl: _githubCtrl.text.trim(),
      liveUrl: _liveCtrl.text.trim(),
      featured: _featured,
      published: _published,
    );

    widget.onSave(draft);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 640.w, maxHeight: screenHeight * 0.86),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Divider(height: 1, color: AppColors.border),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCoverImageSection(),
                      SizedBox(height: 20.h),
                      _buildTextField(
                        controller: _titleCtrl,
                        label: 'Title',
                        hint: 'e.g. Velora',
                        onChanged: _onTitleChanged,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                      ),
                      SizedBox(height: 14.h),
                      _buildTextField(
                        controller: _slugCtrl,
                        label: 'Slug',
                        hint: 'auto-generated-from-title',
                        onChanged: (_) => setState(() => _slugEditedManually = true),
                      ),
                      SizedBox(height: 14.h),
                      _buildTextField(
                        controller: _shortDescCtrl,
                        label: 'Short description',
                        hint: 'One line for the project card',
                        maxLines: 2,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Short description is required'
                            : null,
                      ),
                      SizedBox(height: 14.h),
                      _buildTextField(
                        controller: _techCtrl,
                        label: 'Technologies',
                        hint: 'Flutter, Firebase, GetX',
                      ),
                      SizedBox(height: 14.h),
                      _buildCategoryPicker(),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _yearCtrl,
                              label: 'Year',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: _githubCtrl,
                              label: 'GitHub URL',
                              hint: 'https://github.com/...',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      _buildTextField(
                        controller: _liveCtrl,
                        label: 'Live demo URL',
                        hint: 'https://...',
                      ),
                      SizedBox(height: 14.h),
                      _buildToggleRow(
                        label: 'Featured',
                        subtitle: 'Show in highlighted/featured spots',
                        value: _featured,
                        onChanged: (v) => setState(() => _featured = v),
                      ),
                      SizedBox(height: 8.h),
                      _buildToggleRow(
                        label: 'Published',
                        subtitle: 'Visible on the public Projects page',
                        value: _published,
                        onChanged: (v) => setState(() => _published = v),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: AppColors.border),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 12.w, 20.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _isEditing ? 'Edit Project' : 'Add Project',
              style: AppTextStyles.h3(),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: Icon(Icons.close_rounded, color: AppColors.textMuted, size: 22.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cover image', style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
        SizedBox(height: 8.h),
        if (_coverImageUrl.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: CachedNetworkImage(
              imageUrl: _coverImageUrl,
              height: 140.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                height: 140.h,
                color: AppColors.surfaceSoft,
                alignment: Alignment.center,
                child: Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Upload a new image below to replace it.',
            style: AppTextStyles.small(),
          ),
          SizedBox(height: 10.h),
        ],
        MediaUploadZone(
          folder:
              'portfolio/projects/${_slugCtrl.text.isEmpty ? 'untitled' : _slugCtrl.text}/cover',
          kind: MediaUploadKind.image,
          multiple: false,
          maxFiles: 1,
          tileSize: 88,
          onUploaded: (CloudinaryUploadResult result) {
            setState(() => _coverImageUrl = result.secureUrl);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categories', style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final category in ProjectCategories.all)
              _CategoryChip(
                label: category,
                selected: _selectedCategories.contains(category),
                onTap: () => setState(() {
                  if (_selectedCategories.contains(category)) {
                    _selectedCategories.remove(category);
                  } else {
                    _selectedCategories.add(category);
                  }
                }),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
              Text(subtitle, style: AppTextStyles.small()),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: AppTextStyles.bodyMedium(color: AppColors.textSecondary)),
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text(_isEditing ? 'Save Changes' : 'Add Project'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          style: AppTextStyles.body(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.small(),
            filled: true,
            fillColor: AppColors.surfaceSoft,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
              borderSide: BorderSide(color: AppColors.primary, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.danger),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.small(
            color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
