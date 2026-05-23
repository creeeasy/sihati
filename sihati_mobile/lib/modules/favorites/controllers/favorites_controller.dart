import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/doctor_model.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import 'package:sihati_mobile/data/repositories/favorite_repository.dart';
import 'package:sihati_mobile/app/routes/app_routes.dart';

class FavoritesController extends GetxController {
  final FavoriteRepository favoriteRepository;

  FavoritesController({required this.favoriteRepository});

  final favoritePharmacies = <PharmacyModel>[].obs;
  final favoriteDoctors = <DoctorModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  int get pharmacyCount => favoritePharmacies.length;
  int get doctorCount => favoriteDoctors.length;
  int get totalCount => pharmacyCount + doctorCount;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final pharmacies = await favoriteRepository.getFavoritePharmacies();
      final doctors = await favoriteRepository.getFavoriteDoctors();

      favoritePharmacies.value = pharmacies;
      favoriteDoctors.value = doctors;
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des favoris: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removePharmacyFavorite(String pharmacyId) async {
    try {
      final success = await favoriteRepository.removeFavoritePharmacy(pharmacyId);
      if (success) {
        favoritePharmacies.removeWhere((p) => p.id == pharmacyId);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de retirer la pharmacie des favoris',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeDoctorFavorite(String doctorId) async {
    try {
      final success = await favoriteRepository.removeFavoriteDoctor(doctorId);
      if (success) {
        favoriteDoctors.removeWhere((d) => d.id == doctorId);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de retirer le médecin des favoris',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> clearAll() async {
    // There is no bulk delete on the backend per the repository. 
    // We would have to delete one by one.
    // For now, let's delete them individually if the user confirms.
    try {
      isLoading.value = true;
      for (var pharmacy in favoritePharmacies) {
        await favoriteRepository.removeFavoritePharmacy(pharmacy.id);
      }
      for (var doctor in favoriteDoctors) {
        await favoriteRepository.removeFavoriteDoctor(doctor.id);
      }
      
      favoritePharmacies.clear();
      favoriteDoctors.clear();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer tous les favoris',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
