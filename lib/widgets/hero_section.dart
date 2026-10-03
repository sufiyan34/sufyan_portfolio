import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/home_controller.dart';
import 'package:sufyan_portfolio/models/home_content_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Brand colours used for the floating technology icons.
const Color _flutterBlue = Color(0xFF027DFD);
const Color _firebaseOrange = Color(0xFFFFA000);
const Color _apiTeal = Color(0xFF00A88F);
const Color _stripePurple = Color(0xFF635BFF);
const Color _githubInk = Color(0xFF24292F);
const Color _ink = Color(0xFF111413);

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
        child: Stack(
          children: [
            const Positioned.fill(child: _HeroBackdrop()),
            Container(
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
            ),
          ],
        ),
      );
    });
  }
}

// ===========================================================================
// Backdrop — dot grid, soft colour blobs, slow rotating ring
// ===========================================================================

class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),
            Positioned(
              right: -120.w,
              top: -120.h,
              child: _blob(AppColors.accentGold.withValues(alpha: 0.20), 420.w),
            ),
            Positioned(
              left: -140.w,
              bottom: -160.h,
              child: _blob(AppColors.primary.withValues(alpha: 0.10), 460.w),
            ),
            Positioned(
              right: 60.w,
              bottom: 40.h,
              child:
                  SizedBox(
                        width: 260.w,
                        height: 260.w,
                        child: CustomPaint(
                          painter: _DashedRingPainter(
                            AppColors.primary.withValues(alpha: 0.16),
                          ),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .rotate(duration: Duration(seconds: 40)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
    ),
  );
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary.withValues(alpha: 0.07);
    const step = 28.0;
    for (double x = step / 2; x < size.width; x += step) {
      for (double y = step / 2; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedRingPainter extends CustomPainter {
  final Color color;
  const _DashedRingPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rect = Offset.zero & size;
    const dashes = 48;
    for (var i = 0; i < dashes; i++) {
      final start = (i / dashes) * 2 * math.pi;
      canvas.drawArc(
        rect.deflate(1),
        start,
        (2 * math.pi / dashes) * 0.55,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter old) => old.color != color;
}

// ===========================================================================
// Layouts
// ===========================================================================

class _DesktopHero extends StatelessWidget {
  final HomeContentModel data;
  final List<HomeStatModel> stats;

  const _DesktopHero({required this.data, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 640.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 52,
                child: Padding(
                  padding: EdgeInsets.only(left: 2.w, right: 30.w),
                  child: _HeroCopy(data: data, desktop: true),
                ),
              ),
              Expanded(
                flex: 48,
                child: _HeroVisual(imageUrl: data.heroImageUrl, stats: stats),
              ),
            ],
          ),
        ),
        SizedBox(height: 28.h),
        _HeroStats(stats: stats),
      ],
    );
  }
}

class _StackedHero extends StatelessWidget {
  final HomeContentModel data;
  final List<HomeStatModel> stats;
  final bool tablet;

  const _StackedHero({
    required this.data,
    required this.stats,
    required this.tablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroVisual(imageUrl: data.heroImageUrl, stats: stats),
        SizedBox(height: tablet ? 40.h : 34.h),
        _HeroCopy(data: data, desktop: false),
        SizedBox(height: tablet ? 32.h : 26.h),
        _HeroStats(stats: stats),
      ],
    );
  }
}

// ===========================================================================
// Copy
// ===========================================================================

class _HeroCopy extends StatelessWidget {
  final HomeContentModel data;
  final bool desktop;

  const _HeroCopy({required this.data, required this.desktop});

