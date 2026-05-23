// lib/modules/medications/controllers/medications_list_controller.dart
import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/medication_model.dart';
import 'package:sihati_mobile/data/repositories/medication_repository.dart';
import 'package:sihati_mobile/app/routes/app_routes.dart';

class MedicationsListController extends GetxController {
  final MedicationRepository medicationRepository;

  MedicationsListController({required this.medicationRepository});

  final medications = <MedicationModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMedications();
  }

  Future<void> loadMedications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final results =
          await medicationRepository.getAllMedications(page: 1, limit: 50);
      medications.value = results;
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des médicaments: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void goToMedicationDetail(String medicationId) {
    Get.toNamed('${AppRoutes.MEDICATION_DETAIL}/$medicationId');
  }

  void refreshMedications() {
    loadMedications();
  }
}
