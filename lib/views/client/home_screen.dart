import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/controllers/home_controller.dart';
import 'package:sufyan_portfolio/widgets/hero_section.dart';
import 'package:sufyan_portfolio/widgets/home_section_previews.dart';
import 'package:sufyan_portfolio/widgets/public_navbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PublicNavbar(
        activeRoute: AppRoutes.home,
        onLetsTalk: () => Get.toNamed(AppRoutes.hireUs),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: controller.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const HeroSection(),
              const HomeSectionPreviews(),
              SizedBox(height: 18.h),
            ],
          ),
        ),
      ),
    );
  }
}
