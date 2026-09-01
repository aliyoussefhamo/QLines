import 'queue_ticket.dart';

class MyReservation {
  const MyReservation({
    required this.id,
    required this.branchId,
    required this.serviceId,
    required this.ticketNumber,
    required this.status,
    required this.createdAt,
    required this.estimatedTurnAt,
    required this.qrToken,
  });

  final String id;
  final String branchId;
  final String serviceId;
  final int ticketNumber;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime estimatedTurnAt;
  final String qrToken;

  bool get canCancel => status == TicketStatus.reserved;
}
