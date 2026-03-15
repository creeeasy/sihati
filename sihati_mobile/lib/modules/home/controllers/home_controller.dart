import 'package:get/get.dart';
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

  // Quick stats
  final upcomingAppointments = 0.obs;
  final favoritesCount = 0.obs;

  // Recent activities
  final recentActivities = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadQuickStats();
    loadRecentActivities();
  }

  // ═══════════════════════════════════════════════════════════════
  // Greeting based on time of day
  // ═══════════════════════════════════════════════════════════════

  String get greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Comment allez-vous ce matin ?';
    } else if (hour < 18) {
      return 'Bon après-midi !';
    } else {
      return 'Bonsoir !';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Load User Data
  // ═══════════════════════════════════════════════════════════════

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;

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
      // TODO: Replace with real data from repositories

      // Mock upcoming appointments count
      upcomingAppointments.value = 2;

      // Load favorites count
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
    Get.toNamed(AppRoutes.PROFILE);
  }

  void goToAIAssistant() {
    Get.toNamed(AppRoutes.AI_ASSISTANT, arguments: {'tag': 'home'});
  }

  void goToFavorites() {
    Get.toNamed(AppRoutes.FAVORITES);
  }

  void goToMyMedications() {
    // TODO: Navigate to my medications screen
    Get.snackbar(
      'Mes médicaments',
      'Fonctionnalité à venir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToMyAppointments() {
    Get.toNamed(AppRoutes.MY_APPOINTMENTS);
  }

  void goToHistory() {
    // TODO: Navigate to history screen
    Get.snackbar(
      'Historique',
      'Fonctionnalité à venir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToAllServices() {
    // TODO: Navigate to all services screen
    Get.snackbar(
      'Tous les services',
      'Fonctionnalité à venir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Refresh
  // ═══════════════════════════════════════════════════════════════

  Future<void> refresh() async {
    await Future.wait([
      loadUserData(),
      loadQuickStats(),
      loadRecentActivities(),
    ]);
  }
}
