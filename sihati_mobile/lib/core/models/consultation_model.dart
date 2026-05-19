// lib/core/models/consultation_model.dart
//
// Matches backend: Consultation.ts (underscored: true)
// Fields: id, appointmentId→appointment_id, patientId→patient_id,
//   doctorId→doctor_id, consultationDate→consultation_date, chiefComplaint→chief_complaint,
//   symptoms, diagnosis, treatmentPlan→treatment_plan, notes
//
// NOTE: consultationController includes doctor as User (not Doctor) with:
//   { id, fullName, profileImage }
// There is NO durationMinutes field in the backend.
class ConsultationDoctor {
  final String id;
  final String fullName;
  final String? profileImage;

  ConsultationDoctor({
    required this.id,
    required this.fullName,
    this.profileImage,
  });

  factory ConsultationDoctor.fromJson(Map<String, dynamic> json) {
    return ConsultationDoctor(
      id: json['id'].toString(),
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      profileImage: json['profileImage'] ?? json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        if (profileImage != null) 'profileImage': profileImage,
      };
}

class Consultation {
  final String id;
  final String? appointmentId;
  final String patientId;
  final String doctorId;
  final DateTime consultationDate;
  final String? chiefComplaint;
  final String? symptoms;
  final String? diagnosis;
  final String? treatmentPlan;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  // Included via association (as 'doctor' → User):
  final ConsultationDoctor? doctor;

  Consultation({
    required this.id,
    this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.consultationDate,
    this.chiefComplaint,
    this.symptoms,
    this.diagnosis,
    this.treatmentPlan,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.doctor,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'].toString(),
      appointmentId: json['appointmentId']?.toString() ??
          json['appointment_id']?.toString(),
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      doctorId: (json['doctorId'] ?? json['doctor_id'] ?? '').toString(),
      consultationDate: DateTime.parse(
          json['consultationDate'] ?? json['consultation_date']),
      chiefComplaint: json['chiefComplaint'] ?? json['chief_complaint'],
      symptoms: json['symptoms'] as String?,
      diagnosis: json['diagnosis'] as String?,
      treatmentPlan: json['treatmentPlan'] ?? json['treatment_plan'],
      notes: json['notes'] as String?,
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
          ? ConsultationDoctor.fromJson(
              json['doctor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (appointmentId != null) 'appointmentId': appointmentId,
      'patientId': patientId,
      'doctorId': doctorId,
      'consultationDate': consultationDate.toIso8601String(),
      if (chiefComplaint != null) 'chiefComplaint': chiefComplaint,
      if (symptoms != null) 'symptoms': symptoms,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (treatmentPlan != null) 'treatmentPlan': treatmentPlan,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  String get formattedDate {
    return '${consultationDate.day} ${_getMonthName(consultationDate.month)} ${consultationDate.year}';
  }

  String get doctorName => doctor?.fullName ?? 'Dr. Inconnu';

  String _getMonthName(int month) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[month - 1];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Consultation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Consultation(id: $id, patientId: $patientId, date: $formattedDate)';
}
