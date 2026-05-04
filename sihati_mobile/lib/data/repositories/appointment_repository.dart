// lib/data/repositories/appointment_repository.dart
import '../providers/appointment_provider.dart';
import '../../core/models/appointment_model.dart';

/// Appointment repository
/// Handles appointment operations with real backend
class AppointmentRepository {
  final AppointmentProvider _appointmentProvider;

  AppointmentRepository({
    required AppointmentProvider appointmentProvider,
  }) : _appointmentProvider = appointmentProvider;

  /// Get all appointments for current user
  Future<List<AppointmentModel>> getMyAppointments(String patientId) async {
    try {
      return await _appointmentProvider.getPatientAppointments(patientId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get upcoming appointments
  Future<List<AppointmentModel>> getUpcomingAppointments(
      String patientId) async {
    try {
      return await _appointmentProvider.getUpcomingAppointments(patientId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get past appointments
  Future<List<AppointmentModel>> getPastAppointments(String patientId) async {
    try {
      return await _appointmentProvider.getPastAppointments(patientId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get appointment by ID
  Future<AppointmentModel> getAppointmentById(String id) async {
    try {
      return await _appointmentProvider.getAppointmentById(id);
    } catch (e) {
      rethrow;
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
      final today = DateTime.now();
      final appointmentDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(time.split(':')[0]),
        int.parse(time.split(':')[1]),
      );

      if (appointmentDateTime.isBefore(today)) {
        throw Exception('La date ne peut pas être dans le passé');
      }

      return await _appointmentProvider.bookAppointment(
        patientId: patientId,
        doctorId: doctorId,
        date: date,
        time: time,
        reason: reason,
        officeId: officeId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _appointmentProvider.cancelAppointment(appointmentId);
    } catch (e) {
      rethrow;
    }
  }

  /// Reschedule appointment
  Future<AppointmentModel> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDate,
    required String newTime,
  }) async {
    try {
      final today = DateTime.now();
      final appointmentDateTime = DateTime(
        newDate.year,
        newDate.month,
        newDate.day,
        int.parse(newTime.split(':')[0]),
        int.parse(newTime.split(':')[1]),
      );

      if (appointmentDateTime.isBefore(today)) {
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
    required String doctorId,
    required DateTime date,
    String? officeId,
  }) async {
    try {
      return await _appointmentProvider.getAvailableSlots(
        doctorId: doctorId,
        date: date,
        officeId: officeId,
      );
    } catch (e) {
      return [];
    }
  }

  /// 🆕 Get next available slot for a doctor
  /// Returns a human-readable string like "Aujourd'hui 10:00" or "Demain 14:30"
  Future<String?> getNextAvailableSlot(String doctorId) async {
    try {
      final now = DateTime.now();

      // Check next 7 days
      for (var i = 0; i < 7; i++) {
        final date = now.add(Duration(days: i));
        final slots = await getAvailableSlots(
          doctorId: doctorId,
          date: date,
        );

        if (slots.isNotEmpty) {
          if (i == 0) {
            return 'Aujourd\'hui ${slots.first}';
          } else if (i == 1) {
            return 'Demain ${slots.first}';
          } else {
            return '${_formatDate(date)} ${slots.first}';
          }
        }
      }

      return null;
    } catch (e) {
      print('Error getting next available slot: $e');
      return null;
    }
  }

  /// 🆕 Format date for display
  String _formatDate(DateTime date) {
    final days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    return '${days[date.weekday % 7]} ${date.day}/${date.month}';
  }

  /// Check if user has appointment with doctor
  Future<bool> hasAppointmentWith(String patientId, String doctorId) async {
    try {
      final appointments = await getUpcomingAppointments(patientId);
      return appointments.any((a) => a.doctorId == doctorId);
    } catch (e) {
      return false;
    }
  }

  /// Get appointments count
  Future<Map<String, int>> getAppointmentsCounts(String patientId) async {
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
