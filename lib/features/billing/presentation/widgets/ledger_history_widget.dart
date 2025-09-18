import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mindhearth/features/billing/domain/entities/ledger_entry.dart';

/// Ledger history widget with trauma-informed design
/// Shows transaction history with clear, reassuring messaging
class LedgerHistoryWidget extends StatelessWidget {
  final List<LedgerEntry> entries;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRefresh;

  const LedgerHistoryWidget({
    Key? key,
    required this.entries,
    this.isLoading = false,
    this.hasMore = true,
    this.onLoadMore,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A complete record of all your credit transactions. '
                    'This helps you understand your account activity and maintain control over your healing journey.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Entries list
          if (entries.isEmpty && !isLoading)
            SliverToBoxAdapter(
              child: _buildEmptyState(context),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < entries.length) {
                    return _buildEntryTile(context, entries[index]);
                  } else if (hasMore && !isLoading) {
                    // Load more trigger
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      onLoadMore?.call();
                    });
                    return const SizedBox.shrink();
                  } else if (isLoading) {
                    return _buildLoadingTile(context);
                  } else {
                    return _buildEndOfList(context);
                  }
                },
                childCount: entries.length + (hasMore ? 1 : 0) + (isLoading ? 1 : 0),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here once you start using credits. '
            'This is completely normal - everyone starts their healing journey at their own pace.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryTile(BuildContext context, LedgerEntry entry) {
    final isCredit = entry.isCredit;
    final color = isCredit ? Colors.green : Colors.red;
    final icon = isCredit ? Icons.add_circle : Icons.remove_circle;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 20,
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          title: Text(
            entry.typeDescription,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy • h:mm a').format(entry.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (entry.notes != null) ...[
                const SizedBox(height: 4),
                Text(
                  entry.notes!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.formattedDelta,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Balance: ${entry.balanceAfter}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingTile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          title: Text(
            'Loading transactions...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEndOfList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        'You\'ve reached the end of your transaction history. '
        'This shows you have a complete record of your healing journey.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
