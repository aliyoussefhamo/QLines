import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../data/api_staff_queue_repository.dart';
import '../domain/staff_queue_item.dart';

class StaffQueueScreen extends StatefulWidget {
  const StaffQueueScreen({
    required this.repository,
    required this.branchId,
    required this.onLogout,
    super.key,
  });

  final ApiStaffQueueRepository repository;
  final String branchId;
  final Future<void> Function() onLogout;

  @override
  State<StaffQueueScreen> createState() => _StaffQueueScreenState();
}

class _StaffQueueScreenState extends State<StaffQueueScreen> {
  List<StaffQueueItem> _items = const [];
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await widget.repository.getQueue();
      if (mounted) setState(() => _items = items);
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذر تحميل الطابور');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _callNext() async {
    await _runUpdate(() => widget.repository.callNext());
  }

  Future<void> _updateCurrent(String status) async {
    final current = _items.where((item) => item.status == 'called').firstOrNull;
    if (current == null) return;
    await _runUpdate(() => widget.repository.updateStatus(current.id, status));
  }

  Future<void> _runUpdate(Future<StaffQueueItem> Function() operation) async {
    setState(() => _isUpdating = true);
    try {
      await operation();
      await _load();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final called = _items.where((item) => item.status == 'called').firstOrNull;
    final waiting = _items.where((item) => item.status == 'waiting').toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الموظف'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: FilledButton(
                onPressed: _load,
                child: const Text('إعادة المحاولة'),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('الفرع: ${widget.branchId}'),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: called == null
                        ? const Text(
                            'لا يوجد دور مستدعى حالياً',
                            textAlign: TextAlign.center,
                          )
                        : Column(
                            children: [
                              Text(
                                'الدور الحالي ${called.ticketNumber}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                              ),
                              Text(called.serviceName),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: _isUpdating
                                          ? null
                                          : () => _updateCurrent('completed'),
                                      icon: const Icon(Icons.check),
                                      label: const Text('تمت الخدمة'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _isUpdating
                                          ? null
                                          : () => _updateCurrent('no_show'),
                                      icon: const Icon(
                                        Icons.person_off_outlined,
                                      ),
                                      label: const Text('غائب'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: called != null || waiting.isEmpty || _isUpdating
                      ? null
                      : _callNext,
                  icon: const Icon(Icons.campaign_outlined),
                  label: const Text('استدعاء الدور التالي'),
                ),
                const SizedBox(height: 20),
                Text(
                  'المنتظرون (${waiting.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...waiting.map(
                  (item) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${item.ticketNumber}'),
                      ),
                      title: Text(item.serviceName),
                      subtitle: Text(
                        'وقت الحجز: ${TimeOfDay.fromDateTime(item.createdAt.toLocal()).format(context)}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
