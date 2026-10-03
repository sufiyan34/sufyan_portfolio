import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/package_model.dart';

/// Per-tier palette: the card colour and the border colour are intentionally
/// different so every tier reads as its own object.
///
///  Silver   -> ivory card   + black border
///  Gold     -> golden card  + deep green border
///  Platinum -> green card   + golden border
///  Custom   -> black card   + mint-green border
class _Tier {
  final Color background;
  final Color backgroundAlt; // second stop of the card gradient
  final Color border;
  final Color foreground;
  final Color secondary;
  final Color accent; // icons, chips, ticks, CTA
  final Color onAccent;
  final IconData icon;
  final String mark;

  const _Tier({
    required this.background,
    required this.backgroundAlt,
    required this.border,
    required this.foreground,
    required this.secondary,
    required this.accent,
    required this.onAccent,
    required this.icon,
    required this.mark,
  });

  static const _ink = Color(0xFF111413);

  static _Tier of(String type) {
    switch (PackageTypes.normalize(type)) {
      case PackageTypes.gold:
        return _Tier(
          background: AppColors.accentGoldSoft,
          backgroundAlt: const Color(0xFFEBD28F),
          border: AppColors.primary,
          foreground: AppColors.textPrimary,
          secondary: AppColors.textPrimary.withValues(alpha: 0.72),
          accent: AppColors.primary,
          onAccent: Colors.white,
          icon: Icons.star_rounded,
          mark: 'G',
        );
      case PackageTypes.platinum:
        return _Tier(
          background: AppColors.primary,
          backgroundAlt: AppColors.primaryDark,
          border: AppColors.accentGold,
          foreground: AppColors.textOnPrimary,
          secondary: AppColors.textOnPrimary.withValues(alpha: 0.74),
          accent: AppColors.accentGold,
          onAccent: AppColors.textPrimary,
          icon: Icons.diamond_rounded,
          mark: 'P',
        );
      case PackageTypes.custom:
        return _Tier(
          background: _ink,
          backgroundAlt: const Color(0xFF1E2523),
          border: const Color(0xFF3FB68B),
          foreground: Colors.white,
          secondary: Colors.white.withValues(alpha: 0.72),
          accent: const Color(0xFF3FB68B),
          onAccent: _ink,
          icon: Icons.tune_rounded,
          mark: 'C',
        );
      case PackageTypes.silver:
      default:
        return _Tier(
          background: const Color(0xFFFBFAF6),
          backgroundAlt: const Color(0xFFE9EAE6),
          border: _ink,
          foreground: AppColors.textPrimary,
          secondary: AppColors.textSecondary,
          accent: _ink,
          onAccent: Colors.white,
          icon: Icons.workspace_premium_rounded,
          mark: 'S',
        );
    }
  }
}

class PackageCard extends StatefulWidget {
  final PackageModel package;

  /// Optional position in a grid; only used to stagger the entrance flip.
  final int index;

  const PackageCard({super.key, required this.package, this.index = 0});

