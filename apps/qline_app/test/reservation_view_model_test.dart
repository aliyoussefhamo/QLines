import 'package:flutter_test/flutter_test.dart';
import 'package:qline_app/features/reservations/domain/queue_ticket.dart';
import 'package:qline_app/features/reservations/domain/reservation_repository.dart';
import 'package:qline_app/features/reservations/presentation/reservation_view_model.dart';

void main() {
  test('creates a reservation with the selected branch and service', () async {
    final repository = _SuccessfulRepository();
    final viewModel = ReservationViewModel(repository);

    await viewModel.reserve(
      branchId: 'branch-1',
      serviceId: 'service-2',
      peopleAhead: 3,
      estimatedWaitMinutes: 14,
      estimatedTravelMinutes: 8,
    );

    expect(repository.branchId, 'branch-1');
    expect(repository.serviceId, 'service-2');
    expect(viewModel.status, ReservationStatus.success);
    expect(viewModel.ticket?.number, 'A-1');
  });

  test('exposes failure when reservation creation fails', () async {
    final viewModel = ReservationViewModel(_FailingRepository());

    await viewModel.reserve(
      branchId: 'branch-1',
      serviceId: 'service-2',
      peopleAhead: 3,
      estimatedWaitMinutes: 14,
      estimatedTravelMinutes: 8,
    );

    expect(viewModel.status, ReservationStatus.failure);
    expect(viewModel.ticket, isNull);
    expect(viewModel.errorMessage, isNotEmpty);
  });
}

class _SuccessfulRepository implements ReservationRepository {
  String? branchId;
  String? serviceId;

  @override
  Future<QueueTicket> createReservation({
    required String branchId,
    required String serviceId,
    required int peopleAhead,
    required int estimatedWaitMinutes,
    required int estimatedTravelMinutes,
  }) async {
    this.branchId = branchId;
    this.serviceId = serviceId;
    return QueueTicket(
      id: 'ticket-1',
      number: 'A-1',
      branchId: branchId,
      serviceId: serviceId,
      peopleAhead: peopleAhead,
      estimatedWaitMinutes: estimatedWaitMinutes,
      estimatedTravelMinutes: estimatedTravelMinutes,
      createdAt: DateTime(2026),
      status: TicketStatus.reserved,
    );
  }
}

class _FailingRepository implements ReservationRepository {
  @override
  Future<QueueTicket> createReservation({
    required String branchId,
    required String serviceId,
    required int peopleAhead,
    required int estimatedWaitMinutes,
    required int estimatedTravelMinutes,
  }) {
    throw Exception('network');
  }
}
