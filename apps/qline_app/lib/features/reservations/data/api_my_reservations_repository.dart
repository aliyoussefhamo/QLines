import '../../../core/network/api_client.dart';
import '../domain/my_reservation.dart';
import '../domain/queue_ticket.dart';

class ApiMyReservationsRepository {
  const ApiMyReservationsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<MyReservation>> findMine() async {
    final response = await _apiClient.get('/reservations');
    if (response is! List) {
      throw const FormatException('Invalid reservations response');
    }
    return response
        .map((item) => _fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<MyReservation> cancel(String reservationId) async {
    final response = await _apiClient.patch(
      '/reservations/$reservationId/cancel',
    );
    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid reservation response');
    }
    return _fromJson(response);
  }

  MyReservation _fromJson(Map<String, dynamic> json) {
    return MyReservation(
      id: json['id'] as String,
      branchId: json['branchId'] as String,
      serviceId: json['serviceId'] as String,
      ticketNumber: json['ticketNumber'] as int,
      status: _status(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      estimatedTurnAt: DateTime.parse(json['estimatedTurnAt'] as String),
      qrToken: json['qrToken'] as String,
    );
  }

  TicketStatus _status(String value) => switch (value) {
    'waiting' => TicketStatus.reserved,
    'called' => TicketStatus.called,
    'completed' => TicketStatus.completed,
    'cancelled' => TicketStatus.cancelled,
    _ => throw FormatException('Unknown reservation status: $value'),
  };
}
