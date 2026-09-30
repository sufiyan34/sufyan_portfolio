import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/services/firebase_auth_service.dart';

/// Lightweight route gate for admin URLs.
///
/// The login flow performs the full role/active-profile check. This
/// middleware additionally prevents unauthenticated users from opening an
/// admin route directly by URL.
class AdminRouteMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!FirebaseAuthService.instance.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
