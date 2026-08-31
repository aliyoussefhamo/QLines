import 'package:flutter/material.dart';

import '../core/location/distance_calculator.dart';
import '../core/location/fake_location_service.dart';
import '../features/branches/data/fake_branch_repository.dart';
import '../features/branches/presentation/branches_screen.dart';
import '../features/branches/presentation/branches_view_model.dart';
import '../features/organizations/data/fake_organization_repository.dart';
import '../features/organizations/presentation/organizations_screen.dart';
import '../features/organizations/presentation/organizations_view_model.dart';
import '../features/reservations/data/fake_reservation_repository.dart';
import '../features/reservations/presentation/reservation_screen.dart';
import '../features/reservations/presentation/reservation_view_model.dart';
import '../features/services/data/fake_service_repository.dart';
import '../features/services/presentation/services_screen.dart';
import '../features/services/presentation/services_view_model.dart';
import 'theme/qline_theme.dart';

class QlineApp extends StatelessWidget {
  const QlineApp({super.key});

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
      home: OrganizationsScreen(
        viewModel: OrganizationsViewModel(FakeOrganizationRepository()),
        onOrganizationSelected: (context, organization) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BranchesScreen(
                organization: organization,
                viewModel: BranchesViewModel(
                  FakeBranchRepository(),
                  const FakeLocationService(),
                  const HaversineDistanceCalculator(),
                ),
                onBranchSelected: (context, branch, travelMinutes) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ServicesScreen(
                        branch: branch,
                        estimatedTravelMinutes: travelMinutes,
                        viewModel: ServicesViewModel(FakeServiceRepository()),
                        onContinueReservation:
                            (context, branch, service, travelMinutes) {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ReservationScreen(
                                    branch: branch,
                                    service: service,
                                    estimatedTravelMinutes: travelMinutes,
                                    viewModel: ReservationViewModel(
                                      FakeReservationRepository(),
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
      ),
    );
  }
}
