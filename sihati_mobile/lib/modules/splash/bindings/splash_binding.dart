import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/mock/mock_auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Provider
    Get.lazyPut(() => MockAuthProvider());

    // Repository
    Get.lazyPut(() => AuthRepository(
          authProvider: Get.find(),
          storageService: Get.find<StorageService>(),
        ));

    // Controller
    Get.put(SplashController(
      authRepository: Get.find(),
    ));
  }
}
