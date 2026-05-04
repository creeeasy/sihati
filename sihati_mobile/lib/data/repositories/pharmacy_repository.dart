// lib/data/repositories/pharmacy_repository.dart
import '../providers/pharmacy_provider.dart';
import '../../core/services/location_service.dart';
import '../../core/models/pharmacy_model.dart';

/// Pharmacy repository
/// Handles pharmacy data operations and location-based queries
/// Coordinates between PharmacyProvider and LocationService
class PharmacyRepository {
  final PharmacyProvider _pharmacyProvider;
  final LocationService _locationService;

  PharmacyRepository({
    required PharmacyProvider pharmacyProvider,
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
  Future<List<PharmacyModel>> getNearbyPharmacies({
    double radius = 5,
    String? wilaya,
  }) async {
    try {
      final position = await _locationService.getCurrentLocation();

      if (position == null) {
        throw Exception(
          'Permission de localisation requise.\n'
          'Veuillez activer la localisation dans les paramètres.',
        );
      }

      return await _pharmacyProvider.getNearbyPharmacies(
        position.latitude,
        position.longitude,
        radius: radius,
        wilaya: wilaya,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get nearby pharmacies with custom location
  Future<List<PharmacyModel>> getNearbyPharmaciesAt({
    required double latitude,
    required double longitude,
    double radius = 5,
    String? wilaya,
  }) async {
    try {
      return await _pharmacyProvider.getNearbyPharmacies(
        latitude,
        longitude,
        radius: radius,
        wilaya: wilaya,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get pharmacy details by ID
  Future<PharmacyModel> getPharmacyDetails(String id) async {
    try {
      return await _pharmacyProvider.getPharmacyById(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Get pharmacies on duty tonight
  Future<List<PharmacyModel>> getDutyPharmacies({
    String? wilaya,
    bool useLocation = true,
    double radius = 10,
  }) async {
    try {
      double? latitude;
      double? longitude;

      if (useLocation) {
        try {
          final position = await _locationService.getCurrentLocation();
          if (position != null) {
            latitude = position.latitude;
            longitude = position.longitude;
          }
        } catch (e) {
          print('Failed to get location: $e');
        }
      }

      return await _pharmacyProvider.getDutyPharmacies(
        wilaya: wilaya,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
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
      if (position == null) return pharmacies;

      final pharmaciesWithDistance = pharmacies.map((pharmacy) {
        final distance = _locationService.calculateDistance(
          position.latitude,
          position.longitude,
          pharmacy.latitude,
          pharmacy.longitude,
        );
        return pharmacy.copyWith(distance: distance);
      }).toList();

      pharmaciesWithDistance.sort((a, b) {
        if (a.distance == null && b.distance == null) return 0;
        if (a.distance == null) return 1;
        if (b.distance == null) return -1;
        return a.distance!.compareTo(b.distance!);
      });

      return pharmaciesWithDistance;
    } catch (e) {
      return pharmacies;
    }
  }
}
