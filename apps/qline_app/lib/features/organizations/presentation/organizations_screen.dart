import 'package:flutter/material.dart';

import '../domain/organization.dart';
import 'organizations_view_model.dart';

class OrganizationsScreen extends StatefulWidget {
  const OrganizationsScreen({
    super.key,
    required this.viewModel,
    required this.onOrganizationSelected,
    required this.onMyReservations,
    required this.onLogout,
  });

  final OrganizationsViewModel viewModel;
  final void Function(BuildContext context, Organization organization)
  onOrganizationSelected;
  final void Function(BuildContext context) onMyReservations;
  final Future<void> Function() onLogout;

  @override
  State<OrganizationsScreen> createState() => _OrganizationsScreenState();
}

class _OrganizationsScreenState extends State<OrganizationsScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_refresh);
    widget.viewModel.loadOrganizations();
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
        title: const Text('QLines'),
        actions: [
          IconButton(
            onPressed: () => widget.onMyReservations(context),
            tooltip: 'حجوزاتي',
            icon: const Icon(Icons.confirmation_number_outlined),
          ),
          IconButton(
            onPressed: () => _confirmLogout(context),
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'وين بدك تحجز؟',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('اختر المؤسسة، ثم سنرتب فروعها من الأقرب إليك.'),
              const SizedBox(height: 20),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('تراجع'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.onLogout();
  }

  Widget _buildContent() {
    return switch (widget.viewModel.status) {
      OrganizationsStatus.initial || OrganizationsStatus.loading =>
        const Center(child: CircularProgressIndicator()),
      OrganizationsStatus.failure => Center(
        child: FilledButton(
          onPressed: widget.viewModel.loadOrganizations,
          child: const Text('إعادة المحاولة'),
        ),
      ),
      OrganizationsStatus.success => ListView.separated(
        itemCount: widget.viewModel.organizations.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final organization = widget.viewModel.organizations[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              onTap: organization.isActive
                  ? () => widget.onOrganizationSelected(context, organization)
                  : null,
              leading: CircleAvatar(
                radius: 26,
                child: Icon(_iconFor(organization.category)),
              ),
              title: Text(
                organization.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${organization.category} • ${organization.branchCount} فروع',
              ),
              trailing: const Icon(Icons.chevron_left),
            ),
          );
        },
      ),
    };
  }

  IconData _iconFor(String category) {
    return switch (category) {
      'اتصالات' => Icons.phone_android_outlined,
      'تعليم' => Icons.school_outlined,
      _ => Icons.account_balance_outlined,
    };
  }
}
