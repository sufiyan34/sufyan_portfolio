import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/service_model.dart';
import 'package:sufyan_portfolio/widgets/service_icon.dart';

class ServiceFormDialog extends StatefulWidget {
  final ServiceModel? existing;
  final Future<bool> Function(ServiceModel draft) onSave;

  const ServiceFormDialog({
    super.key,
    this.existing,
    required this.onSave,
  });

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _shortDescriptionController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _featuresController;
  late final TextEditingController _technologiesController;
  late final TextEditingController _sortOrderController;

  late String _icon;
  late bool _published;
  late bool _featured;
  bool _saving = false;

  ServiceModel get _initial => widget.existing ?? ServiceModel.empty();

  @override
  void initState() {
    super.initState();
    final service = _initial;
    _titleController = TextEditingController(text: service.title);
    _categoryController = TextEditingController(text: service.category);
    _shortDescriptionController = TextEditingController(
      text: service.shortDescription,
    );
    _descriptionController = TextEditingController(text: service.description);
    _featuresController = TextEditingController(text: service.features.join('\n'));
    _technologiesController = TextEditingController(
      text: service.technologies.join(', '),
    );
    _sortOrderController = TextEditingController(
      text: service.sortOrder.toString(),
    );
    _icon = service.icon;
    _published = service.published;
    _featured = service.featured;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _shortDescriptionController.dispose();
    _descriptionController.dispose();
    _featuresController.dispose();
    _technologiesController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final draft = ServiceModel(
      id: widget.existing?.id ?? '',
      title: _titleController.text.trim(),
      category: _categoryController.text.trim(),
      shortDescription: _shortDescriptionController.text.trim(),
      description: _descriptionController.text.trim(),
      features: _parseLines(_featuresController.text),
      technologies: _parseCommaList(_technologiesController.text),
      icon: _icon,
      sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
      published: _published,
      featured: _featured,
      createdAt: widget.existing?.createdAt ?? 0,
      updatedAt: widget.existing?.updatedAt ?? 0,
    );

    setState(() => _saving = true);
    final success = await widget.onSave(draft);
    if (!mounted) return;
    setState(() => _saving = false);

    if (success) Navigator.of(context).pop();
  }

  List<String> _parseLines(String raw) => raw
      .split('\n')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();

  List<String> _parseCommaList(String raw) => raw
      .split(RegExp(r'[,\n]'))
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();

