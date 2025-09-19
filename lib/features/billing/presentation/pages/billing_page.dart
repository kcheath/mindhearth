import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/features/billing/providers/billing_provider.dart';
import 'package:mindhearth/features/billing/presentation/widgets/credit_balance_card.dart';
import 'package:mindhearth/features/billing/presentation/widgets/ledger_history_widget.dart';
import 'package:mindhearth/features/billing/presentation/widgets/purchase_history_widget.dart';
import 'package:mindhearth/features/billing/presentation/widgets/billing_actions_widget.dart';
import 'package:mindhearth/features/billing/presentation/widgets/purchase_dialog.dart';
import 'package:mindhearth/features/billing/presentation/widgets/gift_dialog.dart';
import 'package:mindhearth/features/billing/presentation/widgets/support_dialog.dart';
import 'package:mindhearth/features/billing/presentation/widgets/debug_billing_panel.dart';
import 'package:mindhearth/core/config/debug_config.dart';

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
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Debug panel (only in debug mode)
            if (DebugConfig.isDebugMode) ...[
              const DebugBillingPanel(),
              const SizedBox(height: 8),
            ],
            
            // Credit Balance Card - Top 1/3
            Expanded(
              flex: 1,
              child: CreditBalanceCard(
                balance: billingState.balance,
                isLoading: billingState.isLoading,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Billing Actions - Bottom 2/3
            Expanded(
              flex: 2,
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PurchaseDialog(),
        fullscreenDialog: true,
      ),
    );
  }

  void _showGiftDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GiftDialog(),
        fullscreenDialog: true,
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SupportDialog(),
        fullscreenDialog: true,
      ),
    );
  }
}
