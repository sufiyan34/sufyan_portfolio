import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/home_controller.dart';
import 'package:sufyan_portfolio/models/home_content_model.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final data = controller.content.value;
      final stats = controller.stats;
      final width = MediaQuery.of(context).size.width;
      final desktop = width >= 1100;
      final tablet = width >= 760 && width < 1100;

      return Container(
        color: AppColors.background,
        padding: EdgeInsets.fromLTRB(
          desktop ? 30.w : 18.w,
          desktop ? 8.h : 10.h,
          desktop ? 30.w : 18.w,
          desktop ? 40.h : 30.h,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1420.w),
            child: desktop
                ? _DesktopHero(data: data, stats: stats)
                : _StackedHero(data: data, stats: stats, tablet: tablet),
          ),
        ),
      );
    });
  }
}

class _DesktopHero extends StatelessWidget {
  final HomeContentModel data;
  final List<HomeStatModel> stats;

  const _DesktopHero({required this.data, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 570.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 51,
                child: Padding(
                  padding: EdgeInsets.only(left: 2.w, right: 24.w),
                  child: _HeroCopy(data: data, desktop: true),
                ),
              ),
              Expanded(
                flex: 49,
                child: _HeroVisual(imageUrl: data.heroImageUrl),
              ),
            ],
          ),
        ),
        SizedBox(height: 26.h),
        _HeroStats(stats: stats),
      ],
    );
  }
}

class _StackedHero extends StatelessWidget {
  final HomeContentModel data;
  final List<HomeStatModel> stats;
  final bool tablet;

  const _StackedHero({required this.data, required this.stats, required this.tablet});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroVisual(imageUrl: data.heroImageUrl),
        SizedBox(height: tablet ? 34.h : 28.h),
        _HeroCopy(data: data, desktop: false),
        SizedBox(height: tablet ? 30.h : 24.h),
        _HeroStats(stats: stats),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  final HomeContentModel data;
  final bool desktop;

  const _HeroCopy({required this.data, required this.desktop});

  @override
  Widget build(BuildContext context) {
    final align = desktop ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    final textAlign = desktop ? TextAlign.left : TextAlign.center;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: align,
      children: [
        Text(
          data.eyebrow.isEmpty ? "Hi, I'm" : data.eyebrow,
          textAlign: textAlign,
          style: AppTextStyles.bodyMedium(color: AppColors.textPrimary).copyWith(
            fontSize: desktop ? 17.sp : 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 350)),
        SizedBox(height: 3.h),
        _SplitHeadline(text: data.headline, desktop: desktop),
        SizedBox(height: 13.h),
        Text(
          data.subHeadline,
          textAlign: textAlign,
          style: AppTextStyles.bodyMedium(color: AppColors.textPrimary).copyWith(
            fontSize: desktop ? 17.sp : 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(delay: const Duration(milliseconds: 120), duration: const Duration(milliseconds: 400)),
        SizedBox(height: 15.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: desktop ? 520.w : 640.w),
          child: Text(
            data.description,
            textAlign: textAlign,
            style: AppTextStyles.body().copyWith(
              fontSize: desktop ? 13.6.sp : 13.5.sp,
              height: 1.65,
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 400)),
        ),
        SizedBox(height: 27.h),
        Wrap(
          alignment: desktop ? WrapAlignment.start : WrapAlignment.center,
          spacing: 12.w,
          runSpacing: 10.h,
          children: [
            _HeroButton(
              label: data.primaryButtonText.isEmpty ? 'Hire Me' : data.primaryButtonText,
              filled: true,
              onTap: () {
                final route = data.primaryButtonRoute.isEmpty ? AppRoutes.hireUs : data.primaryButtonRoute;
                Get.toNamed(route);
              },
            ),
            _HeroButton(
              label: data.secondaryButtonText.isEmpty ? 'View My Work' : data.secondaryButtonText,
              filled: false,
              onTap: () {
                final route = data.secondaryButtonRoute.isEmpty ? AppRoutes.projects : data.secondaryButtonRoute;
                Get.toNamed(route);
              },
              trailing: const Icon(Icons.north_east_rounded),
            ),
          ],
        ).animate().fadeIn(delay: const Duration(milliseconds: 280), duration: const Duration(milliseconds: 400)),
      ],
    );
  }
}

class _SplitHeadline extends StatelessWidget {
  final String text;
  final bool desktop;

  const _SplitHeadline({required this.text, required this.desktop});

