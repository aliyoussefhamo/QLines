import 'dart:math' as math;

import 'geo_point.dart';

abstract interface class DistanceCalculator {
  double distanceInKilometers(GeoPoint from, GeoPoint to);
}

class HaversineDistanceCalculator implements DistanceCalculator {
  const HaversineDistanceCalculator();

  static const _earthRadiusKm = 6371.0;

  @override
  double distanceInKilometers(GeoPoint from, GeoPoint to) {
    final latitudeDelta = _toRadians(to.latitude - from.latitude);
    final longitudeDelta = _toRadians(to.longitude - from.longitude);
    final fromLatitude = _toRadians(from.latitude);
    final toLatitude = _toRadians(to.latitude);

    final haversine =
        math.pow(math.sin(latitudeDelta / 2), 2) +
        math.cos(fromLatitude) *
            math.cos(toLatitude) *
            math.pow(math.sin(longitudeDelta / 2), 2);
    final centralAngle = 2 * math.asin(math.sqrt(haversine));
    return _earthRadiusKm * centralAngle;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
}
