import 'queue_ticket.dart';

abstract interface class ReservationRepository {
  Future<QueueTicket> createReservation({
    required String branchId,
    required String serviceId,
    required int peopleAhead,
    required int estimatedWaitMinutes,
    required int estimatedTravelMinutes,
  });
}
