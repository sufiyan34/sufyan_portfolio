import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/widgets/app_footer.dart';
import 'package:sufyan_portfolio/widgets/public_navbar.dart';

/// Branded 404 page.
///
/// * the 4-0-4 digits float and follow the pointer (parallax, also on touch drag)
/// * tap the "0" to spin it — it has opinions about being poked
/// * "Back to Home", "Go back" and quick links, all with hover animation
/// * fully responsive: digits scale with the screen width
class NotFoundScreen extends StatefulWidget {
  const NotFoundScreen({super.key});

  @override
  State<NotFoundScreen> createState() => _NotFoundScreenState();
}

class _NotFoundScreenState extends State<NotFoundScreen>
    with SingleTickerProviderStateMixin {
  static const _quips = [
    'Ouch. Still not here.',
    'Nothing under this one either.',
    'I only know how to spin.',
    'The buttons below work better.',
    'Okay, now you’re just poking me.',
    'Fine. Take me home?',
  ];

  late final AnimationController _spin;
  Offset _pointer = Offset.zero; // -1..1 in both axes
  int _taps = 0;
  String? _quip;
  Timer? _quipTimer;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _quipTimer?.cancel();
    _spin.dispose();
    super.dispose();
  }

  void _onZeroTap() {
    _spin.forward(from: 0);
    setState(() => _quip = _quips[_taps++ % _quips.length]);
    _quipTimer?.cancel();
    _quipTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _quip = null);
    });
  }

  void _trackPointer(Offset local, Size size) {
    if (size.isEmpty) return;
    setState(() {
      _pointer = Offset(
        ((local.dx / size.width) - .5) * 2,
        ((local.dy / size.height) - .5) * 2,
      ).clampedTo(-1, 1);
    });
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PublicNavbar(activeRoute: AppRoutes.notFound),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final heroHeight = math.max(560.0, constraints.maxHeight * 0.86);

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: heroHeight,
                  width: double.infinity,
                  child: _hero(constraints.maxWidth, heroHeight),
                ),
                AppFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _hero(double width, double height) {
    final digit = (width * 0.19).clamp(96.0, 230.0);
    final compact = width < 640;
    final attempted = Uri.base.path;
    final showPath =
        attempted.isNotEmpty &&
        attempted != '/' &&
        attempted != AppRoutes.notFound;

    return MouseRegion(
      onHover: (event) =>
          _trackPointer(event.localPosition, Size(width, height)),
      onExit: (_) => setState(() => _pointer = Offset.zero),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (d) => _trackPointer(d.localPosition, Size(width, height)),
        onPanEnd: (_) => setState(() => _pointer = Offset.zero),
        child: Stack(
          children: [
            ..._backgroundShapes(width, height),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _digits(digit),
                    SizedBox(height: compact ? 8 : 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(scale: anim, child: child),
                      ),
                      child: _quip == null
                          ? const SizedBox(key: ValueKey('none'), height: 30)
                          : Container(
                              key: ValueKey(_quip),
                              height: 30,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentGoldSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _quip!,
                                style:
                                    AppTextStyles.small(
                                      color: AppColors.textPrimary,
                                    ).copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                          'Lost in the pixels?',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h1().copyWith(
                            fontSize: compact ? 30 : 42,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 450.ms)
                        .slideY(begin: .12, end: 0),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Text(
                        'The page you’re looking for doesn’t exist, has moved, or never made it out of the sketchbook.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body().copyWith(
                          fontSize: compact ? 14 : 16,
                          height: 1.6,
                        ),
                      ),
                    ).animate().fadeIn(delay: 620.ms, duration: 450.ms),
                    if (showPath) ...[
                      const SizedBox(height: 14),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 520),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          attempted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.small().copyWith(
                            fontFamily: 'monospace',
                            fontSize: 12.5,
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                    ],
                    const SizedBox(height: 26),
                    Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _NfButton(
                              label: 'Back to Home',
                              icon: Icons.home_rounded,
                              filled: true,
                              onTap: () => Get.offAllNamed(AppRoutes.home),
                            ),
                            _NfButton(
                              label: 'Go back',
                              icon: Icons.arrow_back_rounded,
                              filled: false,
                              onTap: _goBack,
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(delay: 780.ms, duration: 450.ms)
                        .slideY(begin: .15, end: 0),
                    const SizedBox(height: 26),
                    Text('Or jump straight to', style: AppTextStyles.small()),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final link in const [
                          ('Projects', AppRoutes.projects),
                          ('Services', AppRoutes.services),
                          ('Packages', AppRoutes.packages),
                          ('About', AppRoutes.about),
                          ('Contact', AppRoutes.contactUs),
                        ])
                          _QuickLink(
                            label: link.$1,
                            onTap: () => Get.offAllNamed(link.$2),
                          ),
                      ],
                    ).animate().fadeIn(delay: 900.ms, duration: 450.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4 0 4
  // ---------------------------------------------------------------------------

  Widget _digits(double d) {
    Widget parallax(double factor, Widget child) {
      return TweenAnimationBuilder<Offset>(
        tween: Tween(end: _pointer),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        builder: (_, value, c) => Transform.translate(
          offset: Offset(value.dx * factor, value.dy * factor),
          child: c,
        ),
        child: child,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        parallax(16, _four(d))
            .animate()
            .fadeIn(duration: 450.ms)
            .slideY(
              begin: .4,
              end: 0,
              duration: 650.ms,
              curve: Curves.easeOutBack,
            ),
        SizedBox(width: d * .05),
        parallax(30, _zero(d))
            .animate()
            .fadeIn(delay: 140.ms, duration: 450.ms)
            .slideY(
              begin: .4,
              end: 0,
              delay: 140.ms,
              duration: 650.ms,
              curve: Curves.easeOutBack,
            ),
        SizedBox(width: d * .05),
        parallax(16, _four(d))
            .animate()
            .fadeIn(delay: 280.ms, duration: 450.ms)
            .slideY(
              begin: .4,
              end: 0,
              delay: 280.ms,
              duration: 650.ms,
              curve: Curves.easeOutBack,
            ),
      ],
    );
  }

  Widget _four(double d) {
    return ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ).createShader(rect),
          child: Text(
            '4',
            style: AppTextStyles.display().copyWith(
              fontSize: d,
              height: 1,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: -5, end: 5, duration: 2600.ms, curve: Curves.easeInOut);
  }

  Widget _zero(double d) {
    final ring = d * .66;

    return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _onZeroTap,
            child: RotationTransition(
              turns: CurvedAnimation(
                parent: _spin,
                curve: Curves.easeInOutBack,
              ),
              child: SizedBox(
                width: ring + 20,
                height: ring + 20,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ring
                    Container(
                      width: ring,
                      height: ring,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: d * .075,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .18),
                            blurRadius: 30,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                    ),
                    // Gold dot orbiting the ring
                    SizedBox(
                          width: ring + 20,
                          height: ring + 20,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: d * .13,
                              height: d * .13,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat())
                        .rotate(duration: Duration(seconds: 5)),
                    // Question mark in the middle
                    Text(
                          '?',
                          style: AppTextStyles.display().copyWith(
                            fontSize: d * .3,
                            height: 1,
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(.9, .9),
                          end: const Offset(1.1, 1.1),
                          duration: 1400.ms,
                          curve: Curves.easeInOut,
                        ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: 6, end: -6, duration: 2200.ms, curve: Curves.easeInOut);
  }

  // ---------------------------------------------------------------------------
  // Drifting background blobs
  // ---------------------------------------------------------------------------

  List<Widget> _backgroundShapes(double w, double h) {
    Widget blob({
      required double left,
      required double top,
      required double size,
      required Color color,
      required int ms,
      required double travel,
    }) {
      return Positioned(
        left: left,
        top: top,
        child: IgnorePointer(
          child:
              Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(
                    begin: -travel,
                    end: travel,
                    duration: ms.ms,
                    curve: Curves.easeInOut,
                  ),
        ),
      );
    }

    return [
      blob(
        left: w * .06,
        top: h * .12,
        size: 120,
        color: AppColors.primarySoft,
        ms: 4200,
        travel: 16,
      ),
      blob(
        left: w * .84,
        top: h * .18,
        size: 78,
        color: AppColors.accentGoldSoft,
        ms: 3600,
        travel: 12,
      ),
      blob(
        left: w * .14,
        top: h * .68,
        size: 64,
        color: AppColors.accentGoldSoft,
        ms: 3900,
        travel: 14,
      ),
      blob(
        left: w * .78,
        top: h * .66,
        size: 140,
        color: AppColors.primarySoft,
        ms: 4800,
        travel: 18,
      ),
    ];
  }
}

extension on Offset {
  Offset clampedTo(double min, double max) =>
      Offset(dx.clamp(min, max).toDouble(), dy.clamp(min, max).toDouble());
}

// =============================================================================
// Buttons
// =============================================================================

class _NfButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _NfButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  State<_NfButton> createState() => _NfButtonState();
}

class _NfButtonState extends State<_NfButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final filled = widget.filled;
    final bg = filled
        ? (_hover ? AppColors.primaryDark : AppColors.primary)
        : (_hover ? AppColors.primarySoft : AppColors.surface);
    final fg = filled ? Colors.white : AppColors.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _pressed ? .96 : (_hover ? 1.05 : 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: filled ? bg : AppColors.border),
              boxShadow: _hover && filled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .3),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSlide(
                  duration: const Duration(milliseconds: 220),
                  offset: Offset(
                    widget.icon == Icons.arrow_back_rounded && _hover ? -.2 : 0,
                    0,
                  ),
                  child: Icon(widget.icon, size: 19, color: fg),
                ),
                const SizedBox(width: 9),
                Text(
                  widget.label,
                  style: AppTextStyles.bodyMedium(color: fg)
                      .copyWith(fontSize: 14.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickLink({required this.label, required this.onTap});

  @override
  State<_QuickLink> createState() => _QuickLinkState();
}

class _QuickLinkState extends State<_QuickLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          offset: Offset(0, _hover ? -.1 : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _hover ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: _hover ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              widget.label,
              style: AppTextStyles.small(
                color: _hover ? Colors.white : AppColors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w700, fontSize: 12.5),
            ),
          ),
        ),
      ),
    );
  }
}
