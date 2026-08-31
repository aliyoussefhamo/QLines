import 'package:flutter/foundation.dart';

import '../domain/organization.dart';
import '../domain/organization_repository.dart';

enum OrganizationsStatus { initial, loading, success, failure }

class OrganizationsViewModel extends ChangeNotifier {
  OrganizationsViewModel(this._repository);

  final OrganizationRepository _repository;
  OrganizationsStatus status = OrganizationsStatus.initial;
  List<Organization> organizations = const [];
  String? errorMessage;

  Future<void> loadOrganizations() async {
    status = OrganizationsStatus.loading;
    notifyListeners();
    try {
      organizations = await _repository.getOrganizations();
      status = OrganizationsStatus.success;
    } catch (_) {
      status = OrganizationsStatus.failure;
      errorMessage = 'تعذر تحميل المؤسسات. حاول مرة أخرى.';
    }
    notifyListeners();
  }
}
