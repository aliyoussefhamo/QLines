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

  factory Branch.fromJson(
    Map<String, dynamic> json, {
    required String organizationName,
  }) {
    final peopleWaiting = json['peopleWaiting'] as int;
    final bookingsAhead = json['bookingsAhead'] as int;
    final activeCounters = json['activeServiceCounters'] as int;
    final averageDuration = json['averageServiceDurationMinutes'] as int;
    final peopleAhead = peopleWaiting + bookingsAhead;
    final serviceRounds = activeCounters > 0
        ? (peopleAhead / activeCounters).ceil()
        : 0;

    return Branch(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      name: json['name'] as String,
      organizationName: organizationName,
      address: json['address'] as String,
      peopleWaiting: peopleWaiting,
      estimatedWaitMinutes: serviceRounds * averageDuration,
      isOpen: json['isActive'] as bool,
      location: GeoPoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      ),
    );
  }
}
