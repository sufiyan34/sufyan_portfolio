import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sufyan_portfolio/splash_screen.dart';

void main() {
  usePathUrlStrategy();

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

          home: const SplashScreen(),
        );
      },
    );
  }
}
