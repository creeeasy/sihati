import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class SihatiMapbox extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? markerTitle;
  final double height;
  final double zoom;
  final bool showMyLocation;
  final VoidCallback? onMapTap;

  const SihatiMapbox({
    super.key,
    required this.latitude,
    required this.longitude,
    this.markerTitle,
    this.height = 200,
    this.zoom = 14.0,
    this.showMyLocation = false,
    this.onMapTap,
  });

  @override
  State<SihatiMapbox> createState() => _SihatiMapboxState();
}

class _SihatiMapboxState extends State<SihatiMapbox> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MapWidget(
          cameraOptions: CameraOptions(
            center: Point(
              coordinates: Position(widget.longitude, widget.latitude),
            ),
            zoom: widget.zoom,
          ),
          styleUri: MapboxStyles.MAPBOX_STREETS,
          onMapCreated: _onMapCreated,
          onTapListener: widget.onMapTap != null
              ? (coordinate) {
                  widget.onMapTap?.call();
                }
              : null,
        ),
      ),
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    await _addMarker();
  }

  Future<void> _addMarker() async {
    if (mapboxMap == null) return;

    pointAnnotationManager =
        await mapboxMap!.annotations.createPointAnnotationManager();

    final point = Point(
      coordinates: Position(widget.longitude, widget.latitude),
    );

    final annotation = PointAnnotationOptions(
      geometry: point,
      iconSize: 1.5,
      iconColor: Colors.red.value,
    );

    await pointAnnotationManager?.create(annotation);
  }
}
