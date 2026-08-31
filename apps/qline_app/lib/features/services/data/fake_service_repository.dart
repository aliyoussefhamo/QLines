import '../../../core/queue/queue_wait_estimator.dart';
import '../domain/service.dart';
import '../domain/service_repository.dart';

class FakeServiceRepository implements ServiceRepository {
  @override
  Future<List<QueueService>> getServicesByBranch(String branchId) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    const estimator = QueueWaitEstimator();
    const employees = [
      QueueEmployee(
        id: 'employee-1',
        supportedServiceIds: {'document-issuance', 'bill-payment'},
        remainingCurrentServiceMinutes: 3,
      ),
      QueueEmployee(
        id: 'employee-2',
        supportedServiceIds: {'document-issuance', 'document-certification'},
        remainingCurrentServiceMinutes: 6,
      ),
    ];
    const peopleAhead = [
      WaitingQueueEntry(serviceId: 'document-issuance', durationMinutes: 12),
      WaitingQueueEntry(serviceId: 'bill-payment', durationMinutes: 5),
      WaitingQueueEntry(serviceId: 'document-issuance', durationMinutes: 12),
      WaitingQueueEntry(
        serviceId: 'document-certification',
        durationMinutes: 15,
      ),
    ];

    int waitFor(String serviceId) => estimator.estimateWaitMinutes(
      requestedServiceId: serviceId,
      activeEmployees: employees,
      peopleAhead: peopleAhead,
    );

    return [
      QueueService(
        id: 'document-issuance',
        branchId: branchId,
        name: 'إصدار وثيقة',
        description: 'تقديم طلب وإصدار الوثائق الرسمية.',
        estimatedDurationMinutes: 12,
        peopleWaiting: 4,
        estimatedWaitMinutes: waitFor('document-issuance'),
        isAvailable: true,
      ),
      QueueService(
        id: 'bill-payment',
        branchId: branchId,
        name: 'دفع فاتورة',
        description: 'تسديد الفواتير والرسوم المستحقة.',
        estimatedDurationMinutes: 5,
        peopleWaiting: 7,
        estimatedWaitMinutes: waitFor('bill-payment'),
        isAvailable: true,
      ),
      QueueService(
        id: 'document-certification',
        branchId: branchId,
        name: 'تصديق أوراق',
        description: 'تصديق الوثائق والأوراق المطلوبة.',
        estimatedDurationMinutes: 15,
        peopleWaiting: 0,
        estimatedWaitMinutes: waitFor('document-certification'),
        isAvailable: false,
      ),
    ];
  }
}
