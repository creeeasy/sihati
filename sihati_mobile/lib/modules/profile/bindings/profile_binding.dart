// lib/modules/profile/bindings/profile_binding.dart
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/auth_provider.dart'; // ✅ Real provider
import '../../../data/repositories/auth_repository.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Core services (if not already registered)
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }
    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService(), permanent: true);
    }

    // ✅ Real Provider
    if (!Get.isRegistered<AuthProvider>()) {
      Get.put(
        AuthProvider(Get.find<ApiService>()),
        permanent: true,
      );
    }

    // ✅ Repository avec Real Provider
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put(
        AuthRepository(
          authProvider: Get.find<AuthProvider>(),
          storageService: Get.find<StorageService>(),
        ),
        permanent: true,
      );
    }

    // Controller
    Get.lazyPut(
      () => ProfileController(
        authRepository: Get.find<AuthRepository>(),
        storageService: Get.find<StorageService>(),
      ),
    );
  }
}
