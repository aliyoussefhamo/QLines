class PendingEmailVerification {
  const PendingEmailVerification({
    required this.email,
    required this.expiresInSeconds,
  });

  final String email;
  final int expiresInSeconds;
}
