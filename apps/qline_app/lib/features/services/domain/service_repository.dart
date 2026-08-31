import 'service.dart';

abstract interface class ServiceRepository {
  Future<List<QueueService>> getServicesByBranch(String branchId);
}
