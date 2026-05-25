// lib/modules/doctors/controllers/doctor_list_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/doctor_model.dart';
import 'package:sihati_mobile/core/models/specialty_model.dart';
import 'package:sihati_mobile/data/repositories/doctor_repository.dart';
import 'package:sihati_mobile/app/routes/app_routes.dart';
import 'package:sihati_mobile/core/services/storage_service.dart';

class DoctorListController extends GetxController {
  final DoctorRepository doctorRepository;
  final StorageService storageService;

  final String _lastWilayaKey = 'last_wilaya_filter';

  DoctorListController({
    required this.doctorRepository,
    required this.storageService,
  });

  // ─── State ───────────────────────────────────────────────────
  final doctors = <DoctorModel>[].obs;
  final filteredDoctors = <DoctorModel>[].obs;
  final topRatedDoctors = <DoctorModel>[].obs; // ← getTopRatedDoctors
  final specialties = <SpecialtyModel>[].obs;
  final isLoading = false.obs;
  final isTopRatedLoading = false.obs;
  final isNameSearchLoading = false.obs; // spinner for backend search
  final errorMessage = ''.obs;

  // ─── Filters ─────────────────────────────────────────────────
  final selectedSpecialtyId = Rxn<String>();
  final selectedWilaya = Rxn<String>();
  final useLocation = false.obs;
  final searchQuery = ''.obs;
  final sortBy = 'distance'.obs;

  // ─── View mode ───────────────────────────────────────────────
  /// 'all' | 'top_rated' | 'by_specialty' | 'by_wilaya' | 'search'
  final viewMode = 'all'.obs;

  // ─── Debounce ────────────────────────────────────────────────
  Timer? _searchDebounce;

  // ─── Pagination ──────────────────────────────────────────────
  final currentPage = 1.obs;
  final hasMorePages = true.obs;
  final pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    loadSpecialties();
    loadAllDoctors(); // getAllDoctors wired here
    loadTopRatedDoctors(); // getTopRatedDoctors wired here
    _loadSavedFilters();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════
  // LOADERS
  // ═══════════════════════════════════════════════════════════════

  /// getAllDoctors — default view
  Future<void> loadAllDoctors() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      viewMode.value = 'all';

      final results = await doctorRepository.getAllDoctors();
      doctors.value = results;
      _applyFilters();
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// getTopRatedDoctors — horizontal strip at top
  Future<void> loadTopRatedDoctors() async {
    try {
      isTopRatedLoading.value = true;
      final results = await doctorRepository.getTopRatedDoctors(limit: 6);
      topRatedDoctors.value = results;
    } catch (e) {
      print('Top rated load error: $e');
    } finally {
      isTopRatedLoading.value = false;
    }
  }

  Future<void> loadSpecialties() async {
    try {
      final specs = await doctorRepository.getSpecialties();
      specialties.value = specs;
    } catch (e) {
      print('Error loading specialties: $e');
    }
  }

