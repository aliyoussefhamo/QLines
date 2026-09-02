import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../domain/my_reservation.dart';
import '../domain/queue_ticket.dart';
import 'my_reservations_view_model.dart';
import '../../../core/realtime/reservation_realtime_service.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({
    required this.viewModel,
    required this.realtimeService,
    super.key,
  });

  final MyReservationsViewModel viewModel;
  final ReservationRealtimeService realtimeService;

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_refresh);
    widget.viewModel.load();
    widget.realtimeService.addListener(_refreshFromRealtime);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_refresh);
    widget.viewModel.dispose();
    widget.realtimeService.removeListener(_refreshFromRealtime);
    widget.realtimeService.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _refreshFromRealtime() {
    widget.viewModel.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حجوزاتي')),
      body: SafeArea(child: _content()),
    );
  }

  Widget _content() {
    final viewModel = widget.viewModel;
    if (viewModel.status == MyReservationsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.status == MyReservationsStatus.failure) {
      return Center(
        child: FilledButton.icon(
          onPressed: viewModel.load,
          icon: const Icon(Icons.refresh),
          label: const Text('إعادة المحاولة'),
        ),
      );
    }
    if (viewModel.reservations.isEmpty) {
      return const Center(child: Text('لا توجد حجوزات حتى الآن'));
    }
    return RefreshIndicator(
      onRefresh: viewModel.load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.reservations.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _ReservationCard(
          reservation: viewModel.reservations[index],
          isCancelling:
              viewModel.cancellingId == viewModel.reservations[index].id,
          onShowQr: () => _showQr(viewModel.reservations[index]),
          onCancel: () => _confirmCancel(viewModel.reservations[index]),
        ),
      ),
    );
  }

  Future<void> _confirmCancel(MyReservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الحجز'),
        content: const Text('هل أنت متأكد من إلغاء هذا الحجز؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('تراجع'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إلغاء الحجز'),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.viewModel.cancel(reservation);
  }

  void _showQr(MyReservation reservation) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 320,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'رقم الدور A-${reservation.ticketNumber}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SizedBox.square(
                  dimension: 220,
                  child: QrImageView(
                    data: reservation.qrToken,
                    version: QrVersions.auto,
                    size: 220,
                    padding: const EdgeInsets.all(8),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'اعرض هذا الرمز عند الوصول إلى الفرع',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إغلاق'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.isCancelling,
    required this.onShowQr,
    required this.onCancel,
  });

  final MyReservation reservation;
  final bool isCancelling;
  final VoidCallback onShowQr;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text('${reservation.ticketNumber}')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الدور A-${reservation.ticketNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_statusLabel(reservation.status)),
                    ],
                  ),
                ),
                Chip(label: Text(_statusLabel(reservation.status))),
              ],
            ),
            const Divider(height: 24),
            Text('الفرع: ${reservation.branchId}'),
            Text('الخدمة: ${reservation.serviceId}'),
            Text('الموعد المتوقع: ${_date(reservation.estimatedTurnAt)}'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShowQr,
                    icon: const Icon(Icons.qr_code),
                    label: const Text('عرض QR'),
                  ),
                ),
                if (reservation.canCancel) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: isCancelling ? null : onCancel,
                      icon: const Icon(Icons.cancel_outlined),
                      label: Text(isCancelling ? 'جارٍ الإلغاء' : 'إلغاء'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(TicketStatus status) => switch (status) {
    TicketStatus.reserved => 'قيد الانتظار',
    TicketStatus.called => 'حان دورك',
    TicketStatus.completed => 'مكتمل',
    TicketStatus.cancelled => 'ملغى',
    TicketStatus.checkedIn => 'تم الوصول',
    TicketStatus.serving => 'قيد الخدمة',
  };

  String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
