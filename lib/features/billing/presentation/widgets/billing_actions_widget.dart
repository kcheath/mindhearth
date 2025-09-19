import 'package:flutter/material.dart';

/// Billing actions widget with trauma-informed design
/// Provides safe, reassuring actions for billing management
class BillingActionsWidget extends StatelessWidget {
  final VoidCallback? onPurchaseCredits;
  final VoidCallback? onGiftCredits;
  final VoidCallback? onContactSupport;

  const BillingActionsWidget({
    Key? key,
    this.onPurchaseCredits,
    this.onGiftCredits,
    this.onContactSupport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Actions',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            _buildActionGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return Column(
      children: [
        // Purchase Credits
        _buildActionTile(
          context,
          icon: Icons.add_circle,
          title: 'Purchase Credits',
          subtitle: 'Buy additional credits to continue your healing journey',
          color: Theme.of(context).colorScheme.primary,
          onTap: onPurchaseCredits,
        ),
        const SizedBox(height: 12),
        
        // Gift Credits
        _buildActionTile(
          context,
          icon: Icons.card_giftcard,
          title: 'Gift Credits',
          subtitle: 'Share the gift of healing with someone you care about',
          color: Colors.purple,
          onTap: onGiftCredits,
        ),
        const SizedBox(height: 12),
        
        // Contact Support
        _buildActionTile(
          context,
          icon: Icons.support_agent,
          title: 'Contact Support',
          subtitle: 'Get help with billing questions or account issues',
          color: Colors.blue,
          onTap: onContactSupport,
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
