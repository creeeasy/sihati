import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:sihati_mobile/core/models/user_model.dart';
import 'package:sihati_mobile/data/repositories/auth_repository.dart';
import 'package:sihati_mobile/core/services/storage_service.dart';
import 'package:sihati_mobile/app/routes/app_routes.dart';

class ProfileController extends GetxController {
  final AuthRepository authRepository;
  final StorageService storageService;

  ProfileController({
    required this.authRepository,
    required this.storageService,
  });

  // State
  final user = Rxn<UserModel>();
  final isLoading = false.obs;
  final isEditing = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final isUpdatingChifa = false.obs;

  // Stats (loaded separately from /patient/stats)
  final prescriptionsCount = 0.obs;
  final medicationsCount = 0.obs;
  final consultationsCount = 0.obs;

  // Form controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController(); // Read-only

  // Settings
  final notificationsEnabled = true.obs;
  final darkModeEnabled = false.obs;
  final language = 'Français'.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();

    // Load saved settings from storage
    _loadSettings();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  // Load saved settings
  Future<void> _loadSettings() async {
    final notifications = await storageService.getBool('notifications_enabled');
    if (notifications != null) {
      notificationsEnabled.value = notifications;
    }

    final darkMode = await storageService.getBool('dark_mode');
    if (darkMode != null) {
      darkModeEnabled.value = darkMode;
    }

    final savedLanguage = await storageService.getString('language');
    if (savedLanguage != null) {
      language.value = savedLanguage;
    }
  }

  // Load user profile
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userData = await authRepository.getCurrentUser();

      if (userData != null) {
        user.value = userData;
        _initFormControllers(userData);
      } else {
        // Try to verify token as fallback
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

  // Initialize form controllers with user data
  void _initFormControllers(UserModel userData) {
    fullNameController.text = userData.fullName;
    phoneController.text = userData.phoneNumber;
    emailController.text = userData.email;
  }

  // Toggle edit mode
  void toggleEditMode() {
    if (isEditing.value) {
      // Cancel edit - reset form
      if (user.value != null) {
        _initFormControllers(user.value!);
      }
    }
    isEditing.value = !isEditing.value;
    successMessage.value = '';
    errorMessage.value = '';
  }

  // Update profile
  Future<void> updateProfile() async {
    // Validate inputs
    if (!_validateInputs()) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      // Prepare updated fields
      final newFullName = fullNameController.text.trim();
      final newPhone = phoneController.text.trim();

      // Only send fields that actually changed
      final String? fullNameToUpdate =
          newFullName != user.value?.fullName ? newFullName : null;
      final String? phoneToUpdate =
          newPhone != user.value?.phoneNumber ? newPhone : null;

      // If nothing changed, just exit edit mode
      if (fullNameToUpdate == null && phoneToUpdate == null) {
        isEditing.value = false;
        successMessage.value = 'Aucune modification détectée';
        return;
      }

      // Call repository to update profile
      final updatedUser = await authRepository.updateProfile(
        fullName: fullNameToUpdate,
        phoneNumber: phoneToUpdate,
      );

      // Update local user data
      user.value = updatedUser;

      // Show success message
      successMessage.value = 'Profil mis à jour avec succès';
      isEditing.value = false;

      Get.snackbar(
        'Succès',
        'Votre profil a été mis à jour',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errorMessage.value =
          'Erreur lors de la mise à jour: ${e.toString().replaceAll('Exception: ', '')}';
    } finally {
      isLoading.value = false;
    }
  }

  // Validate form inputs
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

    // Algerian phone number validation (05XXXXXXXX) - using same regex as repository
    final phoneRegex = RegExp(r'^0[5-7][0-9]{8}$');
    if (!phoneRegex.hasMatch(phone)) {
      errorMessage.value = 'Numéro de téléphone invalide (format: 05XXXXXXXX)';
      return false;
    }

    return true;
  }

  // ============================================================
  // 🆕 CHIFA CARD METHODS
  // ============================================================

  /// Check if user has Chifa number
  bool hasChifa() {
    return user.value?.hasChifa ?? false;
  }

  /// Get formatted Chifa number for display
  String? getFormattedChifa() {
    return user.value?.formattedChifa;
  }

  /// Get raw Chifa number (without formatting)
  String? getRawChifa() {
    return user.value?.chifaNumber;
  }

