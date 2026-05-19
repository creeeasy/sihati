// lib/core/models/medication_history_model.dart
//
// Matches backend: MedicationHistory.ts (underscored: true)
// This model has a dedicated table: medication_histories
// Fields: id, patientId→patient_id, prescriptionId→prescription_id,
//   medicationId→medication_id, medicationName→medication_name,
//   dosage, frequency, startDate→start_date, endDate→end_date,
//   prescribedBy→prescribed_by (UUID → doctors.id), reason,
//   createdAt→created_at, updatedAt→updated_at
//
// NOTE: isActive and adherenceRate do NOT exist in the backend model.
// Use isContinuous (endDate == null) and daysRemaining getters instead.
class MedicationHistory {
  final String id;
  final String patientId;
  final String? prescriptionId;
  final String? medicationId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? prescribedBy; // doctor UUID
  final String? reason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MedicationHistory({
    required this.id,
    required this.patientId,
    this.prescriptionId,
    this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.prescribedBy,
    this.reason,
    required this.createdAt,
    this.updatedAt,
  });

  /// True if no end date (ongoing/continuous medication)
  bool get isContinuous => endDate == null;

  /// Days remaining until end date (null if no end date)
  int? get daysRemaining {
    if (endDate == null) return null;
    final remaining = endDate!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Progress percentage (0–100), null if no end date
  double? get progressPercentage {
    if (endDate == null) return null;
    final total = endDate!.difference(startDate).inDays;
    if (total <= 0) return 100.0;
    final elapsed = DateTime.now().difference(startDate).inDays;
    return ((elapsed / total) * 100).clamp(0.0, 100.0);
  }

  factory MedicationHistory.fromJson(Map<String, dynamic> json) {
    return MedicationHistory(
      id: json['id'].toString(),
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      prescriptionId: json['prescriptionId']?.toString() ??
          json['prescription_id']?.toString(),
      medicationId:
          json['medicationId']?.toString() ?? json['medication_id']?.toString(),
      medicationName: json['medicationName'] ?? json['medication_name'] ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      startDate: DateTime.parse(
          (json['startDate'] ?? json['start_date']).toString()),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : json['end_date'] != null
              ? DateTime.tryParse(json['end_date'].toString())
              : null,
      prescribedBy:
          json['prescribedBy']?.toString() ?? json['prescribed_by']?.toString(),
      reason: json['reason'] as String?,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      if (prescriptionId != null) 'prescriptionId': prescriptionId,
      if (medicationId != null) 'medicationId': medicationId,
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'endDate': endDate!.toIso8601String().split('T')[0],
      if (prescribedBy != null) 'prescribedBy': prescribedBy,
      if (reason != null) 'reason': reason,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicationHistory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MedicationHistory(id: $id, medication: $medicationName, dosage: $dosage)';
}
