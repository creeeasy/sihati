import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/mock/mock_auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Provider (if not already registered)
    if (!Get.isRegistered<MockAuthProvider>()) {
      Get.lazyPut(() => MockAuthProvider());
    }

    // Repository (if not already registered)
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut(() => AuthRepository(
            authProvider: Get.find(),
            storageService: Get.find<StorageService>(),
          ));
    }

    // Controller
    Get.lazyPut(() => HomeController(
          authRepository: Get.find(),
        ));
  }
}
