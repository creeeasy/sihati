// lib/modules/ai_assistant/bindings/ai_assistant_binding.dart
import 'package:get/get.dart';
import '../../../core/services/ai_service.dart';
import '../controllers/ai_assistant_controller.dart';

class AIAssistantBinding extends Bindings {
  @override
  void dependencies() {
    final tag = Get.arguments?['tag']?.toString() ?? 'home';

    if (!Get.isRegistered<AIService>()) {
      Get.put(AIService(), permanent: true);
    }

    Get.put<AIAssistantController>(
      AIAssistantController(aiService: Get.find<AIService>()),
      tag: tag,
    );
  }
}
