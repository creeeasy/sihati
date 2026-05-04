// lib/core/models/prescription_model.dart
import 'doctor_model.dart';

class Prescription {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime date;
  final String? diagnosis;
  final String? notes;
  final int validityDays;
  final bool isRenewable;
  final String? fileUrl;
  final List<PrescriptionMedication> medications;
  final DoctorModel? doctor;

  Prescription({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.date,
    this.diagnosis,
    this.notes,
    this.validityDays = 30,
    this.isRenewable = false,
    this.fileUrl,
    required this.medications,
    this.doctor,
  });

  DateTime get expiryDate => date.add(Duration(days: validityDays));
  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isValid => !isExpired;

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'].toString(),
      patientId: json['patientId'].toString(),
      doctorId: json['doctorId'].toString(),
      date: DateTime.parse(json['date'] ?? json['prescription_date']),
      diagnosis: json['diagnosis'],
      notes: json['notes'],
      validityDays: json['validityDays'] ?? json['validity_days'] ?? 30,
      isRenewable: json['isRenewable'] ?? json['is_renewable'] ?? false,
      fileUrl: json['fileUrl'] ?? json['file_url'],
      medications: json['medications'] != null
          ? (json['medications'] as List)
              .map((m) => PrescriptionMedication.fromJson(m))
              .toList()
          : [],
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
      'diagnosis': diagnosis,
      'notes': notes,
      'validityDays': validityDays,
      'isRenewable': isRenewable,
      'fileUrl': fileUrl,
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
      prescriptionId: json['prescriptionId'].toString(),
      medicationId:
          json['medicationId']?.toString() ?? json['medication_id']?.toString(),
      medicationName: json['medicationName'] ?? json['medication_name'] ?? '',
      dosage: json['dosage'],
      frequency: json['frequency'],
      durationDays: json['durationDays'] ?? json['duration_days'],
      quantity: json['quantity'],
      instructions: json['instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescriptionId': prescriptionId,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'durationDays': durationDays,
      'quantity': quantity,
      'instructions': instructions,
    };
  }
}
