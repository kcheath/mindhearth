import 'package:flutter/material.dart';
import 'package:mindhearth/features/billing/presentation/widgets/debug_billing_panel.dart';

/// Full screen debug billing screen
/// Provides comprehensive debug tools for billing system
class DebugBillingScreen extends StatelessWidget {
  const DebugBillingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.bug_report,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            const Text('Debug Billing Tools'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to Billing',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDebugInfo(context),
            tooltip: 'Debug Information',
          ),
        ],
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: DebugBillingPanel(),
        ),
      ),
    );
  }

  void _showDebugInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Billing Tools'),
        content: const Text(
          'This debug panel provides development tools for testing and managing the billing system. '
          'Use these tools to seed credits, test purchases, and monitor system health.\n\n'
          '⚠️ These tools are only available in debug mode.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
