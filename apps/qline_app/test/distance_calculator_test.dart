import 'package:flutter_test/flutter_test.dart';
import 'package:qline_app/core/location/distance_calculator.dart';
import 'package:qline_app/core/location/geo_point.dart';

void main() {
  test('returns zero for the same point', () {
    const point = GeoPoint(latitude: 33.5138, longitude: 36.2765);
    const calculator = HaversineDistanceCalculator();
    expect(calculator.distanceInKilometers(point, point), closeTo(0, 0.001));
  });

  test('calculates a known approximate distance', () {
    const damascus = GeoPoint(latitude: 33.5138, longitude: 36.2765);
    const beirut = GeoPoint(latitude: 33.8938, longitude: 35.5018);
    const calculator = HaversineDistanceCalculator();
    expect(calculator.distanceInKilometers(damascus, beirut), closeTo(82.8, 2));
  });
}
