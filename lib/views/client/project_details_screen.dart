import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/project_details_controller.dart';
import 'package:sufyan_portfolio/models/project_model.dart';
import 'package:sufyan_portfolio/widgets/project_details_skeletons.dart';
import 'package:sufyan_portfolio/widgets/public_navbar.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProjectDetailsController());
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1180;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PublicNavbar(activeRoute: AppRoutes.projects),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: controller.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48.w : 20.w,
              vertical: isDesktop ? 54.h : 34.h,
            ),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const ProjectDetailsSkeleton();
              }

              final project = controller.project.value;
              if (project == null) {
                return _NotFoundState(message: controller.errorMessage.value);
              }

              return _ProjectDetailsContent(project: project);
            }),
          ),
        ),
      ),
    );
  }
}

class _ProjectDetailsContent extends StatelessWidget {
  final ProjectModel project;
  const _ProjectDetailsContent({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProjectHero(project: project),
        if (project.fullDescription.isNotEmpty) ...[
          SizedBox(height: 34.h),
          _TextSection(
            eyebrow: 'PROJECT OVERVIEW',
            title: 'Built with clarity from idea to interface.',
            body: project.fullDescription,
          ),
        ],
        if (project.features.isNotEmpty) ...[
          SizedBox(height: 30.h),
          _FeatureSection(features: project.features),
        ],
        if (project.challenge.isNotEmpty ||
            project.solution.isNotEmpty ||
            project.results.isNotEmpty) ...[
          SizedBox(height: 30.h),
          _CaseStudySections(project: project),
        ],
        if (project.gallery.isNotEmpty) ...[
          SizedBox(height: 30.h),
          _GallerySection(project: project),
        ],
        SizedBox(height: 26.h),
        _ProjectCta(project: project),
      ],
    );
  }
}

class _ProjectHero extends StatelessWidget {
  final ProjectModel project;
  const _ProjectHero({required this.project});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 980;
        final copy = _HeroCopy(project: project);
        final visual = _HeroImage(project: project);

