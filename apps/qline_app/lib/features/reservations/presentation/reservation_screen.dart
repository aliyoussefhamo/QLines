import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../branches/domain/branch.dart';
import '../../services/domain/service.dart';
import '../domain/queue_ticket.dart';
import 'reservation_view_model.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({
    super.key,
    required this.branch,
    required this.service,
    required this.estimatedTravelMinutes,
    required this.viewModel,
  });

  final Branch branch;
  final QueueService service;
  final int estimatedTravelMinutes;
  final ReservationViewModel viewModel;

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_refresh);
    widget.viewModel.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.viewModel.status == ReservationStatus.success
              ? 'تذكرتك'
              : 'تأكيد الحجز',
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: widget.viewModel.status == ReservationStatus.success
              ? _TicketView(
                  key: const ValueKey('ticket'),
                  ticket: widget.viewModel.ticket!,
                  branch: widget.branch,
                  service: widget.service,
                )
              : _ConfirmationView(
                  key: const ValueKey('confirmation'),
                  branch: widget.branch,
                  service: widget.service,
                  status: widget.viewModel.status,
                  errorMessage: widget.viewModel.errorMessage,
                  onConfirm: () => widget.viewModel.reserve(
                    branchId: widget.branch.id,
                    serviceId: widget.service.id,
                    peopleAhead: widget.service.peopleWaiting,
                    estimatedWaitMinutes: widget.service.estimatedWaitMinutes,
                    estimatedTravelMinutes: widget.estimatedTravelMinutes,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ConfirmationView extends StatelessWidget {
  const _ConfirmationView({
    super.key,
    required this.branch,
    required this.service,
    required this.status,
    required this.errorMessage,
    required this.onConfirm,
  });

  final Branch branch;
  final QueueService service;
  final ReservationStatus status;
  final String? errorMessage;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final isSubmitting = status == ReservationStatus.submitting;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Icon(
          Icons.event_available_outlined,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'راجع تفاصيل حجزك',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _SummaryTile(
          icon: Icons.apartment_outlined,
          title: branch.organizationName,
          subtitle: '${branch.name} • ${branch.address}',
        ),
        const SizedBox(height: 12),
        _SummaryTile(
          icon: Icons.design_services_outlined,
          title: service.name,
          subtitle: service.description,
        ),
        const SizedBox(height: 12),
        _SummaryTile(
          icon: Icons.schedule,
          title: '${service.peopleWaiting} أشخاص قبلك تقريبًا',
          subtitle:
              'بدء الخدمة متوقع خلال ${service.estimatedWaitMinutes} دقيقة',
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: isSubmitting ? null : onConfirm,
          icon: isSubmitting
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_circle_outline),
          label: Text(isSubmitting ? 'جارٍ إنشاء الحجز...' : 'تأكيد الحجز'),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
      ),
    );
  }
}

class _TicketView extends StatelessWidget {
  const _TicketView({
    super.key,
    required this.ticket,
    required this.branch,
    required this.service,
  });

  final QueueTicket ticket;
  final Branch branch;
  final QueueService service;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              Icon(Icons.verified_outlined, color: colors.onPrimary, size: 44),
              const SizedBox(height: 8),
              Text('تم الحجز بنجاح', style: TextStyle(color: colors.onPrimary)),
              const SizedBox(height: 16),
              Text(
                ticket.number,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('رقم دورك', style: TextStyle(color: colors.onPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _TicketMetric(value: '${ticket.peopleAhead}', label: 'أشخاص قبلك'),
            _TicketMetric(
              value: '${ticket.estimatedTravelMinutes}',
              label: 'دقيقة للوصول',
            ),
            _TicketMetric(
              value: '${ticket.estimatedWaitMinutes}',
              label: 'دقيقة انتظار',
            ),
            _TicketMetric(
              value: '${ticket.estimatedTotalMinutes}',
              label: 'دقيقة إجمالي',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SummaryTile(
          icon: Icons.apartment_outlined,
          title: branch.name,
          subtitle: branch.address,
        ),
        const SizedBox(height: 12),
        _SummaryTile(
          icon: Icons.design_services_outlined,
          title: service.name,
          subtitle: 'الحالة: محجوز - بانتظار تسجيل الوصول',
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'رمز تسجيل الوصول',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                QrImageView(
                  data: ticket.qrToken,
                  version: QrVersions.auto,
                  size: 190,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text(
                  'اعرض هذا الرمز عند الوصول إلى الفرع',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
          icon: const Icon(Icons.home_outlined),
          label: const Text('العودة للرئيسية'),
        ),
      ],
    );
  }
}

class _TicketMetric extends StatelessWidget {
  const _TicketMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: 150,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
