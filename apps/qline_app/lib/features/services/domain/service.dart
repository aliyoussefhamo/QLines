class QueueService {
  const QueueService({
    required this.id,
    required this.branchId,
    required this.name,
    required this.description,
    required this.requiredDocuments,
    required this.requirements,
    required this.steps,
    required this.notes,
    required this.feeAmount,
    required this.currency,
    required this.estimatedDurationMinutes,
    required this.peopleWaiting,
    required this.estimatedWaitMinutes,
    required this.isAvailable,
  });

  final String id;
  final String branchId;
  final String name;
  final String description;
  final List<String> requiredDocuments;
  final List<String> requirements;
  final List<String> steps;
  final List<String> notes;
  final num? feeAmount;
  final String? currency;
  final int estimatedDurationMinutes;
  final int peopleWaiting;
  final int estimatedWaitMinutes;
  final bool isAvailable;

  factory QueueService.fromJson(Map<String, dynamic> json) {
    final peopleWaiting = json['peopleWaiting'] as int;
    final bookingsAhead = json['bookingsAhead'] as int;
    final activeCounters = json['activeServiceCounters'] as int;
    final averageDuration = json['averageServiceDurationMinutes'] as int;
    final serviceRounds = activeCounters > 0
        ? ((peopleWaiting + bookingsAhead) / activeCounters).ceil()
        : 0;

    return QueueService(
      id: json['id'] as String,
      branchId: json['branchId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      requiredDocuments: List<String>.from(
        json['requiredDocuments'] as List<dynamic>,
      ),
      requirements: List<String>.from(json['requirements'] as List<dynamic>),
      steps: List<String>.from(json['steps'] as List<dynamic>),
      notes: List<String>.from(json['notes'] as List<dynamic>),
      feeAmount: json['feeAmount'] as num?,
      currency: json['currency'] as String?,
      estimatedDurationMinutes: averageDuration,
      peopleWaiting: peopleWaiting + bookingsAhead,
      estimatedWaitMinutes: serviceRounds * averageDuration,
      isAvailable: json['isAvailable'] as bool,
    );
  }
}
