// lib/data/providers/pharmacy_provider.dart
import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import '../../app/constants/api_constants.dart';
import '../../core/models/pharmacy_model.dart';

class PharmacyProvider {
  final ApiService _apiService;

  PharmacyProvider(this._apiService);

  /// Get all pharmacies with optional filters
  Future<List<PharmacyModel>> getAllPharmacies({
    String? wilaya,
    bool? isOnDuty,
    double? latitude,
    double? longitude,
    double radius = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (wilaya != null && wilaya.isNotEmpty) queryParams['wilaya'] = wilaya;
      if (isOnDuty != null) queryParams['onDuty'] = isOnDuty;
      if (latitude != null) queryParams['lat'] = latitude;
      if (longitude != null) queryParams['lng'] = longitude;
      if (radius != 10) queryParams['radius'] = radius;

      final response = await _apiService.get(
        ApiConstants.PHARMACIES,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> pharmaciesJson = data['pharmacies'] ?? data;

        return pharmaciesJson
            .map((json) => PharmacyModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load pharmacies');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Get pharmacy by ID
  Future<PharmacyModel> getPharmacyById(String id) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.PHARMACY_DETAIL}/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final pharmacyJson = data['pharmacy'] ?? data;
        return PharmacyModel.fromJson(pharmacyJson);
      }
      throw Exception('Pharmacy not found');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Get nearby pharmacies within radius (km)
  Future<List<PharmacyModel>> getNearbyPharmacies(
    double latitude,
    double longitude, {
    double radius = 5,
    String? wilaya,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'lat': latitude,
        'lng': longitude,
        'radius': radius,
        if (wilaya != null && wilaya.isNotEmpty) 'wilaya': wilaya,
      };

      final response = await _apiService.get(
        ApiConstants.NEARBY_PHARMACIES,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> pharmaciesJson = data['pharmacies'] ?? data;

        return pharmaciesJson
            .map((json) => PharmacyModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error getting nearby pharmacies: ${e.message}');
      return [];
    }
  }

  /// Get pharmacies on duty (de garde)
  Future<List<PharmacyModel>> getDutyPharmacies({
    String? wilaya,
    double? latitude,
    double? longitude,
    double radius = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (wilaya != null && wilaya.isNotEmpty) queryParams['wilaya'] = wilaya;
      if (latitude != null) queryParams['lat'] = latitude;
      if (longitude != null) queryParams['lng'] = longitude;
      if (radius != 10) queryParams['radius'] = radius;

      final response = await _apiService.get(
        ApiConstants.DUTY_PHARMACIES,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> pharmaciesJson = data['pharmacies'] ?? data;

        return pharmaciesJson
            .map((json) => PharmacyModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error getting duty pharmacies: ${e.message}');
      return [];
    }
  }

  /// Get pharmacies by wilaya
  Future<List<PharmacyModel>> getPharmaciesByWilaya(String wilaya) async {
    return getAllPharmacies(wilaya: wilaya);
  }

  /// Search pharmacies by name or address
  Future<List<PharmacyModel>> searchPharmacies(String query) async {
    try {
      final response = await _apiService.get(
        ApiConstants.PHARMACIES,
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> pharmaciesJson = data['pharmacies'] ?? data;

        return pharmaciesJson
            .map((json) => PharmacyModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error searching pharmacies: ${e.message}');
      return [];
    }
  }
}
