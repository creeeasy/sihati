import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../app/constants/api_constants.dart';
import '../../../core/models/appointment_model.dart';

class AppointmentProvider {
  final ApiService _apiService;

  AppointmentProvider(this._apiService);

  /// Get all appointments for a patient
  Future<List<AppointmentModel>> getPatientAppointments(
      String patientId) async {
    try {
      final response = await _apiService.get(
        '/appointments/patient/$patientId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> appointmentsJson = data['appointments'] ?? data;

        return appointmentsJson
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load appointments');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Get appointments for a doctor
  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId) async {
    try {
      final response = await _apiService.get(
        '/appointments/doctor/$doctorId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> appointmentsJson = data['appointments'] ?? data;

        return appointmentsJson
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load appointments');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Get upcoming appointments
  Future<List<AppointmentModel>> getUpcomingAppointments(
      String patientId) async {
    try {
      final response = await _apiService.get(
        '/appointments/patient/$patientId/upcoming',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> appointmentsJson = data['appointments'] ?? data;

        return appointmentsJson
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load upcoming appointments');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Get past appointments
  Future<List<AppointmentModel>> getPastAppointments(String patientId) async {
    try {
      final response = await _apiService.get(
        '/appointments/patient/$patientId/past',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> appointmentsJson = data['appointments'] ?? data;

        return appointmentsJson
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load past appointments');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Get appointment by ID
  Future<AppointmentModel> getAppointmentById(String id) async {
    try {
      final response = await _apiService.get(
        '/appointments/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return AppointmentModel.fromJson(data['appointment'] ?? data);
      }
      throw Exception('Appointment not found');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Book new appointment
  Future<AppointmentModel> bookAppointment({
    required String patientId,
    required String doctorId,
    required DateTime date,
    required String time,
    String? reason,
    String? officeId,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.APPOINTMENTS,
        data: {
          'patientId': patientId,
          'doctorId': doctorId,
          'date': date.toIso8601String().split('T')[0],
          'time': time,
          'reason': reason,
          if (officeId != null) 'officeId': officeId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return AppointmentModel.fromJson(data['appointment'] ?? data);
      }
      throw Exception('Failed to book appointment');
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception(message);
    }
  }

  /// Cancel appointment
  Future<void> cancelAppointment(String id) async {
    try {
      final response = await _apiService.put(
        '/appointments/$id/cancel',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel appointment');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Reschedule appointment
  Future<AppointmentModel> rescheduleAppointment({
    required String id,
    required DateTime newDate,
    required String newTime,
  }) async {
    try {
      final response = await _apiService.put(
        '/appointments/$id/reschedule',
        data: {
          'date': newDate.toIso8601String().split('T')[0],
          'time': newTime,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return AppointmentModel.fromJson(data['appointment'] ?? data);
      }
      throw Exception('Failed to reschedule appointment');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Get available slots for a doctor
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

  /// Confirm appointment (Doctor only)
  Future<AppointmentModel> confirmAppointment(String id) async {
    try {
      final response = await _apiService.put(
        '/appointments/$id/confirm',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return AppointmentModel.fromJson(data['appointment'] ?? data);
      }
      throw Exception('Failed to confirm appointment');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Complete appointment (Doctor only)
  Future<AppointmentModel> completeAppointment(String id) async {
    try {
      final response = await _apiService.put(
        '/appointments/$id/complete',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return AppointmentModel.fromJson(data['appointment'] ?? data);
      }
      throw Exception('Failed to complete appointment');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
