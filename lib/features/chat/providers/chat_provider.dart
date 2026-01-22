import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mindhearth/features/chat/domain/entities/chat_message.dart';
import 'package:mindhearth/core/providers/usecase_providers.dart';
import 'package:mindhearth/core/providers/unified_chat_providers.dart';
import 'package:mindhearth/core/providers/session_provider.dart';
import 'package:mindhearth/core/models/session_state.dart';
import 'package:mindhearth/core/models/unified_chat_models.dart';
import 'package:mindhearth/core/domain/usecases/unified_chat_usecases.dart';
import 'package:mindhearth/core/utils/logger.dart';
import 'package:mindhearth/core/utils/session_validator.dart';
import 'package:mindhearth/features/billing/domain/providers/session_question_provider.dart';
import 'package:mindhearth/core/domain/usecases/chat_usecases.dart';

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
  final GetSessionMessagesUseCase _getSessionMessagesUseCase;
  final UpdateSessionUseCase _updateSessionUseCase;
  final DeleteSessionUseCase _deleteSessionUseCase;
  
  // Unified chat use cases
  final SendUnifiedMessageUseCase _sendUnifiedMessageUseCase;
  final SendUnifiedStreamingMessageUseCase _sendUnifiedStreamingMessageUseCase;
  final CreateRAGOptionsUseCase _createRAGOptionsUseCase;
  final CreateChatMetadataUseCase _createChatMetadataUseCase;
  final SelectChatModeUseCase _selectChatModeUseCase;
  
  final Ref _ref;
  StreamSubscription<ChatMessage>? _streamSubscription;
  StreamSubscription<UnifiedChatResponse>? _unifiedStreamSubscription;
  
  // Conversation history for context-aware AI responses
  List<Map<String, String>> _conversationHistory = [];
  
  // RAG settings
  bool _ragEnabled = true;

  ChatNotifier({
    required GetSessionsUseCase getSessionsUseCase,
    required CreateSessionUseCase createSessionUseCase,
    required GetSessionMessagesUseCase getSessionMessagesUseCase,
    required UpdateSessionUseCase updateSessionUseCase,
    required DeleteSessionUseCase deleteSessionUseCase,
    required SendUnifiedMessageUseCase sendUnifiedMessageUseCase,
    required SendUnifiedStreamingMessageUseCase sendUnifiedStreamingMessageUseCase,
    required CreateRAGOptionsUseCase createRAGOptionsUseCase,
    required CreateChatMetadataUseCase createChatMetadataUseCase,
    required SelectChatModeUseCase selectChatModeUseCase,
    required Ref ref,
  }) : _getSessionsUseCase = getSessionsUseCase,
       _createSessionUseCase = createSessionUseCase,
       _getSessionMessagesUseCase = getSessionMessagesUseCase,
       _updateSessionUseCase = updateSessionUseCase,
       _deleteSessionUseCase = deleteSessionUseCase,
       _sendUnifiedMessageUseCase = sendUnifiedMessageUseCase,
       _sendUnifiedStreamingMessageUseCase = sendUnifiedStreamingMessageUseCase,
       _createRAGOptionsUseCase = createRAGOptionsUseCase,
       _createChatMetadataUseCase = createChatMetadataUseCase,
       _selectChatModeUseCase = selectChatModeUseCase,
       _ref = ref,
       super(const ChatState()) {
    // Delay initialization to prevent connection loss
    Future.delayed(const Duration(milliseconds: 500), () {
    _initializeChat();
    });
  }

  // Initialize chat - load sessions and create new session if needed
  Future<void> _initializeChat() async {
    try {
      appLogger.info('Initializing chat...');
      
      // Only load sessions, don't create new session automatically
      await loadSessions();
      
      appLogger.info('Chat initialization completed with ${state.sessions.length} sessions');
    } catch (e) {
      appLogger.error('Error initializing chat', {'error': e.toString()});
      state = state.copyWith(error: 'Failed to initialize chat');
    }
  }

  // Load all sessions
  Future<void> loadSessions() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Add timeout to prevent hanging
      final result = await _getSessionsUseCase().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Session loading timed out');
        },
      );
      
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
        final errorMessage = result.error?.message ?? 'Failed to load sessions';
        throw Exception(errorMessage);
      }
    } catch (e) {
      appLogger.error('Error loading sessions', {'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load sessions: ${e.toString()}',
      );
    }
  }

  // Create a new session (public method for user-initiated session creation)
  Future<void> createNewSession({String? name}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Add timeout to prevent hanging
      final result = await _createSessionUseCase(name: name ?? 'New Chat').timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Session creation timed out');
        },
      );
      
      if (result.isSuccess) {
        final session = result.data!;
        
        // Add the new session to the existing sessions list instead of reloading
        final newSessionData = {
          'id': session.id,
          'name': session.name,
          'session_type': session.sessionType,
          'purpose': session.purpose,
          'created_at': session.createdAt.toIso8601String(),
          'updated_at': session.updatedAt.toIso8601String(),
        };
        
        state = state.copyWith(
          currentSessionId: session.id,
          messages: [], // Clear messages for new session
          sessions: [...state.sessions, newSessionData],
          isLoading: false,
        );
        
        // Validate the new session ID
        SessionValidator.validateSessionId(session.id, context: 'session_creation');
        
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
        error: 'Failed to create new session: ${e.toString()}',
      );
    }
  }

  // Switch to a different session
  Future<void> switchToSession(String sessionId) async {
    try {
      // Validate session ID format
      if (!SessionValidator.validateSessionId(sessionId, context: 'session_switch')) {
        appLogger.warning('⚠️ Using legacy session ID format', {'sessionId': sessionId});
      }
      
      appLogger.info('🔄 Starting session switch', {'sessionId': sessionId, 'previousSessionId': state.currentSessionId});
      state = state.copyWith(isLoading: true, error: null);
      
      // Switch to session - load its messages
      final result = await _getSessionMessagesUseCase(sessionId: sessionId);
      if (result.isSuccess && result.data != null) {
        final messages = result.data!;
        appLogger.debug('📊 Loaded ${messages.length} messages for session $sessionId');
        
        // Sort messages chronologically (oldest first) for proper conversation flow
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        appLogger.debug('📊 Sorted ${messages.length} messages chronologically');
        
        // Clear conversation history for new session
        _conversationHistory.clear();
        
        // Populate conversation history from loaded messages (already sorted)
        _conversationHistory = messages.map((msg) => {
          'role': msg.role ?? 'user',
          'content': msg.content ?? '',
        }).toList();
        
        appLogger.debug('📊 Populated conversation history with ${_conversationHistory.length} items');
        
        state = state.copyWith(
          currentSessionId: sessionId,
          messages: messages,
          isLoading: false,
        );
        appLogger.info('✅ Session switch successful', {'sessionId': sessionId, 'messageCount': messages.length});
      } else {
        appLogger.error('❌ Session switch failed', {'sessionId': sessionId, 'error': result.error?.message});
        state = state.copyWith(
          isLoading: false,
          error: result.error?.message ?? 'Failed to load session messages',
        );
      }
    } catch (e) {
      appLogger.error('💥 Error switching to session', {'sessionId': sessionId, 'error': e.toString()});
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
      
      final result = await _getSessionMessagesUseCase(sessionId: sessionId);
      if (result.isSuccess) {
        final messages = result.data!;
        appLogger.info('Received chat history from service', {'sessionId': sessionId, 'historyCount': messages.length});
      
      // Sort messages by timestamp (oldest first)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        // Populate conversation history for context-aware responses
        _conversationHistory = messages.map((msg) => {
          'role': msg.role,
          'content': msg.content,
        }).toList();
      
      state = state.copyWith(
        messages: messages,
        error: null,
      );
      
        appLogger.info('Loaded ${messages.length} messages for session and populated conversation history', {'sessionId': sessionId});
      } else {
        appLogger.error('Failed to load chat history', {'sessionId': sessionId, 'error': result.error?.message});
        state = state.copyWith(
          error: result.error?.message ?? 'Failed to load chat history',
        );
      }
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
        // Save messages locally (this is now handled by the state management)
        // No need for separate local storage call
      } catch (e) {
        appLogger.error('Error saving messages locally', {'error': e.toString()});
      }
    }
  }

  // Legacy method - now redirects to unified method for backward compatibility
  Future<void> sendMessage(String content) async {
    // Redirect to unified method for backward compatibility
    await sendUnifiedMessage(content);
  }


  // Unified chat methods
  /// Send a message using the unified chat endpoint with RAG support
  Future<void> sendUnifiedMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    try {
      // Add user message to conversation history
      _conversationHistory.add({
        'role': 'user',
        'content': content,
      });
      
      // Add user message immediately
      final userMessage = ChatMessage(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: state.currentSessionId ?? '',
        content: content,
        role: 'user',
        timestamp: DateTime.now(),
      );
      
      final updatedMessages = List<ChatMessage>.from(state.messages);
      updatedMessages.add(userMessage);
      
      state = state.copyWith(
        messages: updatedMessages,
        isStreaming: true,
        error: null,
      );
      
      // Track question for billing
      await _trackQuestionForBilling();
      
      // Create RAG options and metadata
      final ragOptions = _createRAGOptionsUseCase(
        useRAG: _ragEnabled,
        streaming: true,
        persistMessages: true,
        consent: true,
        contextLimit: 5,
      );
      
      final metadata = _createChatMetadataUseCase(
        purpose: 'chat',
        sessionType: 'conversation',
      );
      
      // Select intelligent chat mode
      final mode = _selectChatModeUseCase(
        message: content,
        useRAG: _ragEnabled,
        streaming: true,
        messageLength: content.length,
      );
      
      // Use unified endpoint
      final result = await _sendUnifiedMessageUseCase(
        message: content,
        sessionId: state.currentSessionId,
        mode: mode,
        ragOptions: ragOptions,
        metadata: metadata,
        conversationHistory: _conversationHistory,
      );
      
      if (result.isSuccess) {
        final unifiedResponse = result.data!;
        
        if (unifiedResponse.success && unifiedResponse.data != null) {
          // Add AI response to conversation history
          _conversationHistory.add({
            'role': 'assistant',
            'content': unifiedResponse.data!.response,
          });
          
          // Create enhanced ChatMessage with RAG data
          final aiMessage = ChatMessage(
            id: unifiedResponse.data!.messageMetadata.messageId,
            sessionId: unifiedResponse.data!.sessionId,
            content: unifiedResponse.data!.response,
            role: 'assistant',
            timestamp: unifiedResponse.data!.messageMetadata.timestamp,
            metadata: {
              'sources': unifiedResponse.data!.sources.map((s) => s.toJson()).toList(),
              'rag_metadata': unifiedResponse.data!.ragMetadata.toJson(),
              'message_metadata': unifiedResponse.data!.messageMetadata.toJson(),
            },
          );
          
          // Add the AI response message
          final updatedMessages = List<ChatMessage>.from(state.messages);
          updatedMessages.add(aiMessage);
          
          state = state.copyWith(
            messages: updatedMessages,
            isStreaming: false,
          );
        } else {
          throw Exception(unifiedResponse.error?.message ?? 'Failed to send message');
        }
      } else {
        final errorMessage = result.error?.message ?? 'Failed to send message';
        throw Exception(errorMessage);
      }
      
      // Save messages to local storage
      _saveMessagesLocally();
    } catch (e) {
      appLogger.error('Error sending unified message', {'error': e.toString()});
      state = state.copyWith(
        isStreaming: false,
        error: 'Failed to send message',
      );
    }
  }
  
  /// Send a streaming message using the unified chat endpoint
  Future<void> sendUnifiedStreamingMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    try {
      // Add user message to conversation history
      _conversationHistory.add({
        'role': 'user',
        'content': content,
      });
      
      // Add user message immediately
      final userMessage = ChatMessage(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: state.currentSessionId ?? '',
        content: content,
        role: 'user',
        timestamp: DateTime.now(),
      );
      
      final updatedMessages = List<ChatMessage>.from(state.messages);
      updatedMessages.add(userMessage);
      
      state = state.copyWith(
        messages: updatedMessages,
        isStreaming: true,
        error: null,
      );
      
      // Create RAG options and metadata
      final ragOptions = _createRAGOptionsUseCase(
        useRAG: _ragEnabled,
        streaming: true,
        persistMessages: true,
        consent: true,
        contextLimit: 5,
      );
      
      final metadata = _createChatMetadataUseCase(
        purpose: 'chat',
        sessionType: 'conversation',
      );
      
      // Use unified streaming endpoint
      final streamResult = await _sendUnifiedStreamingMessageUseCase(
        message: content,
        sessionId: state.currentSessionId,
        ragOptions: ragOptions,
        metadata: metadata,
        conversationHistory: _conversationHistory,
      );
      
      if (streamResult.isSuccess) {
        final stream = streamResult.data!;
        
        // Create empty AI message for streaming
        final aiMessage = ChatMessage(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          sessionId: state.currentSessionId ?? '',
          content: '',
          role: 'assistant',
          timestamp: DateTime.now(),
        );
        
        final updatedMessages = List<ChatMessage>.from(state.messages);
        updatedMessages.add(aiMessage);
        
        state = state.copyWith(messages: updatedMessages);
        
        // Listen to unified stream
        _unifiedStreamSubscription = stream.listen(
          (unifiedResponse) {
            if (unifiedResponse.success && unifiedResponse.data != null) {
              // Update the last message with streaming content
              final updatedMessages = List<ChatMessage>.from(state.messages);
              if (updatedMessages.isNotEmpty) {
                final lastMessage = updatedMessages.last;
                updatedMessages.last = lastMessage.copyWith(
                  content: unifiedResponse.data!.response,
                  metadata: {
                    'sources': unifiedResponse.data!.sources.map((s) => s.toJson()).toList(),
                    'rag_metadata': unifiedResponse.data!.ragMetadata.toJson(),
                    'message_metadata': unifiedResponse.data!.messageMetadata.toJson(),
                  },
                );
                state = state.copyWith(messages: updatedMessages);
              }
            }
          },
          onDone: () {
            // Add AI response to conversation history
            final lastMessage = state.messages.last;
            _conversationHistory.add({
              'role': 'assistant',
              'content': lastMessage.content,
            });
            
            state = state.copyWith(isStreaming: false);
            appLogger.info('Unified streaming completed');
            _saveMessagesLocally();
          },
          onError: (error) {
            appLogger.error('Unified streaming error', {'error': error.toString()});
            state = state.copyWith(
              isStreaming: false,
              error: 'Streaming failed',
            );
          },
        );
      } else {
        // Fallback to standard unified message
        await sendUnifiedMessage(content);
      }
    } catch (e) {
      appLogger.error('Error sending unified streaming message', {'error': e.toString()});
      state = state.copyWith(
        isStreaming: false,
        error: 'Failed to send message',
      );
    }
  }
  
  /// Toggle RAG functionality
  void toggleRAG(bool enabled) {
    _ragEnabled = enabled;
    appLogger.info('RAG toggled', {'enabled': enabled});
  }
  
  /// Get current RAG status
  bool get ragEnabled => _ragEnabled;

  // Clear current session
  void clearSession() {
    _streamSubscription?.cancel();
    // Clear conversation history
    _conversationHistory.clear();
    // Clear session - reset state
    state = state.copyWith(
      currentSessionId: null,
      messages: [],
      isLoading: false,
      isStreaming: false,
      error: null,
    );
  }

  // Start a new conversation (clear conversation history)
  void startNewConversation() {
    _streamSubscription?.cancel();
    // Clear conversation history for context-aware responses
    _conversationHistory.clear();
    // Clear current session and messages
    state = state.copyWith(
      currentSessionId: null,
      messages: [],
      isLoading: false,
      isStreaming: false,
      error: null,
    );
    appLogger.info('Started new conversation - conversation history cleared');
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
      
      final result = await _updateSessionUseCase(
        id: sessionId,
        name: newName,
      );
      final success = result.isSuccess;
      
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
      
      final result = await _deleteSessionUseCase(sessionId);
      final success = result.isSuccess;
      
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
        final errorMessage = result.error?.message ?? 'Failed to delete session';
        state = state.copyWith(
          isLoading: false,
          error: errorMessage,
        );
        appLogger.error('Failed to delete session', {'sessionId': sessionId, 'error': errorMessage});
      }
    } catch (e) {
      final errorMessage = 'Failed to delete session: ${e.toString()}';
      appLogger.error('Error deleting session', {'sessionId': sessionId, 'error': e.toString()});
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
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
        await sendUnifiedMessage(lastMessage.content);
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
    getSessionMessagesUseCase: ref.read(getSessionMessagesUseCaseProvider),
    updateSessionUseCase: ref.read(updateSessionUseCaseProvider),
    deleteSessionUseCase: ref.read(deleteSessionUseCaseProvider),
    sendUnifiedMessageUseCase: ref.read(sendUnifiedMessageUseCaseProvider),
    sendUnifiedStreamingMessageUseCase: ref.read(sendUnifiedStreamingMessageUseCaseProvider),
    createRAGOptionsUseCase: ref.read(createRAGOptionsUseCaseProvider),
    createChatMetadataUseCase: ref.read(createChatMetadataUseCaseProvider),
    selectChatModeUseCase: ref.read(selectChatModeUseCaseProvider),
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
