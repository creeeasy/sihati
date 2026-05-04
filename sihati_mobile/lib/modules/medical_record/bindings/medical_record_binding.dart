// lib/modules/medical_record/bindings/medical_record_binding.dart
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/patient_provider.dart';
import '../../../data/repositories/patient_repository.dart';
import '../controllers/medical_record_controller.dart';

class MedicalRecordBinding extends Bindings {
  @override
  void dependencies() {
    // Core services
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }
    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService(), permanent: true);
    }

    // Provider
    if (!Get.isRegistered<PatientProvider>()) {
      Get.lazyPut(() => PatientProvider(Get.find<ApiService>()));
    }

    // Repository
    if (!Get.isRegistered<PatientRepository>()) {
      Get.lazyPut(() => PatientRepository(
            patientProvider: Get.find<PatientProvider>(),
            storageService: Get.find<StorageService>(),
          ));
    }

    // Controller
    Get.lazyPut<MedicalRecordController>(
      () => MedicalRecordController(
        patientRepository: Get.find<PatientRepository>(),
      ),
    );
  }
}
