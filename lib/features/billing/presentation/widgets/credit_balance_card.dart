import 'package:flutter/material.dart';
import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/features/billing/presentation/widgets/debug_billing_panel.dart';

/// Credit balance card with trauma-informed design
/// Shows current balance with clear, reassuring messaging
class CreditBalanceCard extends StatelessWidget {
  final int balance;
  final bool isLoading;

  const CreditBalanceCard({
    Key? key,
    required this.balance,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Balance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                // Debug icon (only in debug mode)
                if (DebugConfig.isDebugMode)
                  IconButton(
                    icon: Icon(
                      Icons.bug_report,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                    onPressed: () => _showDebugPanel(context),
                    tooltip: 'Debug Billing Tools',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  balance.toString(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'credits',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getBalanceColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getBalanceColor(context).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getBalanceIcon(),
                    size: 16,
                    color: _getBalanceColor(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getBalanceMessage(),
                    style: TextStyle(
                      color: _getBalanceColor(context),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _getCompactMessage(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBalanceColor(BuildContext context) {
    if (balance >= 100) {
      return Colors.green;
    } else if (balance >= 50) {
      return Colors.orange;
    } else if (balance >= 10) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  IconData _getBalanceIcon() {
    if (balance >= 100) {
      return Icons.check_circle;
    } else if (balance >= 50) {
      return Icons.warning;
    } else if (balance >= 10) {
      return Icons.info;
    } else {
      return Icons.error;
    }
  }

  String _getBalanceMessage() {
    if (balance >= 100) {
      return 'Healthy Balance';
    } else if (balance >= 50) {
      return 'Good Balance';
    } else if (balance >= 10) {
      return 'Low Balance';
    } else {
      return 'Very Low Balance';
    }
  }

  String _getCompactMessage() {
    if (balance >= 100) {
      return 'Healthy balance - continue your healing journey with confidence.';
    } else if (balance >= 50) {
      return 'Good balance - you have enough credits to continue.';
    } else if (balance >= 10) {
      return 'Low balance - consider purchasing more credits or wait for your monthly grant.';
    } else {
      return 'Very low balance - purchase credits or wait for your monthly grant. We\'re here to support you.';
    }
  }

  void _showDebugPanel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: const DebugBillingPanel(),
        ),
      ),
    );
  }
}
