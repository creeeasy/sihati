import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import '../../../data/repositories/pharmacy_repository.dart';
import '../../../app/routes/app_routes.dart';

class DutyPharmacyController extends GetxController {
  final PharmacyRepository pharmacyRepository;

  DutyPharmacyController({required this.pharmacyRepository});

  // State
  final pharmacies = <PharmacyModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedWilaya = Rxn<String>();

  // Wilayas list
  final List<String> wilayas = [
    'Tous',
    'Alger',
    'Oran',
    'Constantine',
    'Annaba',
    'Blida',
    'Batna',
    'Djelfa',
    'Sétif',
    'Sidi Bel Abbès',
    'Biskra',
    'Tébessa',
    'El Oued',
    'Skikda',
    'Tiaret',
    'Béjaïa',
    'Tlemcen',
    'Ouargla',
    'Béchar',
    'Mostaganem',
    'Bordj Bou Arréridj',
    'Chlef',
    'Souk Ahras',
    'Tizi Ouzou',
    'Médéa',
    'El Tarf',
    'Jijel',
    'Relizane',
    'M\'Sila',
    'Aïn Defla',
    'Naâma',
    'Aïn Témouchent',
    'Ghardaïa',
    'Mascara',
  ];

  @override
  void onInit() {
    super.onInit();
    loadDutyPharmacies();
  }

  /// Load duty pharmacies
  Future<void> loadDutyPharmacies() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final wilaya = selectedWilaya.value;
      final result = await pharmacyRepository.getDutyPharmacies(
        wilaya: (wilaya == null || wilaya == 'Tous') ? null : wilaya,
      );

      pharmacies.value = result;

      if (result.isEmpty) {
        errorMessage.value = 'Aucune pharmacie de garde trouvée';
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

  /// Filter by wilaya
  void filterByWilaya(String? wilaya) {
    selectedWilaya.value = wilaya;
    loadDutyPharmacies();
  }

  /// ✅ CORRIGÉ: Navigate to pharmacy details with String ID
  void goToPharmacyDetail(String pharmacyId) {
    Get.toNamed('${AppRoutes.PHARMACY_DETAIL}/$pharmacyId');
  }

  /// Refresh
  Future<void> refresh() async {
    await loadDutyPharmacies();
  }

  /// Get current date/time string
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
      'Déc'
    ];

    final day = days[now.weekday - 1];
    final month = months[now.month - 1];

    return '$day ${now.day} $month ${now.year} - ${now.hour}h${now.minute.toString().padLeft(2, '0')}';
  }
}
