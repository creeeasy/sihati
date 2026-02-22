import 'package:get/get.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/location_service.dart';
import '../../../data/providers/mock/mock_medication_provider.dart';
import '../../../data/repositories/medication_repository.dart';
import '../controllers/ai_assistant_controller.dart';

class AIAssistantBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<AIService>(() => AIService());
    Get.lazyPut<LocationService>(() => LocationService());

    // Providers
    Get.lazyPut<MockMedicationProvider>(() => MockMedicationProvider());

    // Repository
    Get.lazyPut<MedicationRepository>(() => MedicationRepository(
          medicationProvider: Get.find<MockMedicationProvider>(),
          locationService: Get.find<LocationService>(),
        ));

    // Controller
    Get.lazyPut<AIAssistantController>(() => AIAssistantController(
          aiService: Get.find<AIService>(),
          medicationRepository: Get.find<MedicationRepository>(),
        ));
  }
}
