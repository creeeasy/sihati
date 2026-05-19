// lib/core/models/doctor_model.dart
//
// Matches backend: Doctor.ts + /doctors responses (underscored: true)
// Fields: id, userId, specialtyId, doctorName→doctor_name, clinicName→clinic_name,
//   clinicAddress→clinic_address, wilaya, commune, latitude, longitude, phone,
//   whatsappNumber→whatsapp_number, consultationFee→consultation_fee, bio,
//   yearsOfExperience→years_of_experience, averageRating→average_rating,
//   totalReviews→total_reviews, isVerified→is_verified,
//   createdAt→created_at, updatedAt→updated_at
//
// Virtual (computed by backend service): distance
// Included via association: specialty (SpecialtyModel)
import 'specialty_model.dart';

class DoctorModel {
  final String id;
  final String? userId;
  final String? specialtyId;
  final String doctorName;
  final SpecialtyModel? specialty;
  final String clinicName;
  final String clinicAddress;
  final String wilaya;
  final String? commune;
  final double latitude;
  final double longitude;
  final String phone;
  final String? whatsappNumber;
  final double? consultationFee;
  final String? bio;
  final int? yearsOfExperience;
  final double? averageRating;
  final int? totalReviews;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? distance;

  DoctorModel({
    required this.id,
    this.userId,
    this.specialtyId,
    required this.doctorName,
    this.specialty,
    required this.clinicName,
    required this.clinicAddress,
    required this.wilaya,
    this.commune,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.whatsappNumber,
    this.consultationFee,
    this.bio,
    this.yearsOfExperience,
    this.averageRating,
    this.totalReviews,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
    this.distance,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'].toString(),
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      specialtyId:
          json['specialtyId']?.toString() ?? json['specialty_id']?.toString(),
      doctorName: json['doctorName'] ?? json['doctor_name'] ?? '',
      specialty: json['specialty'] != null
          ? SpecialtyModel.fromJson(json['specialty'] as Map<String, dynamic>)
          : null,
      clinicName: json['clinicName'] ?? json['clinic_name'] ?? '',
      clinicAddress: json['clinicAddress'] ?? json['clinic_address'] ?? '',
      wilaya: json['wilaya'] as String? ?? '',
      commune: json['commune'] as String?,
      latitude: _toDouble(json['latitude']) ?? 0.0,
      longitude: _toDouble(json['longitude']) ?? 0.0,
      phone: json['phone'] as String? ?? '',
      whatsappNumber: json['whatsappNumber'] ?? json['whatsapp_number'],
      consultationFee: _toDouble(
          json['consultationFee'] ?? json['consultation_fee']),
      bio: json['bio'] as String?,
      yearsOfExperience:
          json['yearsOfExperience'] ?? json['years_of_experience'],
      averageRating: _toDouble(
          json['averageRating'] ?? json['average_rating']),
      totalReviews: json['totalReviews'] ?? json['total_reviews'],
      isVerified: json['isVerified'] ?? json['is_verified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'] as String)
              : null,
      distance: _toDouble(json['distance']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      if (specialtyId != null) 'specialtyId': specialtyId,
      'doctorName': doctorName,
      if (specialty != null) 'specialty': specialty!.toJson(),
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'wilaya': wilaya,
      if (commune != null) 'commune': commune,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      if (whatsappNumber != null) 'whatsappNumber': whatsappNumber,
      if (consultationFee != null) 'consultationFee': consultationFee,
      if (bio != null) 'bio': bio,
      if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
      if (averageRating != null) 'averageRating': averageRating,
      if (totalReviews != null) 'totalReviews': totalReviews,
      'isVerified': isVerified,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (distance != null) 'distance': distance,
    };
  }

  String get fullClinicAddress {
    if (commune != null && commune!.isNotEmpty) {
      return '$clinicAddress, $commune, $wilaya';
    }
    return '$clinicAddress, $wilaya';
  }

  String get formattedDistance {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toStringAsFixed(0)} m';
    }
    return '${distance!.toStringAsFixed(1)} km';
  }

  String get formattedFee {
    if (consultationFee == null) return 'Non spécifié';
    return '${consultationFee!.toStringAsFixed(0)} DA';
  }

  String get experienceText {
    if (yearsOfExperience == null) return '';
    if (yearsOfExperience == 1) return '1 an d\'expérience';
    return '$yearsOfExperience ans d\'expérience';
  }

  String get ratingText {
    if (averageRating == null || totalReviews == null) return 'Pas d\'avis';
    return '${averageRating!.toStringAsFixed(1)} ($totalReviews avis)';
  }

  bool get hasWhatsapp => whatsappNumber != null && whatsappNumber!.isNotEmpty;
  bool get hasBio => bio != null && bio!.isNotEmpty;
  bool get hasReviews => totalReviews != null && totalReviews! > 0;

  int get ratingStars {
    if (averageRating == null) return 0;
    return averageRating!.round();
  }

  DoctorModel copyWith({
    String? id,
    String? userId,
    String? specialtyId,
    String? doctorName,
    SpecialtyModel? specialty,
    String? clinicName,
    String? clinicAddress,
    String? wilaya,
    String? commune,
    double? latitude,
    double? longitude,
    String? phone,
    String? whatsappNumber,
    double? consultationFee,
    String? bio,
    int? yearsOfExperience,
    double? averageRating,
    int? totalReviews,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? distance,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      specialtyId: specialtyId ?? this.specialtyId,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      wilaya: wilaya ?? this.wilaya,
      commune: commune ?? this.commune,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      consultationFee: consultationFee ?? this.consultationFee,
      bio: bio ?? this.bio,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      distance: distance ?? this.distance,
    );
  }

  @override
  String toString() {
    return 'DoctorModel(id: $id, name: $doctorName, specialty: ${specialty?.nameFr}, wilaya: $wilaya)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoctorModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
