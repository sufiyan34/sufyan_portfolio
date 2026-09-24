import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/splash_screen.dart';
import 'package:sufyan_portfolio/views/client/home_screen.dart';

class GetAppRoutes {
  GetAppRoutes._();

  // ===========================================================================
  // CUSTOMER ROUTES
  // ===========================================================================

  static final pages = [
    // -------------------------------------------------------------------------
    // SPLASH
    // -------------------------------------------------------------------------
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(name: AppRoutes.splash, page: () => HomeScreen()),
  ];
}
