import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:sihati_mobile/core/services/mapbox_service.dart';

class MapboxMapScreen extends StatefulWidget {
  const MapboxMapScreen({super.key});

  @override
  State<MapboxMapScreen> createState() => _MapboxMapScreenState();
}

class _MapboxMapScreenState extends State<MapboxMapScreen> {
  MapboxMap? mapboxMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte Mapbox'),
        elevation: 0,
      ),
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        cameraOptions: MapboxService.defaultCamera,
        styleUri: MapboxService.getLightStyleUri(),
        textureView: true,
        onMapCreated: _onMapCreated,
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    print('✅ Mapbox map created successfully!');
  }
}
