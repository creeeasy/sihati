/*import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:sihati_mobile/core/models/medication_model.dart';
import 'package:sihati_mobile/core/models/medication_search_result.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';
import 'mock_pharmacy_provider.dart';

/// Mock medication provider
/// Searches medications and returns pharmacies that have them in stock
class MockMedicationProvider {
  List<MedicationModel> _medications = [];
  bool _isLoaded = false;
  final MockPharmacyProvider _pharmacyProvider = MockPharmacyProvider();

  // Load medications from JSON
  Future<void> _loadData() async {
    if (_isLoaded) return;

    try {
      String jsonString =
          await rootBundle.loadString('assets/mock_data/medications.json');
      List<dynamic> jsonList = json.decode(jsonString);
      _medications =
          jsonList.map((json) => MedicationModel.fromJson(json)).toList();
      _isLoaded = true;
    } catch (e) {
      print('Error loading medications: $e');
      throw Exception('Failed to load medication data');
    }
  }

  /// Search medications by name and return results with pharmacies
  Future<List<MedicationSearchResult>> searchMedication(
    String searchTerm, {
    double? latitude,
    double? longitude,
  }) async {
    await _loadData();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    if (searchTerm.isEmpty || searchTerm.length < 2) {
      throw Exception('Veuillez entrer au moins 2 caractères');
    }

    // Search medications by name or generic name
    final lowerQuery = searchTerm.toLowerCase();
    final matchingMedications = _medications.where((med) {
      return med.name.toLowerCase().contains(lowerQuery) ||
          (med.genericName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();

    if (matchingMedications.isEmpty) {
      return [];
    }

    // Get all pharmacies
    final allPharmacies = await _pharmacyProvider.getAllPharmacies();

    // Build search results
    final results = <MedicationSearchResult>[];

    for (var medication in matchingMedications) {
      // Get random pharmacies that have this medication
      final pharmaciesWithStock = _getPharmaciesWithStock(
        medication.id,
        allPharmacies,
        latitude: latitude,
        longitude: longitude,
      );

      if (pharmaciesWithStock.isNotEmpty) {
        results.add(MedicationSearchResult(
          medication: medication,
          pharmacies: pharmaciesWithStock,
        ));
      }
    }

    return results;
  }

  /// Get medication by ID
  Future<MedicationModel> getMedicationById(int id) async {
    await _loadData();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      return _medications.firstWhere((m) => m.id == id);
    } catch (e) {
      throw Exception('Médicament non trouvé');
    }
  }

  /// Get all medications
  Future<List<MedicationModel>> getAllMedications() async {
    await _loadData();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return List.from(_medications);
  }

  /// Get random pharmacies with stock for a medication
  /// Uses medication ID as seed for consistent results
  List<PharmacyWithStock> _getPharmaciesWithStock(
    int medicationId,
    List<PharmacyModel> allPharmacies, {
    double? latitude,
    double? longitude,
  }) {
    // Use medication ID as seed for consistent random selection
    final random = Random(medicationId);

    // Select 3-7 random pharmacies
    final count = 3 + random.nextInt(5); // 3 to 7 pharmacies

    // Shuffle and take
    final shuffled = List<PharmacyModel>.from(allPharmacies)..shuffle(random);
    var selectedPharmacies = shuffled.take(count).toList();

    // If location provided, calculate distances
    if (latitude != null && longitude != null) {
      selectedPharmacies = selectedPharmacies.map((pharmacy) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          pharmacy.latitude,
          pharmacy.longitude,
        );
        return pharmacy.copyWith(distance: distance);
      }).toList();

      // Sort by distance
      selectedPharmacies.sort((a, b) {
        if (a.distance == null && b.distance == null) return 0;
        if (a.distance == null) return 1;
        if (b.distance == null) return -1;
        return a.distance!.compareTo(b.distance!);
      });
    }

    // Convert to PharmacyWithStock
    return selectedPharmacies.map((pharmacy) {
      // Random last update time (within last 24 hours)
      final hoursAgo = random.nextInt(24);
      final lastUpdated = DateTime.now().subtract(Duration(hours: hoursAgo));

      return PharmacyWithStock(
        pharmacy: pharmacy,
        isAvailable: true,
        lastUpdated: lastUpdated,
        distance: pharmacy.distance,
      );
    }).toList();
  }

  /// Calculate distance between two points (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371; // kilometers

    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLng / 2) * sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  /// Search medications by category
  Future<List<MedicationModel>> searchByCategory(String category) async {
    await _loadData();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final results = _medications.where((med) {
      return med.category?.toLowerCase() == category.toLowerCase();
    }).toList();

    return results;
  }

  /// Get popular medications (mock - returns first 10)
  Future<List<MedicationModel>> getPopularMedications() async {
    await _loadData();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    return _medications.take(10).toList();
  }
}
*/
