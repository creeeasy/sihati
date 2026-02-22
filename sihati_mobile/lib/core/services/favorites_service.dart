import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sihati_mobile/core/models/doctor_model.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import '../../app/constants/storage_keys.dart';

/// Favorites service
/// Manages saved pharmacies and doctors locally
/// Singleton - available app-wide via Get.find<FavoritesService>()
class FavoritesService extends GetxService {
  late SharedPreferences _prefs;

  // Observable lists - UI updates automatically
  final favoritePharmacies = <PharmacyModel>[].obs;
  final favoriteDoctors = <DoctorModel>[].obs;

  Future<FavoritesService> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFavorites();
    return this;
  }

  // ==================== LOAD ====================

  Future<void> _loadFavorites() async {
    try {
      // Load pharmacies
      final pharmacyJson = _prefs.getString(StorageKeys.FAVORITE_PHARMACIES);
      if (pharmacyJson != null) {
        final List<dynamic> list = json.decode(pharmacyJson);
        favoritePharmacies.value =
            list.map((e) => PharmacyModel.fromJson(e)).toList();
      }

      // Load doctors
      final doctorJson = _prefs.getString(StorageKeys.FAVORITE_DOCTORS);
      if (doctorJson != null) {
        final List<dynamic> list = json.decode(doctorJson);
        favoriteDoctors.value =
            list.map((e) => DoctorModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  // ==================== PHARMACIES ====================

  /// Check if pharmacy is favorited
  bool isPharmacyFavorite(int pharmacyId) {
    return favoritePharmacies.any((p) => p.id == pharmacyId);
  }

  /// Toggle pharmacy favorite
  Future<void> togglePharmacyFavorite(PharmacyModel pharmacy) async {
    try {
      if (isPharmacyFavorite(pharmacy.id)) {
        // Remove
        favoritePharmacies.removeWhere((p) => p.id == pharmacy.id);
        Get.snackbar(
          'Supprimé',
          '${pharmacy.pharmacyName} retiré des favoris',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        // Add
        favoritePharmacies.add(pharmacy);
        Get.snackbar(
          'Ajouté ❤️',
          '${pharmacy.pharmacyName} ajouté aux favoris',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
      await _savePharmacies();
    } catch (e) {
      print('Error toggling pharmacy favorite: $e');
    }
  }

  /// Add pharmacy to favorites
  Future<void> addPharmacyFavorite(PharmacyModel pharmacy) async {
    if (!isPharmacyFavorite(pharmacy.id)) {
      favoritePharmacies.add(pharmacy);
      await _savePharmacies();
    }
  }

  /// Remove pharmacy from favorites
  Future<void> removePharmacyFavorite(int pharmacyId) async {
    favoritePharmacies.removeWhere((p) => p.id == pharmacyId);
    await _savePharmacies();
  }

  Future<void> _savePharmacies() async {
    try {
      final jsonList = favoritePharmacies.map((p) => p.toJson()).toList();
      await _prefs.setString(
        StorageKeys.FAVORITE_PHARMACIES,
        json.encode(jsonList),
      );
    } catch (e) {
      print('Error saving pharmacies: $e');
    }
  }

  // ==================== DOCTORS ====================

  /// Check if doctor is favorited
  bool isDoctorFavorite(int doctorId) {
    return favoriteDoctors.any((d) => d.id == doctorId);
  }

  /// Toggle doctor favorite
  Future<void> toggleDoctorFavorite(DoctorModel doctor) async {
    try {
      if (isDoctorFavorite(doctor.id)) {
        // Remove
        favoriteDoctors.removeWhere((d) => d.id == doctor.id);
        Get.snackbar(
          'Supprimé',
          '${doctor.doctorName} retiré des favoris',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        // Add
        favoriteDoctors.add(doctor);
        Get.snackbar(
          'Ajouté ❤️',
          '${doctor.doctorName} ajouté aux favoris',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
      await _saveDoctors();
    } catch (e) {
      print('Error toggling doctor favorite: $e');
    }
  }

  /// Add doctor to favorites
  Future<void> addDoctorFavorite(DoctorModel doctor) async {
    if (!isDoctorFavorite(doctor.id)) {
      favoriteDoctors.add(doctor);
      await _saveDoctors();
    }
  }

  /// Remove doctor from favorites
  Future<void> removeDoctorFavorite(int doctorId) async {
    favoriteDoctors.removeWhere((d) => d.id == doctorId);
    await _saveDoctors();
  }

  Future<void> _saveDoctors() async {
    try {
      final jsonList = favoriteDoctors.map((d) => d.toJson()).toList();
      await _prefs.setString(
        StorageKeys.FAVORITE_DOCTORS,
        json.encode(jsonList),
      );
    } catch (e) {
      print('Error saving doctors: $e');
    }
  }

  // ==================== COUNTS ====================

  int get pharmacyCount => favoritePharmacies.length;
  int get doctorCount => favoriteDoctors.length;
  int get totalCount => pharmacyCount + doctorCount;

  // ==================== CLEAR ====================

  Future<void> clearAll() async {
    favoritePharmacies.clear();
    favoriteDoctors.clear();
    await _prefs.remove(StorageKeys.FAVORITE_PHARMACIES);
    await _prefs.remove(StorageKeys.FAVORITE_DOCTORS);
  }
}
