import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/medication_search_result.dart';
import 'package:sihati_mobile/data/repositories/medication_repository.dart';
import 'package:sihati_mobile/app/routes/app_routes.dart';

class MedicationSearchController extends GetxController {
  final MedicationRepository medicationRepository;

  MedicationSearchController({required this.medicationRepository});

  // State
  final searchResults = <MedicationSearchResult>[].obs;
  final searchController = TextEditingController();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final useLocation = true.obs;
  final hasSearched = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Auto-fill search from arguments (e.g. from AI chat or medication detail)
    final args = Get.arguments;
    if (args is Map && args['searchQuery'] != null) {
      searchController.text = args['searchQuery'] as String;
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
        useLocation: useLocation.value,
      );

      searchResults.value = results;
      hasSearched.value = true;

      if (results.isEmpty) {
        Get.snackbar(
          'Aucun résultat',
          'Aucune pharmacie ne dispose de ce médicament',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors de la recherche: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleLocation() {
    useLocation.value = !useLocation.value;
    if (hasSearched.value && searchResults.isNotEmpty) {
      _reSortResults();
    }
  }

  Future<void> _reSortResults() async {
    if (useLocation.value) {
      try {
        isLoading.value = true;
        final sortedResults = await medicationRepository.sortResultsByDistance(
          searchResults.toList(),
        );
        searchResults.value = sortedResults;
      } catch (e) {
        // Silently fail — keep original order
      } finally {
        isLoading.value = false;
      }
    }
  }

  // ─── Navigation ───────────────────────────────────────────

  void goToPharmacyDetail(int pharmacyId) {
    Get.toNamed('${AppRoutes.PHARMACY_DETAIL}/$pharmacyId');
  }

  void goToMedicationDetail(String medicationName) {
    Get.toNamed(
      AppRoutes.MEDICATION_DETAIL,
      arguments: {'medicationName': medicationName},
    );
  }

  // ─── Helpers ──────────────────────────────────────────────

  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    hasSearched.value = false;
    errorMessage.value = '';
  }

  String getStockMessage(int count) {
    if (count == 0) return 'Non disponible';
    if (count == 1) return 'Disponible dans 1 pharmacie';
    return 'Disponible dans $count pharmacies';
  }
}
