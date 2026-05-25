import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/medication_model.dart';
import 'package:sihati_mobile/data/repositories/medication_repository.dart';
import 'package:sihati_mobile/app/routes/app_routes.dart';

class MedicationSearchController extends GetxController {
  final MedicationRepository medicationRepository;

  MedicationSearchController({required this.medicationRepository});

  final searchResults = <MedicationModel>[].obs;
  final searchController = TextEditingController();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final hasSearched = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['searchQuery'] != null) {
      searchController.text = args['searchQuery'] as String;
      searchMedication();
    } else if (args is String) {
      searchController.text = args;
      searchMedication();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> searchMedication() async {
    final query = searchController.text.trim();

    if (query.length < 2) {
      Get.snackbar(
        'Erreur de recherche',
        'Veuillez saisir au moins 2 caractères',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isLoading.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final results = await medicationRepository.searchMedication(
        query,
        useLocation: false,
      );

      searchResults.value = results;
      hasSearched.value = true;

      if (results.isEmpty) {
        Get.snackbar(
          'Aucun résultat',
          'Aucun médicament trouvé',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors de la recherche: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void goToMedicationDetail(String medicationId) {
    Get.toNamed('${AppRoutes.MEDICATION_DETAIL}/$medicationId');
  }

  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    hasSearched.value = false;
    errorMessage.value = '';
  }
}
