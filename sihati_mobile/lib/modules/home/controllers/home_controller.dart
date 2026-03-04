import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';

class HomeController extends GetxController {
  final AuthRepository authRepository;

  HomeController({required this.authRepository});

  // State
  final userName = ''.obs;
  final userRole = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  /// Load current user data
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

  /// Navigate to medication search
  void goToMedicationSearch() {
    Get.toNamed(AppRoutes.MEDICATION_SEARCH);
  }

  /// Navigate to duty pharmacies
  void goToDutyPharmacies() {
    Get.toNamed(AppRoutes.DUTY_PHARMACIES);
  }

  /// Navigate to doctor list
  void goToDoctorList() {
    Get.toNamed(AppRoutes.DOCTOR_LIST);
  }

  /// Navigate to pharmacy list
  void goToPharmacyList() {
    Get.toNamed(AppRoutes.PHARMACY_LIST);
  }

  /// Navigate to profile
  void goToProfile() {
    Get.toNamed(AppRoutes.PROFILE);
  }

  /// Refresh user data
  Future<void> refresh() async {
    await loadUserData();
  }

  void goToAIAssistant() {
    Get.toNamed(AppRoutes.AI_ASSISTANT, arguments: {'tag': 'home'});
  }

  void goToFavorites() {
    Get.toNamed(AppRoutes.FAVORITES);
  }
}
