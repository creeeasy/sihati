import 'package:sihati_mobile/core/models/pharmacy_with_stock.dart';
import 'medication_model.dart';

/// Result of a medication search query
/// Contains the medication and list of pharmacies that have it in stock
class MedicationSearchResult {
  final MedicationModel medication;
  final List<PharmacyWithStock> pharmacies;

  MedicationSearchResult({
    required this.medication,
    required this.pharmacies,
  });

  // Create from JSON
  factory MedicationSearchResult.fromJson(Map<String, dynamic> json) {
    return MedicationSearchResult(
      medication:
          MedicationModel.fromJson(json['medication'] as Map<String, dynamic>),
      pharmacies: (json['pharmacies'] as List<dynamic>)
          .map((p) => PharmacyWithStock.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'medication': medication.toJson(),
      'pharmacies': pharmacies.map((p) => p.toJson()).toList(),
    };
  }

  // Helper: Check if medication is available anywhere
  bool get isAvailable => pharmacies.isNotEmpty;

  // Helper: Get total pharmacy count
  int get pharmacyCount => pharmacies.length;

  // Helper: Get nearest pharmacy (if distance calculated)
  PharmacyWithStock? get nearestPharmacy {
    if (pharmacies.isEmpty) return null;

    // Find pharmacy with minimum distance
    PharmacyWithStock? nearest;
    double? minDistance;

    for (var pharmacy in pharmacies) {
      if (pharmacy.distance != null) {
        if (minDistance == null || pharmacy.distance! < minDistance) {
          minDistance = pharmacy.distance;
          nearest = pharmacy;
        }
      }
    }

    return nearest ?? pharmacies.first;
  }

  @override
  String toString() {
    return 'MedicationSearchResult(medication: ${medication.name}, pharmacyCount: $pharmacyCount)';
  }
}
