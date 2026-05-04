// lib/modules/auth/bindings/auth_binding.dart
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Core services (permanent)
    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService(), permanent: true);
    }
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    // Provider (REAL)
    Get.lazyPut(() => AuthProvider(Get.find<ApiService>()));

    // Repository
    Get.lazyPut(() => AuthRepository(
          authProvider: Get.find<AuthProvider>(),
          storageService: Get.find<StorageService>(),
        ));

    // Controllers
    Get.lazyPut(() => LoginController(authRepository: Get.find()));
    Get.lazyPut(() => RegisterController(authRepository: Get.find()));
  }
}
