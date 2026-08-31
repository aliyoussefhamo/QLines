enum TicketStatus { reserved, checkedIn, called, serving, completed, cancelled }

class QueueTicket {
  const QueueTicket({
    required this.id,
    required this.number,
    required this.branchId,
    required this.serviceId,
    required this.peopleAhead,
    required this.estimatedWaitMinutes,
    required this.estimatedTravelMinutes,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String number;
  final String branchId;
  final String serviceId;
  final int peopleAhead;
  final int estimatedWaitMinutes;
  final int estimatedTravelMinutes;
  int get estimatedTotalMinutes =>
      estimatedWaitMinutes + estimatedTravelMinutes;
  final DateTime createdAt;
  final TicketStatus status;
}
