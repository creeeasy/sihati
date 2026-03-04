import 'package:get/get.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/location_service.dart';
import '../../../data/providers/mock/mock_medication_provider.dart';
import '../../../data/repositories/medication_repository.dart';
import '../controllers/ai_assistant_controller.dart';

class AIAssistantBinding extends Bindings {
  @override
  void dependencies() {
    final tag = Get.arguments?['tag']?.toString() ?? 'home';

    Get.lazyPut<AIService>(() => AIService());
    Get.lazyPut<LocationService>(() => LocationService());
    Get.lazyPut<MockMedicationProvider>(() => MockMedicationProvider());
    Get.lazyPut<MedicationRepository>(() => MedicationRepository(
          medicationProvider: Get.find<MockMedicationProvider>(),
          locationService: Get.find<LocationService>(),
        ));

    Get.put<AIAssistantController>(
      AIAssistantController(aiService: Get.find<AIService>()),
      tag: tag,
    );
  }
}
