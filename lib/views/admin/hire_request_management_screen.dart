import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/hire_request_management_controller.dart';
import 'package:sufyan_portfolio/models/hire_request_model.dart';
import 'package:sufyan_portfolio/widgets/admin_shell.dart';

class HireRequestManagementScreen extends StatelessWidget {
  const HireRequestManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HireRequestManagementController());
    return AdminShell(
      title: 'Hire Requests',
      eyebrow: 'Client requests',
      trailing: IconButton(
        tooltip: 'Refresh',
        onPressed: controller.loadRequests,
        icon: const Icon(Iconsax.refresh, size: 19),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = controller.filteredRequests;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.loadRequests,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(22.w, 20.h, 22.w, 30.h),
            children: [
              _Stats(requests: controller.requests),
              SizedBox(height: 18.h),
              _Toolbar(controller: controller),
              SizedBox(height: 18.h),
              if (requests.isEmpty)
                _EmptyState()
              else
                ...requests.map(
                  (request) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _RequestCard(request: request),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _Stats extends StatelessWidget {
  final List<HireRequestModel> requests;
  const _Stats({required this.requests});

  @override
  Widget build(BuildContext context) {
    final newCount = requests
        .where((item) => item.status == HireRequestStatuses.newRequest)
        .length;
    final activeCount = requests
        .where(
          (item) => !{
            HireRequestStatuses.completed,
            HireRequestStatuses.rejected,
            HireRequestStatuses.cancelled,
          }.contains(item.status),
        )
        .length;
    final proposals = requests
        .where((item) => item.status == HireRequestStatuses.proposalSent)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : 2;
        final items = [
          ('Total', requests.length.toString(), Iconsax.briefcase),
          ('New', newCount.toString(), Iconsax.star),
          ('Active', activeCount.toString(), Iconsax.activity),
          ('Proposals', proposals.toString(), Iconsax.document_text),
        ];
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            mainAxisExtent: 102.h,
          ),
          itemBuilder: (_, index) {
            final item = items[index];
            return Container(
              padding: EdgeInsets.all(16.w),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.$2,
                        style: AppTextStyles.h3().copyWith(fontSize: 22.sp),
                      ),
                      Text(item.$1, style: AppTextStyles.small()),
                    ],
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

class _Toolbar extends StatelessWidget {
  final HireRequestManagementController controller;
  const _Toolbar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: controller.setSearch,
          decoration: InputDecoration(
            hintText: 'Search name, company, project, email…',
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
          ),
        ),
        SizedBox(height: 11.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(
            () => Row(
              children: controller.filters.map((status) {
                final selected = controller.selectedStatus.value == status;
                return Padding(
                  padding: EdgeInsets.only(right: 7.w),
                  child: ChoiceChip(
                    selected: selected,
                    label: Text(
                      status == kAllHireRequestsFilter
                          ? 'All'
                          : HireRequestStatuses.label(status),
                    ),
                    onSelected: (_) => controller.selectStatus(status),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border),
                    labelStyle: AppTextStyles.small(
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  final HireRequestModel request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final date = request.createdAt > 0
        ? DateFormat('dd MMM yyyy, hh:mm a')
              .format(DateTime.fromMillisecondsSinceEpoch(request.createdAt))
        : 'Just now';

    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: () =>
          Get.toNamed(AppRoutes.hireRequestDetails, arguments: request.id),
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: Icon(
                Iconsax.briefcase,
                color: AppColors.primary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          request.projectName.isEmpty
                              ? 'Untitled project'
                              : request.projectName,
                          style: AppTextStyles.h3().copyWith(fontSize: 17.sp),
                        ),
                      ),
                      _StatusBadge(status: request.status),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${request.name}${request.company.isEmpty ? '' : ' • ${request.company}'}',
                    style: AppTextStyles.bodyMedium().copyWith(
                      fontSize: 12.5.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    [
                      request.projectType,
                      request.serviceTitle,
                      request.packageTitle,
                    ].where((e) => e.trim().isNotEmpty).join(' • '),
                    style: AppTextStyles.small().copyWith(fontSize: 11.5.sp),
                  ),
                  SizedBox(height: 7.h),
                  Text(
                    date,
                    style: AppTextStyles.small(color: AppColors.textMuted)
                        .copyWith(fontSize: 10.5.sp),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Icon(
              Iconsax.arrow_right_3,
              color: AppColors.textMuted,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (HireRequestStatuses.normalize(status)) {
      case HireRequestStatuses.completed:
      case HireRequestStatuses.approved:
        color = AppColors.success;
        break;
      case HireRequestStatuses.rejected:
      case HireRequestStatuses.cancelled:
        color = AppColors.danger;
        break;
      case HireRequestStatuses.proposalSent:
      case HireRequestStatuses.negotiation:
        color = AppColors.accentGold;
        break;
      default:
        color = AppColors.info;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        HireRequestStatuses.label(status),
        style: AppTextStyles.small(color: color)
            .copyWith(fontSize: 10.sp, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 70.h, horizontal: 24.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Iconsax.briefcase, size: 34.sp, color: AppColors.textMuted),
          SizedBox(height: 12.h),
          Text('No hire requests found.', style: AppTextStyles.h3()),
          SizedBox(height: 6.h),
          Text(
            'New project enquiries will appear here.',
            style: AppTextStyles.body(),
          ),
        ],
      ),
    );
  }
}
