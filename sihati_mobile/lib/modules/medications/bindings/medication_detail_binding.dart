// lib/modules/medications/bindings/medication_detail_binding.dart
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/medication_provider.dart';
import '../../../data/repositories/medication_repository.dart';
import '../../../data/providers/ai_provider.dart';
import '../../../data/repositories/ai_repository.dart';
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

    // Provider
    if (!Get.isRegistered<MedicationProvider>()) {
      Get.put(
        MedicationProvider(Get.find<ApiService>()),
        permanent: true,
      );
    }
    
    if (!Get.isRegistered<AiProvider>()) {
      Get.put(
        AiProvider(Get.find<ApiService>()),
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
    
    if (!Get.isRegistered<AiRepository>()) {
      Get.lazyPut(
        () => AiRepository(
          aiProvider: Get.find<AiProvider>(),
        ),
        fenix: true,
      );
    }

    Get.lazyPut<MedicationDetailController>(
      () => MedicationDetailController(
        medicationRepository: Get.find<MedicationRepository>(),
        aiRepository: Get.find<AiRepository>(),
      ),
    );
  }
}
