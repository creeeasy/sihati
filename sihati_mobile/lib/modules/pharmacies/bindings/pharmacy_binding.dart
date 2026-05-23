// lib/modules/pharmacies/bindings/pharmacy_binding.dart
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/pharmacy_provider.dart';
import '../../../data/repositories/pharmacy_repository.dart';
import '../../../data/providers/favorite_provider.dart';
import '../../../data/repositories/favorite_repository.dart';
import '../controllers/pharmacy_list_controller.dart';
import '../controllers/pharmacy_detail_controller.dart';
import '../controllers/duty_pharmacy_controller.dart';

class PharmacyBinding extends Bindings {
  @override
  void dependencies() {
    // Core services
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }
    if (!Get.isRegistered<LocationService>()) {
      Get.put(LocationService(), permanent: true);
    }
    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService(), permanent: true);
    }

    // Real Provider
    if (!Get.isRegistered<PharmacyProvider>()) {
      Get.put(
        PharmacyProvider(Get.find<ApiService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<FavoriteProvider>()) {
      Get.put(
        FavoriteProvider(Get.find<ApiService>()),
        permanent: true,
      );
    }

    // Repository
    if (!Get.isRegistered<PharmacyRepository>()) {
      Get.put(
        PharmacyRepository(
          pharmacyProvider: Get.find<PharmacyProvider>(),
          locationService: Get.find<LocationService>(),
        ),
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

    // Controllers
    Get.lazyPut(() => PharmacyListController(
          pharmacyRepository: Get.find<PharmacyRepository>(),
        ));

    Get.lazyPut(() => PharmacyDetailController(
          pharmacyRepository: Get.find<PharmacyRepository>(),
          favoriteRepository: Get.find<FavoriteRepository>(),
        ));

    Get.lazyPut(() => DutyPharmacyController(
          pharmacyRepository: Get.find<PharmacyRepository>(),
        ));
  }
}