  InputDecoration _decoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: AppTextStyles.small(color: AppColors.textSecondary),
      hintStyle: AppTextStyles.small(),
      filled: true,
      fillColor: AppColors.surfaceSoft,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    final width = MediaQuery.of(context).size.width;
    final dialogWidth = width >= 1100 ? 940.w : width >= 700 ? 700.w : width * 0.94;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: SizedBox(
        width: dialogWidth,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 22.h, 16.w, 12.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            editing ? 'Edit Service' : 'Add Service',
                            style: AppTextStyles.h3().copyWith(fontSize: 22.sp),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            editing
                                ? 'Refine how this capability is presented on your portfolio.'
                                : 'Create a clear service card for your public portfolio.',
                            style: AppTextStyles.small(),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _saving ? null : () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, size: 21.sp),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.border),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 10.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 650;
                            final basic = Column(
                              children: [
                                TextFormField(
                                  controller: _titleController,
                                  textInputAction: TextInputAction.next,
                                  decoration: _decoration(label: 'Service title', hint: 'Flutter Development'),
                                  validator: (value) => (value == null || value.trim().isEmpty)
                                      ? 'Title is required'
                                      : null,
                                ),
                                SizedBox(height: 12.h),
                                TextFormField(
                                  controller: _categoryController,
                                  textInputAction: TextInputAction.next,
                                  decoration: _decoration(
                                    label: 'Category',
                                    hint: 'Mobile Development',
                                  ),
                                  validator: (value) => (value == null || value.trim().isEmpty)
                                      ? 'Category is required'
                                      : null,
                                ),
                                SizedBox(height: 12.h),
                                TextFormField(
                                  controller: _shortDescriptionController,
                                  maxLength: 150,
                                  textInputAction: TextInputAction.next,
                                  decoration: _decoration(
                                    label: 'Short description',
                                    hint: 'Modern, high-performance cross-platform apps.',
                                  ),
                                  validator: (value) => (value == null || value.trim().isEmpty)
                                      ? 'Short description is required'
                                      : null,
                                ),
                              ],
                            );

                            final iconBox = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Service icon', style: AppTextStyles.bodyMedium().copyWith(fontSize: 13.sp)),
                                SizedBox(height: 9.h),
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: ServiceIconBadge.options.map((key) {
                                    return ServiceIconOption(
                                      iconKey: key,
                                      selected: _icon == key,
                                      onTap: () => setState(() => _icon = key),
                                    );
                                  }).toList(),
                                ),
                              ],
                            );

                            if (compact) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [basic, SizedBox(height: 18.h), iconBox],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: basic),
                                SizedBox(width: 18.w),
                                SizedBox(width: 360.w, child: iconBox),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 14.h),
                        TextFormField(
                          controller: _descriptionController,
                          minLines: 4,
                          maxLines: 7,
                          decoration: _decoration(
                            label: 'Detailed description',
                            hint: 'Explain the outcome, scope, and value of this service.',
                          ),
                          validator: (value) => (value == null || value.trim().isEmpty)
                              ? 'Description is required'
                              : null,
                        ),
                        SizedBox(height: 14.h),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 650;
                            final features = TextFormField(
                              controller: _featuresController,
                              minLines: 4,
                              maxLines: 7,
                              decoration: _decoration(
                                label: 'Key features / deliverables',
                                hint: 'One item per line',
                              ),
                            );
                            final technologies = TextFormField(
                              controller: _technologiesController,
                              minLines: 4,
                              maxLines: 7,
                              decoration: _decoration(
                                label: 'Technologies / methods',
                                hint: 'Flutter, Firebase, REST APIs',
                              ),
                            );

                            if (compact) {
                              return Column(
                                children: [features, SizedBox(height: 14.h), technologies],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: features),
                                SizedBox(width: 14.w),
                                Expanded(child: technologies),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 14.h),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 650;
                            final order = TextFormField(
                              controller: _sortOrderController,
                              keyboardType: TextInputType.number,
                              decoration: _decoration(
                                label: 'Display order',
                                hint: '0',
                              ),
                            );
                            final status = Column(
                              children: [
                                SwitchListTile.adaptive(
                                  value: _published,
                                  onChanged: _saving ? null : (value) => setState(() => _published = value),
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: AppColors.primary,
                                  title: Text('Published', style: AppTextStyles.bodyMedium().copyWith(fontSize: 13.sp)),
                                  subtitle: Text('Show on the public Services page', style: AppTextStyles.small()),
                                ),
                                SwitchListTile.adaptive(
                                  value: _featured,
                                  onChanged: _saving ? null : (value) => setState(() => _featured = value),
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: AppColors.primary,
                                  title: Text('Featured', style: AppTextStyles.bodyMedium().copyWith(fontSize: 13.sp)),
                                  subtitle: Text('Give this service a stronger visual emphasis', style: AppTextStyles.small()),
                                ),
                              ],
                            );

                            if (compact) {
                              return Column(
                                children: [order, SizedBox(height: 8.h), status],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 180.w, child: order),
                                SizedBox(width: 18.w),
                                Expanded(child: status),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 18.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving ? null : () => Navigator.of(context).pop(),
                      child: Text('Cancel', style: AppTextStyles.bodyMedium(color: AppColors.textSecondary)),
                    ),
                    SizedBox(width: 10.w),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      icon: _saving
                          ? SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_rounded),
                      label: Text(_saving ? 'Saving...' : editing ? 'Save Changes' : 'Add Service'),
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
