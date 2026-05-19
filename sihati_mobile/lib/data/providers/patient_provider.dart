// lib/data/providers/patient_provider.dart
import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import '../../app/constants/api_constants.dart';
import '../../core/models/patient_profile_model.dart';
import '../../core/models/prescription_model.dart';
import '../../core/models/consultation_model.dart';
import '../../core/models/medical_document_model.dart';
import '../../core/models/medication_history_model.dart';
import '../../core/models/allergy_model.dart';

/// Patient provider — communicates with the Sihati backend
///
/// Available backend routes used (patient-only):
///   GET    /patient/profile           → get patient profile
///   PUT    /patient/profile           → update patient profile
///   GET    /patient/prescriptions     → list prescriptions (paginated)
///   GET    /patient/prescriptions/:id → single prescription with medications
///   GET    /patient/consultations     → list consultations (paginated)
///   GET    /patient/consultations/:id → single consultation
///   GET    /patient/documents         → list medical documents
///   POST   /patient/documents         → upload document (multipart)
///   DELETE /patient/documents/:id     → delete document
///   GET    /patient/allergies         → list patient allergies (read-only)
///   GET    /patient/stats             → dashboard stats
///
/// NOTE: Medication history is derived client-side from prescriptions.
///       The backend has no dedicated /patient/medications/history endpoint.
///
/// Not available via patient routes (use allergyController if needed):
///   - POST   /allergies (separate route, not /patient/allergies)
///   - DELETE /allergies/:id
class PatientProvider {
  final ApiService _apiService;

  PatientProvider(this._apiService);

  // ─── Profile ────────────────────────────────────────────────────────

