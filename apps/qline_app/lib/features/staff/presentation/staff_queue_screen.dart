import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/realtime/reservation_realtime_service.dart';
import '../../../core/realtime/realtime_status_badge.dart';
import '../data/api_staff_queue_repository.dart';
import '../domain/staff_queue_item.dart';
import 'qr_scanner_screen.dart';

class StaffQueueScreen extends StatefulWidget {
  const StaffQueueScreen({
    required this.repository,
    required this.branchId,
    required this.onLogout,
    required this.realtimeService,
    super.key,
  });

  final ApiStaffQueueRepository repository;
  final String branchId;
  final Future<void> Function() onLogout;
  final ReservationRealtimeService realtimeService;

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
    widget.realtimeService.addListener(_refreshFromRealtime);
  }

  @override
  void dispose() {
    widget.realtimeService.removeListener(_refreshFromRealtime);
    widget.realtimeService.dispose();
    super.dispose();
  }

  void _refreshFromRealtime() {
    if (widget.realtimeService.lastEvent == null) {
      if (mounted) setState(() {});
      return;
    }
    _load(showLoading: false);
  }

  Future<void> _load({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final items = await widget.repository.getQueue();
      if (mounted) setState(() => _items = items);
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذر تحميل الطابور');
    } finally {
      if (mounted && showLoading) setState(() => _isLoading = false);
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

  Future<void> _openScanner() async {
    final token = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const QrScannerScreen()),
    );
    if (token != null) await _checkIn(token);
  }

  Future<void> _enterQrManually() async {
    final controller = TextEditingController();
    final token = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إدخال رمز الحجز'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'رمز QR'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('تحقق'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (token != null && token.isNotEmpty) await _checkIn(token);
  }

  Future<void> _checkIn(String token) async {
    setState(() => _isUpdating = true);
    try {
      final item = await widget.repository.checkIn(token);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تأكيد حضور الدور ${item.ticketNumber}')),
        );
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final called = _items.where((item) => item.status == 'called').firstOrNull;
    final checkedIn = _items
        .where((item) => item.status == 'checked_in')
        .toList();
    final awaitingArrival = _items
        .where((item) => item.status == 'waiting')
        .toList();
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
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: RealtimeStatusBadge(
                    isConnected: widget.realtimeService.isConnected,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isUpdating ? null : _openScanner,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('مسح QR'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      onPressed: _isUpdating ? null : _enterQrManually,
                      tooltip: 'إدخال الرمز يدوياً',
                      icon: const Icon(Icons.keyboard_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                  onPressed: called != null || checkedIn.isEmpty || _isUpdating
                      ? null
                      : _callNext,
                  icon: const Icon(Icons.campaign_outlined),
                  label: const Text('استدعاء الدور التالي'),
                ),
                const SizedBox(height: 20),
                Text(
                  'جاهزون للاستدعاء (${checkedIn.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...checkedIn.map(
                  (item) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${item.ticketNumber}'),
                      ),
                      title: Text(item.serviceName),
                      subtitle: const Text('تم تأكيد الحضور'),
                      trailing: const Icon(Icons.verified, color: Colors.green),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'بانتظار الوصول (${awaitingArrival.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...awaitingArrival.map(
                  (item) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${item.ticketNumber}'),
                      ),
                      title: Text(item.serviceName),
                      subtitle: Text(
                        'وقت الحجز: ${TimeOfDay.fromDateTime(item.createdAt.toLocal()).format(context)}',
                      ),
                      trailing: const Icon(Icons.schedule_outlined),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
