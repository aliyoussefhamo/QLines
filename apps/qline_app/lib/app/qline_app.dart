import 'package:flutter/material.dart';

import '../core/location/distance_calculator.dart';
import '../core/location/fake_location_service.dart';
import '../core/network/api_client.dart';
import '../features/auth/data/api_auth_repository.dart';
import '../features/auth/data/auth_session_store.dart';
import '../features/auth/domain/auth_session.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/branches/data/api_branch_repository.dart';
import '../features/branches/presentation/branches_screen.dart';
import '../features/branches/presentation/branches_view_model.dart';
import '../features/organizations/data/api_organization_repository.dart';
import '../features/organizations/presentation/organizations_screen.dart';
import '../features/organizations/presentation/organizations_view_model.dart';
import '../features/reservations/data/api_reservation_repository.dart';
import '../features/reservations/data/api_my_reservations_repository.dart';
import '../features/reservations/presentation/my_reservations_screen.dart';
import '../features/reservations/presentation/my_reservations_view_model.dart';
import '../features/reservations/presentation/reservation_screen.dart';
import '../features/reservations/presentation/reservation_view_model.dart';
import '../features/services/data/api_service_repository.dart';
import '../features/services/presentation/services_screen.dart';
import '../features/services/presentation/services_view_model.dart';
import '../features/profile/data/api_profile_repository.dart';
import '../features/profile/domain/user_profile.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/staff/data/api_staff_queue_repository.dart';
import '../features/staff/presentation/staff_queue_screen.dart';
import 'theme/qline_theme.dart';

class QlineApp extends StatefulWidget {
  const QlineApp({super.key});

  @override
  State<QlineApp> createState() => _QlineAppState();
}

class _QlineAppState extends State<QlineApp> {
  late final ApiClient _apiClient;
  final AuthSessionStore _sessionStore = const AuthSessionStore();
  AuthSession? _session;
  bool _isRestoringSession = true;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(onUnauthorized: _handleUnauthorized);
    _restoreSession();
  }

  void _handleUnauthorized() {
    _sessionStore.clear();
    if (mounted) setState(() => _session = null);
  }

  Future<void> _restoreSession() async {
    AuthSession? session;
    try {
      session = await _sessionStore.read();
      if (session != null) _apiClient.setAccessToken(session.accessToken);
    } catch (_) {
      await _sessionStore.clear().catchError((_) {});
    } finally {
      if (mounted) {
        setState(() {
          _session = session;
          _isRestoringSession = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _sessionStore.clear();
    _apiClient.clearAccessToken();
    if (mounted) setState(() => _session = null);
  }

  Future<void> _updateProfile(UserProfile profile) async {
    final current = _session;
    if (current == null) return;
    final updated = AuthSession(
      accessToken: current.accessToken,
      userId: profile.id,
      fullName: profile.fullName,
      email: profile.email,
      expiresAt: current.expiresAt,
      role: current.role,
      employeeBranchId: current.employeeBranchId,
    );
    await _sessionStore.save(updated);
    _session = updated;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QLines',
      debugShowCheckedModeBanner: false,
      theme: QlineTheme.light,
      locale: const Locale('ar'),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: _home(),
    );
  }

  Widget _home() {
    if (_isRestoringSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_session == null) {
      return LoginScreen(
        key: const ValueKey('login'),
        repository: ApiAuthRepository(_apiClient, _sessionStore),
        onAuthenticated: (_, session) => setState(() => _session = session),
      );
    }
    if (_session!.isStaff) {
      return StaffQueueScreen(
        repository: ApiStaffQueueRepository(_apiClient),
        branchId: _session!.employeeBranchId!,
        onLogout: _logout,
      );
    }
    return KeyedSubtree(
      key: const ValueKey('organizations'),
      child: _organizationsFlow(),
    );
  }

  Widget _organizationsFlow() {
    return OrganizationsScreen(
      viewModel: OrganizationsViewModel(ApiOrganizationRepository(_apiClient)),
      onLogout: _logout,
      onProfile: (context) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProfileScreen(
              repository: ApiProfileRepository(_apiClient),
              onProfileUpdated: _updateProfile,
              onLogout: _logout,
            ),
          ),
        );
      },
      onMyReservations: (context) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MyReservationsScreen(
              viewModel: MyReservationsViewModel(
                ApiMyReservationsRepository(_apiClient),
              ),
            ),
          ),
        );
      },
      onOrganizationSelected: (context, organization) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BranchesScreen(
              organization: organization,
              viewModel: BranchesViewModel(
                ApiBranchRepository(_apiClient),
                const FakeLocationService(),
                const HaversineDistanceCalculator(),
              ),
              onBranchSelected: (context, branch, travelMinutes) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ServicesScreen(
                      branch: branch,
                      estimatedTravelMinutes: travelMinutes,
                      viewModel: ServicesViewModel(
                        ApiServiceRepository(_apiClient),
                      ),
                      onContinueReservation:
                          (context, branch, service, travelMinutes) {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ReservationScreen(
                                  branch: branch,
                                  service: service,
                                  estimatedTravelMinutes: travelMinutes,
                                  viewModel: ReservationViewModel(
                                    ApiReservationRepository(_apiClient),
                                  ),
                                ),
                              ),
                            );
                          },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
