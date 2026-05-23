// lib/modules/ai_assistant/bindings/ai_assistant_binding.dart
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../data/providers/ai_provider.dart';
import '../../../data/repositories/ai_repository.dart';
import '../controllers/ai_assistant_controller.dart';

class AIAssistantBinding extends Bindings {
  @override
  void dependencies() {
    final tag = Get.arguments?['tag']?.toString() ?? 'home';

    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    if (!Get.isRegistered<AiProvider>()) {
      Get.put(AiProvider(Get.find<ApiService>()), permanent: true);
    }

    if (!Get.isRegistered<AiRepository>()) {
      Get.lazyPut(() => AiRepository(aiProvider: Get.find<AiProvider>()), fenix: true);
    }

    Get.put<AIAssistantController>(
      AIAssistantController(aiRepository: Get.find<AiRepository>()),
      tag: tag,
    );
  }
}
