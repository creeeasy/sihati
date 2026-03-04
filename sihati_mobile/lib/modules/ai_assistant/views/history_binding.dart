import 'package:get/get.dart';
import '../../../core/services/ai_service.dart';
import '../controllers/history_controller.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AIService>(() => AIService());
    Get.lazyPut<HistoryController>(
      () => HistoryController(aiService: Get.find<AIService>()),
    );
  }
}
