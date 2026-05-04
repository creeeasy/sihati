// lib/modules/appointments/bindings/my_appointments_binding.dart
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/appointment_provider.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../controllers/my_appointments_controller.dart';

class MyAppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    // Core services
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }
    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService(), permanent: true);
    }

    // Real Provider
    if (!Get.isRegistered<AppointmentProvider>()) {
      Get.put(
        AppointmentProvider(Get.find<ApiService>()),
        permanent: true,
      );
    }

    // Repository
    if (!Get.isRegistered<AppointmentRepository>()) {
      Get.put(
        AppointmentRepository(
          appointmentProvider: Get.find<AppointmentProvider>(),
        ),
        permanent: true,
      );
    }

    // Controller
    Get.lazyPut<MyAppointmentsController>(
      () => MyAppointmentsController(
        appointmentRepository: Get.find(),
        storageService: Get.find(),
      ),
    );
  }
}
