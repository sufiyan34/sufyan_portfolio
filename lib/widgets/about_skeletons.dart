import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';

class AboutPageSkeleton extends StatelessWidget {
  const AboutPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bar(width: 115.w, height: 12.h),
          SizedBox(height: 12.h),
          _Bar(width: 230.w, height: 38.h),
          SizedBox(height: 12.h),
          _Bar(width: 560.w, height: 14.h),
          SizedBox(height: 8.h),
          _Bar(width: 470.w, height: 14.h),
          SizedBox(height: 26.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 900;
              if (!twoColumns) {
                return Column(
                  children: [
                    _ImageSkeleton(height: 310.h),
                    SizedBox(height: 18.h),
                    _BodySkeleton(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _BodySkeleton()),
                  SizedBox(width: 30.w),
                  SizedBox(width: 420.w, child: _ImageSkeleton(height: 390.h)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BodySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Bar(width: double.infinity, height: 15.h),
        SizedBox(height: 8.h),
        _Bar(width: double.infinity, height: 15.h),
        SizedBox(height: 8.h),
        _Bar(width: 420.w, height: 15.h),
        SizedBox(height: 22.h),
        Wrap(
          spacing: 9.w,
          runSpacing: 9.h,
          children: List.generate(
            4,
            (_) => _Bar(width: 92.w, height: 34.h, radius: 999),
          ),
        ),
        SizedBox(height: 28.h),
        _Bar(width: 130.w, height: 22.h),
        SizedBox(height: 18.h),
        ...List.generate(
          4,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: 15.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bar(width: 12.w, height: 12.w, radius: 999),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bar(width: 210.w, height: 15.h),
                      SizedBox(height: 7.h),
                      _Bar(width: double.infinity, height: 12.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageSkeleton extends StatelessWidget {
  final double height;
  const _ImageSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
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