  @override
  Widget build(BuildContext context) {
    final value = text.isEmpty ? 'Muhammad Sufyan' : text;
    final words = value.split(' ');
    final first = words.length > 1 ? words.sublist(0, words.length - 1).join(' ') : value;
    final last = words.length > 1 ? words.last : '';

    final style = (desktop ? AppTextStyles.display() : AppTextStyles.h1()).copyWith(
      fontSize: desktop ? 49.sp : 39.sp,
      letterSpacing: desktop ? -1.7 : -0.9,
      height: 1.03,
    );

    return RichText(
      textAlign: desktop ? TextAlign.left : TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(text: first, style: style.copyWith(color: AppColors.textPrimary)),
          if (last.isNotEmpty)
            TextSpan(
              text: ' $last',
              style: style.copyWith(color: AppColors.primary),
            ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 60), duration: const Duration(milliseconds: 450)).slideY(
      begin: 0.05,
      end: 0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }
}

class _HeroButton extends StatefulWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  final Widget? trailing;

  const _HeroButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.trailing,
  });

  @override
  State<_HeroButton> createState() => _HeroButtonState();
}

class _HeroButtonState extends State<_HeroButton> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final background = widget.filled ? AppColors.primary : AppColors.surface;
    final foreground = widget.filled ? AppColors.textOnPrimary : AppColors.textPrimary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: widget.filled ? AppColors.primary : AppColors.border),
            boxShadow: hovered ? AppColors.cardShadow : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.bodyMedium(color: foreground).copyWith(fontSize: 12.3.sp),
              ),
              if (widget.trailing != null) ...[
                SizedBox(width: 7.w),
                IconTheme(
                  data: IconThemeData(size: 14.sp, color: foreground),
                  child: widget.trailing!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  final String imageUrl;
  const _HeroVisual({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final desktop = width >= 1100;
    final imageHeight = desktop ? 505.h : (width >= 760 ? 460.h : 390.h);

    return SizedBox(
      height: imageHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: AppColors.featureShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const _HeroFallback(),
                        errorWidget: (_, __, ___) => const _HeroFallback(),
                      )
                    else
                      const _HeroFallback(),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Color(0x220D3B36),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -23.w,
            top: desktop ? 95.h : 74.h,
            child: _FloatingTechStack(),
          ),
          Positioned(
            right: desktop ? 20.w : 12.w,
            top: 14.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 7.w),
                  Text(
                    'Available for Opportunities',
                    style: AppTextStyles.small(color: AppColors.primary).copyWith(
                      fontSize: 9.4.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 550)).scale(
          begin: const Offset(0.975, 0.975),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutCubic,
        );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceSoft,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -80.w,
            bottom: -90.h,
            child: Container(
              width: 300.w,
              height: 300.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.person_outline_rounded,
              size: 110.sp,
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingTechStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      padding: EdgeInsets.symmetric(vertical: 9.h),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.featureShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _TechIcon(icon: Icons.flutter_dash, label: 'Flutter'),
          _TechDivider(),
          _TechIcon(icon: Icons.local_fire_department_rounded, label: 'Firebase'),
          _TechDivider(),
          _TechIcon(icon: Icons.api_rounded, label: 'API'),
          _TechDivider(),
          _TechIcon(icon: Icons.credit_card_rounded, label: 'Stripe'),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 400)).slideX(
      begin: -0.12,
      end: 0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }
}

class _TechDivider extends StatelessWidget {
  const _TechDivider();
  @override
  Widget build(BuildContext context) => SizedBox(height: 3.h);
}

class _TechIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TechIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Container(
        width: 36.w,
        height: 36.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 19.sp, color: AppColors.primary),
      ),
    );
  }
}

class _HeroStats extends StatelessWidget {
  final List<HomeStatModel> stats;
  const _HeroStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 760;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: desktop ? 18.h : 15.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runSpacing: 18.h,
        children: [
          for (final stat in stats.take(4))
            SizedBox(
              width: desktop ? 180.w : 135.w,
              child: Column(
                children: [
                  Text(
                    stat.value,
                    style: AppTextStyles.statNumber(color: AppColors.textPrimary).copyWith(
                      fontSize: desktop ? 23.sp : 20.sp,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    stat.label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.small(color: AppColors.textMuted).copyWith(
                      fontSize: 10.5.sp,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 400), duration: const Duration(milliseconds: 400));
  }
}
