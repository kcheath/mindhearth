import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindhearth/app/widgets/adaptive_navigation.dart';
import 'package:mindhearth/features/chat/widgets/chat_input_bar.dart';
import 'package:mindhearth/features/chat/widgets/chat_app_bar.dart';
import 'package:mindhearth/features/chat/widgets/chat_message_list.dart';
import 'package:mindhearth/features/chat/widgets/chat_loading_indicator.dart';
import 'package:mindhearth/features/chat/providers/chat_provider.dart';
import 'package:mindhearth/core/widgets/error_widget.dart';
import 'package:mindhearth/core/widgets/empty_state_widget.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Refactored chat page using reusable components
class ChatPageRefactored extends ConsumerStatefulWidget {
  const ChatPageRefactored({super.key});

  @override
  ConsumerState<ChatPageRefactored> createState() => _ChatPageRefactoredState();
}

class _ChatPageRefactoredState extends ConsumerState<ChatPageRefactored> {
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
    await chatNotifier.sendMessage(message);
    
    // Scroll to bottom after sending message
    _scrollToBottom();
  }

  Future<void> _startNewSession() async {
    final chatNotifier = ref.read(chatProvider.notifier);
    
    // Show confirmation dialog if there are messages
    if (ref.read(chatProvider).messages.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Start New Session'),
          content: const Text('Are you sure you want to start a new chat session? Your current conversation will be saved.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Start New'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
    }
    
    await chatNotifier.createNewSession();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New session started')),
      );
    }
  }

  void _showSessionHistory() {
    appLogger.debug('Showing session history dialog');
    showDialog(
      context: context,
      builder: (context) => _SessionHistoryDialog(
        onRenameSession: (session) => _showSessionInfoFromHistory(context, session),
      ),
    );
  }

  void _showSessionInfo(BuildContext context, chatState) async {
    if (chatState.currentSessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active session to view information')),
      );
      return;
    }

    final sessionName = _getSessionTitle(chatState);
    final result = await context.push('/session-info/${chatState.currentSessionId}', extra: {
      'sessionName': sessionName,
    });
    
    // Handle the result from session info page
    if (result != null) {
      if (result == true) {
        // Success - session was deleted and last session loaded
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session deleted and last session loaded')),
        );
      } else if (result is String) {
        // Error - show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete session: $result')),
        );
      }
    }
  }

  void _showSessionInfoFromHistory(BuildContext context, Map<String, dynamic> session) async {
    final result = await context.push('/session-info/${session['id']}', extra: {
      'sessionName': session['name'] ?? 'Untitled Session',
    });
    
    // Handle the result from session info page
    if (result != null) {
      if (result == true) {
        // Success - session was deleted and last session loaded
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session deleted and last session loaded')),
        );
      } else if (result is String) {
        // Error - show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete session: $result')),
        );
      }
    }
  }

  String _getSessionTitle(chatState) {
    if (chatState.currentSessionId == null) {
      return 'Chat';
    }
    
    final session = chatState.sessions.firstWhere(
      (s) => s['id'] == chatState.currentSessionId,
      orElse: () => {'name': 'Untitled Session'},
    );
    
    return session['name'] ?? 'Untitled Session';
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    
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
            context.go('/journal');
            break;
          case 3:
            context.go('/documents');
            break;
          case 4:
            context.go('/reports');
            break;
          case 5:
            context.go('/billing');
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
                onRetry: () => ref.read(chatProvider.notifier).retryLastAction(),
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
            
            // Input bar
            ChatInputBar(
              onSendMessage: _handleSendMessage,
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

    return ChatMessageList(
      scrollController: _scrollController,
      onScrollToBottom: _scrollToBottom,
    );
  }
}

/// Session history dialog component
class _SessionHistoryDialog extends StatelessWidget {
  final Function(Map<String, dynamic>) onRenameSession;

  const _SessionHistoryDialog({
    required this.onRenameSession,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Session History'),
      content: const Text('Session history functionality will be implemented here.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
