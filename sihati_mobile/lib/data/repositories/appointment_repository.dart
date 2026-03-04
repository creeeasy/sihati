import 'package:sihati_mobile/core/models/appointment_model.dart';
import '../providers/mock/mock_appointment_provider.dart';

/// Appointment repository
/// Handles appointment operations
class AppointmentRepository {
  final MockAppointmentProvider _appointmentProvider;

  AppointmentRepository({
    required MockAppointmentProvider appointmentProvider,
  }) : _appointmentProvider = appointmentProvider;

  /// Get all appointments for current user
  Future<List<AppointmentModel>> getMyAppointments(int patientId) async {
    try {
      return await _appointmentProvider.getPatientAppointments(patientId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get upcoming appointments
  Future<List<AppointmentModel>> getUpcomingAppointments(int patientId) async {
    try {
      return await _appointmentProvider.getUpcomingAppointments(patientId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get past appointments
  Future<List<AppointmentModel>> getPastAppointments(int patientId) async {
    try {
      return await _appointmentProvider.getPastAppointments(patientId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get appointment by ID
  Future<AppointmentModel> getAppointmentById(int id) async {
    try {
      return await _appointmentProvider.getAppointmentById(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Book new appointment
  Future<AppointmentModel> bookAppointment({
    required int patientId,
    required int doctorId,
    required DateTime date,
    required String time,
    String? reason,
  }) async {
    try {
      // Validate date (not in the past)
      if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        throw Exception('La date ne peut pas être dans le passé');
      }

      return await _appointmentProvider.bookAppointment(
        patientId: patientId,
        doctorId: doctorId,
        date: date,
        time: time,
        reason: reason,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel appointment
  Future<void> cancelAppointment(int appointmentId) async {
    try {
      await _appointmentProvider.cancelAppointment(appointmentId);
    } catch (e) {
      rethrow;
    }
  }

  /// Reschedule appointment
  Future<AppointmentModel> rescheduleAppointment({
    required int appointmentId,
    required DateTime newDate,
    required String newTime,
  }) async {
    try {
      // Validate date (not in the past)
      if (newDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        throw Exception('La date ne peut pas être dans le passé');
      }

      return await _appointmentProvider.rescheduleAppointment(
        id: appointmentId,
        newDate: newDate,
        newTime: newTime,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get available slots for a doctor on a specific date
  Future<List<String>> getAvailableSlots({
    required int doctorId,
    required DateTime date,
  }) async {
    try {
      return await _appointmentProvider.getAvailableSlots(
        doctorId: doctorId,
        date: date,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get next available slot for a doctor
  Future<String?> getNextAvailableSlot(int doctorId) async {
    try {
      return await _appointmentProvider.getNextAvailableSlot(doctorId);
    } catch (e) {
      return null;
    }
  }

  /// Check if user has appointment with doctor
  Future<bool> hasAppointmentWith(int patientId, int doctorId) async {
    try {
      final appointments = await getUpcomingAppointments(patientId);
      return appointments.any((a) => a.doctorId == doctorId);
    } catch (e) {
      return false;
    }
  }

  /// Get appointments count
  Future<Map<String, int>> getAppointmentsCounts(int patientId) async {
    try {
      final appointments = await getMyAppointments(patientId);

      return {
        'total': appointments.length,
        'upcoming': appointments.where((a) => a.isUpcoming).length,
        'past': appointments.where((a) => a.isPast).length,
        'cancelled': appointments
            .where((a) => a.status == AppointmentStatus.cancelled)
            .length,
      };
    } catch (e) {
      return {
        'total': 0,
        'upcoming': 0,
        'past': 0,
        'cancelled': 0,
      };
    }
  }
}
