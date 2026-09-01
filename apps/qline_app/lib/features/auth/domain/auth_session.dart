class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.userId,
    required this.fullName,
    required this.email,
  });

  final String accessToken;
  final String userId;
  final String fullName;
  final String email;
}
