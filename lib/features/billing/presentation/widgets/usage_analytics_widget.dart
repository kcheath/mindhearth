import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindhearth/features/billing/domain/providers/usage_analytics_provider.dart';
import 'package:mindhearth/features/billing/domain/entities/credit_consumption.dart';

/// Usage analytics widget
class UsageAnalyticsWidget extends ConsumerWidget {
  final int periodDays;

  const UsageAnalyticsWidget({
    super.key,
    this.periodDays = 30,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(usageAnalyticsProvider);
    final analyticsNotifier = ref.read(usageAnalyticsProvider.notifier);

    // Load analytics on first build
    ref.listen(usageAnalyticsProvider, (previous, next) {
      if (previous == null && next.analytics == null && !next.isLoading) {
        analyticsNotifier.loadAnalytics(periodDays: periodDays);
      }
    });

    if (analyticsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (analyticsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading analytics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              analyticsState.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => analyticsNotifier.refreshAnalytics(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final analytics = analyticsState.analytics;
    if (analytics == null) {
      return const Center(child: Text('No analytics data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, analytics, analyticsNotifier),
          const SizedBox(height: 24),
          _buildSummaryCards(context, analytics),
          const SizedBox(height: 24),
          _buildBreakdownChart(context, analytics),
          const SizedBox(height: 24),
          _buildRecentEntries(context, analytics),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UsageAnalytics analytics, UsageAnalyticsNotifier analyticsNotifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Analytics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Last ${analytics.periodDays} days',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => analyticsNotifier.refreshAnalytics(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh analytics',
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, UsageAnalytics analytics) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            'Total Consumed',
            '${analytics.totalConsumed}',
            Icons.trending_down,
            Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Total Granted',
            '${analytics.totalGranted}',
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Net Usage',
            '${analytics.netUsage}',
            Icons.balance,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownChart(BuildContext context, UsageAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consumption Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...analytics.breakdownByType.entries.map((entry) {
              final percentage = analytics.totalConsumed > 0
                  ? (entry.value / analytics.totalConsumed * 100)
                  : 0.0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        _getTypeDisplayName(entry.key),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTypeColor(entry.key),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.value}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEntries(BuildContext context, UsageAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Entries',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (analytics.recentEntries.isEmpty)
              const Text('No recent entries')
            else
              ...analytics.recentEntries.take(10).map((entry) {
                return _buildEntryItem(context, entry);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryItem(BuildContext context, CreditConsumption entry) {
    final isDebit = entry.delta < 0;
    final color = isDebit ? Colors.red : Colors.green;
    
    return ListTile(
      leading: Icon(
        isDebit ? Icons.remove : Icons.add,
        color: color,
      ),
      title: Text(
        _getTypeDisplayName(entry.type),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
        entry.notes ?? 'No description',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${entry.delta > 0 ? '+' : ''}${entry.delta}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Balance: ${entry.balanceAfter}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'chat_debit':
        return 'Chat Usage';
      case 'session_usage':
        return 'Session Time';
      case 'doc_debit':
        return 'Document Processing';
      case 'ai_summary_debit':
        return 'AI Summary';
      case 'purchase':
        return 'Credit Purchase';
      case 'grant':
        return 'Credit Grant';
      case 'gift_in':
        return 'Gift Received';
      case 'gift_out':
        return 'Gift Sent';
      case 'adjustment':
        return 'Manual Adjustment';
      case 'carry_deduction':
        return 'Carryover Deduction';
      default:
        return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'chat_debit':
        return Colors.blue;
      case 'session_usage':
        return Colors.orange;
      case 'doc_debit':
        return Colors.purple;
      case 'ai_summary_debit':
        return Colors.teal;
      case 'purchase':
        return Colors.green;
      case 'grant':
        return Colors.amber;
      case 'gift_in':
        return Colors.cyan;
      case 'gift_out':
        return Colors.indigo;
      case 'adjustment':
        return Colors.grey;
      case 'carry_deduction':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}
