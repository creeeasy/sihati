// lib/modules/appointments/bindings/book_appointment_binding.dart
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/providers/appointment_provider.dart';
import '../../../data/providers/doctor_provider.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../controllers/book_appointment_controller.dart';

class BookAppointmentBinding extends Bindings {
  @override
  void dependencies() {
    // Core services
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }
    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService(), permanent: true);
    }

    // Real Providers
    if (!Get.isRegistered<AppointmentProvider>()) {
      Get.put(
        AppointmentProvider(Get.find<ApiService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<DoctorProvider>()) {
      Get.put(
        DoctorProvider(Get.find<ApiService>()),
        permanent: true,
      );
    }

    // Repository (singleton)
    if (!Get.isRegistered<AppointmentRepository>()) {
      Get.put(
        AppointmentRepository(
          appointmentProvider: Get.find<AppointmentProvider>(),
        ),
        permanent: true,
      );
    }

    // Controller
    Get.lazyPut<BookAppointmentController>(
      () => BookAppointmentController(
        appointmentRepository: Get.find(),
        storageService: Get.find(),
      ),
    );
  }
}
