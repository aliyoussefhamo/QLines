class QueueService {
  const QueueService({
    required this.id,
    required this.branchId,
    required this.name,
    required this.description,
    required this.estimatedDurationMinutes,
    required this.peopleWaiting,
    required this.estimatedWaitMinutes,
    required this.isAvailable,
  });

  final String id;
  final String branchId;
  final String name;
  final String description;
  final int estimatedDurationMinutes;
  final int peopleWaiting;
  final int estimatedWaitMinutes;
  final bool isAvailable;
}
