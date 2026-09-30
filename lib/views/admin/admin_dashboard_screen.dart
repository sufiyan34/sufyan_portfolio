import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/admin_dashboard_controller.dart';
import 'package:sufyan_portfolio/services/firebase_auth_service.dart';
import 'package:sufyan_portfolio/widgets/admin_auth_skeletons.dart';
import 'package:sufyan_portfolio/widgets/admin_shell.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AdminDashboardController>()
        ? Get.find<AdminDashboardController>()
        : Get.put(AdminDashboardController());

    return AdminShell(
      title: 'Dashboard',
      eyebrow: 'Overview',
      trailing: _HeaderAction(controller: controller),
      child: Obx(() {
        if (controller.isLoading.value && controller.metrics.isEmpty) {
          return const AdminDashboardSkeleton();
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.loadDashboard(refresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 44.h),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1500.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Greeting(controller: controller),
                    SizedBox(height: 28.h),
                    _MetricsGrid(controller: controller),
                    SizedBox(height: 26.h),
                    _DashboardLowerSection(controller: controller),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final AdminDashboardController controller;
  const _HeaderAction({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IconButton(
        tooltip: 'Refresh dashboard',
        onPressed: controller.isRefreshing.value
            ? null
            : () => controller.loadDashboard(refresh: true),
        icon: controller.isRefreshing.value
            ? SizedBox(
                width: 17.sp,
                height: 17.sp,
                child: const CircularProgressIndicator(strokeWidth: 1.8),
              )
            : Icon(Iconsax.refresh, size: 18.sp, color: AppColors.textSecondary),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  final AdminDashboardController controller;
  const _Greeting({required this.controller});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formatted = DateFormat('EEEE, d MMMM yyyy').format(now);
    final firstName = controller.displayName.trim().split(RegExp(r'\s+')).first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good ${_partOfDay(now.hour)}, $firstName',
          style: AppTextStyles.h1().copyWith(fontSize: 34.sp),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: .08, end: 0, curve: Curves.easeOutCubic),
        SizedBox(height: 7.h),
        Row(
          children: [
            Text(
              formatted,
              style: AppTextStyles.small(color: AppColors.textMuted).copyWith(fontSize: 11.5.sp),
            ),
            SizedBox(width: 9.w),
            Container(
              width: 4.w,
              height: 4.w,
              decoration: const BoxDecoration(
                color: AppColors.accentGold,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 9.w),
            Text(
              'Your portfolio control center',
              style: AppTextStyles.small(color: AppColors.textSecondary).copyWith(fontSize: 11.5.sp),
            ),
          ],
        ).animate(delay: 80.ms).fadeIn(duration: 450.ms),
      ],
    );
  }

  String _partOfDay(int hour) {
    if (hour < 12) return 'morning';
    if (hour < 18) return 'afternoon';
    return 'evening';
  }
}

class _MetricsGrid extends StatelessWidget {
  final AdminDashboardController controller;
  const _MetricsGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1500 ? 5 : width >= 1150 ? 4 : width >= 760 ? 3 : 2;
    final contentWidth = width - (width >= 1100 ? 264 : 0);
    final usable = contentWidth - (columns - 1) * 14.w;
    final cardWidth = columns == 1
        ? usable
        : (usable / columns).clamp(170.w, 340.w).toDouble();

    return Wrap(
      spacing: 14.w,
      runSpacing: 14.h,
      children: controller.metrics
          .take(width < 760 ? 6 : controller.metrics.length)
          .toList()
          .asMap()
          .entries
          .map(
            (entry) => SizedBox(
              width: cardWidth,
              child: _MetricCard(metric: entry.value, index: entry.key),
            ),
          )
          .toList(),
    );
  }
}

class _MetricCard extends StatefulWidget {
  final DashboardMetric metric;
  final int index;
  const _MetricCard({required this.metric, required this.index});

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final metric = widget.metric;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: () => Get.toNamed(metric.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: hovered ? AppColors.primary.withValues(alpha: 0.20) : AppColors.border,
            ),
            boxShadow: hovered ? AppColors.cardShadow : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    child: Icon(metric.icon, size: 18.sp, color: AppColors.primary),
                  ),
                  const Spacer(),
                  Icon(
                    Iconsax.arrow_up_1,
                    size: 14.sp,
                    color: AppColors.accentGold,
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              Text(
                '${metric.value}',
                style: AppTextStyles.statNumber().copyWith(fontSize: 28.sp),
              ),
              SizedBox(height: 5.h),
              Text(
                metric.label,
                style: AppTextStyles.bodyMedium().copyWith(fontSize: 12.sp),
              ),
              SizedBox(height: 3.h),
              Text(
                metric.subtitle,
                style: AppTextStyles.small().copyWith(fontSize: 10.5.sp),
              ),
            ],
          ),
        ),
      )
          .animate(delay: (80 * widget.index).ms)
          .fadeIn(duration: 350.ms)
          .slideY(begin: .06, end: 0, curve: Curves.easeOutCubic),
    );
  }
}

