import '../../../core/network/api_client.dart';
import '../domain/auth_session.dart';
import 'auth_session_store.dart';

class ApiAuthRepository {
  const ApiAuthRepository(this._apiClient, this._sessionStore);

  final ApiClient _apiClient;
  final AuthSessionStore _sessionStore;

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
      expiresAt: DateTime.now().add(
        Duration(seconds: response['expiresInSeconds'] as int),
      ),
    );
    _apiClient.setAccessToken(session.accessToken);
    await _sessionStore.save(session);
    return session;
  }
}
