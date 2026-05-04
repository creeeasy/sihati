import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' show SnackPosition;
import 'package:get/route_manager.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../providers/patient_provider.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/user_model.dart';
import '../../core/models/patient_profile_model.dart';
import '../../core/models/prescription_model.dart';
import '../../core/models/consultation_model.dart';
import '../../core/models/medical_document_model.dart';
import '../../core/models/medication_history_model.dart';

class PatientRepository {
  final PatientProvider _patientProvider;
  final StorageService _storageService;

  PatientRepository({
    required PatientProvider patientProvider,
    required StorageService storageService,
  })  : _patientProvider = patientProvider,
        _storageService = storageService;

  // ─── Current User ──────────────────────────────────────────

  Future<UserModel?> getCurrentUser() async {
    return await _storageService.getUser();
  }

  // ─── Profile ────────────────────────────────────────────────

  Future<PatientProfile> getPatientProfile() async {
    return await _patientProvider.getPatientProfile();
  }

  Future<PatientProfile> updatePatientProfile(Map<String, dynamic> data) async {
    return await _patientProvider.updatePatientProfile(data);
  }

  // ─── Prescriptions ──────────────────────────────────────────

  Future<List<Prescription>> getPrescriptions(
      {int page = 1, int limit = 20}) async {
    return await _patientProvider.getPrescriptions(page: page, limit: limit);
  }

  Future<Prescription> getPrescriptionById(String id) async {
    return await _patientProvider.getPrescriptionById(id);
  }

  Future<void> downloadPrescriptionPDF(String id) async {
    await _patientProvider.downloadPrescriptionPDF(id);
  }

  // ─── Medication History ─────────────────────────────────────

  Future<List<MedicationHistory>> getMedicationHistory({bool? active}) async {
    return await _patientProvider.getMedicationHistory(active: active);
  }

  Future<List<MedicationHistory>> getActiveMedications() async {
    return await _patientProvider.getActiveMedications();
  }

  // ─── Consultations ──────────────────────────────────────────

  Future<List<Consultation>> getConsultations(
      {int page = 1, int limit = 20}) async {
    return await _patientProvider.getConsultations(page: page, limit: limit);
  }

  Future<Consultation> getConsultationById(String id) async {
    return await _patientProvider.getConsultationById(id);
  }

  // ─── Documents ──────────────────────────────────────────────

  Future<List<MedicalDocument>> getDocuments() async {
    return await _patientProvider.getDocuments();
  }

  Future<MedicalDocument> uploadDocument(FormData formData) async {
    return await _patientProvider.uploadDocument(formData);
  }

  Future<void> deleteDocument(String id) async {
    await _patientProvider.deleteDocument(id);
  }

  // ─── Allergies ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllergies() async {
    return await _patientProvider.getAllergies();
  }

  Future<void> addAllergy(Map<String, dynamic> allergy) async {
    await _patientProvider.addAllergy(allergy);
  }

  Future<void> deleteAllergy(String id) async {
    await _patientProvider.deleteAllergy(id);
  }

  // ─── Stats ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStats() async {
    return await _patientProvider.getStats();
  }

  /// Download a document by ID
  Future<void> downloadDocument(String documentId) async {
    try {
      // Call the provider to get the file
      final fileData = await _patientProvider.downloadDocument(documentId);

      // Save to device
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/document_$documentId.pdf';
      final file = File(filePath);
      await file.writeAsBytes(fileData);

      // Open the file
      await OpenFile.open(filePath);

      Get.snackbar(
        'Succès',
        'Document téléchargé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      throw Exception('Impossible de télécharger le document: $e');
    }
  }
}
