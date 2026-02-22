import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sihati_mobile/core/models/auth_response.dart';
import 'package:sihati_mobile/core/models/user_model.dart';

class MockAuthProvider {
  List<UserModel> _users = [];
  bool _isLoaded = false;

  // Load users from JSON
  Future<void> _loadUsers() async {
    if (_isLoaded) return;

    try {
      String jsonString =
          await rootBundle.loadString('assets/mock_data/users.json');
      List<dynamic> jsonList = json.decode(jsonString);
      _users = jsonList.map((json) => UserModel.fromJson(json)).toList();
      _isLoaded = true;
    } catch (e) {
      print('Error loading users: $e');
      throw Exception('Failed to load user data');
    }
  }

  /// Login with email and password
  /// Returns AuthResponse with user data and token
  Future<AuthResponse> login(String email, String password) async {
    // Load users if not loaded
    await _loadUsers();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Find user by email
    final user = _users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('Email ou mot de passe incorrect'),
    );

    // Check password (plain text comparison for mock)
    // In real app, this would be hashed
    final userJson = await _getUserPassword(user.email);
    if (userJson['password'] != password) {
      throw Exception('Email ou mot de passe incorrect');
    }

    // Check if account is active
    if (!user.isActive) {
      throw Exception('Compte désactivé');
    }

    // Generate mock token
    final token = _generateMockToken(user);

    // Return auth response
    return AuthResponse(
      user: user,
      token: token,
    );
  }

  /// Register new patient account
  Future<AuthResponse> registerPatient({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    await _loadUsers();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Check if email already exists
    final emailExists = _users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );

    if (emailExists) {
      throw Exception('Cet email est déjà utilisé');
    }

    // Generate new user ID
    final newId = _users.isEmpty
        ? 1
        : _users.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1;

    // Create new user
    final newUser = UserModel(
      id: newId,
      email: email,
      role: 'patient',
      fullName: fullName,
      phoneNumber: phoneNumber,
      isActive: true,
      createdAt: DateTime.now(),
    );

    // Add to list (temporary, not persisted)
    _users.add(newUser);

    // Generate token
    final token = _generateMockToken(newUser);

    // Return auth response
    return AuthResponse(
      user: newUser,
      token: token,
    );
  }

  /// Get user profile by token
  Future<UserModel> getProfile(String token) async {
    await _loadUsers();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Extract user ID from token
    final userId = _extractUserIdFromToken(token);

    if (userId == null) {
      throw Exception('Token invalide');
    }

    // Find user by ID
    final user = _users.firstWhere(
      (u) => u.id == userId,
      orElse: () => throw Exception('Utilisateur non trouvé'),
    );

    return user;
  }

  /// Generate mock JWT token
  /// Format: mock_token_{userId}_{timestamp}
  String _generateMockToken(UserModel user) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'mock_token_${user.id}_$timestamp';
  }

  /// Extract user ID from mock token
  int? _extractUserIdFromToken(String token) {
    try {
      // Token format: mock_token_{userId}_{timestamp}
      final parts = token.split('_');
      if (parts.length >= 3) {
        return int.parse(parts[2]);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get user password from JSON (for login validation)
  Future<Map<String, dynamic>> _getUserPassword(String email) async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/mock_data/users.json');
      List<dynamic> jsonList = json.decode(jsonString);

      final userJson = jsonList.firstWhere(
        (u) => u['email'].toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('User not found'),
      );

      return userJson as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Invalid credentials');
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    required int userId,
    String? fullName,
    String? phoneNumber,
  }) async {
    await _loadUsers();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Find user
    final userIndex = _users.indexWhere((u) => u.id == userId);

    if (userIndex == -1) {
      throw Exception('Utilisateur non trouvé');
    }

    // Update user
    final updatedUser = _users[userIndex].copyWith(
      fullName: fullName ?? _users[userIndex].fullName,
      phoneNumber: phoneNumber ?? _users[userIndex].phoneNumber,
      updatedAt: DateTime.now(),
    );

    _users[userIndex] = updatedUser;

    return updatedUser;
  }
}
