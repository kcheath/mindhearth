import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/core/services/chat_service.dart';
import 'package:mindhearth/features/chat/widgets/chat_message_bubble.dart';
import 'package:mindhearth/core/providers/api_providers.dart';
import 'package:mindhearth/core/utils/logger.dart';

// Chat state class
class ChatState {
  final List<ChatMessage> messages;
  final String? currentSessionId;
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> sessions;
  final bool isStreaming;

  const ChatState({
    this.messages = const [],
    this.currentSessionId,
    this.isLoading = false,
    this.error,
    this.sessions = const [],
    this.isStreaming = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    String? currentSessionId,
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? sessions,
    bool? isStreaming,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      sessions: sessions ?? this.sessions,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

// Chat notifier following Tsukiyo pattern
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;
  StreamSubscription<String>? _streamSubscription;

  ChatNotifier(this._chatService) : super(const ChatState()) {
    _initializeChat();
  }

  // Initialize chat - load sessions and create new session if needed
  Future<void> _initializeChat() async {
    try {
      await loadSessions();
      if (state.currentSessionId == null) {
        await createNewSession();
      }
    } catch (e) {
      appLogger.error('Error initializing chat', {'error': e.toString()});
      state = state.copyWith(error: 'Failed to initialize chat');
    }
  }

  // Load all sessions
  Future<void> loadSessions() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final sessions = await _chatService.getSessions(sessionType: 'conversation');
      
      state = state.copyWith(
        sessions: sessions,
        isLoading: false,
      );
      
      appLogger.info('Loaded ${sessions.length} sessions');
    } catch (e) {
      appLogger.error('Error loading sessions', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load sessions',
      );
    }
  }

