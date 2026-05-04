// lib/modules/home/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/storage_service.dart';

class HomeController extends GetxController {
  final AuthRepository authRepository;
  final StorageService? storageService;

  HomeController({
    required this.authRepository,
    this.storageService,
  });

  // State
  final userName = ''.obs;
  final userRole = ''.obs;
  final isLoading = false.obs;
  final isGuestMode = false.obs;

  // Quick stats
  final upcomingAppointments = 0.obs;
  final favoritesCount = 0.obs;

  // Recent activities
  final recentActivities = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    checkGuestMode();
    loadUserData();
    loadQuickStats();
    loadRecentActivities();
  }

  void checkGuestMode() {
    // ✅ Utilise l'observable du repository
    isGuestMode.value = authRepository.isGuestMode.value;

    if (isGuestMode.value) {
      userName.value = 'Invité';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Greeting
  // ═══════════════════════════════════════════════════════════════

  String get greeting {
    final hour = DateTime.now().hour;

    if (isGuestMode.value) {
      if (hour < 12) {
        return 'Explorez Sihati librement ☀️';
      } else if (hour < 18) {
        return 'Découvrez nos services 🌟';
      } else {
        return 'Bienvenue sur Sihati 🌙';
      }
    } else {
      if (hour < 12) {
        return 'Comment allez-vous ce matin ?';
      } else if (hour < 18) {
        return 'Bon après-midi !';
      } else {
        return 'Bonsoir !';
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Load User Data
  // ═══════════════════════════════════════════════════════════════

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;

      if (isGuestMode.value) {
        userName.value = 'Invité';
        userRole.value = 'guest';
        return;
      }

      final user = await authRepository.getCurrentUser();

      if (user != null) {
        userName.value = user.fullName;
        userRole.value = user.role;
      }
    } catch (e) {
      print('Error loading user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Load Quick Stats
  // ═══════════════════════════════════════════════════════════════

  Future<void> loadQuickStats() async {
    try {
      if (isGuestMode.value) {
        upcomingAppointments.value = 0;
        favoritesCount.value = 0;
        return;
      }

      // ✅ TODO: Appeler le vrai API pour les stats
      upcomingAppointments.value = 2;

      if (storageService != null) {
        final favMeds = await storageService!.getFavoriteMedications();
        favoritesCount.value = favMeds.length;
      }
    } catch (e) {
      print('Error loading quick stats: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Load Recent Activities
  // ═══════════════════════════════════════════════════════════════

  Future<void> loadRecentActivities() async {
    try {
      if (isGuestMode.value) {
        recentActivities.value = [];
        return;
      }

      if (storageService != null) {
        final history = await storageService!.getMedicationHistory();

        recentActivities.value = history.take(3).map((item) {
          return {
            'type': 'medication',
            'title': 'Recherche: ${item['name']}',
            'time': _formatTime(item['viewedAt']),
          };
        }).toList();
      }
    } catch (e) {
      print('Error loading recent activities: $e');
    }
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';

    try {
      final date = DateTime.parse(isoString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return 'Il y a ${diff.inMinutes} min';
      } else if (diff.inHours < 24) {
        return 'Il y a ${diff.inHours}h';
      } else if (diff.inDays < 7) {
        return 'Il y a ${diff.inDays}j';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Navigation Methods
  // ═══════════════════════════════════════════════════════════════

  void goToMedicationSearch() {
    Get.toNamed(AppRoutes.MEDICATION_SEARCH);
  }

  void goToDutyPharmacies() {
    Get.toNamed(AppRoutes.DUTY_PHARMACIES);
  }

  void goToDoctorList() {
    Get.toNamed(AppRoutes.DOCTOR_LIST);
  }

  void goToPharmacyList() {
    Get.toNamed(AppRoutes.PHARMACY_LIST);
  }

  void goToProfile() {
    if (isGuestMode.value) {
      authRepository.promptLoginForFeature('accéder à votre profil');
      return;
    }
    Get.toNamed(AppRoutes.PROFILE);
  }

  void goToAIAssistant() {
    Get.toNamed(AppRoutes.AI_ASSISTANT, arguments: {'tag': 'home'});
  }

  void goToFavorites() {
    Get.toNamed(AppRoutes.FAVORITES);
  }

  void goToMyMedications() {
    Get.snackbar(
      'Mes médicaments',
      'Fonctionnalité à venir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToMyAppointments() {
    if (isGuestMode.value) {
      authRepository.promptLoginForFeature('prendre ou voir vos rendez-vous');
      return;
    }
    Get.toNamed(AppRoutes.MY_APPOINTMENTS);
  }

  void goToHistory() {
    Get.snackbar(
      'Historique',
      'Fonctionnalité à venir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void logoutGuest() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Quitter le mode invité'),
        content: const Text(
          'Créez un compte pour sauvegarder vos données ou continuez sans sauvegarde.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              authRepository.logout();
            },
            child: const Text(
              'Quitter',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.REGISTER);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Créer un compte'),
          ),
        ],
      ),
    );
  }

  Future<void> refresh() async {
    await Future.wait([
      loadUserData(),
      loadQuickStats(),
      loadRecentActivities(),
    ]);
  }
}
