import 'package:flutter/material.dart';

/// Reusable loading widget with different states
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final bool showMessage;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Loading widget for specific contexts
class ContextualLoadingWidget extends StatelessWidget {
  final String context;
  final String? customMessage;

  const ContextualLoadingWidget({
    super.key,
    required this.context,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final message = customMessage ?? _getContextualMessage();
    return LoadingWidget(message: message);
  }

  String _getContextualMessage() {
    switch (context) {
      case 'chat':
        return 'Sending your message...';
      case 'journal':
        return 'Saving your entry...';
      case 'billing':
        return 'Loading account information...';
      case 'onboarding':
        return 'Setting up your account...';
      case 'ai_summary':
        return 'Generating AI summary...';
      case 'redaction':
        return 'Processing content...';
      default:
        return 'Loading...';
    }
  }
}
