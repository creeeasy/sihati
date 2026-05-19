import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/doctor_model.dart';
import 'package:sihati_mobile/data/repositories/doctor_repository.dart';
import 'package:sihati_mobile/data/repositories/appointment_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorDetailController extends GetxController {
  final DoctorRepository doctorRepository;
  final AppointmentRepository? appointmentRepository;

  DoctorDetailController({
    required this.doctorRepository,
    this.appointmentRepository,
  });

  final doctor = Rxn<DoctorModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isFavorite = false.obs;
  final nextAvailableSlot = Rxn<String>();

  // ✅ CORRIGÉ: String ID
  String get doctorId => Get.parameters['id'] ?? ''; // ✅ String

  @override
  void onInit() {
    super.onInit();
    loadDoctorDetails();
  }

  Future<void> loadDoctorDetails() async {
    // ✅ CORRIGÉ: Vérifier si ID est vide
    if (doctorId.isEmpty) {
      errorMessage.value = 'ID de médecin invalide';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // ✅ CORRIGÉ: Passage String ID
      final doctorData = await doctorRepository.getDoctorDetails(doctorId);
      doctor.value = doctorData;

      await _loadNextAvailableSlot();
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des détails: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadNextAvailableSlot() async {
    if (appointmentRepository == null || doctor.value == null) return;

    try {
      // ✅ CORRIGÉ: doctor.value!.id est déjà String
      final slot =
          await appointmentRepository!.getNextAvailableSlot(doctor.value!.id);
      nextAvailableSlot.value = slot;
    } catch (e) {
      print('Error loading next slot: $e');
    }
  }

  void bookAppointment() {
    if (doctor.value == null) return;
    Get.toNamed('/book-appointment', arguments: doctor.value);
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    Get.snackbar(
      isFavorite.value ? 'Ajouté aux favoris' : 'Retiré des favoris',
      isFavorite.value
          ? '${doctor.value?.doctorName} a été ajouté à vos favoris'
          : '${doctor.value?.doctorName} a été retiré de vos favoris',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> callDoctor() async {
    if (doctor.value == null) return;

    final phoneNumber = doctor.value!.phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$phoneNumber');

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
        'Impossible d\'ouvrir l\'application téléphone',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> openWhatsApp() async {
    if (doctor.value == null) return;
    if (doctor.value!.whatsappNumber == null ||
        doctor.value!.whatsappNumber!.isEmpty) {
      Get.snackbar(
        'WhatsApp non disponible',
        'Ce médecin n\'a pas de numéro WhatsApp',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final whatsappNumber =
        doctor.value!.whatsappNumber!.replaceAll(RegExp(r'[^\d+]'), '');
    final message = Uri.encodeComponent(
        'Bonjour Docteur, je souhaite prendre un rendez-vous.');
    final uri = Uri.parse('https://wa.me/$whatsappNumber?text=$message');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Erreur',
          'WhatsApp n\'est pas installé',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir WhatsApp',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> getDirections() async {
    if (doctor.value == null) return;

    final lat = doctor.value!.latitude;
    final lng = doctor.value!.longitude;
    final label = Uri.encodeComponent(doctor.value!.clinicName);

    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$label');

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
        'Impossible d\'ouvrir l\'application de cartes',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void shareDoctor() {
    if (doctor.value == null) return;

    final text = '''
📍 ${doctor.value!.doctorName}
🏥 ${doctor.value!.specialty?.nameFr ?? 'Spécialiste'}
📞 ${doctor.value!.phone}
📍 ${doctor.value!.clinicAddress}, ${doctor.value!.wilaya}
💰 $formattedFee
    '''
        .trim();

    Get.snackbar(
      'Partager',
      'Fonctionnalité de partage: $text',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  // workingHoursList removed — Doctor model has no workingHours field in backend.
  // Available slots are queried via GET /doctors/:id/available-slots?date=YYYY-MM-DD

  String get formattedFee {
    if (doctor.value == null) return '';
    if (doctor.value!.consultationFee == null) {
      return 'Prix non spécifié';
    }
    return '${doctor.value!.consultationFee!.toStringAsFixed(0)} DA';
  }

  String get fullAddress {
    if (doctor.value == null) return '';
    final parts = <String>[];
    parts.add(doctor.value!.clinicAddress);
    if (doctor.value!.commune != null && doctor.value!.commune!.isNotEmpty) {
      parts.add(doctor.value!.commune!);
    }
    parts.add(doctor.value!.wilaya);
    return parts.join(', ');
  }

  // ✅ AJOUT: Méthode pour rafraîchir
  Future<void> refreshDoctor() async {
    await loadDoctorDetails();
  }
}
