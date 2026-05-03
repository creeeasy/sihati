import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import '../../../data/repositories/pharmacy_repository.dart';
import '../../../app/routes/app_routes.dart';

class PharmacyListController extends GetxController {
  final PharmacyRepository pharmacyRepository;

  PharmacyListController({required this.pharmacyRepository});

  final pharmacies = <PharmacyModel>[].obs;
  final filteredPharmacies = <PharmacyModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedWilaya = Rxn<String>();
  final showNearbyOnly = false.obs;
  final showActiveOnly = false.obs;
  final searchQuery = ''.obs;
  final isSearchFocused = false.obs;

  final List<String> wilayas = [
    'Tous',
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
    'Bordj Bou Arréridj',
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

  int get activeFiltersCount {
    int count = 0;
    if (showActiveOnly.value) count++;
    if (showNearbyOnly.value) count++;
    if (selectedWilaya.value != null && selectedWilaya.value != 'Tous') count++;
    if (searchQuery.value.isNotEmpty) count++;
    return count;
  }

  String get activePharmaciesCount {
    final openCount = pharmacies.where((p) => p.isOpenNow).length;
    return '$openCount ouvertes sur ${pharmacies.length}';
  }

  @override
  void onInit() {
    super.onInit();
    loadPharmacies();
  }

  Future<void> loadPharmacies() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (showNearbyOnly.value) {
        await loadNearbyPharmacies();
      } else {
        final wilaya = selectedWilaya.value;
        final result = await pharmacyRepository.getAllPharmacies(
          wilaya: (wilaya == null || wilaya == 'Tous') ? null : wilaya,
        );
        pharmacies.value = result;
      }

      _applyFilters();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Erreur', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadNearbyPharmacies() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await pharmacyRepository.getNearbyPharmacies(radius: 10);
      pharmacies.value = result;
      _applyFilters();
      Get.snackbar(
          'Succès', '${result.length} pharmacie(s) trouvée(s) à proximité',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.value.contains('permission')) {
        Get.snackbar('Permission requise',
            'Activez la localisation pour voir les pharmacies proches',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4));
      } else {
        Get.snackbar('Erreur', errorMessage.value,
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void filterByWilaya(String? wilaya) {
    selectedWilaya.value = wilaya;
    showNearbyOnly.value = false;
    loadPharmacies();
  }

  void toggleNearbyFilter() {
    showNearbyOnly.value = !showNearbyOnly.value;
    if (showNearbyOnly.value) {
      selectedWilaya.value = null;
    }
    loadPharmacies();
  }

  void toggleActiveFilter() {
    showActiveOnly.value = !showActiveOnly.value;
    _applyFilters();
  }

  void showOnlyOpenPharmacies() {
    if (showActiveOnly.value) {
      clearFilters();
    } else {
      showActiveOnly.value = true;
      showNearbyOnly.value = false;
      selectedWilaya.value = null;
      searchQuery.value = '';
      _applyFilters();
    }
  }

  void searchPharmacies(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    var results = pharmacies.toList();

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      results = results.where((pharmacy) {
        return pharmacy.pharmacyName.toLowerCase().contains(query) ||
            pharmacy.address.toLowerCase().contains(query) ||
            pharmacy.wilaya.toLowerCase().contains(query);
      }).toList();
    }

    if (showActiveOnly.value) {
      results = results.where((pharmacy) => pharmacy.isOpenNow).toList();
    }

    filteredPharmacies.value = results;
  }

  void clearFilters() {
    selectedWilaya.value = null;
    showNearbyOnly.value = false;
    showActiveOnly.value = false;
    searchQuery.value = '';
    loadPharmacies();
  }

  void goToPharmacyDetail(int pharmacyId) {
    Get.toNamed('${AppRoutes.PHARMACY_DETAIL}/$pharmacyId');
  }

  Future<void> refresh() async {
    await loadPharmacies();
  }
}
