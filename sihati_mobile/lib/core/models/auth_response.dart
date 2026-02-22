import 'user_model.dart';
import 'pharmacy_model.dart';
import 'doctor_model.dart';

/// Response model for authentication endpoints (login, register)
/// Contains user data, auth token, and role-specific data
class AuthResponse {
  final UserModel user;
  final String token;
  final PharmacyModel? pharmacy; // Only if user is pharmacy
  final DoctorModel? doctor; // Only if user is doctor

  AuthResponse({
    required this.user,
    required this.token,
    this.pharmacy,
    this.doctor,
  });

  // Create from JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      pharmacy: json['pharmacy'] != null
          ? PharmacyModel.fromJson(json['pharmacy'] as Map<String, dynamic>)
          : null,
      doctor: json['doctor'] != null
          ? DoctorModel.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'pharmacy': pharmacy?.toJson(),
      'doctor': doctor?.toJson(),
    };
  }

  // Helper: Check user type
  bool get isPatient => user.isPatient;
  bool get isPharmacy => user.isPharmacy;
  bool get isDoctor => user.isDoctor;
  bool get isAdmin => user.isAdmin;

  // Helper: Get display name
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
