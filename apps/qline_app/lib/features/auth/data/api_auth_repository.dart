import '../../../core/network/api_client.dart';
import '../domain/auth_session.dart';

class ApiAuthRepository {
  const ApiAuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {'email': email.trim(), 'password': password},
    );
    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid login response');
    }
    final user = response['user'];
    if (user is! Map<String, dynamic>) {
      throw const FormatException('Invalid user response');
    }
    final session = AuthSession(
      accessToken: response['accessToken'] as String,
      userId: user['id'] as String,
      fullName: user['fullName'] as String,
      email: user['email'] as String,
    );
    _apiClient.setAccessToken(session.accessToken);
    return session;
  }
}
