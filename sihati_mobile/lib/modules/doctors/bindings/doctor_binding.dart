import 'package:get/get.dart';
import 'package:sihati_mobile/core/services/location_service.dart';
import 'package:sihati_mobile/core/services/storage_service.dart';
import 'package:sihati_mobile/data/providers/mock/mock_doctor_provider.dart';
import 'package:sihati_mobile/data/repositories/doctor_repository.dart';
import '../controllers/doctor_list_controller.dart';
import '../controllers/doctor_detail_controller.dart';

class DoctorBinding extends Bindings {
  @override
  void dependencies() {
    // Register MockDoctorProvider if not already registered
    if (!Get.isRegistered<MockDoctorProvider>()) {
      Get.put(
        MockDoctorProvider(),
        permanent: true,
      );
    }

    // Register LocationService if not already registered
    if (!Get.isRegistered<LocationService>()) {
      Get.put(
        LocationService(),
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

    // Register DoctorRepository
    Get.lazyPut(
      () => DoctorRepository(
        doctorProvider: Get.find<MockDoctorProvider>(),
        locationService: Get.find<LocationService>(),
      ),
      fenix: true, // Re-create if disposed
    );

    // Register DoctorListController
    Get.lazyPut(
      () => DoctorListController(
        doctorRepository: Get.find<DoctorRepository>(),
        storageService: Get.find<StorageService>(),
      ),
    );

    // Register DoctorDetailController (will be created when needed)
    Get.lazyPut(
      () => DoctorDetailController(
        doctorRepository: Get.find<DoctorRepository>(),
      ),
    );
  }
}
