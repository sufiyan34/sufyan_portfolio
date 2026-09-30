import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';

class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _SkeletonBox({this.width, required this.height, this.radius = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

class SkillsPageSkeleton extends StatelessWidget {
  final bool admin;

  const SkillsPageSkeleton({super.key, this.admin = false});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.surface,
      period: const Duration(milliseconds: 1200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(width: admin ? 300 : 280, height: admin ? 42 : 50),
          SizedBox(height: 10.h),
          _SkeletonBox(width: admin ? 520 : 460, height: 18),
          SizedBox(height: 28.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: List.generate(
              admin ? 5 : 4,
              (_) => _SkeletonBox(width: 86, height: 38, radius: 999),
            ),
          ),
          SizedBox(height: 28.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1180
                  ? 3
                  : constraints.maxWidth >= 760
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: admin ? 6 : 6,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 18.w,
                  mainAxisSpacing: 18.h,
                  childAspectRatio: admin ? 1.38 : 1.55,
                ),
                itemBuilder: (_, __) => Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const _SkeletonBox(width: 46, height: 46, radius: 14),
                          SizedBox(width: 12.w),
                          const Expanded(
                            child: _SkeletonBox(height: 18, radius: 7),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      const _SkeletonBox(height: 12, radius: 6),
                      SizedBox(height: 9.h),
                      const _SkeletonBox(height: 12, radius: 6),
                      const Spacer(),
                      const _SkeletonBox(height: 5, radius: 999),
                      SizedBox(height: 12.h),
                      const _SkeletonBox(width: 86, height: 12, radius: 6),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
