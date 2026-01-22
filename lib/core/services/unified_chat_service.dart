import 'dart:async';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/models/unified_chat_models.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Unified chat service that handles all chat scenarios through a single endpoint
class UnifiedChatService {
  final ApiService _apiService;
  
  UnifiedChatService({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();
  
  /// Send a message using the unified chat endpoint
  Future<UnifiedChatResponse> sendMessage({
    required String message,
    String? sessionId,
    ChatMode mode = ChatMode.auto,
    RAGOptions? ragOptions,
    ChatMetadata? metadata,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      appLogger.info('💬 Sending unified message', {
        'sessionId': sessionId,
        'mode': mode.name,
        'useRAG': ragOptions?.useRAG ?? false,
      });
      
      final requestData = {
        'message': message,
        if (sessionId != null) 'session_id': sessionId,
        'communication_type': 'chat',
        'metadata': {
          'mode': mode.name,
          'timestamp': DateTime.now().toIso8601String(),
          if (ragOptions != null) ...ragOptions.toJson(),
          if (metadata != null) ...metadata.toJson(),
          if (conversationHistory != null) 'conversation_history': conversationHistory,
        },
      };
      
      final response = await _apiService.post(
        '/communications/chat',
        data: requestData,
      );
      
      return response.when(
        success: (data, message) {
          appLogger.info('✅ Unified message sent successfully');
          return UnifiedChatResponse.fromJson(data);
        },
        error: (errorMessage, statusCode, errors) {
          appLogger.error('❌ Unified message failed', {
            'error': errorMessage,
            'statusCode': statusCode,
          });
          return UnifiedChatResponse(
            success: false,
            error: UnifiedChatError(
              code: 'API_ERROR',
              message: errorMessage,
              details: {'status_code': statusCode, 'errors': errors},
              timestamp: DateTime.now(),
              requestId: '',
            ),
          );
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception in unified chat service', {'error': e.toString()});
      return UnifiedChatResponse(
        success: false,
        error: UnifiedChatError(
          code: 'NETWORK_ERROR',
          message: e.toString(),
          timestamp: DateTime.now(),
          requestId: '',
        ),
      );
    }
  }
  
  /// Send a streaming message using the unified chat endpoint
  Stream<UnifiedChatResponse> sendStreamingMessage({
    required String message,
    String? sessionId,
    RAGOptions? ragOptions,
    ChatMetadata? metadata,
    List<Map<String, String>>? conversationHistory,
  }) async* {
    try {
      appLogger.info('💬 Sending unified streaming message', {
        'sessionId': sessionId,
        'useRAG': ragOptions?.useRAG ?? false,
      });
      
      final requestData = {
        'message': message,
        if (sessionId != null) 'session_id': sessionId,
        'mode': 'streaming',
        if (ragOptions != null) 'options': ragOptions.toJson(),
        if (metadata != null) 'metadata': metadata.toJson(),
        if (conversationHistory != null) 'conversation_history': conversationHistory,
      };
      
      final response = await _apiService.postStream(
        '/communications/chat/stream',
        data: requestData,
      );
      
      yield* response.when(
        success: (stream, message) => stream.map((data) {
          try {
            return UnifiedChatResponse.fromJson(data);
          } catch (e) {
            appLogger.error('❌ Error parsing streaming response', {'error': e.toString()});
            return UnifiedChatResponse(
              success: false,
              error: UnifiedChatError(
                code: 'PARSE_ERROR',
                message: 'Failed to parse streaming response',
                timestamp: DateTime.now(),
                requestId: '',
              ),
            );
          }
        }),
        error: (errorMessage, statusCode, errors) {
          appLogger.error('❌ Unified streaming failed', {
            'error': errorMessage,
            'statusCode': statusCode,
          });
          return Stream.value(UnifiedChatResponse(
            success: false,
            error: UnifiedChatError(
              code: 'STREAMING_ERROR',
              message: errorMessage,
              details: {'status_code': statusCode, 'errors': errors},
              timestamp: DateTime.now(),
              requestId: '',
            ),
          ));
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception in unified streaming service', {'error': e.toString()});
      yield UnifiedChatResponse(
        success: false,
        error: UnifiedChatError(
          code: 'STREAMING_NETWORK_ERROR',
          message: e.toString(),
          timestamp: DateTime.now(),
          requestId: '',
        ),
      );
    }
  }
  
  /// Send a batch of messages for processing
  Future<List<UnifiedChatResponse>> sendBatchMessages({
    required List<String> messages,
    String? sessionId,
    RAGOptions? ragOptions,
    ChatMetadata? metadata,
  }) async {
    final responses = <UnifiedChatResponse>[];
    
    for (final message in messages) {
      final response = await sendMessage(
        message: message,
        sessionId: sessionId,
        mode: ChatMode.standard,
        ragOptions: ragOptions,
        metadata: metadata,
      );
      responses.add(response);
      
      // Add small delay between messages to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return responses;
  }
  
  /// Get chat history for a session
  Future<UnifiedChatResponse> getChatHistory({
    required String sessionId,
    int? limit,
    int? offset,
  }) async {
    try {
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
          return UnifiedChatResponse(
            success: true,
            data: UnifiedChatData(
              communicationId: '',
              sessionId: sessionId,
              response: 'History retrieved',
              mode: 'history',
              sources: [],
              ragMetadata: const RAGMetadata(
                contextRetrieved: 0,
                totalSources: 0,
                retrievalTimeMs: 0,
                ragEnabled: false,
                dataSources: [],
              ),
              messageMetadata: MessageMetadata(
                messageId: 'history_${DateTime.now().millisecondsSinceEpoch}',
                timestamp: DateTime.now(),
                processingTimeMs: 0,
                modelUsed: 'history',
                tokensUsed: 0,
              ),
            ),
          );
        },
        error: (errorMessage, statusCode, errors) {
          return UnifiedChatResponse(
            success: false,
            error: UnifiedChatError(
              code: 'HISTORY_ERROR',
              message: errorMessage,
              details: {'status_code': statusCode, 'errors': errors},
              timestamp: DateTime.now(),
              requestId: '',
            ),
          );
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception getting chat history', {'error': e.toString()});
      return UnifiedChatResponse(
        success: false,
        error: UnifiedChatError(
          code: 'HISTORY_NETWORK_ERROR',
          message: e.toString(),
          timestamp: DateTime.now(),
          requestId: '',
        ),
      );
    }
  }
}
