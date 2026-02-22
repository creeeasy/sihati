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
      final isLoggedIn = await authRepository.isLoggedIn();
      log(isLoggedIn.toString());
      if (isLoggedIn) {
        final user = await authRepository.verifyToken();
        if (user != null) {
          Get.offAllNamed(AppRoutes.HOME);
        } else {
          Get.offAllNamed(AppRoutes.LOGIN);
        }
      } else {
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
