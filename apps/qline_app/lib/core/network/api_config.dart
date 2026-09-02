abstract final class ApiConfig {
  static const serverUrl = String.fromEnvironment(
    'API_SERVER_URL',
    defaultValue: 'http://localhost:3000',
  );
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '$serverUrl/api/v1',
  );
}
