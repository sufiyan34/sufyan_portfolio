import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/controllers/admin/admin_auth_controller.dart';
import 'package:sufyan_portfolio/controllers/admin/hire_request_details_controller.dart';
import 'package:sufyan_portfolio/controllers/admin/admin_route_middleware.dart';
import 'package:sufyan_portfolio/controllers/hire_request_controller.dart';
import 'package:sufyan_portfolio/splash_screen.dart';
import 'package:sufyan_portfolio/views/admin/access_denied_screen.dart';
import 'package:sufyan_portfolio/views/admin/admin_placeholder_screen.dart';
import 'package:sufyan_portfolio/views/admin/admin_dashboard_screen.dart';
import 'package:sufyan_portfolio/views/admin/experience_management_screen.dart';
import 'package:sufyan_portfolio/views/admin/hire_request_details_screen.dart';
import 'package:sufyan_portfolio/views/admin/hire_request_management_screen.dart';
import 'package:sufyan_portfolio/views/admin/login_screen.dart';
import 'package:sufyan_portfolio/views/admin/package_management_screen.dart';
import 'package:sufyan_portfolio/views/admin/project_management_screen.dart';
import 'package:sufyan_portfolio/views/admin/service_management_screen.dart';
import 'package:sufyan_portfolio/views/admin/sign_up_screen.dart';
import 'package:sufyan_portfolio/views/admin/skill_management_screen.dart';
import 'package:sufyan_portfolio/views/client/about_screen.dart';
import 'package:sufyan_portfolio/views/client/contact_screen.dart';
import 'package:sufyan_portfolio/views/client/experience_screen.dart';
import 'package:sufyan_portfolio/views/client/home_screen.dart';
import 'package:sufyan_portfolio/views/client/hire_us_screen.dart';
import 'package:sufyan_portfolio/views/client/request_success_screen.dart';
import 'package:sufyan_portfolio/views/client/packages_screen.dart';
import 'package:sufyan_portfolio/views/client/project_details_screen.dart';
import 'package:sufyan_portfolio/views/client/projects_screen.dart';
import 'package:sufyan_portfolio/views/client/services_screen.dart';
import 'package:sufyan_portfolio/views/client/skills_screen.dart';

class GetAppRoutes {
  GetAppRoutes._();

  static final pages = [
    // -----------------------------------------------------------------------
    // GENERAL
    // -----------------------------------------------------------------------
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(
      name: AppRoutes.login,
      page: () => const AdminLoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminAuthController>(
          () => AdminAuthController(),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.signUP,
      page: () => const AdminSignUpScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminAuthController>(
          () => AdminAuthController(),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.accessDeniedScreen,
      page: () => const AccessDeniedScreen(),
    ),

    // -----------------------------------------------------------------------
    // PUBLIC / CLIENT
    // -----------------------------------------------------------------------
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.about, page: () => const AboutScreen()),
    GetPage(name: AppRoutes.services, page: () => const ServicesScreen()),
    GetPage(name: AppRoutes.skills, page: () => const SkillsScreen()),
    GetPage(name: AppRoutes.experience, page: () => const ExperienceScreen()),
    GetPage(name: AppRoutes.projects, page: () => const ProjectsScreen()),
    GetPage(
      name: AppRoutes.projectDetails,
      page: () => const ProjectDetailsScreen(),
    ),
    GetPage(name: AppRoutes.packages, page: () => const PackagesScreen()),
    GetPage(
      name: AppRoutes.hireUs,
      page: () => const HireUsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HireRequestController>(
          () => HireRequestController(),
          fenix: false,
        );
      }),
    ),
    GetPage(
      name: AppRoutes.requestSuccess,
      page: () => const RequestSuccessScreen(),
    ),
    GetPage(name: AppRoutes.contactUs, page: () => const ContactScreen()),

    // -----------------------------------------------------------------------
    // ADMIN — existing modules + new auth/dashboard
    // -----------------------------------------------------------------------
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardScreen(),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.projectManagement,
      page: () => ProjectManagementScreen(),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.serviceManagement,
      page: () => const ServiceManagementScreen(),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.skillManagement,
      page: () => const SkillManagementScreen(),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.experienceManagement,
      page: () => const ExperienceManagementScreen(),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.packageManagement,
      page: () => const PackageManagementScreen(),
      middlewares: [AdminRouteMiddleware()],
    ),

    // -----------------------------------------------------------------------
    // ADMIN PLACEHOLDERS — keeps the shell navigable until these modules are built.
    // -----------------------------------------------------------------------
    GetPage(
      name: AppRoutes.siteManagement,
      page: () => const AdminPlaceholderScreen(
        title: 'Site Management',
        description: 'Edit global portfolio information, branding and public-site configuration from one place.',
        icon: Iconsax.setting_2,
      ),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.testimonialManagement,
      page: () => const AdminPlaceholderScreen(
        title: 'Testimonials',
        description: 'Manage client testimonials, publishing state and presentation order.',
        icon: Iconsax.message_favorite,
      ),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.mediaManagement,
      page: () => const AdminPlaceholderScreen(
        title: 'Media Management',
        description: 'Organize portfolio media and Cloudinary-backed assets from the admin workspace.',
        icon: Iconsax.gallery,
      ),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.hireRequestManagement,
      page: () => const HireRequestManagementScreen(),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.hireRequestDetails,
      page: () => const HireRequestDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HireRequestDetailsController>(
          () => HireRequestDetailsController(),
          fenix: false,
        );
      }),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.consultationManagement,
      page: () => const AdminPlaceholderScreen(
        title: 'Consultations',
        description: 'Review consultation enquiries and keep upcoming client conversations organized.',
        icon: Iconsax.calendar,
      ),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.contactMessageManagement,
      page: () => const AdminPlaceholderScreen(
        title: 'Contact Messages',
        description: 'Your public contact inbox will live here, with read state and follow-up actions.',
        icon: Iconsax.sms,
      ),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminProfile,
      page: () => const AdminPlaceholderScreen(
        title: 'Profile & Settings',
        description: 'Manage administrator profile details and workspace preferences here.',
        icon: Iconsax.profile_2user,
      ),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage(
      name: AppRoutes.adminSettings,
      page: () => const AdminPlaceholderScreen(
        title: 'Admin Settings',
        description: 'Workspace settings and administrative configuration will be managed here.',
        icon: Iconsax.setting_2,
      ),
      middlewares: [AdminRouteMiddleware()],
    ),
  ];
}
