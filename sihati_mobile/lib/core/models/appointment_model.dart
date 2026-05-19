// lib/core/models/appointment_model.dart
//
// Matches backend: Appointment.ts (underscored: true)
// Fields: id, patientId→patient_id, doctorId→doctor_id, officeId→office_id,
//   appointmentDate→appointment_date, appointmentTime→appointment_time,
//   status (ENUM: pending|confirmed|cancelled|completed|no_show),
//   reason, notes, cancelledAt→cancelled_at, cancelledBy→cancelled_by,
//   cancellationReason→cancellation_reason,
//   createdAt→created_at, updatedAt→updated_at
//
// Booking body (POST /appointments) expects: appointmentDate, appointmentTime
import 'doctor_model.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String? officeId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final AppointmentStatus status;
  final String? reason;
  final String? notes;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DoctorModel? doctor;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.officeId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.reason,
    this.notes,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    required this.createdAt,
    this.updatedAt,
    this.doctor,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'].toString(),
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      doctorId: (json['doctorId'] ?? json['doctor_id'] ?? '').toString(),
      officeId:
          json['officeId']?.toString() ?? json['office_id']?.toString(),
      appointmentDate: DateTime.parse(
          (json['appointmentDate'] ?? json['appointment_date']).toString()),
      appointmentTime:
          json['appointmentTime'] ?? json['appointment_time'] ?? '',
      status: _statusFromString(json['status'] as String?),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.tryParse(json['cancelledAt'].toString())
          : json['cancelled_at'] != null
              ? DateTime.tryParse(json['cancelled_at'].toString())
              : null,
      cancelledBy:
          json['cancelledBy']?.toString() ?? json['cancelled_by']?.toString(),
      cancellationReason:
          json['cancellationReason'] ?? json['cancellation_reason'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'] as String)
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
      if (officeId != null) 'officeId': officeId,
      'appointmentDate': appointmentDate.toIso8601String().split('T')[0],
      'appointmentTime': appointmentTime,
      'status': status.toShortString(),
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  String get formattedDate {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${appointmentDate.day} ${months[appointmentDate.month - 1]} ${appointmentDate.year}';
  }

  String get formattedTime => appointmentTime;
  String get formattedDateTime => '$formattedDate à $appointmentTime';

  bool get isUpcoming {
    final now = DateTime.now();
    final timeParts = appointmentTime.split(':');
    final appointmentDateTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      int.tryParse(timeParts[0]) ?? 0,
      int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0,
    );
    return appointmentDateTime.isAfter(now) &&
        (status == AppointmentStatus.pending ||
            status == AppointmentStatus.confirmed);
  }

  bool get isPast {
    final now = DateTime.now();
    final timeParts = appointmentTime.split(':');
    final appointmentDateTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      int.tryParse(timeParts[0]) ?? 0,
      int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0,
    );
    return appointmentDateTime.isBefore(now) ||
        status == AppointmentStatus.completed;
  }

  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return appointmentDate.year == tomorrow.year &&
        appointmentDate.month == tomorrow.month &&
        appointmentDate.day == tomorrow.day;
  }

  String get relativeDateText {
    if (isToday) return 'Aujourd\'hui';
    if (isTomorrow) return 'Demain';
    return formattedDate;
  }

  bool get canCancel {
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
      case 'no_show':
        return AppointmentStatus.noShow;
      case 'pending':
      default:
        return AppointmentStatus.pending;
    }
  }

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? officeId,
    DateTime? appointmentDate,
    String? appointmentTime,
    AppointmentStatus? status,
    String? reason,
    String? notes,
    DateTime? cancelledAt,
    String? cancelledBy,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DoctorModel? doctor,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      officeId: officeId ?? this.officeId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      doctor: doctor ?? this.doctor,
    );
  }

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
      case AppointmentStatus.noShow:
        return 0xFF9E9E9E; // Grey
    }
  }

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
      case AppointmentStatus.noShow:
        return 'Non présenté';
    }
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
  noShow, // backend: 'no_show'
}

extension AppointmentStatusExtension on AppointmentStatus {
  String toShortString() {
    switch (this) {
      case AppointmentStatus.noShow:
        return 'no_show';
      default:
        return toString().split('.').last;
    }
  }
}
