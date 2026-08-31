import 'package:flutter/material.dart';

import '../../branches/domain/branch.dart';
import '../domain/service.dart';
import 'services_view_model.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({
    super.key,
    required this.branch,
    required this.estimatedTravelMinutes,
    required this.viewModel,
    required this.onContinueReservation,
  });

  final Branch branch;
  final int estimatedTravelMinutes;
  final ServicesViewModel viewModel;
  final void Function(
    BuildContext context,
    Branch branch,
    QueueService service,
    int estimatedTravelMinutes,
  )
  onContinueReservation;

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_refresh);
    widget.viewModel.loadServices(widget.branch.id);
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
      appBar: AppBar(title: const Text('الخدمات')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BranchSummary(branch: widget.branch),
              const SizedBox(height: 20),
              Text(
                'اختر الخدمة المطلوبة',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return switch (widget.viewModel.status) {
      ServicesStatus.initial || ServicesStatus.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      ServicesStatus.failure => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(widget.viewModel.errorMessage!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => widget.viewModel.loadServices(widget.branch.id),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
      ServicesStatus.success when widget.viewModel.services.isEmpty =>
        const Center(child: Text('لا توجد خدمات متاحة في هذا الفرع.')),
      ServicesStatus.success => ListView.separated(
        itemCount: widget.viewModel.services.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final service = widget.viewModel.services[index];
          return _ServiceCard(
            service: service,
            onTap: service.isAvailable
                ? () => _showServiceDetails(service)
                : null,
          );
        },
      ),
    };
  }

  void _showServiceDetails(QueueService service) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              service.name,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(service.description),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                widget.onContinueReservation(
                  this.context,
                  widget.branch,
                  service,
                  widget.estimatedTravelMinutes,
                );
              },
              icon: const Icon(Icons.confirmation_number_outlined),
              label: const Text('متابعة الحجز'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchSummary extends StatelessWidget {
  const _BranchSummary({required this.branch});

  final Branch branch;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            child: const Icon(Icons.location_on_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.organizationName,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text('${branch.name} • ${branch.address}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onTap});

  final QueueService service;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: service.isAvailable
                      ? colors.secondaryContainer
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.design_services_outlined,
                  color: service.isAvailable ? colors.secondary : Colors.grey,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.isAvailable
                          ? '${service.peopleWaiting} منتظرين • انتظار ${service.estimatedWaitMinutes} دقيقة'
                          : 'الخدمة غير متاحة حاليًا',
                    ),
                  ],
                ),
              ),
              Icon(
                service.isAvailable ? Icons.chevron_left : Icons.lock_outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
