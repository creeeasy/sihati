// lib/data/providers/appointment_provider.dart
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../app/constants/api_constants.dart';
import '../../../core/models/appointment_model.dart';

/// Appointment provider — communicates with the Sihati backend
///
/// Available backend routes used (patient-only):
///   GET  /appointments/patient/:patientId   → all patient appointments
///   GET  /appointments/:id                  → single appointment
///   POST /appointments                      → book new appointment
///   PUT  /appointments/:id/cancel           → cancel
///
/// NOTE: No /upcoming, /past, or /reschedule routes on backend.
/// Filtering is done client-side in AppointmentRepository.
class AppointmentProvider {
  final ApiService _apiService;

  AppointmentProvider(this._apiService);

  // ─── Read ────────────────────────────────────────────────────────────

  /// Get ALL appointments for a patient (upcoming + past combined)
  /// Backend: GET /appointments/patient/:patientId
  Future<List<AppointmentModel>> getPatientAppointments(
      String patientId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.APPOINTMENTS_PATIENT}/$patientId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        // Backend returns: { success: true, data: [...] }
        final List<dynamic> appointmentsJson =
            data is List ? data : (data['appointments'] ?? data);
        print(appointmentsJson);

        return appointmentsJson
            .map((json) => AppointmentModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load appointments');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Get appointment by ID
  /// Backend: GET /appointments/:id
  Future<AppointmentModel> getAppointmentById(String id) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.APPOINTMENTS}/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return AppointmentModel.fromJson(data is Map ? data : data);
      }
      throw Exception('Appointment not found');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // ─── Write ────────────────────────────────────────────────────────────

  /// Book a new appointment
  /// Backend: POST /appointments
  /// Body: { patientId, doctorId, appointmentDate, appointmentTime, reason?, officeId? }
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
          // Backend fields are: appointmentDate + appointmentTime
          'appointmentDate': date.toIso8601String().split('T')[0],
          'appointmentTime': time,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
          if (officeId != null) 'officeId': officeId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return AppointmentModel.fromJson(data is Map ? data : data);
      }
      throw Exception('Failed to book appointment');
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception(message);
    }
  }

  /// Cancel an appointment
  /// Backend: PUT /appointments/:id/cancel
  Future<void> cancelAppointment(String id, {String? reason}) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.APPOINTMENTS}/$id/cancel',
        data: reason != null ? {'reason': reason} : null,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel appointment');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // ─── Slots ────────────────────────────────────────────────────────────

  /// Get available time slots for a doctor on a date
  /// Backend: GET /doctors/:doctorId/available-slots?date=YYYY-MM-DD&officeId=?
  Future<List<String>> getAvailableSlots({
    required String doctorId,
    required DateTime date,
    String? officeId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'date': date.toIso8601String().split('T')[0],
        if (officeId != null) 'officeId': officeId,
      };

      final response = await _apiService.get(
        '${ApiConstants.DOCTOR_AVAILABLE_SLOTS}/$doctorId/available-slots',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> slots =
            data is List ? data : (data['slots'] ?? data);
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
}
