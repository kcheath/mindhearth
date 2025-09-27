import 'dart:async';
import 'dart:convert';
import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/entities/app_error.dart';
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
      appLogger.info('📋 Getting chat sessions');

      final response = await _apiService.get('/sessions/');

      return response.when(
        success: (data, message) {
          // Handle both direct array response and wrapped response
          List<dynamic> sessionsList;
          if (data is List) {
            // Backend returns sessions array directly
            sessionsList = data;
          } else if (data is Map<String, dynamic> && data.containsKey('sessions')) {
            // Backend returns sessions wrapped in object
            sessionsList = data['sessions'] as List;
          } else {
            // Fallback to empty list
            sessionsList = [];
          }
          
          final sessions = sessionsList
              .map((json) => Session.fromJson(json as Map<String, dynamic>))
              .toList();
          appLogger.info('✅ Retrieved ${sessions.length} sessions');
          return Result.success(sessions);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to get sessions: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception getting sessions: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to get sessions: $e'));
    }
  }

  @override
  Future<Result<Session?>> getSession(String id) async {
    try {
      appLogger.info('📋 Getting session: $id');

      final response = await _apiService.get('/sessions/$id');

      return response.when(
        success: (data, message) {
          final session = Session.fromJson(data as Map<String, dynamic>);
          appLogger.info('✅ Retrieved session: ${session.id}');
          return Result.success(session);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to get session: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception getting session: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to get session: $e'));
    }
  }

  @override
  Future<Result<Session>> createSession({
    required String name,
    String? sessionType,
    String? purpose,
  }) async {
    try {
      appLogger.info('➕ Creating session: $name');

      final response = await _apiService.post(
        '/sessions/',
        data: {
          'name': name,
          if (sessionType != null) 'session_type': sessionType,
          if (purpose != null) 'purpose': purpose,
        },
      );

      return response.when(
        success: (data, message) {
          final session = Session.fromJson(data as Map<String, dynamic>);
          appLogger.info('✅ Created session: ${session.id}');
          return Result.success(session);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to create session: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception creating session: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to create session: $e'));
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
      appLogger.info('✏️ Updating session: $id');

      final response = await _apiService.put(
        '/sessions/$id',
        data: {
          if (name != null) 'name': name,
          if (sessionType != null) 'session_type': sessionType,
          if (purpose != null) 'purpose': purpose,
        },
      );

      return response.when(
        success: (data, message) {
          final session = Session.fromJson(data as Map<String, dynamic>);
          appLogger.info('✅ Updated session: ${session.id}');
          return Result.success(session);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to update session: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception updating session: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to update session: $e'));
    }
  }

  @override
  Future<Result<void>> deleteSession(String id) async {
    try {
      appLogger.info('🗑️ Deleting session: $id');

      final response = await _apiService.delete('/sessions/$id');

      return response.when(
        success: (data, message) {
          appLogger.info('✅ Deleted session: $id');
          return Result.success(null);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to delete session: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception deleting session: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to delete session: $e'));
    }
  }

  @override
  Future<Result<List<ChatMessage>>> getSessionMessages({
    required String sessionId,
    int? limit,
    int? offset,
  }) async {
    try {
      appLogger.info('💬 Getting messages for session: $sessionId');

      // FIXED: Use the correct communications endpoint instead of /chat/{sessionId}/messages
      final response = await _apiService.get(
        '/communications/',
        queryParameters: {
          'session_id': sessionId,
          'item_type': 'chat',
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      return response.when(
        success: (data, message) {
          // Enhanced logging to debug data structure
          appLogger.debug('📊 Communications API response data structure:', {'data': data});
          
          // FIXED: Parse communications response format
          final communicationsList = data['communications'] as List? ?? [];
          appLogger.debug('📊 Communications list length: ${communicationsList.length}');
          
          if (communicationsList.isNotEmpty) {
            appLogger.debug('📊 First communication item structure:', {'item': communicationsList.first});
          }
          
          final communications = communicationsList
              .map((json) {
                try {
                  final item = json as Map<String, dynamic>;
                  
                  // Handle different field names from communications endpoint
                  final chatMessage = ChatMessage(
                    id: (item['id'] as String?)?.isNotEmpty == true 
                        ? item['id'] as String 
                        : 'comm_${DateTime.now().millisecondsSinceEpoch}',
                    sessionId: (item['session_id'] as String?)?.isNotEmpty == true 
                        ? item['session_id'] as String 
                        : sessionId,
                    content: (item['original_content'] as String?)?.isNotEmpty == true 
                        ? item['original_content'] as String 
                        : (item['content'] as String?)?.isNotEmpty == true 
                            ? item['content'] as String 
                            : '',
                    role: (item['role'] as String?)?.isNotEmpty == true 
                        ? item['role'] as String 
                        : 'user',
                    timestamp: item['created_at'] != null 
                        ? DateTime.tryParse(item['created_at'] as String) ?? DateTime.now()
                        : DateTime.now(),
                    messageType: item['item_type'] as String?,
                    metadata: {
                      'redacted_content': item['redacted_content'],
                      'consent': item['consent'],
                      'created_at': item['created_at'],
                      'updated_at': item['updated_at'],
                    },
                  );
                  
                  appLogger.debug('📊 Parsed communication item:', {
                    'id': chatMessage.id,
                    'role': chatMessage.role,
                    'content_length': chatMessage.content.length,
                  });
                  
                  return chatMessage;
                } catch (e) {
                  appLogger.error('❌ Failed to parse communication item:', {'item': json, 'error': e.toString()});
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<ChatMessage>()
              .toList();
              
          // Sort messages chronologically (oldest first) for proper conversation flow
          communications.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
          appLogger.info('✅ Retrieved ${communications.length} messages for session: $sessionId (sorted chronologically)');
          return Result.success(communications);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to get messages: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception getting messages: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to get messages: $e'));
    }
  }

  @override
  Future<Result<ChatMessage>> sendMessage({
    required String sessionId,
    required String content,
    String? messageType,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      appLogger.info('💬 Sending message to session: $sessionId');

      final response = await _apiService.post(
        '/chat/',
        data: {
          'session_id': sessionId,
          'message': content,
          if (messageType != null) 'message_type': messageType,
          if (conversationHistory != null) 'messages': conversationHistory, // NEW: Send full conversation context
          'purpose': 'chat', // NEW: Explicit purpose
        },
      );

      return response.when(
        success: (data, message) {
          // Map API response to ChatMessage format
          final responseData = data as Map<String, dynamic>;
          final chatMessage = ChatMessage(
            id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
            sessionId: responseData['session_id'] as String? ?? sessionId,
            content: responseData['message'] as String? ?? '',
            role: 'assistant',
            timestamp: DateTime.now(),
            messageType: responseData['session_type'] as String?,
            metadata: {
              'purpose': responseData['purpose'],
              'specialist_type': responseData['specialist_type'],
              'specialist_display_name': responseData['specialist_display_name'],
              'confidence': responseData['confidence'],
              'rag_enabled': responseData['rag_enabled'],
              'sources': responseData['sources'],
              'matched_rule': responseData['matched_rule'],
              'suggestions': responseData['suggestions'],
            },
          );
          appLogger.info('✅ Message sent successfully: ${chatMessage.id}');
          return Result.success(chatMessage);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to send message: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception sending message: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to send message: $e'));
    }
  }

  @override
  Future<Result<Stream<ChatMessage>>> sendStreamingMessage({
    required String sessionId,
    required String content,
    String? messageType,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      appLogger.info('💬 Sending streaming message to session: $sessionId');

      final response = await _apiService.postStream(
        '/chat/stream',
        data: {
          'session_id': sessionId,
          'message': content,
          if (messageType != null) 'message_type': messageType,
          if (conversationHistory != null) 'messages': conversationHistory, // NEW: Send full conversation context
          'purpose': 'chat', // NEW: Explicit purpose
        },
      );

      return response.when(
        success: (data, message) {
          final stream = data as Stream<dynamic>;
          final chatStream = stream.map((event) {
            try {
          final data = json.decode(event) as Map<String, dynamic>;
          return ChatMessage.fromJson(data);
            } catch (e) {
              appLogger.error('❌ Error parsing stream event: $e, event: $event');
              throw AppErrorFactory.unknown(message: 'Error parsing stream event: $e');
            }
          });
          
          appLogger.info('✅ Streaming message started');
          return Result.success(chatStream);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to start streaming: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception starting streaming: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to start streaming: $e'));
    }
  }

  @override
  Future<Result<List<CommunicationItem>>> getCommunicationHistory({
    required String sessionId,
    int? limit,
    int? offset,
  }) async {
    try {
      appLogger.info('📞 Getting communication history for session: $sessionId');

      final response = await _apiService.get(
        '/communications/',
        queryParameters: {
          'session_id': sessionId,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      return response.when(
        success: (data, message) {
          final items = (data['communications'] as List)
              .map((json) => CommunicationItem.fromJson(json as Map<String, dynamic>))
              .toList();
          appLogger.info('✅ Retrieved ${items.length} communication items for session: $sessionId');
          return Result.success(items);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to get communication history: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception getting communication history: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to get communication history: $e'));
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
      appLogger.info('📞 Adding communication item to session: $sessionId');

      final response = await _apiService.post(
        '/communications/',
        data: {
          'session_id': sessionId,
          'content': content,
          if (itemType != null) 'item_type': itemType,
          if (metadata != null) 'metadata': metadata,
        },
      );

      return response.when(
        success: (data, message) {
          final item = CommunicationItem.fromJson(data as Map<String, dynamic>);
          appLogger.info('✅ Added communication item: ${item.id}');
          return Result.success(item);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to add communication item: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception adding communication item: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to add communication item: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getSessionAnalytics(String sessionId) async {
    try {
      appLogger.info('📊 Getting session analytics for session: $sessionId');

      final response = await _apiService.get('/sessions/$sessionId/analytics');

      return response.when(
        success: (data, message) {
          appLogger.info('✅ Retrieved session analytics');
          return Result.success(data as Map<String, dynamic>);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to get session analytics: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception getting session analytics: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to get session analytics: $e'));
    }
  }

  @override
  Future<Result<void>> archiveSession(String sessionId) async {
    try {
      appLogger.info('📦 Archiving session: $sessionId');

      final response = await _apiService.post('/sessions/$sessionId/archive');

      return response.when(
        success: (data, message) {
          appLogger.info('✅ Session archived successfully');
          return Result.success(null);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to archive session: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception archiving session: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to archive session: $e'));
    }
  }

  @override
  Future<Result<void>> restoreSession(String sessionId) async {
    try {
      appLogger.info('📦 Restoring session: $sessionId');

      final response = await _apiService.post('/sessions/$sessionId/restore');

      return response.when(
        success: (data, message) {
          appLogger.info('✅ Session restored successfully');
          return Result.success(null);
        },
        error: (message, statusCode, errors) {
          appLogger.error('❌ Failed to restore session: $message');
          return Result.failure(AppErrorFactory.network(message: message));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception restoring session: $e');
      return Result.failure(AppErrorFactory.network(message: 'Failed to restore session: $e'));
    }
  }
}