import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:sihati_mobile/core/models/doctor_model.dart';
import 'package:sihati_mobile/core/models/specialty_model.dart';

/// Mock doctor provider
/// Loads doctor and specialty data from JSON
class MockDoctorProvider {
  List<DoctorModel> _doctors = [];
  List<SpecialtyModel> _specialties = [];
  bool _doctorsLoaded = false;
  bool _specialtiesLoaded = false;

  // Load doctors from JSON
  Future<void> _loadDoctors() async {
    if (_doctorsLoaded) return;

    try {
      String jsonString =
          await rootBundle.loadString('assets/mock_data/doctors.json');
      List<dynamic> jsonList = json.decode(jsonString);
      _doctors = jsonList.map((json) => DoctorModel.fromJson(json)).toList();
      _doctorsLoaded = true;
    } catch (e) {
      print('Error loading doctors: $e');
      throw Exception('Failed to load doctor data');
    }
  }

  // Load specialties from JSON
  Future<void> _loadSpecialties() async {
    if (_specialtiesLoaded) return;

    try {
      String jsonString =
          await rootBundle.loadString('assets/mock_data/specialties.json');
      List<dynamic> jsonList = json.decode(jsonString);
      _specialties =
          jsonList.map((json) => SpecialtyModel.fromJson(json)).toList();
      _specialtiesLoaded = true;
    } catch (e) {
      print('Error loading specialties: $e');
      throw Exception('Failed to load specialty data');
    }
  }

  /// Get all medical specialties
  Future<List<SpecialtyModel>> getSpecialties() async {
    await _loadSpecialties();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    return List.from(_specialties);
  }

  /// Search doctors with filters
  Future<List<DoctorModel>> searchDoctors({
    int? specialtyId,
    String? wilaya,
    double? latitude,
    double? longitude,
    double radius = 10,
  }) async {
    await _loadDoctors();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    var results = List<DoctorModel>.from(_doctors);

    // Filter by specialty
    if (specialtyId != null) {
      results = results.where((d) => d.specialty.id == specialtyId).toList();
    }

    // Filter by wilaya
    if (wilaya != null && wilaya.isNotEmpty) {
      results = results
          .where((d) => d.wilaya.toLowerCase() == wilaya.toLowerCase())
          .toList();
    }

    // Filter by location and radius
    if (latitude != null && longitude != null) {
      // Calculate distance for each doctor
      results = results.map((doctor) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          doctor.latitude,
          doctor.longitude,
        );
        return doctor.copyWith(distance: distance);
      }).toList();

      // Filter by radius
      results = results
          .where((d) => d.distance != null && d.distance! <= radius)
          .toList();

      // Sort by distance (nearest first)
      results.sort((a, b) {
        if (a.distance == null && b.distance == null) return 0;
        if (a.distance == null) return 1;
        if (b.distance == null) return -1;
        return a.distance!.compareTo(b.distance!);
      });
    } else {
      // Sort by rating if no location provided
      results.sort((a, b) {
        final ratingA = a.averageRating ?? 0;
        final ratingB = b.averageRating ?? 0;
        return ratingB.compareTo(ratingA); // Descending order
      });
    }

    return results;
  }

  /// Get doctor by ID
  Future<DoctorModel> getDoctorById(int id) async {
    await _loadDoctors();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      return _doctors.firstWhere((d) => d.id == id);
    } catch (e) {
      throw Exception('Médecin non trouvé');
    }
  }

  /// Get all doctors
  Future<List<DoctorModel>> getAllDoctors() async {
    await _loadDoctors();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Sort by rating
    final sorted = List<DoctorModel>.from(_doctors);
    sorted.sort((a, b) {
      final ratingA = a.averageRating ?? 0;
      final ratingB = b.averageRating ?? 0;
      return ratingB.compareTo(ratingA);
    });

    return sorted;
  }

  /// Get doctors by specialty
  Future<List<DoctorModel>> getDoctorsBySpecialty(int specialtyId) async {
    return searchDoctors(specialtyId: specialtyId);
  }

  /// Get doctors by wilaya
  Future<List<DoctorModel>> getDoctorsByWilaya(String wilaya) async {
    return searchDoctors(wilaya: wilaya);
  }

  /// Get top rated doctors
  Future<List<DoctorModel>> getTopRatedDoctors({int limit = 10}) async {
    await _loadDoctors();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Sort by rating and take top N
    final sorted = List<DoctorModel>.from(_doctors);
    sorted.sort((a, b) {
      final ratingA = a.averageRating ?? 0;
      final ratingB = b.averageRating ?? 0;
      return ratingB.compareTo(ratingA);
    });

    return sorted.take(limit).toList();
  }

  /// Search doctors by name
  Future<List<DoctorModel>> searchByName(String query) async {
    await _loadDoctors();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (query.isEmpty) {
      return _doctors;
    }

    final lowerQuery = query.toLowerCase();
    final results = _doctors.where((d) {
      return d.doctorName.toLowerCase().contains(lowerQuery) ||
          d.specialty.nameFr.toLowerCase().contains(lowerQuery) ||
          d.specialty.nameAr.contains(query);
    }).toList();

    return results;
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

  /// Get specialty by ID
  Future<SpecialtyModel> getSpecialtyById(int id) async {
    await _loadSpecialties();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      return _specialties.firstWhere((s) => s.id == id);
    } catch (e) {
      throw Exception('Spécialité non trouvée');
    }
  }
}
