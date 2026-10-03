import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/service_model.dart';
import 'package:sufyan_portfolio/widgets/service_icon.dart';

/// Card colour + a deliberately *different* border colour, picked from the
/// service category so a category always keeps the same look.
class _Palette {
  final Color background;
  final Color backgroundAlt;
  final Color border;
  final Color foreground;
  final Color secondary;
  final Color accent;
  final Color onAccent;

  const _Palette({
    required this.background,
    required this.backgroundAlt,
    required this.border,
    required this.foreground,
    required this.secondary,
    required this.accent,
    required this.onAccent,
  });

  static const _ink = Color(0xFF111413);

  static _Palette forKey(String key) {
    var sum = 0;
    for (final unit in key.trim().toLowerCase().codeUnits) {
      sum += unit;
    }
    switch (sum % 4) {
      case 0: // ivory card, black border
        return _Palette(
          background: const Color(0xFFFBFAF6),
          backgroundAlt: const Color(0xFFE9EAE6),
          border: _ink,
          foreground: AppColors.textPrimary,
          secondary: AppColors.textSecondary,
          accent: _ink,
          onAccent: Colors.white,
        );
      case 1: // green card, golden border
        return _Palette(
          background: AppColors.primary,
          backgroundAlt: AppColors.primaryDark,
          border: AppColors.accentGold,
          foreground: Colors.white,
          secondary: Colors.white.withValues(alpha: 0.74),
          accent: AppColors.accentGold,
          onAccent: AppColors.textPrimary,
        );
      case 2: // golden card, green border
        return _Palette(
          background: AppColors.accentGoldSoft,
          backgroundAlt: const Color(0xFFEBD28F),
          border: AppColors.primary,
          foreground: AppColors.textPrimary,
          secondary: AppColors.textPrimary.withValues(alpha: 0.72),
          accent: AppColors.primary,
          onAccent: Colors.white,
        );
      default: // black card, mint border
        return _Palette(
          background: _ink,
          backgroundAlt: const Color(0xFF1E2523),
          border: const Color(0xFF3FB68B),
          foreground: Colors.white,
          secondary: Colors.white.withValues(alpha: 0.72),
          accent: const Color(0xFF3FB68B),
          onAccent: _ink,
        );
    }
  }
}

class ServiceCard extends StatefulWidget {
  final ServiceModel service;

  /// Optional grid position, only used to stagger the entrance flip.
  final int index;

  const ServiceCard({super.key, required this.service, this.index = 0});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>
    with TickerProviderStateMixin {
  late final AnimationController _flip;
  late final AnimationController _entrance;
  late final AnimationController _shimmer;

  bool _hovered = false;
  bool _pinned = false; // flipped by tapping the button (touch devices)

  bool get _flipped => _hovered || _pinned;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    Future.delayed(Duration(milliseconds: 90 * (widget.index % 6)), () {
      if (mounted) _entrance.forward();
    });
  }

