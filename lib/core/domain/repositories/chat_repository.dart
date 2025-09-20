import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/features/chat/domain/entities/session.dart';
import 'package:mindhearth/features/chat/domain/entities/chat_message.dart';
import 'package:mindhearth/features/chat/domain/entities/communication_item.dart';

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
  });

  /// Send a streaming message to a session
  Future<Result<Stream<ChatMessage>>> sendStreamingMessage({
    required String sessionId,
    required String content,
    String? messageType,
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
}
