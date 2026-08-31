import 'package:flutter_test/flutter_test.dart';
import 'package:qline_app/core/location/distance_calculator.dart';
import 'package:qline_app/core/location/fake_location_service.dart';
import 'package:qline_app/core/location/geo_point.dart';
import 'package:qline_app/features/branches/domain/branch.dart';
import 'package:qline_app/features/branches/domain/branch_repository.dart';
import 'package:qline_app/features/branches/presentation/branches_view_model.dart';

void main() {
  test('loads branches and exposes success state', () async {
    final viewModel = BranchesViewModel(
      _SuccessfulRepository(),
      const FakeLocationService(),
      const HaversineDistanceCalculator(),
    );
    await viewModel.loadBranches('org-1');
    expect(viewModel.status, BranchesStatus.success);
    expect(viewModel.branches, hasLength(1));
    expect(viewModel.errorMessage, isNull);
  });

  test('exposes a readable error when repository fails', () async {
    final viewModel = BranchesViewModel(
      _FailingRepository(),
      const FakeLocationService(),
      const HaversineDistanceCalculator(),
    );
    await viewModel.loadBranches('org-1');
    expect(viewModel.status, BranchesStatus.failure);
    expect(viewModel.errorMessage, isNotEmpty);
  });
}

class _SuccessfulRepository implements BranchRepository {
  @override
  Future<List<Branch>> getBranchesByOrganization(String organizationId) async =>
      const [
        Branch(
          id: '1',
          organizationId: 'org-1',
          name: 'Test branch',
          organizationName: 'Test organization',
          address: 'Test address',
          peopleWaiting: 2,
          estimatedWaitMinutes: 5,
          isOpen: true,
          location: GeoPoint(latitude: 33.52, longitude: 36.28),
        ),
      ];
}

class _FailingRepository implements BranchRepository {
  @override
  Future<List<Branch>> getBranchesByOrganization(String organizationId) =>
      throw Exception('network');
}
