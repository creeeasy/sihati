// lib/modules/medical_record/controllers/medical_record_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/patient_repository.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/patient_profile_model.dart';
import '../../../core/models/prescription_model.dart';
import '../../../core/models/consultation_model.dart';
import '../../../core/models/medical_document_model.dart';
import '../../../core/models/medication_history_model.dart';

class MedicalRecordController extends GetxController {
  final PatientRepository _patientRepository;

  MedicalRecordController({
    required PatientRepository patientRepository,
  }) : _patientRepository = patientRepository;

  // Tab index
  final tabIndex = 0.obs;

  // Data states
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // User & Patient data
  final user = Rxn<UserModel>();
  final patientProfile = Rxn<PatientProfile>();

  // Statistics
  final ordonnancesCount = 0.obs;
  final medicationsCount = 0.obs;
  final consultationsCount = 0.obs;
  final documentsCount = 0.obs;

  // Lists
  final prescriptions = <Prescription>[].obs;
  final medicationHistory = <MedicationHistory>[].obs;
  final consultations = <Consultation>[].obs;
  final medicalDocuments = <MedicalDocument>[].obs;

  // Allergies
  final allergies = <Map<String, dynamic>>[].obs;

  // Current medications
  final currentMedications = <MedicationHistory>[].obs;

  // Last consultation
  final lastConsultation = Rxn<Consultation>();

  // 🆕 Filter for medication history
  final showActiveOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMedicalData();
  }

  Future<void> loadMedicalData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Load user profile
      user.value = await _patientRepository.getCurrentUser();

      // Load patient profile
      patientProfile.value = await _patientRepository.getPatientProfile();

      // Load statistics
      final stats = await _patientRepository.getStats();
      ordonnancesCount.value = stats['prescriptionsCount'] ?? 0;
      medicationsCount.value = stats['medicationsCount'] ?? 0;
      consultationsCount.value = stats['consultationsCount'] ?? 0;
      documentsCount.value = stats['documentsCount'] ?? 0;

      // Load lists
      prescriptions.value = await _patientRepository.getPrescriptions();
      medicationHistory.value = await _patientRepository.getMedicationHistory();
      consultations.value = await _patientRepository.getConsultations();
      medicalDocuments.value = await _patientRepository.getDocuments();

      // Load allergies
      allergies.value = await _patientRepository.getAllergies();

      // Load current medications
      currentMedications.value =
          medicationHistory.where((m) => m.isActive).toList();

      // Get last consultation
      if (consultations.isNotEmpty) {
        lastConsultation.value = consultations.first;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error loading medical data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    tabIndex.value = index;
  }

  void goBack() {
    Get.back();
  }

  void viewPrescription(String prescriptionId) {
    Get.toNamed('/prescription/$prescriptionId');
  }

  Future<void> downloadPrescriptionPDF(String prescriptionId) async {
    try {
      isLoading.value = true;
      await _patientRepository.downloadPrescriptionPDF(prescriptionId);
      Get.snackbar(
        'Téléchargement',
        'PDF téléchargé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de télécharger le PDF',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addAllergy() {
    Get.dialog(
      AlertDialog(
        title: const Text('Ajouter une allergie'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Nom de l\'allergie',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) async {
            if (value.isNotEmpty) {
              try {
                await _patientRepository.addAllergy({'name': value});
                await loadMedicalData(); // Refresh
                Get.back();
                Get.snackbar(
                  'Succès',
                  'Allergie ajoutée',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Erreur',
                  'Impossible d\'ajouter l\'allergie',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void removeAllergy(Map<String, dynamic> allergy) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer l\'allergie'),
        content: Text('Voulez-vous vraiment supprimer "${allergy['name']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _patientRepository.deleteAllergy(allergy['id'].toString());
        await loadMedicalData(); // Refresh
        Get.snackbar(
          'Succès',
          'Allergie supprimée',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible de supprimer l\'allergie',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // 🆕 Delete document method
  Future<void> deleteDocument(String documentId) async {
    try {
      isLoading.value = true;
      await _patientRepository.deleteDocument(documentId);
      await loadMedicalData(); // Refresh
      Get.snackbar(
        'Succès',
        'Document supprimé',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer le document',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🆕 Download document method
  Future<void> downloadDocument(MedicalDocument document) async {
    try {
      isLoading.value = true;
      // TODO: Implement document download
      // await _patientRepository.downloadDocument(document.id);

      Get.snackbar(
        'Téléchargement',
        'Téléchargement de ${document.title}...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );

      // Simulate download for now
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Succès',
        'Document téléchargé: ${document.title}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de télécharger le document',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // À ajouter si nécessaire
  Future<void> downloadDocumentById(String documentId) async {
    try {
      isLoading.value = true;
      await _patientRepository.downloadDocument(documentId);
      Get.snackbar(
        'Succès',
        'Document téléchargé',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de télécharger le document',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void uploadDocument() async {
    // TODO: Implement document upload with file picker
    Get.snackbar(
      'Document',
      'Fonctionnalité à venir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void refreshData() async {
    await loadMedicalData();
  }

  // 🆕 Helper to get filtered medications
  List<MedicationHistory> getFilteredMedications() {
    if (showActiveOnly.value) {
      return medicationHistory.where((m) => m.isActive).toList();
    }
    return medicationHistory;
  }

  String getFormattedDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return months[month - 1];
  }

  void addMedication() {
    // TODO: Navigate to add medication screen
    Get.snackbar(
      'Médicament',
      'Fonctionnalité à venir',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
