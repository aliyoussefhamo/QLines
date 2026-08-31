import '../domain/queue_ticket.dart';
import '../domain/reservation_repository.dart';

class FakeReservationRepository implements ReservationRepository {
  @override
  Future<QueueTicket> createReservation({
    required String branchId,
    required String serviceId,
    required int peopleAhead,
    required int estimatedWaitMinutes,
    required int estimatedTravelMinutes,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    return QueueTicket(
      id: 'ticket-${DateTime.now().millisecondsSinceEpoch}',
      number: 'A-104',
      branchId: branchId,
      serviceId: serviceId,
      peopleAhead: peopleAhead,
      estimatedWaitMinutes: estimatedWaitMinutes,
      estimatedTravelMinutes: estimatedTravelMinutes,
      createdAt: DateTime.now(),
      status: TicketStatus.reserved,
    );
  }
}
