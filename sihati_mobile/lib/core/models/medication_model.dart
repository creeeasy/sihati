// lib/core/models/medication_model.dart

class MedicationModel {
  final String id;
  final String name;
  final String? genericName;
  final String? dci;
  final String? form;
  final String? dosage;
  final String? category;
  final String? manufacturer;
  final String? description;
  final String? indications;
  final String? contraindications;
  final String? sideEffects;
  final String? posology;
  final bool requiresPrescription;
  final String? barcode;
  final DateTime? createdAt;

  MedicationModel({
    required this.id,
    required this.name,
    this.genericName,
    this.dci,
    this.form,
    this.dosage,
    this.category,
    this.manufacturer,
    this.description,
    this.indications,
    this.contraindications,
    this.sideEffects,
    this.posology,
    this.requiresPrescription = false,
    this.barcode,
    this.createdAt,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      genericName: json['genericName'] ?? json['generic_name'],
      dci: json['dci'],
      form: json['form'],
      dosage: json['dosage'],
      category: json['category'],
      manufacturer: json['manufacturer'],
      description: json['description'],
      indications: json['indications'],
      contraindications: json['contraindications'],
      sideEffects: json['sideEffects'] ?? json['side_effects'],
      posology: json['posology'],
      requiresPrescription: json['requiresPrescription'] ??
          json['requires_prescription'] ??
          false,
      barcode: json['barcode'],
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
      'dci': dci,
      'form': form,
      'dosage': dosage,
      'category': category,
      'manufacturer': manufacturer,
      'description': description,
      'indications': indications,
      'contraindications': contraindications,
      'sideEffects': sideEffects,
      'posology': posology,
      'requiresPrescription': requiresPrescription,
      'barcode': barcode,
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
        (genericName?.toLowerCase().contains(lowerQuery) ?? false) ||
        (dci?.toLowerCase().contains(lowerQuery) ?? false);
  }

  MedicationModel copyWith({
    String? id,
    String? name,
    String? genericName,
    String? dci,
    String? form,
    String? dosage,
    String? category,
    String? manufacturer,
    String? description,
    String? indications,
    String? contraindications,
    String? sideEffects,
    String? posology,
    bool? requiresPrescription,
    String? barcode,
    DateTime? createdAt,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      dci: dci ?? this.dci,
      form: form ?? this.form,
      dosage: dosage ?? this.dosage,
      category: category ?? this.category,
      manufacturer: manufacturer ?? this.manufacturer,
      description: description ?? this.description,
      indications: indications ?? this.indications,
      contraindications: contraindications ?? this.contraindications,
      sideEffects: sideEffects ?? this.sideEffects,
      posology: posology ?? this.posology,
      requiresPrescription: requiresPrescription ?? this.requiresPrescription,
      barcode: barcode ?? this.barcode,
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
