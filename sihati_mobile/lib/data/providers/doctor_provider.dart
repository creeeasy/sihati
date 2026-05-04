// lib/data/providers/doctor_provider.dart
import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import '../../app/constants/api_constants.dart';
import '../../core/models/doctor_model.dart';
import '../../core/models/specialty_model.dart';

class DoctorProvider {
  final ApiService _apiService;

  DoctorProvider(this._apiService);

  /// Get all medical specialties
  Future<List<SpecialtyModel>> getSpecialties() async {
    try {
      final response = await _apiService.get(ApiConstants.SPECIALTIES);

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> specialtiesJson = data['specialties'] ?? data;

        return specialtiesJson
            .map((json) => SpecialtyModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load specialties');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Search doctors with filters
  /// ✅ CORRIGÉ: specialtyId est String? (UUID)
  Future<List<DoctorModel>> searchDoctors({
    String? specialtyId, // ✅ String?
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
        final data = response.data['data'] ?? response.data;
        final List<dynamic> doctorsJson = data['doctors'] ?? data;

        return doctorsJson.map((json) => DoctorModel.fromJson(json)).toList();
      }
      throw Exception('Failed to search doctors');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Get doctor by ID
  Future<DoctorModel> getDoctorById(String id) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.DOCTOR_DETAIL}/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final doctorJson = data['doctor'] ?? data;
        return DoctorModel.fromJson(doctorJson);
      }
      throw Exception('Doctor not found');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Get all doctors
  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      final response = await _apiService.get(ApiConstants.DOCTORS);

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> doctorsJson = data['doctors'] ?? data;

        return doctorsJson.map((json) => DoctorModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load doctors');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Get doctors by specialty
  Future<List<DoctorModel>> getDoctorsBySpecialty(String specialtyId) async {
    return searchDoctors(specialtyId: specialtyId);
  }

  /// Get doctors by wilaya
  Future<List<DoctorModel>> getDoctorsByWilaya(String wilaya) async {
    return searchDoctors(wilaya: wilaya);
  }

  /// Get top rated doctors
  Future<List<DoctorModel>> getTopRatedDoctors({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/doctors/top-rated',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> doctorsJson = data['doctors'] ?? data;

        return doctorsJson.map((json) => DoctorModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error getting top rated doctors: ${e.message}');
      return [];
    }
  }

  /// Search doctors by name
  Future<List<DoctorModel>> searchByName(String query) async {
    try {
      final response = await _apiService.get(
        ApiConstants.DOCTOR_SEARCH,
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> doctorsJson = data['doctors'] ?? data;

        return doctorsJson.map((json) => DoctorModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error searching by name: ${e.message}');
      return [];
    }
  }

  /// Get available time slots
  Future<List<String>> getAvailableSlots({
    required String doctorId,
    required DateTime date,
    String? officeId,
  }) async {
    try {
      final queryParams = {
        'date': date.toIso8601String().split('T')[0],
        if (officeId != null) 'officeId': officeId,
      };

      final response = await _apiService.get(
        '/doctors/$doctorId/available-slots',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> slots = data['slots'] ?? data;
        return slots
            .map((slot) => (slot['time'] ?? slot.toString()).toString())
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error getting available slots: ${e.message}');
      return [];
    }
  }

  /// Get specialty by ID
  Future<SpecialtyModel> getSpecialtyById(String id) async {
    try {
      final specialties = await getSpecialties();
      final specialty = specialties.firstWhere(
        (s) => s.id == id,
        orElse: () => throw Exception('Specialty not found'),
      );
      return specialty;
    } catch (e) {
      throw Exception('Spécialité non trouvée');
    }
  }
}
