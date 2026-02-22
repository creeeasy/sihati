import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/utils/validators.dart';

class RegisterController extends GetxController {
  final AuthRepository authRepository;
  RegisterController({required this.authRepository});

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final errorMessage = ''.obs;

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> register() async {
    try {
      errorMessage.value = '';

      // Validate
      String? error;
      error = Validators.validateName(fullNameController.text);
      if (error != null) {
        errorMessage.value = error;
        return;
      }

      error = Validators.validateEmail(emailController.text);
      if (error != null) {
        errorMessage.value = error;
        return;
      }

      error = Validators.validatePhoneNumber(phoneController.text);
      if (error != null) {
        errorMessage.value = error;
        return;
      }

      error = Validators.validatePassword(passwordController.text);
      if (error != null) {
        errorMessage.value = error;
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        errorMessage.value = 'Les mots de passe ne correspondent pas';
        return;
      }

      isLoading.value = true;

      await authRepository.registerPatient(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
      );

      Get.offAllNamed(AppRoutes.HOME);
      Get.snackbar('Succès', 'Inscription réussie',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Erreur', errorMessage.value,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() => Get.back();
}
