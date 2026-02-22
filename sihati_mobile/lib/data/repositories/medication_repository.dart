import 'package:sihati_mobile/core/models/medication_model.dart';
import 'package:sihati_mobile/core/models/medication_search_result.dart';
import '../../core/services/location_service.dart';
import '../providers/mock/mock_medication_provider.dart';

/// Medication repository
/// Handles medication search operations
/// Coordinates between MedicationProvider and LocationService
class MedicationRepository {
  final MockMedicationProvider _medicationProvider;
  final LocationService _locationService;

  MedicationRepository({
    required MockMedicationProvider medicationProvider,
    required LocationService locationService,
  })  : _medicationProvider = medicationProvider,
        _locationService = locationService;

  /// Search for medication by name
  /// Optionally uses current location to sort results by distance
  Future<List<MedicationSearchResult>> searchMedication(
    String searchTerm, {
    bool useLocation = true,
  }) async {
    try {
      // Validate search term
      if (searchTerm.isEmpty) {
        throw Exception('Veuillez entrer un nom de médicament');
      }

      if (searchTerm.length < 2) {
        throw Exception('Veuillez entrer au moins 2 caractères');
      }

      double? latitude;
      double? longitude;

      // Get location if requested
      if (useLocation) {
        try {
          final position = await _locationService.getCurrentLocation();
          if (position != null) {
            latitude = position.latitude;
            longitude = position.longitude;
          }
        } catch (e) {
          // Location failed, continue without it
          print('Failed to get location: $e');
        }
      }

      // Search medications
      final results = await _medicationProvider.searchMedication(
        searchTerm,
        latitude: latitude,
        longitude: longitude,
      );

      return results;
    } catch (e) {
      rethrow;
    }
  }

  /// Search medication with specific location (for search by address)
  Future<List<MedicationSearchResult>> searchMedicationAt(
    String searchTerm, {
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Validate search term
      if (searchTerm.isEmpty || searchTerm.length < 2) {
        throw Exception('Veuillez entrer au moins 2 caractères');
      }

      return await _medicationProvider.searchMedication(
        searchTerm,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get medication details by ID
  Future<MedicationModel> getMedicationById(int id) async {
    try {
      return await _medicationProvider.getMedicationById(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all medications (for browsing)
  Future<List<MedicationModel>> getAllMedications() async {
    try {
      return await _medicationProvider.getAllMedications();
    } catch (e) {
      rethrow;
    }
  }

  /// Search medications by category
  Future<List<MedicationModel>> searchByCategory(String category) async {
    try {
      if (category.isEmpty) {
        throw Exception('Catégorie requise');
      }

      return await _medicationProvider.searchByCategory(category);
    } catch (e) {
      rethrow;
    }
  }

  /// Get popular medications
  Future<List<MedicationModel>> getPopularMedications() async {
    try {
      return await _medicationProvider.getPopularMedications();
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

  /// Validate search term
  bool isValidSearchTerm(String term) {
    return term.isNotEmpty && term.length >= 2;
  }

  /// Get search suggestions (could be enhanced with autocomplete later)
  List<String> getSearchSuggestions(String query) {
    // For now, return empty list
    // In future, could return popular searches or autocomplete suggestions
    return [];
  }
  // Add this method to your MedicationRepository class

  /// Sort medication search results by distance from current location
  Future<List<MedicationSearchResult>> sortResultsByDistance(
    List<MedicationSearchResult> results,
  ) async {
    try {
      // Get current location
      final position = await _locationService.getCurrentLocation();

      if (position == null) {
        // Can't sort without location, return original list
        return results;
      }

      // For each result, sort its pharmacies by distance
      final sortedResults = <MedicationSearchResult>[];

      for (var result in results) {
        // Sort pharmacies within this result by distance
        final sortedPharmacies = List<PharmacyWithStock>.from(result.pharmacies)
          ..sort((a, b) {
            // If distance is null, put at the end
            if (a.distance == null && b.distance == null) return 0;
            if (a.distance == null) return 1;
            if (b.distance == null) return -1;
            return a.distance!.compareTo(b.distance!);
          });

        // Create new result with sorted pharmacies
        sortedResults.add(
          MedicationSearchResult(
            medication: result.medication,
            pharmacies: sortedPharmacies,
          ),
        );
      }

      // Sort results by nearest pharmacy distance
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

        // If no distances available, keep original order
        if (aNearestDistance == null && bNearestDistance == null) return 0;
        if (aNearestDistance == null) return 1;
        if (bNearestDistance == null) return -1;
        return aNearestDistance.compareTo(bNearestDistance);
      });

      return sortedResults;
    } catch (e) {
      print('Error sorting results by distance: $e');
      return results; // Return original list if sorting fails
    }
  }
}
