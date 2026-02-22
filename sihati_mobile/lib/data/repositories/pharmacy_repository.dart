import 'package:get/get.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import '../../core/services/location_service.dart';
import '../providers/mock/mock_pharmacy_provider.dart';

/// Pharmacy repository
/// Handles pharmacy data operations and location-based queries
/// Coordinates between PharmacyProvider and LocationService
class PharmacyRepository {
  final MockPharmacyProvider _pharmacyProvider;
  final LocationService _locationService;

  PharmacyRepository({
    required MockPharmacyProvider pharmacyProvider,
    required LocationService locationService,
  })  : _pharmacyProvider = pharmacyProvider,
        _locationService = locationService;

  /// Get all pharmacies with optional wilaya filter
  Future<List<PharmacyModel>> getAllPharmacies({String? wilaya}) async {
    try {
      return await _pharmacyProvider.getAllPharmacies(wilaya: wilaya);
    } catch (e) {
      rethrow;
    }
  }

  /// Get nearby pharmacies using current location
  /// Throws exception if location permission is denied
  Future<List<PharmacyModel>> getNearbyPharmacies({
    double radius = 5,
  }) async {
    try {
      // Get current location
      final position = await _locationService.getCurrentLocation();

      if (position == null) {
        throw Exception(
          'Permission de localisation requise.\n'
          'Veuillez activer la localisation dans les paramètres.',
        );
      }

      // Get pharmacies within radius
      final pharmacies = await _pharmacyProvider.getNearbyPharmacies(
        position.latitude,
        position.longitude,
        radius: radius,
      );

      return pharmacies;
    } catch (e) {
      rethrow;
    }
  }

  /// Get nearby pharmacies with custom location (for search by address)
  Future<List<PharmacyModel>> getNearbyPharmaciesAt({
    required double latitude,
    required double longitude,
    double radius = 5,
  }) async {
    try {
      return await _pharmacyProvider.getNearbyPharmacies(
        latitude,
        longitude,
        radius: radius,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get pharmacy details by ID
  Future<PharmacyModel> getPharmacyDetails(int id) async {
    try {
      return await _pharmacyProvider.getPharmacyById(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Get pharmacies on duty tonight
  Future<List<PharmacyModel>> getDutyPharmacies({String? wilaya}) async {
    try {
      return await _pharmacyProvider.getDutyPharmacies(wilaya: wilaya);
    } catch (e) {
      rethrow;
    }
  }

  /// Get pharmacies by wilaya
  Future<List<PharmacyModel>> getPharmaciesByWilaya(String wilaya) async {
    try {
      if (wilaya.isEmpty) {
        throw Exception('Wilaya requise');
      }
      return await _pharmacyProvider.getPharmaciesByWilaya(wilaya);
    } catch (e) {
      rethrow;
    }
  }

  /// Search pharmacies by name or address
  Future<List<PharmacyModel>> searchPharmacies(String query) async {
    try {
      if (query.isEmpty) {
        // Return all if query is empty
        return await _pharmacyProvider.getAllPharmacies();
      }

      if (query.length < 2) {
        throw Exception('Veuillez entrer au moins 2 caractères');
      }

      return await _pharmacyProvider.searchPharmacies(query);
    } catch (e) {
      rethrow;
    }
  }

  /// Check if location services are available
  Future<bool> isLocationAvailable() async {
    try {
      return await _locationService.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      return await _locationService.requestPermission();
    } catch (e) {
      return false;
    }
  }

  /// Get distance from current location to pharmacy
  Future<double?> getDistanceToPharmacy(PharmacyModel pharmacy) async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) return null;

      return _locationService.calculateDistance(
        position.latitude,
        position.longitude,
        pharmacy.latitude,
        pharmacy.longitude,
      );
    } catch (e) {
      return null;
    }
  }

  /// Sort pharmacies by distance from current location
  Future<List<PharmacyModel>> sortByDistance(
    List<PharmacyModel> pharmacies,
  ) async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        // Can't sort without location, return as is
        return pharmacies;
      }

      // Calculate distance for each pharmacy
      final pharmaciesWithDistance = pharmacies.map((pharmacy) {
        final distance = _locationService.calculateDistance(
          position.latitude,
          position.longitude,
          pharmacy.latitude,
          pharmacy.longitude,
        );
        return pharmacy.copyWith(distance: distance);
      }).toList();

      // Sort by distance
      pharmaciesWithDistance.sort((a, b) {
        if (a.distance == null && b.distance == null) return 0;
        if (a.distance == null) return 1;
        if (b.distance == null) return -1;
        return a.distance!.compareTo(b.distance!);
      });

      return pharmaciesWithDistance;
    } catch (e) {
      // Error getting location, return unsorted
      return pharmacies;
    }
  }
}
