import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sihati_mobile/core/models/user_model.dart';
import 'dart:convert';
import '../../app/constants/storage_keys.dart';

/// Storage service for local data persistence
/// Wraps SharedPreferences for easy data storage and retrieval
/// Singleton service initialized at app startup
class StorageService extends GetxService {
  late SharedPreferences _prefs;

  /// Initialize service - MUST be called at app startup
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ==================== AUTH TOKEN ====================

  /// Save authentication token
  Future<void> saveToken(String token) async {
    try {
      await _prefs.setString(StorageKeys.TOKEN, token);
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  /// Get authentication token
  Future<String?> getToken() async {
    try {
      return _prefs.getString(StorageKeys.TOKEN);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  /// Remove authentication token
  Future<void> removeToken() async {
    try {
      await _prefs.remove(StorageKeys.TOKEN);
    } catch (e) {
      print('Error removing token: $e');
    }
  }

  // ==================== USER DATA ====================

  /// Save user data
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await _prefs.setString(StorageKeys.USER_DATA, userJson);
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  /// Get user data
  Future<UserModel?> getUser() async {
    try {
      final userJson = _prefs.getString(StorageKeys.USER_DATA);
      if (userJson == null) return null;

      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Remove user data
  Future<void> removeUser() async {
    try {
      await _prefs.remove(StorageKeys.USER_DATA);
    } catch (e) {
      print('Error removing user: $e');
    }
  }

  // ==================== AUTH STATUS ====================

  /// Check if user is logged in (has valid token)
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // ==================== CLEAR DATA ====================

  /// Clear all authentication data (token + user)
  Future<void> clearAuth() async {
    try {
      await removeToken();
      await removeUser();
    } catch (e) {
      print('Error clearing auth: $e');
    }
  }

  /// Clear all app data
  Future<void> clearAll() async {
    try {
      await _prefs.clear();
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  // ==================== GENERIC METHODS ====================

  /// Save string value
  Future<void> saveString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      print('Error saving string: $e');
    }
  }

  /// Get string value
  Future<String?> getString(String key) async {
    try {
      return _prefs.getString(key);
    } catch (e) {
      print('Error getting string: $e');
      return null;
    }
  }

  /// Save boolean value
  Future<void> saveBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
    } catch (e) {
      print('Error saving bool: $e');
    }
  }

  /// Get boolean value
  Future<bool?> getBool(String key) async {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      print('Error getting bool: $e');
      return null;
    }
  }

  /// Save integer value
  Future<void> saveInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
    } catch (e) {
      print('Error saving int: $e');
    }
  }

  /// Get integer value
  Future<int?> getInt(String key) async {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      print('Error getting int: $e');
      return null;
    }
  }

  /// Save double value
  Future<void> saveDouble(String key, double value) async {
    try {
      await _prefs.setDouble(key, value);
    } catch (e) {
      print('Error saving double: $e');
    }
  }

  /// Get double value
  Future<double?> getDouble(String key) async {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      print('Error getting double: $e');
      return null;
    }
  }

  /// Remove specific key
  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      print('Error removing key: $e');
    }
  }

  /// Check if key exists
  bool hasKey(String key) {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      print('Error checking key: $e');
      return false;
    }
  }
}
