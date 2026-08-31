import '../../../core/location/geo_point.dart';

class Branch {
  const Branch({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.organizationName,
    required this.address,
    required this.peopleWaiting,
    required this.estimatedWaitMinutes,
    required this.isOpen,
    required this.location,
  });

  final String id;
  final String organizationId;
  final String name;
  final String organizationName;
  final String address;
  final int peopleWaiting;
  final int estimatedWaitMinutes;
  final bool isOpen;
  final GeoPoint location;
}
