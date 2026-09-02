import '../../../core/network/api_client.dart';
import '../domain/auth_session.dart';
import '../domain/pending_email_verification.dart';
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
    return _saveSession(response);
  }

  Future<PendingEmailVerification> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      body: {
        'fullName': fullName.trim(),
        'email': email.trim(),
        'password': password,
      },
    );
    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid registration response');
    }
    return PendingEmailVerification(
      email: response['email'] as String,
      expiresInSeconds: response['expiresInSeconds'] as int,
    );
  }

  Future<AuthSession> verifyEmail({
    required String email,
    required String code,
  }) async {
    final response = await _apiClient.post(
      '/auth/verify-email',
      body: {'email': email, 'code': code},
    );
    return _saveSession(response);
  }

  Future<void> resendVerification(String email) async {
    await _apiClient.post('/auth/resend-verification', body: {'email': email});
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.post(
      '/auth/forgot-password',
      body: {'email': email.trim()},
    );
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _apiClient.post(
      '/auth/reset-password',
      body: {
        'email': email.trim(),
        'code': code.trim(),
        'newPassword': newPassword,
      },
    );
  }

  Future<AuthSession> _saveSession(Object? response) async {
    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid authentication response');
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
      role: user['role'] as String,
      employeeBranchId: user['employeeBranchId'] as String?,
    );
    _apiClient.setAccessToken(session.accessToken);
    await _sessionStore.save(session);
    return session;
  }
}
