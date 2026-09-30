import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/services/firebase_auth_service.dart';

class AdminAuthController extends GetxController {
  final FirebaseAuthService _auth = FirebaseAuthService.instance;

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  final nameController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final errorMessage = RxnString();

  User? get currentUser => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    _prefillFromCurrentUser();
  }

  void _prefillFromCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return;
    nameController.text = user.displayName ?? '';
    signUpEmailController.text = user.email ?? '';
  }

  String? validateLogin() {
    if (loginEmailController.text.trim().isEmpty) {
      return 'Enter your admin email.';
    }
    if (!GetUtils.isEmail(loginEmailController.text.trim())) {
      return 'Enter a valid email address.';
    }
    if (loginPasswordController.text.isEmpty) {
      return 'Enter your password.';
    }
    return null;
  }

  String? validateSignUp() {
    final name = nameController.text.trim();
    final email = signUpEmailController.text.trim();
    final password = signUpPasswordController.text;
    final confirm = confirmPasswordController.text;

    if (name.isEmpty) return 'Enter your name.';
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      return 'Enter a valid email address.';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (confirm != password) return 'Passwords do not match.';
    return null;
  }

  Future<void> login() async {
    final validation = validateLogin();
    if (validation != null) {
      errorMessage.value = validation;
      return;
    }

    await _runAuth(() async {
      final user = await _auth.signIn(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text,
      );

      final profile = await _auth.loadProfile();
      if (!_isAllowedAdmin(profile)) {
        await _auth.signOut();
        Get.offAllNamed(AppRoutes.accessDeniedScreen);
        return;
      }

      Get.offAllNamed(
        AppRoutes.adminDashboard,
        arguments: {
          'userId': user.uid,
          'displayName': user.displayName,
        },
      );
    });
  }

  Future<void> signUp() async {
    final validation = validateSignUp();
    if (validation != null) {
      errorMessage.value = validation;
      return;
    }

    await _runAuth(() async {
      final user = await _auth.signUp(
        email: signUpEmailController.text.trim(),
        password: signUpPasswordController.text,
        displayName: nameController.text.trim(),
      );

      Get.offAllNamed(
        AppRoutes.adminDashboard,
        arguments: {
          'userId': user.uid,
          'displayName': user.displayName ?? nameController.text.trim(),
        },
      );
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  bool _isAllowedAdmin(Map<dynamic, dynamic>? profile) {
    if (profile == null) return false;

    final role = profile['role']?.toString().toLowerCase();
    final active = profile['active'] == true ||
        profile['active']?.toString().toLowerCase() == 'true';

    return active && (role == 'superadmin' || role == 'admin');
  }

  Future<void> _runAuth(Future<void> Function() task) async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      await task();
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
      debugPrint('Admin auth error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    nameController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
