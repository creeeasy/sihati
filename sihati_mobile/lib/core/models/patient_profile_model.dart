// lib/core/models/patient_profile_model.dart
//
// Matches backend: PatientProfile.ts (underscored: true)
// Fields: id, userId, dateOfBirth→date_of_birth, gender, bloodType→blood_type,
//   emergencyContactName→emergency_contact_name,
//   emergencyContactPhone→emergency_contact_phone,
//   createdAt→created_at, updatedAt→updated_at
//
// NOTE: address, wilaya, commune live on the User model, not here.
class PatientProfile {
  final String id;
  final String userId;
  final DateTime? dateOfBirth;
  final String? gender; // 'male' | 'female' | 'other'
  final String? bloodType;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PatientProfile({
    required this.id,
    required this.userId,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.emergencyContactName,
    this.emergencyContactPhone,
    required this.createdAt,
    this.updatedAt,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'].toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : json['date_of_birth'] != null
              ? DateTime.tryParse(json['date_of_birth'].toString())
              : null,
      gender: json['gender'] as String?,
      bloodType: json['bloodType'] ?? json['blood_type'],
      emergencyContactName:
          json['emergencyContactName'] ?? json['emergency_contact_name'],
      emergencyContactPhone:
          json['emergencyContactPhone'] ?? json['emergency_contact_phone'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
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
      'userId': userId,
      if (dateOfBirth != null)
        'dateOfBirth': dateOfBirth!.toIso8601String().split('T')[0],
      if (gender != null) 'gender': gender,
      if (bloodType != null) 'bloodType': bloodType,
      if (emergencyContactName != null)
        'emergencyContactName': emergencyContactName,
      if (emergencyContactPhone != null)
        'emergencyContactPhone': emergencyContactPhone,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Computed age from dateOfBirth
  int? get age {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    int age = today.year - dateOfBirth!.year;
    final m = today.month - dateOfBirth!.month;
    if (m < 0 || (m == 0 && today.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  PatientProfile copyWith({
    String? id,
    String? userId,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
    String? emergencyContactName,
    String? emergencyContactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PatientProfile(id: $id, userId: $userId, gender: $gender, bloodType: $bloodType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PatientProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
