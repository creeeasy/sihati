import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../app/constants/api_constants.dart';
import '../../../core/models/auth_response.dart';
import '../../../core/models/user_model.dart';

class AuthProvider {
  final ApiService _apiService;

  AuthProvider(this._apiService);

  /// Login with email and password
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.LOGIN,
        data: {
          'email': email,
          'password': password,
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
          pharmacy: null,
          doctor: null,
        );
      }
      throw Exception('Login failed: ${response.statusCode}');
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? e.message ?? 'Login failed';
      throw Exception(message);
    }
  }

  /// Register new patient
  Future<AuthResponse> registerPatient({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String? chifaNumber,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.REGISTER_PATIENT,
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
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
          pharmacy: null,
          doctor: null,
        );
      }
      throw Exception('Registration failed: ${response.statusCode}');
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? e.message ?? 'Registration failed';
      throw Exception(message);
    }
  }

  /// Get user profile
  Future<UserModel> getProfile(String token) async {
    try {
      final response = await _apiService.get(
        ApiConstants.PROFILE,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return UserModel.fromJson(data['user'] ?? data);
      }
      throw Exception('Failed to get profile');
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.PROFILE}/$userId',
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
      throw Exception(e.message);
    }
  }

  /// Update Chifa number
  Future<UserModel> updateChifaNumber({
    required String userId,
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
      throw Exception(e.message);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.LOGOUT);
    } catch (e) {
      // Ignore errors on logout
    }
  }
}
