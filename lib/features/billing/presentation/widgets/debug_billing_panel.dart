import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/features/billing/providers/debug_billing_provider.dart';

/// Debug billing panel for development and testing
class DebugBillingPanel extends ConsumerStatefulWidget {
  const DebugBillingPanel({Key? key}) : super(key: key);

  @override
  ConsumerState<DebugBillingPanel> createState() => _DebugBillingPanelState();
}

class _DebugBillingPanelState extends ConsumerState<DebugBillingPanel> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _creditsController = TextEditingController();
  final TextEditingController _operationTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _creditsController.text = '100';
    _operationTypeController.text = 'message';
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _creditsController.dispose();
    _operationTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!DebugConfig.isDebugMode) {
      return const SizedBox.shrink();
    }

    final debugState = ref.watch(debugBillingProvider);
    final debugNotifier = ref.read(debugBillingProvider.notifier);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Icon(
                  Icons.bug_report,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Debug Billing Panel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (debugState.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Error display
            if (debugState.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        debugState.error!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => debugNotifier.clearError(),
                    ),
                  ],
                ),
              ),
            
            if (debugState.error != null) const SizedBox(height: 16),
            
            // Backend status success
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Debug endpoints are now available! Backend billing system is working.',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Credit management section
            _buildSectionTitle('Credit Management'),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userIdController,
                    decoration: const InputDecoration(
                      labelText: 'User ID',
                      hintText: 'Enter user ID',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _creditsController,
                    decoration: const InputDecoration(
                      labelText: 'Credits',
                      hintText: 'Enter credits',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: debugState.isLoading ? null : () => _seedCredits(debugNotifier),
                    icon: const Icon(Icons.add_circle, size: 16),
                    label: const Text('Seed Credits'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: debugState.isLoading ? null : () => _topUpCredits(debugNotifier),
                    icon: const Icon(Icons.trending_up, size: 16),
                    label: const Text('Top Up'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: debugState.isLoading ? null : () => _simulatePurchase(debugNotifier),
                    icon: const Icon(Icons.shopping_cart, size: 16),
                    label: const Text('Simulate Purchase'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: debugState.isLoading ? null : () => _resetBilling(debugNotifier),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reset All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // System information section
            _buildSectionTitle('System Information'),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: debugState.isLoading ? null : () => debugNotifier.loadBillingHealth(),
                    icon: const Icon(Icons.health_and_safety, size: 16),
                    label: const Text('Health Check'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: debugState.isLoading ? null : () => debugNotifier.loadBillingMode(),
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Billing Mode'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Operation testing section
            _buildSectionTitle('Operation Testing'),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _operationTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Operation Type',
                      hintText: 'e.g., message, chat, upload',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: debugState.isLoading ? null : () => _checkOperation(debugNotifier),
                  icon: const Icon(Icons.check_circle, size: 16),
                  label: const Text('Check'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }


  Future<void> _seedCredits(DebugBillingNotifier notifier) async {
    final userId = _userIdController.text.trim();
    final credits = int.tryParse(_creditsController.text.trim()) ?? 0;
    
    if (userId.isEmpty) {
      _showSnackBar('Please enter a user ID', Colors.red);
      return;
    }
    
    if (credits <= 0) {
      _showSnackBar('Please enter a valid credit amount', Colors.red);
      return;
    }
    
    final success = await notifier.seedCredits(userId: userId, credits: credits);
    if (success) {
      _showSnackBar('Credits seeded successfully!', Colors.green);
    } else {
      _showSnackBar('Failed to seed credits', Colors.red);
    }
  }

  Future<void> _topUpCredits(DebugBillingNotifier notifier) async {
    final credits = int.tryParse(_creditsController.text.trim()) ?? 0;
    
    if (credits <= 0) {
      _showSnackBar('Please enter a valid credit amount', Colors.red);
      return;
    }
    
    final success = await notifier.topUpCredits(credits: credits);
    if (success) {
      _showSnackBar('Credits topped up successfully!', Colors.green);
    } else {
      _showSnackBar('Failed to top up credits', Colors.red);
    }
  }

  Future<void> _simulatePurchase(DebugBillingNotifier notifier) async {
    final userId = _userIdController.text.trim();
    final credits = int.tryParse(_creditsController.text.trim()) ?? 0;
    
    if (userId.isEmpty) {
      _showSnackBar('Please enter a user ID', Colors.red);
      return;
    }
    
    if (credits <= 0) {
      _showSnackBar('Please enter a valid credit amount', Colors.red);
      return;
    }
    
    final success = await notifier.simulatePurchase(userId: userId, credits: credits);
    if (success) {
      _showSnackBar('Purchase simulated successfully!', Colors.green);
    } else {
      _showSnackBar('Failed to simulate purchase', Colors.red);
    }
  }

  Future<void> _resetBilling(DebugBillingNotifier notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Billing Data'),
        content: const Text('Are you sure you want to reset all billing data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await notifier.resetBillingData();
      if (success) {
        _showSnackBar('Billing data reset successfully!', Colors.green);
      } else {
        _showSnackBar('Failed to reset billing data', Colors.red);
      }
    }
  }

  Future<void> _checkOperation(DebugBillingNotifier notifier) async {
    final operationType = _operationTypeController.text.trim();
    
    if (operationType.isEmpty) {
      _showSnackBar('Please enter an operation type', Colors.red);
      return;
    }
    
    await notifier.checkOperation(operationType: operationType);
    _showSnackBar('Operation check completed', Colors.blue);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
