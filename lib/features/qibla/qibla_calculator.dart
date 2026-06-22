import 'dart:math';

class QiblaCalculator {
  // Kaaba Coordinates
  static const double meccaLatitude = 21.422487;
  static const double meccaLongitude = 39.826206;

  /// Calculates the bearing direction in degrees from current position to Kaaba.
  static double calculateQiblaDirection(double latitude, double longitude) {
    // Convert to Radians
    double latRad = latitude * pi / 180.0;
    double lonRad = longitude * pi / 180.0;
    double meccaLatRad = meccaLatitude * pi / 180.0;
    double meccaLonRad = meccaLongitude * pi / 180.0;

    double deltaLon = meccaLonRad - lonRad;

    double y = sin(deltaLon);
    double x = cos(latRad) * tan(meccaLatRad) - sin(latRad) * cos(deltaLon);

    double qiblaAngle = atan2(y, x);

    // Convert back to degrees
    double qiblaDegrees = qiblaAngle * 180.0 / pi;

    // Normalise angle to 0 - 360 range
    return (qiblaDegrees + 360.0) % 360.0;
  }
}
