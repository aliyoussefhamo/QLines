import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/auth_session.dart';

class AuthSessionStore {
  const AuthSessionStore({this.storage = const FlutterSecureStorage()});

  static const _tokenKey = 'auth_access_token';
  static const _userIdKey = 'auth_user_id';
  static const _fullNameKey = 'auth_full_name';
  static const _emailKey = 'auth_email';
  static const _expiresAtKey = 'auth_expires_at';
  static const _roleKey = 'auth_role';
  static const _employeeBranchIdKey = 'auth_employee_branch_id';

  final FlutterSecureStorage storage;

  Future<void> save(AuthSession session) async {
    // Web creates its encryption key on the first write. These writes must be
    // sequential to prevent multiple first-write key generations racing.
    await storage.write(key: _tokenKey, value: session.accessToken);
    await storage.write(key: _userIdKey, value: session.userId);
    await storage.write(key: _fullNameKey, value: session.fullName);
    await storage.write(key: _emailKey, value: session.email);
    await storage.write(
      key: _expiresAtKey,
      value: session.expiresAt.toUtc().toIso8601String(),
    );
    await storage.write(key: _roleKey, value: session.role);
    await storage.write(
      key: _employeeBranchIdKey,
      value: session.employeeBranchId ?? '',
    );
  }

  Future<AuthSession?> read() async {
    final values = await Future.wait([
      storage.read(key: _tokenKey),
      storage.read(key: _userIdKey),
      storage.read(key: _fullNameKey),
      storage.read(key: _emailKey),
      storage.read(key: _expiresAtKey),
      storage.read(key: _roleKey),
      storage.read(key: _employeeBranchIdKey),
    ]);
    if (values.any((value) => value == null)) return null;

    final expiresAt = DateTime.tryParse(values[4]!);
    if (expiresAt == null) {
      await clear();
      return null;
    }
    final session = AuthSession(
      accessToken: values[0]!,
      userId: values[1]!,
      fullName: values[2]!,
      email: values[3]!,
      expiresAt: expiresAt,
      role: values[5]!,
      employeeBranchId: values[6]!.isEmpty ? null : values[6],
    );
    if (session.isExpired) {
      await clear();
      return null;
    }
    return session;
  }

  Future<void> clear() => storage.deleteAll();
}
