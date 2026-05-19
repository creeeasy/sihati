// lib/core/models/auth_response.dart
//
// Patient-only app: pharmacy and doctor fields removed.
// Backend login/register returns: { user, accessToken, refreshToken }
// NOTE: backend uses 'accessToken' key (NOT 'token')
import 'user_model.dart';

/// Response model for authentication endpoints (login, register)
/// Patient-only: no pharmacy or doctor fields.
class AuthResponse {
  final UserModel user;
  final String token; // maps from backend 'accessToken'
  final String? refreshToken;

  AuthResponse({
    required this.user,
    required this.token,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      // Backend sends 'accessToken', fallback to 'token' for safety
      token: json['accessToken'] as String? ?? json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': token,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }

  bool get isPatient => user.isPatient;
  bool get isPharmacy => user.isPharmacy;
  bool get isDoctor => user.isDoctor;
  bool get isAdmin => user.isAdmin;

  @override
  String toString() {
    return 'AuthResponse(user: ${user.email}, role: ${user.role}, hasToken: ${token.isNotEmpty})';
  }
}
