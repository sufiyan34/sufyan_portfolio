import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';

class ContactPageSkeleton extends StatelessWidget {
  const ContactPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 1000;
          if (!desktop) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IntroSkeleton(),
                SizedBox(height: 24.h),
                _FormSkeleton(),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _IntroSkeleton()),
              SizedBox(width: 28.w),
              Expanded(child: _FormSkeleton()),
            ],
          );
        },
      ),
    );
  }
}

class _IntroSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Bar(width: 115.w, height: 12.h),
        SizedBox(height: 11.h),
        _Bar(width: 240.w, height: 38.h),
        SizedBox(height: 12.h),
        _Bar(width: 410.w, height: 14.h),
        SizedBox(height: 8.h),
        _Bar(width: 340.w, height: 14.h),
        SizedBox(height: 24.h),
        ...List.generate(
          4,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: 17.h),
            child: Row(
              children: [
                _Bar(width: 34.w, height: 34.w, radius: 12),
                SizedBox(width: 11.w),
                Expanded(child: _Bar(width: 190.w, height: 13.h)),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        _Bar(width: 250.w, height: 18.h),
      ],
    );
  }
}

class _FormSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bar(width: 90.w, height: 16.h),
          SizedBox(height: 18.h),
          ...List.generate(
            4,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 13.h),
              child: _Bar(width: double.infinity, height: 48.h, radius: 12),
            ),
          ),
          _Bar(width: double.infinity, height: 108.h, radius: 12),
          SizedBox(height: 18.h),
          _Bar(width: double.infinity, height: 44.h, radius: 999),
        ],
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
