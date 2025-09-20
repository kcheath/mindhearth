import 'package:flutter/material.dart';

/// Reusable empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.action,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Contextual empty state widgets
class ContextualEmptyStateWidget extends StatelessWidget {
  final String context;
  final Widget? action;

  const ContextualEmptyStateWidget({
    super.key,
    required this.context,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final (title, message, icon) = _getContextualEmptyState(this.context);
    
    return EmptyStateWidget(
      title: title,
      message: message,
      icon: icon,
      action: action,
    );
  }

  (String, String, IconData) _getContextualEmptyState(String context) {
    switch (context) {
      case 'chat':
        return (
          'Start a conversation',
          'Share your thoughts, ask questions, or explore your feelings in a safe space.',
          Icons.chat_bubble_outline
        );
      case 'journal':
        return (
          'No journal entries yet',
          'Start documenting your journey by creating your first journal entry.',
          Icons.book_outlined
        );
      case 'billing':
        return (
          'No transactions yet',
          'Your transaction history will appear here once you start using credits.',
          Icons.receipt_outlined
        );
      case 'sessions':
        return (
          'No chat sessions yet',
          'Your chat sessions will appear here once you start conversations.',
          Icons.chat_outlined
        );
      case 'documents':
        return (
          'No documents yet',
          'Upload documents to get started with document processing.',
          Icons.description_outlined
        );
      default:
        return (
          'Nothing here yet',
          'Content will appear here as you use the app.',
          Icons.inbox_outlined
        );
    }
  }
}
