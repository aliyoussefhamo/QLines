class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.expiresAt,
    required this.role,
    required this.employeeBranchId,
  });

  final String accessToken;
  final String userId;
  final String fullName;
  final String email;
  final DateTime expiresAt;
  final String role;
  final String? employeeBranchId;

  bool get isExpired => !expiresAt.isAfter(DateTime.now());
  bool get isStaff => role == 'staff' || role == 'admin';
}
