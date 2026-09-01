import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/api_my_reservations_repository.dart';
import '../domain/my_reservation.dart';

enum MyReservationsStatus { loading, success, failure }

class MyReservationsViewModel extends ChangeNotifier {
  MyReservationsViewModel(this._repository);

  final ApiMyReservationsRepository _repository;
  MyReservationsStatus status = MyReservationsStatus.loading;
  List<MyReservation> reservations = const [];
  String? errorMessage;
  String? cancellingId;

  Future<void> load() async {
    status = MyReservationsStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      reservations = await _repository.findMine();
      status = MyReservationsStatus.success;
    } on ApiException catch (error) {
      errorMessage = error.message;
      status = MyReservationsStatus.failure;
    } catch (_) {
      errorMessage = 'تعذر تحميل الحجوزات';
      status = MyReservationsStatus.failure;
    }
    notifyListeners();
  }

  Future<void> cancel(MyReservation reservation) async {
    cancellingId = reservation.id;
    errorMessage = null;
    notifyListeners();
    try {
      final updated = await _repository.cancel(reservation.id);
      reservations = reservations
          .map((item) => item.id == updated.id ? updated : item)
          .toList(growable: false);
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'تعذر إلغاء الحجز';
    } finally {
      cancellingId = null;
      notifyListeners();
    }
  }
}
