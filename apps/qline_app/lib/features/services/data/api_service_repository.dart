import '../../../core/network/api_client.dart';
import '../domain/service.dart';
import '../domain/service_repository.dart';

class ApiServiceRepository implements ServiceRepository {
  const ApiServiceRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<QueueService>> getServicesByBranch(String branchId) async {
    final response = await _apiClient.get('/branches/$branchId/services');

    if (response is! List<dynamic>) {
      throw const FormatException('Invalid branch services response');
    }

    return response
        .map((item) => QueueService.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
