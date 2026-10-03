import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_images.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';

// -----------------------------------------------------------------------------
// Sizing note
//
// The navbar uses plain logical pixels on purpose (no .w / .h / .sp).
// ScreenUtil is configured with a 1440x900 design size and `minTextAdapt`,
// which shrinks anything that uses it on phones — fine for page content, but it
// makes a navigation bar's tap targets and labels too small to use.
// -----------------------------------------------------------------------------

const double _kNavHeight = 72;
const double _kWideBreakpoint = 1120; // inline links + CTA
const double _kCompactBreakpoint = 720; // logo + menu button only

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

TextStyle _t(
  double size, {
  Color color = AppColors.textPrimary,
  FontWeight weight = FontWeight.w600,
  double? letterSpacing,
  double? height,
}) {
  return AppTextStyles.bodyMedium(color: color).copyWith(
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: height,
  );
}

/// Navigates unless we're already on that page. Compared against the real
/// current route (not `activeRoute`), so pages that borrow another page's
/// highlight — Consultation highlights "Packages" — can still link to it.
void _goTo(String route) {
  if (Get.currentRoute != route) Get.toNamed(route);
}

/// Public portfolio navigation bar. Drop-in replacement: same constructor,
/// still used as `Scaffold.appBar`.
///
/// - Wide (>= 1120): monogram + name, centred pill of links, "Let's Talk".
/// - Medium (720-1120): monogram + name, "Let's Talk", menu button.
/// - Compact (< 720): monogram (+ name when there's room) and menu button.
///
/// The menu opens as a slide-in panel with large, thumb-friendly rows.
class PublicNavbar extends StatelessWidget implements PreferredSizeWidget {
  final String activeRoute;
  final VoidCallback? onLetsTalk;

  const PublicNavbar({
    super.key,
    this.activeRoute = AppRoutes.home,
    this.onLetsTalk,
  });

  @override
  Size get preferredSize => const Size.fromHeight(_kNavHeight);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= _kWideBreakpoint;
    final compact = width < _kCompactBreakpoint;
    final showName = width >= 420;
    final horizontal = wide ? 40.0 : (compact ? 16.0 : 28.0);

    void letsTalk() => (onLetsTalk ?? () => _goTo(AppRoutes.hireUs)).call();

