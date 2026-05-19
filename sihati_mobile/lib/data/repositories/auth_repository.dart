// lib/data/repositories/auth_repository.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/auth_response.dart';
import '../../core/models/user_model.dart';
import '../providers/auth_provider.dart';

/// Authentication repository
/// Handles login, register, logout and token management.
///
/// NOTE on provider signatures:
///   - getProfile()             → no args (JWT from interceptor)
///   - updateProfile(...)       → no userId param (JWT identifies user)
///   - updateChifaNumber(...)   → no userId param (JWT identifies user)
class AuthRepository {
  final AuthProvider _authProvider;
  final StorageService _storageService;

  AuthRepository({
    required AuthProvider authProvider,
    required StorageService storageService,
  })  : _authProvider = authProvider,
        _storageService = storageService;

  // Observable states
  final isGuestMode = false.obs;
  final isAuthenticated = false.obs;

  /// Login with email and password
  Future<AuthResponse> login(String email, String password) async {
    try {
      if (email.isEmpty) throw Exception('Email requis');
      if (password.isEmpty) throw Exception('Mot de passe requis');

      final response = await _authProvider.login(email, password);

      // Save tokens and user
      await _storageService.saveToken(response.token);
      if (response.refreshToken != null) {
        await _storageService.saveRefreshToken(response.refreshToken!);
      }
      await _storageService.saveUser(response.user);

      isAuthenticated.value = true;
      isGuestMode.value = false;
      await _storageService.saveGuestModeStatus(false);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Login as guest
  Future<void> loginAsGuest() async {
    try {
      await _storageService.clearAuth();
      await _storageService.saveGuestModeStatus(true);
      isGuestMode.value = true;
      isAuthenticated.value = false;
    } catch (e) {
      throw Exception('Impossible d\'entrer en mode invité');
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
      // Validations
      if (email.isEmpty) throw Exception('Email requis');
      if (!_isValidEmail(email)) throw Exception('Format d\'email invalide');
      if (password.isEmpty) throw Exception('Mot de passe requis');
      if (password.length < 8) {
        throw Exception('Mot de passe doit contenir au moins 8 caractères');
      }
      if (fullName.isEmpty) throw Exception('Nom complet requis');
      if (fullName.length < 3)
        throw Exception('Nom doit contenir au moins 3 caractères');
      if (phoneNumber.isEmpty) throw Exception('Numéro de téléphone requis');
      if (!_isValidAlgerianPhone(phoneNumber)) {
        throw Exception('Numéro de téléphone invalide (format: 05XXXXXXXX)');
      }

      final response = await _authProvider.registerPatient(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        chifaNumber: chifaNumber,
      );

      // Save tokens and user
      await _storageService.saveToken(response.token);
      if (response.refreshToken != null) {
        await _storageService.saveRefreshToken(response.refreshToken!);
      }
      await _storageService.saveUser(response.user);

      isAuthenticated.value = true;
      isGuestMode.value = false;
      await _storageService.saveGuestModeStatus(false);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authProvider.logout();
    } finally {
      await _storageService.clearAuth();
      await _storageService.remove('guest_mode');
      isAuthenticated.value = false;
      isGuestMode.value = false;
    }
  }

  /// Check authentication status on app start
  Future<void> checkAuthStatus() async {
    try {
      final token = await _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        isAuthenticated.value = true;
        isGuestMode.value = false;
        return;
      }

      final isGuest = await _storageService.getGuestModeStatus();
      if (isGuest) {
        isGuestMode.value = true;
        isAuthenticated.value = false;
        return;
      }

      isAuthenticated.value = false;
      isGuestMode.value = false;
    } catch (e) {
      print('Auth check error: $e');
      isAuthenticated.value = false;
      isGuestMode.value = false;
    }
  }

  /// Get current user from storage
  Future<UserModel?> getCurrentUser() async {
    try {
      return await _storageService.getUser();
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _storageService.isLoggedIn();
  }

  /// Check if user is in guest mode
  Future<bool> isGuest() async {
    return await _storageService.getGuestModeStatus();
  }

  /// Get current auth token from storage
  Future<String?> getToken() async {
    return await _storageService.getToken();
  }

  /// Verify token and get user profile from backend
  /// NOTE: getProfile() takes NO token parameter — JWT handled by interceptor.
  Future<UserModel?> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      // getProfile() uses JWT from interceptor — no token arg
      final user = await _authProvider.getProfile();
      await _storageService.saveUser(user);
      return user;
    } catch (e) {
      await logout();
      return null;
    }
  }

  /// Update user profile (fullName, phoneNumber)
  /// NOTE: updateProfile() takes NO userId param — backend uses JWT.
  Future<UserModel> updateProfile({
    String? fullName,
    String? phoneNumber,
  }) async {
    try {
      if (fullName != null && fullName.length < 3) {
        throw Exception('Nom doit contenir au moins 3 caractères');
      }
      if (phoneNumber != null && !_isValidAlgerianPhone(phoneNumber)) {
        throw Exception('Numéro de téléphone invalide');
      }

      // No userId param — provider uses JWT interceptor
      final updatedUser = await _authProvider.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      await _storageService.saveUser(updatedUser);
      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  /// Update user's Chifa number
  /// NOTE: updateChifaNumber() takes NO userId param — backend uses JWT.
  Future<UserModel> updateChifaNumber(String? chifaNumber) async {
    try {
      if (chifaNumber != null && chifaNumber.isNotEmpty) {
        if (chifaNumber.length < 13 || chifaNumber.length > 15) {
          throw Exception(
              'Le numéro Carte Chifa doit contenir entre 13 et 15 chiffres');
        }
        if (!RegExp(r'^\d+$').hasMatch(chifaNumber)) {
          throw Exception(
              'Le numéro Carte Chifa ne doit contenir que des chiffres');
        }
      }

      // No userId param — provider uses JWT interceptor
      final updatedUser = await _authProvider.updateChifaNumber(
        chifaNumber: chifaNumber,
      );

      await _storageService.saveUser(updatedUser);
      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  /// Prompt login for restricted actions
  void promptLoginForFeature(String featureName) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            const Text('Connexion requise',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
            'Pour $featureName, vous devez créer un compte ou vous connecter.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Continuer en invité',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Se connecter',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidAlgerianPhone(String phone) {
    final phoneRegex = RegExp(r'^0[5-7][0-9]{8}$');
    return phoneRegex.hasMatch(phone);
  }
}
