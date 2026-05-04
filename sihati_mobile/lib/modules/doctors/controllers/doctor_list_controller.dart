// lib/modules/doctors/controllers/doctor_list_controller.dart
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

  // State
  final doctors = <DoctorModel>[].obs;
  final filteredDoctors = <DoctorModel>[].obs;
  final specialties = <SpecialtyModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Filters - ✅ String pour specialtyId (UUID)
  final selectedSpecialtyId = Rxn<String>();
  final selectedWilaya = Rxn<String>();
  final useLocation = false.obs;
  final searchQuery = ''.obs;
  final sortBy = 'distance'.obs;

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
    searchDoctors();
    _loadSavedFilters();
  }

  Future<void> _loadSavedFilters() async {
    final savedWilaya = await storageService.getString(_lastWilayaKey);
    if (savedWilaya != null && savedWilaya.isNotEmpty) {
      selectedWilaya.value = savedWilaya;
      searchDoctors();
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

  /// ✅ CORRIGÉ: Utilise directement String sans conversion
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

      // ✅ Passage direct de selectedSpecialtyId.value (String? UUID)
      final results = await doctorRepository.searchDoctors(
        specialtyId: selectedSpecialtyId.value, // ✅ String? direct
        wilaya: selectedWilaya.value,
        useLocation: useLocation.value,
      );

      doctors.value = results;
      _applyFilters();
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des médecins: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ CORRIGÉ: Accepte String ID
  void filterBySpecialty(String? specialtyId) {
    selectedSpecialtyId.value = specialtyId;
    searchDoctors(refresh: true);
  }

  void filterByWilaya(String? wilaya) {
    selectedWilaya.value = wilaya;
    if (wilaya != null && wilaya.isNotEmpty) {
      storageService.saveString(_lastWilayaKey, wilaya);
    } else {
      storageService.remove(_lastWilayaKey);
    }
    searchDoctors(refresh: true);
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
        'Veuillez activer la localisation pour utiliser le filtre de proximité',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      searchDoctors(refresh: true);
    }
  }

  void searchDoctorsByName(String query) {
    searchQuery.value = query.toLowerCase().trim();
    _applyFilters();
  }

  void clearFilters() {
    selectedSpecialtyId.value = null;
    selectedWilaya.value = null;
    useLocation.value = false;
    searchQuery.value = '';
    sortBy.value = 'distance';
    storageService.remove(_lastWilayaKey);
    searchDoctors(refresh: true);
  }

  void changeSortBy(String sortOption) {
    sortBy.value = sortOption;
    _applySorting();
  }

  void _applyFilters() {
    var results = List<DoctorModel>.from(doctors);

    if (searchQuery.value.isNotEmpty) {
      results = results.where((doctor) {
        return doctor.doctorName.toLowerCase().contains(searchQuery.value) ||
            doctor.specialty.nameFr.toLowerCase().contains(searchQuery.value) ||
            doctor.clinicName.toLowerCase().contains(searchQuery.value);
      }).toList();
    }

    filteredDoctors.value = results;
    _applySorting();
  }

  void _applySorting() {
    var results = List<DoctorModel>.from(filteredDoctors);

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

  /// ✅ CORRIGÉ: String ID
  void goToDoctorDetail(String doctorId) {
    Get.toNamed('${AppRoutes.DOCTOR_DETAIL}/$doctorId');
  }

  /// ✅ CORRIGÉ: String ID
  String getSpecialtyName(String? specialtyId) {
    if (specialtyId == null) return 'Toutes spécialités';
    final specialty = specialties.firstWhereOrNull((s) => s.id == specialtyId);
    return specialty?.nameFr ?? 'Spécialité';
  }

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

  Future<void> refreshData() async {
    await searchDoctors(refresh: true);
  }
}
