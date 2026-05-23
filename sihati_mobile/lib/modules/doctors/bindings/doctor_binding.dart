// lib/modules/doctors/bindings/doctor_binding.dart
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/doctor_provider.dart';
import '../../../data/repositories/doctor_repository.dart';
import '../../../data/providers/favorite_provider.dart';
import '../../../data/repositories/favorite_repository.dart';
import '../controllers/doctor_list_controller.dart';
import '../controllers/doctor_detail_controller.dart';

class DoctorBinding extends Bindings {
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
    if (!Get.isRegistered<DoctorProvider>()) {
      Get.put(
        DoctorProvider(Get.find<ApiService>()),
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
    Get.lazyPut(
      () => DoctorRepository(
        doctorProvider: Get.find<DoctorProvider>(),
        locationService: Get.find<LocationService>(),
      ),
      fenix: true,
    );

    if (!Get.isRegistered<FavoriteRepository>()) {
      Get.lazyPut(
        () => FavoriteRepository(
          favoriteProvider: Get.find<FavoriteProvider>(),
        ),
        fenix: true,
      );
    }

    // Controllers
    Get.lazyPut(
      () => DoctorListController(
        doctorRepository: Get.find<DoctorRepository>(),
        storageService: Get.find<StorageService>(),
      ),
    );

    Get.lazyPut(
      () => DoctorDetailController(
        doctorRepository: Get.find<DoctorRepository>(),
        favoriteRepository: Get.find<FavoriteRepository>(),
      ),
    );
  }
}
