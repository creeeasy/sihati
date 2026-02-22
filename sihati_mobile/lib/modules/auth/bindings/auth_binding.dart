import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/mock/mock_auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Provider
    Get.lazyPut(() => MockAuthProvider());

    // Repository
    Get.lazyPut(() => AuthRepository(
          authProvider: Get.find(),
          storageService: Get.find<StorageService>(),
        ));

    // Controllers
    Get.lazyPut(() => LoginController(authRepository: Get.find()));
    Get.lazyPut(() => RegisterController(authRepository: Get.find()));
  }
}
