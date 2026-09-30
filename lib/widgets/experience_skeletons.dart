import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';

class ExperienceClientSkeleton extends StatelessWidget {
  const ExperienceClientSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: _PublicSkeletonCard(index: index),
        ),
      ),
    );
  }
}

class ExperienceAdminSkeleton extends StatelessWidget {
  const ExperienceAdminSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 820;
        return GridView.builder(
          padding: EdgeInsets.only(bottom: 30.h),
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: compact ? 620.w : 430.w,
            mainAxisSpacing: 18.h,
            crossAxisSpacing: 18.w,
            childAspectRatio: compact ? 1.25 : 1.08,
          ),
          itemBuilder: (_, index) => _AdminSkeletonCard(index: index),
        );
      },
    );
  }
}

class _PublicSkeletonCard extends StatelessWidget {
  final int index;
  const _PublicSkeletonCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.surface,
      period: const Duration(milliseconds: 1300),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 66.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                if (index < 2)
                  Container(
                    margin: EdgeInsets.only(top: 7.h),
                    width: 1.5.w,
                    height: 190.h,
                    color: Colors.white,
                  ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(22.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(width: 90.w, height: 12.h),
                  SizedBox(height: 10.h),
                  _bar(width: 250.w, height: 22.h),
                  SizedBox(height: 10.h),
                  _bar(width: 170.w, height: 14.h),
                  SizedBox(height: 18.h),
                  _bar(width: double.infinity, height: 11.h),
                  SizedBox(height: 8.h),
                  _bar(width: double.infinity, height: 11.h),
                  SizedBox(height: 8.h),
                  _bar(width: 220.w, height: 11.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSkeletonCard extends StatelessWidget {
  final int index;
  const _AdminSkeletonCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.surface,
      period: const Duration(milliseconds: 1300),
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(child: _bar(width: double.infinity, height: 17.h)),
              ],
            ),
            SizedBox(height: 18.h),
            _bar(width: 160.w, height: 12.h),
            SizedBox(height: 10.h),
            _bar(width: double.infinity, height: 11.h),
            SizedBox(height: 8.h),
            _bar(width: double.infinity, height: 11.h),
            SizedBox(height: 8.h),
            _bar(width: 210.w, height: 11.h),
            const Spacer(),
            Row(
              children: [
                _bar(width: 70.w, height: 28.h),
                const Spacer(),
                _bar(width: 88.w, height: 30.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _bar({required double width, required double height}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999.r),
    ),
  );
}