class _DashboardLowerSection extends StatelessWidget {
  final AdminDashboardController controller;
  const _DashboardLowerSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1050;

    final left = _ActivityPanel(controller: controller);
    final right = _QuickActionsPanel();

    if (!desktop) {
      return Column(
        children: [
          left,
          SizedBox(height: 18.h),
          right,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: left),
        SizedBox(width: 18.w),
        Expanded(flex: 4, child: right),
      ],
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  final AdminDashboardController controller;
  const _ActivityPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Recent Activity',
      subtitle: 'Latest changes and client-side activity',
      action: TextButton(
        onPressed: () => Get.toNamed(AppRoutes.hireRequestManagement),
        child: Text(
          'View requests',
          style: AppTextStyles.small(color: AppColors.primary).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 10.5.sp,
          ),
        ),
      ),
      child: Obx(() {
        if (controller.activities.isEmpty) {
          return _EmptyActivity();
        }

        return Column(
          children: controller.activities.asMap().entries.map((entry) {
            final activity = entry.value;
            return _ActivityRow(
              activity: activity,
              last: entry.key == controller.activities.length - 1,
            );
          }).toList(),
        );
      }),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final DashboardActivity activity;
  final bool last;
  const _ActivityRow({required this.activity, required this.last});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () => Get.toNamed(activity.route),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(activity.icon, color: AppColors.primary, size: 17.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium().copyWith(fontSize: 11.8.sp),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    activity.subtitle,
                    style: AppTextStyles.small().copyWith(fontSize: 10.sp),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              activity.timeLabel,
              style: AppTextStyles.small(color: AppColors.textMuted).copyWith(fontSize: 9.8.sp),
            ),
            if (!last) ...[
              SizedBox(height: 38.h),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 44.h),
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.activity, color: AppColors.primary, size: 22.sp),
          ),
          SizedBox(height: 13.h),
          Text('Nothing new yet', style: AppTextStyles.bodyMedium().copyWith(fontSize: 12.sp)),
          SizedBox(height: 4.h),
          Text(
            'Recent portfolio activity will appear here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.small().copyWith(fontSize: 10.5.sp),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const actions = [
      ('Add project', AppRoutes.projectManagement, Iconsax.add_square),
      ('Manage services', AppRoutes.serviceManagement, Iconsax.activity),
      ('Manage packages', AppRoutes.packageManagement, Iconsax.tag_2),
      ('Review contact inbox', AppRoutes.contactMessageManagement, Iconsax.sms),
    ];

    return _Panel(
      title: 'Quick Actions',
      subtitle: 'Jump directly to the areas you use most',
      child: Column(
        children: actions.asMap().entries.map((entry) {
          final action = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: entry.key == actions.length - 1 ? 0 : 10.h),
            child: _QuickActionTile(
              title: action.$1,
              route: action.$2,
              icon: action.$3,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickActionTile extends StatefulWidget {
  final String title;
  final String route;
  final IconData icon;
  const _QuickActionTile({required this.title, required this.route, required this.icon});

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: () => Get.toNamed(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: hover ? AppColors.surfaceSoft : AppColors.background,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(widget.icon, size: 17.sp, color: Colors.white),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Text(
                  widget.title,
                  style: AppTextStyles.bodyMedium().copyWith(fontSize: 11.5.sp),
                ),
              ),
              Icon(Iconsax.arrow_right_3, size: 16.sp, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;

  const _Panel({
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h3().copyWith(fontSize: 17.sp)),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.small().copyWith(fontSize: 10.5.sp),
                    ),
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          SizedBox(height: 17.h),
          child,
        ],
      ),
    );
  }
}
