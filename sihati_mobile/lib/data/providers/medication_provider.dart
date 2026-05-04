import 'package:dio/dio.dart';
import 'package:sihati_mobile/core/models/pharmacy_with_stock.dart';
import '../../core/services/api_service.dart';
import '../../app/constants/api_constants.dart';
import '../../core/models/medication_model.dart';
import '../../core/models/medication_search_result.dart';

class MedicationProvider {
  final ApiService _apiService;

  MedicationProvider(this._apiService);

  /// Search medications by name and return results with pharmacies
  Future<List<MedicationSearchResult>> searchMedication(
    String searchTerm, {
    double? latitude,
    double? longitude,
    String? wilaya,
    double radius = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': searchTerm,
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
        if (wilaya != null && wilaya.isNotEmpty) 'wilaya': wilaya,
        'radius': radius,
      };

      final response = await _apiService.get(
        ApiConstants.MEDICATION_SEARCH,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> resultsJson = data['results'] ?? data;

        return resultsJson
            .map((json) => MedicationSearchResult.fromJson(json))
            .toList();
      }
      throw Exception('Failed to search medications');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Get medication by ID
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

  /// Search medications by barcode
  Future<MedicationModel?> searchByBarcode(String barcode) async {
    try {
      final response = await _apiService.post(
        '/medications/barcode',
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

  /// Get pharmacies that have a specific medication in stock
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
        '/medications/$medicationId/pharmacies',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> pharmaciesJson = data['pharmacies'] ?? data;

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

  /// Get all medications (for browsing)
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
        final List<dynamic> medicationsJson = data['medications'] ?? data;

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
  Future<List<MedicationModel>> getPopularMedications({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/medications/popular',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> medicationsJson = data['medications'] ?? data;

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

  /// Check drug interactions
  Future<Map<String, dynamic>> checkInteractions({
    required List<String> medicationIds,
    required String newMedicationId,
  }) async {
    try {
      final response = await _apiService.post(
        '/ai/check-interactions',
        data: {
          'currentMedications': medicationIds,
          'newMedication': newMedicationId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return {
          'hasInteractions': data['hasInteractions'] ?? false,
          'interactions': data['interactions'] ?? [],
          'safeToTake': data['safeToTake'] ?? true,
        };
      }
      return {'hasInteractions': false, 'interactions': [], 'safeToTake': true};
    } on DioException catch (e) {
      print('Interaction check error: ${e.message}');
      return {'hasInteractions': false, 'interactions': [], 'safeToTake': true};
    }
  }
}
