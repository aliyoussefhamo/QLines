import '../../../core/network/api_client.dart';
import '../domain/queue_ticket.dart';
import '../domain/reservation_repository.dart';

class ApiReservationRepository implements ReservationRepository {
  const ApiReservationRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<QueueTicket> createReservation({
    required String branchId,
    required String serviceId,
    required int peopleAhead,
    required int estimatedWaitMinutes,
    required int estimatedTravelMinutes,
  }) async {
    final response = await _apiClient.post(
      '/reservations',
      body: {
        // Temporary until authentication supplies the signed-in user id.
        'userId': 'demo-user',
        'branchId': branchId,
        'serviceId': serviceId,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid reservation response');
    }

    final createdAt = DateTime.parse(response['createdAt'] as String);
    final estimatedTurnAt = DateTime.parse(
      response['estimatedTurnAt'] as String,
    );
    final serverWaitMinutes =
        (estimatedTurnAt.difference(createdAt).inSeconds / 60).ceil();

    return QueueTicket(
      id: response['id'] as String,
      number: 'A-${response['ticketNumber']}',
      branchId: response['branchId'] as String,
      serviceId: response['serviceId'] as String,
      peopleAhead: peopleAhead,
      estimatedWaitMinutes: serverWaitMinutes,
      estimatedTravelMinutes: estimatedTravelMinutes,
      createdAt: createdAt,
      status: _parseStatus(response['status'] as String),
      qrToken: response['qrToken'] as String,
    );
  }

  TicketStatus _parseStatus(String status) {
    return switch (status) {
      'waiting' => TicketStatus.reserved,
      'called' => TicketStatus.called,
      'completed' => TicketStatus.completed,
      'cancelled' => TicketStatus.cancelled,
      _ => throw FormatException('Unknown reservation status: $status'),
    };
  }
}
