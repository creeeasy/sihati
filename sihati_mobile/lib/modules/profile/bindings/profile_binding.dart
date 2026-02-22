import 'package:get/get.dart';
import 'package:sihati_mobile/data/repositories/auth_repository.dart';
import 'package:sihati_mobile/core/services/storage_service.dart';
import 'package:sihati_mobile/data/providers/mock/mock_auth_provider.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Register MockAuthProvider if not already registered
    if (!Get.isRegistered<MockAuthProvider>()) {
      Get.put(
        MockAuthProvider(),
        permanent: true,
      );
    }

    // Register StorageService if not already registered
    if (!Get.isRegistered<StorageService>()) {
      // Note: StorageService should be initialized at app startup
      // This is just a fallback
      Get.put(
        StorageService(),
        permanent: true,
      );
    }

    // Register AuthRepository if not already registered
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put(
        AuthRepository(
          authProvider: Get.find<MockAuthProvider>(),
          storageService: Get.find<StorageService>(),
        ),
        permanent: true, // Repository should persist
      );
    }

    // Register ProfileController
    Get.lazyPut(
      () => ProfileController(
        authRepository: Get.find<AuthRepository>(),
        storageService: Get.find<StorageService>(),
      ),
    );
  }
}
