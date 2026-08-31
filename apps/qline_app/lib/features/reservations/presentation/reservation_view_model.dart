import 'package:flutter/foundation.dart';

import '../domain/queue_ticket.dart';
import '../domain/reservation_repository.dart';

enum ReservationStatus { initial, submitting, success, failure }

class ReservationViewModel extends ChangeNotifier {
  ReservationViewModel(this._repository);

  final ReservationRepository _repository;

  ReservationStatus status = ReservationStatus.initial;
  QueueTicket? ticket;
  String? errorMessage;

  Future<void> reserve({
    required String branchId,
    required String serviceId,
    required int peopleAhead,
    required int estimatedWaitMinutes,
    required int estimatedTravelMinutes,
  }) async {
    if (status == ReservationStatus.submitting) return;

    status = ReservationStatus.submitting;
    errorMessage = null;
    notifyListeners();

    try {
      ticket = await _repository.createReservation(
        branchId: branchId,
        serviceId: serviceId,
        peopleAhead: peopleAhead,
        estimatedWaitMinutes: estimatedWaitMinutes,
        estimatedTravelMinutes: estimatedTravelMinutes,
      );
      status = ReservationStatus.success;
    } catch (_) {
      status = ReservationStatus.failure;
      errorMessage = 'تعذر إنشاء الحجز. حاول مرة أخرى.';
    }

    notifyListeners();
  }
}
