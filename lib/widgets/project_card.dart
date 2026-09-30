import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/project_model.dart';

/// Project card used on the public Projects page (and reusable later for a
/// "My Projects" preview section on Home) — per PORTFOLIO_UI_DESIGN_SPEC.md
/// section "Project card": cover image, title, one-line description, and a
/// small tech-stack row.
class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;

  const ProjectCard({super.key, required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 11,
                child: project.coverImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: project.coverImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _coverFallback(),
                        errorWidget: (_, __, ___) => _coverFallback(),
                      )
                    : _coverFallback(),
              ),
              Padding(
                padding: EdgeInsets.all(18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.title,
                            style: AppTextStyles.h3().copyWith(fontSize: 18.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.north_east_rounded,
                          size: 18.sp,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      project.shortDescription,
                      style: AppTextStyles.body().copyWith(fontSize: 13.5.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.technologies.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Text(
                        project.technologies.join('   '),
                        style: AppTextStyles.small(color: AppColors.primary).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverFallback() {
    return Container(
      color: AppColors.surfaceSoft,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 32.sp),
    );
  }
}
