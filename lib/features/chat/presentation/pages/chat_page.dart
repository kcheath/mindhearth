import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindhearth/app/widgets/adaptive_navigation.dart';
import 'package:mindhearth/features/chat/widgets/chat_input_bar.dart';
import 'package:mindhearth/features/chat/widgets/chat_message_bubble.dart';
import 'package:mindhearth/features/chat/providers/chat_provider.dart';
import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/core/utils/logger.dart';

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
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showSessionInfo(context, chatState),
              tooltip: 'Session Information',
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
              sessionId: chatState.currentSessionId,
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
  final Function(Map<String, dynamic>) onRenameSession;
  
  const _SessionHistoryDialog({
    Key? key,
    required this.onRenameSession,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    
    appLogger.debug('SessionHistoryDialog building', {
      'sessionsCount': chatState.sessions.length,
      'currentSessionId': chatState.currentSessionId,
    });
    
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
                        
                        // Debug logging
                        appLogger.debug('Session comparison', {
                          'sessionId': session['id'],
                          'currentSessionId': chatState.currentSessionId,
                          'isCurrentSession': isCurrentSession,
                        });
                        
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCurrentSession)
                                const Icon(Icons.check_circle, color: Colors.green),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  switch (value) {
                     case 'rename':
                       // Navigate to session info page
                       Navigator.pop(context); // Close session history dialog
                       onRenameSession(session);
                       break;
                                    case 'delete':
                                      _showDeleteDialog(context, ref, session);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'rename',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Rename'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            appLogger.debug('Session tapped', {
                              'sessionId': session['id'],
                              'isCurrentSession': isCurrentSession,
                            });
                            
                            // Always switch to the tapped session and close dialog
                            appLogger.debug('Calling switchToSession', {'sessionId': session['id']});
                            ref.read(chatProvider.notifier).switchToSession(session['id']);
                            Navigator.pop(context);
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

  void _showRenameDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> session) {
    final TextEditingController nameController = TextEditingController(
      text: session['name'] ?? 'Untitled Session',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Session'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Session Name',
            hintText: 'Enter a name for this conversation',
            border: OutlineInputBorder(),
          ),
          maxLength: 100,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a session name')),
                );
                return;
              }
              if (newName == session['name']) {
                Navigator.pop(context);
                return;
              }

              await ref.read(chatProvider.notifier).updateSessionName(session['id'], newName);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session renamed successfully')),
              );
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text('Are you sure you want to delete "${session['name'] ?? 'Untitled Session'}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(chatProvider.notifier).deleteSession(session['id']);
                Navigator.pop(context);
                
                // Show success message on the parent context (chat screen)
                // This avoids the widget lifecycle issue
                Future.delayed(const Duration(milliseconds: 100), () {
                  final rootContext = Navigator.of(context, rootNavigator: true).context;
                  if (rootContext.mounted) {
                    ScaffoldMessenger.of(rootContext).showSnackBar(
                      const SnackBar(content: Text('Session deleted successfully')),
                    );
                  }
                });
              } catch (e) {
                Navigator.pop(context);
                
                // Show error message on the parent context
                Future.delayed(const Duration(milliseconds: 100), () {
                  final rootContext = Navigator.of(context, rootNavigator: true).context;
                  if (rootContext.mounted) {
                    ScaffoldMessenger.of(rootContext).showSnackBar(
                      SnackBar(content: Text('Failed to delete session: $e')),
                    );
                  }
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}