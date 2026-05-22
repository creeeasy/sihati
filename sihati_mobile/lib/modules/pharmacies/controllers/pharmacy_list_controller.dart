import 'dart:async';

import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import '../../../data/repositories/pharmacy_repository.dart';
import '../../../app/routes/app_routes.dart';

class PharmacyListController extends GetxController {
  final PharmacyRepository pharmacyRepository;

  PharmacyListController({required this.pharmacyRepository});

  // ── State ────────────────────────────────────────────────────
  final pharmacies = <PharmacyModel>[].obs;
  final filteredPharmacies = <PharmacyModel>[].obs;
  final isLoading = false.obs;
  final isSearchLoading = false.obs; // spinner during backend search
  final errorMessage = ''.obs;
  final selectedWilaya = Rxn<String>();
  final showNearbyOnly = false.obs;
  final showActiveOnly = false.obs;
  final searchQuery = ''.obs;
  final showMapView = false.obs;

  // ── Debounce ─────────────────────────────────────────────────
  Timer? _debounce;

  // ── Map: currently centred pharmacy index ─────────────────────
  // Used so tapping a card in map view re-centres the map
  final centredIndex = 0.obs;

  // ── Wilayas ──────────────────────────────────────────────────
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

  // ── Computed ─────────────────────────────────────────────────

  int get activeFiltersCount {
    int count = 0;
    if (showActiveOnly.value) count++;
    if (showNearbyOnly.value) count++;
    if (selectedWilaya.value != null) count++;
    if (searchQuery.value.isNotEmpty) count++;
    return count;
  }

  String get activePharmaciesCount {
    final open = pharmacies.where((p) => p.isOpenNow).length;
    return '$open ouverte${open > 1 ? 's' : ''} sur ${pharmacies.length}';
  }

  // ═══════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();
    loadPharmacies();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════
  // LOAD
  // ═══════════════════════════════════════════════════════════════

  Future<void> loadPharmacies() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (showNearbyOnly.value) {
        await _loadNearby();
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

  Future<void> _loadNearby() async {
    try {
      final result = await pharmacyRepository.getNearbyPharmacies(radius: 10);
      pharmacies.value = result;
      if (result.isNotEmpty) {
        Get.snackbar(
          'Succès',
          '${result.length} pharmacie(s) trouvée(s) à proximité',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg.contains('permission') || msg.contains('localisation')) {
        Get.snackbar(
          'Permission requise',
          'Activez la localisation pour voir les pharmacies proches',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        showNearbyOnly.value = false;
        // Fallback: reload without location
        final result = await pharmacyRepository.getAllPharmacies();
        pharmacies.value = result;
      } else {
        rethrow;
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // SEARCH — backend call with 500 ms debounce
  // ═══════════════════════════════════════════════════════════════

  /// Called on every TextField change.
  /// - Immediately updates [searchQuery] and runs client-side filter
  ///   so the list reacts instantly with whatever is already loaded.
  /// - After 500 ms, if query ≥ 2 chars, fires a backend search
  ///   (GET /pharmacies?q=) and merges results.
  /// - If query is cleared, reloads the base list.
  void searchPharmacies(String query) {
    searchQuery.value = query;

    // Cancel any pending debounce
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      // Cleared — reload base list (respects wilaya/nearby filters)
      loadPharmacies();
      return;
    }

    // Instant client-side feedback while user types
    _applyFilters();

    if (query.length < 2) return; // wait for at least 2 chars before backend

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        isSearchLoading.value = true;
        final results = await pharmacyRepository.searchPharmacies(query);
        // Backend results replace local list for this search session
        pharmacies.value = results;
        _applyFilters();
      } catch (_) {
        // On error fall back to client-side filter already applied above
      } finally {
        isSearchLoading.value = false;
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // FILTERS
  // ═══════════════════════════════════════════════════════════════

  void filterByWilaya(String? wilaya) {
    selectedWilaya.value = (wilaya == null || wilaya == 'Tous') ? null : wilaya;
    showNearbyOnly.value = false; // wilaya and nearby are mutually exclusive
    loadPharmacies();
  }

  void toggleNearbyFilter() {
    showNearbyOnly.value = !showNearbyOnly.value;
    if (showNearbyOnly.value) selectedWilaya.value = null;
    loadPharmacies();
  }

  void toggleActiveFilter() {
    showActiveOnly.value = !showActiveOnly.value;
    // FIX: only toggle the open filter — do NOT clear wilaya/nearby/search.
    // The old showOnlyOpenPharmacies() called clearFilters() on toggle-off,
    // wiping every other active filter the user had set.
    _applyFilters();
  }

  void clearFilters() {
    selectedWilaya.value = null;
    showNearbyOnly.value = false;
    showActiveOnly.value = false;
    searchQuery.value = '';
    loadPharmacies();
  }

  void _applyFilters() {
    var results = pharmacies.toList();

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      results = results.where((p) {
        return p.pharmacyName.toLowerCase().contains(query) ||
            p.address.toLowerCase().contains(query) ||
            p.wilaya.toLowerCase().contains(query);
      }).toList();
    }

    if (showActiveOnly.value) {
      results = results.where((p) => p.isOpenNow).toList();
    }

    filteredPharmacies.value = results;
  }

  // ═══════════════════════════════════════════════════════════════
  // MAP
  // ═══════════════════════════════════════════════════════════════

  void toggleMapView() => showMapView.value = !showMapView.value;

  /// Called when the user taps a card in the map strip.
  /// Re-centres the map on that pharmacy and navigates to its detail.
  void selectMapPharmacy(int index, String pharmacyId) {
    centredIndex.value = index;
    goToPharmacyDetail(pharmacyId);
  }

  // ═══════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════

  void goToPharmacyDetail(String pharmacyId) {
    Get.toNamed('${AppRoutes.PHARMACY_DETAIL}/$pharmacyId');
  }

  void goToDutyPharmacies() {
    Get.toNamed(AppRoutes.DUTY_PHARMACIES);
  }

  Future<void> refresh() async => loadPharmacies();
}
