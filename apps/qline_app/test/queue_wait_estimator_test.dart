import 'package:flutter_test/flutter_test.dart';
import 'package:qline_app/core/queue/queue_wait_estimator.dart';

void main() {
  test('assigns waiting people to the earliest capable employee', () {
    const estimator = QueueWaitEstimator();
    final wait = estimator.estimateWaitMinutes(
      requestedServiceId: 'documents',
      activeEmployees: const [
        QueueEmployee(
          id: 'e1',
          supportedServiceIds: {'documents'},
          remainingCurrentServiceMinutes: 5,
        ),
        QueueEmployee(
          id: 'e2',
          supportedServiceIds: {'documents'},
          remainingCurrentServiceMinutes: 10,
        ),
      ],
      peopleAhead: const [
        WaitingQueueEntry(serviceId: 'documents', durationMinutes: 8),
        WaitingQueueEntry(serviceId: 'documents', durationMinutes: 8),
      ],
    );
    expect(wait, 13);
  });

  test('ignores employees who cannot perform the requested service', () {
    const estimator = QueueWaitEstimator();
    final wait = estimator.estimateWaitMinutes(
      requestedServiceId: 'documents',
      activeEmployees: const [
        QueueEmployee(id: 'e1', supportedServiceIds: {'payments'}),
        QueueEmployee(
          id: 'e2',
          supportedServiceIds: {'documents'},
          remainingCurrentServiceMinutes: 7,
        ),
      ],
      peopleAhead: const [],
    );
    expect(wait, 7);
  });
}
