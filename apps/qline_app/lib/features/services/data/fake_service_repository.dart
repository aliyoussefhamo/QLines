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
        requiredDocuments: ['البطاقة الشخصية', 'صورة عن البطاقة الشخصية'],
        requirements: ['حضور صاحب العلاقة أو وكيله القانوني'],
        steps: ['حجز الدور', 'تقديم الوثائق', 'دفع الرسوم', 'استلام الوثيقة'],
        notes: ['تأكد من صلاحية البطاقة الشخصية'],
        feeAmount: 5000,
        currency: 'SYP',
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
        requiredDocuments: ['رقم الحساب أو الاشتراك', 'الفاتورة إن وجدت'],
        requirements: ['معرفة رقم الحساب المطلوب تسديده'],
        steps: ['حجز الدور', 'تأكيد الحساب والمبلغ', 'الدفع', 'استلام الإيصال'],
        notes: ['احتفظ بإيصال الدفع'],
        feeAmount: null,
        currency: null,
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
        requiredDocuments: [
          'الوثيقة الأصلية',
          'صورة عن الوثيقة',
          'البطاقة الشخصية',
        ],
        requirements: ['أن تكون الوثيقة صادرة عن جهة معترف بها'],
        steps: ['حجز الدور', 'تدقيق الوثيقة', 'دفع الرسوم', 'استلام الوثيقة'],
        notes: ['قد تُطلب نسخة إضافية بحسب نوع الوثيقة'],
        feeAmount: 7500,
        currency: 'SYP',
        estimatedDurationMinutes: 15,
        peopleWaiting: 0,
        estimatedWaitMinutes: waitFor('document-certification'),
        isAvailable: false,
      ),
    ];
  }
}
