import 'geo_point.dart';
import 'location_service.dart';

class FakeLocationService implements LocationService {
  const FakeLocationService();

  @override
  Future<GeoPoint> getCurrentLocation() async {
    // Temporary demo position near central Damascus.
    return const GeoPoint(latitude: 33.5138, longitude: 36.2765);
  }
}
