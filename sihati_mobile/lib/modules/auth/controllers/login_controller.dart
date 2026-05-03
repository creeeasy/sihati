import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository authRepository;
  LoginController({required this.authRepository});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final errorMessage = ''.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    try {
      errorMessage.value = '';
      if (emailController.text.isEmpty) {
        errorMessage.value = 'Email requis';
        Get.snackbar('Erreur', 'Email requis',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (passwordController.text.isEmpty) {
        errorMessage.value = 'Mot de passe requis';
        Get.snackbar('Erreur', 'Mot de passe requis',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      isLoading.value = true;
      await authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );

      Get.offAllNamed(AppRoutes.HOME);
      Get.snackbar('Succès', 'Connexion réussie',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Erreur', errorMessage.value,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// 🆕 Continue as guest
  Future<void> continueAsGuest() async {
    try {
      isLoading.value = true;

      // Call guest login method in auth repository
      await authRepository.loginAsGuest();

      Get.offAllNamed(AppRoutes.HOME);
      Get.snackbar(
        'Mode Invité',
        'Explorez Sihati! Connectez-vous pour plus de fonctionnalités.',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'entrer en mode invité',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() => Get.toNamed(AppRoutes.REGISTER);
}
