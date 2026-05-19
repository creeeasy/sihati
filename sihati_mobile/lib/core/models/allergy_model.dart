// lib/core/models/allergy_model.dart

enum AllergyType {
  medication,
  food,
  environmental,
  other,
}

enum AllergySeverity {
  mild,
  moderate,
  severe,
}

class Allergy {
  final String id;
  final String patientId;
  final String allergyName;
  final AllergyType allergyType;
  final AllergySeverity severity;
  final String? reaction;
  final DateTime declaredAt;
  final String? declaredBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Allergy({
    required this.id,
    required this.patientId,
    required this.allergyName,
    required this.allergyType,
    required this.severity,
    this.reaction,
    required this.declaredAt,
    this.declaredBy,
    this.createdAt,
    this.updatedAt,
  });

  // ─── Display helpers ─────────────────────────────────────────────

  String get formattedType {
    switch (allergyType) {
      case AllergyType.medication:
        return 'Médicament';
      case AllergyType.food:
        return 'Alimentaire';
      case AllergyType.environmental:
        return 'Environnementale';
      case AllergyType.other:
        return 'Autre';
    }
  }

  String get formattedSeverity {
    switch (severity) {
      case AllergySeverity.mild:
        return 'Légère';
      case AllergySeverity.moderate:
        return 'Modérée';
      case AllergySeverity.severe:
        return 'Sévère';
    }
  }

  // ─── Serialization ───────────────────────────────────────────────

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      id: json['id'].toString(),
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      allergyName: json['allergyName'] ?? json['allergy_name'] ?? '',
      allergyType:
          _allergyTypeFromString(json['allergyType'] ?? json['allergy_type']),
      severity: _severityFromString(json['severity']),
      reaction: json['reaction'] as String?,
      declaredAt: json['declaredAt'] != null
          ? DateTime.parse(json['declaredAt'] as String)
          : json['declared_at'] != null
              ? DateTime.parse(json['declared_at'] as String)
              : DateTime.now(),
      declaredBy:
          json['declaredBy']?.toString() ?? json['declared_by']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'allergyName': allergyName,
      'allergyType': allergyType.name,
      'severity': severity.name,
      'reaction': reaction,
      'declaredAt': declaredAt.toIso8601String(),
      'declaredBy': declaredBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ─── Helpers ─────────────────────────────────────────────────────

  static AllergyType _allergyTypeFromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'medication':
        return AllergyType.medication;
      case 'food':
        return AllergyType.food;
      case 'environmental':
        return AllergyType.environmental;
      case 'other':
      default:
        return AllergyType.other;
    }
  }

  static AllergySeverity _severityFromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'severe':
        return AllergySeverity.severe;
      case 'moderate':
        return AllergySeverity.moderate;
      case 'mild':
      default:
        return AllergySeverity.mild;
    }
  }

  // ─── Equality ────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Allergy && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Allergy(id: $id, name: $allergyName, type: $formattedType, severity: $formattedSeverity)';
  }
}