  @override
  void dispose() {
    _flip.dispose();
    _entrance.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  void _syncFlip() {
    if (_flipped) {
      _flip.forward();
    } else {
      _flip.reverse();
    }
  }

  void _setHover(bool value) {
    setState(() => _hovered = value);
    if (value) _shimmer.forward(from: 0);
    _syncFlip();
  }

  void _togglePinned() {
    setState(() => _pinned = !_pinned);
    _syncFlip();
  }

  // Top-left + bottom-right are the big corners.
  BorderRadius _radius(double border) => BorderRadius.only(
    topLeft: Radius.circular(math.max(0, 38.r - border)),
    bottomRight: Radius.circular(math.max(0, 38.r - border)),
    topRight: Radius.circular(math.max(0, 8.r - border)),
    bottomLeft: Radius.circular(math.max(0, 8.r - border)),
  );

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final palette = _Palette.forKey(service.category);

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -8 : 0, 0),
        child: AnimatedBuilder(
          animation: Listenable.merge([_flip, _entrance]),
          builder: (context, _) {
            final enter = Curves.easeOutBack.transform(_entrance.value);
            final enterAngle = (1 - enter) * (math.pi / 2.4);

            final flipAngle =
                Curves.easeInOutBack.transform(_flip.value) * math.pi;
            final showBack = flipAngle > math.pi / 2;
            final pop = 1 + 0.07 * math.sin(_flip.value * math.pi);

            final matrix = Matrix4.identity()
              ..setEntry(3, 2, 0.0011)
              ..rotateY(flipAngle + enterAngle)
              ..scale(pop, pop, 1.0);

            // The front face decides the card height; the back face is laid
            // over it (Positioned.fill) so both faces are always the same size.
            return Opacity(
              opacity: _entrance.value.clamp(0.0, 1.0),
              child: Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: Stack(
                  children: [
                    Visibility(
                      visible: !showBack,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: _shell(palette, child: _front(service, palette)),
                    ),
                    Positioned.fill(
                      child: Visibility(
                        visible: showBack,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: _shell(
                            palette,
                            child: _back(service, palette),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _shell(_Palette palette, {required Widget child}) {
    final borderWidth = 4.5.w;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(38.r),
          bottomRight: Radius.circular(38.r),
          topRight: Radius.circular(8.r),
          bottomLeft: Radius.circular(8.r),
        ),
        border: Border.all(color: palette.border, width: borderWidth),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.background, palette.backgroundAlt],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.border.withValues(alpha: _hovered ? 0.38 : 0.15),
            blurRadius: _hovered ? 32 : 18,
            offset: Offset(_hovered ? 8 : 5, _hovered ? 16 : 9),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _radius(borderWidth),
        child: Stack(
          children: [
            // Corner stripe in the small top-right corner.
            Positioned(
              top: -26.h,
              right: -26.w,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 90.w,
                    height: 52.h,
                    color: palette.accent.withValues(alpha: 0.18),
                  ),
                ),
              ),
            ),
            // Light sweep on hover.
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _shimmer,
                  builder: (context, _) {
                    final t = _shimmer.value;
                    if (t == 0 || t == 1) return const SizedBox.shrink();
                    final pos = -0.4 + t * 1.8;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.22),
                            Colors.white.withValues(alpha: 0),
                          ],
                          stops: [
                            (pos - 0.12).clamp(0.0, 1.0),
                            pos.clamp(0.0, 1.0),
                            (pos + 0.12).clamp(0.0, 1.0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 22.w, 22.h),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Front
  // ---------------------------------------------------------------------

  Widget _front(ServiceModel service, _Palette palette) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: palette.accent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.r),
                    bottomRight: Radius.circular(18.r),
                    topRight: Radius.circular(5.r),
                    bottomLeft: Radius.circular(5.r),
                  ),
                ),
                child: Icon(
                  ServiceIconBadge.resolve(service.icon),
                  color: palette.onAccent,
                  size: 24.sp,
                ),
              ),
              const Spacer(),
              if (service.featured)
                Container(
                  margin: EdgeInsets.only(right: 4.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 12.sp,
                        color: palette.onAccent,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Featured',
                        style: AppTextStyles.small(color: palette.onAccent)
                            .copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            service.category.toUpperCase(),
            style: AppTextStyles.overline(color: palette.accent)
                .copyWith(fontSize: 10.5.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 7.h),
          Text(
            service.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h3(color: palette.foreground),
          ),
          SizedBox(height: 7.h),
          Text(
            service.shortDescription,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(color: palette.secondary)
                .copyWith(fontSize: 13.5.sp, height: 1.6),
          ),
          SizedBox(height: 12.h),
          _Dashes(color: palette.foreground.withValues(alpha: 0.28)),
          SizedBox(height: 12.h),
          if (service.features.isNotEmpty)
            ...service.features
                .take(3)
                .map(
                  (feature) => Padding(
                    padding: EdgeInsets.only(bottom: 7.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 1.h),
                          width: 17.sp,
                          height: 17.sp,
                          decoration: BoxDecoration(
                            color: palette.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 12.sp,
                            color: palette.onAccent,
                          ),
                        ),
                        SizedBox(width: 9.w),
                        Expanded(
                          child: Text(
                            feature,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.small(
                              color: palette.foreground,
                            ).copyWith(height: 1.45, fontSize: 12.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          SizedBox(height: 6.h),
          if (service.technologies.isNotEmpty)
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: service.technologies
                  .take(4)
                  .map((tech) => _TechChip(label: tech, palette: palette))
                  .toList(),
            ),
          SizedBox(height: 14.h),
          Align(
            alignment: Alignment.centerRight,
            child: _FlipHint(
              palette: palette,
              icon: Icons.flip_rounded,
              label: 'Details',
              onTap: _togglePinned,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Back
  // ---------------------------------------------------------------------

  Widget _back(ServiceModel service, _Palette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              ServiceIconBadge.resolve(service.icon),
              color: palette.accent,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'WHAT YOU GET',
                style: AppTextStyles.overline(color: palette.accent)
                    .copyWith(fontSize: 10.5.sp, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          service.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.h3(color: palette.foreground),
        ),
        SizedBox(height: 10.h),
        _Dashes(color: palette.foreground.withValues(alpha: 0.28)),
        SizedBox(height: 10.h),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.description.isEmpty
                      ? service.shortDescription
                      : service.description,
                  style: AppTextStyles.body(color: palette.secondary)
                      .copyWith(fontSize: 13.sp, height: 1.6),
                ),
                if (service.features.length > 3) ...[
                  SizedBox(height: 12.h),
                  ...service.features
                      .skip(3)
                      .map(
                        (feature) => Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 15.sp,
                                color: palette.accent,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: AppTextStyles.small(
                                    color: palette.foreground,
                                  ).copyWith(height: 1.45, fontSize: 12.sp),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
                if (service.technologies.length > 4) ...[
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: service.technologies
                        .skip(4)
                        .map((tech) => _TechChip(label: tech, palette: palette))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_pinned && !_hovered) ...[
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: _FlipHint(
              palette: palette,
              icon: Icons.arrow_back_rounded,
              label: 'Back',
              onTap: _togglePinned,
            ),
          ),
        ],
      ],
    );
  }
}

class _FlipHint extends StatelessWidget {
  final _Palette palette;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FlipHint({
    required this.palette,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: palette.accent, width: 1.6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: palette.accent),
            SizedBox(width: 5.w),
            Text(
              label,
              style: AppTextStyles.small(color: palette.accent)
                  .copyWith(fontSize: 11.sp, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  final _Palette palette;

  const _TechChip({required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: palette.foreground.withValues(alpha: 0.08),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(11.r),
          bottomRight: Radius.circular(11.r),
          topRight: Radius.circular(3.r),
          bottomLeft: Radius.circular(3.r),
        ),
        border: Border.all(
          color: palette.accent.withValues(alpha: 0.65),
          width: 1.2,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.small(color: palette.foreground)
            .copyWith(fontSize: 11.sp, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Dashes extends StatelessWidget {
  final Color color;
  const _Dashes({required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dash = 6.0;
        const gap = 5.0;
        final count = (constraints.maxWidth / (dash + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(width: dash, height: 1.6, color: color),
          ),
        );
      },
    );
  }
}
