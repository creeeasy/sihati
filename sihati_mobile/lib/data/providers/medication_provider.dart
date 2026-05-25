// lib/data/providers/medication_provider.dart
import 'package:dio/dio.dart';
import 'package:sihati_mobile/core/models/pharmacy_with_stock.dart';
import '../../core/services/api_service.dart';
import '../../app/constants/api_constants.dart';
import '../../core/models/medication_model.dart';

/// Medication provider — communicates with the Sihati backend
///
/// Available backend routes used (patient-only):
///   GET  /medications                → all medications (paginated)
///   GET  /medications/:id            → medication detail
///   GET  /medications/search         → search by name
///   GET  /medications/popular        → popular medications
///   POST /medications/barcode        → search by barcode
///   GET  /medications/:id/pharmacies → pharmacies with stock
class MedicationProvider {
  final ApiService _apiService;

  MedicationProvider(this._apiService);

  // ─── Search ─────────────────────────────────────────────────────────

  /// Search medications by name and return results with pharmacies
  /// Backend: GET /medications/search
  Future<List<MedicationModel>> searchMedication(String searchTerm) async {
    try {
      final queryParams = <String, dynamic>{
        'q': searchTerm,
      };

      final response = await _apiService.get(
        ApiConstants.MEDICATION_SEARCH,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;

        final List<dynamic> resultsJson =
            data is List ? data : (data['results'] ?? data);
        return resultsJson
            .map((json) =>
                MedicationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to search medications');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Search medications by barcode
  /// Backend: POST /medications/barcode
  Future<MedicationModel?> searchByBarcode(String barcode) async {
    try {
      final response = await _apiService.post(
        ApiConstants.MEDICATION_BARCODE,
        data: {'barcode': barcode},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        if (data['medication'] != null) {
          return MedicationModel.fromJson(data['medication']);
        }
      }
      return null;
    } on DioException catch (e) {
      print('Barcode search error: ${e.message}');
      return null;
    }
  }

  // ─── Detail ─────────────────────────────────────────────────────────

  /// Get medication by ID
  /// Backend: GET /medications/:id
  Future<MedicationModel> getMedicationById(String id) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.MEDICATIONS}/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final medicationJson = data['medication'] ?? data;
        return MedicationModel.fromJson(medicationJson);
      }
      throw Exception('Medication not found');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // ─── List ────────────────────────────────────────────────────────────

  /// Get all medications (paginated)
  /// Backend: GET /medications
  Future<List<MedicationModel>> getAllMedications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.MEDICATIONS,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> medicationsJson =
            data is List ? data : (data['medications'] ?? data);

        return medicationsJson
            .map((json) => MedicationModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error getting all medications: ${e.message}');
      return [];
    }
  }

  /// Get popular medications
  /// Backend: GET /medications/popular
  Future<List<MedicationModel>> getPopularMedications({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.MEDICATION_POPULAR,
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> medicationsJson =
            data is List ? data : (data['medications'] ?? data);

        return medicationsJson
            .map((json) => MedicationModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error getting popular medications: ${e.message}');
      return [];
    }
  }

  // ─── Pharmacy Stock ──────────────────────────────────────────────────

  /// Get pharmacies that have a specific medication in stock
  /// Backend: GET /medications/:id/pharmacies
  Future<List<PharmacyWithStock>> getPharmaciesWithStock(
    String medicationId, {
    double? latitude,
    double? longitude,
    double radius = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
        'radius': radius,
      };

      final response = await _apiService.get(
        '${ApiConstants.MEDICATION_PHARMACIES}/$medicationId/pharmacies',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> pharmaciesJson =
            data is List ? data : (data['pharmacies'] ?? data);

        return pharmaciesJson
            .map((json) => PharmacyWithStock.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error getting pharmacies with stock: ${e.message}');
      return [];
    }
  }
}
