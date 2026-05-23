// lib/modules/profile/bindings/profile_binding.dart
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/patient_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/patient_repository.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }
    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService(), permanent: true);
    }

    if (!Get.isRegistered<AuthProvider>()) {
      Get.put(AuthProvider(Get.find<ApiService>()), permanent: true);
    }

    if (!Get.isRegistered<PatientProvider>()) {
      Get.put(PatientProvider(Get.find<ApiService>()), permanent: true);
    }

    if (!Get.isRegistered<AuthRepository>()) {
      Get.put(
        AuthRepository(
          authProvider: Get.find<AuthProvider>(),
          storageService: Get.find<StorageService>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<PatientRepository>()) {
      Get.put(
        PatientRepository(
          patientProvider: Get.find<PatientProvider>(),
          storageService: Get.find<StorageService>(),
        ),
        permanent: true,
      );
    }

    Get.lazyPut(
      () => ProfileController(
        authRepository: Get.find<AuthRepository>(),
        patientRepository: Get.find<PatientRepository>(),
        storageService: Get.find<StorageService>(),
      ),
    );
  }
}
