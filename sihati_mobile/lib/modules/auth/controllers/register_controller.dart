import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/utils/validators.dart';

class RegisterController extends GetxController {
  final AuthRepository authRepository;

  RegisterController({required this.authRepository});

  // Text controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final chifaNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable states
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final acceptTerms = false.obs;
  final isChifaValid = false.obs;
  final errorMessage = ''.obs;
  final chifaText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to Chifa number changes for validation
    chifaNumberController.addListener(() {
      _validateChifa();
      chifaText.value = chifaNumberController.text;
    });
    // Set initial value
    chifaText.value = chifaNumberController.text;
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    chifaNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void _validateChifa() {
    final chifa = chifaNumberController.text.replaceAll(' ', '');

    if (chifa.isEmpty) {
      isChifaValid.value = false;
      return;
    }

    // Chifa numbers are typically 13-15 digits in Algeria
    isChifaValid.value = chifa.length >= 13 && chifa.length <= 15;
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

      // Validate all inputs
      if (!_validateInputs()) return;

      isLoading.value = true;

      // Prepare chifa number (empty string if not provided)
      String chifaNumber =
          chifaNumberController.text.replaceAll(' ', '').trim();

      // Call registration API
      await authRepository.registerPatient(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        chifaNumber: chifaNumber.isNotEmpty ? chifaNumber : null,
      );

      Get.offAllNamed(AppRoutes.HOME);
      Get.snackbar(
        'Succès',
        'Inscription réussie',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateInputs() {
    // Full name validation
    String? error = Validators.validateName(fullNameController.text);
    if (error != null) {
      errorMessage.value = error;
      return false;
    }

    // Email validation
    error = Validators.validateEmail(emailController.text);
    if (error != null) {
      errorMessage.value = error;
      return false;
    }

    // Phone validation
    error = Validators.validatePhoneNumber(phoneController.text);
    if (error != null) {
      errorMessage.value = error;
      return false;
    }

    // Chifa validation (only if provided)
    final chifaNumber = chifaNumberController.text.replaceAll(' ', '');
    if (chifaNumber.isNotEmpty && !isChifaValid.value) {
      errorMessage.value = 'Numéro Carte Chifa invalide (13-15 chiffres)';
      return false;
    }

    // Password validation
    error = Validators.validatePassword(passwordController.text);
    if (error != null) {
      errorMessage.value = error;
      return false;
    }

    // Confirm password validation
    if (passwordController.text != confirmPasswordController.text) {
      errorMessage.value = 'Les mots de passe ne correspondent pas';
      return false;
    }

    // Terms acceptance
    if (!acceptTerms.value) {
      errorMessage.value = 'Veuillez accepter les conditions d\'utilisation';
      return false;
    }

    return true;
  }

  void goToLogin() => Get.back();
}
