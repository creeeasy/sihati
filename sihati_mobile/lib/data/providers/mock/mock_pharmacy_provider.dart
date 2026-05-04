/*
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:sihati_mobile/core/models/pharmacy_model.dart';

/// Mock pharmacy provider
/// Loads pharmacy data from JSON and simulates API responses
class MockPharmacyProvider {
  List<PharmacyModel> _pharmacies = [];
  bool _isLoaded = false;

  // Load pharmacies from JSON
  Future<void> _loadData() async {
    if (_isLoaded) return;

    try {
      String jsonString =
          await rootBundle.loadString('assets/mock_data/pharmacies.json');
      List<dynamic> jsonList = json.decode(jsonString);
      _pharmacies =
          jsonList.map((json) => PharmacyModel.fromJson(json)).toList();
      _isLoaded = true;
    } catch (e) {
      print('Error loading pharmacies: $e');
      throw Exception('Failed to load pharmacy data');
    }
  }

  /// Get all pharmacies with optional filters
  Future<List<PharmacyModel>> getAllPharmacies({
    String? wilaya,
    bool? isOnDuty,
  }) async {
    await _loadData();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    var result = List<PharmacyModel>.from(_pharmacies);

    // Filter by wilaya
    if (wilaya != null && wilaya.isNotEmpty) {
      result = result
          .where((p) => p.wilaya.toLowerCase() == wilaya.toLowerCase())
          .toList();
    }

    // Filter by duty status
    if (isOnDuty != null) {
      result = result.where((p) => p.isOnDutyTonight == isOnDuty).toList();
    }

    // Sort by name
    result.sort((a, b) => a.pharmacyName.compareTo(b.pharmacyName));

    return result;
  }

  /// Get pharmacy by ID
  Future<PharmacyModel> getPharmacyById(int id) async {
    await _loadData();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      return _pharmacies.firstWhere((p) => p.id == id);
    } catch (e) {
      throw Exception('Pharmacie non trouvée');
    }
  }

  /// Get nearby pharmacies within radius (km)
  Future<List<PharmacyModel>> getNearbyPharmacies(
    double latitude,
    double longitude, {
    double radius = 5,
  }) async {
    await _loadData();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Calculate distance for each pharmacy
    final pharmaciesWithDistance = _pharmacies.map((pharmacy) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        pharmacy.latitude,
        pharmacy.longitude,
      );

      // Add distance to pharmacy using copyWith
      return pharmacy.copyWith(distance: distance);
    }).toList();

    // Filter by radius
    final nearby = pharmaciesWithDistance
        .where((p) => p.distance != null && p.distance! <= radius)
        .toList();

    // Sort by distance (nearest first)
    nearby.sort((a, b) {
      if (a.distance == null && b.distance == null) return 0;
      if (a.distance == null) return 1;
      if (b.distance == null) return -1;
      return a.distance!.compareTo(b.distance!);
    });

    return nearby;
  }

  /// Get pharmacies on duty tonight
  Future<List<PharmacyModel>> getDutyPharmacies({String? wilaya}) async {
    await _loadData();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    var result = _pharmacies.where((p) => p.isOnDutyTonight).toList();

    // Filter by wilaya if provided
    if (wilaya != null && wilaya.isNotEmpty) {
      result = result
          .where((p) => p.wilaya.toLowerCase() == wilaya.toLowerCase())
          .toList();
    }

    // Sort by pharmacy name
    result.sort((a, b) => a.pharmacyName.compareTo(b.pharmacyName));

    return result;
  }

  /// Calculate distance between two points using Haversine formula
  /// Returns distance in kilometers
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    // Convert degrees to radians
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);

    // Haversine formula
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLng / 2) * sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distance = earthRadius * c;

    return distance;
  }

  /// Convert degrees to radians
  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  /// Get pharmacies by wilaya (for filtering)
  Future<List<PharmacyModel>> getPharmaciesByWilaya(String wilaya) async {
    return getAllPharmacies(wilaya: wilaya);
  }

  /// Search pharmacies by name
  Future<List<PharmacyModel>> searchPharmacies(String query) async {
    await _loadData();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (query.isEmpty) {
      return _pharmacies;
    }

    final lowerQuery = query.toLowerCase();
    final results = _pharmacies.where((p) {
      return p.pharmacyName.toLowerCase().contains(lowerQuery) ||
          p.address.toLowerCase().contains(lowerQuery) ||
          p.wilaya.toLowerCase().contains(lowerQuery);
    }).toList();

    return results;
  }
}

 */
