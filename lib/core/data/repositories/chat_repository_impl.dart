import 'dart:async';
import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/repositories/chat_repository.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/features/chat/domain/entities/session.dart';
import 'package:mindhearth/features/chat/domain/entities/chat_message.dart';
import 'package:mindhearth/features/chat/domain/entities/communication_item.dart';
import 'package:mindhearth/core/utils/logger.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ApiService _apiService;

  ChatRepositoryImpl(this._apiService);

  @override
  Future<Result<List<Session>>> getSessions({
    int? limit,
    int? offset,
  }) async {
    try {
      appLogger.info('💬 Getting chat sessions', extra: {
        'limit': limit,
        'offset': offset,
      });

      final response = await _apiService.get(
        '/sessions/',
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final sessions = (data['sessions'] as List)
            .map((json) => Session.fromJson(json as Map<String, dynamic>))
            .toList();
        appLogger.info('✅ Retrieved ${sessions.length} sessions');
        return Result.success(sessions);
      } else {
        appLogger.error('❌ Failed to get sessions: ${response.error}');
        return Result.failure(response.error ?? 'Failed to get sessions');
      }
    } catch (e) {
      appLogger.error('💥 Exception getting sessions: $e');
      return Result.failure('Failed to get sessions: $e');
    }
  }

  @override
  Future<Result<Session?>> getSession(String id) async {
    try {
      appLogger.info('💬 Getting session: $id');

      final response = await _apiService.get('/sessions/$id');

      if (response.isSuccess) {
        final session = Session.fromJson(response.data as Map<String, dynamic>);
        appLogger.info('✅ Retrieved session: ${session.id}');
        return Result.success(session);
      } else {
        appLogger.error('❌ Failed to get session: ${response.error}');
        return Result.failure(response.error ?? 'Failed to get session');
      }
    } catch (e) {
      appLogger.error('💥 Exception getting session: $e');
      return Result.failure('Failed to get session: $e');
    }
  }

  @override
  Future<Result<Session>> createSession({
    required String name,
    String? sessionType,
    String? purpose,
  }) async {
    try {
      appLogger.info('💬 Creating session', extra: {
        'name': name,
        'sessionType': sessionType,
        'purpose': purpose,
      });

      final response = await _apiService.post(
        '/sessions/',
        data: {
          'name': name,
          if (sessionType != null) 'session_type': sessionType,
          if (purpose != null) 'purpose': purpose,
        },
      );

      if (response.isSuccess) {
        final session = Session.fromJson(response.data as Map<String, dynamic>);
        appLogger.info('✅ Created session: ${session.id}');
        return Result.success(session);
      } else {
        appLogger.error('❌ Failed to create session: ${response.error}');
        return Result.failure(response.error ?? 'Failed to create session');
      }
    } catch (e) {
      appLogger.error('💥 Exception creating session: $e');
      return Result.failure('Failed to create session: $e');
    }
  }

  @override
  Future<Result<Session>> updateSession({
    required String id,
    String? name,
    String? sessionType,
    String? purpose,
  }) async {
    try {
      appLogger.info('💬 Updating session: $id', extra: {
        'name': name,
        'sessionType': sessionType,
        'purpose': purpose,
      });

      final response = await _apiService.put(
        '/sessions/$id',
        data: {
          if (name != null) 'name': name,
          if (sessionType != null) 'session_type': sessionType,
          if (purpose != null) 'purpose': purpose,
        },
      );

      if (response.isSuccess) {
        final session = Session.fromJson(response.data as Map<String, dynamic>);
        appLogger.info('✅ Updated session: ${session.id}');
        return Result.success(session);
      } else {
        appLogger.error('❌ Failed to update session: ${response.error}');
        return Result.failure(response.error ?? 'Failed to update session');
      }
    } catch (e) {
      appLogger.error('💥 Exception updating session: $e');
      return Result.failure('Failed to update session: $e');
    }
  }

  @override
  Future<Result<void>> deleteSession(String id) async {
    try {
      appLogger.info('🗑️ Deleting session: $id');

      final response = await _apiService.delete('/sessions/$id');

      if (response.isSuccess) {
        appLogger.info('✅ Deleted session: $id');
        return Result.success(null);
      } else {
        appLogger.error('❌ Failed to delete session: ${response.error}');
        return Result.failure(response.error ?? 'Failed to delete session');
      }
    } catch (e) {
      appLogger.error('💥 Exception deleting session: $e');
      return Result.failure('Failed to delete session: $e');
    }
  }

  @override
  Future<Result<List<ChatMessage>>> getSessionMessages({
    required String sessionId,
    int? limit,
    int? offset,
  }) async {
    try {
      appLogger.info('💬 Getting messages for session: $sessionId', extra: {
        'limit': limit,
        'offset': offset,
      });

      final response = await _apiService.get(
        '/sessions/$sessionId/messages',
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final messages = (data['messages'] as List)
            .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
            .toList();
        appLogger.info('✅ Retrieved ${messages.length} messages');
        return Result.success(messages);
      } else {
        appLogger.error('❌ Failed to get messages: ${response.error}');
        return Result.failure(response.error ?? 'Failed to get messages');
      }
    } catch (e) {
      appLogger.error('💥 Exception getting messages: $e');
      return Result.failure('Failed to get messages: $e');
    }
  }

  @override
  Future<Result<ChatMessage>> sendMessage({
    required String sessionId,
    required String content,
    String? messageType,
  }) async {
    try {
      appLogger.info('💬 Sending message to session: $sessionId', extra: {
        'messageType': messageType,
        'hasContent': content.isNotEmpty,
      });

      final response = await _apiService.post(
        '/chat/',
        data: {
          'session_id': sessionId,
          'content': content,
          if (messageType != null) 'message_type': messageType,
        },
      );

      if (response.isSuccess) {
        final message = ChatMessage.fromJson(response.data as Map<String, dynamic>);
        appLogger.info('✅ Sent message: ${message.id}');
        return Result.success(message);
      } else {
        appLogger.error('❌ Failed to send message: ${response.error}');
        return Result.failure(response.error ?? 'Failed to send message');
      }
    } catch (e) {
      appLogger.error('💥 Exception sending message: $e');
      return Result.failure('Failed to send message: $e');
    }
  }

  @override
  Future<Result<Stream<ChatMessage>>> sendStreamingMessage({
    required String sessionId,
    required String content,
    String? messageType,
  }) async {
    try {
      appLogger.info('💬 Sending streaming message to session: $sessionId', extra: {
        'messageType': messageType,
        'hasContent': content.isNotEmpty,
      });

      final response = await _apiService.postStream(
        '/chat/stream',
        data: {
          'session_id': sessionId,
          'content': content,
          if (messageType != null) 'message_type': messageType,
        },
      );

      if (response.isSuccess) {
        final stream = response.data as Stream<ChatMessage>;
        appLogger.info('✅ Started streaming message');
        return Result.success(stream);
      } else {
        appLogger.error('❌ Failed to start streaming: ${response.error}');
        return Result.failure(response.error ?? 'Failed to start streaming');
      }
    } catch (e) {
      appLogger.error('💥 Exception starting streaming: $e');
      return Result.failure('Failed to start streaming: $e');
    }
  }

  @override
  Future<Result<List<CommunicationItem>>> getCommunicationHistory({
    required String sessionId,
    int? limit,
    int? offset,
  }) async {
    try {
      appLogger.info('📞 Getting communication history for session: $sessionId', extra: {
        'limit': limit,
        'offset': offset,
      });

      final response = await _apiService.get(
        '/communications/',
        queryParameters: {
          'session_id': sessionId,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final communications = (data['communications'] as List)
            .map((json) => CommunicationItem.fromJson(json as Map<String, dynamic>))
            .toList();
        appLogger.info('✅ Retrieved ${communications.length} communication items');
        return Result.success(communications);
      } else {
        appLogger.error('❌ Failed to get communication history: ${response.error}');
        return Result.failure(response.error ?? 'Failed to get communication history');
      }
    } catch (e) {
      appLogger.error('💥 Exception getting communication history: $e');
      return Result.failure('Failed to get communication history: $e');
    }
  }

  @override
  Future<Result<CommunicationItem>> addCommunicationItem({
    required String sessionId,
    required String content,
    String? itemType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      appLogger.info('📞 Adding communication item to session: $sessionId', extra: {
        'itemType': itemType,
        'hasContent': content.isNotEmpty,
      });

      final response = await _apiService.post(
        '/communications/',
        data: {
          'session_id': sessionId,
          'content': content,
          if (itemType != null) 'item_type': itemType,
          if (metadata != null) 'metadata': metadata,
        },
      );

      if (response.isSuccess) {
        final item = CommunicationItem.fromJson(response.data as Map<String, dynamic>);
        appLogger.info('✅ Added communication item: ${item.id}');
        return Result.success(item);
      } else {
        appLogger.error('❌ Failed to add communication item: ${response.error}');
        return Result.failure(response.error ?? 'Failed to add communication item');
      }
    } catch (e) {
      appLogger.error('💥 Exception adding communication item: $e');
      return Result.failure('Failed to add communication item: $e');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getSessionAnalytics(String sessionId) async {
    try {
      appLogger.info('📊 Getting analytics for session: $sessionId');

      final response = await _apiService.get('/sessions/$sessionId/analytics');

      if (response.isSuccess) {
        appLogger.info('✅ Retrieved session analytics');
        return Result.success(response.data as Map<String, dynamic>);
      } else {
        appLogger.error('❌ Failed to get session analytics: ${response.error}');
        return Result.failure(response.error ?? 'Failed to get session analytics');
      }
    } catch (e) {
      appLogger.error('💥 Exception getting session analytics: $e');
      return Result.failure('Failed to get session analytics: $e');
    }
  }

  @override
  Future<Result<void>> archiveSession(String sessionId) async {
    try {
      appLogger.info('📦 Archiving session: $sessionId');

      final response = await _apiService.post('/sessions/$sessionId/archive');

      if (response.isSuccess) {
        appLogger.info('✅ Archived session: $sessionId');
        return Result.success(null);
      } else {
        appLogger.error('❌ Failed to archive session: ${response.error}');
        return Result.failure(response.error ?? 'Failed to archive session');
      }
    } catch (e) {
      appLogger.error('💥 Exception archiving session: $e');
      return Result.failure('Failed to archive session: $e');
    }
  }

  @override
  Future<Result<void>> restoreSession(String sessionId) async {
    try {
      appLogger.info('📦 Restoring session: $sessionId');

      final response = await _apiService.post('/sessions/$sessionId/restore');

      if (response.isSuccess) {
        appLogger.info('✅ Restored session: $sessionId');
        return Result.success(null);
      } else {
        appLogger.error('❌ Failed to restore session: ${response.error}');
        return Result.failure(response.error ?? 'Failed to restore session');
      }
    } catch (e) {
      appLogger.error('💥 Exception restoring session: $e');
      return Result.failure('Failed to restore session: $e');
    }
  }
}
