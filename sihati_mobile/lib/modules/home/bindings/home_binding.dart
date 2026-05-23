// lib/modules/home/bindings/home_binding.dart
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/api_service.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/providers/patient_provider.dart';
import '../../../data/repositories/patient_repository.dart';
import '../../../data/providers/appointment_provider.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../../../data/providers/favorite_provider.dart';
import '../../../data/repositories/favorite_repository.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Core services
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }
    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService(), permanent: true);
    }

    // Auth
    if (!Get.isRegistered<AuthProvider>()) {
      Get.lazyPut(() => AuthProvider(Get.find<ApiService>()));
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut(() => AuthRepository(
            authProvider: Get.find<AuthProvider>(),
            storageService: Get.find<StorageService>(),
          ));
    }

    // Patient
    if (!Get.isRegistered<PatientProvider>()) {
      Get.lazyPut(() => PatientProvider(Get.find<ApiService>()));
    }
    if (!Get.isRegistered<PatientRepository>()) {
      Get.lazyPut(() => PatientRepository(
            patientProvider: Get.find<PatientProvider>(),
            storageService: Get.find<StorageService>(),
          ));
    }

    // Appointment
    if (!Get.isRegistered<AppointmentProvider>()) {
      Get.lazyPut(() => AppointmentProvider(Get.find<ApiService>()));
    }
    if (!Get.isRegistered<AppointmentRepository>()) {
      Get.lazyPut(() => AppointmentRepository(
            appointmentProvider: Get.find<AppointmentProvider>(),
          ));
    }

    // Favorite
    if (!Get.isRegistered<FavoriteProvider>()) {
      Get.lazyPut(() => FavoriteProvider(Get.find<ApiService>()));
    }
    if (!Get.isRegistered<FavoriteRepository>()) {
      Get.lazyPut(() => FavoriteRepository(
            favoriteProvider: Get.find<FavoriteProvider>(),
          ));
    }

    // Controller
    Get.lazyPut(() => HomeController(
          authRepository: Get.find<AuthRepository>(),
          patientRepository: Get.find<PatientRepository>(),
          appointmentRepository: Get.find<AppointmentRepository>(),
          favoriteRepository: Get.find<FavoriteRepository>(),
          storageService: Get.find<StorageService>(),
        ));
  }
}
