import 'package:flutter_test/flutter_test.dart';
import 'package:qline_app/features/services/domain/service.dart';
import 'package:qline_app/features/services/domain/service_repository.dart';
import 'package:qline_app/features/services/presentation/services_view_model.dart';

void main() {
  test('loads services for the selected branch', () async {
    final repository = _SuccessfulRepository();
    final viewModel = ServicesViewModel(repository);

    await viewModel.loadServices('branch-42');

    expect(repository.receivedBranchId, 'branch-42');
    expect(viewModel.status, ServicesStatus.success);
    expect(viewModel.services.single.branchId, 'branch-42');
  });

  test('exposes failure when loading services fails', () async {
    final viewModel = ServicesViewModel(_FailingRepository());

    await viewModel.loadServices('branch-42');

    expect(viewModel.status, ServicesStatus.failure);
    expect(viewModel.errorMessage, isNotEmpty);
  });
}

class _SuccessfulRepository implements ServiceRepository {
  String? receivedBranchId;

  @override
  Future<List<QueueService>> getServicesByBranch(String branchId) async {
    receivedBranchId = branchId;
    return [
      QueueService(
        id: 'service-1',
        branchId: branchId,
        name: 'Test service',
        description: 'Test description',
        requiredDocuments: const ['Identity card'],
        requirements: const ['Applicant must attend'],
        steps: const ['Submit documents'],
        notes: const ['Test note'],
        feeAmount: 100,
        currency: 'SYP',
        estimatedDurationMinutes: 5,
        peopleWaiting: 2,
        estimatedWaitMinutes: 10,
        isAvailable: true,
      ),
    ];
  }
}

class _FailingRepository implements ServiceRepository {
  @override
  Future<List<QueueService>> getServicesByBranch(String branchId) {
    throw Exception('network');
  }
}
