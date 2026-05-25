// lib/modules/profile/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/core/models/user_model.dart';
import 'package:sihati_mobile/data/repositories/auth_repository.dart';
import 'package:sihati_mobile/data/repositories/patient_repository.dart';
import 'package:sihati_mobile/core/services/storage_service.dart';
import 'package:sihati_mobile/app/routes/app_routes.dart';

class ProfileController extends GetxController {
  final AuthRepository authRepository;
  final PatientRepository patientRepository;
  final StorageService storageService;

  ProfileController({
    required this.authRepository,
    required this.patientRepository,
    required this.storageService,
  });

  final user = Rxn<UserModel>();
  final isLoading = false.obs;
  final isEditing = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final isUpdatingChifa = false.obs;

  final prescriptionsCount = 0.obs;
  final medicationsCount = 0.obs;
  final consultationsCount = 0.obs;

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final notificationsEnabled = true.obs;
  final language = 'Français'.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    loadStats();
    _loadSettings();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> _loadSettings() async {
    final notifications = await storageService.getBool('notifications_enabled');
    if (notifications != null) notificationsEnabled.value = notifications;

    final savedLanguage = await storageService.getString('language');
    if (savedLanguage != null) language.value = savedLanguage;
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userData = await authRepository.getCurrentUser();

      if (userData != null) {
        user.value = userData;
        _initFormControllers(userData);
      } else {
        final verifiedUser = await authRepository.verifyToken();
        if (verifiedUser != null) {
          user.value = verifiedUser;
          _initFormControllers(verifiedUser);
        } else {
          errorMessage.value = 'Impossible de charger le profil';
        }
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement du profil: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStats() async {
    try {
      final stats = await patientRepository.getStats();
      prescriptionsCount.value = stats['prescriptionsCount'] ?? 0;
      medicationsCount.value = stats['medicationsCount'] ?? 0;
      consultationsCount.value = stats['consultationsCount'] ?? 0;
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  void _initFormControllers(UserModel userData) {
    fullNameController.text = userData.fullName;
    phoneController.text = userData.phoneNumber;
    emailController.text = userData.email;
  }

  void toggleEditMode() {
    if (isEditing.value) {
      if (user.value != null) _initFormControllers(user.value!);
    }
    isEditing.value = !isEditing.value;
    successMessage.value = '';
    errorMessage.value = '';
  }

  Future<void> updateProfile() async {
    if (!_validateInputs()) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final newFullName = fullNameController.text.trim();
      final newPhone = phoneController.text.trim();

      final String? fullNameToUpdate =
          newFullName != user.value?.fullName ? newFullName : null;
      final String? phoneToUpdate =
          newPhone != user.value?.phoneNumber ? newPhone : null;

      if (fullNameToUpdate == null && phoneToUpdate == null) {
        isEditing.value = false;
        successMessage.value = 'Aucune modification détectée';
        return;
      }

      final updatedUser = await authRepository.updateProfile(
        fullName: fullNameToUpdate,
        phoneNumber: phoneToUpdate,
      );

      user.value = updatedUser;
      successMessage.value = 'Profil mis à jour avec succès';
      isEditing.value = false;

      Get.snackbar('Succès', 'Votre profil a été mis à jour',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
    } catch (e) {
      errorMessage.value =
          'Erreur lors de la mise à jour: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateInputs() {
    final fullName = fullNameController.text.trim();
    if (fullName.isEmpty) {
      errorMessage.value = 'Le nom complet est requis';
      return false;
    }
    if (fullName.length < 3) {
      errorMessage.value = 'Le nom doit contenir au moins 3 caractères';
      return false;
    }

    final phone = phoneController.text.trim().replaceAll(' ', '');
    if (phone.isEmpty) {
      errorMessage.value = 'Le numéro de téléphone est requis';
      return false;
    }

    final phoneRegex = RegExp(r'^0[5-7][0-9]{8}$');
    if (!phoneRegex.hasMatch(phone)) {
      errorMessage.value = 'Numéro de téléphone invalide (format: 05XXXXXXXX)';
      return false;
    }

    return true;
  }

  bool hasChifa() => user.value?.hasChifa ?? false;
  String? getFormattedChifa() => user.value?.formattedChifa;
  String? getRawChifa() => user.value?.chifaNumber;

  bool isValidChifaNumber(String chifaNumber) {
    final cleaned = chifaNumber.replaceAll(' ', '');
    if (cleaned.isEmpty) return false;
    return cleaned.length >= 13 &&
        cleaned.length <= 15 &&
        RegExp(r'^\d+$').hasMatch(cleaned);
  }

  Future<void> updateChifaNumber(String chifaNumber) async {
    try {
      isUpdatingChifa.value = true;
      errorMessage.value = '';

      String cleanedChifa = chifaNumber.replaceAll(' ', '');

      if (cleanedChifa.isNotEmpty) {
        if (cleanedChifa.length < 13 || cleanedChifa.length > 15) {
          throw Exception(
              'Le numéro Carte Chifa doit contenir entre 13 et 15 chiffres');
        }
        if (!RegExp(r'^\d+$').hasMatch(cleanedChifa)) {
          throw Exception(
              'Le numéro Carte Chifa ne doit contenir que des chiffres');
        }
      }

      final updatedUser = await authRepository.updateChifaNumber(
        cleanedChifa.isEmpty ? null : cleanedChifa,
      );

      user.value = updatedUser;

      Get.snackbar(
          'Succès',
          cleanedChifa.isEmpty
              ? 'Numéro Carte Chifa supprimé'
              : 'Numéro Carte Chifa mis à jour',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Erreur', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3));
    } finally {
      isUpdatingChifa.value = false;
    }
  }

  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    await storageService.saveBool('notifications_enabled', value);
  }

  Future<void> changeLanguage(String newLanguage) async {
    language.value = newLanguage;
    await storageService.saveString('language', newLanguage);
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await authRepository.logout();
      user.value = null;
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      errorMessage.value = 'Erreur lors de la déconnexion: $e';
      Get.snackbar('Erreur', 'Impossible de se déconnecter',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  String getUserInitials() {
    if (user.value == null) return '';
    final nameParts = user.value!.fullName.split(' ');
    if (nameParts.length >= 2)
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    return user.value!.fullName.substring(0, 1).toUpperCase();
  }

  String getUserRole() {
    if (user.value == null) return '';
    switch (user.value!.role) {
      case 'patient':
        return 'Patient';
      case 'doctor':
        return 'Médecin';
      case 'pharmacy':
        return 'Pharmacien';
      case 'admin':
        return 'Administrateur';
      default:
        return 'Utilisateur';
    }
  }

  String formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(' ', '');
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 10)}';
    }
    return phone;
  }

  Future<bool> isLoggedIn() async => await authRepository.isLoggedIn();
  Future<void> refreshUserData() async {
    await loadProfile();
    await loadStats();
  }

  void goToMedicalRecord() => Get.toNamed(AppRoutes.MEDICAL_RECORD);
  void goToFavorites() => Get.toNamed(AppRoutes.FAVORITES);
  void goToAppointments() => Get.toNamed(AppRoutes.MY_APPOINTMENTS);
}