  Future<void> _loadSavedFilters() async {
    final savedWilaya = await storageService.getString(_lastWilayaKey);
    if (savedWilaya != null && savedWilaya.isNotEmpty) {
      selectedWilaya.value = savedWilaya;
      await filterByWilaya(savedWilaya);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // SEARCH  — backend searchByName with 500ms debounce
  // ═══════════════════════════════════════════════════════════════

  void searchDoctorsByName(String query) {
    searchQuery.value = query.trim();

    _searchDebounce?.cancel();

    if (query.trim().isEmpty) {
      // Back to full list
      _applyFilters();
      viewMode.value = 'all';
      return;
    }

    if (query.trim().length < 2) {
      _applyClientSideSearch(query.trim());
      return;
    }

    // Debounced backend call — searchByName
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        isNameSearchLoading.value = true;
        viewMode.value = 'search';

        final results = await doctorRepository.searchByName(query.trim());
        doctors.value = results;
        filteredDoctors.value = results;
      } catch (e) {
        // Fallback to client-side
        _applyClientSideSearch(query.trim());
      } finally {
        isNameSearchLoading.value = false;
      }
    });
  }

  void _applyClientSideSearch(String query) {
    final lower = query.toLowerCase();
    filteredDoctors.value = doctors.where((d) {
      return d.doctorName.toLowerCase().contains(lower) ||
          (d.specialty?.nameFr.toLowerCase().contains(lower) ?? false) ||
          d.clinicName.toLowerCase().contains(lower);
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // FILTERS
  // ═══════════════════════════════════════════════════════════════

  /// getDoctorsBySpecialty — called when user picks a specialty
  Future<void> filterBySpecialty(String? specialtyId) async {
    selectedSpecialtyId.value = specialtyId;
    searchQuery.value = '';

    if (specialtyId == null) {
      viewMode.value = 'all';
      await loadAllDoctors();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      viewMode.value = 'by_specialty';

      // getDoctorsBySpecialty wired here
      final results = await doctorRepository.getDoctorsBySpecialty(specialtyId);
      doctors.value = results;
      filteredDoctors.value = results;
      _applySorting();
    } catch (e) {
      errorMessage.value = 'Erreur lors du filtrage: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// getDoctorsByWilaya — called when user picks a wilaya
  Future<void> filterByWilaya(String? wilaya) async {
    selectedWilaya.value = wilaya;
    searchQuery.value = '';

    if (wilaya == null || wilaya.isEmpty) {
      storageService.remove(_lastWilayaKey);
      viewMode.value = 'all';
      await loadAllDoctors();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      viewMode.value = 'by_wilaya';

      // getDoctorsByWilaya wired here
      final results = await doctorRepository.getDoctorsByWilaya(wilaya);
      doctors.value = results;
      filteredDoctors.value = results;
      _applySorting();

      storageService.saveString(_lastWilayaKey, wilaya);
    } catch (e) {
      errorMessage.value = 'Erreur lors du filtrage par wilaya: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// searchDoctors — used when location + specialty combined
  Future<void> searchDoctors({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMorePages.value = true;
      doctors.clear();
    }

    if (isLoading.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      viewMode.value = 'all';

      final results = await doctorRepository.searchDoctors(
        specialtyId: selectedSpecialtyId.value,
        wilaya: selectedWilaya.value,
        useLocation: useLocation.value,
      );

      doctors.value = results;
      _applyFilters();
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleNearbyFilter() {
    useLocation.value = !useLocation.value;
    if (useLocation.value) {
      _requestLocationPermission();
    } else {
      searchDoctors(refresh: true);
    }
  }

  Future<void> _requestLocationPermission() async {
    final granted = await doctorRepository.requestLocationPermission();
    if (!granted) {
      useLocation.value = false;
      Get.snackbar(
        'Permission requise',
        'Veuillez activer la localisation',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      searchDoctors(refresh: true);
    }
  }

  void clearFilters() {
    selectedSpecialtyId.value = null;
    selectedWilaya.value = null;
    useLocation.value = false;
    searchQuery.value = '';
    sortBy.value = 'distance';
    viewMode.value = 'all';
    storageService.remove(_lastWilayaKey);
    loadAllDoctors();
  }

  void changeSortBy(String sortOption) {
    sortBy.value = sortOption;
    _applySorting();
  }

  void _applyFilters() {
    var results = List<DoctorModel>.from(doctors);

    if (searchQuery.value.isNotEmpty) {
      final lower = searchQuery.value.toLowerCase();
      results = results.where((d) {
        return d.doctorName.toLowerCase().contains(lower) ||
            (d.specialty?.nameFr.toLowerCase().contains(lower) ?? false) ||
            d.clinicName.toLowerCase().contains(lower);
      }).toList();
    }

    filteredDoctors.value = results;
    _applySorting();
  }

  void _applySorting() {
    var results = List<DoctorModel>.from(filteredDoctors);

    switch (sortBy.value) {
      case 'rating':
        filteredDoctors.value = doctorRepository.sortByRating(results);
        break;
      case 'fee':
        filteredDoctors.value = doctorRepository.sortByFee(results);
        break;
      case 'experience':
        filteredDoctors.value = doctorRepository.sortByExperience(results);
        break;
      case 'distance':
      default:
        if (useLocation.value) {
          doctorRepository.sortByDistance(results).then((sorted) {
            filteredDoctors.value = sorted;
          });
        } else {
          filteredDoctors.value = results;
        }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════

  void goToDoctorDetail(String doctorId) {
    Get.toNamed('${AppRoutes.DOCTOR_DETAIL}/$doctorId');
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  String getSpecialtyName(String? specialtyId) {
    if (specialtyId == null) return 'Toutes spécialités';
    final s = specialties.firstWhereOrNull((s) => s.id == specialtyId);
    return s?.nameFr ?? 'Spécialité';
  }

  String getFilterSummary() {
    final parts = <String>[];
    if (selectedSpecialtyId.value != null) {
      parts.add(getSpecialtyName(selectedSpecialtyId.value));
    }
    if (selectedWilaya.value != null && selectedWilaya.value!.isNotEmpty) {
      parts.add(selectedWilaya.value!);
    }
    if (useLocation.value) parts.add('À proximité');
    if (searchQuery.value.isNotEmpty) parts.add('"${searchQuery.value}"');
    return parts.isEmpty ? 'Tous les médecins' : parts.join(' • ');
  }

  String get viewModeLabel {
    switch (viewMode.value) {
      case 'top_rated':
        return 'Mieux notés';
      case 'by_specialty':
        return getSpecialtyName(selectedSpecialtyId.value);
      case 'by_wilaya':
        return selectedWilaya.value ?? '';
      case 'search':
        return 'Résultats: "${searchQuery.value}"';
      default:
        return 'Tous les médecins';
    }
  }

  bool get hasActiveFilters =>
      selectedSpecialtyId.value != null ||
      (selectedWilaya.value != null && selectedWilaya.value!.isNotEmpty) ||
      useLocation.value ||
      searchQuery.value.isNotEmpty;

  Future<void> refreshData() async {
    await loadAllDoctors();
    await loadTopRatedDoctors();
  }
}
