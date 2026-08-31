import 'package:flutter/material.dart';

import '../domain/branch.dart';
import '../../organizations/domain/organization.dart';
import 'branches_view_model.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({
    super.key,
    required this.viewModel,
    required this.organization,
    required this.onBranchSelected,
  });

  final BranchesViewModel viewModel;
  final Organization organization;
  final void Function(
    BuildContext context,
    Branch branch,
    int estimatedTravelMinutes,
  )
  onBranchSelected;

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_refresh);
    widget.viewModel.loadBranches(widget.organization.id);
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
        title: Text(widget.organization.name),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'الإشعارات',
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WelcomeBanner(
                title: 'احجز دورك قبل أن تصل',
                subtitle: 'الفروع مرتبة من الأقرب إلى موقعك.',
              ),
              const SizedBox(height: 16),
              _TravelModeFilter(
                selectedMode: widget.viewModel.travelMode,
                onSelected: widget.viewModel.selectTravelMode,
              ),
              const SizedBox(height: 20),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return switch (widget.viewModel.status) {
      BranchesStatus.initial || BranchesStatus.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      BranchesStatus.failure => _ErrorView(
        message: widget.viewModel.errorMessage!,
        onRetry: () => widget.viewModel.loadBranches(widget.organization.id),
      ),
      BranchesStatus.success => ListView.separated(
        itemCount: widget.viewModel.branches.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final branch = widget.viewModel.branches[index];
          return _BranchCard(
            branch: branch,
            distanceKm: widget.viewModel.distanceFor(branch),
            travelMinutes: widget.viewModel.travelMinutesFor(branch),
            travelMode: widget.viewModel.travelMode,
            onTap: branch.isOpen
                ? () => widget.onBranchSelected(
                    context,
                    branch,
                    widget.viewModel.travelMinutesFor(branch),
                  )
                : null,
          );
        },
      ),
    };
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    required this.distanceKm,
    required this.travelMinutes,
    required this.travelMode,
    required this.onTap,
  });

  final Branch branch;
  final double distanceKm;
  final int travelMinutes;
  final TravelMode travelMode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      branch.organizationName,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _StatusBadge(isOpen: branch.isOpen),
                ],
              ),
              const SizedBox(height: 4),
              Text('${branch.name} • ${branch.address}'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 20,
                runSpacing: 8,
                children: [
                  _Metric(
                    icon: Icons.near_me_outlined,
                    label: '${distanceKm.toStringAsFixed(1)} كم',
                  ),
                  _Metric(
                    icon: travelMode == TravelMode.walking
                        ? Icons.directions_walk
                        : Icons.directions_car_outlined,
                    label: '$travelMinutes دقيقة للوصول',
                  ),
                  _Metric(
                    icon: Icons.groups_outlined,
                    label: '${branch.peopleWaiting} منتظرين',
                  ),
                  _Metric(
                    icon: Icons.schedule,
                    label: branch.isOpen
                        ? '${branch.estimatedWaitMinutes} دقيقة تقريبًا'
                        : 'الحجز متوقف',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TravelModeFilter extends StatelessWidget {
  const _TravelModeFilter({
    required this.selectedMode,
    required this.onSelected,
  });

  final TravelMode selectedMode;
  final ValueChanged<TravelMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TravelMode>(
      segments: const [
        ButtonSegment(
          value: TravelMode.walking,
          icon: Icon(Icons.directions_walk),
          label: Text('مشي'),
        ),
        ButtonSegment(
          value: TravelMode.driving,
          icon: Icon(Icons.directions_car_outlined),
          label: Text('سيارة'),
        ),
      ],
      selected: {selectedMode},
      onSelectionChanged: (selection) => onSelected(selection.first),
      showSelectedIcon: false,
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colors.primary, colors.tertiary]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: colors.onPrimary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.confirmation_number_outlined,
            size: 48,
            color: colors.onPrimary,
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        isOpen ? 'مفتوح' : 'مغلق',
        style: TextStyle(color: color.shade700, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
