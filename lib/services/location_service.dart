import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:islamic_app/config/app_config.dart';

class LocationService {
  // Default coordinates (Mecca: 21.4225° N, 39.8262° E)
  static const double fallbackLatitude = 21.4225;
  static const double fallbackLongitude = 39.8262;

  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _getFallbackPosition();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _getFallbackPosition();
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return _getFallbackPosition();
    } 

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );
      await _cacheLocation(position.latitude, position.longitude);
      return position;
    } catch (_) {
      return _getFallbackPosition();
    }
  }

  static Future<void> _cacheLocation(double lat, double lon) async {
    try {
      final box = await Hive.openBox(AppConfig.settingsBoxName);
      await box.put('latitude', lat);
      await box.put('longitude', lon);
    } catch (_) {}
  }

  static Future<Position> _getFallbackPosition() async {
    try {
      final box = await Hive.openBox(AppConfig.settingsBoxName);
      final double? lat = box.get('latitude');
      final double? lon = box.get('longitude');
      if (lat != null && lon != null) {
        return Position(
          latitude: lat,
          longitude: lon,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      }
    } catch (_) {}

    return Position(
      latitude: fallbackLatitude,
      longitude: fallbackLongitude,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }
}
