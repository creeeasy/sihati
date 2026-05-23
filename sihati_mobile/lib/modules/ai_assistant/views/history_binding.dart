import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../data/providers/ai_provider.dart';
import '../../../data/repositories/ai_repository.dart';
import '../controllers/history_controller.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }
    if (!Get.isRegistered<AiProvider>()) {
      Get.put(AiProvider(Get.find<ApiService>()), permanent: true);
    }
    if (!Get.isRegistered<AiRepository>()) {
      Get.lazyPut(() => AiRepository(aiProvider: Get.find<AiProvider>()), fenix: true);
    }

    Get.lazyPut<HistoryController>(
      () => HistoryController(aiRepository: Get.find<AiRepository>()),
    );
  }
}
