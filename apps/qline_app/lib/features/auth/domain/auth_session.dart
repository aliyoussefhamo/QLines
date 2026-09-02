class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.expiresAt,
  });

  final String accessToken;
  final String userId;
  final String fullName;
  final String email;
  final DateTime expiresAt;

  bool get isExpired => !expiresAt.isAfter(DateTime.now());
}
