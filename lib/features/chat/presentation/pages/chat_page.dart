import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindhearth/app/providers/providers.dart';
import 'package:mindhearth/app/widgets/adaptive_navigation.dart';
import 'package:mindhearth/features/chat/widgets/chat_input_bar.dart';
import 'package:mindhearth/features/chat/widgets/chat_message_bubble.dart';
import 'package:mindhearth/core/config/debug_config.dart';
import 'package:mindhearth/core/services/chat_service.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  int _selectedIndex = 0;
  late ChatService _chatService;

  @override
  void initState() {
    super.initState();
    _chatService = ref.read(chatServiceProvider);
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Load existing chat history from backend
    final history = await _chatService.loadChatHistory();
    if (history.isNotEmpty) {
      setState(() {
        _messages.addAll(history);
      });
    } else {
      // Add welcome message if no history
      _addWelcomeMessage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: _getWelcomeMessage(),
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  String _getWelcomeMessage() {
    if (DebugConfig.isDebugMode) {
      return '''Hello! I'm Mindhearth, your trauma-informed AI assistant. I'm here to support you on your healing journey.

🔧 **Debug Mode Active**
- Backend: ${DebugConfig.apiUrl}
- Test User: ${DebugConfig.testEmail}

How can I help you today?''';
    } else {
      return '''Hello! I'm Mindhearth, your trauma-informed AI assistant. I'm here to support you on your healing journey.

I can help you with:
• Processing difficult emotions and experiences
• Developing coping strategies
• Understanding trauma responses
• Building resilience and self-compassion
• Creating a safe space for healing

How can I help you today?''';
    }
  }

  Future<void> _handleSendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    try {
      // Send user message to backend
      final userMessage = await _chatService.sendUserMessage(message);
      if (userMessage != null) {
        setState(() {
          _messages.add(userMessage);
        });

        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        // Get AI response from backend
        final aiMessage = await _chatService.getAIResponse(message);
        if (aiMessage != null) {
          setState(() {
            _messages.add(aiMessage);
            _isLoading = false;
          });

          // Scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send message. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  void _handleToolSelected() {
    // TODO: Implement tool selection logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tool selected - coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onDestinationSelected(int index) {
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
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final safeArea = MediaQuery.of(context).padding;
    
    return AdaptiveNavigation(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Chat messages
              Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyState()
                    : _buildChatList(),
              ),
              
              // Input bar
              ChatInputBar(
                onSendMessage: _handleSendMessage,
                onToolSelected: _handleToolSelected,
                availableTools: ChatTools.defaultTools,
                isLoading: _isLoading,
              ),
              
              // Loading indicator
              if (_isLoading)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Mindhearth is thinking...',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to Mindhearth',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Your trauma-informed AI assistant is here to support your healing journey.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (DebugConfig.isDebugMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Text(
                '🐛 Debug Mode: Connected to real backend',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return ChatMessageBubble(
          message: message.message,
          isUser: message.isUser,
          timestamp: message.timestamp,
          isLoading: message.isLoading,
          onCopy: () {
            // TODO: Implement copy functionality
          },
          onSave: () {
            // TODO: Implement save functionality
          },
          onShare: () {
            // TODO: Implement share functionality
          },
        );
      },
    );
  }
}
