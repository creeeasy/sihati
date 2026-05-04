// lib/core/models/specialty_model.dart
class SpecialtyModel {
  final String id; // ✅ Changed from int to String (UUID)
  final String nameFr;
  final String nameAr;
  final String? iconUrl;
  final String? description;

  SpecialtyModel({
    required this.id,
    required this.nameFr,
    required this.nameAr,
    this.iconUrl,
    this.description,
  });

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(
      id: json['id'].toString(), // ✅ Convert to String
      nameFr: json['nameFr'] ?? json['name_fr'] ?? '',
      nameAr: json['nameAr'] ?? json['name_ar'] ?? '',
      iconUrl: json['iconUrl'] ?? json['icon_url'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameFr': nameFr,
      'nameAr': nameAr,
      'iconUrl': iconUrl,
      'description': description,
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
