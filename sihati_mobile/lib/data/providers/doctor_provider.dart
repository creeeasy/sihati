// lib/data/providers/doctor_provider.dart
import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import '../../app/constants/api_constants.dart';
import '../../core/models/doctor_model.dart';
import '../../core/models/specialty_model.dart';

/// Doctor provider — communicates with the Sihati backend
///
/// Available backend routes used (patient-only):
///   GET /doctors             → all doctors
///   GET /doctors/:id         → doctor detail
///   GET /doctors/search      → search with filters
///   GET /doctors/top-rated   → top rated doctors
///   GET /doctors/specialties → all specialties
class DoctorProvider {
  final ApiService _apiService;

  DoctorProvider(this._apiService);

  // ─── Specialties ────────────────────────────────────────────────────

  /// Get all medical specialties
  /// Backend: GET /doctors/specialties
  Future<List<SpecialtyModel>> getSpecialties() async {
    try {
      final response = await _apiService.get(ApiConstants.SPECIALTIES);

      if (response.statusCode == 200) {
        final List<SpecialtyModel> list = (response.data['data']
                as List<dynamic>)
            .map(
                (json) => SpecialtyModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return list;
      }
      throw Exception('Failed to load specialties');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // ─── Search ─────────────────────────────────────────────────────────

  /// Search doctors with filters
  /// Backend: GET /doctors/search
  Future<List<DoctorModel>> searchDoctors({
    String? specialtyId,
    String? wilaya,
    double? latitude,
    double? longitude,
    double radius = 10,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (specialtyId != null && specialtyId.isNotEmpty)
        queryParams['specialtyId'] = specialtyId;
      if (wilaya != null && wilaya.isNotEmpty) queryParams['wilaya'] = wilaya;
      if (latitude != null) queryParams['lat'] = latitude;
      if (longitude != null) queryParams['lng'] = longitude;
      if (radius != 10) queryParams['radius'] = radius;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final response = await _apiService.get(
        ApiConstants.DOCTOR_SEARCH,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<DoctorModel> list = (response.data['data'] as List<dynamic>)
            .map((json) => DoctorModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return list;
      }
      throw Exception('Failed to search doctors');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Search doctors by name
  /// Backend: GET /doctors/search?q=
  Future<List<DoctorModel>> searchByName(String query) async {
    try {
      final response = await _apiService.get(
        ApiConstants.DOCTOR_SEARCH,
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final List<DoctorModel> list = (response.data['data'] as List<dynamic>)
            .map((json) => DoctorModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return list;
      }
      return [];
    } on DioException catch (e) {
      print('Error searching by name: ${e.message}');
      return [];
    }
  }

  // ─── List ────────────────────────────────────────────────────────────

  /// Get all doctors
  /// Backend: GET /doctors
  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      final response = await _apiService.get(ApiConstants.DOCTORS);

      if (response.statusCode == 200) {
        final List<DoctorModel> list = (response.data['data'] as List<dynamic>)
            .map((json) => DoctorModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return list;
      }
      throw Exception('Failed to load doctors');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Get doctor by ID
  /// Backend: GET /doctors/:id
  Future<DoctorModel> getDoctorById(String id) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.DOCTOR_DETAIL}/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return DoctorModel.fromJson(data);
      }
      throw Exception('Doctor not found');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Get doctors by specialty (convenience)
  Future<List<DoctorModel>> getDoctorsBySpecialty(String specialtyId) async {
    return searchDoctors(specialtyId: specialtyId);
  }

  /// Get doctors by wilaya (convenience)
  Future<List<DoctorModel>> getDoctorsByWilaya(String wilaya) async {
    return searchDoctors(wilaya: wilaya);
  }

  /// Get top rated doctors
  /// Backend: GET /doctors/top-rated
  Future<List<DoctorModel>> getTopRatedDoctors({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.DOCTOR_TOP_RATED,
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<DoctorModel> list = (response.data['data'] as List<dynamic>)
            .map((json) => DoctorModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return list;
      }
      return [];
    } on DioException catch (e) {
      print('Error getting top rated doctors: ${e.message}');
      return [];
    }
  }
}
