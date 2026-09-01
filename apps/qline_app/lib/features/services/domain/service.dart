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
}
