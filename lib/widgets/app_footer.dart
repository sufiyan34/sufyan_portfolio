import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/footer_controller.dart';

// =============================================================================
// PAGE WRAPPER
// =============================================================================

/// Scrollable page body that ends with [AppFooter].
///
/// Short pages keep the footer pinned to the bottom of the screen; long pages
/// let it flow in after the content. Put your page content in [child] — the
/// footer stays full-width, outside any horizontal [padding].
///
/// ```dart
/// body: PageWithFooter(
///   padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 56.h),
///   child: YourPageContent(),
/// ),
/// ```
class PageWithFooter extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;

  const PageWithFooter({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: physics,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(padding: padding, child: child),
        ),
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Align(alignment: Alignment.bottomCenter, child: AppFooter()),
        ),
      ],
    );
  }
}

// =============================================================================
// FOOTER
// =============================================================================

class _FooterLinkData {
  final String label;
  final String route;
  const _FooterLinkData(this.label, this.route);
}

class AppFooter extends StatefulWidget {
  final String name;
  final String tagline;
  final bool showNewsletter;

  const AppFooter({
    super.key,
    this.name = 'Muhammad Sufyan',
    this.tagline = 'Flutter developer & software engineer building modern, scalable mobile, web and business apps.',
    this.showNewsletter = true,
  });

  @override
  State<AppFooter> createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> {
  late final FooterController _controller;
  final _emailController = TextEditingController();

  static const _explore = [
    _FooterLinkData('Home', AppRoutes.home),
    _FooterLinkData('About', AppRoutes.about),
    _FooterLinkData('Services', AppRoutes.services),
    _FooterLinkData('Skills', AppRoutes.skills),
    _FooterLinkData('Projects', AppRoutes.projects),
  ];

  static const _workWithMe = [
    _FooterLinkData('Packages', AppRoutes.packages),
    _FooterLinkData('Hire Me', AppRoutes.hireUs),
    _FooterLinkData('Book a Consultation', AppRoutes.consultation),
    _FooterLinkData('Contact', AppRoutes.contactUs),
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<FooterController>()
        ? Get.find<FooterController>()
        : Get.put(FooterController(), permanent: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await _controller.subscribe(_emailController.text);
    if (ok) _emailController.clear();
  }

  void _go(String route) {
    if (Get.currentRoute == route) {
      _scrollToTop();
      return;
    }
    Get.toNamed(route);
  }

  void _scrollToTop() {
    final controller = PrimaryScrollController.maybeOf(context);
    if (controller != null && controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 1000;
    final waveHeight = (desktop ? 78 : 44).h;

    return Stack(
      children: [
        // Back wave — a lighter, offset layer that gives the edge some depth.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: waveHeight + 4,
          child: CustomPaint(painter: _BackWavePainter(waveHeight)),
        ),

        // Front wave — the footer body itself, clipped to a curved top edge.
        ClipPath(
          clipper: _FrontWaveClipper(waveHeight),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Stack(
              children: [
                // Oversized, barely-there monogram for a bit of character.
                Positioned(
                  right: -10.w,
                  bottom: -46.h,
                  child: IgnorePointer(
                    child: Text(
                      'MS',
                      style: AppTextStyles.display(
                        color: Colors.white.withValues(alpha: 0.035),
                      ).copyWith(fontSize: 280.sp, height: 1),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: waveHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 1240.w),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          desktop ? 48.w : 22.w,
                          28.h,
                          desktop ? 48.w : 22.w,
                          22.h,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 900;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                wide ? _desktopTop() : _compactTop(),
                                SizedBox(height: 30.h),
                                const _FooterDivider(),
                                SizedBox(height: 16.h),
                                _bottomBar(wide),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // LAYOUTS
  // ---------------------------------------------------------------------------

  Widget _desktopTop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _brandBlock()),
        SizedBox(width: 24.w),
        Expanded(flex: 2, child: _linkColumn('Explore', _explore)),
        Expanded(flex: 3, child: _linkColumn('Work With Me', _workWithMe)),
        SizedBox(width: 12.w),
        Expanded(flex: 5, child: _connectBlock(alignEnd: true)),
      ],
    );
  }

  Widget _compactTop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _brandBlock(),
        SizedBox(height: 28.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _linkColumn('Explore', _explore)),
            SizedBox(width: 16.w),
            Expanded(child: _linkColumn('Work With Me', _workWithMe)),
          ],
        ),
        SizedBox(height: 28.h),
        _connectBlock(alignEnd: false),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // BLOCKS
  // ---------------------------------------------------------------------------

  Widget _brandBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: Text(
                'MS',
                style: AppTextStyles.bodyMedium(color: Colors.white)
                    .copyWith(fontSize: 15.sp, letterSpacing: 0.8),
              ),
            ),
            SizedBox(width: 13.w),
            Flexible(
              child: Text(
                widget.name,
                style: AppTextStyles.h3(color: Colors.white)
                    .copyWith(fontSize: 19.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 360.w),
          child: Text(
            widget.tagline,
            style: AppTextStyles.body(
              color: Colors.white.withValues(alpha: 0.68),
            ).copyWith(fontSize: 12.5.sp, height: 1.7),
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() {
          final content = _controller.content.value;
          final rows = <Widget>[
            if (_controller.hasEmail)
              _ContactLine(
                icon: Iconsax.sms,
                text: content.email,
                onTap: () => _open('mailto:${content.email}'),
              ),
            if (_controller.hasPhone)
              _ContactLine(
                icon: Iconsax.call,
                text: content.phone,
                onTap: () => _open('tel:${content.phone.replaceAll(' ', '')}'),
              ),
            if (_controller.hasLocation)
              _ContactLine(icon: Iconsax.location, text: content.location),
          ];
          if (rows.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rows,
          );
        }),
      ],
    );
  }

  Widget _linkColumn(String title, List<_FooterLinkData> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ColumnTitle(title),
        SizedBox(height: 13.h),
        for (final link in links)
          _FooterLink(label: link.label, onTap: () => _go(link.route)),
      ],
    );
  }

