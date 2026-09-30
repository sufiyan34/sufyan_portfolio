import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/services/firebase_auth_service.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  final String title;
  final String eyebrow;
  final Widget? trailing;
  final bool showBackButton;

  const AdminShell({
    super.key,
    required this.child,
    required this.title,
    this.eyebrow = 'Admin workspace',
    this.trailing,
    this.showBackButton = false,
  });

  bool _isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1100;

  @override
  Widget build(BuildContext context) {
    final desktop = _isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: desktop ? null : const Drawer(child: AdminSidebar()),
      body: SafeArea(
        child: Row(
          children: [
            if (desktop) const SizedBox(width: 264, child: AdminSidebar()),
            Expanded(
              child: Column(
                children: [
                  _AdminTopBar(
                    title: title,
                    eyebrow: eyebrow,
                    trailing: trailing,
                    showBackButton: showBackButton,
                    showMenu: !desktop,
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  static const _items = <_AdminNavItem>[
    _AdminNavItem('Dashboard', AppRoutes.adminDashboard, Iconsax.element_4),
    _AdminNavItem(
      'Site Information',
      AppRoutes.siteManagement,
      Iconsax.setting_2,
    ),
    _AdminNavItem('Projects', AppRoutes.projectManagement, Iconsax.grid_1),
    _AdminNavItem('Services', AppRoutes.serviceManagement, Iconsax.activity),
    _AdminNavItem('Skills', AppRoutes.skillManagement, Iconsax.flash_1),
    _AdminNavItem('Experience', AppRoutes.experienceManagement, Iconsax.timer),
    _AdminNavItem('Packages', AppRoutes.packageManagement, Iconsax.tag_2),
    _AdminNavItem(
      'Testimonials',
      AppRoutes.testimonialManagement,
      Iconsax.message_favorite,
    ),
    _AdminNavItem('Media', AppRoutes.mediaManagement, Iconsax.gallery),
  ];

  static const _requestItems = <_AdminNavItem>[
    _AdminNavItem(
      'Hire Requests',
      AppRoutes.hireRequestManagement,
      Iconsax.briefcase,
    ),
    _AdminNavItem(
      'Consultations',
      AppRoutes.consultationManagement,
      Iconsax.calendar,
    ),
    _AdminNavItem(
      'Contact Messages',
      AppRoutes.contactMessageManagement,
      Iconsax.sms,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.adminSidebar,
      child: Column(
        children: [
          SizedBox(height: 22.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    'MS',
                    style: AppTextStyles.bodyMedium(color: Colors.white)
                        .copyWith(fontSize: 14.sp, letterSpacing: 0.6),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sufyan Admin',
                        style: AppTextStyles.bodyMedium(color: Colors.white)
                            .copyWith(fontSize: 14.sp),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Portfolio control center',
                        style: AppTextStyles.small(
                          color: Colors.white.withValues(alpha: 0.55),
                        ).copyWith(fontSize: 10.5.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 26.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 16.h),
              children: [
                _sectionLabel('Main'),
                ..._items.map(_buildItem),
                SizedBox(height: 18.h),
                _sectionLabel('Requests'),
                ..._requestItems.map(_buildItem),
                SizedBox(height: 18.h),
                _sectionLabel('Account'),
                _buildItem(
                  const _AdminNavItem(
                    'Profile & Settings',
                    AppRoutes.adminProfile,
                    Iconsax.profile_2user,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 14.h),
            child: _SidebarLogout(),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 9.h),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.overline(
          color: Colors.white.withValues(alpha: 0.38),
        ).copyWith(fontSize: 9.5.sp, letterSpacing: 1.4),
      ),
    );
  }

  Widget _buildItem(_AdminNavItem item) {
    final active =
        Get.currentRoute == item.route ||
        (item.route != AppRoutes.adminDashboard &&
            Get.currentRoute.startsWith('${item.route}/'));

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          if (Get.currentRoute == item.route) return;
          Get.offAllNamed(item.route);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withValues(alpha: 0.11)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border: active
                ? Border.all(color: Colors.white.withValues(alpha: 0.05))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 18.sp,
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.58),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Text(
                  item.label,
                  style: AppTextStyles.bodyMedium(
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.67),
                  ).copyWith(fontSize: 12.5.sp),
                ),
              ),
              if (active)
                Container(
                  width: 5.w,
                  height: 5.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentGold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarLogout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () async {
        await FirebaseAuthService.instance.signOut();
        Get.offAllNamed(AppRoutes.login);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.logout_1,
              color: Colors.white.withValues(alpha: 0.72),
              size: 18.sp,
            ),
            SizedBox(width: 11.w),
            Text(
              'Sign out',
              style: AppTextStyles.bodyMedium(
                color: Colors.white.withValues(alpha: 0.72),
              ).copyWith(fontSize: 12.5.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  final String title;
  final String eyebrow;
  final Widget? trailing;
  final bool showBackButton;
  final bool showMenu;

  const _AdminTopBar({
    required this.title,
    required this.eyebrow,
    this.trailing,
    required this.showBackButton,
    required this.showMenu,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuthService.instance.currentUser;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Admin';

    return Container(
      height: 76.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (showMenu)
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(
                  Icons.menu_rounded,
                  size: 24.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          if (showBackButton) ...[
            IconButton(
              onPressed: Get.back,
              icon: Icon(
                Iconsax.arrow_left,
                size: 20.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: AppTextStyles.overline(color: AppColors.textMuted)
                      .copyWith(fontSize: 9.5.sp, letterSpacing: 1.2),
                ),
                SizedBox(height: 3.h),
                Text(
                  title,
                  style: AppTextStyles.h3().copyWith(fontSize: 18.sp),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 28.w,
                  height: 28.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _initials(name),
                    style: AppTextStyles.small(color: AppColors.primary)
                        .copyWith(fontSize: 10.sp),
                  ),
                ),
                if (MediaQuery.sizeOf(context).width >= 720) ...[
                  SizedBox(width: 8.w),
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium().copyWith(
                      fontSize: 11.5.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'AD';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _AdminNavItem {
  final String label;
  final String route;
  final IconData icon;
  const _AdminNavItem(this.label, this.route, this.icon);
}
