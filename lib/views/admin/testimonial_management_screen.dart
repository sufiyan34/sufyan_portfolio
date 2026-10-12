import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/testimonial_management_controller.dart';
import 'package:sufyan_portfolio/models/testimonial_model.dart';
import 'package:sufyan_portfolio/widgets/admin_shell.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';
import 'package:sufyan_portfolio/widgets/testimonial_form_dialog.dart';

/// Admin > Testimonials: manage the client quotes shown on the public site.
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
          label: 'Add',
          icon: Icons.add_rounded,
          onPressed: () => _openForm(context, controller),
        ),
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
                          ('Total', '${controller.items.length}', Iconsax.quote_up),
                          ('Published', '${controller.publishedCount}', Iconsax.eye),
                          ('Featured', '${controller.featuredCount}', Iconsax.star),
                          ('Avg. rating', controller.averageRating, Iconsax.like_1),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      AdminSearchField(
                        hint: 'Search by client, company or quote',
                        onChanged: controller.setSearch,
                      ),
                      SizedBox(height: 12.h),
                      AdminFilterChips(
                        values: _filterLabels.keys.toList(),
                        selected: controller.filter.value,
                        labelOf: (v) => _filterLabels[v] ?? v,
                        onSelected: controller.setFilter,
                      ),
                      SizedBox(height: 18.h),
                      if (list.isEmpty)
                        const AdminEmptyState(
                          icon: Iconsax.quote_down,
                          title: 'No testimonials yet',
                          message: 'Add your first client testimonial with the button above.',
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
                                          message: 'This permanently removes it from Firebase and the public site.',
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
                  ),
                ),
              ),
            ],
          ),
        );
      }),
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
      builder: (_) => TestimonialFormDialog(existing: existing, onSave: controller.save),
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
                      Text(
                        item.roleLine,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.small(),
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < item.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 17.sp,
                    color: i < item.rating ? AppColors.accentGold : AppColors.textMuted,
                  ),
                ),
              ),
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
              if (item.featured)
                const AdminPill(text: 'FEATURED', color: AppColors.accentGold),
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
