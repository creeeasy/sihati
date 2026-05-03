import 'dart:developer';

import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';

class SplashController extends GetxController {
  final AuthRepository authRepository;

  SplashController({required this.authRepository});

  @override
  void onInit() {
    print("hello world");
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      // First check auth status using the repository method
      await authRepository.checkAuthStatus();

      // Now check if user is authenticated OR in guest mode
      final isAuthenticated = authRepository.isAuthenticated.value;
      final isGuest = authRepository.isGuestMode.value;

      log('isAuthenticated: $isAuthenticated, isGuest: $isGuest');

      if (isAuthenticated) {
        // User is logged in, verify token is still valid
        final user = await authRepository.verifyToken();
        if (user != null) {
          Get.offAllNamed(AppRoutes.HOME);
        } else {
          Get.offAllNamed(AppRoutes.LOGIN);
        }
      } else if (isGuest) {
        // User is in guest mode, go directly to home
        Get.offAllNamed(AppRoutes.HOME);
      } else {
        // No authentication and not in guest mode, show login
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      log('Auth check error: $e');
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
