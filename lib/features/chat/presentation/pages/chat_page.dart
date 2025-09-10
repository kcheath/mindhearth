import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindhearth/app/widgets/adaptive_navigation.dart';
import 'package:mindhearth/features/chat/widgets/chat_input_bar.dart';
import 'package:mindhearth/features/chat/widgets/chat_message_bubble.dart';
import 'package:mindhearth/features/chat/providers/chat_provider.dart';
import 'package:mindhearth/core/config/debug_config.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
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
    showDialog(
      context: context,
      builder: (context) => _SessionHistoryDialog(),
    );
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
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getSessionTitle(chatState)),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: _showSessionHistory,
              tooltip: 'Session History',
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _startNewSession,
              tooltip: 'Start New Session',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings'),
              tooltip: 'Settings',
            ),
          ],
        ),
        body: Column(
          children: [
            // Error banner
            if (chatState.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade100,
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chatState.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => ref.read(chatProvider.notifier).clearError(),
                    ),
                  ],
                ),
              ),
            
            // Chat messages
            Expanded(
              child: chatState.messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: chatState.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatState.messages[index];
                        return ChatMessageBubble(
                          message: message.message,
                          isUser: message.isUser,
                          timestamp: message.timestamp,
                          key: ValueKey(message.id),
                        );
                      },
                    ),
            ),
            
            // Loading indicator
            if (chatState.isLoading || chatState.isStreaming)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      chatState.isStreaming ? 'AI is typing...' : 'Loading...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            
            // Input bar
            ChatInputBar(
              onSendMessage: _handleSendMessage,
              isLoading: chatState.isLoading || chatState.isStreaming,
            ),
          ],
        ),
      ),
    );
  }

  String _getSessionTitle(chatState) {
    if (chatState.currentSessionId != null) {
      try {
        final session = chatState.sessions.firstWhere(
          (s) => s['id'] == chatState.currentSessionId,
        );
        return session['name'] ?? 'Chat Session';
      } catch (e) {
        return 'Chat Session';
      }
    }
    return 'Chat';
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'I\'m here to listen and support you.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionHistoryDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            AppBar(
              title: const Text('Chat History'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: chatState.sessions.isEmpty
                  ? const Center(
                      child: Text('No chat sessions yet'),
                    )
                  : ListView.builder(
                      itemCount: chatState.sessions.length,
                      itemBuilder: (context, index) {
                        final session = chatState.sessions[index];
                        final isCurrentSession = session['id'] == chatState.currentSessionId;
                        
                        return ListTile(
                          title: Text(
                            session['name'] ?? 'Untitled Session',
                            style: TextStyle(
                              fontWeight: isCurrentSession ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            'Created: ${_formatDate(session['created_at'])}',
                          ),
                          trailing: isCurrentSession
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          onTap: () {
                            if (!isCurrentSession) {
                              ref.read(chatProvider.notifier).switchToSession(session['id']);
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}