        if (!desktop) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [copy, SizedBox(height: 20.h), visual],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: copy),
            SizedBox(width: 32.w),
            Expanded(flex: 6, child: visual),
          ],
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  final ProjectModel project;
  const _HeroCopy({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CASE STUDY', style: AppTextStyles.overline())
            .animate()
            .fadeIn(duration: 350.ms),
        SizedBox(height: 9.h),
        Text(project.title, style: AppTextStyles.h1())
            .animate()
            .fadeIn(delay: 60.ms, duration: 450.ms)
            .slideY(begin: .06, end: 0),
        SizedBox(height: 10.h),
        Text(project.shortDescription, style: AppTextStyles.body()),
        SizedBox(height: 19.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: project.technologies.map(_TechPill.new).toList(),
        ),
        SizedBox(height: 22.h),
        Wrap(
          spacing: 9.w,
          runSpacing: 9.h,
          children: [
            if (project.year > 0)
              _MetaPill(label: 'Year', value: project.year.toString()),
            if (project.role.isNotEmpty)
              _MetaPill(label: 'Role', value: project.role),
            if (project.clientName.isNotEmpty)
              _MetaPill(label: 'Client', value: project.clientName),
          ],
        ),
        SizedBox(height: 23.h),
        Row(
          children: [
            if (project.liveUrl.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _launch(project.liveUrl),
                icon: Icon(Icons.open_in_new_rounded, size: 16.sp),
                label: Text('Live Demo', style: AppTextStyles.bodyMedium(color: AppColors.textOnPrimary).copyWith(fontSize: 13.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
              ),
            if (project.liveUrl.isNotEmpty && project.githubUrl.isNotEmpty)
              SizedBox(width: 9.w),
            if (project.githubUrl.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => _launch(project.githubUrl),
                icon: Icon(Icons.code_rounded, size: 16.sp),
                label: Text('GitHub', style: AppTextStyles.bodyMedium(color: AppColors.primary).copyWith(fontSize: 13.sp)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.border),
                  padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  final ProjectModel project;
  const _HeroImage({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.featureShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23.r),
        child: AspectRatio(
          aspectRatio: 1.28,
          child: project.coverImageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: project.coverImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _fallback(),
                  errorWidget: (_, __, ___) => _fallback(),
                )
              : _fallback(),
        ),
      ),
    ).animate().fadeIn(delay: 140.ms, duration: 520.ms).slideX(begin: .04, end: 0);
  }

  Widget _fallback() {
    return Container(
      color: AppColors.surfaceSoft,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 48.sp),
    );
  }
}

class _TechPill extends StatelessWidget {
  final String label;
  const _TechPill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.small(color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;
  final String value;
  const _MetaPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: AppColors.border),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$label  ', style: AppTextStyles.small(color: AppColors.textMuted)),
            TextSpan(text: value, style: AppTextStyles.small(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String body;
  const _TextSection({required this.eyebrow, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(26.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow, style: AppTextStyles.overline()),
          SizedBox(height: 8.h),
          Text(title, style: AppTextStyles.h3()),
          SizedBox(height: 10.h),
          Text(body, style: AppTextStyles.body()),
        ],
      ),
    ).animate().fadeIn(delay: 220.ms, duration: 450.ms);
  }
}

class _FeatureSection extends StatelessWidget {
  final List<String> features;
  const _FeatureSection({required this.features});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(26.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('KEY FEATURES', style: AppTextStyles.overline()),
          SizedBox(height: 13.h),
          Wrap(
            spacing: 18.w,
            runSpacing: 15.h,
            children: features.map((feature) {
              return SizedBox(
                width: 320.w,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 18.sp, color: AppColors.primary),
                    SizedBox(width: 9.w),
                    Expanded(child: Text(feature, style: AppTextStyles.small(color: AppColors.textPrimary))),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 270.ms, duration: 450.ms);
  }
}

class _CaseStudySections extends StatelessWidget {
  final ProjectModel project;
  const _CaseStudySections({required this.project});

  @override
  Widget build(BuildContext context) {
    final items = <_CaseItem>[
      if (project.challenge.isNotEmpty) _CaseItem('THE CHALLENGE', project.challenge),
      if (project.solution.isNotEmpty) _CaseItem('THE SOLUTION', project.solution),
      if (project.results.isNotEmpty) _CaseItem('THE RESULT', project.results),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 520.w,
        crossAxisSpacing: 18.w,
        mainAxisSpacing: 18.h,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: EdgeInsets.all(22.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.eyebrow, style: AppTextStyles.overline()),
              SizedBox(height: 12.h),
              Expanded(child: Text(item.body, style: AppTextStyles.body())),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 300 + (70 * index)), duration: 450.ms);
      },
    );
  }
}

class _CaseItem {
  final String eyebrow;
  final String body;
  const _CaseItem(this.eyebrow, this.body);
}

class _GallerySection extends StatelessWidget {
  final ProjectModel project;
  const _GallerySection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SCREENSHOTS', style: AppTextStyles.overline()),
        SizedBox(height: 13.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: project.gallery.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 360.w,
            crossAxisSpacing: 15.w,
            mainAxisSpacing: 15.h,
            childAspectRatio: 1.18,
          ),
          itemBuilder: (context, index) {
            final url = project.gallery[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: url.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _galleryFallback(),
                      errorWidget: (_, __, ___) => _galleryFallback(),
                    )
                  : _galleryFallback(),
            ).animate().fadeIn(delay: Duration(milliseconds: 70 * index), duration: 400.ms);
          },
        ),
      ],
    );
  }

  Widget _galleryFallback() {
    return Container(
      color: AppColors.surfaceSoft,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 30.sp),
    );
  }
}

class _ProjectCta extends StatelessWidget {
  final ProjectModel project;
  const _ProjectCta({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 19.h),
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
                  'Have a project in mind?',
                  style: AppTextStyles.h3(color: AppColors.textOnPrimary).copyWith(fontSize: 19.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Let’s talk about what you’re building next.',
                  style: AppTextStyles.small(color: AppColors.textOnPrimary.withValues(alpha: .72)),
                ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          OutlinedButton(
            onPressed: () => Get.toNamed(AppRoutes.packages),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textOnPrimary,
              side: BorderSide(color: AppColors.textOnPrimary.withValues(alpha: .38)),
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text('View Packages', style: AppTextStyles.bodyMedium(color: AppColors.textOnPrimary).copyWith(fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  final String message;
  const _NotFoundState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 110.h),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_rounded, size: 50.sp, color: AppColors.textMuted),
            SizedBox(height: 14.h),
            Text('Project unavailable', style: AppTextStyles.h3()),
            SizedBox(height: 7.h),
            Text(
              message.isEmpty ? 'This project could not be found.' : message,
              style: AppTextStyles.body(),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18.h),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.projects),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text('Back to Projects', style: AppTextStyles.bodyMedium(color: AppColors.textOnPrimary).copyWith(fontSize: 13.sp)),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _launch(String rawUrl) async {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.platformDefault);
}
