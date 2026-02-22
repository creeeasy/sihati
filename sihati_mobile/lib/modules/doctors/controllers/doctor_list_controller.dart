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

  // Custom storage key for wilaya filter
  final String _lastWilayaKey = 'last_wilaya_filter';

  DoctorListController({
    required this.doctorRepository,
    required this.storageService,
  });

  // State
  final doctors = <DoctorModel>[].obs;
  final filteredDoctors = <DoctorModel>[].obs;
  final specialties = <SpecialtyModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Filters
  final selectedSpecialtyId = Rxn<int>();
  final selectedWilaya = Rxn<String>();
  final useLocation = false.obs;
  final searchQuery = ''.obs;
  final sortBy = 'distance'.obs; // 'distance', 'rating', 'fee', 'experience'

  // Pagination
  final currentPage = 1.obs;
  final hasMorePages = true.obs;
  final pageSize = 10;

  // Wilaya list for Algeria
  final List<String> algerianWilayas = [
    'Adrar',
    'Chlef',
    'Laghouat',
    'Oum El Bouaghi',
    'Batna',
    'Béjaïa',
    'Biskra',
    'Béchar',
    'Blida',
    'Bouira',
    'Tamanrasset',
    'Tébessa',
    'Tlemcen',
    'Tiaret',
    'Tizi Ouzou',
    'Alger',
    'Djelfa',
    'Jijel',
    'Sétif',
    'Saïda',
    'Skikda',
    'Sidi Bel Abbès',
    'Annaba',
    'Guelma',
    'Constantine',
    'Médéa',
    'Mostaganem',
    'M\'Sila',
    'Mascara',
    'Ouargla',
    'Oran',
    'El Bayadh',
    'Illizi',
    'Bordj Bou Arreridj',
    'Boumerdès',
    'El Tarf',
    'Tindouf',
    'Tissemsilt',
    'El Oued',
    'Khenchela',
    'Souk Ahras',
    'Tipaza',
    'Mila',
    'Aïn Defla',
    'Naâma',
    'Aïn Témouchent',
    'Ghardaïa',
    'Relizane'
  ];

  @override
  void onInit() {
    super.onInit();
    loadSpecialties();
    searchDoctors(); // Initial load with current filters

    // Load last used filters from storage (async)
    _loadSavedFilters();
  }

  Future<void> _loadSavedFilters() async {
    final savedWilaya = await storageService.getString(_lastWilayaKey);
    if (savedWilaya != null && savedWilaya.isNotEmpty) {
      selectedWilaya.value = savedWilaya;
      // Reload with saved wilaya
      searchDoctors();
    }
  }

  // Load specialties
  Future<void> loadSpecialties() async {
    try {
      final specs = await doctorRepository.getSpecialties();
      specialties.value = specs;
    } catch (e) {
      print('Error loading specialties: $e');
    }
  }

  // Search doctors with current filters
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

      // Call the repository's searchDoctors method with current filters
      final results = await doctorRepository.searchDoctors(
        specialtyId: selectedSpecialtyId.value,
        wilaya: selectedWilaya.value,
        useLocation: useLocation.value,
      );

      doctors.value = results;
      _applyFilters(); // Apply search query and sorting
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des médecins: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Filter by specialty
  void filterBySpecialty(int? specialtyId) {
    selectedSpecialtyId.value = specialtyId;
    searchDoctors(refresh: true);
  }

  // Filter by wilaya
  void filterByWilaya(String? wilaya) {
    selectedWilaya.value = wilaya;
    if (wilaya != null && wilaya.isNotEmpty) {
      storageService.saveString(_lastWilayaKey, wilaya);
    } else {
      storageService.remove(_lastWilayaKey);
    }
    searchDoctors(refresh: true);
  }

  // Toggle nearby filter
  void toggleNearbyFilter() {
    useLocation.value = !useLocation.value;
    if (useLocation.value) {
      _requestLocationPermission();
    } else {
      searchDoctors(refresh: true);
    }
  }

  // Request location permission
  Future<void> _requestLocationPermission() async {
    final granted = await doctorRepository.requestLocationPermission();
    if (!granted) {
      useLocation.value = false;
      Get.snackbar(
        'Permission requise',
        'Veuillez activer la localisation pour utiliser le filtre de proximité',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      searchDoctors(refresh: true);
    }
  }

  // Search doctors by name (local filtering)
  void searchDoctorsByName(String query) {
    searchQuery.value = query.toLowerCase().trim();
    _applyFilters();
  }

  // Clear all filters
  void clearFilters() {
    selectedSpecialtyId.value = null;
    selectedWilaya.value = null;
    useLocation.value = false;
    searchQuery.value = '';
    sortBy.value = 'distance';
    storageService.remove(_lastWilayaKey);
    searchDoctors(refresh: true);
  }

  // Change sort order
  void changeSortBy(String sortOption) {
    sortBy.value = sortOption;
    _applySorting();
  }

  // Apply search query filter and sorting to the doctors list
  void _applyFilters() {
    var results = List<DoctorModel>.from(doctors);

    // Apply search query (local filtering)
    if (searchQuery.value.isNotEmpty) {
      results = results.where((doctor) {
        return doctor.doctorName.toLowerCase().contains(searchQuery.value) ||
            doctor.specialty.nameFr.toLowerCase().contains(searchQuery.value) ||
            (doctor.clinicName.toLowerCase().contains(searchQuery.value));
      }).toList();
    }

    // Update filteredDoctors
    filteredDoctors.value = results;

    // Apply sorting
    _applySorting();
  }

  // Apply sorting to filteredDoctors
  void _applySorting() {
    var results = List<DoctorModel>.from(filteredDoctors);

    // Apply sorting based on selected option
    switch (sortBy.value) {
      case 'rating':
        results = doctorRepository.sortByRating(results);
        filteredDoctors.value = results;
        break;
      case 'fee':
        results = doctorRepository.sortByFee(results);
        filteredDoctors.value = results;
        break;
      case 'experience':
        results = doctorRepository.sortByExperience(results);
        filteredDoctors.value = results;
        break;
      case 'distance':
      default:
        // Sort by distance if location is enabled, otherwise keep as is
        if (useLocation.value) {
          doctorRepository.sortByDistance(results).then((sorted) {
            filteredDoctors.value = sorted;
          });
        } else {
          filteredDoctors.value = results;
        }
        break;
    }
  }

  // Navigate to doctor detail
  void goToDoctorDetail(int doctorId) {
    Get.toNamed('${AppRoutes.DOCTOR_DETAIL}/$doctorId');
  }

  // Get specialty name by ID
  String getSpecialtyName(int? specialtyId) {
    if (specialtyId == null) return 'Toutes spécialités';
    final specialty = specialties.firstWhereOrNull((s) => s.id == specialtyId);
    return specialty?.nameFr ?? 'Spécialité';
  }

  // Get filter summary text
  String getFilterSummary() {
    List<String> parts = [];
    if (selectedSpecialtyId.value != null) {
      parts.add(getSpecialtyName(selectedSpecialtyId.value));
    }
    if (selectedWilaya.value != null && selectedWilaya.value!.isNotEmpty) {
      parts.add(selectedWilaya.value!);
    }
    if (useLocation.value) {
      parts.add('À proximité');
    }
    if (searchQuery.value.isNotEmpty) {
      parts.add('"${searchQuery.value}"');
    }
    return parts.isEmpty ? 'Tous les médecins' : parts.join(' • ');
  }

  // Refresh data (pull-to-refresh)
  Future<void> refreshData() async {
    await searchDoctors(refresh: true);
  }
}
