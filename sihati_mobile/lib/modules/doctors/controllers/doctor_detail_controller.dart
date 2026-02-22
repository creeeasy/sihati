import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/doctor_model.dart';
import 'package:sihati_mobile/data/repositories/doctor_repository.dart';

class DoctorDetailController extends GetxController {
  final DoctorRepository doctorRepository;

  DoctorDetailController({
    required this.doctorRepository,
  });

  // State
  final doctor = Rxn<DoctorModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isFavorite = false.obs;

  // Get doctor ID from route parameters
  int get doctorId => int.tryParse(Get.parameters['id'] ?? '0') ?? 0;

  @override
  void onInit() {
    super.onInit();
    loadDoctorDetails();
  }

  // Load doctor details
  Future<void> loadDoctorDetails() async {
    if (doctorId == 0) {
      errorMessage.value = 'ID de médecin invalide';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final doctorData = await doctorRepository.getDoctorDetails(doctorId);
      doctor.value = doctorData;

      // Check if doctor is in favorites (you can implement this with StorageService later)
      // isFavorite.value = await _checkIfFavorite(doctorId);
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement des détails: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle favorite status
  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    // TODO: Implement favorite functionality with StorageService
    Get.snackbar(
      isFavorite.value ? 'Ajouté aux favoris' : 'Retiré des favoris',
      isFavorite.value
          ? '${doctor.value?.doctorName} a été ajouté à vos favoris'
          : '${doctor.value?.doctorName} a été retiré de vos favoris',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Make phone call
  void callDoctor() {
    if (doctor.value == null) return;

    final phoneNumber = doctor.value!.phone.replaceAll(' ', '');
    // TODO: Implement with url_launcher
    // await launch('tel:$phoneNumber');

    Get.snackbar(
      'Appel',
      'Fonctionnalité à implémenter: Appeler ${doctor.value!.doctorName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Open WhatsApp
  void openWhatsApp() {
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

    final whatsappNumber = doctor.value!.whatsappNumber!.replaceAll(' ', '');
    // TODO: Implement with url_launcher
    // await launch('https://wa.me/$whatsappNumber?text=Bonjour%20Docteur');

    Get.snackbar(
      'WhatsApp',
      'Fonctionnalité à implémenter: Ouvrir WhatsApp',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Open directions in maps
  void getDirections() {
    if (doctor.value == null) return;

    // TODO: Implement with url_launcher
    // await launch('https://www.google.com/maps/search/?api=1&query=${doctor.value!.latitude},${doctor.value!.longitude}');

    Get.snackbar(
      'Itinéraire',
      'Fonctionnalité à implémenter: Ouvrir Google Maps',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Share doctor profile
  void shareDoctor() {
    if (doctor.value == null) return;

    // TODO: Implement share functionality
    Get.snackbar(
      'Partager',
      'Fonctionnalité à implémenter: Partager le profil',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Get formatted working hours
  List<MapEntry<String, String>> get workingHoursList {
    if (doctor.value == null || doctor.value!.workingHours == null) {
      return [];
    }

    try {
      final workingHours = doctor.value!.workingHours! as Map<String, dynamic>;
      final List<MapEntry<String, String>> hours = [];

      // French days mapping
      final dayMapping = {
        'monday': 'Lundi',
        'tuesday': 'Mardi',
        'wednesday': 'Mercredi',
        'thursday': 'Jeudi',
        'friday': 'Vendredi',
        'saturday': 'Samedi',
        'sunday': 'Dimanche',
      };

      workingHours.forEach((key, value) {
        final frenchDay = dayMapping[key.toLowerCase()] ?? key;

        if (value is String) {
          hours.add(MapEntry(frenchDay, value));
        } else if (value is Map) {
          // Handle complex hours (e.g., with breaks)
          final periods = <String>[];
          if (value['morning'] != null) periods.add(value['morning']);
          if (value['afternoon'] != null) periods.add(value['afternoon']);
          hours.add(MapEntry(frenchDay, periods.join(' / ')));
        }
      });

      return hours;
    } catch (e) {
      print('Error parsing working hours: $e');
      return [];
    }
  }

  // Check if doctor is available now (simplified)
  bool get isAvailableNow {
    // TODO: Implement proper availability check based on working hours
    return true;
  }

  // Format consultation fee
  String get formattedFee {
    if (doctor.value == null) return '';
    if (doctor.value!.consultationFee == null) {
      return 'Prix non spécifié';
    }
    return '${doctor.value!.consultationFee!.toStringAsFixed(0)} DA';
  }

  // Get full address
  String get fullAddress {
    if (doctor.value == null) return '';
    final parts = <String>[];
    parts.add(doctor.value!.clinicAddress);
    if (doctor.value!.commune != null) {
      parts.add(doctor.value!.commune!);
    }
    parts.add(doctor.value!.wilaya);
    return parts.join(', ');
  }
}
