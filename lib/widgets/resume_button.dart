import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/repositories/about_content_repository.dart';
import 'package:sufyan_portfolio/widgets/contact_social_links.dart'
    show openExternalLink;

/// Animated "Download Resume" pill.
///
/// Pass [url] when the page already has the About content loaded (About
/// screen). Leave it null anywhere else (Hire Me, footer, …) and the button
/// looks the resume link up itself. It hides itself when no resume has been
/// uploaded, so a visitor never sees a dead button.
class ResumeButton extends StatefulWidget {
  final String? url;

  /// Use `true` on dark backgrounds (e.g. the green Hire Me banner).
  final bool onDark;

  const ResumeButton({super.key, this.url, this.onDark = false});

  @override
  State<ResumeButton> createState() => _ResumeButtonState();
}

class _ResumeButtonState extends State<ResumeButton> {
  static String? _cachedUrl;

  String _url = '';
  bool _hover = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _url = widget.url ?? _cachedUrl ?? '';
    if (widget.url == null && _cachedUrl == null) _fetch();
  }

  @override
  void didUpdateWidget(covariant ResumeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != null && widget.url != _url) _url = widget.url!;
  }

  Future<void> _fetch() async {
    try {
      final about = await AboutContentRepository.instance.getContent();
      _cachedUrl = about.resumeUrl;
      if (mounted) setState(() => _url = about.resumeUrl);
    } catch (_) {
      // Stay hidden.
    }
  }

  Future<void> _open() async {
    final ok = await openExternalLink(_url);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t open the resume right now.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_url.trim().isEmpty) return const SizedBox.shrink();

    final active = _hover || _pressed;
    // Light-background look: green outline -> fills green. Dark: gold pill.
    final bg = widget.onDark
        ? (active ? Colors.white : AppColors.accentGold)
        : (active ? AppColors.primary : AppColors.surface);
    final fg = widget.onDark
        ? AppColors.primary
        : (active ? Colors.white : AppColors.primary);
    final border = widget.onDark
        ? Colors.transparent
        : (active ? AppColors.primary : AppColors.border);

    return Semantics(
      button: true,
      label: 'Download resume',
      child: MouseRegion(
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
          onTap: _open,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 160),
            scale: _pressed ? .96 : (_hover ? 1.04 : 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: border),
                boxShadow: _hover
                    ? [
                        BoxShadow(
                          color: (widget.onDark ? Colors.black : AppColors.primary)
                              .withValues(alpha: .22),
                          blurRadius: 20,
                          offset: const Offset(0, 9),
                        ),
                      ]
                    : const [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Arrow nudges down on hover, like a download.
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutBack,
                    offset: Offset(0, _hover ? .12 : 0),
                    child: Icon(Icons.download_rounded, size: 19.sp, color: fg),
                  ),
                  SizedBox(width: 9.w),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 240),
                    style: AppTextStyles.bodyMedium(color: fg).copyWith(fontSize: 13.5.sp),
                    child: const Text('Download Resume'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: .25, end: 0),
    );
  }
}
