import 'package:get/get.dart';
import 'package:sihati_mobile/core/services/api_service.dart';
import 'package:sihati_mobile/core/services/location_service.dart';
import 'package:sihati_mobile/data/providers/medication_provider.dart';
import 'package:sihati_mobile/data/repositories/medication_repository.dart';
import '../controllers/medications_list_controller.dart';

class MedicationsListBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }
    if (!Get.isRegistered<LocationService>()) {
      Get.put(LocationService(), permanent: true);
    }
    if (!Get.isRegistered<MedicationProvider>()) {
      Get.lazyPut(() => MedicationProvider(Get.find<ApiService>()));
    }
    if (!Get.isRegistered<MedicationRepository>()) {
      Get.lazyPut(() => MedicationRepository(
            medicationProvider: Get.find<MedicationProvider>(),
            locationService: Get.find<LocationService>(),
          ));
    }
    Get.lazyPut<MedicationsListController>(
      () => MedicationsListController(
        medicationRepository: Get.find<MedicationRepository>(),
      ),
    );
  }
}
