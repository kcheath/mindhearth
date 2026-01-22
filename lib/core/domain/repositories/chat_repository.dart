import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/features/chat/domain/entities/session.dart';
import 'package:mindhearth/features/chat/domain/entities/chat_message.dart';
import 'package:mindhearth/features/chat/domain/entities/communication_item.dart';
import 'package:mindhearth/core/models/unified_chat_models.dart';

abstract class ChatRepository {
  /// Get all chat sessions
  Future<Result<List<Session>>> getSessions({
    int? limit,
    int? offset,
  });

  /// Get a specific session by ID
  Future<Result<Session?>> getSession(String id);

  /// Create a new chat session
  Future<Result<Session>> createSession({
    required String name,
    String? sessionType,
    String? purpose,
  });

  /// Update an existing session
  Future<Result<Session>> updateSession({
    required String id,
    String? name,
    String? sessionType,
    String? purpose,
  });

  /// Delete a session
  Future<Result<void>> deleteSession(String id);

  /// Get messages for a session
  Future<Result<List<ChatMessage>>> getSessionMessages({
    required String sessionId,
    int? limit,
    int? offset,
  });

  /// Send a message to a session
  Future<Result<ChatMessage>> sendMessage({
    required String sessionId,
    required String content,
    String? messageType,
    List<Map<String, String>>? conversationHistory,
  });

  /// Send a streaming message to a session
  Future<Result<Stream<ChatMessage>>> sendStreamingMessage({
    required String sessionId,
    required String content,
    String? messageType,
    List<Map<String, String>>? conversationHistory,
  });

  /// Get communication history for a session
  Future<Result<List<CommunicationItem>>> getCommunicationHistory({
    required String sessionId,
    int? limit,
    int? offset,
  });

  /// Add a communication item
  Future<Result<CommunicationItem>> addCommunicationItem({
    required String sessionId,
    required String content,
    String? itemType,
    Map<String, dynamic>? metadata,
  });

  /// Get session analytics
  Future<Result<Map<String, dynamic>>> getSessionAnalytics(String sessionId);

  /// Archive a session
  Future<Result<void>> archiveSession(String sessionId);

  /// Restore an archived session
  Future<Result<void>> restoreSession(String sessionId);

  // New unified chat methods
  /// Send a unified message with enhanced capabilities
  Future<Result<UnifiedChatResponse>> sendUnifiedMessage({
    required String message,
    String? sessionId,
    ChatMode mode = ChatMode.auto,
    RAGOptions? ragOptions,
    ChatMetadata? metadata,
    List<Map<String, String>>? conversationHistory,
  });

  /// Send a unified streaming message
  Future<Result<Stream<UnifiedChatResponse>>> sendUnifiedStreamingMessage({
    required String message,
    String? sessionId,
    RAGOptions? ragOptions,
    ChatMetadata? metadata,
    List<Map<String, String>>? conversationHistory,
  });

  /// Send batch messages for processing
  Future<Result<List<UnifiedChatResponse>>> sendBatchMessages({
    required List<String> messages,
    String? sessionId,
    RAGOptions? ragOptions,
    ChatMetadata? metadata,
  });

  /// Get unified chat history
  Future<Result<UnifiedChatResponse>> getUnifiedChatHistory({
    required String sessionId,
    int? limit,
    int? offset,
  });
}
