import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/package_model.dart';

class PackageFormDialog extends StatefulWidget {
  final PackageModel? existing;
  final Future<bool> Function(PackageModel draft) onSave;

  const PackageFormDialog({
    super.key,
    this.existing,
    required this.onSave,
  });

  @override
  State<PackageFormDialog> createState() => _PackageFormDialogState();
}

class _PackageFormDialogState extends State<PackageFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _shortDescriptionController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _pricingNoteController;
  late final TextEditingController _deliveryController;
  late final TextEditingController _revisionsController;
  late final TextEditingController _featuresController;
  late final TextEditingController _technologiesController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _ctaController;

  late String _type;
  late bool _published;
  late bool _featured;
  bool _saving = false;

  PackageModel get _initial => widget.existing ?? PackageModel.empty();

  @override
  void initState() {
    super.initState();
    final item = _initial;
    _titleController = TextEditingController(text: item.title);
    _shortDescriptionController = TextEditingController(text: item.shortDescription);
    _descriptionController = TextEditingController(text: item.description);
    _priceController = TextEditingController(
      text: item.price == 0 ? '' : item.price.toString(),
    );
    _currencyController = TextEditingController(text: item.currency);
    _pricingNoteController = TextEditingController(text: item.pricingNote);
    _deliveryController = TextEditingController(text: item.deliveryDays.toString());
    _revisionsController = TextEditingController(text: item.revisions.toString());
    _featuresController = TextEditingController(text: item.features.join('\n'));
    _technologiesController = TextEditingController(text: item.technologies.join(', '));
    _sortOrderController = TextEditingController(text: item.sortOrder.toString());
    _ctaController = TextEditingController(text: item.ctaLabel);
    _type = PackageTypes.normalize(item.type);
    _published = item.published;
    _featured = item.featured;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescriptionController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _pricingNoteController.dispose();
    _deliveryController.dispose();
    _revisionsController.dispose();
    _featuresController.dispose();
    _technologiesController.dispose();
    _sortOrderController.dispose();
    _ctaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final maxWidth = MediaQuery.of(context).size.width > 1050 ? 920.w : 720.w;

    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 0.92.sh),
        child: Padding(
          padding: EdgeInsets.all(26.w),
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
                          isEditing ? 'Edit Package' : 'Add Package',
                          style: AppTextStyles.h2().copyWith(fontSize: 30.sp),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'Define the package details, tier, and what the client receives.',
                          style: AppTextStyles.body().copyWith(fontSize: 13.5.sp),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final twoColumns = constraints.maxWidth >= 720;
                        return Column(
                          children: [
                            _section(
                              title: 'Package identity',
                              child: twoColumns
                                  ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: _field('Title', _titleController, requiredField: true)),
                                        SizedBox(width: 14.w),
                                        Expanded(child: _typeField()),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _field('Title', _titleController, requiredField: true),
                                        SizedBox(height: 12.h),
                                        _typeField(),
                                      ],
                                    ),
                            ),
                            SizedBox(height: 14.h),
                            _section(
                              title: 'Pricing & delivery',
                              child: twoColumns
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: _field(
                                            'Price',
                                            _priceController,
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            hintText: 'Leave empty for a fully custom quote',
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        SizedBox(width: 110.w, child: _field('Currency', _currencyController)),
                                        SizedBox(width: 12.w),
                                        Expanded(child: _field('Pricing note', _pricingNoteController)),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _field(
                                          'Price',
                                          _priceController,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          hintText: 'Leave empty for a fully custom quote',
                                        ),
                                        SizedBox(height: 12.h),
                                        Row(
                                          children: [
                                            Expanded(child: _field('Currency', _currencyController)),
                                            SizedBox(width: 12.w),
                                            Expanded(child: _field('Pricing note', _pricingNoteController)),
                                          ],
                                        ),
                                      ],
                                    ),
                            ),
                            SizedBox(height: 12.h),
                            if (twoColumns)
                              Row(
                                children: [
                                  Expanded(
                                    child: _field(
                                      'Delivery days',
                                      _deliveryController,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _field(
                                      'Revisions',
                                      _revisionsController,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(child: _field('Display order', _sortOrderController, keyboardType: TextInputType.number)),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(child: _field('Delivery days', _deliveryController, keyboardType: TextInputType.number)),
                                  SizedBox(width: 12.w),
                                  Expanded(child: _field('Revisions', _revisionsController, keyboardType: TextInputType.number)),
                                ],
                              ),
                            SizedBox(height: 14.h),
                            _section(
                              title: 'Client-facing copy',
                              child: Column(
                                children: [
                                  _field(
                                    'Short description',
                                    _shortDescriptionController,
                                    requiredField: true,
                                    maxLines: 3,
                                  ),
                                  SizedBox(height: 12.h),
                                  _field(
                                    'Full description',
                                    _descriptionController,
                                    maxLines: 4,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 14.h),
                            _section(
                              title: 'What is included',
                              child: Column(
                                children: [
                                  _field(
                                    'Included features',
                                    _featuresController,
                                    hintText: 'One feature per line',
                                    maxLines: 7,
                                  ),
                                  SizedBox(height: 12.h),
                                  _field(
                                    'Technologies / deliverable tags',
                                    _technologiesController,
                                    hintText: 'Comma separated',
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 14.h),
                            _section(
                              title: 'Publishing',
                              child: Column(
                                children: [
                                  _field('CTA label', _ctaController, requiredField: true),
                                  SizedBox(height: 10.h),
                                  SwitchListTile.adaptive(
                                    value: _published,
                                    onChanged: _saving ? null : (value) => setState(() => _published = value),
                                    contentPadding: EdgeInsets.zero,
                                    title: Text('Published', style: AppTextStyles.bodyMedium()),
                                    subtitle: Text('Show this package on the client page.', style: AppTextStyles.small()),
                                    activeColor: AppColors.primary,
                                  ),
                                  SwitchListTile.adaptive(
                                    value: _featured,
                                    onChanged: _saving ? null : (value) => setState(() => _featured = value),
                                    contentPadding: EdgeInsets.zero,
                                    title: Text('Featured', style: AppTextStyles.bodyMedium()),
                                    subtitle: Text('Give this package extra visual emphasis.', style: AppTextStyles.small()),
                                    activeColor: AppColors.accentGold,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    child: Text('Cancel', style: AppTextStyles.bodyMedium(color: AppColors.textSecondary)),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 13.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      elevation: 0,
                    ),
                    child: _saving
                        ? SizedBox(
                            width: 18.sp,
                            height: 18.sp,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isEditing ? 'Save Changes' : 'Add Package'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
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
          Text(title, style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp)),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool requiredField = false,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.body().copyWith(fontSize: 13.5.sp, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: AppTextStyles.small(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.small(),
        filled: true,
        fillColor: AppColors.surfaceSoft,
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
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      ),
      validator: requiredField
          ? (value) => value == null || value.trim().isEmpty ? '$label is required.' : null
          : null,
    );
  }

  Widget _typeField() {
    return DropdownButtonFormField<String>(
      initialValue: _type,
      decoration: InputDecoration(
        labelText: 'Package type',
        labelStyle: AppTextStyles.small(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceSoft,
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
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      items: PackageTypes.all
          .map(
            (type) => DropdownMenuItem<String>(
              value: type,
              child: Text(PackageTypes.label(type)),
            ),
          )
          .toList(),
      onChanged: _saving ? null : (value) => setState(() => _type = value ?? PackageTypes.silver),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final deliveryDays = int.tryParse(_deliveryController.text.trim()) ?? 0;
    final revisions = int.tryParse(_revisionsController.text.trim()) ?? 0;
    final sortOrder = int.tryParse(_sortOrderController.text.trim()) ?? 0;

    final draft = _initial.copyWith(
      title: _titleController.text.trim(),
      type: _type,
      shortDescription: _shortDescriptionController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      currency: _currencyController.text.trim().isEmpty
          ? 'USD'
          : _currencyController.text.trim().toUpperCase(),
      pricingNote: _pricingNoteController.text.trim().isEmpty
          ? (_type == PackageTypes.custom ? 'Custom quote' : 'Fixed package')
          : _pricingNoteController.text.trim(),
      deliveryDays: deliveryDays,
      revisions: revisions,
      features: _parseLines(_featuresController.text),
      technologies: _parseCommaList(_technologiesController.text),
      sortOrder: sortOrder,
      published: _published,
      featured: _featured,
      ctaLabel: _ctaController.text.trim(),
    );

    setState(() => _saving = true);
    final success = await widget.onSave(draft);
    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save package. Please try again.')),
      );
    }
  }

  List<String> _parseLines(String value) {
    return value
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> _parseCommaList(String value) {
    return value
        .split(RegExp(r'[,\n]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
