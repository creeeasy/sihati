import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import '../../../data/repositories/pharmacy_repository.dart';
import '../../../app/routes/app_routes.dart';

class PharmacyListController extends GetxController {
  final PharmacyRepository pharmacyRepository;

  PharmacyListController({required this.pharmacyRepository});

  // State
  final pharmacies = <PharmacyModel>[].obs;
  final filteredPharmacies = <PharmacyModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Filters
  final selectedWilaya = Rxn<String>();
  final showNearbyOnly = false.obs;
  final searchQuery = ''.obs;

  // Wilayas list (Algerian provinces)
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
    'Relizane',
  ];

  @override
  void onInit() {
    super.onInit();
    loadPharmacies();
  }

  /// Load all pharmacies
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
        _applyFilters();
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load nearby pharmacies
  Future<void> loadNearbyPharmacies() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await pharmacyRepository.getNearbyPharmacies(radius: 10);

      pharmacies.value = result;
      _applyFilters();

      Get.snackbar(
        'Succès',
        '${result.length} pharmacie(s) trouvée(s) à proximité',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');

      if (errorMessage.value.contains('permission')) {
        Get.snackbar(
          'Permission requise',
          'Activez la localisation pour voir les pharmacies proches',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Erreur',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter by wilaya
  void filterByWilaya(String? wilaya) {
    selectedWilaya.value = wilaya;
    showNearbyOnly.value = false;
    loadPharmacies();
  }

  /// Toggle nearby filter
  void toggleNearbyFilter() {
    showNearbyOnly.value = !showNearbyOnly.value;
    if (showNearbyOnly.value) {
      selectedWilaya.value = null;
    }
    loadPharmacies();
  }

  /// Search pharmacies
  void searchPharmacies(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  /// Apply search filter
  void _applyFilters() {
    if (searchQuery.value.isEmpty) {
      filteredPharmacies.value = pharmacies;
      return;
    }

    final query = searchQuery.value.toLowerCase();
    filteredPharmacies.value = pharmacies.where((pharmacy) {
      return pharmacy.pharmacyName.toLowerCase().contains(query) ||
          pharmacy.address.toLowerCase().contains(query) ||
          pharmacy.wilaya.toLowerCase().contains(query);
    }).toList();
  }

  /// Clear all filters
  void clearFilters() {
    selectedWilaya.value = null;
    showNearbyOnly.value = false;
    searchQuery.value = '';
    loadPharmacies();
  }

  /// Navigate to pharmacy details
  void goToPharmacyDetail(int pharmacyId) {
    Get.toNamed('${AppRoutes.PHARMACY_DETAIL}/$pharmacyId');
  }

  /// Refresh
  Future<void> refresh() async {
    await loadPharmacies();
  }
}
