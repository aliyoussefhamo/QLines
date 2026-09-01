import 'package:flutter/material.dart';

import '../core/location/distance_calculator.dart';
import '../core/location/fake_location_service.dart';
import '../core/network/api_client.dart';
import '../features/auth/data/api_auth_repository.dart';
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
import 'theme/qline_theme.dart';

class QlineApp extends StatelessWidget {
  const QlineApp({super.key});

  static final ApiClient _apiClient = ApiClient();

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
      home: LoginScreen(
        repository: ApiAuthRepository(_apiClient),
        onAuthenticated: (context, _) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => _organizationsFlow()),
          );
        },
      ),
    );
  }

  Widget _organizationsFlow() {
    return OrganizationsScreen(
      viewModel: OrganizationsViewModel(ApiOrganizationRepository(_apiClient)),
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
