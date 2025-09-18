import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mindhearth/features/billing/domain/entities/purchase.dart';

/// Purchase history widget with trauma-informed design
/// Shows purchase history with clear, reassuring messaging
class PurchaseHistoryWidget extends StatelessWidget {
  final List<Purchase> purchases;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRefresh;

  const PurchaseHistoryWidget({
    Key? key,
    required this.purchases,
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
                    'Purchase History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A secure record of all your credit purchases. '
                    'Your payment information is always protected and your privacy is our priority.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Purchases list
          if (purchases.isEmpty && !isLoading)
            SliverToBoxAdapter(
              child: _buildEmptyState(context),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < purchases.length) {
                    return _buildPurchaseTile(context, purchases[index]);
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
                childCount: purchases.length + (hasMore ? 1 : 0) + (isLoading ? 1 : 0),
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
            Icons.shopping_cart_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Purchases Yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your purchase history will appear here once you buy credits. '
            'You can start your healing journey with the free credits we provide, '
            'and purchase more when you\'re ready.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseTile(BuildContext context, Purchase purchase) {
    final statusColor = _getStatusColor(purchase.status);
    final statusIcon = _getStatusIcon(purchase.status);

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
            backgroundColor: statusColor.withOpacity(0.1),
            radius: 20,
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 20,
            ),
          ),
          title: Text(
            purchase.providerDisplayName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy • h:mm a').format(purchase.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Product: ${purchase.productId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      purchase.statusDisplayName,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                purchase.formattedAmount,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Qty: ${purchase.quantity}',
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
            'Loading purchases...',
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
        'You\'ve reached the end of your purchase history. '
        'This shows you have a complete record of your investment in your healing journey.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'failed':
        return Icons.error;
      case 'refunded':
        return Icons.undo;
      default:
        return Icons.help;
    }
  }
}
