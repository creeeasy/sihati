import 'package:get/get.dart';
import 'package:sihati_mobile/data/providers/mock/mock_appointment_provider.dart';
import 'package:sihati_mobile/data/providers/mock/mock_doctor_provider.dart';
import 'package:sihati_mobile/data/repositories/appointment_repository.dart';

import '../controllers/book_appointment_controller.dart';

class BookAppointmentBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize appointment provider
    final appointmentProvider = MockAppointmentProvider(
      doctorProvider: Get.find<MockDoctorProvider>(),
    );

    // Initialize appointment repository (singleton)
    Get.put(
      AppointmentRepository(
        appointmentProvider: appointmentProvider,
      ),
      permanent: true,
    );

    // Controller
    Get.lazyPut<BookAppointmentController>(
      () => BookAppointmentController(
        appointmentRepository: Get.find(),
        storageService: Get.find(),
      ),
    );
  }
}
