/*import 'package:sihati_mobile/core/models/appointment_model.dart';
import 'mock_doctor_provider.dart';

class MockAppointmentProvider {
  final MockDoctorProvider _doctorProvider;

  final List<AppointmentModel> _appointments = [];
  int _nextId = 1;

  MockAppointmentProvider({required MockDoctorProvider doctorProvider})
      : _doctorProvider = doctorProvider {
    _initializeDemoData();
  }

  void _initializeDemoData() {
    final now = DateTime.now();

    _appointments.addAll([
      AppointmentModel(
        id: _nextId++,
        patientId: 1,
        doctorId: 1,
        appointmentDate: now.add(const Duration(days: 1)),
        appointmentTime: '10:00',
        status: AppointmentStatus.confirmed,
        reason: 'Consultation de suivi',
        createdAt: now,
      ),
      AppointmentModel(
        id: _nextId++,
        patientId: 1,
        doctorId: 5,
        appointmentDate: now.add(const Duration(days: 7)),
        appointmentTime: '14:00',
        status: AppointmentStatus.pending,
        reason: 'Premier rendez-vous',
        createdAt: now,
      ),
    ]);
  }

  Future<List<AppointmentModel>> getPatientAppointments(int patientId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var appointments =
        _appointments.where((a) => a.patientId == patientId).toList();

    for (var i = 0; i < appointments.length; i++) {
      try {
        final doctor =
            await _doctorProvider.getDoctorById(appointments[i].doctorId);
        appointments[i] = appointments[i].copyWith(doctor: doctor);
      } catch (e) {
        print('Error loading doctor for appointment ${appointments[i].id}: $e');
      }
    }

    appointments.sort((a, b) {
      final dateA = DateTime(
        a.appointmentDate.year,
        a.appointmentDate.month,
        a.appointmentDate.day,
        int.parse(a.appointmentTime.split(':')[0]),
        int.parse(a.appointmentTime.split(':')[1]),
      );
      final dateB = DateTime(
        b.appointmentDate.year,
        b.appointmentDate.month,
        b.appointmentDate.day,
        int.parse(b.appointmentTime.split(':')[0]),
        int.parse(b.appointmentTime.split(':')[1]),
      );
      return dateA.compareTo(dateB);
    });

    return appointments;
  }

  Future<List<AppointmentModel>> getUpcomingAppointments(int patientId) async {
    final all = await getPatientAppointments(patientId);
    return all.where((a) => a.isUpcoming).toList();
  }

  Future<List<AppointmentModel>> getPastAppointments(int patientId) async {
    final all = await getPatientAppointments(patientId);
    return all.where((a) => a.isPast).toList();
  }

  Future<AppointmentModel> getAppointmentById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      var appointment = _appointments.firstWhere((a) => a.id == id);

      final doctor = await _doctorProvider.getDoctorById(appointment.doctorId);
      appointment = appointment.copyWith(doctor: doctor);

      return appointment;
    } catch (e) {
      throw Exception('Rendez-vous non trouvé');
    }
  }

  Future<AppointmentModel> bookAppointment({
    required int patientId,
    required int doctorId,
    required DateTime date,
    required String time,
    String? reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final isAvailable = await _isSlotAvailable(doctorId, date, time);
    if (!isAvailable) {
      throw Exception('Ce créneau n\'est plus disponible');
    }

    final appointment = AppointmentModel(
      id: _nextId++,
      patientId: patientId,
      doctorId: doctorId,
      appointmentDate: date,
      appointmentTime: time,
      status: AppointmentStatus.pending,
      reason: reason,
      createdAt: DateTime.now(),
    );

    _appointments.add(appointment);

    final doctor = await _doctorProvider.getDoctorById(doctorId);
    return appointment.copyWith(doctor: doctor);
  }

  Future<void> cancelAppointment(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _appointments.indexWhere((a) => a.id == id);
    if (index == -1) {
      throw Exception('Rendez-vous non trouvé');
    }

    _appointments[index] = _appointments[index].copyWith(
      status: AppointmentStatus.cancelled,
      updatedAt: DateTime.now(),
    );
  }

  Future<AppointmentModel> rescheduleAppointment({
    required int id,
    required DateTime newDate,
    required String newTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _appointments.indexWhere((a) => a.id == id);
    if (index == -1) {
      throw Exception('Rendez-vous non trouvé');
    }

    final appointment = _appointments[index];

    final isAvailable = await _isSlotAvailable(
      appointment.doctorId,
      newDate,
      newTime,
    );
    if (!isAvailable) {
      throw Exception('Ce créneau n\'est plus disponible');
    }

    _appointments[index] = appointment.copyWith(
      appointmentDate: newDate,
      appointmentTime: newTime,
      status: AppointmentStatus.pending,
      updatedAt: DateTime.now(),
    );

    final doctor = await _doctorProvider.getDoctorById(appointment.doctorId);
    return _appointments[index].copyWith(doctor: doctor);
  }

  Future<List<String>> getAvailableSlots({
    required int doctorId,
    required DateTime date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    print(
        '🔍 Getting slots for doctor $doctorId on ${date.day}/${date.month}/${date.year}');

    final doctor = await _doctorProvider.getDoctorById(doctorId);

    print('👨‍⚕️ Doctor: ${doctor.doctorName}');
    print('📅 Working hours: ${doctor.workingHours}');

    final dayNames = [
      'dimanche',
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi'
    ];
    final dayName = dayNames[date.weekday % 7];

    print('📆 Day name: $dayName (weekday: ${date.weekday})');

    final hours = doctor.getHoursForDay(dayName);

    print('⏰ Hours for $dayName: $hours');

    if (hours == null) {
      print('❌ No working hours for $dayName');
      return [];
    }

    List<String> slots = [];

    if (hours['morning'] != null && hours['morning']!.isNotEmpty) {
      print('🌅 Morning hours: ${hours['morning']}');
      final morning = hours['morning']!.split('-');
      if (morning.length == 2) {
        final morningSlots =
            _generateSlots(morning[0].trim(), morning[1].trim());
        print(
            '🌅 Generated ${morningSlots.length} morning slots: $morningSlots');
        slots.addAll(morningSlots);
      }
    }

    if (hours['afternoon'] != null && hours['afternoon']!.isNotEmpty) {
      print('🌆 Afternoon hours: ${hours['afternoon']}');
      final afternoon = hours['afternoon']!.split('-');
      if (afternoon.length == 2) {
        final afternoonSlots =
            _generateSlots(afternoon[0].trim(), afternoon[1].trim());
        print(
            '🌆 Generated ${afternoonSlots.length} afternoon slots: $afternoonSlots');
        slots.addAll(afternoonSlots);
      }
    }

    print('📋 Total slots before filtering: ${slots.length}');

    final bookedSlots = _appointments
        .where((a) =>
            a.doctorId == doctorId &&
            a.appointmentDate.year == date.year &&
            a.appointmentDate.month == date.month &&
            a.appointmentDate.day == date.day &&
            (a.status == AppointmentStatus.pending ||
                a.status == AppointmentStatus.confirmed))
        .map((a) => a.appointmentTime)
        .toList();

    print('🚫 Booked slots: $bookedSlots');

    slots.removeWhere((slot) => bookedSlots.contains(slot));

    print('✅ Available slots: ${slots.length} - $slots');

    return slots;
  }

  List<String> _generateSlots(String startTime, String endTime) {
    final slots = <String>[];

    try {
      print('⚙️ Generating slots from $startTime to $endTime');

      final startParts = startTime.split(':');
      final endParts = endTime.split(':');

      int startHour = int.parse(startParts[0]);
      int startMinute = startParts.length > 1 ? int.parse(startParts[1]) : 0;

      int endHour = int.parse(endParts[0]);
      int endMinute = endParts.length > 1 ? int.parse(endParts[1]) : 0;

      var currentHour = startHour;
      var currentMinute = startMinute;

      while (currentHour < endHour ||
          (currentHour == endHour && currentMinute < endMinute)) {
        slots.add(
            '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}');

        currentMinute += 30;
        if (currentMinute >= 60) {
          currentMinute -= 60;
          currentHour++;
        }
      }

      print('⚙️ Generated ${slots.length} slots');
    } catch (e) {
      print('❌ Error generating slots: $e');
    }

    return slots;
  }

  Future<bool> _isSlotAvailable(
      int doctorId, DateTime date, String time) async {
    final slots = await getAvailableSlots(doctorId: doctorId, date: date);
    return slots.contains(time);
  }

  Future<String?> getNextAvailableSlot(int doctorId) async {
    final now = DateTime.now();

    for (var i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final slots = await getAvailableSlots(doctorId: doctorId, date: date);

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
  }

  String _formatDate(DateTime date) {
    final days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    return '${days[date.weekday % 7]} ${date.day}/${date.month}';
  }
}

*/
