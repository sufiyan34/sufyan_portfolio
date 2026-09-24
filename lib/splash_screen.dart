import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sufyan_portfolio/views/client/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  static const Color primary = Color(0xFF0D3B36);
  static const Color background = Color(0xFFF8F6F0);
  static const Color gold = Color(0xFFD5A43A);

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Get.off(
          () => HomeScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                    width: 125,
                    height: 125,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12222A27),
                          blurRadius: 30,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 700))
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: 30),

              // Name
              Text(
                    'MUHAMMAD SUFYAN',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5,
                      color: primary,
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                  )
                  .slideY(
                    begin: 0.25,
                    end: 0,
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                  ),

              const SizedBox(height: 12),

              // Gold divider
              Container(
                width: 45,
                height: 2,
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(10),
                ),
              ).animate().scaleX(
                begin: 0,
                end: 1,
                delay: const Duration(milliseconds: 800),
                duration: const Duration(milliseconds: 500),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'SOFTWARE ENGINEER  •  PORTFOLIO',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.0,
                  color: const Color(0xFF66706C),
                ),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 900),
                duration: const Duration(milliseconds: 600),
              ),

              const SizedBox(height: 55),

              // Loading indicator
              SizedBox(
                width: 90,
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: const Color(0xFFE2ECE9),
                  valueColor: const AlwaysStoppedAnimation<Color>(primary),
                  borderRadius: BorderRadius.circular(20),
                ),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 1100),
                duration: const Duration(milliseconds: 500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
