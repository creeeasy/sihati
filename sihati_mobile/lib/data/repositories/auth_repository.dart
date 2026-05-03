import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/auth_response.dart';
import 'package:sihati_mobile/core/models/user_model.dart';
import '../../core/services/storage_service.dart';
import '../providers/mock/mock_auth_provider.dart';

/// Authentication repository
/// Handles login, register, logout and token management
/// Coordinates between AuthProvider and StorageService
class AuthRepository {
  final MockAuthProvider _authProvider;
  final StorageService _storageService;

  AuthRepository({
    required MockAuthProvider authProvider,
    required StorageService storageService,
  })  : _authProvider = authProvider,
        _storageService = storageService;

  // Observable states
  final isGuestMode = false.obs;
  final isAuthenticated = false.obs;

  /// Login with email and password
  /// Saves token and user to storage on success
  Future<AuthResponse> login(String email, String password) async {
    try {
      // Validate inputs
      if (email.isEmpty) {
        throw Exception('Email requis');
      }
      if (password.isEmpty) {
        throw Exception('Mot de passe requis');
      }

      // Call provider to authenticate
      final response = await _authProvider.login(email, password);

      // Save token and user to storage
      await _storageService.saveToken(response.token);
      await _storageService.saveUser(response.user);

      // Update observable states
      isAuthenticated.value = true;
      isGuestMode.value = false;

      // Clear guest mode if it was active
      await _storageService.saveBool('guest_mode', false);

      return response;
    } catch (e) {
      // Rethrow to be handled by controller
      rethrow;
    }
  }

  /// 🆕 Login as guest
  /// Allows users to explore the app without creating an account
  Future<void> loginAsGuest() async {
    try {
      // Clear any existing auth data
      await _storageService.clearAuth();

      // Save guest mode status
      await _storageService.saveBool('guest_mode', true);

      // Update observable states
      isGuestMode.value = true;
      isAuthenticated.value = false;

      print('Guest mode activated successfully');
    } catch (e) {
      print('Error entering guest mode: $e');
      throw Exception('Impossible d\'entrer en mode invité');
    }
  }

  /// Register new patient account
  /// Validates inputs and saves credentials on success
  Future<AuthResponse> registerPatient(
      {required String email,
      required String password,
      required String fullName,
      required String phoneNumber,
      String? chifaNumber}) async {
    try {
      // Validate inputs
      if (email.isEmpty) {
        throw Exception('Email requis');
      }
      if (!_isValidEmail(email)) {
        throw Exception('Format d\'email invalide');
      }
      if (password.isEmpty) {
        throw Exception('Mot de passe requis');
      }
      if (password.length < 8) {
        throw Exception('Mot de passe doit contenir au moins 8 caractères');
      }
      if (fullName.isEmpty) {
        throw Exception('Nom complet requis');
      }
      if (fullName.length < 3) {
        throw Exception('Nom doit contenir au moins 3 caractères');
      }
      if (phoneNumber.isEmpty) {
        throw Exception('Numéro de téléphone requis');
      }
      if (!_isValidAlgerianPhone(phoneNumber)) {
        throw Exception('Numéro de téléphone invalide (format: 05XXXXXXXX)');
      }

      // Call provider to register
      final response = await _authProvider.registerPatient(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      // Save token and user to storage
      await _storageService.saveToken(response.token);
      await _storageService.saveUser(response.user);

      // Update observable states
      isAuthenticated.value = true;
      isGuestMode.value = false;

      // Clear guest mode if it was active
      await _storageService.saveBool('guest_mode', false);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout user
  /// Clears all authentication data from storage
  Future<void> logout() async {
    try {
      await _storageService.clearAuth();
      await _storageService.remove('guest_mode');

      // Update observable states
      isAuthenticated.value = false;
      isGuestMode.value = false;
    } catch (e) {
      // Even if storage fails, don't throw - user wants to logout
      print('Logout error: $e');
    }
  }

  /// 🆕 Check authentication status on app start
  /// Determines if user is logged in, in guest mode, or needs to login
  Future<void> checkAuthStatus() async {
    try {
      // First check if user has valid token (logged in)
      final token = await _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        isAuthenticated.value = true;
        isGuestMode.value = false;
        return;
      }

      // Then check if in guest mode
      final isGuest = await _storageService.getBool('guest_mode') ?? false;
      if (isGuest) {
        isGuestMode.value = true;
        isAuthenticated.value = false;
        return;
      }

      // Neither authenticated nor guest
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
      print('Get current user error: $e');
      return null;
    }
  }

  /// Check if user is logged in
  /// Returns true if valid token exists in storage
  Future<bool> isLoggedIn() async {
    try {
      return await _storageService.isLoggedIn();
    } catch (e) {
      print('Is logged in error: $e');
      return false;
    }
  }

  /// 🆕 Check if user is in guest mode
  Future<bool> isGuest() async {
    try {
      final isGuest = await _storageService.getBool('guest_mode') ?? false;
      return isGuest;
    } catch (e) {
      print('Is guest error: $e');
      return false;
    }
  }

  /// Get current auth token from storage
  Future<String?> getToken() async {
    try {
      return await _storageService.getToken();
    } catch (e) {
      print('Get token error: $e');
      return null;
    }
  }

  /// Verify token and get user profile
  /// Useful for checking if token is still valid
  Future<UserModel?> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final user = await _authProvider.getProfile(token);

      // Update stored user data
      await _storageService.saveUser(user);

      return user;
    } catch (e) {
      // Token invalid or expired, clear auth data
      await logout();
      return null;
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? fullName,
    String? phoneNumber,
  }) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Validate inputs
      if (fullName != null && fullName.length < 3) {
        throw Exception('Nom doit contenir au moins 3 caractères');
      }
      if (phoneNumber != null && !_isValidAlgerianPhone(phoneNumber)) {
        throw Exception('Numéro de téléphone invalide');
      }

      // Update via provider
      final updatedUser = await _authProvider.updateProfile(
        userId: user.id,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      // Save updated user to storage
      await _storageService.saveUser(updatedUser);

      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  /// 🆕 Prompt login for restricted actions (when in guest mode)
  /// Shows a dialog asking user to login or sign up
  void promptLoginForFeature(String featureName) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            Text(
              'Connexion requise',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Pour $featureName, vous devez créer un compte ou vous connecter.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Continuer en invité',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Se connecter',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate Algerian phone number format (10 digits starting with 0)
  bool _isValidAlgerianPhone(String phone) {
    final phoneRegex = RegExp(r'^0[5-7][0-9]{8}$');
    return phoneRegex.hasMatch(phone);
  }

  /// Update user's Chifa number
  Future<UserModel> updateChifaNumber(String? chifaNumber) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Validate Chifa number if provided
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

      // Update via provider
      final updatedUser = await _authProvider.updateChifaNumber(
        userId: user.id,
        chifaNumber: chifaNumber,
      );

      // Save updated user to storage
      await _storageService.saveUser(updatedUser);

      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }
}
