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
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Search medication
  // In MedicationSearchController, update searchMedication method:

  Future<void> searchMedication() async {
    final query = searchController.text.trim();

    // Validate search term (min 2 characters)
    if (query.length < 2) {
      Get.snackbar(
        'Erreur de recherche',
        'Veuillez saisir au moins 2 caractères',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Don't start another search if already loading
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

  // Toggle location usage
  void toggleLocation() {
    useLocation.value = !useLocation.value;
    // If we already have results, re-sort them based on location preference
    if (hasSearched.value && searchResults.isNotEmpty) {
      _reSortResults();
    }
  }

  // Re-sort results based on location preference
  Future<void> _reSortResults() async {
    if (useLocation.value) {
      // Get current location and re-sort
      try {
        isLoading.value = true;
        final sortedResults = await medicationRepository.sortResultsByDistance(
          searchResults.toList(),
        );
        searchResults.value = sortedResults;
      } catch (e) {
        // Silently fail - keep original order
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Navigate to pharmacy detail
  void goToPharmacyDetail(int pharmacyId) {
    Get.toNamed('${AppRoutes.PHARMACY_DETAIL}/$pharmacyId');
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    hasSearched.value = false;
    errorMessage.value = '';
  }

  // Get stock status message
  String getStockMessage(int count) {
    if (count == 0) return 'Non disponible';
    if (count == 1) return 'Disponible dans 1 pharmacie';
    return 'Disponible dans $count pharmacies';
  }
}