  @override
  Widget build(BuildContext context) {
    final align = desktop
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    final textAlign = desktop ? TextAlign.left : TextAlign.center;
    final wrapAlign = desktop ? WrapAlignment.start : WrapAlignment.center;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: align,
      children: [
        // Availability pill with a pulsing dot.
        Container(
              padding: EdgeInsets.fromLTRB(10.w, 7.h, 14.w, 7.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  width: 1.4,
                ),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                        width: 9.w,
                        height: 9.w,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(begin: 0.8, end: 1.3, duration: 900.ms),
                  SizedBox(width: 8.w),
                  Text(
                    'Open for freelance & full-time roles',
                    style: AppTextStyles.small(color: AppColors.primary)
                        .copyWith(fontSize: 11.sp, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: 350.ms)
            .slideY(begin: -0.3, end: 0, curve: Curves.easeOutBack),
        SizedBox(height: 20.h),

        // Greeting with a waving hand.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              data.eyebrow.isEmpty ? "Hi, I'm" : data.eyebrow,
              style: AppTextStyles.bodyMedium(color: AppColors.textPrimary)
                  .copyWith(
                    fontSize: desktop ? 19.sp : 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(width: 8.w),
            Icon(
                  Icons.waving_hand_rounded,
                  size: desktop ? 22.sp : 18.sp,
                  color: AppColors.accentGold,
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .rotate(
                  begin: -0.04,
                  end: 0.06,
                  duration: 700.ms,
                  alignment: Alignment.bottomRight,
                ),
          ],
        ).animate().fadeIn(delay: 80.ms, duration: 350.ms),
        SizedBox(height: 4.h),

        _SplitHeadline(text: data.headline, desktop: desktop),
        SizedBox(height: 14.h),

        // Role line with an accent bar.
        Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4.w,
                  height: desktop ? 24.h : 20.h,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: 10.w),
                Flexible(
                  child: Text(
                    data.subHeadline,
                    textAlign: textAlign,
                    style:
                        AppTextStyles.bodyMedium(color: AppColors.textPrimary)
                            .copyWith(
                              fontSize: desktop ? 19.sp : 16.sp,
                              fontWeight: FontWeight.w800,
                            ),
                  ),
                ),
              ],
            )
            .animate()
            .fadeIn(delay: 180.ms, duration: 400.ms)
            .slideX(begin: -0.05, end: 0),
        SizedBox(height: 16.h),

        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: desktop ? 560.w : 640.w),
          child: Text(
            data.description,
            textAlign: textAlign,
            style: AppTextStyles.body().copyWith(
              fontSize: desktop ? 14.6.sp : 14.sp,
              height: 1.7,
            ),
          ),
        ).animate().fadeIn(delay: 260.ms, duration: 400.ms),
        SizedBox(height: 18.h),

        // Skill chips.
        Wrap(
          alignment: wrapAlign,
          spacing: 8.w,
          runSpacing: 8.h,
          children: const [
            _SkillChip(label: 'Flutter', color: _flutterBlue),
            _SkillChip(label: 'Firebase', color: _firebaseOrange),
            _SkillChip(label: 'REST APIs', color: _apiTeal),
            _SkillChip(label: 'GetX', color: AppColors.primary),
            _SkillChip(label: 'Clean Architecture', color: _stripePurple),
          ],
        ).animate().fadeIn(delay: 340.ms, duration: 400.ms),
        SizedBox(height: 26.h),

        Wrap(
          alignment: wrapAlign,
          spacing: 12.w,
          runSpacing: 10.h,
          children: [
            _HeroButton(
              label: data.primaryButtonText.isEmpty
                  ? 'Hire Me'
                  : data.primaryButtonText,
              filled: true,
              onTap: () {
                final route = data.primaryButtonRoute.isEmpty
                    ? AppRoutes.hireUs
                    : data.primaryButtonRoute;
                Get.toNamed(route);
              },
              trailing: const Icon(Icons.arrow_forward_rounded),
            ),
            _HeroButton(
              label: data.secondaryButtonText.isEmpty
                  ? 'View My Work'
                  : data.secondaryButtonText,
              filled: false,
              onTap: () {
                final route = data.secondaryButtonRoute.isEmpty
                    ? AppRoutes.projects
                    : data.secondaryButtonRoute;
                Get.toNamed(route);
              },
              trailing: const Icon(Icons.north_east_rounded),
            ),
          ],
        ).animate().fadeIn(delay: 420.ms, duration: 400.ms),
        SizedBox(height: 22.h),

        // Quick facts.
        Wrap(
          alignment: wrapAlign,
          spacing: 20.w,
          runSpacing: 8.h,
          children: const [
            _Fact(icon: Icons.location_on_rounded, label: 'Lahore, Pakistan'),
            _Fact(icon: Icons.public_rounded, label: 'Remote-friendly'),
            _Fact(icon: Icons.bolt_rounded, label: 'Fast replies'),
          ],
        ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final Color color;
  const _SkillChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.75), width: 1.5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14.r),
          bottomRight: Radius.circular(14.r),
          topRight: Radius.circular(4.r),
          bottomLeft: Radius.circular(4.r),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 7.w),
          Text(
            label,
            style: AppTextStyles.small(color: AppColors.textPrimary)
                .copyWith(fontSize: 11.5.sp, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Fact({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15.sp, color: AppColors.accentGold),
        SizedBox(width: 6.w),
        Text(
          label,
          style: AppTextStyles.small(color: AppColors.textSecondary)
              .copyWith(fontSize: 11.8.sp, fontWeight: FontWeight.w700),
        ),
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
    final first = words.length > 1
        ? words.sublist(0, words.length - 1).join(' ')
        : value;
    final last = words.length > 1 ? words.last : '';

    final style = (desktop ? AppTextStyles.display() : AppTextStyles.h1())
        .copyWith(
          fontSize: desktop ? 60.sp : 42.sp,
          letterSpacing: desktop ? -2.0 : -1.0,
          height: 1.04,
        );

    return Wrap(
          alignment: desktop ? WrapAlignment.start : WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(
              '$first ',
              style: style.copyWith(color: AppColors.textPrimary),
            ),
            if (last.isNotEmpty)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Gradient surname.
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (rect) => const LinearGradient(
                      colors: [
                        AppColors.primary,
                        Color(0xFF2F7D59),
                        AppColors.accentGold,
                      ],
                    ).createShader(rect),
                    child: Text(
                      last,
                      style: style.copyWith(color: Colors.white),
                    ),
                  ),
                  // Hand-drawn style gold underline that draws itself.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -6.h,
                    child:
                        Container(
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.r),
                              bottomRight: Radius.circular(8.r),
                            ),
                          ),
                        ).animate().scaleX(
                          begin: 0,
                          end: 1,
                          alignment: Alignment.centerLeft,
                          delay: 650.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                ],
              ),
          ],
        )
        .animate()
        .fadeIn(delay: 60.ms, duration: 450.ms)
        .slideY(
          begin: 0.06,
          end: 0,
          duration: 450.ms,
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
    final filled = widget.filled;
    final background = filled ? AppColors.primary : AppColors.surface;
    final foreground = filled ? AppColors.textOnPrimary : AppColors.textPrimary;
    final borderColor = filled ? AppColors.accentGold : AppColors.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, hovered ? -3 : 0, 0),
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 13.h),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22.r),
              bottomRight: Radius.circular(22.r),
              topRight: Radius.circular(6.r),
              bottomLeft: Radius.circular(6.r),
            ),
            border: Border.all(color: borderColor, width: 2.4),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: hovered ? 0.40 : 0.20),
                blurRadius: hovered ? 22 : 12,
                offset: Offset(hovered ? 4 : 3, hovered ? 10 : 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.bodyMedium(color: foreground)
                    .copyWith(fontSize: 13.5.sp, fontWeight: FontWeight.w800),
              ),
              if (widget.trailing != null) ...[
                SizedBox(width: 9.w),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  transform: Matrix4.translationValues(hovered ? 3 : 0, 0, 0),
                  child: IconTheme(
                    data: IconThemeData(
                      size: 16.sp,
                      color: filled ? AppColors.accentGold : AppColors.primary,
                    ),
                    child: widget.trailing!,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Visual
// ===========================================================================

class _HeroVisual extends StatelessWidget {
  final String imageUrl;
  final List<HomeStatModel> stats;
  const _HeroVisual({required this.imageUrl, required this.stats});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final desktop = width >= 1100;
    final imageHeight = desktop ? 565.h : (width >= 760 ? 480.h : 400.h);

    const borderWidth = 5.0;
    final big = 64.r;
    final small = 10.r;

    BorderRadius frameRadius(double inset) => BorderRadius.only(
      topLeft: Radius.circular(math.max(0, big - inset)),
      bottomRight: Radius.circular(math.max(0, big - inset)),
      topRight: Radius.circular(math.max(0, small - inset)),
      bottomLeft: Radius.circular(math.max(0, small - inset)),
    );

    final projectStat =
        stats.firstWhereOrNull(
          (s) => s.label.toLowerCase().contains('project'),
        ) ??
        (stats.isNotEmpty ? stats.first : null);

    return Padding(
          padding: EdgeInsets.only(left: 26.w, right: 16.w, bottom: 16.h),
          child: SizedBox(
            height: imageHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Offset green block behind the frame for depth.
                Positioned(
                  left: 16.w,
                  top: 16.h,
                  right: -16.w,
                  bottom: -16.h,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: frameRadius(0),
                    ),
                  ),
                ),
                // Image frame with thick golden border.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: frameRadius(0),
                      border: Border.all(
                        color: AppColors.accentGold,
                        width: borderWidth,
                      ),
                      boxShadow: AppColors.featureShadow,
                      color: AppColors.surfaceSoft,
                    ),
                    child: ClipRRect(
                      borderRadius: frameRadius(borderWidth),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (imageUrl.isNotEmpty)
                            CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              placeholder: (_, __) => const _HeroFallback(),
                              errorWidget: (_, __, ___) =>
                                  const _HeroFallback(),
                            )
                          else
                            const _HeroFallback(),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  AppColors.primary.withValues(alpha: 0.45),
                                ],
                              ),
                            ),
                          ),
                          // Light sweep.
                          IgnorePointer(
                            child:
                                DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withValues(alpha: 0),
                                            Colors.white.withValues(
                                              alpha: 0.20,
                                            ),
                                            Colors.white.withValues(alpha: 0),
                                          ],
                                          stops: const [0.4, 0.5, 0.6],
                                        ),
                                      ),
                                    )
                                    .animate(onPlay: (c) => c.repeat())
                                    .slideX(
                                      begin: -1.5,
                                      end: 1.5,
                                      duration: 3200.ms,
                                      curve: Curves.easeInOut,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Floating coloured tech stack (left edge).
                Positioned(
                  left: -34.w,
                  top: desktop ? 70.h : 50.h,
                  child: const _FloatingTechStack(),
                ),

                // Code card (top right).
                Positioned(
                  right: -4.w,
                  top: 22.h,
                  child: const _CodeCard()
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(
                        begin: -5,
                        end: 5,
                        duration: 2600.ms,
                        curve: Curves.easeInOut,
                      ),
                ),

                // Glass stat card (bottom left).
                if (projectStat != null)
                  Positioned(
                    left: 22.w,
                    bottom: 22.h,
                    child: _GlassStat(stat: projectStat)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(
                          begin: 4,
                          end: -4,
                          duration: 3000.ms,
                          curve: Curves.easeInOut,
                        ),
                  ),

                // Rotating badge (bottom right).
                Positioned(
                  right: -18.w,
                  bottom: 36.h,
                  child: const _SpinBadge(),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 550.ms)
        .scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1, 1),
          duration: 550.ms,
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