  Widget _connectBlock({required bool alignEnd}) {
    final cross = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: cross,
      children: [
        if (widget.showNewsletter) ...[
          Text(
            'Sign up for project updates & new work',
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            style: AppTextStyles.bodyMedium(color: Colors.white)
                .copyWith(fontSize: 12.5.sp),
          ),
          SizedBox(height: 11.h),
          _newsletterField(),
          Obx(() {
            final message = _controller.feedback.value;
            if (message.isEmpty) return const SizedBox.shrink();
            final error = _controller.feedbackIsError.value;
            return Padding(
              padding: EdgeInsets.only(top: 9.h),
              child: Text(
                message,
                textAlign: alignEnd ? TextAlign.end : TextAlign.start,
                style: AppTextStyles.small(
                  color: error ? const Color(0xFFF3B9B1) : AppColors.accentGold,
                ).copyWith(fontSize: 11.5.sp),
              ),
            );
          }),
          SizedBox(height: 22.h),
        ],
        Obx(() {
          final links = _socialButtons(_controller.content.value.socialLinks);
          if (links.isEmpty) return const SizedBox.shrink();
          return Wrap(
            alignment: alignEnd ? WrapAlignment.end : WrapAlignment.start,
            spacing: 10.w,
            runSpacing: 10.h,
            children: links,
          );
        }),
      ],
    );
  }

  Widget _newsletterField() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 430.w),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46.h,
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.send,
                onChanged: (_) => _controller.clearFeedback(),
                onSubmitted: (_) => _submit(),
                style: AppTextStyles.bodyMedium(color: AppColors.textPrimary)
                    .copyWith(fontSize: 13.sp),
                decoration: InputDecoration(
                  hintText: 'Your email address',
                  hintStyle: AppTextStyles.small(color: AppColors.textMuted)
                      .copyWith(fontSize: 12.5.sp),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Obx(() {
            final busy = _controller.isSubscribing.value;
            return SizedBox(
              height: 46.h,
              child: ElevatedButton(
                onPressed: busy ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: AppColors.primaryDark,
                  disabledBackgroundColor: AppColors.accentGold.withValues(
                    alpha: 0.6,
                  ),
                  disabledForegroundColor: AppColors.primaryDark,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 22.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: AppTextStyles.bodyMedium().copyWith(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: busy
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryDark,
                        ),
                      )
                    : const Text('Subscribe'),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _socialButtons(Map<String, String> links) {
    // Order = display order. Only networks with a saved URL are shown.
    const known = <String, (FaIconData, String)>{
      'github': (FontAwesomeIcons.github, 'GitHub'),
      'linkedin': (FontAwesomeIcons.linkedinIn, 'LinkedIn'),
      'x': (FontAwesomeIcons.xTwitter, 'X'),
      'instagram': (FontAwesomeIcons.instagram, 'Instagram'),
      'facebook': (FontAwesomeIcons.facebookF, 'Facebook'),
      'whatsapp': (FontAwesomeIcons.whatsapp, 'WhatsApp'),
      'website': (FontAwesomeIcons.globe, 'Website'),
    };

    final buttons = <Widget>[];
    for (final entry in known.entries) {
      final url = links[entry.key];
      if (url == null || url.trim().isEmpty) continue;
      buttons.add(
        _SocialButton(
          icon: entry.value.$1,
          tooltip: entry.value.$2,
          onTap: () => _open(url),
        ),
      );
    }
    return buttons;
  }

  Widget _bottomBar(bool wide) {
    final copyright = Text(
      '© ${DateTime.now().year} ${widget.name}. All rights reserved.',
      style: AppTextStyles.small(color: Colors.white.withValues(alpha: 0.78))
          .copyWith(fontSize: 11.5.sp, fontWeight: FontWeight.w600),
    );

    final built = Text(
      'Designed & built with Flutter',
      style: AppTextStyles.small(color: Colors.white.withValues(alpha: 0.5))
          .copyWith(fontSize: 11.5.sp),
    );

    final toTop = _BackToTop(onTap: _scrollToTop);

    if (wide) {
      return Row(
        children: [
          copyright,
          const Spacer(),
          built,
          SizedBox(width: 16.w),
          toTop,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              copyright,
              SizedBox(height: 4.h),
              built,
            ],
          ),
        ),
        toTop,
      ],
    );
  }
}

// =============================================================================
// SMALL PIECES
// =============================================================================

Future<void> _open(String raw) async {
  var value = raw.trim();
  if (value.isEmpty) return;
  if (!value.contains(':')) value = 'https://$value';
  final uri = Uri.tryParse(value);
  if (uri == null) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Nothing useful to show a visitor if their device can't open the link.
  }
}

