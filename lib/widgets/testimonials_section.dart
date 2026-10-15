import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/testimonial_model.dart';
import 'package:sufyan_portfolio/repositories/testimonial_repository.dart';

/// Public "Kind words from clients" carousel. Self-contained: it loads the
/// published testimonials itself, so it can be dropped into any page.
///
/// Shows nothing while loading, when there are no published testimonials, or
/// if the read fails (a visitor never sees an empty or broken section).
class TestimonialsSection extends StatefulWidget {
  const TestimonialsSection({super.key});

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  // Loaded once per app session so revisiting Home / About doesn't refetch.
  static List<TestimonialModel>? _cache;

  final CarouselSliderController _carousel = CarouselSliderController();
  List<TestimonialModel> _items = const [];
  int _page = 0;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_cache != null) {
      _items = _cache!;
      return;
    }
    try {
      final list = await TestimonialRepository.instance.getPublished();
      // Featured first, then the admin's display order.
      list.sort((a, b) {
        if (a.featured != b.featured) return a.featured ? -1 : 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });
      _cache = list;
      if (mounted) setState(() => _items = list);
    } catch (_) {
      // Stay hidden.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();

    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100 ? 3 : (width >= 720 ? 2 : 1);
    final horizontal = width >= 1100 ? 64.w : 20.w;
    final canSlide = _items.length > columns;
    // One dot per testimonial (the carousel loops through all of them).
    final pageCount = _items.length;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, 56.h, horizontal, 20.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1320.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TESTIMONIALS', style: AppTextStyles.overline()),
                        SizedBox(height: 10.h),
                        Text('Kind words from clients', style: AppTextStyles.h1()),
                        SizedBox(height: 8.h),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 620.w),
                          child: Text(
                            'A few notes from people I’ve built products with.',
                            style: AppTextStyles.body(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (canSlide && width >= 720) ...[
                    _ArrowButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => _carousel.previousPage(
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    _ArrowButton(
                      icon: Icons.arrow_forward_rounded,
                      onTap: () => _carousel.nextPage(
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ],
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: .05, end: 0),
              SizedBox(height: 26.h),
              MouseRegion(
                onEnter: (_) => setState(() => _paused = true),
                onExit: (_) => setState(() => _paused = false),
                child: CarouselSlider.builder(
                  carouselController: _carousel,
                  itemCount: _items.length,
                  itemBuilder: (context, index, _) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9.w),
                    child: _TestimonialCard(item: _items[index]),
                  ),
                  options: CarouselOptions(
                    height: columns == 1 ? 330.h : 300.h,
                    viewportFraction: 1 / columns,
                    padEnds: false,
                    enableInfiniteScroll: canSlide,
                    autoPlay: canSlide && !_paused,
                    autoPlayInterval: const Duration(seconds: 6),
                    autoPlayAnimationDuration: const Duration(milliseconds: 650),
                    autoPlayCurve: Curves.easeOutCubic,
                    onPageChanged: (index, _) =>
                        setState(() => _page = index % pageCount),
                  ),
                ),
              ),
              if (canSlide) ...[
                SizedBox(height: 18.h),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < pageCount; i++)
                        GestureDetector(
                          onTap: () => _carousel.animateToPage(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            width: i == _page ? 26.w : 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: i == _page ? AppColors.primary : AppColors.border,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                    ],
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

class _TestimonialCard extends StatefulWidget {
  final TestimonialModel item;
  const _TestimonialCard({required this.item});

  @override
  State<_TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<_TestimonialCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(top: _hover ? 0 : 6.h, bottom: _hover ? 6.h : 0),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: t.featured ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: t.featured
                ? AppColors.primary
                : (_hover ? AppColors.primary.withValues(alpha: .4) : AppColors.border),
          ),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .16),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ]
              : AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 38.sp,
                  color: AppColors.accentGold,
                ),
                const Spacer(),
                for (var i = 0; i < 5; i++)
                  Icon(
                    i < t.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 18.sp,
                    color: i < t.rating
                        ? AppColors.accentGold
                        : (t.featured ? Colors.white30 : AppColors.border),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: Text(
                t.quote,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(
                  color: t.featured
                      ? Colors.white.withValues(alpha: .9)
                      : AppColors.textSecondary,
                ).copyWith(height: 1.6, fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                _Avatar(url: t.avatarUrl, name: t.clientName, onDark: t.featured),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.clientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium(
                          color: t.featured ? Colors.white : AppColors.textPrimary,
                        ).copyWith(fontSize: 14.sp),
                      ),
                      if (t.roleLine.isNotEmpty)
                        Text(
                          t.roleLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.small(
                            color: t.featured
                                ? Colors.white.withValues(alpha: .65)
                                : AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final String name;
  final bool onDark;
  const _Avatar({required this.url, required this.name, required this.onDark});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final size = 44.w;
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onDark ? Colors.white.withValues(alpha: .14) : AppColors.primarySoft,
      ),
      child: Text(
        _initials,
        style: AppTextStyles.bodyMedium(
          color: onDark ? Colors.white : AppColors.primary,
        ).copyWith(fontSize: 14.sp),
      ),
    );
    if (url.trim().isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (_, child, progress) => progress == null ? child : fallback,
      ),
    );
  }
}

class _ArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowButton({required this.icon, required this.onTap});

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hover ? AppColors.primary : AppColors.surface,
            border: Border.all(color: _hover ? AppColors.primary : AppColors.border),
          ),
          child: Icon(
            widget.icon,
            size: 19.sp,
            color: _hover ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
