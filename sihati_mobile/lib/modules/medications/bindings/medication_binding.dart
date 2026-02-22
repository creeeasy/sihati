import 'package:get/get.dart';
import 'package:sihati_mobile/core/services/location_service.dart';
import 'package:sihati_mobile/data/providers/mock/mock_medication_provider.dart';
import 'package:sihati_mobile/data/repositories/medication_repository.dart';
import '../controllers/medication_search_controller.dart';

class MedicationBinding extends Bindings {
  @override
  void dependencies() {
    // Register LocationService if not already registered
    if (!Get.isRegistered<LocationService>()) {
      Get.put(LocationService(), permanent: true);
    }

    // Register MockMedicationProvider if not already registered
    if (!Get.isRegistered<MockMedicationProvider>()) {
      Get.put(MockMedicationProvider(), permanent: true);
    }

    // Register MedicationRepository if not already registered
    if (!Get.isRegistered<MedicationRepository>()) {
      Get.put(
        MedicationRepository(
          medicationProvider: Get.find<MockMedicationProvider>(),
          locationService: Get.find<LocationService>(),
        ),
        permanent: true,
      );
    }

    // Register MedicationSearchController
    Get.lazyPut(
      () => MedicationSearchController(
        medicationRepository: Get.find<MedicationRepository>(),
      ),
    );
  }
}