  /// Validate Chifa number format
  bool isValidChifaNumber(String chifaNumber) {
    final cleaned = chifaNumber.replaceAll(' ', '');
    if (cleaned.isEmpty) return false;
    return cleaned.length >= 13 &&
        cleaned.length <= 15 &&
        RegExp(r'^\d+$').hasMatch(cleaned);
  }

  /// Update Chifa number
  Future<void> updateChifaNumber(String chifaNumber) async {
    try {
      isUpdatingChifa.value = true;
      errorMessage.value = '';

      // Clean the chifa number (remove spaces)
      String cleanedChifa = chifaNumber.replaceAll(' ', '');

      // Validate format if provided
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

      // Call API to update
      final updatedUser = await authRepository.updateChifaNumber(
        cleanedChifa.isEmpty ? null : cleanedChifa,
      );

      // Update local user data
      user.value = updatedUser;

      // Show success message
      Get.snackbar(
        'Succès',
        cleanedChifa.isEmpty
            ? 'Numéro Carte Chifa supprimé'
            : 'Numéro Carte Chifa mis à jour',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isUpdatingChifa.value = false;
    }
  }

  /// Remove Chifa number
  Future<void> removeChifaNumber() async {
    try {
      isUpdatingChifa.value = true;
      errorMessage.value = '';

      // Call API to remove
      final updatedUser = await authRepository.updateChifaNumber(null);

      // Update local user data
      user.value = updatedUser;

      Get.snackbar(
        'Succès',
        'Numéro Carte Chifa supprimé',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errorMessage.value = 'Impossible de supprimer le numéro Chifa';
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdatingChifa.value = false;
    }
  }

  // ============================================================
  // END OF CHIFA METHODS
  // ============================================================

  // Toggle notifications
  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    await storageService.saveBool('notifications_enabled', value);

    Get.snackbar(
      'Notifications',
      value ? 'Notifications activées' : 'Notifications désactivées',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  // Toggle dark mode
  Future<void> toggleDarkMode(bool value) async {
    darkModeEnabled.value = value;
    await storageService.saveBool('dark_mode', value);

    // TODO: Implement actual theme switching when ready
    Get.snackbar(
      'Thème',
      'Le changement de thème sera disponible dans la prochaine version',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Change language
  Future<void> changeLanguage(String newLanguage) async {
    language.value = newLanguage;
    await storageService.saveString('language', newLanguage);

    // TODO: Implement localization when ready
    Get.snackbar(
      'Langue',
      'Langue changée en $newLanguage\n(disponible dans la prochaine version)',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Logout
  Future<void> logout() async {
    try {
      isLoading.value = true;

      await authRepository.logout();

      // Clear local user data
      user.value = null;

      // Navigate to login and remove all previous routes
      Get.offAllNamed(AppRoutes.LOGIN);

      Get.snackbar(
        'Déconnexion',
        'Vous avez été déconnecté avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors de la déconnexion: $e';

      Get.snackbar(
        'Erreur',
        'Impossible de se déconnecter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Show logout confirmation dialog
  void showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppColors.textSecondary),
            ),
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

  // Get user initials for avatar
  String getUserInitials() {
    if (user.value == null) return '';

    final nameParts = user.value!.fullName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return user.value!.fullName.substring(0, 1).toUpperCase();
  }

  // Get user role in French
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

  // Format phone number for display
  String formatPhoneNumber(String phone) {
    // Format: 0550 12 34 56
    final cleaned = phone.replaceAll(' ', '');
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 10)}';
    }
    return phone;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await authRepository.isLoggedIn();
  }

  // Refresh user data (for pull-to-refresh)
  Future<void> refreshUserData() async {
    await loadProfile();
  }

  /// Navigate to Medical Record screen
  void goToMedicalRecord() {
    Get.toNamed(AppRoutes.MEDICAL_RECORD);
  }

  /// Navigate to Favorites screen
  void goToFavorites() {
    Get.toNamed(AppRoutes.FAVORITES);
  }

  /// Navigate to Appointments screen
  void goToAppointments() {
    Get.toNamed(AppRoutes.MY_APPOINTMENTS);
  }

  /// Navigate to Reminders screen
  void goToReminders() {
    Get.toNamed(AppRoutes.REMINDERS);
  }

  /// Navigate to Settings screen (if needed)
  void goToSettings() {
    Get.toNamed(AppRoutes.SETTINGS);
  }

  /// Navigate to About screen (if needed)
  void goToAbout() {
    Get.toNamed(AppRoutes.ABOUT);
  }
}
