import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/features/billing/domain/entities/credit_package.dart';
import 'package:mindhearth/features/billing/providers/billing_provider.dart';
import 'package:mindhearth/features/billing/domain/services/iap_service.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'dart:io';

/// Purchase dialog for buying credit packages
/// Provides trauma-informed purchase experience with clear pricing
class PurchaseDialog extends ConsumerStatefulWidget {
  const PurchaseDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<PurchaseDialog> createState() => _PurchaseDialogState();
}

class _PurchaseDialogState extends ConsumerState<PurchaseDialog> {
  CreditPackage? _selectedPackage;
  String _selectedPaymentMethod = 'stripe';
  bool _isProcessing = false;
  bool _iapAvailable = false;
  final IAPService _iapService = IAPService();

  @override
  void initState() {
    super.initState();
    _initializeIAP();
  }

  Future<void> _initializeIAP() async {
    if (Platform.isIOS || Platform.isAndroid) {
      _iapAvailable = await _iapService.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  // Mock credit packages - in production, these would come from the backend
  final List<CreditPackage> _packages = [
    const CreditPackage(
      id: 'starter',
      name: 'Starter Pack',
      description: 'Perfect for getting started on your healing journey',
      credits: 10,
      price: 4.99,
      currency: 'USD',
    ),
    const CreditPackage(
      id: 'healer',
      name: 'Healer Pack',
      description: 'Great value for regular users',
      credits: 25,
      price: 9.99,
      currency: 'USD',
      isPopular: true,
      bonusCredits: 5,
      bonusDescription: '5 bonus credits included!',
    ),
    const CreditPackage(
      id: 'warrior',
      name: 'Warrior Pack',
      description: 'For those committed to deep healing work',
      credits: 60,
      price: 19.99,
      currency: 'USD',
      bonusCredits: 15,
      bonusDescription: '15 bonus credits included!',
    ),
    const CreditPackage(
      id: 'champion',
      name: 'Champion Pack',
      description: 'Maximum value for dedicated healing warriors',
      credits: 150,
      price: 39.99,
      currency: 'USD',
      bonusCredits: 50,
      bonusDescription: '50 bonus credits included!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.add_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Purchase Credits'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Choose a credit package to continue your healing journey. '
                'All transactions are secure and your privacy is protected.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPackageList(),
                      const SizedBox(height: 16),
                      _buildPaymentMethodSelector(),
                      if (_selectedPackage != null) ...[
                        const SizedBox(height: 16),
                        _buildPurchaseSummary(),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageList() {
    return Column(
      children: _packages.map((package) => _buildPackageCard(package)).toList(),
    );
  }

  Widget _buildPackageCard(CreditPackage package) {
    final isSelected = _selectedPackage?.id == package.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: InkWell(
        onTap: () => setState(() => _selectedPackage = package),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Radio<CreditPackage>(
                value: package,
                groupValue: _selectedPackage,
                onChanged: (value) => setState(() => _selectedPackage = value),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          package.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (package.isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'POPULAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      package.description,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          package.valueProposition,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          package.formattedPrice,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    if (package.bonusDescription != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        package.bonusDescription!,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (_iapAvailable) ...[
          _buildPaymentOption('iap', 'In-App Purchase', Icons.smartphone),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: _buildPaymentOption('stripe', 'Credit Card', Icons.credit_card),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPaymentOption('paypal', 'PayPal', Icons.payment),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;
    
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseSummary() {
    if (_selectedPackage == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Package:'),
              Text(
                _selectedPackage!.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Credits:'),
              Text(
                _selectedPackage!.formattedCredits,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:'),
              Text(
                _selectedPackage!.formattedPrice,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isProcessing ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _canPurchase() ? _processPurchase : null,
            child: _isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Purchase ${_selectedPackage?.formattedPrice ?? ''}'),
          ),
        ),
      ],
    );
  }

  bool _canPurchase() {
    return _selectedPackage != null && !_isProcessing;
  }

  Future<void> _processPurchase() async {
    if (_selectedPackage == null) return;
    
    setState(() => _isProcessing = true);
    
    try {
      appLogger.info('Processing purchase', {
        'packageId': _selectedPackage!.id,
        'paymentMethod': _selectedPaymentMethod,
      });
      
      final billingNotifier = ref.read(billingProvider.notifier);
      
      bool success = false;
      
      if (_selectedPaymentMethod == 'iap' && _iapAvailable) {
        // Use in-app purchase
        success = await _iapService.purchaseProduct(_selectedPackage!.id);
      } else {
        // Use traditional payment methods
        success = await billingNotifier.purchaseCredits(
          packageId: _selectedPackage!.id,
          paymentMethod: _selectedPaymentMethod,
        );
      }
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Purchase successful! ${_selectedPackage!.totalCredits} credits added to your account.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh billing data
        await billingNotifier.loadBillingData();
        
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        throw Exception('Purchase failed');
      }
    } catch (e) {
      appLogger.error('Purchase failed', {'error': e.toString()});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
