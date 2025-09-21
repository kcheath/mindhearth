import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/features/chat/domain/entities/chat_message.dart';
import 'package:mindhearth/core/providers/usecase_providers.dart';
import 'package:mindhearth/core/providers/session_provider.dart';
import 'package:mindhearth/core/models/session_state.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/features/billing/domain/providers/session_question_provider.dart';

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

// Chat notifier with constructor injection
class ChatNotifier extends StateNotifier<ChatState> {
  final GetSessionsUseCase _getSessionsUseCase;
  final CreateSessionUseCase _createSessionUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final SendStreamingMessageUseCase _sendStreamingMessageUseCase;
  final LoadChatHistoryUseCase _loadChatHistoryUseCase;
  final Ref _ref;
  StreamSubscription<String>? _streamSubscription;

  ChatNotifier({
    required GetSessionsUseCase getSessionsUseCase,
    required CreateSessionUseCase createSessionUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required SendStreamingMessageUseCase sendStreamingMessageUseCase,
    required LoadChatHistoryUseCase loadChatHistoryUseCase,
    required Ref ref,
  }) : _getSessionsUseCase = getSessionsUseCase,
       _createSessionUseCase = createSessionUseCase,
       _sendMessageUseCase = sendMessageUseCase,
       _sendStreamingMessageUseCase = sendStreamingMessageUseCase,
       _loadChatHistoryUseCase = loadChatHistoryUseCase,
       _ref = ref,
       super(const ChatState()) {
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
      
      final result = await _getSessionsUseCase();
      
      if (result.isSuccess) {
        final sessions = result.data!.map((session) => {
          'id': session.id,
          'name': session.name,
          'session_type': session.sessionType,
          'purpose': session.purpose,
          'created_at': session.createdAt.toIso8601String(),
          'updated_at': session.updatedAt.toIso8601String(),
        }).toList();
        
        state = state.copyWith(
          sessions: sessions,
          isLoading: false,
        );
        
        appLogger.info('Loaded ${sessions.length} sessions');
      } else {
        throw Exception(result.error?.message ?? 'Failed to load sessions');
      }
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
      
      final result = await _createSessionUseCase(name: name ?? 'New Chat');
      
      if (result.isSuccess) {
        final session = result.data!;
        state = state.copyWith(
          currentSessionId: session.id,
          messages: [], // Clear messages for new session
          isLoading: false,
        );
        
        // Reload sessions to include the new one
        await loadSessions();
        
        appLogger.info('Created new session', {'sessionId': session.id});
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to create new session',
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
      appLogger.info('Starting session switch', {'sessionId': sessionId});
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await _chatService.switchToSession(sessionId);
      appLogger.info('Session switch result', {'sessionId': sessionId, 'success': success});
      
      if (success) {
        // Update the current session ID in the state first
        state = state.copyWith(currentSessionId: sessionId);
        appLogger.info('Updated current session ID in state', {'sessionId': sessionId});
        
        // Load chat history for the new session
        appLogger.info('About to load chat history', {'sessionId': sessionId});
        await loadChatHistory(sessionId);
        appLogger.info('Finished loading chat history', {'sessionId': sessionId});
        
        // Ensure loading is set to false
        state = state.copyWith(isLoading: false);
        
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
      appLogger.info('Starting to load chat history', {'sessionId': sessionId});
      
      final history = await _chatService.getChatHistory(sessionId: sessionId);
      
      appLogger.info('Received chat history from service', {'sessionId': sessionId, 'historyCount': history.length});
      
      // Convert history to ChatMessage objects
      final messages = history.map((comm) {
        return ChatMessage(
          id: comm['id'] as String,
          sessionId: comm['session_id'] as String? ?? '',
          content: comm['original_content'] as String? ?? '',
          role: comm['role'] as String? ?? 'user',
          timestamp: DateTime.parse(comm['created_at'] as String),
        );
      }).toList();
      
      // Sort messages by timestamp (oldest first)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      state = state.copyWith(
        messages: messages,
        error: null,
      );
      
      appLogger.info('Loaded ${messages.length} messages for session', {'sessionId': sessionId});
    } catch (e) {
      appLogger.error('Error loading chat history', {'sessionId': sessionId, 'error': e.toString()});
      state = state.copyWith(
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
          'original_content': msg.content,
          'role': msg.role,
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
        sessionId: state.currentSessionId ?? '',
        content: content,
        role: 'user',
        timestamp: DateTime.now(),
      );
      
      state = state.copyWith(
        messages: [...state.messages, userMessage],
        isStreaming: true,
        error: null,
      );
      
      // Track question for session question billing
      await _trackQuestionForBilling();
      
      // Try streaming first (using use case)
      final streamResult = await _sendStreamingMessageUseCase(content, state.currentSessionId ?? '');
      
      if (streamResult.isSuccess) {
        final stream = streamResult.data!;
        // Handle streaming response
        String aiMessageContent = '';
        final aiMessage = ChatMessage(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          sessionId: state.currentSessionId ?? '',
          content: '',
          role: 'assistant',
          timestamp: DateTime.now(),
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
                sessionId: updatedMessages.last.sessionId,
                content: aiMessageContent,
                role: 'assistant',
                timestamp: updatedMessages.last.timestamp,
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
      final result = await _sendMessageUseCase(content, state.currentSessionId ?? '');
      
      if (result.isSuccess) {
        final message = result.data!;
        // Add the AI response message
        final updatedMessages = List<ChatMessage>.from(state.messages);
        if (updatedMessages.isNotEmpty) {
          updatedMessages.removeLast(); // Remove the user message we added
        }
        updatedMessages.add(message); // Add the AI response
        
        state = state.copyWith(
          messages: updatedMessages,
          isStreaming: false,
        );
      } else {
        throw Exception(result.error?.message ?? 'Failed to send message');
      }
      
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

  // Track question for session question billing
  Future<void> _trackQuestionForBilling() async {
    try {
      if (state.currentSessionId != null) {
        // Get the session question provider and add 1 question
        final sessionQuestionNotifier = _ref.read(sessionQuestionProvider.notifier);
        await sessionQuestionNotifier.addQuestions(1, sessionId: state.currentSessionId);
        
        appLogger.info('Tracked question for billing', {
          'sessionId': state.currentSessionId,
          'questions': 1,
        });
      }
    } catch (e) {
      appLogger.error('Failed to track question for billing', {
        'error': e.toString(),
        'sessionId': state.currentSessionId,
      });
    }
  }

  // Clear error
  // Update session name
  Future<void> updateSessionName(String sessionId, String newName) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await _chatService.updateSessionName(sessionId, newName);
      
      if (success) {
        // Reload sessions to get the updated name
        await loadSessions();
        
        state = state.copyWith(
          isLoading: false,
        );
        
        appLogger.info('Updated session name', {'sessionId': sessionId, 'newName': newName});
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to update session name',
        );
      }
    } catch (e) {
      appLogger.error('Error updating session name', {'sessionId': sessionId, 'newName': newName, 'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update session name',
      );
    }
  }

  // Delete session
  Future<void> deleteSession(String sessionId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final success = await _chatService.deleteSession(sessionId);
      
      if (success) {
        // Reload sessions to get the updated list
        await loadSessions();
        
        // If this was the current session, restart the chat screen as if just logged in
        if (state.currentSessionId == sessionId) {
          // Clear all messages and create a fresh session
          state = state.copyWith(
            messages: [],
            currentSessionId: null,
            error: null,
          );
          await createNewSession();
        }
        
        state = state.copyWith(
          isLoading: false,
        );
        
        appLogger.info('Deleted session', {'sessionId': sessionId});
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to delete session',
        );
      }
    } catch (e) {
      appLogger.error('Error deleting session', {'sessionId': sessionId, 'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete session',
      );
    }
  }

  // Load the most recent session
  Future<void> loadLastSession() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Get all sessions
      await loadSessions();
      
      if (state.sessions.isNotEmpty) {
        // Find the most recent session (by created_at date)
        final sortedSessions = List<Map<String, dynamic>>.from(state.sessions);
        sortedSessions.sort((a, b) {
          final aDate = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
          final bDate = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
          return bDate.compareTo(aDate); // Most recent first
        });
        
        final lastSession = sortedSessions.first;
        final sessionId = lastSession['id'] as String;
        
        // Switch to the last session
        await switchToSession(sessionId);
        
        appLogger.info('Loaded last session', {'sessionId': sessionId});
      } else {
        // No sessions available, create a new one
        await createNewSession();
        appLogger.info('No sessions available, created new session');
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      appLogger.error('Error loading last session', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load last session',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Get current session
  Session? get currentSession {
    if (state.currentSessionId != null) {
      // Find session in sessions list
      final sessionData = state.sessions.firstWhere(
        (session) => session['id'] == state.currentSessionId,
        orElse: () => {},
      );
      if (sessionData.isNotEmpty) {
        return Session.fromJson(sessionData);
      }
    }
    return null;
  }

  // Retry the last action (resend last message)
  Future<void> retryLastAction() async {
    if (state.messages.isNotEmpty) {
      final lastMessage = state.messages.last;
      if (lastMessage.role == 'user') {
        // Resend the last user message
        await sendMessage(lastMessage.content);
      }
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}

// Provider for ChatNotifier with constructor injection
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final chatNotifier = ChatNotifier(
    getSessionsUseCase: ref.read(getSessionsUseCaseProvider),
    createSessionUseCase: ref.read(createSessionUseCaseProvider),
    sendMessageUseCase: ref.read(sendMessageUseCaseProvider),
    sendStreamingMessageUseCase: ref.read(sendStreamingMessageUseCaseProvider),
    loadChatHistoryUseCase: ref.read(loadChatHistoryUseCaseProvider),
    ref: ref,
  );
  
  // Listen to session changes from SessionNotifier
  ref.listen<SessionState>(sessionNotifierProvider, (previous, next) {
    final previousSessionId = previous?.currentSession?.id;
    final nextSessionId = next.currentSession?.id;
    
    // If session changed, load chat history for the new session
    if (previousSessionId != nextSessionId && nextSessionId != null) {
      appLogger.info('Session changed via SessionNotifier', {
        'previousSessionId': previousSessionId,
        'nextSessionId': nextSessionId,
      });
      
      // Switch to the new session in ChatNotifier
      chatNotifier.switchToSession(nextSessionId);
    }
  });
  
  return chatNotifier;
});
