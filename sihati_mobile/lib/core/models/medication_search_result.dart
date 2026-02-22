import 'medication_model.dart';
import 'pharmacy_model.dart';

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

/// Pharmacy with stock information for a specific medication
class PharmacyWithStock {
  final PharmacyModel pharmacy;
  final bool isAvailable;
  final DateTime? lastUpdated;
  final double? distance;

  PharmacyWithStock({
    required this.pharmacy,
    this.isAvailable = true,
    this.lastUpdated,
    this.distance,
  });

  // Create from JSON
  factory PharmacyWithStock.fromJson(Map<String, dynamic> json) {
    return PharmacyWithStock(
      pharmacy: PharmacyModel.fromJson(json),
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? true,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : json['last_updated'] != null
              ? DateTime.parse(json['last_updated'] as String)
              : null,
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    final json = pharmacy.toJson();
    json['isAvailable'] = isAvailable;
    json['lastUpdated'] = lastUpdated?.toIso8601String();
    json['distance'] = distance;
    return json;
  }

  // Helper: Get stock status text
  String get stockStatus {
    return isAvailable ? 'En stock' : 'Rupture de stock';
  }

  // Helper: Get last updated text
  String get lastUpdatedText {
    if (lastUpdated == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);

    if (difference.inMinutes < 60) {
      return 'Mis à jour il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Mis à jour il y a ${difference.inHours}h';
    } else {
      return 'Mis à jour il y a ${difference.inDays}j';
    }
  }

  // Helper: Get formatted distance
  String get formattedDistance {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toStringAsFixed(0)} m';
    }
    return '${distance!.toStringAsFixed(1)} km';
  }

  @override
  String toString() {
    return 'PharmacyWithStock(pharmacy: ${pharmacy.pharmacyName}, isAvailable: $isAvailable, distance: $formattedDistance)';
  }
}
