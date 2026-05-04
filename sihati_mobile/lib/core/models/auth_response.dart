// lib/core/models/auth_response.dart
import 'user_model.dart';
import 'pharmacy_model.dart';
import 'doctor_model.dart';

/// Response model for authentication endpoints (login, register)
/// Contains user data, auth token, and role-specific data
class AuthResponse {
  final UserModel user;
  final String token;
  final String? refreshToken; // 🆕 Added refresh token
  final PharmacyModel? pharmacy;
  final DoctorModel? doctor;

  AuthResponse({
    required this.user,
    required this.token,
    this.refreshToken,
    this.pharmacy,
    this.doctor,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String?,
      pharmacy: json['pharmacy'] != null
          ? PharmacyModel.fromJson(json['pharmacy'] as Map<String, dynamic>)
          : null,
      doctor: json['doctor'] != null
          ? DoctorModel.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (pharmacy != null) 'pharmacy': pharmacy?.toJson(),
      if (doctor != null) 'doctor': doctor?.toJson(),
    };
  }

  bool get isPatient => user.isPatient;
  bool get isPharmacy => user.isPharmacy;
  bool get isDoctor => user.isDoctor;
  bool get isAdmin => user.isAdmin;

  String get displayName {
    if (isPharmacy && pharmacy != null) {
      return pharmacy!.pharmacyName;
    } else if (isDoctor && doctor != null) {
      return doctor!.doctorName;
    }
    return user.fullName;
  }

  @override
  String toString() {
    return 'AuthResponse(user: ${user.email}, role: ${user.role}, hasToken: ${token.isNotEmpty})';
  }
}
