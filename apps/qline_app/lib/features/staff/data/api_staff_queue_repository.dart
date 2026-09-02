import '../../../core/network/api_client.dart';
import '../domain/staff_queue_item.dart';

class ApiStaffQueueRepository {
  const ApiStaffQueueRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<StaffQueueItem>> getQueue() async {
    final response = await _apiClient.get('/staff/queue');
    if (response is! List) {
      throw const FormatException('Invalid queue response');
    }
    return response
        .map((item) => StaffQueueItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<StaffQueueItem> callNext() async {
    final response = await _apiClient.patch('/staff/queue/next');
    return _parse(response);
  }

  Future<StaffQueueItem> updateStatus(String id, String status) async {
    final response = await _apiClient.patch(
      '/staff/queue/$id/status',
      body: {'status': status},
    );
    return _parse(response);
  }

  Future<StaffQueueItem> checkIn(String qrToken) async {
    final response = await _apiClient.post(
      '/staff/queue/check-in',
      body: {'qrToken': qrToken.trim()},
    );
    return _parse(response);
  }

  StaffQueueItem _parse(Object? response) {
    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid queue item response');
    }
    return StaffQueueItem.fromJson(response);
  }
}
