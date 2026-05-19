// lib/core/models/prescription_model.dart
//
// Matches backend: Prescription.ts + PrescriptionMedication.ts (underscored: true)
// Prescription fields: id, consultationId, patientId, doctorId,
//   prescriptionDate, diagnosis, notes, validityDays, isRenewable, fileUrl
// PrescriptionMedication fields: id, prescriptionId, medicationId,
//   medicationName, dosage, frequency, durationDays, quantity, instructions
//
// prescriptionController includes: medications (PrescriptionMedication[]),
//   doctor (Doctor with user: User)
import 'doctor_model.dart';

class Prescription {
  final String id;
  final String? consultationId;
  final String patientId;
  final String doctorId;
  final DateTime prescriptionDate;
  final String? diagnosis;
  final String? notes;
  final int validityDays;
  final bool isRenewable;
  final String? fileUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<PrescriptionMedication> medications;
  final DoctorModel? doctor;

  Prescription({
    required this.id,
    this.consultationId,
    required this.patientId,
    required this.doctorId,
    required this.prescriptionDate,
    this.diagnosis,
    this.notes,
    this.validityDays = 30,
    this.isRenewable = false,
    this.fileUrl,
    required this.createdAt,
    this.updatedAt,
    required this.medications,
    this.doctor,
  });

  DateTime get expiryDate =>
      prescriptionDate.add(Duration(days: validityDays));
  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isValid => !isExpired;

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'].toString(),
      consultationId: json['consultationId']?.toString() ??
          json['consultation_id']?.toString(),
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      doctorId: (json['doctorId'] ?? json['doctor_id'] ?? '').toString(),
      prescriptionDate: DateTime.parse(
          (json['prescriptionDate'] ?? json['prescription_date'] ??
                  json['date'])
              .toString()),
      diagnosis: json['diagnosis'] as String?,
      notes: json['notes'] as String?,
      validityDays: json['validityDays'] ?? json['validity_days'] ?? 30,
      isRenewable: json['isRenewable'] ?? json['is_renewable'] ?? false,
      fileUrl: json['fileUrl'] ?? json['file_url'],
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
      medications: json['medications'] != null
          ? (json['medications'] as List)
              .map((m) => PrescriptionMedication.fromJson(m))
              .toList()
          : [],
      doctor: json['doctor'] != null
          ? DoctorModel.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (consultationId != null) 'consultationId': consultationId,
      'patientId': patientId,
      'doctorId': doctorId,
      'prescriptionDate': prescriptionDate.toIso8601String(),
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (notes != null) 'notes': notes,
      'validityDays': validityDays,
      'isRenewable': isRenewable,
      if (fileUrl != null) 'fileUrl': fileUrl,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'medications': medications.map((m) => m.toJson()).toList(),
    };
  }
}

class PrescriptionMedication {
  final String id;
  final String prescriptionId;
  final String? medicationId;
  final String medicationName;
  final String? dosage;
  final String? frequency;
  final int? durationDays;
  final int? quantity;
  final String? instructions;

  PrescriptionMedication({
    required this.id,
    required this.prescriptionId,
    this.medicationId,
    required this.medicationName,
    this.dosage,
    this.frequency,
    this.durationDays,
    this.quantity,
    this.instructions,
  });

  factory PrescriptionMedication.fromJson(Map<String, dynamic> json) {
    return PrescriptionMedication(
      id: json['id'].toString(),
      prescriptionId: (json['prescriptionId'] ?? json['prescription_id'] ?? '')
          .toString(),
      medicationId:
          json['medicationId']?.toString() ?? json['medication_id']?.toString(),
      medicationName: json['medicationName'] ?? json['medication_name'] ?? '',
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      durationDays: json['durationDays'] ?? json['duration_days'],
      quantity: json['quantity'],
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescriptionId': prescriptionId,
      if (medicationId != null) 'medicationId': medicationId,
      'medicationName': medicationName,
      if (dosage != null) 'dosage': dosage,
      if (frequency != null) 'frequency': frequency,
      if (durationDays != null) 'durationDays': durationDays,
      if (quantity != null) 'quantity': quantity,
      if (instructions != null) 'instructions': instructions,
    };
  }
}
