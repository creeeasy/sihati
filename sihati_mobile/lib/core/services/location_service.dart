import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math';

/// Location service for GPS and distance calculations
/// Handles location permissions and geocoding
/// Singleton service initialized at app startup
class LocationService extends GetxService {
  /// Initialize service
  Future<LocationService> init() async {
    return this;
  }

  // ==================== LOCATION ====================

  /// Get current location
  /// Returns null if permission denied or location unavailable
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      // Check permission
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        // Try to request permission
        final granted = await requestPermission();
        if (!granted) {
          print('Location permission denied');
          return null;
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // ==================== PERMISSIONS ====================

  /// Check if location permission is granted
  Future<bool> checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }

  /// Request location permission
  /// Returns true if granted, false otherwise
  Future<bool> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        print('Location permission denied');
        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permission denied forever');
        // Show dialog to user to open settings
        return false;
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      print('Error requesting permission: $e');
      return false;
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('Error checking location service: $e');
      return false;
    }
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      print('Error opening location settings: $e');
    }
  }

  // ==================== DISTANCE CALCULATION ====================

  /// Calculate distance between two points using Haversine formula
  /// Returns distance in kilometers
  double calculateDistance(
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

  /// Format distance for display
  /// Returns "X.X km" or "XXX m" depending on distance
  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      final meters = (distanceInKm * 1000).round();
      return '$meters m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  // ==================== GEOCODING ====================

  /// Get address from coordinates (reverse geocoding)
  /// Returns formatted address string or null if failed
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;

      // Build address string
      final parts = <String>[];

      if (place.street != null && place.street!.isNotEmpty) {
        parts.add(place.street!);
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        parts.add(place.locality!);
      }
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        parts.add(place.administrativeArea!);
      }
      if (place.country != null && place.country!.isNotEmpty) {
        parts.add(place.country!);
      }

      return parts.join(', ');
    } catch (e) {
      print('Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Get coordinates from address (geocoding)
  /// Returns Position or null if failed
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);

      if (locations.isEmpty) return null;

      final location = locations.first;

      return Position(
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    } catch (e) {
      print('Error getting coordinates from address: $e');
      return null;
    }
  }

  // ==================== UTILITY ====================

  /// Get distance from current location to target
  Future<double?> getDistanceToTarget(
      double targetLat, double targetLng) async {
    try {
      final position = await getCurrentLocation();
      if (position == null) return null;

      return calculateDistance(
        position.latitude,
        position.longitude,
        targetLat,
        targetLng,
      );
    } catch (e) {
      print('Error getting distance to target: $e');
      return null;
    }
  }

  /// Check if target is within radius (in km)
  Future<bool> isWithinRadius(
    double targetLat,
    double targetLng,
    double radius,
  ) async {
    try {
      final distance = await getDistanceToTarget(targetLat, targetLng);
      if (distance == null) return false;

      return distance <= radius;
    } catch (e) {
      print('Error checking radius: $e');
      return false;
    }
  }
}
