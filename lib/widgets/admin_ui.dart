import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';

/// Small shared building blocks for the admin screens, written against the
/// same tokens the existing admin screens already use (AppColors /
/// AppTextStyles, 16-18 radius cards, 1px border, soft pills).

class AdminCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final bool shadow;

  const AdminCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding,
    this.shadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
        boxShadow: shadow ? AppColors.cardShadow : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: AppTextStyles.bodyMedium().copyWith(
                          fontSize: 14.sp,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          subtitle!,
                          style: AppTextStyles.small().copyWith(
                            fontSize: 11.5.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            SizedBox(height: 14.h),
          ],
          child,
        ],
      ),
    );
  }
}

/// Row of stat tiles (icon + number + label). Up to 4 columns on wide
/// layouts, 2 on narrow ones.
class AdminStatsGrid extends StatelessWidget {
  final List<(String label, String value, IconData icon)> items;
  const AdminStatsGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 900 ? items.length.clamp(1, 4) : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            mainAxisExtent: 92.h,
          ),
          itemBuilder: (_, index) {
            final item = items[index];
            return Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(item.$3, color: AppColors.primary, size: 18.sp),
                  ),
                  SizedBox(width: 11.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.$2,
                          style: AppTextStyles.h3().copyWith(fontSize: 22.sp),
                        ),
                        Text(
                          item.$1,
                          style: AppTextStyles.small(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class AdminSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const AdminSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.small(),
        prefixIcon: const Icon(Iconsax.search_normal_1),
        filled: true,
        fillColor: AppColors.surface,
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
      ),
    );
  }
}

/// Horizontally scrolling choice chips (same look as the Hire Requests filter).
class AdminFilterChips extends StatelessWidget {
  final List<String> values;
  final String selected;
  final String Function(String value) labelOf;
  final ValueChanged<String> onSelected;

  const AdminFilterChips({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: values.map((value) {
          final isSelected = selected == value;
          return Padding(
            padding: EdgeInsets.only(right: 7.w),
            child: ChoiceChip(
              selected: isSelected,
              label: Text(labelOf(value)),
              onSelected: (_) => onSelected(value),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              showCheckmark: false,
              side: const BorderSide(color: AppColors.border),
              labelStyle: AppTextStyles.small(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AdminPill extends StatelessWidget {
  final String text;
  final Color color;
  const AdminPill({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTextStyles.small(
          color: color,
        ).copyWith(fontSize: 10.sp, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 70.h, horizontal: 24.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34.sp, color: AppColors.textMuted),
          SizedBox(height: 12.h),
          Text(title, style: AppTextStyles.h3(), textAlign: TextAlign.center),
          SizedBox(height: 6.h),
          Text(
            message,
            style: AppTextStyles.body(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AdminPrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expand;

  const AdminPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? SizedBox(
            width: 18.sp,
            height: 18.sp,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.textOnPrimary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 17.sp),
                SizedBox(width: 8.w),
              ],
              Text(label),
            ],
          );

    return SizedBox(
      width: expand ? double.infinity : null,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: child,
      ),
    );
  }
}

class AdminOutlineButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;

  const AdminOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? AppColors.textPrimary;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 16.sp),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        side: BorderSide(
          color: color?.withValues(alpha: 0.4) ?? AppColors.border,
        ),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}

InputDecoration adminInputDecoration(
  String label, {
  String? hint,
  Widget? suffix,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixIcon: suffix,
    labelStyle: AppTextStyles.small(color: AppColors.textSecondary),
    hintStyle: AppTextStyles.small(),
    filled: true,
    fillColor: AppColors.surfaceSoft,
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
    border: border(AppColors.border),
    enabledBorder: border(AppColors.border),
    focusedBorder: border(AppColors.primary, 1.2),
    errorBorder: border(AppColors.danger),
    focusedErrorBorder: border(AppColors.danger, 1.2),
  );
}

/// Standard text field used across the new admin forms.
class AdminTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final bool required;
  final TextInputType? keyboardType;
  final bool enabled;

  const AdminTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.required = false,
    this.keyboardType,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
      validator: required
          ? (value) =>
                value == null || value.trim().isEmpty ? '$label is required' : null
          : null,
      decoration: adminInputDecoration(label, hint: hint),
    );
  }
}

/// Two fields side by side on wide layouts, stacked on narrow ones.
class AdminTwoCol extends StatelessWidget {
  final Widget left;
  final Widget right;
  const AdminTwoCol({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(children: [left, SizedBox(height: 14.h), right]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: 14.w),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

Future<bool> confirmAdminDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(title, style: AppTextStyles.h3().copyWith(fontSize: 21.sp)),
      content: Text(message, style: AppTextStyles.body()),
      actionsPadding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 16.h),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed == true;
}

void adminSnack(String title, String message, {bool error = false}) {
  Get.snackbar(
    title,
    message,
    backgroundColor: error
        ? AppColors.danger.withValues(alpha: 0.12)
        : AppColors.primarySoft,
    colorText: error ? AppColors.danger : AppColors.primary,
    margin: EdgeInsets.all(16.w),
    maxWidth: 420,
  );
}

/// Shows a Cloudinary-hosted (or any https) image with a tidy fallback.
class AdminNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final BorderRadius? radius;

  const AdminNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Iconsax.gallery,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: AppColors.surfaceMuted,
      child: Icon(fallbackIcon, color: AppColors.textMuted, size: 22.sp),
    );

    final image = url.trim().isEmpty
        ? placeholder
        : Image.network(
            url,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => placeholder,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : placeholder,
          );

    return radius == null
        ? image
        : ClipRRect(borderRadius: radius!, child: image);
  }
}
