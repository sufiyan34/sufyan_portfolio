import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';

/// One nav item shown in [PublicNavbar] and the mobile drawer.
class _NavItem {
  final String label;
  final String route;

  const _NavItem(this.label, this.route);
}

const List<_NavItem> _kNavItems = [
  _NavItem('Home', AppRoutes.home),
  _NavItem('About', AppRoutes.about),
  _NavItem('Services', AppRoutes.services),
  _NavItem('Skills', AppRoutes.skills),
  _NavItem('Projects', AppRoutes.projects),
  _NavItem('Packages', AppRoutes.packages),
  _NavItem('Hire Me', AppRoutes.hireUs),
  _NavItem('Contact', AppRoutes.contactUs),
];

/// Public portfolio navigation bar.
///
/// Desktop:
/// - Minimal MS editorial logo
/// - Compact navigation
/// - Active item with small underline
/// - Rounded "Let's Talk" button
///
/// Tablet/mobile:
/// - Logo + hamburger
/// - Bottom-sheet navigation
class PublicNavbar extends StatelessWidget implements PreferredSizeWidget {
  final String activeRoute;
  final VoidCallback? onLetsTalk;

  const PublicNavbar({
    super.key,
    this.activeRoute = AppRoutes.home,
    this.onLetsTalk,
  });

  @override
  Size get preferredSize => Size.fromHeight(68.h);

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1000;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);

    return Container(
      height: preferredSize.height,
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28.w : 20.w),
          child: Row(
            children: [
              const _BrandMark(),

              const Spacer(),

              if (isDesktop) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final item in _kNavItems)
                      _NavLink(
                        label: item.label,
                        route: item.route,
                        active: item.route == activeRoute,
                      ),
                  ],
                ),

                SizedBox(width: 14.w),

                _LetsTalkButton(onTap: onLetsTalk),
              ] else
                _HamburgerButton(
                  activeRoute: activeRoute,
                  onLetsTalk: onLetsTalk,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimal "MS" editorial-style brand mark.
///
/// The reference uses a small plain monogram rather than
/// a rounded green square.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32.w,
      height: 32.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 6.h,
            child: Text(
              'M',
              style: AppTextStyles.bodyMedium(color: AppColors.textPrimary)
                  .copyWith(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: -0.8,
                  ),
            ),
          ),
          Positioned(
            left: 14.w,
            top: 1.h,
            child: Text(
              'S',
              style: AppTextStyles.bodyMedium(color: AppColors.textPrimary)
                  .copyWith(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final String route;
  final bool active;

  const _NavLink({
    required this.label,
    required this.route,
    required this.active,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.active || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          if (!widget.active) {
            Get.toNamed(widget.route);
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style:
                    AppTextStyles.bodyMedium(
                      color: highlighted
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ).copyWith(
                      fontSize: 10.5.sp,
                      fontWeight: widget.active
                          ? FontWeight.w600
                          : FontWeight.w500,
                      letterSpacing: -0.05,
                    ),
              ),

              SizedBox(height: 5.h),

              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: widget.active ? 14.w : 0,
                height: 1.5.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LetsTalkButton extends StatefulWidget {
  final VoidCallback? onTap;

  const _LetsTalkButton({this.onTap});

  @override
  State<_LetsTalkButton> createState() => _LetsTalkButtonState();
}

class _LetsTalkButtonState extends State<_LetsTalkButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap ?? () => Get.toNamed(AppRoutes.hireUs),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: 34.h,
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(999.r),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ]
                : null,
          ),
          child: Text(
            "Let's Talk",
            style: AppTextStyles.bodyMedium(color: AppColors.textOnPrimary)
                .copyWith(fontSize: 10.5.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _HamburgerButton extends StatelessWidget {
  final String activeRoute;
  final VoidCallback? onLetsTalk;

  const _HamburgerButton({required this.activeRoute, this.onLetsTalk});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Open menu',
      splashRadius: 22.r,
      icon: Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 24.sp),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.background,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          builder: (_) {
            return _MobileNavSheet(
              activeRoute: activeRoute,
              onLetsTalk: onLetsTalk,
            );
          },
        );
      },
    );
  }
}

class _MobileNavSheet extends StatelessWidget {
  final String activeRoute;
  final VoidCallback? onLetsTalk;

  const _MobileNavSheet({required this.activeRoute, this.onLetsTalk});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99.r),
                ),
              ),
            ),

            SizedBox(height: 14.h),

            for (final item in _kNavItems)
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                dense: true,
                visualDensity: const VisualDensity(vertical: -1),
                title: Text(
                  item.label,
                  style:
                      AppTextStyles.bodyMedium(
                        color: item.route == activeRoute
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ).copyWith(
                        fontSize: 14.sp,
                        fontWeight: item.route == activeRoute
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                ),
                trailing: item.route == activeRoute
                    ? Icon(
                        Icons.check_rounded,
                        size: 18.sp,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () {
                  Navigator.of(context).pop();

                  if (item.route != activeRoute) {
                    Get.toNamed(item.route);
                  }
                },
              ),

            SizedBox(height: 10.h),

            SizedBox(
              width: double.infinity,
              child: _LetsTalkButton(
                onTap: () {
                  Navigator.of(context).pop();

                  (onLetsTalk ?? () => Get.toNamed(AppRoutes.hireUs)).call();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
