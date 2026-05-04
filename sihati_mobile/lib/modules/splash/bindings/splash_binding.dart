// lib/modules/splash/bindings/splash_binding.dart
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/auth_provider.dart'; // ✅ Real provider
import '../../../data/repositories/auth_repository.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
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
      Get.lazyPut(() => AuthProvider(Get.find<ApiService>()));
    }

    // ✅ Repository avec Real Provider
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut(() => AuthRepository(
            authProvider: Get.find<AuthProvider>(),
            storageService: Get.find<StorageService>(),
          ));
    }

    // Controller
    Get.put(SplashController(
      authRepository: Get.find(),
    ));
  }
}
