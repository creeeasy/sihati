// lib/core/models/specialty_model.dart
//
// Matches backend: Specialty.ts (underscored: true)
// Fields: id, nameFr→name_fr, nameAr→name_ar, icon, description
class SpecialtyModel {
  final String id;
  final String nameFr;
  final String nameAr;
  final String? icon; // backend field name is 'icon' (not iconUrl)
  final String? description;

  SpecialtyModel({
    required this.id,
    required this.nameFr,
    required this.nameAr,
    this.icon,
    this.description,
  });

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(
      id: json['id'].toString(),
      nameFr: json['nameFr'] ?? json['name_fr'] ?? '',
      nameAr: json['nameAr'] ?? json['name_ar'] ?? '',
      // Backend stores as 'icon' (not iconUrl)
      icon: json['icon'] ?? json['iconUrl'] ?? json['icon_url'],
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameFr': nameFr,
      'nameAr': nameAr,
      if (icon != null) 'icon': icon,
      if (description != null) 'description': description,
    };
  }

  @override
  String toString() {
    return 'SpecialtyModel(id: $id, nameFr: $nameFr, nameAr: $nameAr)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpecialtyModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
