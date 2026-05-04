import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import '../../core/models/patient_profile_model.dart';
import '../../core/models/prescription_model.dart';
import '../../core/models/consultation_model.dart';
import '../../core/models/medical_document_model.dart';
import '../../core/models/medication_history_model.dart';

class PatientProvider {
  final ApiService _apiService;

  PatientProvider(this._apiService);

  // ─── Profile ────────────────────────────────────────────────

  Future<PatientProfile> getPatientProfile() async {
    try {
      final response = await _apiService.get('/patient/profile');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return PatientProfile.fromJson(data['profile'] ?? data);
      }
      throw Exception('Failed to load patient profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<PatientProfile> updatePatientProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/patient/profile', data: data);
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return PatientProfile.fromJson(data['profile'] ?? data);
      }
      throw Exception('Failed to update patient profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // ─── Prescriptions ──────────────────────────────────────────

  Future<List<Prescription>> getPrescriptions(
      {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get(
        '/patient/prescriptions',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> list = data['prescriptions'] ?? data;
        return list.map((json) => Prescription.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error loading prescriptions: ${e.message}');
      return [];
    }
  }

  Future<Prescription> getPrescriptionById(String id) async {
    try {
      final response = await _apiService.get('/patient/prescriptions/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return Prescription.fromJson(data['prescription'] ?? data);
      }
      throw Exception('Prescription not found');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<String> downloadPrescriptionPDF(String id) async {
    try {
      final response = await _apiService.get(
        '/patient/prescriptions/$id/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      // Return the file path or URL
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // ─── Medication History ─────────────────────────────────────

  Future<List<MedicationHistory>> getMedicationHistory({bool? active}) async {
    try {
      final queryParams = active != null ? {'active': active} : null;
      final response = await _apiService.get(
        '/patient/medications/history',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> list = data['medications'] ?? data;
        return list.map((json) => MedicationHistory.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error loading medication history: ${e.message}');
      return [];
    }
  }

  Future<List<MedicationHistory>> getActiveMedications() async {
    return getMedicationHistory(active: true);
  }

  // ─── Consultations ─────────────────────────────────────────

  Future<List<Consultation>> getConsultations(
      {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get(
        '/patient/consultations',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> list = data['consultations'] ?? data;
        return list.map((json) => Consultation.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error loading consultations: ${e.message}');
      return [];
    }
  }

  Future<Consultation> getConsultationById(String id) async {
    try {
      final response = await _apiService.get('/patient/consultations/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return Consultation.fromJson(data['consultation'] ?? data);
      }
      throw Exception('Consultation not found');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // ─── Documents ──────────────────────────────────────────────

  Future<List<MedicalDocument>> getDocuments() async {
    try {
      final response = await _apiService.get('/patient/documents');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> list = data['documents'] ?? data;
        return list.map((json) => MedicalDocument.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error loading documents: ${e.message}');
      return [];
    }
  }

  Future<MedicalDocument> uploadDocument(FormData formData) async {
    try {
      final response = await _apiService.upload('/patient/documents', formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return MedicalDocument.fromJson(data['document'] ?? data);
      }
      throw Exception('Failed to upload document');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<void> deleteDocument(String id) async {
    try {
      await _apiService.delete('/patient/documents/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // ─── Allergies ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllergies() async {
    try {
      final response = await _apiService.get('/patient/allergies');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> list = data['allergies'] ?? data;
        return list.map((json) => json as Map<String, dynamic>).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error loading allergies: ${e.message}');
      return [];
    }
  }

  Future<void> addAllergy(Map<String, dynamic> allergy) async {
    try {
      await _apiService.post('/patient/allergies', data: allergy);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<void> deleteAllergy(String id) async {
    try {
      await _apiService.delete('/patient/allergies/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // ─── Stats ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiService.get('/patient/stats');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return {
          'prescriptionsCount': data['prescriptionsCount'] ?? 0,
          'medicationsCount': data['medicationsCount'] ?? 0,
          'consultationsCount': data['consultationsCount'] ?? 0,
          'documentsCount': data['documentsCount'] ?? 0,
        };
      }
      return {
        'prescriptionsCount': 0,
        'medicationsCount': 0,
        'consultationsCount': 0,
        'documentsCount': 0,
      };
    } on DioException catch (e) {
      print('Error loading stats: ${e.message}');
      return {
        'prescriptionsCount': 0,
        'medicationsCount': 0,
        'consultationsCount': 0,
        'documentsCount': 0,
      };
    }
  }

  /// Download a document by ID
  Future<List<int>> downloadDocument(String documentId) async {
    try {
      final response = await _apiService.get(
        '/patient/documents/$documentId/download',
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return List<int>.from(response.data);
      }
      throw Exception('Failed to download document');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
