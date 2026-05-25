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
import '../../../core/models/allergy_model.dart';

class MedicalRecordController extends GetxController {
  final PatientRepository _patientRepository;

  MedicalRecordController({required PatientRepository patientRepository})
      : _patientRepository = patientRepository;

  final tabIndex = 0.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final user = Rxn<UserModel>();
  final patientProfile = Rxn<PatientProfile>();

  final ordonnancesCount = 0.obs;
  final medicationsCount = 0.obs;
  final consultationsCount = 0.obs;
  final documentsCount = 0.obs;

  final prescriptions = <Prescription>[].obs;
  final medicationHistory = <MedicationHistory>[].obs;
  final consultations = <Consultation>[].obs;
  final medicalDocuments = <MedicalDocument>[].obs;
  final allergies = <Allergy>[].obs;
  final currentMedications = <MedicationHistory>[].obs;
  final lastConsultation = Rxn<Consultation>();
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

      user.value = await _patientRepository.getCurrentUser();
      patientProfile.value = await _patientRepository.getPatientProfile();

      final stats = await _patientRepository.getStats();
      ordonnancesCount.value = stats['prescriptionsCount'] ?? 0;
      medicationsCount.value = stats['medicationsCount'] ?? 0;
      consultationsCount.value = stats['consultationsCount'] ?? 0;
      documentsCount.value = stats['documentsCount'] ?? 0;

      prescriptions.value = await _patientRepository.getPrescriptions();
      medicationHistory.value = await _patientRepository.getMedicationHistory();
      consultations.value = await _patientRepository.getConsultations();
      medicalDocuments.value = await _patientRepository.getDocuments();
      allergies.value = await _patientRepository.getAllergies();

      currentMedications.value = medicationHistory
          .where((m) =>
              m.isContinuous ||
              (m.endDate != null && m.endDate!.isAfter(DateTime.now())))
          .toList();

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

  void changeTab(int index) => tabIndex.value = index;
  void goBack() => Get.back();

  Future<void> deleteDocument(String documentId) async {
    try {
      isLoading.value = true;
      await _patientRepository.deleteDocument(documentId);
      await loadMedicalData();
      Get.snackbar('Succès', 'Document supprimé',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de supprimer le document',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void refreshData() async => await loadMedicalData();

  List<MedicationHistory> getFilteredMedications() {
    if (showActiveOnly.value) {
      return medicationHistory
          .where((m) =>
              m.isContinuous ||
              (m.endDate != null && m.endDate!.isAfter(DateTime.now())))
          .toList();
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
}
