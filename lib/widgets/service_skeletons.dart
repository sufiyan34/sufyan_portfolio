import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';

class ServiceSkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const ServiceSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceSoft,
      highlightColor: AppColors.surface,
      child: Container(
        width: width,
        height: height.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(radius.r),
        ),
      ),
    );
  }
}

class ServicesPageSkeleton extends StatelessWidget {
  final bool admin;

  const ServicesPageSkeleton({super.key, this.admin = false});

  @override
  Widget build(BuildContext context) {
    if (admin) return const _AdminServicesSkeleton();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(30.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ServiceSkeletonBox(width: 110, height: 13),
              SizedBox(height: 12),
              ServiceSkeletonBox(width: 310, height: 45),
              SizedBox(height: 12),
              ServiceSkeletonBox(width: 610, height: 18),
              SizedBox(height: 8),
              ServiceSkeletonBox(width: 540, height: 18),
            ],
          ),
        ),
        SizedBox(height: 22.h),
        Wrap(
          spacing: 9.w,
          runSpacing: 9.h,
          children: const [
            ServiceSkeletonBox(width: 56, height: 34, radius: 999),
            ServiceSkeletonBox(width: 115, height: 34, radius: 999),
            ServiceSkeletonBox(width: 132, height: 34, radius: 999),
            ServiceSkeletonBox(width: 95, height: 34, radius: 999),
          ],
        ),
        SizedBox(height: 28.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1120
                ? 3
                : constraints.maxWidth >= 700
                ? 2
                : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 18.w,
                mainAxisSpacing: 18.h,
                childAspectRatio: columns == 1 ? 1.45 : 1.15,
              ),
              itemBuilder: (_, __) => const _ServiceCardSkeleton(),
            );
          },
        ),
      ],
    );
  }
}

class _ServiceCardSkeleton extends StatelessWidget {
  const _ServiceCardSkeleton();

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
        children: const [
          ServiceSkeletonBox(width: 52, height: 52, radius: 16),
          SizedBox(height: 18),
          ServiceSkeletonBox(width: 90, height: 12),
          SizedBox(height: 10),
          ServiceSkeletonBox(width: 190, height: 28),
          SizedBox(height: 12),
          ServiceSkeletonBox(width: double.infinity, height: 16),
          SizedBox(height: 8),
          ServiceSkeletonBox(width: 225, height: 16),
          SizedBox(height: 18),
          ServiceSkeletonBox(width: 150, height: 14),
          SizedBox(height: 10),
          ServiceSkeletonBox(width: 175, height: 14),
          SizedBox(height: 10),
          ServiceSkeletonBox(width: 132, height: 14),
        ],
      ),
    );
  }
}

class _AdminServicesSkeleton extends StatelessWidget {
  const _AdminServicesSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: const [
              Expanded(child: ServiceSkeletonBox(height: 42, radius: 13)),
              SizedBox(width: 14),
              Expanded(child: ServiceSkeletonBox(height: 34, radius: 999)),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Expanded(
          child: GridView.builder(
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width >= 1180
                  ? 3
                  : MediaQuery.of(context).size.width >= 780
                  ? 2
                  : 1,
              crossAxisSpacing: 18.w,
              mainAxisSpacing: 18.h,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (_, __) => const _AdminCardSkeleton(),
          ),
        ),
      ],
    );
  }
}

class _AdminCardSkeleton extends StatelessWidget {
  const _AdminCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              ServiceSkeletonBox(width: 48, height: 48, radius: 14),
              Spacer(),
              ServiceSkeletonBox(width: 62, height: 28, radius: 999),
            ],
          ),
          SizedBox(height: 16),
          ServiceSkeletonBox(width: 90, height: 12),
          SizedBox(height: 10),
          ServiceSkeletonBox(width: 200, height: 26),
          SizedBox(height: 9),
          ServiceSkeletonBox(width: double.infinity, height: 16),
          SizedBox(height: 8),
          ServiceSkeletonBox(width: 220, height: 16),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: ServiceSkeletonBox(height: 36, radius: 999)),
              SizedBox(width: 9),
              Expanded(child: ServiceSkeletonBox(height: 36, radius: 999)),
            ],
          ),
        ],
      ),
    );
  }
}
