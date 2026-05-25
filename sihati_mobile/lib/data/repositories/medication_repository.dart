import 'package:sihati_mobile/core/models/pharmacy_with_stock.dart';

import '../providers/medication_provider.dart';
import '../../core/services/location_service.dart';
import '../../core/models/medication_model.dart';
import '../../core/models/medication_search_result.dart';

/// Medication repository
/// Handles medication search operations
/// Coordinates between MedicationProvider and LocationService
class MedicationRepository {
  final MedicationProvider _medicationProvider;
  final LocationService _locationService;

  MedicationRepository({
    required MedicationProvider medicationProvider,
    required LocationService locationService,
  })  : _medicationProvider = medicationProvider,
        _locationService = locationService;

  /// Search for medication by name
  /// Optionally uses current location to sort results by distance
  Future<List<MedicationModel>> searchMedication(
    String searchTerm, {
    bool useLocation = true,
    String? wilaya,
    double radius = 10,
  }) async {
    try {
      if (searchTerm.isEmpty) {
        throw Exception('Veuillez entrer un nom de médicament');
      }

      if (searchTerm.length < 2) {
        throw Exception('Veuillez entrer au moins 2 caractères');
      }

      final results = await _medicationProvider.searchMedication(
        searchTerm,
      );

      return results;
    } catch (e) {
      rethrow;
    }
  }

  /// Search medication with specific location
  Future<List<MedicationModel>> searchMedicationAt(
    String searchTerm, {
    required double latitude,
    required double longitude,
    String? wilaya,
    double radius = 10,
  }) async {
    try {
      if (searchTerm.isEmpty || searchTerm.length < 2) {
        throw Exception('Veuillez entrer au moins 2 caractères');
      }

      return await _medicationProvider.searchMedication(
        searchTerm,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get medication details by ID
  Future<MedicationModel> getMedicationById(String id) async {
    try {
      return await _medicationProvider.getMedicationById(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Search medication by barcode
  Future<MedicationModel?> searchByBarcode(String barcode) async {
    try {
      return await _medicationProvider.searchByBarcode(barcode);
    } catch (e) {
      return null;
    }
  }

  /// Get pharmacies that have a specific medication
  Future<List<PharmacyWithStock>> getPharmaciesWithStock(
    String medicationId, {
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

      return await _medicationProvider.getPharmaciesWithStock(
        medicationId,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
    } catch (e) {
      return [];
    }
  }

  /// Get all medications
  Future<List<MedicationModel>> getAllMedications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _medicationProvider.getAllMedications(
          page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  /// Get popular medications
  Future<List<MedicationModel>> getPopularMedications({int limit = 10}) async {
    try {
      return await _medicationProvider.getPopularMedications(limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Check drug interactions
  /// NOTE: The real drug-drug interaction check is handled by AiRepository.checkInteraction().
  /// This method is a stub that always returns safe to keep the app from crashing.
  Future<Map<String, dynamic>> checkInteractions({
    required List<String> currentMedicationIds,
    required String newMedicationId,
  }) async {
    // Use AiRepository.checkInteraction(med1, med2) for the actual check.
    return {'hasInteractions': false, 'interactions': [], 'safeToTake': true};
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

  /// Validate search term
  bool isValidSearchTerm(String term) {
    return term.isNotEmpty && term.length >= 2;
  }

  /// Sort medication search results by distance from current location
  Future<List<MedicationSearchResult>> sortResultsByDistance(
    List<MedicationSearchResult> results,
  ) async {
    try {
      final position = await _locationService.getCurrentLocation();

      if (position == null) {
        return results;
      }

      final sortedResults = <MedicationSearchResult>[];

      for (var result in results) {
        final sortedPharmacies = List<PharmacyWithStock>.from(result.pharmacies)
          ..sort((a, b) {
            if (a.distance == null && b.distance == null) return 0;
            if (a.distance == null) return 1;
            if (b.distance == null) return -1;
            return a.distance!.compareTo(b.distance!);
          });

        sortedResults.add(
          MedicationSearchResult(
            medication: result.medication,
            pharmacies: sortedPharmacies,
          ),
        );
      }

      sortedResults.sort((a, b) {
        final aNearestDistance = a.pharmacies
            .where((p) => p.distance != null)
            .map((p) => p.distance!)
            .fold<double?>(
                null,
                (prev, curr) =>
                    prev == null ? curr : (curr < prev ? curr : prev));

        final bNearestDistance = b.pharmacies
            .where((p) => p.distance != null)
            .map((p) => p.distance!)
            .fold<double?>(
                null,
                (prev, curr) =>
                    prev == null ? curr : (curr < prev ? curr : prev));

        if (aNearestDistance == null && bNearestDistance == null) return 0;
        if (aNearestDistance == null) return 1;
        if (bNearestDistance == null) return -1;
        return aNearestDistance.compareTo(bNearestDistance);
      });

      return sortedResults;
    } catch (e) {
      print('Error sorting results by distance: $e');
      return results;
    }
  }
}
