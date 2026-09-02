import '../../../core/network/api_client.dart';
import '../domain/user_profile.dart';

class ApiProfileRepository {
  const ApiProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<UserProfile> getProfile() async {
    final response = await _apiClient.get('/auth/me');
    return _parseProfile(response);
  }

  Future<UserProfile> updateFullName(String fullName) async {
    final response = await _apiClient.patch(
      '/auth/me',
      body: {'fullName': fullName.trim()},
    );
    return _parseProfile(response);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.patch(
      '/auth/change-password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  UserProfile _parseProfile(Object? response) {
    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid profile response');
    }
    return UserProfile.fromJson(response);
  }
}
