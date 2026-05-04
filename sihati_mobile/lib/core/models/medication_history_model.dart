// lib/core/models/medication_history_model.dart
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
  final String? prescribedBy;
  final String? reason;
  final bool isActive;
  final double? adherenceRate;

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
    required this.isActive,
    this.adherenceRate,
  });

  bool get isContinuous => endDate == null;

  int? get daysRemaining {
    if (endDate == null) return null;
    final remaining = endDate!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  double? get progressPercentage {
    if (endDate == null) return null;
    final total = endDate!.difference(startDate).inDays;
    final elapsed = DateTime.now().difference(startDate).inDays;
    return ((elapsed / total) * 100).clamp(0, 100);
  }

  factory MedicationHistory.fromJson(Map<String, dynamic> json) {
    return MedicationHistory(
      id: json['id'].toString(),
      patientId: json['patientId'].toString(),
      prescriptionId: json['prescriptionId']?.toString() ??
          json['prescription_id']?.toString(),
      medicationId:
          json['medicationId']?.toString() ?? json['medication_id']?.toString(),
      medicationName: json['medicationName'] ?? json['medication_name'] ?? '',
      dosage: json['dosage'],
      frequency: json['frequency'],
      startDate: DateTime.parse(json['startDate'] ?? json['start_date']),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : json['end_date'] != null
              ? DateTime.parse(json['end_date'])
              : null,
      prescribedBy: json['prescribedBy'] ?? json['prescribed_by'],
      reason: json['reason'],
      isActive: json['isActive'] ?? json['is_active'] ?? false,
      adherenceRate: json['adherenceRate']?.toDouble() ??
          json['adherence_rate']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'prescriptionId': prescriptionId,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'prescribedBy': prescribedBy,
      'reason': reason,
      'isActive': isActive,
      'adherenceRate': adherenceRate,
    };
  }
}