// ---------------------------------------------------------------------------
// Floating coloured tech icons
// ---------------------------------------------------------------------------

class _FloatingTechStack extends StatelessWidget {
  const _FloatingTechStack();

  @override
  Widget build(BuildContext context) {
    final items = <_TechItem>[
      _TechItem(
        'Flutter',
        _flutterBlue,
        const Icon(Icons.flutter_dash, color: _flutterBlue),
      ),
      _TechItem(
        'Firebase',
        _firebaseOrange,
        const Icon(Icons.local_fire_department_rounded, color: _firebaseOrange),
      ),
      _TechItem(
        'REST APIs',
        _apiTeal,
        const Icon(Icons.api_rounded, color: _apiTeal),
      ),
      _TechItem(
        'Stripe',
        _stripePurple,
        const FaIcon(FontAwesomeIcons.stripeS, color: _stripePurple),
      ),
      _TechItem(
        'GitHub',
        _githubInk,
        const FaIcon(FontAwesomeIcons.github, color: _githubInk),
      ),
    ];

    return Container(
          width: 62.w,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.r),
              bottomRight: Radius.circular(26.r),
              topRight: Radius.circular(8.r),
              bottomLeft: Radius.circular(8.r),
            ),
            border: Border.all(color: AppColors.primary, width: 2.4),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 26,
                offset: const Offset(6, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _TechBubble(item: items[i])
                    .animate(
                      onPlay: (c) => c.repeat(reverse: true),
                      delay: (i * 220).ms,
                    )
                    .moveY(
                      begin: -2.5,
                      end: 2.5,
                      duration: 1700.ms,
                      curve: Curves.easeInOut,
                    ),
                if (i != items.length - 1) SizedBox(height: 7.h),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .slideX(
          begin: -0.15,
          end: 0,
          duration: 450.ms,
          curve: Curves.easeOutBack,
        );
  }
}

