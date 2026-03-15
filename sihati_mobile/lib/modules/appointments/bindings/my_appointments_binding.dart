import 'package:get/get.dart';
import 'package:sihati_mobile/data/providers/mock/mock_appointment_provider.dart';
import 'package:sihati_mobile/data/providers/mock/mock_doctor_provider.dart';
import 'package:sihati_mobile/data/repositories/appointment_repository.dart';
import '../controllers/my_appointments_controller.dart';

class MyAppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    // Register MockDoctorProvider if not already registered
    if (!Get.isRegistered<MockDoctorProvider>()) {
      Get.put(MockDoctorProvider(), permanent: true);
    }

    // Register MockAppointmentProvider if not already registered
    if (!Get.isRegistered<MockAppointmentProvider>()) {
      Get.put(
          MockAppointmentProvider(
            doctorProvider: Get.find<MockDoctorProvider>(),
          ),
          permanent: true);
    }

    // Register AppointmentRepository if not already registered
    if (!Get.isRegistered<AppointmentRepository>()) {
      Get.put(
        AppointmentRepository(
          appointmentProvider: Get.find<MockAppointmentProvider>(),
        ),
        permanent: true,
      );
    }
    Get.lazyPut<MyAppointmentsController>(
      () => MyAppointmentsController(
        appointmentRepository: Get.find(),
        storageService: Get.find(),
      ),
    );
  }
}
