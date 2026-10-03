import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/about_controller.dart';
import 'package:sufyan_portfolio/models/about_content_model.dart';
import 'package:sufyan_portfolio/widgets/about_skeletons.dart';
import 'package:sufyan_portfolio/widgets/app_footer.dart';
import 'package:sufyan_portfolio/widgets/public_navbar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AboutController());
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1200;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PublicNavbar(activeRoute: AppRoutes.about),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: controller.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48.w : 20.w,
                  vertical: isDesktop ? 58.h : 36.h,
                ),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const AboutPageSkeleton();
                  }

                  return _AboutContent(controller: controller);
                }),
              ),
              AppFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutContent extends StatelessWidget {
  final AboutController controller;
  const _AboutContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    final content = controller.content.value;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 980;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroIntro(content: content),
        SizedBox(height: 34.h),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: _StoryColumn(content: content)),
              SizedBox(width: 32.w),
              SizedBox(
                width: 420.w,
                child: _PortraitCard(
                  content: content,
                  fallbackImageUrl: controller.fallbackImageUrl,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _PortraitCard(
                content: content,
                fallbackImageUrl: controller.fallbackImageUrl,
              ),
              SizedBox(height: 22.h),
              _StoryColumn(content: content),
            ],
          ),
        SizedBox(height: 34.h),
        _CapabilitiesCard(content: content),
        SizedBox(height: 24.h),
        _BottomCta(),
      ],
    );
  }
}

class _HeroIntro extends StatelessWidget {
  final AboutContentModel content;
  const _HeroIntro({required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content.eyebrow,
          style: AppTextStyles.overline(),
        ).animate().fadeIn(duration: 380.ms),
        SizedBox(height: 10.h),
        Text(content.title, style: AppTextStyles.h1())
            .animate()
            .fadeIn(delay: 70.ms, duration: 420.ms)
            .slideY(begin: .08, end: 0),
        SizedBox(height: 10.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 760.w),
          child: Text(
            content.subtitle,
            style: AppTextStyles.bodyMedium(),
          ).animate().fadeIn(delay: 120.ms, duration: 420.ms),
        ),
      ],
    );
  }
}

class _StoryColumn extends StatelessWidget {
  final AboutContentModel content;
  const _StoryColumn({required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          eyebrow: 'THE STORY',
          title: 'A practical engineer with a product mindset.',
        ),
        SizedBox(height: 13.h),
        Text(content.description, style: AppTextStyles.body()),
        SizedBox(height: 20.h),
        Wrap(
          spacing: 9.w,
          runSpacing: 9.h,
          children: content.traits.map(_TraitPill.new).toList(),
        ),
        SizedBox(height: 28.h),
        _SectionHeading(
          eyebrow: 'MY JOURNEY',
          title: 'Experience that keeps moving.',
        ),
        SizedBox(height: 15.h),
        ...content.journey.asMap().entries.map(
          (entry) => _JourneyItem(
            item: entry.value,
            isLast: entry.key == content.journey.length - 1,
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;

  const _SectionHeading({required this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: AppTextStyles.overline().copyWith(fontSize: 11.sp),
        ),
        SizedBox(height: 7.h),
        Text(title, style: AppTextStyles.h3()),
      ],
    );
  }
}

class _TraitPill extends StatelessWidget {
  final String label;
  const _TraitPill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 15.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.small(color: AppColors.textPrimary)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _JourneyItem extends StatelessWidget {
  final AboutJourneyItem item;
  final bool isLast;

  const _JourneyItem({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22.w,
          child: Column(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: AppColors.background, width: 3),
                ),
              ),
              if (!isLast)
                Container(
                  margin: EdgeInsets.only(top: 3.h),
                  width: 1,
                  height: 62.h,
                  color: AppColors.border,
                ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 19.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.bodyMedium()),
                SizedBox(height: 3.h),
                Text(
                  item.period,
                  style: AppTextStyles.small(color: AppColors.primary)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                if (item.description.isNotEmpty) ...[
                  SizedBox(height: 5.h),
                  Text(item.description, style: AppTextStyles.small()),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PortraitCard extends StatelessWidget {
  final AboutContentModel content;
  final String fallbackImageUrl;

  const _PortraitCard({required this.content, required this.fallbackImageUrl});

  @override
  Widget build(BuildContext context) {
    final imageUrl = content.imageUrl.isNotEmpty
        ? content.imageUrl
        : fallbackImageUrl;

    return Container(
          padding: EdgeInsets.all(13.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.featureShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22.r),
                child: AspectRatio(
                  aspectRatio: .94,
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _imageFallback(),
                          errorWidget: (_, __, ___) => _imageFallback(),
                        )
                      : _imageFallback(),
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Muhammad Sufyan',
                          style: AppTextStyles.h3().copyWith(fontSize: 20.sp),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          content.availabilityLabel,
                          style: AppTextStyles.small(color: AppColors.primary)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  if (content.signature.isNotEmpty)
                    Text(
                      content.signature,
                      style: AppTextStyles.h3(color: AppColors.primary)
                          .copyWith(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 180.ms, duration: 500.ms)
        .slideX(begin: .05, end: 0);
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.surfaceSoft,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_outline_rounded,
        color: AppColors.textMuted,
        size: 58.sp,
      ),
    );
  }
}

class _CapabilitiesCard extends StatelessWidget {
  final AboutContentModel content;
  const _CapabilitiesCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(26.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final split = constraints.maxWidth >= 780;
          final intro = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WHAT I DO', style: AppTextStyles.overline()),
              SizedBox(height: 7.h),
              Text(
                'Technical craft, clear communication.',
                style: AppTextStyles.h3(),
              ),
              SizedBox(height: 8.h),
              Text(
                'I combine implementation detail with a practical product perspective, so the final work is easier to use, maintain, and build on.',
                style: AppTextStyles.body(),
              ),
            ],
          );

          final list = Column(
            children: content.capabilities.map((capability) {
              return Padding(
                padding: EdgeInsets.only(bottom: 11.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      margin: EdgeInsets.only(top: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        capability,
                        style: AppTextStyles.small(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );

          if (!split) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                intro,
                SizedBox(height: 22.h),
                list,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: intro),
              SizedBox(width: 48.w),
              Expanded(child: list),
            ],
          );
        },
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
  }
}

class _BottomCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Let’s build something useful.',
                  style: AppTextStyles.h3(color: AppColors.textOnPrimary)
                      .copyWith(fontSize: 20.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Explore my services or take a look at recent work.',
                  style: AppTextStyles.small(
                    color: AppColors.textOnPrimary.withValues(alpha: .72),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15.w),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.services),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              'View Services',
              style: AppTextStyles.bodyMedium().copyWith(fontSize: 13.sp),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 420.ms, duration: 500.ms);
  }
}
