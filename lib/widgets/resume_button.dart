import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/repositories/about_content_repository.dart';
import 'package:sufyan_portfolio/utills/file_download.dart';

enum _DlState { idle, loading, done }

/// Animated "Download Resume" button.
///
/// Pass [url] when the page already has the About content loaded (About
/// screen). Leave it null anywhere else (Hire Me, footer, …) and the button
/// looks the resume link up itself. It hides itself when no resume has been
/// uploaded, so a visitor never sees a dead button.
///
/// Click → the file is fetched and saved straight to the computer, with a
/// live progress ring, then a "Downloaded!" confirmation.
class ResumeButton extends StatefulWidget {
  final String? url;

  /// Use `true` on dark backgrounds (e.g. the green Hire Me banner).
  final bool onDark;

  const ResumeButton({super.key, this.url, this.onDark = false});

  @override
  State<ResumeButton> createState() => _ResumeButtonState();
}

class _ResumeButtonState extends State<ResumeButton>
    with SingleTickerProviderStateMixin {
  static String? _cachedUrl;

  String _url = '';
  bool _hover = false;
  bool _pressed = false;
  _DlState _state = _DlState.idle;
  double? _progress;

  /// Drives the idle glow pulse and the bobbing download arrow.
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

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

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
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

  // ---------------------------------------------------------------------------
  // DOWNLOAD
  // ---------------------------------------------------------------------------

  /// "Resume.pdf" / "Resume.docx" — keeps the real extension of the stored file.
  String _fileName() {
    final path = Uri.tryParse(_url.trim())?.path ?? '';
    final last = Uri.decodeComponent(path.split('/').last);
    final dot = last.lastIndexOf('.');
    final ext = dot >= 0 ? last.substring(dot + 1).toLowerCase() : '';
    return 'Resume.${RegExp(r'^[a-z0-9]{2,5}$').hasMatch(ext) ? ext : 'pdf'}';
  }

  /// Plain-language reason a download failed, so the problem is visible
  /// instead of silently opening a link.
  String _failureReason(Object e) {
    if (e is DioException) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        return 'Cloudinary refused to serve the file (HTTP $code). In Cloudinary '
            'go to Settings → Security and enable "PDF and ZIP files delivery".';
      }
      if (code == 404) {
        return 'The file was not found at the saved link. Re-upload the resume '
            'in the admin panel and press Save.';
      }
      return 'The file could not be fetched (blocked by the browser or offline). '
          'Check your connection and that the resume link opens.';
    }
    return 'The file could not be saved on this device.';
  }

  Future<void> _open() async {
    if (_state == _DlState.loading) return;
    setState(() {
      _state = _DlState.loading;
      _progress = null;
    });

    String? savedTo;
    String? failure;
    try {
      final res = await Dio().get<List<int>>(
        _url.trim(),
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (!mounted) return;
          setState(() => _progress = total > 0 ? received / total : null);
        },
      );
      final data = res.data;
      if (data == null || data.isEmpty) {
        failure = 'The downloaded file was empty.';
      } else {
        savedTo = await saveBytesToDevice(
          Uint8List.fromList(data),
          _fileName(),
        );
        failure ??= savedTo == null ? _failureReason('save') : null;
      }
    } catch (e) {
      debugPrint('Resume download failed: $e');
      failure = _failureReason(e);
    }

    if (!mounted) return;
    setState(() => _state = savedTo != null ? _DlState.done : _DlState.idle);

    if (savedTo != null) {
      Future.delayed(const Duration(milliseconds: 2600), () {
        if (mounted) setState(() => _state = _DlState.idle);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 7),
          content: Text(failure ?? 'Couldn\'t download the resume.'),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  String get _label {
    switch (_state) {
      case _DlState.idle:
        return 'Download Resume';
      case _DlState.loading:
        final p = _progress;
        return p == null ? 'Downloading…' : 'Downloading ${(p * 100).round()}%';
      case _DlState.done:
        return 'Downloaded!';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_url.trim().isEmpty) return const SizedBox.shrink();

    final active = _hover || _pressed;
    final loading = _state == _DlState.loading;
    final done = _state == _DlState.done;
    final dark = widget.onDark && !done;

    final gradient = done
        ? const [AppColors.success, Color(0xFF256349)]
        : widget.onDark
        ? const [AppColors.accentGold, Color(0xFFE9C46A)]
        : const [AppColors.primary, AppColors.primaryDark];
    final fg = dark ? AppColors.primary : Colors.white;
    final glow = done
        ? AppColors.success
        : (widget.onDark ? AppColors.accentGold : AppColors.primary);
    final circleBg = dark ? AppColors.primary : AppColors.accentGold;
    final circleFg = dark ? Colors.white : AppColors.primaryDark;
    final circleSize = 40.w;

    final icon = done
        ? Icon(
            Icons.check_rounded,
            key: const ValueKey('check'),
            size: 22.sp,
            color: circleFg,
          )
        : loading
        ? Icon(
            Icons.arrow_downward_rounded,
            key: const ValueKey('arrow'),
            size: 18.sp,
            color: circleFg,
          )
        : AnimatedBuilder(
            key: const ValueKey('bob'),
            animation: _loop,
            builder: (_, child) {
              final dy =
                  math.sin(_loop.value * 2 * math.pi) * (active ? 4.0 : 2.5);
              return Transform.translate(offset: Offset(0, dy), child: child);
            },
            child: Icon(
              Icons.file_download_outlined,
              size: 22.sp,
              color: circleFg,
            ),
          );

    final pill = AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 24.w, 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleBg,
                  ),
                ),
                if (loading)
                  SizedBox(
                    width: circleSize,
                    height: circleSize,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 2.6,
                      color: circleFg,
                      backgroundColor: circleFg.withValues(alpha: .22),
                    ),
                  ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: icon,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, .35),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.centerLeft,
              children: [...previous, if (current != null) current],
            ),
            child: Text(
              _label,
              key: ValueKey(_state),
              style: AppTextStyles.bodyMedium(color: fg).copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: .2,
              ),
            ),
          ),
        ],
      ),
    );

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
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            scale: _pressed ? .95 : (_hover ? 1.05 : 1),
            child: AnimatedBuilder(
              animation: _loop,
              // Soft breathing glow while idle, stronger on hover.
              builder: (_, child) {
                final wave = (math.sin(_loop.value * 2 * math.pi) + 1) / 2;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: glow.withValues(
                          alpha: active ? .45 : .16 + .16 * wave,
                        ),
                        blurRadius: active ? 28 : 12 + 10 * wave,
                        spreadRadius: active ? 1 : 2 * wave,
                        offset: Offset(0, active ? 12 : 6),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              // A light sweep glides across the button every few seconds.
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: pill
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(
                      delay: 1800.ms,
                      duration: 1500.ms,
                      color: Colors.white.withValues(alpha: .38),
                    ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 420.ms).slideY(begin: .25, end: 0);
  }
}