class _TechItem {
  final String label;
  final Color color;
  final Widget icon;
  const _TechItem(this.label, this.color, this.icon);
}

class _TechBubble extends StatelessWidget {
  final _TechItem item;
  const _TechBubble({required this.item});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.label,
      child: Container(
        width: 42.w,
        height: 42.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: item.color.withValues(alpha: 0.85),
            width: 1.8,
          ),
        ),
        child: IconTheme(
          data: IconThemeData(size: 21.sp, color: item.color),
          child: item.icon,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Floating cards on the image
// ---------------------------------------------------------------------------

class _CodeCard extends StatelessWidget {
  const _CodeCard();

  @override
  Widget build(BuildContext context) {
    TextStyle mono(Color c) => TextStyle(
      fontFamily: 'monospace',
      fontSize: 11.sp,
      height: 1.5,
      fontWeight: FontWeight.w600,
      color: c,
    );
    const keyword = Color(0xFFC792EA);
    const fn = Color(0xFF82AAFF);
    const str = Color(0xFFC3E88D);
    final plain = Colors.white.withValues(alpha: 0.85);

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          bottomRight: Radius.circular(18.r),
          topRight: Radius.circular(5.r),
          bottomLeft: Radius.circular(5.r),
        ),
        border: Border.all(color: const Color(0xFF3FB68B), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final c in const [
                Color(0xFFFF5F57),
                Color(0xFFFEBC2E),
                Color(0xFF28C840),
              ])
                Container(
                  width: 8.w,
                  height: 8.w,
                  margin: EdgeInsets.only(right: 5.w),
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
              SizedBox(width: 6.w),
              Text(
                'sufyan.dart',
                style: mono(plain.withValues(alpha: 0.5))
                    .copyWith(fontSize: 9.5.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'void ', style: mono(keyword)),
                TextSpan(text: 'main', style: mono(fn)),
                TextSpan(text: '() {\n', style: mono(plain)),
                TextSpan(text: '  runApp', style: mono(fn)),
                TextSpan(text: '(', style: mono(plain)),
                TextSpan(text: "'Hire Me'", style: mono(str)),
                TextSpan(text: ');\n}', style: mono(plain)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassStat extends StatelessWidget {
  final HomeStatModel stat;
  const _GlassStat({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 18.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
          topRight: Radius.circular(5.r),
          bottomLeft: Radius.circular(5.r),
        ),
        border: Border.all(color: AppColors.accentGold, width: 2),
        boxShadow: AppColors.featureShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statIcon(stat.icon),
              size: 19.sp,
              color: AppColors.accentGold,
            ),
          ),
          SizedBox(width: 11.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stat.value,
                style: AppTextStyles.statNumber(color: AppColors.primary)
                    .copyWith(fontSize: 20.sp),
              ),
              SizedBox(height: 2.h),
              Text(
                stat.label,
                style: AppTextStyles.small(color: AppColors.textSecondary)
                    .copyWith(fontSize: 10.5.sp, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpinBadge extends StatelessWidget {
  const _SpinBadge();

  @override
  Widget build(BuildContext context) {
    final size = 84.w;
    return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                  boxShadow: AppColors.featureShadow,
                ),
              ),
              SizedBox(
                    width: size - 12,
                    height: size - 12,
                    child: CustomPaint(
                      painter: _DashedRingPainter(
                        AppColors.primary.withValues(alpha: 0.65),
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .rotate(duration: Duration(seconds: 9)),
              Icon(Icons.code_rounded, size: 30.sp, color: AppColors.primary),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 700.ms, duration: 400.ms)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOutBack,
        );
  }
}

// ===========================================================================
// Stats
// ===========================================================================

IconData _statIcon(String key) {
  switch (key) {
    case 'calendar':
      return Icons.calendar_month_rounded;
    case 'briefcase':
      return Icons.work_rounded;
    case 'code':
      return Icons.code_rounded;
    case 'heart':
      return Icons.favorite_rounded;
    case 'star':
      return Icons.star_rounded;
    case 'users':
      return Icons.groups_rounded;
    default:
      return Icons.auto_graph_rounded;
  }
}

class _HeroStats extends StatelessWidget {
  final List<HomeStatModel> stats;
  const _HeroStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final desktop = width >= 760;
    final items = stats.take(4).toList();

    const accents = [
      AppColors.primary,
      AppColors.accentGold,
      _flutterBlue,
      _stripePurple,
    ];
    const cardColors = [
      Color(0xFFFBFAF6),
      AppColors.accentGoldSoft,
      Color(0xFFFBFAF6),
      AppColors.accentGoldSoft,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = desktop ? 4 : 2;
        final gap = 16.w;
        final tileWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < items.length; i++)
              SizedBox(
                width: tileWidth,
                child:
                    _StatTile(
                          stat: items[i],
                          accent: accents[i % accents.length],
                          background: cardColors[i % cardColors.length],
                          mirrored: i.isOdd,
                        )
                        .animate()
                        .fadeIn(delay: (400 + i * 90).ms, duration: 400.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 450.ms,
                          curve: Curves.easeOutCubic,
                        ),
              ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final HomeStatModel stat;
  final Color accent;
  final Color background;
  final bool mirrored;

  const _StatTile({
    required this.stat,
    required this.accent,
    required this.background,
    required this.mirrored,
  });

  @override
  Widget build(BuildContext context) {
    final big = Radius.circular(24.r);
    final small = Radius.circular(6.r);
    final match = RegExp(r'^(\d+(?:\.\d+)?)(.*)$')
        .firstMatch(stat.value.trim());
    final number = match == null ? null : double.tryParse(match.group(1)!);
    final suffix = match?.group(2) ?? '';

    final valueStyle = AppTextStyles.statNumber(color: AppColors.textPrimary)
        .copyWith(fontSize: 28.sp, fontWeight: FontWeight.w900);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: mirrored
            ? BorderRadius.only(
                topRight: big,
                bottomLeft: big,
                topLeft: small,
                bottomRight: small,
              )
            : BorderRadius.only(
                topLeft: big,
                bottomRight: big,
                topRight: small,
                bottomLeft: small,
              ),
        border: Border.all(color: accent, width: 3),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: Offset(mirrored ? -4 : 4, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
                topRight: Radius.circular(4.r),
                bottomLeft: Radius.circular(4.r),
              ),
            ),
            child: Icon(
              _statIcon(stat.icon),
              size: 22.sp,
              color: accent == AppColors.accentGold
                  ? AppColors.textPrimary
                  : Colors.white,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (number == null)
                  Text(stat.value, style: valueStyle)
                else
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: number),
                    duration: const Duration(milliseconds: 1600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      final shown = number % 1 == 0
                          ? value.round().toString()
                          : value.toStringAsFixed(1);
                      return Text('$shown$suffix', style: valueStyle);
                    },
                  ),
                SizedBox(height: 3.h),
                Text(
                  stat.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small(color: AppColors.textSecondary)
                      .copyWith(fontSize: 11.5.sp, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
