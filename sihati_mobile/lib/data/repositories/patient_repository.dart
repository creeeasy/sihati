import 'package:dio/dio.dart';
import '../providers/patient_provider.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/user_model.dart';
import '../../core/models/patient_profile_model.dart';
import '../../core/models/prescription_model.dart';
import '../../core/models/consultation_model.dart';
import '../../core/models/medical_document_model.dart';
import '../../core/models/medication_history_model.dart';
import '../../core/models/allergy_model.dart';

/// Patient repository
///
/// Wraps PatientProvider with business logic and error handling.
///
/// Design decisions:
///   - No getActiveMedications() — backend has no isActive field
///   - No downloadPrescriptionPDF() — backend returns JSON, not a file stream
///   - No downloadDocument() — requires native file handling outside this scope
///   - No addAllergy() / deleteAllergy() — not exposed via patient routes
///   - getAllergies() returns List<Allergy> (typed model, not raw Map)
///   - getMedicationHistory() is derived from prescriptions client-side
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

  Future<PatientProfile> updatePatientProfile(
      Map<String, dynamic> data) async {
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

  // ─── Medication History ─────────────────────────────────────
  // Derived client-side from prescriptions — no dedicated backend endpoint.

  Future<List<MedicationHistory>> getMedicationHistory() async {
    return await _patientProvider.getMedicationHistory();
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

  /// Returns typed List<Allergy> (not raw Maps)
  Future<List<Allergy>> getAllergies() async {
    return await _patientProvider.getAllergies();
  }

  // ─── Stats ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStats() async {
    return await _patientProvider.getStats();
  }
}