    return Material(
      color: AppColors.background,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        // The Scaffold adds the status-bar inset on top of preferredSize,
        // so SafeArea keeps the content centred on notched phones.
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: _kNavHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontal),
              child: Row(
                children: [
                  _Brand(showName: showName),
                  if (wide) ...[
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _LinkCapsule(activeRoute: activeRoute),
                        ),
                      ),
                    ),
                    _CtaButton(onTap: letsTalk),
                  ] else ...[
                    const Spacer(),
                    if (!compact) ...[
                      _CtaButton(onTap: letsTalk),
                      const SizedBox(width: 10),
                    ],
                    _MenuButton(
                      onTap: () => _openMenu(
                        context,
                        activeRoute: activeRoute,
                        onLetsTalk: letsTalk,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// BRAND
// =============================================================================

class _Brand extends StatelessWidget {
  final bool showName;

  const _Brand({required this.showName});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Muhammad Sufyan — home',
      child: InkWell(
        onTap: () => _goTo(AppRoutes.home),
        borderRadius: BorderRadius.circular(14),
        hoverColor: AppColors.primary.withValues(alpha: 0.04),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Monogram(),
              // Container(
              //   color: Colors.red,
              //   height: 300,
              //   child: Image.asset(AppImages.logo),
              // ),
              if (showName) ...[
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Muhammad Sufyan',
                      style: _t(
                        14.5,
                        weight: FontWeight.w800,
                        letterSpacing: -0.2,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Flutter Developer',
                      style: _t(
                        11,
                        color: AppColors.textMuted,
                        weight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Editorial "MS" mark — a large M with a small raised S and a gold full stop.
class _Monogram extends StatelessWidget {
  const _Monogram();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 5,
            child: Text(
              'M',
              style: _t(
                25,
                weight: FontWeight.w800,
                letterSpacing: -1,
                height: 1,
              ),
            ),
          ),
          Positioned(
            left: 21,
            top: 2,
            child: Text(
              'S',
              style: _t(
                13,
                color: AppColors.primary,
                weight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          Positioned(
            left: 31,
            top: 26,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.accentGold,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DESKTOP LINKS
// =============================================================================

class _LinkCapsule extends StatelessWidget {
  final String activeRoute;

  const _LinkCapsule({required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // Transparent Material so the links' focus/hover ink draws over the pill.
      child: Material(
        type: MaterialType.transparency,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in _kNavItems)
              _NavLink(item: item, active: item.route == activeRoute),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final _NavItem item;
  final bool active;

  const _NavLink({required this.item, required this.active});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;

    return Semantics(
      button: true,
      selected: active,
      label: widget.item.label,
      child: InkWell(
        onTap: () => _goTo(widget.item.route),
        onHover: (value) => setState(() => _hovered = value),
        borderRadius: BorderRadius.circular(999),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: AppColors.primary.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primarySoft
                : (_hovered ? AppColors.surfaceSoft : Colors.transparent),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            widget.item.label,
            style: _t(
              13,
              color: active
                  ? AppColors.primary
                  : (_hovered
                        ? AppColors.textPrimary
                        : AppColors.textSecondary),
              weight: active ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// CTA + MENU BUTTON
// =============================================================================

class _CtaButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool expanded;

  const _CtaButton({required this.onTap, this.expanded = false});

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      "Let's Talk",
      style: _t(13.5, color: AppColors.textOnPrimary, weight: FontWeight.w700),
    );

    final arrow = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.accentGold,
        shape: BoxShape.circle,
        boxShadow: _hovered
            ? [
                BoxShadow(
                  color: AppColors.accentGold.withValues(alpha: 0.45),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: AnimatedRotation(
        turns: _hovered ? 0.0 : -0.02,
        duration: const Duration(milliseconds: 180),
        child: const Icon(
          Icons.arrow_outward_rounded,
          size: 17,
          color: AppColors.primaryDark,
        ),
      ),
    );

    return Semantics(
      button: true,
      label: "Let's Talk",
      child: InkWell(
        onTap: widget.onTap,
        onHover: (value) => setState(() => _hovered = value),
        borderRadius: BorderRadius.circular(999),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 46,
          padding: const EdgeInsets.fromLTRB(22, 0, 7, 0),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.primaryDark : AppColors.primary,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: _hovered ? 0.22 : 0.10,
                ),
                blurRadius: _hovered ? 16 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: widget.expanded
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            children: [
              label,
              if (!widget.expanded) const SizedBox(width: 14),
              arrow,
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MenuButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Open menu',
      child: Semantics(
        button: true,
        label: 'Open menu',
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.menu_rounded,
              size: 22,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MOBILE / TABLET MENU PANEL
// =============================================================================

void _openMenu(
  BuildContext context, {
  required String activeRoute,
  required VoidCallback onLetsTalk,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close menu',
    barrierColor: AppColors.primaryDark.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (dialogContext, _, __) =>
        _MenuPanel(activeRoute: activeRoute, onLetsTalk: onLetsTalk),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

class _MenuPanel extends StatelessWidget {
  final String activeRoute;
  final VoidCallback onLetsTalk;

  const _MenuPanel({required this.activeRoute, required this.onLetsTalk});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = math.min(400.0, screenWidth * 0.92);

    void close() => Navigator.of(context).pop();

    return Align(
      alignment: Alignment.centerRight,
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(28)),
        child: Material(
          color: AppColors.background,
          child: SizedBox(
            width: panelWidth,
            height: double.infinity,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 14, 6),
                    child: Row(
                      children: [
                        const _Monogram(),
                        //Image.asset(AppImages.logo),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Muhammad Sufyan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(
                              15,
                              weight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Tooltip(
                          message: 'Close menu',
                          child: InkWell(
                            onTap: close,
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 22,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
                          child: Text(
                            'MENU',
                            style: _t(
                              11,
                              color: AppColors.textMuted,
                              weight: FontWeight.w700,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ),
                        for (var i = 0; i < _kNavItems.length; i++)
                          _MenuRow(
                                index: i + 1,
                                item: _kNavItems[i],
                                active: _kNavItems[i].route == activeRoute,
                                onTap: () {
                                  close();
                                  _goTo(_kNavItems[i].route);
                                },
                              )
                              .animate()
                              .fadeIn(delay: (70 + i * 45).ms, duration: 280.ms)
                              .slideX(
                                begin: 0.08,
                                end: 0,
                                delay: (70 + i * 45).ms,
                                duration: 280.ms,
                                curve: Curves.easeOutCubic,
                              ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      children: [
                        _CtaButton(
                          expanded: true,
                          onTap: () {
                            close();
                            onLetsTalk();
                          },
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton(
                            onPressed: () {
                              close();
                              _goTo(AppRoutes.consultation);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.border),
                              backgroundColor: AppColors.surface,
                              shape: const StadiumBorder(),
                              textStyle: _t(13.5, weight: FontWeight.w700),
                            ),
                            child: const Text('Book a Consultation'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final int index;
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  const _MenuRow({
    required this.index,
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Semantics(
        button: true,
        selected: active,
        label: item.label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              color: active ? AppColors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: _t(
                      12,
                      color: active
                          ? AppColors.accentGold
                          : AppColors.textMuted,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.label,
                    style: _t(
                      20,
                      color: active ? AppColors.primary : AppColors.textPrimary,
                      weight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (active)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accentGold,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
