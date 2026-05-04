// lib/core/models/doctor_model.dart
import 'specialty_model.dart';

class DoctorModel {
  final String id; // ✅ Changed from int to String (UUID)
  final String doctorName;
  final SpecialtyModel specialty;
  final String clinicName;
  final String clinicAddress;
  final String wilaya;
  final String? commune;
  final double latitude;
  final double longitude;
  final String phone;
  final String? whatsappNumber;
  final double? consultationFee;
  final Map<String, dynamic>? workingHours;
  final String? profilePhotoUrl;
  final String? bio;
  final int? yearsOfExperience;
  final double? averageRating;
  final int? totalReviews;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? distance;

  DoctorModel({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.clinicName,
    required this.clinicAddress,
    required this.wilaya,
    this.commune,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.whatsappNumber,
    this.consultationFee,
    this.workingHours,
    this.profilePhotoUrl,
    this.bio,
    this.yearsOfExperience,
    this.averageRating,
    this.totalReviews,
    this.createdAt,
    this.updatedAt,
    this.distance,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'].toString(), // ✅ Convert to String
      doctorName: json['doctorName'] ?? json['doctor_name'] ?? '',
      specialty:
          SpecialtyModel.fromJson(json['specialty'] as Map<String, dynamic>),
      clinicName: json['clinicName'] ?? json['clinic_name'] ?? '',
      clinicAddress: json['clinicAddress'] ?? json['clinic_address'] ?? '',
      wilaya: json['wilaya'] as String,
      commune: json['commune'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String,
      whatsappNumber: json['whatsappNumber'] ?? json['whatsapp_number'],
      consultationFee: json['consultationFee'] != null
          ? (json['consultationFee'] as num).toDouble()
          : json['consultation_fee'] != null
              ? (json['consultation_fee'] as num).toDouble()
              : null,
      workingHours: json['workingHours'] ?? json['working_hours'],
      profilePhotoUrl: json['profilePhotoUrl'] ?? json['profile_photo_url'],
      bio: json['bio'] as String?,
      yearsOfExperience:
          json['yearsOfExperience'] ?? json['years_of_experience'],
      averageRating: json['averageRating'] != null
          ? (json['averageRating'] as num).toDouble()
          : json['average_rating'] != null
              ? (json['average_rating'] as num).toDouble()
              : null,
      totalReviews: json['totalReviews'] ?? json['total_reviews'],
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
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorName': doctorName,
      'specialty': specialty.toJson(),
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'wilaya': wilaya,
      'commune': commune,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'whatsappNumber': whatsappNumber,
      'consultationFee': consultationFee,
      'workingHours': workingHours,
      'profilePhotoUrl': profilePhotoUrl,
      'bio': bio,
      'yearsOfExperience': yearsOfExperience,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'distance': distance,
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
    return '${averageRating!.toStringAsFixed(1)} (${totalReviews} avis)';
  }

  bool get hasWhatsapp => whatsappNumber != null && whatsappNumber!.isNotEmpty;
  bool get hasBio => bio != null && bio!.isNotEmpty;
  bool get hasReviews => totalReviews != null && totalReviews! > 0;

  int get ratingStars {
    if (averageRating == null) return 0;
    return averageRating!.round();
  }

  Map<String, String>? getHoursForDay(String day) {
    if (workingHours == null) return null;

    final dayLower = day.toLowerCase();
    if (workingHours!.containsKey(dayLower)) {
      final hours = workingHours![dayLower];
      if (hours is Map) {
        return {
          'morning': hours['morning']?.toString() ?? '',
          'afternoon': hours['afternoon']?.toString() ?? '',
        };
      }
    }
    return null;
  }

  bool isWorkingOnDay(String day) {
    final hours = getHoursForDay(day);
    if (hours == null) return false;
    return (hours['morning'] != null && hours['morning']!.isNotEmpty) ||
        (hours['afternoon'] != null && hours['afternoon']!.isNotEmpty);
  }

  DoctorModel copyWith({
    String? id,
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
    Map<String, dynamic>? workingHours,
    String? profilePhotoUrl,
    String? bio,
    int? yearsOfExperience,
    double? averageRating,
    int? totalReviews,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? distance,
  }) {
    return DoctorModel(
      id: id ?? this.id,
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
      workingHours: workingHours ?? this.workingHours,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      bio: bio ?? this.bio,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      distance: distance ?? this.distance,
    );
  }

  @override
  String toString() {
    return 'DoctorModel(id: $id, name: $doctorName, specialty: ${specialty.nameFr}, wilaya: $wilaya)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoctorModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