  // Create a new session
  Future<void> createNewSession({String? name}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final sessionId = await _chatService.createChatSession(name: name);
      
      if (sessionId != null) {
        state = state.copyWith(
          currentSessionId: sessionId,
          messages: [], // Clear messages for new session
          isLoading: false,
        );
        
        // Reload sessions to include the new one
        await loadSessions();
        
        appLogger.info('Created new session', {'sessionId': sessionId});
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to create new session',
        );
      }
    } catch (e) {
      appLogger.error('Error creating new session', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create new session',
      );
    }
  }

  // Switch to a different session
  Future<void> switchToSession(String sessionId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await _chatService.switchToSession(sessionId);
      
      if (success) {
        // Load chat history for the new session
        await loadChatHistory(sessionId);
        
        state = state.copyWith(
          currentSessionId: sessionId,
          isLoading: false,
        );
        
        appLogger.info('Switched to session', {'sessionId': sessionId});
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to switch to session',
        );
      }
    } catch (e) {
      appLogger.error('Error switching to session', {'sessionId': sessionId, 'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to switch to session',
      );
    }
  }

  // Load chat history for a session
  Future<void> loadChatHistory(String sessionId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final history = await _chatService.getChatHistory(sessionId: sessionId);
      
      // Convert history to ChatMessage objects
      final messages = history.map((comm) {
        return ChatMessage(
          id: comm['id'] as String,
          message: comm['original_content'] as String? ?? '',
          isUser: comm['role'] == 'user',
          timestamp: DateTime.parse(comm['created_at'] as String),
          sessionId: comm['session_id'] as String?,
        );
      }).toList();
      
      // Sort messages by timestamp (oldest first)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );
      
      appLogger.info('Loaded ${messages.length} messages for session', {'sessionId': sessionId});
    } catch (e) {
      appLogger.error('Error loading chat history', {'sessionId': sessionId, 'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load chat history',
      );
    }
  }

  // Save current messages to local storage
  Future<void> _saveMessagesLocally() async {
    if (state.currentSessionId != null && state.messages.isNotEmpty) {
      try {
        final history = state.messages.map((msg) => {
          'id': msg.id,
          'original_content': msg.message,
          'role': msg.isUser ? 'user' : 'assistant',
          'created_at': msg.timestamp.toIso8601String(),
          'session_id': msg.sessionId,
        }).toList();
        
        // Save to local storage
        await _chatService.saveChatHistoryLocally(state.currentSessionId!, history);
      } catch (e) {
        appLogger.error('Error saving messages locally', {'error': e.toString()});
      }
    }
  }

  // Send a message with streaming response
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    try {
      // Add user message immediately
      final userMessage = ChatMessage(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        message: content,
        isUser: true,
        timestamp: DateTime.now(),
        sessionId: state.currentSessionId,
      );
      
      state = state.copyWith(
        messages: [...state.messages, userMessage],
        isStreaming: true,
        error: null,
      );
      
      // Try streaming first
      final stream = await _chatService.sendMessageStream(content);
      
      if (stream != null) {
        // Handle streaming response
        String aiMessageContent = '';
        final aiMessage = ChatMessage(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          message: '',
          isUser: false,
          timestamp: DateTime.now(),
          sessionId: state.currentSessionId,
        );
        
        // Add empty AI message to start
        state = state.copyWith(
          messages: [...state.messages, aiMessage],
        );
        
        // Listen to stream
        _streamSubscription = stream.listen(
          (chunk) {
            aiMessageContent += chunk;
            // Update the last message (AI message) with new content
            final updatedMessages = List<ChatMessage>.from(state.messages);
            if (updatedMessages.isNotEmpty) {
              updatedMessages.last = ChatMessage(
                id: updatedMessages.last.id,
                message: aiMessageContent,
                isUser: false,
                timestamp: updatedMessages.last.timestamp,
                sessionId: updatedMessages.last.sessionId,
              );
              state = state.copyWith(messages: updatedMessages);
            }
          },
          onDone: () {
            state = state.copyWith(isStreaming: false);
            appLogger.info('Streaming completed');
            // Save messages to local storage
            _saveMessagesLocally();
          },
          onError: (error) {
            appLogger.error('Streaming error', {'error': error.toString()});
            state = state.copyWith(
              isStreaming: false,
              error: 'Streaming failed',
            );
          },
        );
      } else {
        // Fallback to standard chat
        await _sendStandardMessage(content);
      }
    } catch (e) {
      appLogger.error('Error sending message', {'error': e.toString()});
      state = state.copyWith(
        isStreaming: false,
        error: 'Failed to send message',
      );
    }
  }

  // Send message using standard (non-streaming) endpoint
  Future<void> _sendStandardMessage(String content) async {
    try {
      final messages = await _chatService.sendMessageAndGetResponse(content);
      
      if (messages != null && messages.length >= 2) {
        // Replace the last message (user message) and add AI response
        final updatedMessages = List<ChatMessage>.from(state.messages);
        if (updatedMessages.isNotEmpty) {
          updatedMessages.removeLast(); // Remove the user message we added
        }
        updatedMessages.addAll(messages); // Add both user and AI messages
        
        state = state.copyWith(
          messages: updatedMessages,
          isStreaming: false,
        );
        
        // Save messages to local storage
        _saveMessagesLocally();
      } else {
        state = state.copyWith(
          isStreaming: false,
          error: 'Failed to get AI response',
        );
      }
    } catch (e) {
      appLogger.error('Error in standard message sending', {'error': e.toString()});
      state = state.copyWith(
        isStreaming: false,
        error: 'Failed to send message',
      );
    }
  }

  // Update session name
  Future<void> updateSessionName(String sessionId, String name) async {
    try {
      final success = await _chatService.updateSessionName(sessionId, name);
      
      if (success) {
        // Update the session in the list
        final updatedSessions = state.sessions.map((session) {
          if (session['id'] == sessionId) {
            return {...session, 'name': name};
          }
          return session;
        }).toList();
        
        state = state.copyWith(sessions: updatedSessions);
        appLogger.info('Updated session name', {'sessionId': sessionId, 'name': name});
      } else {
        state = state.copyWith(error: 'Failed to update session name');
      }
    } catch (e) {
      appLogger.error('Error updating session name', {'sessionId': sessionId, 'error': e.toString()});
      state = state.copyWith(error: 'Failed to update session name');
    }
  }

  // Clear current session
  void clearSession() {
    _streamSubscription?.cancel();
    _chatService.clearSession();
    state = state.copyWith(
      currentSessionId: null,
      messages: [],
      isStreaming: false,
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}

// Provider for ChatNotifier
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final chatService = ref.read(chatServiceProvider);
  return ChatNotifier(chatService);
});
