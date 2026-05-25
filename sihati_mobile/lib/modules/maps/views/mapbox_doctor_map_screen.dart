import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:sihati_mobile/core/models/doctor_model.dart';
import 'package:sihati_mobile/app/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sihati_mobile/app/constants/app_icons.dart';

class MapboxDoctorMapScreen extends StatefulWidget {
  final List<DoctorModel> doctors;
  final DoctorModel? selectedDoctor;

  const MapboxDoctorMapScreen({
    super.key,
    required this.doctors,
    this.selectedDoctor,
  });

  @override
  State<MapboxDoctorMapScreen> createState() => _MapboxDoctorMapScreenState();
}

class _MapboxDoctorMapScreenState extends State<MapboxDoctorMapScreen> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Médecins sur la carte'),
        elevation: 0,
        actions: [
          IconButton(
            icon: SvgPicture.asset(AppIcons.location, width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn)),
            onPressed: _moveToUserLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("doctorMapWidget"),
            cameraOptions: _getInitialCamera(),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            onMapCreated: _onMapCreated,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildDoctorCounter(),
          ),
        ],
      ),
    );
  }

  CameraOptions _getInitialCamera() {
    if (widget.selectedDoctor != null) {
      return CameraOptions(
        center: Point(
          coordinates: Position(
            widget.selectedDoctor!.longitude,
            widget.selectedDoctor!.latitude,
          ),
        ),
        zoom: 14.0,
      );
    }

    if (widget.doctors.isNotEmpty) {
      return CameraOptions(
        center: Point(
          coordinates: Position(
            widget.doctors.first.longitude,
            widget.doctors.first.latitude,
          ),
        ),
        zoom: 12.0,
      );
    }

    return CameraOptions(
      center: Point(coordinates: Position(3.0588, 36.7538)),
      zoom: 12.0,
    );
  }

  Widget _buildDoctorCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(AppIcons.doctor,
                width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
          ),
          const SizedBox(width: 12),
          Text(
            '${widget.doctors.length} médecins',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    print('✅ Mapbox map created');

    await _addDoctorMarkers();
  }

  Future<void> _addDoctorMarkers() async {
    if (mapboxMap == null) return;

    pointAnnotationManager =
        await mapboxMap!.annotations.createPointAnnotationManager();

    final annotations = <PointAnnotationOptions>[];

    for (final doctor in widget.doctors) {
      final point = Point(
        coordinates: Position(doctor.longitude, doctor.latitude),
      );

      final annotation = PointAnnotationOptions(
        geometry: point,
        iconSize: 1.5,
        iconColor: Colors.blue.value,
      );

      annotations.add(annotation);
    }

    await pointAnnotationManager?.createMulti(annotations);
    print('✅ Added ${annotations.length} doctor markers');

    if (widget.doctors.length > 1) {
      await _fitBoundsToMarkers();
    }
  }

  Future<void> _fitBoundsToMarkers() async {
    if (mapboxMap == null || widget.doctors.isEmpty) return;

    double minLat = widget.doctors.first.latitude;
    double maxLat = widget.doctors.first.latitude;
    double minLng = widget.doctors.first.longitude;
    double maxLng = widget.doctors.first.longitude;

    for (final doctor in widget.doctors) {
      if (doctor.latitude < minLat) minLat = doctor.latitude;
      if (doctor.latitude > maxLat) maxLat = doctor.latitude;
      if (doctor.longitude < minLng) minLng = doctor.longitude;
      if (doctor.longitude > maxLng) maxLng = doctor.longitude;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    double zoom = 10.0;
    if (maxDiff < 0.01) {
      zoom = 14.0;
    } else if (maxDiff < 0.05) {
      zoom = 12.0;
    } else if (maxDiff < 0.1) {
      zoom = 11.0;
    } else if (maxDiff < 0.5) {
      zoom = 9.0;
    } else {
      zoom = 8.0;
    }

    await mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(centerLng, centerLat)),
        zoom: zoom,
      ),
      MapAnimationOptions(duration: 1500),
    );
  }

  void _moveToUserLocation() {
    Get.snackbar(
      'Position',
      'Déplacement vers votre position...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
