import 'doctor_model.dart';

class AppointmentModel {
  final int id;
  final int patientId;
  final int doctorId;
  final DateTime appointmentDate;
  final String appointmentTime; // "10:00", "14:30"
  final AppointmentStatus status;
  final String? reason;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Optional: populated when fetching appointment details
  final DoctorModel? doctor;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.reason,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.doctor,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as int,
      patientId: json['patientId'] ?? json['patient_id'] ?? 0,
      doctorId: json['doctorId'] ?? json['doctor_id'] ?? 0,
      appointmentDate:
          DateTime.parse(json['appointmentDate'] ?? json['appointment_date']),
      appointmentTime:
          json['appointmentTime'] ?? json['appointment_time'] ?? '',
      status: _statusFromString(json['status'] as String?),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      doctor: json['doctor'] != null
          ? DoctorModel.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentDate': appointmentDate.toIso8601String().split('T')[0],
      'appointmentTime': appointmentTime,
      'status': status.toShortString(),
      'reason': reason,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper: Get formatted date
  String get formattedDate {
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return '${appointmentDate.day} ${months[appointmentDate.month - 1]} ${appointmentDate.year}';
  }

  // Helper: Get formatted time
  String get formattedTime {
    return appointmentTime;
  }

  // Helper: Get formatted date and time
  String get formattedDateTime {
    return '$formattedDate à $appointmentTime';
  }

  // Helper: Check if upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    final appointmentDateTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      int.parse(appointmentTime.split(':')[0]),
      int.parse(appointmentTime.split(':')[1]),
    );
    return appointmentDateTime.isAfter(now) &&
        (status == AppointmentStatus.pending ||
            status == AppointmentStatus.confirmed);
  }

  // Helper: Check if past
  bool get isPast {
    final now = DateTime.now();
    final appointmentDateTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      int.parse(appointmentTime.split(':')[0]),
      int.parse(appointmentTime.split(':')[1]),
    );
    return appointmentDateTime.isBefore(now) ||
        status == AppointmentStatus.completed;
  }

  // Helper: Check if today
  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }

  // Helper: Check if tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return appointmentDate.year == tomorrow.year &&
        appointmentDate.month == tomorrow.month &&
        appointmentDate.day == tomorrow.day;
  }

  // Helper: Get relative date text
  String get relativeDateText {
    if (isToday) return 'Aujourd\'hui';
    if (isTomorrow) return 'Demain';
    return formattedDate;
  }

  // Helper: Get status color
  static int getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 0xFFFFA726; // Orange
      case AppointmentStatus.confirmed:
        return 0xFF66BB6A; // Green
      case AppointmentStatus.cancelled:
        return 0xFFEF5350; // Red
      case AppointmentStatus.completed:
        return 0xFF42A5F5; // Blue
    }
  }

  // Helper: Get status text
  static String getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'En attente';
      case AppointmentStatus.confirmed:
        return 'Confirmé';
      case AppointmentStatus.cancelled:
        return 'Annulé';
      case AppointmentStatus.completed:
        return 'Terminé';
    }
  }

  // Helper: Can cancel
  bool get canCancel {
    return (status == AppointmentStatus.pending ||
            status == AppointmentStatus.confirmed) &&
        isUpcoming;
  }

  // Helper: Can reschedule
  bool get canReschedule {
    return (status == AppointmentStatus.pending ||
            status == AppointmentStatus.confirmed) &&
        isUpcoming;
  }

  static AppointmentStatus _statusFromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'completed':
        return AppointmentStatus.completed;
      case 'pending':
      default:
        return AppointmentStatus.pending;
    }
  }

  AppointmentModel copyWith({
    int? id,
    int? patientId,
    int? doctorId,
    DateTime? appointmentDate,
    String? appointmentTime,
    AppointmentStatus? status,
    String? reason,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DoctorModel? doctor,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      doctor: doctor ?? this.doctor,
    );
  }

  @override
  String toString() {
    return 'AppointmentModel(id: $id, doctor: ${doctor?.doctorName}, date: $formattedDate, time: $appointmentTime, status: ${status.toShortString()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppointmentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

extension AppointmentStatusExtension on AppointmentStatus {
  String toShortString() {
    return toString().split('.').last;
  }
}
