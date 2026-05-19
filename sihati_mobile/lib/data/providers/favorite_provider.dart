// lib/data/providers/favorite_provider.dart
import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import '../../app/constants/api_constants.dart';
import '../../core/models/doctor_model.dart';
import '../../core/models/pharmacy_model.dart';

/// Favorite provider — communicates with the Sihati backend favorites API.
///
/// All routes require authentication (JWT interceptor handles this automatically).
///
/// Backend routes:
///   GET    /favorites/stats
///   GET    /favorites/doctors
///   POST   /favorites/doctors/:id
///   DELETE /favorites/doctors/:id
///   GET    /favorites/doctors/:id/check
///   GET    /favorites/pharmacies
///   POST   /favorites/pharmacies/:id
///   DELETE /favorites/pharmacies/:id
///   GET    /favorites/pharmacies/:id/check
class FavoriteProvider {
  final ApiService _apiService;

  FavoriteProvider(this._apiService);

  // ─── Doctor Favorites ─────────────────────────────────────────────────

  /// Get all favorite doctors for the authenticated user
  /// Backend: GET /favorites/doctors
  Future<List<DoctorModel>> getFavoriteDoctors() async {
    try {
      final response = await _apiService.get(ApiConstants.FAVORITES_DOCTORS);

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> doctorsJson = data['doctors'] ?? data;
        return doctorsJson.map((json) => DoctorModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error getting favorite doctors: ${e.message}');
      return [];
    }
  }

  /// Add a doctor to favorites
  /// Backend: POST /favorites/doctors/:id
  Future<bool> addFavoriteDoctor(String doctorId) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.FAVORITES_DOCTORS}/$doctorId',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? e.message ?? 'Failed to add favorite');
    }
  }

  /// Remove a doctor from favorites
  /// Backend: DELETE /favorites/doctors/:id
  Future<bool> removeFavoriteDoctor(String doctorId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.FAVORITES_DOCTORS}/$doctorId',
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ??
          e.message ??
          'Failed to remove favorite');
    }
  }

  /// Check if a doctor is in the user's favorites
  /// Backend: GET /favorites/doctors/:id/check
  Future<bool> checkDoctorFavorite(String doctorId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.FAVORITES_DOCTORS}/$doctorId/check',
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data['isFavorite'] == true;
      }
      return false;
    } on DioException catch (e) {
      print('Error checking doctor favorite: ${e.message}');
      return false;
    }
  }

  // ─── Pharmacy Favorites ───────────────────────────────────────────────

  /// Get all favorite pharmacies for the authenticated user
  /// Backend: GET /favorites/pharmacies
  Future<List<PharmacyModel>> getFavoritePharmacies() async {
    try {
      final response =
          await _apiService.get(ApiConstants.FAVORITES_PHARMACIES);

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> pharmaciesJson = data['pharmacies'] ?? data;
        return pharmaciesJson
            .map((json) => PharmacyModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error getting favorite pharmacies: ${e.message}');
      return [];
    }
  }

  /// Add a pharmacy to favorites
  /// Backend: POST /favorites/pharmacies/:id
  Future<bool> addFavoritePharmacy(String pharmacyId) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.FAVORITES_PHARMACIES}/$pharmacyId',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? e.message ?? 'Failed to add favorite');
    }
  }

  /// Remove a pharmacy from favorites
  /// Backend: DELETE /favorites/pharmacies/:id
  Future<bool> removeFavoritePharmacy(String pharmacyId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.FAVORITES_PHARMACIES}/$pharmacyId',
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ??
          e.message ??
          'Failed to remove favorite');
    }
  }

  /// Check if a pharmacy is in the user's favorites
  /// Backend: GET /favorites/pharmacies/:id/check
  Future<bool> checkPharmacyFavorite(String pharmacyId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.FAVORITES_PHARMACIES}/$pharmacyId/check',
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data['isFavorite'] == true;
      }
      return false;
    } on DioException catch (e) {
      print('Error checking pharmacy favorite: ${e.message}');
      return false;
    }
  }

  // ─── Stats ────────────────────────────────────────────────────────────

  /// Get favorite counts summary
  /// Backend: GET /favorites/stats
  Future<Map<String, int>> getFavoriteStats() async {
    try {
      final response = await _apiService.get(ApiConstants.FAVORITES_STATS);
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return {
          'doctors': data['doctorsCount'] ?? 0,
          'pharmacies': data['pharmaciesCount'] ?? 0,
        };
      }
      return {'doctors': 0, 'pharmacies': 0};
    } on DioException catch (e) {
      print('Error getting favorite stats: ${e.message}');
      return {'doctors': 0, 'pharmacies': 0};
    }
  }
}
