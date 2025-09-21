import 'package:flutter/material.dart';

/// Reusable error widget with different states
class AppErrorWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool showIcon;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.retryText,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon)
              Icon(
                icon ?? Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
            if (showIcon) const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Contextual error widgets for specific scenarios
class ContextualErrorWidget extends StatelessWidget {
  final String context;
  final String? customMessage;
  final VoidCallback? onRetry;

  const ContextualErrorWidget({
    super.key,
    required this.context,
    this.customMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final (title, message, icon) = _getContextualError(this.context, customMessage);
    
    return AppErrorWidget(
      title: title,
      message: message,
      icon: icon,
      onRetry: onRetry,
    );
  }

  (String, String, IconData) _getContextualError(String context, String? customMessage) {
    if (customMessage != null) {
      return ('Error', customMessage, Icons.error_outline);
    }

    switch (context) {
      case 'network':
        return (
          'Connection Error',
          'Unable to connect to the server. Please check your internet connection and try again.',
          Icons.wifi_off
        );
      case 'chat':
        return (
          'Chat Error',
          'Unable to send your message. Please try again.',
          Icons.chat_bubble_outline
        );
      case 'journal':
        return (
          'Journal Error',
          'Unable to save your entry. Please try again.',
          Icons.book_outlined
        );
      case 'billing':
        return (
          'Billing Error',
          'Unable to load account information. Please try again.',
          Icons.account_balance_wallet
        );
      case 'auth':
        return (
          'Authentication Error',
          'Unable to verify your identity. Please log in again.',
          Icons.lock_outline
        );
      case 'ai_summary':
        return (
          'AI Summary Error',
          'Unable to generate AI summary. Please try again.',
          Icons.psychology_outlined
        );
      default:
        return (
          'Error',
          'Something went wrong. Please try again.',
          Icons.error_outline
        );
    }
  }
}
