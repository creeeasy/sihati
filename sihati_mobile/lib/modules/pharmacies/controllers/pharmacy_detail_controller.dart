import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/repositories/pharmacy_repository.dart';
import '../../../data/repositories/favorite_repository.dart';

class PharmacyDetailController extends GetxController {
  final PharmacyRepository pharmacyRepository;
  final FavoriteRepository favoriteRepository;

  PharmacyDetailController({
    required this.pharmacyRepository,
    required this.favoriteRepository,
  });

  // ── State ────────────────────────────────────────────────────
  final pharmacy = Rxn<PharmacyModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isFavorite = false.obs;

  // ── CRITICAL FIX: French display name → English API key ──────
  // The backend stores opening hours with English keys ('monday', 'tuesday'…)
  // The previous code used days[i].toLowerCase() → 'lundi', 'mardi'…
  // which never matched, so hours were silently never displayed.
  static const _dayKeyMap = {
    'Lundi': 'monday',
    'Mardi': 'tuesday',
    'Mercredi': 'wednesday',
    'Jeudi': 'thursday',
    'Vendredi': 'friday',
    'Samedi': 'saturday',
    'Dimanche': 'sunday',
  };

  // ── Route ────────────────────────────────────────────────────
  String get pharmacyId => Get.parameters['id'] ?? '';

  @override
  void onInit() {
    super.onInit();
    loadPharmacyDetails();
    checkFavoriteStatus();
  }

  Future<void> checkFavoriteStatus() async {
    if (pharmacyId.isEmpty) return;
    isFavorite.value = await favoriteRepository.isPharmacyFavorite(pharmacyId);
  }

  // ═══════════════════════════════════════════════════════════════
  // LOAD
  // ═══════════════════════════════════════════════════════════════

  Future<void> loadPharmacyDetails() async {
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

  // ═══════════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════════

  Future<void> toggleFavorite() async {
    try {
      final newStatus = await favoriteRepository.toggleFavoritePharmacy(pharmacyId);
      isFavorite.value = newStatus;
      
      Get.snackbar(
        newStatus ? 'Ajouté aux favoris' : 'Retiré des favoris',
        newStatus
            ? '${pharmacy.value?.pharmacyName} a été ajouté à vos favoris'
            : '${pharmacy.value?.pharmacyName} a été retiré de vos favoris',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier les favoris',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> callPharmacy() async {
    final phone = pharmacy.value?.phone;
    if (phone == null) return;

    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar('Erreur', 'Impossible d\'appeler ce numéro',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('Erreur', 'Erreur lors de l\'appel',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> openWhatsApp() async {
    final whatsapp = pharmacy.value?.whatsappNumber;
    if (whatsapp == null) return;

    final number = whatsapp.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('https://wa.me/$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Erreur', 'WhatsApp non disponible',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('Erreur', 'Erreur lors de l\'ouverture de WhatsApp',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

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
        Get.snackbar('Erreur', 'Impossible d\'ouvrir Google Maps',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('Erreur', 'Erreur lors de l\'ouverture des directions',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // OPENING HOURS — fixed key mapping
  // ═══════════════════════════════════════════════════════════════

  /// Returns ordered Mon→Sun list of (French label → time range or 'Fermé').
  /// Uses [_dayKeyMap] to look up English keys in the API response.
  List<MapEntry<String, String>> get openingHoursList {
    final hours = pharmacy.value?.openingHours;
    if (hours == null || hours.isEmpty) return [];

    final result = <MapEntry<String, String>>[];

    _dayKeyMap.forEach((frenchName, englishKey) {
      if (hours.containsKey(englishKey)) {
        final dayHours = hours[englishKey];
        if (dayHours is Map && dayHours.isNotEmpty) {
          final open = dayHours['open']?.toString() ?? '';
          final close = dayHours['close']?.toString() ?? '';
          if (open.isNotEmpty &&
              open != 'null' &&
              close.isNotEmpty &&
              close != 'null') {
            result.add(MapEntry(frenchName, '$open - $close'));
          } else {
            result.add(MapEntry(frenchName, 'Fermé'));
          }
        } else {
          result.add(MapEntry(frenchName, 'Fermé'));
        }
      } else {
        result.add(MapEntry(frenchName, 'Fermé'));
      }
    });

    return result;
  }
}
