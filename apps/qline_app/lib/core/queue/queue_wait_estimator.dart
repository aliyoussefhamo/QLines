class QueueEmployee {
  const QueueEmployee({
    required this.id,
    required this.supportedServiceIds,
    this.remainingCurrentServiceMinutes = 0,
  });

  final String id;
  final Set<String> supportedServiceIds;
  final int remainingCurrentServiceMinutes;
}

class WaitingQueueEntry {
  const WaitingQueueEntry({
    required this.serviceId,
    required this.durationMinutes,
  });

  final String serviceId;
  final int durationMinutes;
}

class QueueWaitEstimator {
  const QueueWaitEstimator();

  int estimateWaitMinutes({
    required String requestedServiceId,
    required List<QueueEmployee> activeEmployees,
    required List<WaitingQueueEntry> peopleAhead,
  }) {
    final availableAt = {
      for (final employee in activeEmployees)
        employee.id: employee.remainingCurrentServiceMinutes,
    };

    for (final entry in peopleAhead) {
      final employee = _earliestCapableEmployee(
        serviceId: entry.serviceId,
        employees: activeEmployees,
        availableAt: availableAt,
      );
      if (employee != null) {
        availableAt[employee.id] =
            availableAt[employee.id]! + entry.durationMinutes;
      }
    }

    final targetEmployee = _earliestCapableEmployee(
      serviceId: requestedServiceId,
      employees: activeEmployees,
      availableAt: availableAt,
    );
    if (targetEmployee == null) {
      throw StateError('No active employee supports the requested service.');
    }
    return availableAt[targetEmployee.id]!;
  }

  QueueEmployee? _earliestCapableEmployee({
    required String serviceId,
    required List<QueueEmployee> employees,
    required Map<String, int> availableAt,
  }) {
    final capable = employees
        .where((employee) => employee.supportedServiceIds.contains(serviceId))
        .toList();
    if (capable.isEmpty) return null;
    capable.sort(
      (first, second) =>
          availableAt[first.id]!.compareTo(availableAt[second.id]!),
    );
    return capable.first;
  }
}
