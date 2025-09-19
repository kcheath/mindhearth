import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/features/billing/providers/billing_provider.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Gift dialog for sharing credits with others
/// Provides trauma-informed gifting experience with clear value
class GiftDialog extends ConsumerStatefulWidget {
  const GiftDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<GiftDialog> createState() => _GiftDialogState();
}

class _GiftDialogState extends ConsumerState<GiftDialog> {
  final _recipientController = TextEditingController();
  final _messageController = TextEditingController();
  int _selectedAmount = 10;
  bool _isProcessing = false;

  final List<int> _giftAmounts = [5, 10, 25, 50, 100];

  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.card_giftcard,
              color: Colors.purple,
            ),
            const SizedBox(width: 8),
            const Text('Gift Credits'),
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
                'Share the gift of healing with someone you care about. '
                'Help them on their journey to wellness and growth.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildRecipientField(),
                      const SizedBox(height: 16),
                      _buildAmountSelector(),
                      const SizedBox(height: 16),
                      _buildMessageField(),
                      const SizedBox(height: 16),
                      _buildGiftSummary(),
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

  Widget _buildRecipientField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipient Email',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _recipientController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Enter recipient\'s email address',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildAmountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gift Amount',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _giftAmounts.map((amount) => _buildAmountChip(amount)).toList(),
        ),
      ],
    );
  }

  Widget _buildAmountChip(int amount) {
    final isSelected = _selectedAmount == amount;
    
    return FilterChip(
      label: Text('$amount credits'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedAmount = amount);
        }
      },
      selectedColor: Colors.purple.withOpacity(0.2),
      checkmarkColor: Colors.purple,
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Message (Optional)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add a personal message to your gift...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildGiftSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gift Amount:'),
              Text(
                '$_selectedAmount credits',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recipient:'),
              Text(
                _recipientController.text.isEmpty 
                    ? 'Not specified'
                    : _recipientController.text,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (_messageController.text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Message:'),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _messageController.text,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
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
            onPressed: _canGift() ? _processGift : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('Gift $_selectedAmount Credits'),
          ),
        ),
      ],
    );
  }

  bool _canGift() {
    return _recipientController.text.isNotEmpty && 
           _recipientController.text.contains('@') &&
           !_isProcessing;
  }

  Future<void> _processGift() async {
    if (!_canGift()) return;
    
    setState(() => _isProcessing = true);
    
    try {
      appLogger.info('Processing gift', {
        'recipient': _recipientController.text,
        'amount': _selectedAmount,
        'hasMessage': _messageController.text.isNotEmpty,
      });
      
      final billingNotifier = ref.read(billingProvider.notifier);
      
      // In a real implementation, this would call the gift API
      // For now, we'll simulate the gift process
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate successful gift
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gift sent successfully! $_selectedAmount credits sent to ${_recipientController.text}',
          ),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh billing data
      await billingNotifier.loadBillingData();
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      appLogger.error('Gift failed', {'error': e.toString()});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gift failed: ${e.toString()}'),
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
