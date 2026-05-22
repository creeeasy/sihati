import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import '../../../data/repositories/pharmacy_repository.dart';
import '../../../app/routes/app_routes.dart';

class DutyPharmacyController extends GetxController {
  final PharmacyRepository pharmacyRepository;

  DutyPharmacyController({required this.pharmacyRepository});

  // ── State ────────────────────────────────────────────────────
  final pharmacies = <PharmacyModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedWilaya = Rxn<String>();
  final showNearbyOnly = false.obs;

  // ── Wilayas ──────────────────────────────────────────────────
  // Full 48-wilaya list, consistent with PharmacyListController
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
    loadDutyPharmacies();
  }

  // ═══════════════════════════════════════════════════════════════
  // LOAD
  // ═══════════════════════════════════════════════════════════════

  Future<void> loadDutyPharmacies() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final wilaya = selectedWilaya.value;
      final result = await pharmacyRepository.getDutyPharmacies(
        wilaya: (wilaya == null || wilaya == 'Tous') ? null : wilaya,
        // FIX: wire showNearbyOnly to useLocation so the repo fetches
        // lat/lng from LocationService when the nearby toggle is active.
        useLocation: showNearbyOnly.value,
      );

      pharmacies.value = result;
      // FIX: do NOT set errorMessage on empty result — let the EmptyState
      // widget handle it. The old code set errorMessage here which caused
      // ErrorDisplayWidget to render instead of EmptyState.
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.value.contains('permission') ||
          errorMessage.value.contains('localisation')) {
        Get.snackbar(
          'Localisation requise',
          'Activez la localisation pour voir les pharmacies de garde proches',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        // Fall back to non-location load
        showNearbyOnly.value = false;
        errorMessage.value = '';
        await loadDutyPharmacies();
      } else {
        Get.snackbar('Erreur', errorMessage.value,
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // FILTERS
  // ═══════════════════════════════════════════════════════════════

  void filterByWilaya(String? wilaya) {
    // Normalize 'Tous' to null so the API call omits the wilaya param
    selectedWilaya.value = (wilaya == null || wilaya == 'Tous') ? null : wilaya;
    showNearbyOnly.value = false; // nearby and wilaya are mutually exclusive
    loadDutyPharmacies();
  }

  void toggleNearbyFilter() {
    showNearbyOnly.value = !showNearbyOnly.value;
    if (showNearbyOnly.value) {
      selectedWilaya.value = null; // clear wilaya when going nearby
    }
    loadDutyPharmacies();
  }

  void clearFilters() {
    selectedWilaya.value = null;
    showNearbyOnly.value = false;
    loadDutyPharmacies();
  }

  int get activeFiltersCount {
    int count = 0;
    if (showNearbyOnly.value) count++;
    if (selectedWilaya.value != null) count++;
    return count;
  }

  // ═══════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════

  void goToPharmacyDetail(String pharmacyId) {
    Get.toNamed('${AppRoutes.PHARMACY_DETAIL}/$pharmacyId');
  }

  Future<void> refresh() async => loadDutyPharmacies();

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  String get currentDateTime {
    final now = DateTime.now();
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return '${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]} '
        '${now.year} · ${now.hour}h${now.minute.toString().padLeft(2, '0')}';
  }

  String get pharmacyCountLabel {
    final count = pharmacies.length;
    if (count == 0) return 'Aucune pharmacie de garde';
    return '$count pharmacie${count > 1 ? 's' : ''} de garde';
  }
}
