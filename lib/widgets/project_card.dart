import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/project_model.dart';

/// Optional default cover used when a project has no image, e.g.
/// 'assets/images/default_project.png' (folder is already in pubspec assets).
/// Leave empty to use the built-in painted artwork below.
const String kDefaultProjectCover = '';

/// Project card — fully [StatelessWidget].
///
/// Design:
///  * diagonal corners (two big, two nearly square) + thick coloured border
///  * the card colour and the border colour always differ
///  * full-bleed cover image that is cut on a slant into the info panel
///  * everything that moves is stateless: the entrance (3D swing-in, fade,
///    rise), the pulsing arrow and the light sweep come from flutter_animate,
///    and the hover tint + ripple come from [InkWell] (it owns its own state).
///
/// [index] is optional. When given, it staggers the entrance, alternates the
/// colour scheme / corner direction and prints a "No. 01" tag on the cover.
class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;
  final int index;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.index = -1,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _Palette.pick(index >= 0 ? index : _seed(project.title));
    final mirrored = palette.mirrored;
    final borderWidth = 4.5.w;
    final big = 38.r;
    final small = 8.r;

    BorderRadius radius(double inset) {
      final b = math.max(0.0, big - inset);
      final s = math.max(0.0, small - inset);
      return mirrored
          ? BorderRadius.only(
              topRight: Radius.circular(b),
              bottomLeft: Radius.circular(b),
              topLeft: Radius.circular(s),
              bottomRight: Radius.circular(s),
            )
          : BorderRadius.only(
              topLeft: Radius.circular(b),
              bottomRight: Radius.circular(b),
              topRight: Radius.circular(s),
              bottomLeft: Radius.circular(s),
            );
    }

    final card = Container(
      decoration: BoxDecoration(
        borderRadius: radius(0),
        border: Border.all(color: palette.border, width: borderWidth),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.background, palette.backgroundAlt],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.border.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: Offset(mirrored ? -6 : 6, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius(borderWidth),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(flex: 11, child: _cover(palette)),
                Expanded(flex: 9, child: _info(palette)),
              ],
            ),
            // Hover tint + ripple + tap target for the whole card.
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  mouseCursor: SystemMouseCursors.click,
                  hoverColor: palette.accent.withValues(alpha: 0.12),
                  splashColor: palette.accent.withValues(alpha: 0.20),
                  highlightColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final delay = Duration(milliseconds: 90 * (math.max(index, 0) % 6));

    return card
        .animate(delay: delay)
        .fadeIn(duration: 450.ms)
        .slideY(
          begin: 0.06,
          end: 0,
          duration: 650.ms,
          curve: Curves.easeOutCubic,
        )
        // 3D swing-in around the X axis.
        .custom(
          duration: 800.ms,
          curve: Curves.easeOutBack,
          begin: 0,
          end: 1,
          builder: (context, value, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0011)
              ..rotateX((1 - value) * (math.pi / 2.6)),
            child: child,
          ),
        );
  }

  // ---------------------------------------------------------------------
  // Cover
  // ---------------------------------------------------------------------

  Widget _cover(_Palette palette) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipPath(
          clipper: _SlantClipper(cut: 34.h, mirrored: palette.mirrored),
          child: Stack(
            fit: StackFit.expand,
            children: [
              project.coverImageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: project.coverImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _coverFallback(palette),
                      errorWidget: (_, __, ___) => _coverFallback(palette),
                    )
                  : _coverFallback(palette),
              // Darken the top so the chips stay readable on any image.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Colour wash that ties the photo to the card palette.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      palette.background.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Light sweep that repeats every few seconds.
              IgnorePointer(
                child:
                    DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0.22),
                                Colors.white.withValues(alpha: 0),
                              ],
                              stops: const [0.35, 0.5, 0.65],
                            ),
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat())
                        .slideX(
                          begin: -1.4,
                          end: 1.4,
                          duration: 2600.ms,
                          curve: Curves.easeInOut,
                        ),
              ),
            ],
          ),
        ),
        // Accent line that follows the slanted cut.
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _SlantLinePainter(
                cut: 34.h,
                mirrored: palette.mirrored,
                color: palette.accent,
                width: 4.w,
              ),
            ),
          ),
        ),
        // Top chips.
        Positioned(
          top: 14.h,
          left: palette.mirrored ? 16.w : 22.w,
          right: palette.mirrored ? 22.w : 16.w,
          child: Row(
            children: [
              if (project.year > 0)
                _Tag(
                  label: '${project.year}',
                  background: Colors.black.withValues(alpha: 0.55),
                  foreground: Colors.white,
                ),
              if (project.featured) ...[
                if (project.year > 0) SizedBox(width: 6.w),
                _Tag(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Featured',
                  background: palette.accent,
                  foreground: palette.onAccent,
                ),
              ],
              const Spacer(),
              if (index >= 0)
                Text(
                  'No. ${(index + 1).toString().padLeft(2, '0')}',
                  style: AppTextStyles.small(color: Colors.white).copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Shown when the project has no cover image (or it fails to load).
  ///
  /// 1. If [kDefaultProjectCover] points to an asset, that image is used.
  /// 2. Otherwise (or if the asset is missing) a built-in painted artwork is
  ///    drawn, so a card never looks empty. The artwork varies per project.
  Widget _coverFallback(_Palette palette) {
    final art = _DefaultCoverArt(
      seed: _seed(project.title.isEmpty ? project.id : project.title),
      palette: palette,
      title: project.title,
    );
    if (kDefaultProjectCover.isEmpty) return art;
    return Image.asset(
      kDefaultProjectCover,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => art,
    );
  }

  // ---------------------------------------------------------------------
  // Info panel
  // ---------------------------------------------------------------------

  Widget _info(_Palette palette) {
    final techs = project.technologies;
    final shown = techs.take(3).toList();
    final extra = techs.length - shown.length;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        palette.mirrored ? 18.w : 22.w,
        0,
        palette.mirrored ? 22.w : 18.w,
        16.h,
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3(color: palette.foreground)
                        .copyWith(fontSize: 19.sp, fontWeight: FontWeight.w800),
                  ),
                ),
                SizedBox(width: 8.w),
                // Pulsing arrow button.
                Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        color: palette.accent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(13.r),
                          bottomRight: Radius.circular(13.r),
                          topRight: Radius.circular(3.r),
                          bottomLeft: Radius.circular(3.r),
                        ),
                      ),
                      child: Icon(
                        Icons.north_east_rounded,
                        size: 18.sp,
                        color: palette.onAccent,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleXY(
                      begin: 1,
                      end: 1.1,
                      duration: 1100.ms,
                      curve: Curves.easeInOut,
                    ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              project.shortDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(color: palette.secondary)
                  .copyWith(fontSize: 13.sp, height: 1.5),
            ),
            if (techs.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  for (final tech in shown) ...[
                    Flexible(
                      child: _TechChip(label: tech, palette: palette),
                    ),
                    SizedBox(width: 6.w),
                  ],
                  if (extra > 0)
                    Text(
                      '+$extra',
                      style: AppTextStyles.small(
                        color: palette.accent,
                      ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w900),
                    ),
                  const Spacer(),
                  if (project.githubUrl.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 6.w),
                      child: Icon(
                        Icons.code_rounded,
                        size: 16.sp,
                        color: palette.secondary,
                      ),
                    ),
                  if (project.liveUrl.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 6.w),
                      child: Icon(
                        Icons.public_rounded,
                        size: 16.sp,
                        color: palette.secondary,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static int _seed(String key) {
    var sum = 0;
    for (final unit in key.trim().toLowerCase().codeUnits) {
      sum += unit;
    }
    return sum;
  }
}

/// Card colour + a deliberately *different* border colour.
class _Palette {
  final Color background;
  final Color backgroundAlt;
  final Color border;
  final Color foreground;
  final Color secondary;
  final Color accent;
  final Color onAccent;
  final bool mirrored;

  const _Palette({
    required this.background,
    required this.backgroundAlt,
    required this.border,
    required this.foreground,
    required this.secondary,
    required this.accent,
    required this.onAccent,
    required this.mirrored,
  });

  static const _ink = Color(0xFF111413);

  static _Palette pick(int seed) {
    switch (seed % 4) {
      case 0: // green card, golden border
        return _Palette(
          background: AppColors.primary,
          backgroundAlt: AppColors.primaryDark,
          border: AppColors.accentGold,
          foreground: Colors.white,
          secondary: Colors.white.withValues(alpha: 0.74),
          accent: AppColors.accentGold,
          onAccent: AppColors.textPrimary,
          mirrored: false,
        );
      case 1: // ivory card, black border
        return _Palette(
          background: const Color(0xFFFBFAF6),
          backgroundAlt: const Color(0xFFE9EAE6),
          border: _ink,
          foreground: AppColors.textPrimary,
          secondary: AppColors.textSecondary,
          accent: _ink,
          onAccent: Colors.white,
          mirrored: true,
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
          mirrored: false,
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
          mirrored: true,
        );
    }
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;

  const _Tag({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: foreground),
            SizedBox(width: 3.w),
          ],
          Text(
            label,
            style: AppTextStyles.small(color: foreground)
                .copyWith(fontSize: 10.5.sp, fontWeight: FontWeight.w800),
          ),
        ],
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
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: palette.foreground.withValues(alpha: 0.08),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.r),
          bottomRight: Radius.circular(10.r),
          topRight: Radius.circular(3.r),
          bottomLeft: Radius.circular(3.r),
        ),
        border: Border.all(
          color: palette.accent.withValues(alpha: 0.7),
          width: 1.2,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.small(color: palette.foreground)
            .copyWith(fontSize: 10.5.sp, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Cuts the bottom edge of the cover on a diagonal.
class _SlantClipper extends CustomClipper<Path> {
  final double cut;
  final bool mirrored;

  const _SlantClipper({required this.cut, required this.mirrored});

  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, 0);
    path.lineTo(size.width, 0);
    if (mirrored) {
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height - cut);
    } else {
      path.lineTo(size.width, size.height - cut);
      path.lineTo(0, size.height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _SlantClipper old) =>
      old.cut != cut || old.mirrored != mirrored;
}

class _SlantLinePainter extends CustomPainter {
  final double cut;
  final bool mirrored;
  final Color color;
  final double width;

  const _SlantLinePainter({
    required this.cut,
    required this.mirrored,
    required this.color,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    final a = mirrored ? Offset(0, size.height - cut) : Offset(0, size.height);
    final b = mirrored
        ? Offset(size.width, size.height)
        : Offset(size.width, size.height - cut);
    canvas.drawLine(a, b, paint);
  }

  @override
  bool shouldRepaint(covariant _SlantLinePainter old) =>
      old.cut != cut ||
      old.mirrored != mirrored ||
      old.color != color ||
      old.width != width;
}

/// Painted placeholder artwork — three layouts picked from the project seed:
/// a browser window, a phone, or a dashboard. No asset files needed.
class _DefaultCoverArt extends StatelessWidget {
  final int seed;
  final _Palette palette;
  final String title;

  const _DefaultCoverArt({
    required this.seed,
    required this.palette,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CoverArtPainter(seed: seed, palette: palette),
      child: const SizedBox.expand(),
    );
  }
}

class _CoverArtPainter extends CustomPainter {
  final int seed;
  final _Palette palette;

  const _CoverArtPainter({required this.seed, required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // Base gradient.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(palette.background, palette.accent, 0.28)!,
            palette.backgroundAlt,
          ],
        ).createShader(rect),
    );

    // Dot grid.
    final dot = Paint()..color = palette.foreground.withValues(alpha: 0.10);
    const step = 22.0;
    for (double x = step / 2; x < w; x += step) {
      for (double y = step / 2; y < h; y += step) {
        canvas.drawCircle(Offset(x, y), 1.4, dot);
      }
    }

    // Big soft diagonal shapes.
    final shape = Paint()..color = palette.accent.withValues(alpha: 0.16);
    final shift = (seed % 3) * 0.08;
    canvas.drawPath(
      Path()
        ..moveTo(w * (0.55 + shift), 0)
        ..lineTo(w, 0)
        ..lineTo(w, h * 0.7)
        ..close(),
      shape,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h * (0.45 + shift))
        ..lineTo(w * 0.45, h)
        ..lineTo(0, h)
        ..close(),
      shape..color = palette.foreground.withValues(alpha: 0.07),
    );

    switch (seed % 3) {
      case 0:
        _browser(canvas, size);
        break;
      case 1:
        _phone(canvas, size);
        break;
      default:
        _dashboard(canvas, size);
    }
  }

  Paint get _line =>
      Paint()..color = palette.foreground.withValues(alpha: 0.28);
  Paint get _accent => Paint()..color = palette.accent;

  RRect _rr(double l, double t, double w, double h, double r) =>
      RRect.fromRectAndRadius(Rect.fromLTWH(l, t, w, h), Radius.circular(r));

  void _windowFrame(Canvas canvas, RRect frame) {
    canvas.drawShadow(
      Path()..addRRect(frame),
      Colors.black.withValues(alpha: 0.6),
      14,
      false,
    );
    canvas.drawRRect(
      frame,
      Paint()..color = palette.background.withValues(alpha: 0.92),
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..color = palette.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
  }

  void _browser(Canvas canvas, Size size) {
    final w = size.width * 0.62;
    final h = size.height * 0.5;
    final l = (size.width - w) / 2;
    final t = size.height * 0.16;
    _windowFrame(canvas, _rr(l, t, w, h, 10));

    // Title bar dots.
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(l + 14 + i * 12, t + 13), 3.2, _accent);
    }
    canvas.drawRRect(_rr(l + 52, t + 8, w - 66, 10, 5), _line);

    // Hero block + text lines.
    canvas.drawRRect(_rr(l + 14, t + 32, w * 0.42, h * 0.34, 6), _accent);
    for (var i = 0; i < 4; i++) {
      canvas.drawRRect(
        _rr(
          l + w * 0.5,
          t + 34 + i * 13,
          (w * 0.4) - (i.isEven ? 0 : 16),
          6,
          3,
        ),
        _line,
      );
    }
    // Card row.
    final cw = (w - 28 - 16) / 3;
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        _rr(l + 14 + i * (cw + 8), t + h * 0.62, cw, h * 0.28, 5),
        _line,
      );
    }
  }

  void _phone(Canvas canvas, Size size) {
    final h = size.height * 0.66;
    final w = h * 0.5;
    final l = (size.width - w) / 2;
    final t = size.height * 0.1;
    _windowFrame(canvas, _rr(l, t, w, h, 16));

    canvas.drawRRect(_rr(l + w * 0.35, t + 7, w * 0.3, 5, 2.5), _line);
    canvas.drawRRect(_rr(l + 10, t + 24, w - 20, h * 0.26, 8), _accent);
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        _rr(l + 10, t + 34 + h * 0.26 + i * 22, w - 20 - (i * 12), 12, 6),
        _line,
      );
    }
    canvas.drawCircle(Offset(l + w / 2, t + h - 16), 6, _accent);
  }

  void _dashboard(Canvas canvas, Size size) {
    final w = size.width * 0.66;
    final h = size.height * 0.52;
    final l = (size.width - w) / 2;
    final t = size.height * 0.14;
    _windowFrame(canvas, _rr(l, t, w, h, 10));

    // Sidebar.
    canvas.drawRRect(_rr(l + 8, t + 8, w * 0.16, h - 16, 6), _line);
    // Bars.
    final bars = [0.4, 0.7, 0.5, 0.9, 0.6];
    final bw = (w * 0.68 - 4 * 8) / 5;
    for (var i = 0; i < 5; i++) {
      final bh = (h - 56) * bars[i];
      canvas.drawRRect(
        _rr(l + w * 0.24 + i * (bw + 8), t + h - 14 - bh, bw, bh, 4),
        i == 3 ? _accent : _line,
      );
    }
    // Header stat pills.
    canvas.drawRRect(_rr(l + w * 0.24, t + 12, w * 0.22, 14, 7), _accent);
    canvas.drawRRect(_rr(l + w * 0.5, t + 12, w * 0.18, 14, 7), _line);
  }

  @override
  bool shouldRepaint(covariant _CoverArtPainter old) =>
      old.seed != seed || old.palette != palette;
}