  /// Get patient profile
  /// Backend: GET /patient/profile
  Future<PatientProfile> getPatientProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.PATIENT_PROFILE);
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return PatientProfile.fromJson(data['profile'] ?? data);
      }
      throw Exception('Failed to load patient profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Update patient profile
  /// Backend: PUT /patient/profile
  /// Accepted fields: dateOfBirth, gender, bloodType,
  ///   emergencyContactName, emergencyContactPhone
  Future<PatientProfile> updatePatientProfile(
      Map<String, dynamic> updateData) async {
    try {
      final response = await _apiService.put(
        ApiConstants.PATIENT_PROFILE,
        data: updateData,
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return PatientProfile.fromJson(data['profile'] ?? data);
      }
      throw Exception('Failed to update patient profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // ─── Prescriptions ───────────────────────────────────────────────────

  /// Get all prescriptions for the authenticated patient
  /// Backend: GET /patient/prescriptions
  Future<List<Prescription>> getPrescriptions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.PATIENT_PRESCRIPTIONS,
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> list =
            data is List ? data : (data['prescriptions'] ?? data);
        return list.map((json) => Prescription.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error loading prescriptions: ${e.message}');
      return [];
    }
  }

  /// Get prescription by ID
  /// Backend: GET /patient/prescriptions/:id
  Future<Prescription> getPrescriptionById(String id) async {
    try {
      final response =
          await _apiService.get('${ApiConstants.PATIENT_PRESCRIPTIONS}/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return Prescription.fromJson(data is Map ? data : data);
      }
      throw Exception('Prescription not found');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // ─── Medication History ──────────────────────────────────────────────

  /// Get medication history derived client-side from prescriptions.
  /// Backend has no dedicated /patient/medications/history endpoint.
  /// Backend: GET /patient/prescriptions → extract PrescriptionMedications
  Future<List<MedicationHistory>> getMedicationHistory() async {
    try {
      final response = await _apiService.get(
        ApiConstants.PATIENT_PRESCRIPTIONS,
        queryParameters: {'limit': 50},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> prescList =
            data is List ? data : (data['prescriptions'] ?? data);

        final allMedications = <MedicationHistory>[];
        for (final prescJson in prescList) {
          final meds = prescJson['medications'] as List? ??
              prescJson['PrescriptionMedications'] as List? ??
              [];
          for (final med in meds) {
            try {
              // Build a MedicationHistory-compatible map from prescription + medication data
              allMedications.add(MedicationHistory.fromJson({
                ...Map<String, dynamic>.from(med),
                'patientId': prescJson['patientId'] ?? prescJson['patient_id'] ?? '',
                'prescriptionId': prescJson['id'],
                'startDate': prescJson['prescriptionDate'] ??
                    prescJson['prescription_date'] ??
                    prescJson['createdAt'] ??
                    prescJson['created_at'],
                'createdAt': prescJson['createdAt'] ?? prescJson['created_at'],
                if ((med as Map)['durationDays'] != null ||
                    med['duration_days'] != null)
                  'endDate': _computeEndDate(
                    prescJson['prescriptionDate'] ??
                        prescJson['prescription_date'] ??
                        prescJson['createdAt'],
                    med['durationDays'] ?? med['duration_days'],
                  ),
              }));
            } catch (_) {
              // Skip malformed entries
            }
          }
        }
        return allMedications;
      }
      return [];
    } on DioException catch (e) {
      print('Error loading medication history: ${e.message}');
      return [];
    }
  }

  static String? _computeEndDate(dynamic startStr, dynamic durationDays) {
    if (startStr == null || durationDays == null) return null;
    try {
      final start = DateTime.parse(startStr.toString());
      final days = (durationDays is int)
          ? durationDays
          : int.tryParse(durationDays.toString());
      if (days == null) return null;
      return start.add(Duration(days: days)).toIso8601String();
    } catch (_) {
      return null;
    }
  }

  // ─── Consultations ────────────────────────────────────────────────────

  /// Get consultations for the authenticated patient
  /// Backend: GET /patient/consultations
  Future<List<Consultation>> getConsultations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.PATIENT_CONSULTATIONS,
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> list =
            data is List ? data : (data['consultations'] ?? data);
        return list.map((json) => Consultation.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error loading consultations: ${e.message}');
      return [];
    }
  }

  /// Get consultation by ID
  /// Backend: GET /patient/consultations/:id
  Future<Consultation> getConsultationById(String id) async {
    try {
      final response =
          await _apiService.get('${ApiConstants.PATIENT_CONSULTATIONS}/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return Consultation.fromJson(data is Map ? data : data);
      }
      throw Exception('Consultation not found');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // ─── Documents ────────────────────────────────────────────────────────

  /// Get all medical documents
  /// Backend: GET /patient/documents
  Future<List<MedicalDocument>> getDocuments() async {
    try {
      final response = await _apiService.get(ApiConstants.PATIENT_DOCUMENTS);
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> list =
            data is List ? data : (data['documents'] ?? data);
        return list.map((json) => MedicalDocument.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error loading documents: ${e.message}');
      return [];
    }
  }

  /// Upload a medical document (multipart)
  /// Backend: POST /patient/documents
  Future<MedicalDocument> uploadDocument(FormData formData) async {
    try {
      final response =
          await _apiService.upload(ApiConstants.PATIENT_DOCUMENTS, formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return MedicalDocument.fromJson(data is Map ? data : data);
      }
      throw Exception('Failed to upload document');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Delete a document
  /// Backend: DELETE /patient/documents/:id
  Future<void> deleteDocument(String id) async {
    try {
      await _apiService.delete('${ApiConstants.PATIENT_DOCUMENTS}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // ─── Allergies ────────────────────────────────────────────────────────

  /// Get all allergies for the authenticated patient (read-only via patient route)
  /// Backend: GET /patient/allergies
  Future<List<Allergy>> getAllergies() async {
    try {
      final response = await _apiService.get(ApiConstants.PATIENT_ALLERGIES);
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> list =
            data is List ? data : (data['allergies'] ?? data);
        return list.map((json) => Allergy.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error loading allergies: ${e.message}');
      return [];
    }
  }

  // ─── Stats ────────────────────────────────────────────────────────────

  /// Get patient dashboard statistics
  /// Backend: GET /patient/stats
  /// Returns: { prescriptionsCount, medicationsCount, consultationsCount, documentsCount }
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiService.get(ApiConstants.PATIENT_STATS);
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;

        return {
          'prescriptionsCount': data['prescriptionsCount'] ?? 0,
          'medicationsCount': data['medicationsCount'] ?? 0,
          'consultationsCount': data['consultationsCount'] ?? 0,
          'documentsCount': data['documentsCount'] ?? 0,
        };
      }
      return _emptyStats();
    } on DioException catch (e) {
      print('Error loading stats: ${e.message}');
      return _emptyStats();
    }
  }

  Map<String, dynamic> _emptyStats() => {
        'prescriptionsCount': 0,
        'medicationsCount': 0,
        'consultationsCount': 0,
        'documentsCount': 0,
      };
}
