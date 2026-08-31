import 'package:flutter/foundation.dart';

import '../domain/service.dart';
import '../domain/service_repository.dart';

enum ServicesStatus { initial, loading, success, failure }

class ServicesViewModel extends ChangeNotifier {
  ServicesViewModel(this._repository);

  final ServiceRepository _repository;

  ServicesStatus status = ServicesStatus.initial;
  List<QueueService> services = const [];
  String? errorMessage;

  Future<void> loadServices(String branchId) async {
    status = ServicesStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      services = await _repository.getServicesByBranch(branchId);
      status = ServicesStatus.success;
    } catch (_) {
      status = ServicesStatus.failure;
      errorMessage = 'تعذر تحميل الخدمات. حاول مرة أخرى.';
    }

    notifyListeners();
  }
}
