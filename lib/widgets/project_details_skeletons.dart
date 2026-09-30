import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';

class ProjectDetailsSkeleton extends StatelessWidget {
  const ProjectDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 980;
              final visual = _ImageSkeleton();
              final copy = _CopySkeleton();
              if (!desktop) {
                return Column(
                  children: [visual, SizedBox(height: 22.h), copy],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: copy),
                  SizedBox(width: 30.w),
                  Expanded(flex: 6, child: visual),
                ],
              );
            },
          ),
          SizedBox(height: 30.h),
          _Bar(width: 170.w, height: 23.h),
          SizedBox(height: 12.h),
          ...List.generate(
            4,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 9.h),
              child: _Bar(width: double.infinity, height: 14.h),
            ),
          ),
          SizedBox(height: 24.h),
          _Bar(width: 180.w, height: 23.h),
          SizedBox(height: 18.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14.w,
              mainAxisSpacing: 14.h,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (_, __) => Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CopySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Bar(width: 92.w, height: 12.h),
        SizedBox(height: 12.h),
        _Bar(width: 300.w, height: 38.h),
        SizedBox(height: 12.h),
        _Bar(width: 380.w, height: 13.h),
        SizedBox(height: 8.h),
        _Bar(width: 320.w, height: 13.h),
        SizedBox(height: 18.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: List.generate(4, (_) => _Bar(width: 80.w, height: 31.h, radius: 999)),
        ),
        SizedBox(height: 22.h),
        _Bar(width: 160.w, height: 15.h),
        SizedBox(height: 10.h),
        _Bar(width: 200.w, height: 15.h),
      ],
    );
  }
}

class _ImageSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(28.r),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _Bar({required this.width, required this.height, this.radius = 7});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}
