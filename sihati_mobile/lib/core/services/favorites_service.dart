import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sihati_mobile/core/models/doctor_model.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import '../../app/constants/storage_keys.dart';

/// Favorites service
/// Manages saved pharmacies, doctors, and medications locally
/// Singleton - available app-wide via Get.find<FavoritesService>()
class FavoritesService extends GetxService {
  late SharedPreferences _prefs;

  // Observable lists - UI updates automatically
  final favoritePharmacies = <PharmacyModel>[].obs;
  final favoriteDoctors = <DoctorModel>[].obs;
  final favoriteMedications = <String>[].obs; // medication names

  Future<FavoritesService> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFavorites();
    return this;
  }

  // ─── Load ─────────────────────────────────────────────────────

  Future<void> _loadFavorites() async {
    try {
      final pharmacyJson = _prefs.getString(StorageKeys.FAVORITE_PHARMACIES);
      if (pharmacyJson != null) {
        final List<dynamic> list = json.decode(pharmacyJson);
        favoritePharmacies.value =
            list.map((e) => PharmacyModel.fromJson(e)).toList();
      }

      final doctorJson = _prefs.getString(StorageKeys.FAVORITE_DOCTORS);
      if (doctorJson != null) {
        final List<dynamic> list = json.decode(doctorJson);
        favoriteDoctors.value =
            list.map((e) => DoctorModel.fromJson(e)).toList();
      }

      final medJson = _prefs.getString(StorageKeys.FAVORITE_MEDICATIONS);
      if (medJson != null) {
        final List<dynamic> list = json.decode(medJson);
        favoriteMedications.value = list.cast<String>();
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  // ─── Pharmacies ───────────────────────────────────────────────

  bool isPharmacyFavorite(int pharmacyId) =>
      favoritePharmacies.any((p) => p.id == pharmacyId);

  Future<void> togglePharmacyFavorite(PharmacyModel pharmacy) async {
    try {
      if (isPharmacyFavorite(pharmacy.id)) {
        favoritePharmacies.removeWhere((p) => p.id == pharmacy.id);
        Get.snackbar('Supprimé', '${pharmacy.pharmacyName} retiré des favoris',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2));
      } else {
        favoritePharmacies.add(pharmacy);
        Get.snackbar('Ajouté ❤️', '${pharmacy.pharmacyName} ajouté aux favoris',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2));
      }
      await _savePharmacies();
    } catch (e) {
      print('Error toggling pharmacy favorite: $e');
    }
  }

  Future<void> addPharmacyFavorite(PharmacyModel pharmacy) async {
    if (!isPharmacyFavorite(pharmacy.id)) {
      favoritePharmacies.add(pharmacy);
      await _savePharmacies();
    }
  }

  Future<void> removePharmacyFavorite(int pharmacyId) async {
    favoritePharmacies.removeWhere((p) => p.id == pharmacyId);
    await _savePharmacies();
  }

  Future<void> _savePharmacies() async {
    try {
      final jsonList = favoritePharmacies.map((p) => p.toJson()).toList();
      await _prefs.setString(
          StorageKeys.FAVORITE_PHARMACIES, json.encode(jsonList));
    } catch (e) {
      print('Error saving pharmacies: $e');
    }
  }

  // ─── Doctors ──────────────────────────────────────────────────

  bool isDoctorFavorite(int doctorId) =>
      favoriteDoctors.any((d) => d.id == doctorId);

  Future<void> toggleDoctorFavorite(DoctorModel doctor) async {
    try {
      if (isDoctorFavorite(doctor.id)) {
        favoriteDoctors.removeWhere((d) => d.id == doctor.id);
        Get.snackbar('Supprimé', '${doctor.doctorName} retiré des favoris',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2));
      } else {
        favoriteDoctors.add(doctor);
        Get.snackbar('Ajouté ❤️', '${doctor.doctorName} ajouté aux favoris',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2));
      }
      await _saveDoctors();
    } catch (e) {
      print('Error toggling doctor favorite: $e');
    }
  }

  Future<void> addDoctorFavorite(DoctorModel doctor) async {
    if (!isDoctorFavorite(doctor.id)) {
      favoriteDoctors.add(doctor);
      await _saveDoctors();
    }
  }

  Future<void> removeDoctorFavorite(int doctorId) async {
    favoriteDoctors.removeWhere((d) => d.id == doctorId);
    await _saveDoctors();
  }

  Future<void> _saveDoctors() async {
    try {
      final jsonList = favoriteDoctors.map((d) => d.toJson()).toList();
      await _prefs.setString(
          StorageKeys.FAVORITE_DOCTORS, json.encode(jsonList));
    } catch (e) {
      print('Error saving doctors: $e');
    }
  }

  // ─── Medications ──────────────────────────────────────────────

  bool isMedicationFavorite(String name) => favoriteMedications.contains(name);

  Future<void> toggleMedicationFavorite(String name) async {
    try {
      if (isMedicationFavorite(name)) {
        favoriteMedications.remove(name);
        Get.snackbar('Supprimé', '$name retiré des favoris',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2));
      } else {
        favoriteMedications.add(name);
        Get.snackbar('Ajouté ⭐', '$name ajouté aux favoris',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE8F5E9),
            colorText: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 2));
      }
      await _saveMedications();
    } catch (e) {
      print('Error toggling medication favorite: $e');
    }
  }

  Future<void> _saveMedications() async {
    try {
      await _prefs.setString(StorageKeys.FAVORITE_MEDICATIONS,
          json.encode(favoriteMedications.toList()));
    } catch (e) {
      print('Error saving medications: $e');
    }
  }

  // ─── Counts ───────────────────────────────────────────────────

  int get pharmacyCount => favoritePharmacies.length;
  int get doctorCount => favoriteDoctors.length;
  int get medicationCount => favoriteMedications.length;
  int get totalCount => pharmacyCount + doctorCount + medicationCount;

  // ─── Clear ────────────────────────────────────────────────────

  Future<void> clearAll() async {
    favoritePharmacies.clear();
    favoriteDoctors.clear();
    favoriteMedications.clear();
    await _prefs.remove(StorageKeys.FAVORITE_PHARMACIES);
    await _prefs.remove(StorageKeys.FAVORITE_DOCTORS);
    await _prefs.remove(StorageKeys.FAVORITE_MEDICATIONS);
  }
}
