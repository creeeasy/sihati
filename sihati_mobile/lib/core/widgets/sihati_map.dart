import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Reusable OpenStreetMap widget
/// Uses flutter_map (FREE - no API key needed)
class SihatiMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String markerTitle;
  final String? markerSubtitle;
  final double zoom;
  final double height;
  final Color? markerColor;
  final bool showZoomControls;
  final List<MapMarker>? extraMarkers; // For showing multiple markers

  const SihatiMap({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.markerTitle,
    this.markerSubtitle,
    this.zoom = 15,
    this.height = 250,
    this.markerColor,
    this.showZoomControls = true,
    this.extraMarkers,
  }) : super(key: key);

  @override
  State<SihatiMap> createState() => _SihatiMapState();
}

class _SihatiMapState extends State<SihatiMap> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(widget.latitude, widget.longitude);
    final markerColor = widget.markerColor ?? AppColors.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: widget.zoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                // OpenStreetMap tile layer (FREE)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sihati.mobile',
                  maxZoom: 19,
                ),

                // Markers layer
                MarkerLayer(
                  markers: [
                    // Main marker
                    Marker(
                      point: center,
                      width: 80,
                      height: 80,
                      child: _buildMarker(
                        color: markerColor,
                        title: widget.markerTitle,
                        isMain: true,
                      ),
                    ),

                    // Extra markers (for multi-marker view)
                    if (widget.extraMarkers != null)
                      ...widget.extraMarkers!.map(
                        (m) => Marker(
                          point: LatLng(m.latitude, m.longitude),
                          width: 70,
                          height: 70,
                          child: _buildMarker(
                            color: m.color ?? AppColors.secondary,
                            title: m.title,
                            isMain: false,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Zoom controls
            if (widget.showZoomControls)
              Positioned(
                right: 8,
                bottom: 8,
                child: Column(
                  children: [
                    _zoomButton(
                      icon: Icons.add,
                      onTap: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    _zoomButton(
                      icon: Icons.remove,
                      onTap: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        );
                      },
                    ),
                  ],
                ),
              ),

            // OpenStreetMap attribution (required by OSM license)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '© OpenStreetMap contributors',
                  style: AppTextStyles.caption.copyWith(fontSize: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarker({
    required Color color,
    required String title,
    required bool isMain,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            title.length > 12 ? '${title.substring(0, 12)}...' : title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMain ? 10 : 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Pin
        Icon(
          Icons.location_on,
          color: color,
          size: isMain ? 32 : 28,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
            ),
          ],
        ),
      ],
    );
  }

  Widget _zoomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

/// Data class for extra markers on the map
class MapMarker {
  final double latitude;
  final double longitude;
  final String title;
  final Color? color;

  const MapMarker({
    required this.latitude,
    required this.longitude,
    required this.title,
    this.color,
  });
}

/// Multi-marker map for showing nearby pharmacies or doctors
class SihatiMultiMap extends StatelessWidget {
  final double centerLatitude;
  final double centerLongitude;
  final List<MapMarker> markers;
  final double zoom;
  final double height;

  const SihatiMultiMap({
    Key? key,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.markers,
    this.zoom = 13,
    this.height = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SihatiMap(
      latitude: centerLatitude,
      longitude: centerLongitude,
      markerTitle: 'Vous',
      markerColor: AppColors.error,
      zoom: zoom,
      height: height,
      extraMarkers: markers,
    );
  }
}
