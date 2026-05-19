// lib/data/repositories/favorite_repository.dart
import '../providers/favorite_provider.dart';
import '../../core/models/doctor_model.dart';
import '../../core/models/pharmacy_model.dart';

/// Favorite repository
///
/// Wraps FavoriteProvider with error handling and exposes clean methods to
/// controllers. This repository is the single source of truth for favorites
/// synced with the backend.
///
/// Note: the app also has a local FavoritesService (GetStorage) that was used
/// before the backend was available. Going forward, this repository should be
/// the primary favorites source when the user is authenticated.
class FavoriteRepository {
  final FavoriteProvider _favoriteProvider;

  FavoriteRepository({required FavoriteProvider favoriteProvider})
      : _favoriteProvider = favoriteProvider;

  // ─── Doctor Favorites ─────────────────────────────────────────────────

  /// Get all favorited doctors from the backend
  Future<List<DoctorModel>> getFavoriteDoctors() async {
    try {
      return await _favoriteProvider.getFavoriteDoctors();
    } catch (e) {
      print('FavoriteRepository.getFavoriteDoctors error: $e');
      return [];
    }
  }

  /// Add a doctor to backend favorites
  /// Returns true on success
  Future<bool> addFavoriteDoctor(String doctorId) async {
    try {
      return await _favoriteProvider.addFavoriteDoctor(doctorId);
    } catch (e) {
      rethrow;
    }
  }

  /// Remove a doctor from backend favorites
  /// Returns true on success
  Future<bool> removeFavoriteDoctor(String doctorId) async {
    try {
      return await _favoriteProvider.removeFavoriteDoctor(doctorId);
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle doctor favorite status
  /// Returns the new isFavorite state
  Future<bool> toggleFavoriteDoctor(String doctorId) async {
    try {
      final isFav = await _favoriteProvider.checkDoctorFavorite(doctorId);
      if (isFav) {
        await _favoriteProvider.removeFavoriteDoctor(doctorId);
        return false;
      } else {
        await _favoriteProvider.addFavoriteDoctor(doctorId);
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Check if a doctor is in favorites
  Future<bool> isDoctorFavorite(String doctorId) async {
    try {
      return await _favoriteProvider.checkDoctorFavorite(doctorId);
    } catch (e) {
      return false;
    }
  }

  // ─── Pharmacy Favorites ───────────────────────────────────────────────

  /// Get all favorited pharmacies from the backend
  Future<List<PharmacyModel>> getFavoritePharmacies() async {
    try {
      return await _favoriteProvider.getFavoritePharmacies();
    } catch (e) {
      print('FavoriteRepository.getFavoritePharmacies error: $e');
      return [];
    }
  }

  /// Add a pharmacy to backend favorites
  /// Returns true on success
  Future<bool> addFavoritePharmacy(String pharmacyId) async {
    try {
      return await _favoriteProvider.addFavoritePharmacy(pharmacyId);
    } catch (e) {
      rethrow;
    }
  }

  /// Remove a pharmacy from backend favorites
  /// Returns true on success
  Future<bool> removeFavoritePharmacy(String pharmacyId) async {
    try {
      return await _favoriteProvider.removeFavoritePharmacy(pharmacyId);
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle pharmacy favorite status
  /// Returns the new isFavorite state
  Future<bool> toggleFavoritePharmacy(String pharmacyId) async {
    try {
      final isFav = await _favoriteProvider.checkPharmacyFavorite(pharmacyId);
      if (isFav) {
        await _favoriteProvider.removeFavoritePharmacy(pharmacyId);
        return false;
      } else {
        await _favoriteProvider.addFavoritePharmacy(pharmacyId);
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Check if a pharmacy is in favorites
  Future<bool> isPharmacyFavorite(String pharmacyId) async {
    try {
      return await _favoriteProvider.checkPharmacyFavorite(pharmacyId);
    } catch (e) {
      return false;
    }
  }

  // ─── Stats ────────────────────────────────────────────────────────────

  /// Get counts of favorite doctors and pharmacies
  Future<Map<String, int>> getFavoriteStats() async {
    try {
      return await _favoriteProvider.getFavoriteStats();
    } catch (e) {
      return {'doctors': 0, 'pharmacies': 0};
    }
  }
}
