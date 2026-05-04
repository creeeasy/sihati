import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/repositories/pharmacy_repository.dart';

class PharmacyDetailController extends GetxController {
  final PharmacyRepository pharmacyRepository;

  PharmacyDetailController({required this.pharmacyRepository});

  // State
  final pharmacy = Rxn<PharmacyModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ✅ CORRIGÉ: Get pharmacy ID from route as String
  String get pharmacyId => Get.parameters['id'] ?? '';

  @override
  void onInit() {
    super.onInit();
    loadPharmacyDetails();
  }

  /// Load pharmacy details
  Future<void> loadPharmacyDetails() async {
    // ✅ CORRIGÉ: Check if ID is empty
    if (pharmacyId.isEmpty) {
      errorMessage.value = 'ID de pharmacie invalide';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await pharmacyRepository.getPharmacyDetails(pharmacyId);
      pharmacy.value = result;
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

  /// Call pharmacy
  Future<void> callPharmacy() async {
    final phone = pharmacy.value?.phone;
    if (phone == null) return;

    final uri = Uri(scheme: 'tel', path: phone);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible d\'appeler ce numéro',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'appel',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Open WhatsApp
  Future<void> openWhatsApp() async {
    final whatsapp = pharmacy.value?.whatsappNumber;
    if (whatsapp == null) return;

    // Remove spaces and format
    final number = whatsapp.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('https://wa.me/$number');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Erreur',
          'WhatsApp non disponible',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'ouverture de WhatsApp',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Get directions
  Future<void> getDirections() async {
    final lat = pharmacy.value?.latitude;
    final lng = pharmacy.value?.longitude;

    if (lat == null || lng == null) return;

    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible d\'ouvrir Google Maps',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'ouverture des directions',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Get opening hours for each day
  List<MapEntry<String, String>> get openingHoursList {
    final hours = pharmacy.value?.openingHours;
    if (hours == null) return [];

    final days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];

    final result = <MapEntry<String, String>>[];

    for (var i = 0; i < days.length; i++) {
      final dayKey = days[i].toLowerCase();
      if (hours.containsKey(dayKey)) {
        final dayHours = hours[dayKey];
        if (dayHours is Map && dayHours.isNotEmpty) {
          final open = dayHours['open'] ?? '';
          final close = dayHours['close'] ?? '';

          if (open.isNotEmpty && close.isNotEmpty) {
            result.add(MapEntry(days[i], '$open - $close'));
          } else {
            result.add(MapEntry(days[i], 'Fermé'));
          }
        } else {
          result.add(MapEntry(days[i], 'Fermé'));
        }
      } else {
        result.add(MapEntry(days[i], 'Fermé'));
      }
    }

    return result;
  }
}