  @override
  State<PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<PackageCard>
    with TickerProviderStateMixin {
  late final AnimationController _flip;
  late final AnimationController _entrance;
  late final AnimationController _shimmer;

  bool _hovered = false;
  bool _pinned = false; // flipped by tapping the button (touch devices)

  bool get _flipped => _hovered || _pinned;

  void _syncFlip() {
    if (_flipped) {
      _flip.forward();
    } else {
      _flip.reverse();
    }
  }

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
      duration: const Duration(milliseconds: 1500),
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

  void _setHover(bool value) {
    setState(() => _hovered = value);
    if (value) _shimmer.forward(from: 0);
    _syncFlip();
  }

  void _togglePinned() {
    setState(() => _pinned = !_pinned);
    _syncFlip();
  }

  void _choosePackage() {
    final package = widget.package;
    Get.toNamed(
      // The id is also in the URL so the selection survives a page refresh.
      '${AppRoutes.hireUs}?packageId=${Uri.encodeComponent(package.id)}',
      arguments: {
        'packageId': package.id,
        'packageTitle': package.title,
        'packageType': package.type,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tier = _Tier.of(widget.package.type);

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
            // Entrance: card swings in on the Y axis.
            final enter = Curves.easeOutBack.transform(_entrance.value);
            final enterAngle = (1 - enter) * (math.pi / 2.4);

            // Click flip: front <-> back.
            final flipT = Curves.easeInOutBack.transform(_flip.value);
            final flipAngle = flipT * math.pi;
            final isBack = flipAngle > math.pi / 2;

            // Card lifts toward the viewer at the midpoint of the flip.
            final pop = 1 + 0.07 * math.sin(_flip.value * math.pi);

            final matrix = Matrix4.identity()
              ..setEntry(3, 2, 0.0011)
              ..rotateY(flipAngle + enterAngle)
              ..scale(pop, pop, 1.0);

            return Opacity(
              opacity: _entrance.value.clamp(0.0, 1.0),
              child: Transform(
                alignment: Alignment.center,
                transform: matrix,
                child: isBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: _buildBack(tier),
                      )
                    : _buildFront(tier),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Shared shell: diagonal corners, thick coloured border, shimmer, mark
  // ---------------------------------------------------------------------

  BorderRadius get _radius => BorderRadius.only(
    topLeft: Radius.circular(42.r),
    bottomRight: Radius.circular(42.r),
    topRight: Radius.circular(8.r),
    bottomLeft: Radius.circular(8.r),
  );

  Widget _shell(_Tier tier, {required Widget child}) {
    final borderWidth = 4.5.w;
    return Container(
      decoration: BoxDecoration(
        borderRadius: _radius,
        border: Border.all(color: tier.border, width: borderWidth),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tier.background, tier.backgroundAlt],
        ),
        boxShadow: [
          BoxShadow(
            color: tier.border.withValues(alpha: _hovered ? 0.38 : 0.16),
            blurRadius: _hovered ? 34 : 20,
            offset: Offset(_hovered ? 8 : 5, _hovered ? 16 : 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(math.max(0, 42.r - borderWidth)),
          bottomRight: Radius.circular(math.max(0, 42.r - borderWidth)),
          topRight: Radius.circular(math.max(0, 8.r - borderWidth)),
          bottomLeft: Radius.circular(math.max(0, 8.r - borderWidth)),
        ),
        child: Stack(
          children: [
            // Giant faint tier letter as a watermark.
            Positioned(
              right: 6.w,
              bottom: 30.h,
              child: IgnorePointer(
                child: Text(
                  tier.mark,
                  style: TextStyle(
                    fontSize: 150.sp,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: tier.foreground.withValues(alpha: 0.055),
                  ),
                ),
              ),
            ),
            // Diagonal accent stripe in the small top-right corner.
            Positioned(
              top: -26.h,
              right: -26.w,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 90.w,
                    height: 52.h,
                    color: tier.accent.withValues(alpha: 0.18),
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
              padding: EdgeInsets.fromLTRB(26.w, 26.h, 24.w, 24.h),
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

  Widget _buildFront(_Tier tier) {
    final package = widget.package;
    final type = PackageTypes.normalize(package.type);
    final isCustom = type == PackageTypes.custom;

    return _shell(
      tier,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: tier.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(tier.icon, color: tier.onAccent, size: 21.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PackageTypes.label(type).toUpperCase(),
                      style: AppTextStyles.overline(color: tier.accent)
                          .copyWith(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      PackageTypes.descriptor(type),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.small(color: tier.secondary)
                          .copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5.sp,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  package.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3(color: tier.foreground),
                ),
              ),
              if (package.featured) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: tier.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 12.sp,
                        color: tier.onAccent,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Popular',
                        style: AppTextStyles.small(color: tier.onAccent)
                            .copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isCustom && package.price <= 0)
                Text(
                  'Custom quote',
                  style: AppTextStyles.h3(color: tier.foreground)
                      .copyWith(fontSize: 22.sp),
                )
              else ...[
                Text(
                  _formatPrice(package.price),
                  style: AppTextStyles.h2(color: tier.foreground)
                      .copyWith(fontSize: 34.sp),
                ),
                SizedBox(width: 7.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 5.h),
                  child: Text(
                    package.currency.toUpperCase(),
                    style: AppTextStyles.small(
                      color: tier.secondary,
                    ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            package.pricingNote,
            style: AppTextStyles.small(color: tier.secondary),
          ),
          SizedBox(height: 14.h),
          _DashedDivider(color: tier.foreground.withValues(alpha: 0.28)),
          SizedBox(height: 14.h),
          Text(
            package.shortDescription,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(color: tier.secondary)
                .copyWith(fontSize: 13.2.sp),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _MetaChip(
                  icon: Icons.schedule_rounded,
                  label: package.deliveryDays <= 0
                      ? 'Timeline TBD'
                      : '${package.deliveryDays} days',
                  tier: tier,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _MetaChip(
                  icon: Icons.refresh_rounded,
                  label: package.revisions <= 0
                      ? 'Scope TBD'
                      : '${package.revisions} revisions',
                  tier: tier,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (package.features.isNotEmpty) ...[
            ...package.features
                .take(4)
                .map(
                  (feature) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 1.h),
                          width: 17.sp,
                          height: 17.sp,
                          decoration: BoxDecoration(
                            color: tier.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 12.sp,
                            color: tier.onAccent,
                          ),
                        ),
                        SizedBox(width: 9.w),
                        Expanded(
                          child: Text(
                            feature,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.small(color: tier.secondary)
                                .copyWith(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
          const Spacer(),
          SizedBox(height: 8.h),
          Row(
            children: [
              _FlipButton(
                tier: tier,
                icon: Icons.flip_rounded,
                tooltip: 'See details',
                onTap: _togglePinned,
              ),
              SizedBox(width: 10.w),
              Expanded(child: _cta(tier, package)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Back
  // ---------------------------------------------------------------------

  Widget _buildBack(_Tier tier) {
    final package = widget.package;
    final type = PackageTypes.normalize(package.type);

    return _shell(
      tier,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(tier.icon, color: tier.accent, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '${PackageTypes.label(type).toUpperCase()} · DETAILS',
                  style: AppTextStyles.overline(color: tier.accent)
                      .copyWith(fontSize: 10.5.sp, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            package.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h3(color: tier.foreground),
          ),
          SizedBox(height: 12.h),
          _DashedDivider(color: tier.foreground.withValues(alpha: 0.28)),
          SizedBox(height: 12.h),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.description.isEmpty
                        ? package.shortDescription
                        : package.description,
                    style: AppTextStyles.body(color: tier.secondary)
                        .copyWith(fontSize: 13.sp, height: 1.6),
                  ),
                  if (package.features.length > 4) ...[
                    SizedBox(height: 14.h),
                    Text(
                      'Also included',
                      style: AppTextStyles.bodyMedium(color: tier.foreground)
                          .copyWith(fontSize: 13.sp),
                    ),
                    SizedBox(height: 8.h),
                    ...package.features
                        .skip(4)
                        .map(
                          (feature) => Padding(
                            padding: EdgeInsets.only(bottom: 7.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 15.sp,
                                  color: tier.accent,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: AppTextStyles.small(
                                      color: tier.secondary,
                                    ).copyWith(height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                  if (package.technologies.isNotEmpty) ...[
                    SizedBox(height: 14.h),
                    Text(
                      'Tech stack',
                      style: AppTextStyles.bodyMedium(color: tier.foreground)
                          .copyWith(fontSize: 13.sp),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: package.technologies
                          .map(
                            (t) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: tier.accent.withValues(alpha: 0.7),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                t,
                                style:
                                    AppTextStyles.small(color: tier.foreground)
                                        .copyWith(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              if (_pinned && !_hovered) ...[
                _FlipButton(
                  tier: tier,
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Back',
                  onTap: _togglePinned,
                ),
                SizedBox(width: 10.w),
              ],
              Expanded(child: _cta(tier, package)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cta(_Tier tier, PackageModel package) {
    return SizedBox(
      height: 46.h,
      child: ElevatedButton(
        onPressed: _choosePackage,
        style: ElevatedButton.styleFrom(
          backgroundColor: tier.accent,
          foregroundColor: tier.onAccent,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
              topRight: Radius.circular(5.r),
              bottomLeft: Radius.circular(5.r),
            ),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            package.ctaLabel.isEmpty ? 'Choose Package' : package.ctaLabel,
            style: AppTextStyles.bodyMedium(color: tier.onAccent)
                .copyWith(fontSize: 13.2.sp, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  String _formatPrice(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}

class _FlipButton extends StatelessWidget {
  final _Tier tier;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _FlipButton({
    required this.tier,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 46.h,
          height: 46.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: tier.accent, width: 2),
          ),
          child: Icon(icon, size: 20.sp, color: tier.accent),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final _Tier tier;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: tier.foreground.withValues(alpha: 0.08),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
          topRight: Radius.circular(3.r),
          bottomLeft: Radius.circular(3.r),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15.sp, color: tier.accent),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.small(color: tier.foreground)
                  .copyWith(fontSize: 11.5.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  final Color color;
  const _DashedDivider({required this.color});

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
