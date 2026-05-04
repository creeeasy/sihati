// lib/core/models/patient_profile_model.dart
class PatientProfile {
  final String id;
  final String userId;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final String? address;
  final String? wilaya;
  final String? commune;
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
    this.address,
    this.wilaya,
    this.commune,
    this.emergencyContactName,
    this.emergencyContactPhone,
    required this.createdAt,
    this.updatedAt,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : json['date_of_birth'] != null
              ? DateTime.parse(json['date_of_birth'])
              : null,
      gender: json['gender'],
      bloodType: json['bloodType'] ?? json['blood_type'],
      address: json['address'],
      wilaya: json['wilaya'],
      commune: json['commune'],
      emergencyContactName:
          json['emergencyContactName'] ?? json['emergency_contact_name'],
      emergencyContactPhone:
          json['emergencyContactPhone'] ?? json['emergency_contact_phone'],
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bloodType': bloodType,
      'address': address,
      'wilaya': wilaya,
      'commune': commune,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
