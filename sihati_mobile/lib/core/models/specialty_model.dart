class SpecialtyModel {
  final int id;
  final String nameAr; // Arabic name
  final String nameFr; // French name
  final DateTime? createdAt;

  SpecialtyModel({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    this.createdAt,
  });

  // Create SpecialtyModel from JSON
  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(
      id: json['id'] as int,
      nameAr: json['nameAr'] ?? json['name_ar'] ?? '',
      nameFr: json['nameFr'] ?? json['name_fr'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
    );
  }

  // Convert SpecialtyModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameFr': nameFr,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Helper: Get name based on language (defaults to French)
  String getName([String language = 'fr']) {
    switch (language.toLowerCase()) {
      case 'ar':
        return nameAr;
      case 'fr':
      default:
        return nameFr;
    }
  }

  // CopyWith method
  SpecialtyModel copyWith({
    int? id,
    String? nameAr,
    String? nameFr,
    DateTime? createdAt,
  }) {
    return SpecialtyModel(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameFr: nameFr ?? this.nameFr,
      createdAt: createdAt ?? this.createdAt,
    );
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
