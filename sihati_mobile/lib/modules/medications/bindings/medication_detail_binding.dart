// lib/modules/medications/bindings/medication_detail_binding.dart
import 'package:get/get.dart';
import 'package:sihati_mobile/core/services/ai_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/medication_provider.dart';
import '../../../data/repositories/medication_repository.dart';
import '../controllers/medication_detail_controller.dart';

class MedicationDetailBinding extends Bindings {
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
    if (!Get.isRegistered<AIService>()) {
      Get.put(AIService(), permanent: true);
    }

    // Provider
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

    // ✅ CORRIGÉ: Injection des deux dépendances
    Get.lazyPut<MedicationDetailController>(
      () => MedicationDetailController(
        medicationRepository: Get.find<MedicationRepository>(),
        aiService: Get.find<AIService>(),
      ),
    );
  }
}
