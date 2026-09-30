import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/get_app_routes.dart';
import 'package:sufyan_portfolio/firebase_options.dart';
import 'package:seo/seo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // firebase_options.dart is still the placeholder stub until
    // `flutterfire configure` is run, so this is expected to fail until
    // then. The app still boots with static/fallback content.
    debugPrint('Firebase init skipped/failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 900),
      minTextAdapt: true,
      splitScreenMode: true,

      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sufyan Portfolio',

          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFFF8F6F0),

            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D3B36),
            ),

            useMaterial3: true,
          ),
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
          initialRoute: AppRoutes.splash,
          getPages: GetAppRoutes.pages,
        );
      },
    );
  }
}
