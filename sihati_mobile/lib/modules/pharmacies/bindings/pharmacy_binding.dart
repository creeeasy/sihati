import 'package:get/get.dart';
import '../../../core/services/location_service.dart';
import '../../../data/providers/mock/mock_pharmacy_provider.dart';
import '../../../data/repositories/pharmacy_repository.dart';
import '../controllers/pharmacy_list_controller.dart';
import '../controllers/pharmacy_detail_controller.dart';
import '../controllers/duty_pharmacy_controller.dart';

class PharmacyBinding extends Bindings {
  @override
  void dependencies() {
    // Provider
    if (!Get.isRegistered<MockPharmacyProvider>()) {
      Get.lazyPut(() => MockPharmacyProvider());
    }

    // Repository
    if (!Get.isRegistered<PharmacyRepository>()) {
      Get.lazyPut(() => PharmacyRepository(
            pharmacyProvider: Get.find(),
            locationService: Get.find<LocationService>(),
          ));
    }

    // Controllers
    Get.lazyPut(() => PharmacyListController(
          pharmacyRepository: Get.find(),
        ));

    Get.lazyPut(() => PharmacyDetailController(
          pharmacyRepository: Get.find(),
        ));

    Get.lazyPut(() => DutyPharmacyController(
          pharmacyRepository: Get.find(),
        ));
  }
}
