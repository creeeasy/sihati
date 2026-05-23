// lib/modules/favorites/bindings/favorites_binding.dart
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/favorite_provider.dart';
import '../../../data/repositories/favorite_repository.dart';
import '../controllers/favorites_controller.dart';

/// Binding for the Favorites screen.
///
/// Wires: ApiService → FavoriteProvider → FavoriteRepository
class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    // Core services (safe to call multiple times — only registers if absent)
    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService(), permanent: true);
    }
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    // Favorites provider → repository
    if (!Get.isRegistered<FavoriteProvider>()) {
      Get.put(
        FavoriteProvider(Get.find<ApiService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<FavoriteRepository>()) {
      Get.lazyPut(
        () => FavoriteRepository(
          favoriteProvider: Get.find<FavoriteProvider>(),
        ),
        fenix: true,
      );
    }

    Get.lazyPut<FavoritesController>(
      () => FavoritesController(
        favoriteRepository: Get.find<FavoriteRepository>(),
      ),
    );
  }
}
