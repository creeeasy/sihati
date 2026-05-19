// lib/data/repositories/doctor_repository.dart
import '../providers/doctor_provider.dart';
import '../../core/services/location_service.dart';
import '../../core/models/doctor_model.dart';
import '../../core/models/specialty_model.dart';

/// Doctor repository
/// Handles doctor directory operations
class DoctorRepository {
  final DoctorProvider _doctorProvider;
  final LocationService _locationService;

  DoctorRepository({
    required DoctorProvider doctorProvider,
    required LocationService locationService,
  })  : _doctorProvider = doctorProvider,
        _locationService = locationService;

  /// Get all medical specialties
  Future<List<SpecialtyModel>> getSpecialties() async {
    try {
      return await _doctorProvider.getSpecialties();
    } catch (e) {
      rethrow;
    }
  }

  /// Search doctors with filters
  /// ✅ CORRIGÉ: Utilise directement String (UUID)
  Future<List<DoctorModel>> searchDoctors({
    String? specialtyId, // ✅ String? (UUID)
    String? wilaya,
    bool useLocation = false,
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

      // ✅ Passage direct String au provider (sans conversion)
      final doctors = await _doctorProvider.searchDoctors(
        specialtyId: specialtyId, // ✅ String? direct
        wilaya: wilaya,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      return doctors;
    } catch (e) {
      rethrow;
    }
  }

  /// Search doctors near a specific location
  Future<List<DoctorModel>> searchDoctorsAt({
    required double latitude,
    required double longitude,
    String? specialtyId,
    String? wilaya,
    double radius = 10,
  }) async {
    try {
      return await _doctorProvider.searchDoctors(
        specialtyId: specialtyId,
        wilaya: wilaya,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get doctor details by ID
  Future<DoctorModel> getDoctorDetails(String id) async {
    try {
      return await _doctorProvider.getDoctorById(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all doctors (sorted by rating)
  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      return await _doctorProvider.getAllDoctors();
    } catch (e) {
      rethrow;
    }
  }

  /// Get doctors by specialty
  Future<List<DoctorModel>> getDoctorsBySpecialty(String specialtyId) async {
    try {
      return await _doctorProvider.getDoctorsBySpecialty(specialtyId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get doctors by wilaya
  Future<List<DoctorModel>> getDoctorsByWilaya(String wilaya) async {
    try {
      if (wilaya.isEmpty) {
        throw Exception('Wilaya requise');
      }
      return await _doctorProvider.getDoctorsByWilaya(wilaya);
    } catch (e) {
      rethrow;
    }
  }

  /// Get top rated doctors
  Future<List<DoctorModel>> getTopRatedDoctors({int limit = 10}) async {
    try {
      return await _doctorProvider.getTopRatedDoctors(limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  /// Search doctors by name
  Future<List<DoctorModel>> searchByName(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllDoctors();
      }

      if (query.length < 2) {
        throw Exception('Veuillez entrer au moins 2 caractères');
      }

      return await _doctorProvider.searchByName(query);
    } catch (e) {
      rethrow;
    }
  }

  /// Get specialty by ID (filters client-side from the specialties list)
  Future<SpecialtyModel> getSpecialtyById(String id) async {
    try {
      final specialties = await _doctorProvider.getSpecialties();
      return specialties.firstWhere(
        (s) => s.id == id,
        orElse: () => throw Exception('Specialty $id not found'),
      );
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

  /// Get distance from current location to doctor's clinic
  Future<double?> getDistanceToDoctor(DoctorModel doctor) async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) return null;

      return _locationService.calculateDistance(
        position.latitude,
        position.longitude,
        doctor.latitude,
        doctor.longitude,
      );
    } catch (e) {
      return null;
    }
  }

  /// Sort doctors by distance from current location
  Future<List<DoctorModel>> sortByDistance(List<DoctorModel> doctors) async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) return doctors;

      final doctorsWithDistance = doctors.map((doctor) {
        final distance = _locationService.calculateDistance(
          position.latitude,
          position.longitude,
          doctor.latitude,
          doctor.longitude,
        );
        return doctor.copyWith(distance: distance);
      }).toList();

      doctorsWithDistance.sort((a, b) {
        if (a.distance == null && b.distance == null) return 0;
        if (a.distance == null) return 1;
        if (b.distance == null) return -1;
        return a.distance!.compareTo(b.distance!);
      });

      return doctorsWithDistance;
    } catch (e) {
      return doctors;
    }
  }

  /// Sort doctors by rating (highest first)
  List<DoctorModel> sortByRating(List<DoctorModel> doctors) {
    final sorted = List<DoctorModel>.from(doctors);
    sorted.sort((a, b) {
      final ratingA = a.averageRating ?? 0;
      final ratingB = b.averageRating ?? 0;
      return ratingB.compareTo(ratingA);
    });
    return sorted;
  }

  /// Sort doctors by experience (most experienced first)
  List<DoctorModel> sortByExperience(List<DoctorModel> doctors) {
    final sorted = List<DoctorModel>.from(doctors);
    sorted.sort((a, b) {
      final expA = a.yearsOfExperience ?? 0;
      final expB = b.yearsOfExperience ?? 0;
      return expB.compareTo(expA);
    });
    return sorted;
  }

  /// Sort doctors by consultation fee (lowest first)
  List<DoctorModel> sortByFee(List<DoctorModel> doctors) {
    final sorted = List<DoctorModel>.from(doctors);
    sorted.sort((a, b) {
      final feeA = a.consultationFee ?? double.infinity;
      final feeB = b.consultationFee ?? double.infinity;
      return feeA.compareTo(feeB);
    });
    return sorted;
  }
}
