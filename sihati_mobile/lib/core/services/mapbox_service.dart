import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxService {
  static String get accessToken => dotenv.env['MAPBOX_TOKEN'] ?? '';

  static final CameraOptions defaultCamera = CameraOptions(
    center: Point(coordinates: Position(3.0588, 36.7538)),
    zoom: 12.0,
  );

  static CameraOptions algeriaCameraOptions = CameraOptions(
    center: Point(coordinates: Position(3.0588, 36.7538)),
    zoom: 5.0,
  );

  static String getDarkStyleUri() {
    return MapboxStyles.DARK;
  }

  static String getLightStyleUri() {
    return MapboxStyles.MAPBOX_STREETS;
  }

  static String getCustomStyleUri() {
    return 'mapbox://styles/mapbox/streets-v12';
  }

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    print(accessToken);
    MapboxOptions.setAccessToken(accessToken);
  }
}
