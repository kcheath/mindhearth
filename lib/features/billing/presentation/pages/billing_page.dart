import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/features/billing/providers/billing_provider.dart';
import 'package:mindhearth/features/billing/presentation/widgets/credit_balance_card.dart';
import 'package:mindhearth/features/billing/presentation/widgets/ledger_history_widget.dart';
import 'package:mindhearth/features/billing/presentation/widgets/purchase_history_widget.dart';
import 'package:mindhearth/features/billing/presentation/widgets/billing_actions_widget.dart';

/// Main billing page with trauma-informed design
/// Provides comprehensive billing information and controls
class BillingPage extends ConsumerStatefulWidget {
  const BillingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends ConsumerState<BillingPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load billing data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(billingProvider.notifier).refreshAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billingState = ref.watch(billingProvider);
    final billingNotifier = ref.read(billingProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing & Credits'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/chat'),
          tooltip: 'Back to Chat',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => billingNotifier.refreshAll(),
            tooltip: 'Refresh billing information',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Overview'),
            Tab(icon: Icon(Icons.history), text: 'Transactions'),
            Tab(icon: Icon(Icons.shopping_cart), text: 'Purchases'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Error banner
          if (billingState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      billingState.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => billingNotifier.clearError(),
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ],
              ),
            ),
          
          // Main content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                _buildOverviewTab(context, billingState, billingNotifier),
                
                // Transactions Tab
                _buildTransactionsTab(context, billingState, billingNotifier),
                
                // Purchases Tab
                _buildPurchasesTab(context, billingState, billingNotifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, billingState, billingNotifier) {
      return Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Credit Balance Card
            Expanded(
              flex: 1,
              child: CreditBalanceCard(
                balance: billingState.balance,
                isLoading: billingState.isLoading,
              ),
            ),
            
            const SizedBox(height: 6),
            
            // Billing Actions
            Expanded(
              flex: 1,
              child: BillingActionsWidget(
                onPurchaseCredits: () => _showPurchaseDialog(context),
                onGiftCredits: () => _showGiftDialog(context),
                onContactSupport: () => _showSupportDialog(context),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildTransactionsTab(BuildContext context, billingState, billingNotifier) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: LedgerHistoryWidget(
        entries: billingState.ledgerEntries,
        isLoading: billingState.isLoading,
        hasMore: billingState.hasMoreLedger,
        onLoadMore: () => billingNotifier.loadLedger(),
        onRefresh: () => billingNotifier.loadLedger(refresh: true),
      ),
    );
  }

  Widget _buildPurchasesTab(BuildContext context, billingState, billingNotifier) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: PurchaseHistoryWidget(
        purchases: billingState.purchases,
        isLoading: billingState.isLoading,
        hasMore: billingState.hasMorePurchases,
        onLoadMore: () => billingNotifier.loadPurchases(),
        onRefresh: () => billingNotifier.loadPurchases(refresh: true),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Credits'),
        content: const Text(
          'Purchase credits to continue your healing journey. '
          'All transactions are secure and your privacy is protected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement purchase flow
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Purchase flow coming soon!'),
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showGiftDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gift Credits'),
        content: const Text(
          'Share the gift of healing with someone you care about. '
          'Gift credits to help them on their journey.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement gift flow
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gift flow coming soon!'),
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text(
          'We\'re here to help with any billing questions or concerns. '
          'Your privacy and security are our top priorities.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement support flow
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Support flow coming soon!'),
                ),
              );
            },
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }
}
