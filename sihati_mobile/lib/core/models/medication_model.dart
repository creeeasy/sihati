// lib/core/models/medication_model.dart
class MedicationModel {
  final String id; // ✅ Changed from int to String (UUID)
  final String name;
  final String? genericName;
  final String? category;
  final String? description;
  final bool requiresPrescription;
  final DateTime? createdAt;

  MedicationModel({
    required this.id,
    required this.name,
    this.genericName,
    this.category,
    this.description,
    this.requiresPrescription = false,
    this.createdAt,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'].toString(), // ✅ Convert to String
      name: json['name'] as String,
      genericName: json['genericName'] ?? json['generic_name'],
      category: json['category'] as String?,
      description: json['description'] as String?,
      requiresPrescription: json['requiresPrescription'] ??
          json['requires_prescription'] ??
          false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'category': category,
      'description': description,
      'requiresPrescription': requiresPrescription,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  String get displayName {
    if (genericName != null && genericName!.isNotEmpty) {
      return '$name ($genericName)';
    }
    return name;
  }

  String get prescriptionBadge {
    return requiresPrescription ? 'Ordonnance requise' : 'Sans ordonnance';
  }

  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        (genericName?.toLowerCase().contains(lowerQuery) ?? false);
  }

  MedicationModel copyWith({
    String? id,
    String? name,
    String? genericName,
    String? category,
    String? description,
    bool? requiresPrescription,
    DateTime? createdAt,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      category: category ?? this.category,
      description: description ?? this.description,
      requiresPrescription: requiresPrescription ?? this.requiresPrescription,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'MedicationModel(id: $id, name: $name, genericName: $genericName, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
