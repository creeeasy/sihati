// lib/core/services/storage_service.dart
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

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ─── Auth Token ───────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    try {
      await _prefs.setString(StorageKeys.TOKEN, token);
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return _prefs.getString(StorageKeys.TOKEN);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // 🆕 REFRESH TOKEN - Added for real backend
  Future<void> saveRefreshToken(String token) async {
    try {
      await _prefs.setString(StorageKeys.REFRESH_TOKEN, token);
    } catch (e) {
      print('Error saving refresh token: $e');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return _prefs.getString(StorageKeys.REFRESH_TOKEN);
    } catch (e) {
      print('Error getting refresh token: $e');
      return null;
    }
  }

  Future<void> removeToken() async {
    try {
      await _prefs.remove(StorageKeys.TOKEN);
    } catch (e) {
      print('Error removing token: $e');
    }
  }

  // ─── User Data ────────────────────────────────────────────────

  Future<void> saveUser(UserModel user) async {
    try {
      await _prefs.setString(StorageKeys.USER_DATA, json.encode(user.toJson()));
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  Future<UserModel?> getUser() async {
    try {
      final userJson = _prefs.getString(StorageKeys.USER_DATA);
      if (userJson == null) return null;
      return UserModel.fromJson(json.decode(userJson) as Map<String, dynamic>);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> removeUser() async {
    try {
      await _prefs.remove(StorageKeys.USER_DATA);
    } catch (e) {
      print('Error removing user: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // 🆕 UPDATED clearAuth - Now removes refresh token too
  Future<void> clearAuth() async {
    await removeToken();
    await _prefs.remove(StorageKeys.REFRESH_TOKEN);
    await removeUser();
  }

  // ─── Medication History ───────────────────────────────────────

  /// Save a viewed medication to local history (max 50 entries)
  Future<void> addToMedicationHistory(Map<String, dynamic> entry) async {
    try {
      final raw = _prefs.getString(StorageKeys.MEDICATION_HISTORY);
      final List<dynamic> history = raw != null ? json.decode(raw) : [];

      // Remove duplicate if same medication already in history
      history.removeWhere((e) => e['name'] == entry['name']);

      // Add to front
      history.insert(0, entry);

      // Keep only last 50
      final trimmed = history.take(50).toList();

      await _prefs.setString(
          StorageKeys.MEDICATION_HISTORY, json.encode(trimmed));
    } catch (e) {
      print('Error saving medication history: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMedicationHistory() async {
    try {
      final raw = _prefs.getString(StorageKeys.MEDICATION_HISTORY);
      if (raw == null) return [];
      final List<dynamic> list = json.decode(raw);
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting medication history: $e');
      return [];
    }
  }

  Future<void> clearMedicationHistory() async {
    try {
      await _prefs.remove(StorageKeys.MEDICATION_HISTORY);
    } catch (e) {
      print('Error clearing medication history: $e');
    }
  }

  // ─── Favorite Medications ─────────────────────────────────────

  /// Get list of favorite medication names
  Future<List<String>> getFavoriteMedications() async {
    try {
      final raw = _prefs.getString(StorageKeys.FAVORITE_MEDICATIONS);
      if (raw == null) return [];
      final List<dynamic> list = json.decode(raw);
      return list.cast<String>();
    } catch (e) {
      print('Error getting favorite medications: $e');
      return [];
    }
  }

  /// Add medication to favorites
  Future<void> addFavoriteMedication(String medicationName) async {
    try {
      final favorites = await getFavoriteMedications();
      if (!favorites.contains(medicationName)) {
        favorites.add(medicationName);
        await _prefs.setString(
          StorageKeys.FAVORITE_MEDICATIONS,
          json.encode(favorites),
        );
      }
    } catch (e) {
      print('Error adding favorite medication: $e');
      throw Exception('Failed to add favorite medication');
    }
  }

  /// Remove medication from favorites
  Future<void> removeFavoriteMedication(String medicationName) async {
    try {
      final favorites = await getFavoriteMedications();
      favorites.remove(medicationName);
      await _prefs.setString(
        StorageKeys.FAVORITE_MEDICATIONS,
        json.encode(favorites),
      );
    } catch (e) {
      print('Error removing favorite medication: $e');
      throw Exception('Failed to remove favorite medication');
    }
  }

  /// Check if medication is in favorites
  Future<bool> isFavoriteMedication(String medicationName) async {
    try {
      final favorites = await getFavoriteMedications();
      return favorites.contains(medicationName);
    } catch (e) {
      print('Error checking favorite medication: $e');
      return false;
    }
  }

  /// Clear all favorite medications
  Future<void> clearFavoriteMedications() async {
    try {
      await _prefs.remove(StorageKeys.FAVORITE_MEDICATIONS);
    } catch (e) {
      print('Error clearing favorite medications: $e');
    }
  }

  // ─── Generic ──────────────────────────────────────────────────

  Future<void> saveString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      print('Error saving string: $e');
    }
  }

  Future<String?> getString(String key) async {
    try {
      return _prefs.getString(key);
    } catch (e) {
      print('Error getting string: $e');
      return null;
    }
  }

  Future<void> saveBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
    } catch (e) {
      print('Error saving bool: $e');
    }
  }

  // 🆕 FIXED: getBool returns bool? (nullable)
  Future<bool?> getBool(String key) async {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      print('Error getting bool: $e');
      return null;
    }
  }

  // 🆕 Convenience method for guest mode (returns non-nullable with default)
  Future<bool> getGuestModeStatus() async {
    try {
      return _prefs.getBool('guest_mode') ?? false;
    } catch (e) {
      print('Error getting guest mode status: $e');
      return false;
    }
  }

  // 🆕 Save guest mode status
  Future<void> saveGuestModeStatus(bool isGuest) async {
    try {
      await _prefs.setBool('guest_mode', isGuest);
    } catch (e) {
      print('Error saving guest mode status: $e');
    }
  }

  Future<void> saveInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
    } catch (e) {
      print('Error saving int: $e');
    }
  }

  Future<int?> getInt(String key) async {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      print('Error getting int: $e');
      return null;
    }
  }

  Future<void> saveDouble(String key, double value) async {
    try {
      await _prefs.setDouble(key, value);
    } catch (e) {
      print('Error saving double: $e');
    }
  }

  Future<double?> getDouble(String key) async {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      print('Error getting double: $e');
      return null;
    }
  }

  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      print('Error removing key: $e');
    }
  }

  bool hasKey(String key) {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      return false;
    }
  }

  Future<void> clearAll() async {
    try {
      await _prefs.clear();
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }
}