class _ColumnTitle extends StatelessWidget {
  final String text;
  const _ColumnTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: AppTextStyles.bodyMedium(color: Colors.white)
              .copyWith(fontSize: 13.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 7.h),
        Container(
          width: 22.w,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.accentGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(left: _hover ? 6.w : 0, bottom: 11.h),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: AppTextStyles.body(
              color: _hover
                  ? AppColors.accentGold
                  : Colors.white.withValues(alpha: 0.74),
            ).copyWith(fontSize: 12.5.sp),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _ContactLine({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: EdgeInsets.only(bottom: 9.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: AppColors.accentGold),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.body(
                color: Colors.white.withValues(alpha: 0.74),
              ).copyWith(fontSize: 12.5.sp),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return row;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: row),
    );
  }
}

class _SocialButton extends StatefulWidget {
  final FaIconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _hover ? AppColors.accentGold : Colors.transparent,
              border: Border.all(
                color: _hover
                    ? AppColors.accentGold
                    : Colors.white.withValues(alpha: 0.24),
              ),
            ),
            child: FaIcon(
              widget.icon,
              size: 15.sp,
              color: _hover ? AppColors.primaryDark : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _BackToTop extends StatefulWidget {
  final VoidCallback onTap;
  const _BackToTop({required this.onTap});

  @override
  State<_BackToTop> createState() => _BackToTopState();
}

class _BackToTopState extends State<_BackToTop> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Back to top',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 38.w,
            height: 38.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _hover
                  ? AppColors.accentGold
                  : Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Icon(
              Iconsax.arrow_up_2,
              size: 16.sp,
              color: _hover ? AppColors.primaryDark : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterDivider extends StatelessWidget {
  const _FooterDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// WAVES
// =============================================================================

/// Front edge: the footer's real top outline.
Path _frontWave(Size size, double h) {
  final w = size.width;
  return Path()
    ..moveTo(0, h * 0.62)
    ..cubicTo(w * 0.20, h * 1.10, w * 0.42, h * 1.10, w * 0.60, h * 0.52)
    ..cubicTo(w * 0.76, h * 0.02, w * 0.90, h * 0.02, w, h * 0.42)
    ..lineTo(w, size.height)
    ..lineTo(0, size.height)
    ..close();
}

/// Back edge: same idea, different phase, so the two curves cross each other.
Path _backWave(Size size, double h) {
  final w = size.width;
  return Path()
    ..moveTo(0, h * 0.18)
    ..cubicTo(w * 0.22, h * 0.70, w * 0.40, h * 0.78, w * 0.64, h * 0.30)
    ..cubicTo(w * 0.80, 0, w * 0.92, 0, w, h * 0.22)
    ..lineTo(w, size.height)
    ..lineTo(0, size.height)
    ..close();
}

class _FrontWaveClipper extends CustomClipper<Path> {
  final double waveHeight;
  _FrontWaveClipper(this.waveHeight);

  @override
  Path getClip(Size size) => _frontWave(size, waveHeight);

  @override
  bool shouldReclip(covariant _FrontWaveClipper old) =>
      old.waveHeight != waveHeight;
}

class _BackWavePainter extends CustomPainter {
  final double waveHeight;
  _BackWavePainter(this.waveHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.info.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawPath(_backWave(size, waveHeight), paint);
  }

  @override
  bool shouldRepaint(covariant _BackWavePainter old) =>
      old.waveHeight != waveHeight;
}

// Option A: wrapper, keeps the footer pinned to the bottom on short pages
// body: PageWithFooter(
//   padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 56.h),
//   child: YourPageContent(),
// ),

// // Option B: drop it at the end of your own scroll view, outside the padded content
// SingleChildScrollView(
//   child: Column(children: [YourPaddedContent(), const AppFooter()]),
// )
