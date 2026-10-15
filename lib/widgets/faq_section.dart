import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';

/// One question / answer pair.
class FaqItem {
  final String question;
  final String answer;
  const FaqItem(this.question, this.answer);
}

/// ✏️ EDIT YOUR FAQ HERE. Add, remove or reword entries; the section updates
/// automatically. Replace the placeholder answers with your real terms.
const List<FaqItem> kFaqItems = [
  FaqItem(
    'How does pricing work?',
    'Each package has a clear scope and price. For anything outside a package I send a fixed quote after we talk through the project, so there are no surprise bills. The quote covers design, development, testing and handover.',
  ),
  FaqItem(
    'How long does a project take?',
    'A focused app or website usually takes 2 to 6 weeks, depending on scope and how quickly feedback comes back. I share a realistic timeline in the quote and update you at every milestone.',
  ),
  FaqItem(
    'How many revisions are included?',
    'Every package includes revision rounds at the design stage and after the first working build. Small tweaks are always welcome; larger changes of direction are quoted separately so the schedule stays honest.',
  ),
  FaqItem(
    'What do you need from me to get started?',
    'A short brief is enough: what you want to build, who it’s for, and any references you like. You can send it through the Hire Me form, or book a free consultation if you’d rather talk it through first.',
  ),
  FaqItem(
    'Which technologies do you work with?',
    'I build cross-platform apps and web apps with Flutter, backed by Firebase and REST APIs. If your project needs something specific, tell me and I’ll say honestly whether it’s a good fit.',
  ),
  FaqItem(
    'Do you offer support after launch?',
    'Yes. Launch isn’t the end: I offer maintenance and support plans for fixes, updates and new features, and I’m happy to hand over source code and documentation if you’d rather take it in-house.',
  ),
  FaqItem(
    'How do payments and communication work?',
    'Work is split into milestones, so you pay as you see progress. We keep in touch over email or your preferred chat app, and you always know what’s being built next.',
  ),
];

/// Animated accordion FAQ. Only one answer is open at a time.
class FaqSection extends StatefulWidget {
  final List<FaqItem> items;
  const FaqSection({super.key, this.items = kFaqItems});

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  int? _open = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;

        final intro = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FAQ', style: AppTextStyles.overline()),
            SizedBox(height: 10.h),
            Text('Questions, answered', style: AppTextStyles.h1()),
            SizedBox(height: 10.h),
            Text(
              'The things people usually ask before we start. Can’t find yours? Just ask.',
              style: AppTextStyles.body(),
            ),
            SizedBox(height: 20.h),
            _AskButton(onTap: () => Get.toNamed(AppRoutes.contactUs)),
          ],
        );

        final list = Column(
          children: [
            for (var i = 0; i < widget.items.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _FaqTile(
                  item: widget.items[i],
                  open: _open == i,
                  onTap: () => setState(() => _open = _open == i ? null : i),
                )
                    .animate()
                    .fadeIn(delay: (60 * i).ms, duration: 350.ms)
                    .slideY(begin: .06, end: 0, delay: (60 * i).ms),
              ),
          ],
        );

        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [intro, SizedBox(height: 24.h), list],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 340.w, child: intro),
            SizedBox(width: 48.w),
            Expanded(child: list),
          ],
        );
      },
    );
  }
}

class _FaqTile extends StatefulWidget {
  final FaqItem item;
  final bool open;
  final VoidCallback onTap;
  const _FaqTile({required this.item, required this.open, required this.onTap});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final open = widget.open;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: open
                  ? AppColors.primary.withValues(alpha: .45)
                  : (_hover ? AppColors.primary.withValues(alpha: .25) : AppColors.border),
            ),
            boxShadow: open ? AppColors.cardShadow : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: AppTextStyles.bodyMedium(
                        color: open ? AppColors.primary : AppColors.textPrimary,
                      ).copyWith(fontSize: 15.sp),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: open ? AppColors.primary : AppColors.primarySoft,
                    ),
                    child: AnimatedRotation(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      turns: open ? .125 : 0, // + rotates into an ×
                      child: Icon(
                        Icons.add_rounded,
                        size: 19.sp,
                        color: open ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: open
                    ? Padding(
                        padding: EdgeInsets.only(top: 12.h, right: 44.w),
                        child: Text(
                          widget.item.answer,
                          style: AppTextStyles.body().copyWith(height: 1.65),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AskButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AskButton({required this.onTap});

  @override
  State<_AskButton> createState() => _AskButtonState();
}

class _AskButtonState extends State<_AskButton> {
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
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: _hover ? AppColors.primary : AppColors.primarySoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ask a question',
                style: AppTextStyles.bodyMedium(
                  color: _hover ? Colors.white : AppColors.primary,
                ).copyWith(fontSize: 13.5.sp),
              ),
              AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                offset: Offset(_hover ? .25 : 0, 0),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 17.sp,
                  color: _hover ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
