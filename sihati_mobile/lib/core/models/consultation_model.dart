// lib/core/models/consultation_model.dart
import 'doctor_model.dart';

class Consultation {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime date;
  final String? chiefComplaint;
  final String? diagnosis;
  final String? treatmentPlan;
  final String? notes;
  final int? durationMinutes;
  final DoctorModel? doctor;

  Consultation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.date,
    this.chiefComplaint,
    this.diagnosis,
    this.treatmentPlan,
    this.notes,
    this.durationMinutes,
    this.doctor,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'].toString(),
      patientId: json['patientId'].toString(),
      doctorId: json['doctorId'].toString(),
      date: DateTime.parse(json['date'] ?? json['consultation_date']),
      chiefComplaint: json['chiefComplaint'] ?? json['chief_complaint'],
      diagnosis: json['diagnosis'],
      treatmentPlan: json['treatmentPlan'] ?? json['treatment_plan'],
      notes: json['notes'],
      durationMinutes: json['durationMinutes'] ?? json['duration_minutes'],
      doctor:
          json['doctor'] != null ? DoctorModel.fromJson(json['doctor']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'date': date.toIso8601String(),
      'chiefComplaint': chiefComplaint,
      'diagnosis': diagnosis,
      'treatmentPlan': treatmentPlan,
      'notes': notes,
      'durationMinutes': durationMinutes,
    };
  }

  String get formattedDate {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }
}
