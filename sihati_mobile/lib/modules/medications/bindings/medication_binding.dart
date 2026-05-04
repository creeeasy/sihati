// lib/modules/medications/bindings/medication_binding.dart
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/medication_provider.dart';
import '../../../data/repositories/medication_repository.dart';
import '../controllers/medication_search_controller.dart';

class MedicationBinding extends Bindings {
  @override
  void dependencies() {
    // Core services
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }
    if (!Get.isRegistered<LocationService>()) {
      Get.put(LocationService(), permanent: true);
    }
    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService(), permanent: true);
    }

    // Real Provider
    if (!Get.isRegistered<MedicationProvider>()) {
      Get.put(
        MedicationProvider(Get.find<ApiService>()),
        permanent: true,
      );
    }

    // Repository
    if (!Get.isRegistered<MedicationRepository>()) {
      Get.put(
        MedicationRepository(
          medicationProvider: Get.find<MedicationProvider>(),
          locationService: Get.find<LocationService>(),
        ),
        permanent: true,
      );
    }

    // Controller
    Get.lazyPut(
      () => MedicationSearchController(
        medicationRepository: Get.find<MedicationRepository>(),
      ),
    );
  }
}
