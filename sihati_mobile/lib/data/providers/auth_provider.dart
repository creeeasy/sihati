// lib/data/providers/auth_provider.dart
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../app/constants/api_constants.dart';
import '../../../core/models/auth_response.dart';
import '../../../core/models/user_model.dart';

/// Auth provider — communicates with the Sihati backend
///
/// Available backend routes used (patient-only):
///   POST /auth/register          → create account (role: 'patient')
///   POST /auth/login             → get access + refresh tokens
///   GET  /auth/profile           → get user + patient profile
///   PUT  /auth/profile           → update fullName / phoneNumber
///   PUT  /auth/profile/chifa     → update Chifa card number
///   POST /auth/logout            → revoke refresh token
///
/// NOTE: JWT is attached automatically by ApiService interceptor.
/// No need to pass token or userId manually.
class AuthProvider {
  final ApiService _apiService;

  AuthProvider(this._apiService);

  // ─── Login ──────────────────────────────────────────────────────────

  /// Login with email and password
  /// Backend: POST /auth/login
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.LOGIN,
        data: {'email': email, 'password': password, 'role': 'patient'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final user = UserModel.fromJson(data['user'] ?? data);
        final token = data['accessToken'] ?? data['token'];
        final refreshToken = data['refreshToken'];

        return AuthResponse(
          user: user,
          token: token,
          refreshToken: refreshToken,
        );
      }
      throw Exception('Login failed: ${response.statusCode}');
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? e.message ?? 'Login failed';
      throw Exception(message);
    }
  }

  // ─── Register ───────────────────────────────────────────────────────

  /// Register new patient
  /// Backend: POST /auth/register  (role: 'patient' in body)
  Future<AuthResponse> registerPatient({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? chifaNumber,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.REGISTER,
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'role': 'patient',
          if (chifaNumber != null && chifaNumber.isNotEmpty)
            'chifaNumber': chifaNumber,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final user = UserModel.fromJson(data['user'] ?? data);
        final token = data['accessToken'] ?? data['token'];
        final refreshToken = data['refreshToken'];

        return AuthResponse(
          user: user,
          token: token,
          refreshToken: refreshToken,
        );
      }
      throw Exception('Registration failed: ${response.statusCode}');
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? e.message ?? 'Registration failed';
      throw Exception(message);
    }
  }

  // ─── Profile ────────────────────────────────────────────────────────

  /// Get user profile (JWT attached automatically by interceptor)
  /// Backend: GET /auth/profile
  Future<UserModel> getProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.PROFILE);

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return UserModel.fromJson(data['user'] ?? data);
      }
      throw Exception('Failed to get profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Update user profile (user identified by JWT — no userId in URL)
  /// Backend: PUT /auth/profile
  Future<UserModel> updateProfile({
    String? fullName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConstants.PROFILE,
        data: {
          if (fullName != null) 'fullName': fullName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return UserModel.fromJson(data['user'] ?? data);
      }
      throw Exception('Failed to update profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  /// Update Chifa card number
  /// Backend: PUT /auth/profile/chifa
  Future<UserModel> updateChifaNumber({
    String? chifaNumber,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConstants.UPDATE_CHIFA,
        data: {
          'chifaNumber': chifaNumber,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return UserModel.fromJson(data['user'] ?? data);
      }
      throw Exception('Failed to update Chifa number');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // ─── Logout ─────────────────────────────────────────────────────────

  /// Logout — revoke refresh token on backend
  /// Backend: POST /auth/logout
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.LOGOUT);
    } catch (e) {
      // Silently ignore — local state cleared regardless
    }
  }
}
