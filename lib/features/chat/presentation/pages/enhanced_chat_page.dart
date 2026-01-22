import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindhearth/app/widgets/adaptive_navigation.dart';
import 'package:mindhearth/features/chat/widgets/enhanced_chat_input_bar.dart';
import 'package:mindhearth/features/chat/widgets/enhanced_chat_message_bubble.dart';
import 'package:mindhearth/features/chat/widgets/chat_app_bar.dart';
import 'package:mindhearth/features/chat/widgets/chat_loading_indicator.dart';
import 'package:mindhearth/features/chat/providers/chat_provider.dart';
import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Enhanced chat page with unified chat functionality and RAG support
class EnhancedChatPage extends ConsumerStatefulWidget {
  const EnhancedChatPage({super.key});

  @override
  ConsumerState<EnhancedChatPage> createState() => _EnhancedChatPageState();
}

class _EnhancedChatPageState extends ConsumerState<EnhancedChatPage> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // The chat provider will automatically initialize
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage(String message) async {
    if (message.trim().isEmpty) return;
    
    final chatNotifier = ref.read(chatProvider.notifier);
    
    // Use unified chat functionality
    await chatNotifier.sendUnifiedMessage(message);
    
    // Scroll to bottom after sending message
    _scrollToBottom();
  }

  Future<void> _handleSendStreamingMessage(String message) async {
    if (message.trim().isEmpty) return;
    
    final chatNotifier = ref.read(chatProvider.notifier);
    
    // Use unified streaming chat functionality
    await chatNotifier.sendUnifiedStreamingMessage(message);
    
    // Scroll to bottom after sending message
    _scrollToBottom();
  }

  Future<void> _startNewSession() async {
    final chatNotifier = ref.read(chatProvider.notifier);
    await chatNotifier.startNewConversation();
  }

  void _toggleRAG(bool enabled) {
    final chatNotifier = ref.read(chatProvider.notifier);
    chatNotifier.toggleRAG(enabled);
  }

  void _showSessionHistory() {
    showDialog(
      context: context,
      builder: (context) => _SessionHistoryDialog(),
    );
  }

  void _showSessionInfo(BuildContext context, chatState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session ID: ${chatState.currentSessionId ?? 'None'}'),
            Text('Messages: ${chatState.messages.length}'),
            Text('RAG Enabled: ${chatState.ragEnabled}'),
            Text('Status: ${chatState.isLoading ? 'Loading' : 'Ready'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getSessionTitle(chatState) {
    if (chatState.currentSessionId != null) {
      return 'Chat Session';
    }
    return 'New Chat';
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final chatNotifier = ref.read(chatProvider.notifier);

    return AdaptiveNavigation(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            context.go('/chat');
            break;
          case 1:
            context.go('/sessions');
            break;
          case 2:
            context.go('/profile');
            break;
        }
      },
      child: Scaffold(
        appBar: ChatAppBar(
          sessionName: _getSessionTitle(chatState),
          onShowHistory: _showSessionHistory,
          onShowSessionInfo: () => _showSessionInfo(context, chatState),
          onStartNewSession: _startNewSession,
        ),
        body: Column(
          children: [
            // Error banner
            if (chatState.error != null)
              ContextualErrorWidget(
                context: 'chat',
                customMessage: chatState.error,
                onRetry: () => chatNotifier.retryLastAction(),
              ),
            
            // Chat content
            Expanded(
              child: _buildChatContent(chatState),
            ),
            
            // Loading indicator
            if (chatState.isLoading)
              ChatLoadingIndicator(
                message: 'Sending your message...',
                isVisible: chatState.isLoading,
              ),
            
            // Enhanced input bar with RAG toggle
            EnhancedChatInputBar(
              onSendMessage: _handleSendMessage,
              isLoading: chatState.isLoading,
              ragEnabled: chatNotifier.ragEnabled,
              onRagToggle: _toggleRAG,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatContent(chatState) {
    if (chatState.error != null && chatState.messages.isEmpty) {
      return ContextualErrorWidget(
        context: 'chat',
        customMessage: chatState.error,
        onRetry: () => ref.read(chatProvider.notifier).retryLastAction(),
      );
    }

    if (chatState.messages.isEmpty) {
      return ContextualEmptyStateWidget(
        context: 'chat',
        action: ElevatedButton.icon(
          onPressed: _startNewSession,
          icon: const Icon(Icons.add),
          label: const Text('Start New Session'),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: EnhancedChatMessageBubble(
            message: message,
            isUser: message.role == 'user',
            timestamp: message.timestamp,
            onShare: () => _handleShare(context, message),
            onCopy: () => _handleCopy(context, message),
          ),
        );
      },
    );
  }

  void _handleShare(BuildContext context, message) {
    // Share functionality is handled in the EnhancedChatMessageBubble
  }

  void _handleCopy(BuildContext context, message) {
    // Copy functionality is handled in the EnhancedChatMessageBubble
  }
}

/// Session history dialog component
class _SessionHistoryDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Session History'),
      content: const Text('Session history feature coming soon!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Contextual error widget
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.red.shade100,
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              customMessage ?? 'An error occurred in $context',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Clear error
            },
          ),
        ],
      ),
    );
  }
}

/// Contextual empty state widget
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation to see messages here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 24),
            action!,
          ],
        ],
      ),
    );
  }
}





