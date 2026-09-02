import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client, this._onUnauthorized})
    : _client = client ?? http.Client();

  final http.Client _client;
  final void Function()? _onUnauthorized;
  String? _accessToken;

  void setAccessToken(String accessToken) {
    _accessToken = accessToken;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  Map<String, String> _headers({bool hasBody = false}) => {
    'Accept': 'application/json',
    if (hasBody) 'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  Future<Object?> get(String path) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers(),
    );

    return _decodeResponse(response);
  }

  Future<Object?> post(
    String path, {
    required Map<String, Object?> body,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers(hasBody: true),
      body: jsonEncode(body),
    );

    return _decodeResponse(response);
  }

  Future<Object?> patch(
    String path, {
    Map<String, Object?> body = const {},
  }) async {
    final response = await _client.patch(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers(hasBody: true),
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Object? _decodeResponse(http.Response response) {
    final body = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) _onUnauthorized?.call();
      final message = body is Map<String, dynamic>
          ? body['message']?.toString() ?? 'تعذر تنفيذ الطلب'
          : 'تعذر تنفيذ الطلب';

      throw ApiException(message, statusCode: response.statusCode);
    }

    return body;
  }
}
