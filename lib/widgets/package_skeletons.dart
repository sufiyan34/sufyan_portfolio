import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';

class PackagesPageSkeleton extends StatelessWidget {
  const PackagesPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bar(width: 150.w, height: 13.h),
          SizedBox(height: 12.h),
          _Bar(width: 360.w, height: 34.h),
          SizedBox(height: 12.h),
          _Bar(width: 620.w, height: 15.h),
          SizedBox(height: 9.h),
          _Bar(width: 520.w, height: 15.h),
          SizedBox(height: 24.h),
          Wrap(
            spacing: 9.w,
            runSpacing: 9.h,
            children: List.generate(
              4,
              (_) => _Bar(width: 84.w, height: 36.h, radius: 999),
            ),
          ),
          SizedBox(height: 30.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1180
                  ? 4
                  : constraints.maxWidth >= 760
                      ? 2
                      : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: columns == 1 ? 2 : 4,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 18.w,
                  mainAxisSpacing: 18.h,
                  childAspectRatio: columns == 1 ? 0.92 : 0.64,
                ),
                itemBuilder: (_, __) => const _PackageSkeletonCard(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PackageManagementSkeleton extends StatelessWidget {
  const PackageManagementSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: _Bar(width: 240, height: 28)),
              SizedBox(width: 16.w),
              _Bar(width: 130.w, height: 42.h, radius: 999),
            ],
          ),
          SizedBox(height: 18.h),
          _Bar(width: double.infinity, height: 72.h, radius: 18),
          SizedBox(height: 18.h),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1120
                    ? 3
                    : constraints.maxWidth >= 720
                        ? 2
                        : 1;
                return GridView.builder(
                  itemCount: 6,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 18.w,
                    mainAxisSpacing: 18.h,
                    childAspectRatio: columns == 1 ? 1.18 : 0.96,
                  ),
                  itemBuilder: (_, __) => const _PackageSkeletonCard(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageSkeletonCard extends StatelessWidget {
  const _PackageSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bar(width: 84.w, height: 12.h),
          SizedBox(height: 12.h),
          _Bar(width: 150.w, height: 25.h),
          SizedBox(height: 12.h),
          _Bar(width: 95.w, height: 32.h),
          SizedBox(height: 14.h),
          _Bar(width: double.infinity, height: 14.h),
          SizedBox(height: 8.h),
          _Bar(width: 165.w, height: 14.h),
          SizedBox(height: 18.h),
          ...List.generate(
            4,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _Bar(width: double.infinity, height: 13.h),
            ),
          ),
          const Spacer(),
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
