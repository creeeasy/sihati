import 'package:get/get.dart';
import 'package:sihati_mobile/core/services/notification_service.dart';
import '../../../core/services/ai_service.dart';
import '../controllers/medication_detail_controller.dart';

class MedicationDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AIService>(() => AIService());
    Get.lazyPut<NotificationService>(() => NotificationService());

    Get.delete<MedicationDetailController>(force: true);
    Get.put<MedicationDetailController>(
      MedicationDetailController(aiService: Get.find<AIService>()),
    );
  }
}
