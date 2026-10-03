import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/experience_controller.dart';
import 'package:sufyan_portfolio/widgets/app_footer.dart';
import 'package:sufyan_portfolio/widgets/experience_card.dart';
import 'package:sufyan_portfolio/widgets/experience_skeletons.dart';
import 'package:sufyan_portfolio/widgets/public_navbar.dart';

class ExperienceScreen extends StatelessWidget {
  const ExperienceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExperienceController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PublicNavbar(activeRoute: AppRoutes.experience),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.loadExperiences,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _PageIntro()),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 42.h),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 1120.w),
                          child: Obx(() {
                            if (controller.isLoading.value) {
                              return const ExperienceClientSkeleton();
                            }

                            if (controller.experiences.isEmpty) {
                              return const _EmptyExperienceState();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _TimelineIntro(
                                  count: controller.experiences.length,
                                ),
                                SizedBox(height: 24.h),
                                ...controller.experiences.asMap().entries.map(
                                  (entry) => ExperienceTimelineCard(
                                    key: ValueKey(entry.value.id),
                                    experience: entry.value,
                                    isLast:
                                        entry.key ==
                                        controller.experiences.length - 1,
                                    index: entry.key,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                      AppFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1120.w),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 48.h, 20.w, 36.h),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      'MY EXPERIENCE',
                      style: AppTextStyles.overline(color: AppColors.primary)
                          .copyWith(fontSize: 11.sp),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'A timeline of the work\nand systems I have built.',
                    style: AppTextStyles.h1().copyWith(
                      fontSize: compact ? 40.sp : 54.sp,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 700.w),
                    child: Text(
                      'From product interfaces and mobile apps to backend integrations, '
                      'each role has sharpened the way I think about reliable, scalable software.',
                      style: AppTextStyles.body().copyWith(fontSize: 15.sp),
                    ),
                  ),
                ],
              );

              if (compact) return content;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: content),
                  SizedBox(width: 40.w),
                  _IntroAside(),
                ],
              );
            },
          ),
        ),
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.03, end: 0),
    );
  }
}

class _IntroAside extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 245.w,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accentGoldSoft,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.auto_awesome_outlined,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Built with intent',
                style: AppTextStyles.bodyMedium().copyWith(fontSize: 13.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Clean architecture. Practical UI. Measurable product thinking.',
            style: AppTextStyles.small(color: AppColors.textSecondary)
                .copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _TimelineIntro extends StatelessWidget {
  final int count;
  const _TimelineIntro({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Journey',
                style: AppTextStyles.h2().copyWith(fontSize: 31.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                'Experience and growth, one chapter at a time.',
                style: AppTextStyles.body().copyWith(fontSize: 14.sp),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '$count ${count == 1 ? 'entry' : 'entries'}',
            style: AppTextStyles.small(color: AppColors.primary)
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _EmptyExperienceState extends StatelessWidget {
  const _EmptyExperienceState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 56.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62.w,
            height: 62.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Icon(
              Icons.timeline_rounded,
              color: AppColors.primary,
              size: 28.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text('Experience is being prepared', style: AppTextStyles.h3()),
          SizedBox(height: 6.h),
          Text(
            'Your public timeline will appear here once entries are published.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(),
          ),
        ],
      ),
    );
  }
}
