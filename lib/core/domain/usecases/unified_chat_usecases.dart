import 'dart:async';
import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/domain/entities/app_error.dart';
import 'package:mindhearth/core/domain/repositories/chat_repository.dart';
import 'package:mindhearth/core/models/unified_chat_models.dart';
import 'package:mindhearth/core/utils/logger.dart';

/// Use case for sending unified messages with enhanced capabilities
class SendUnifiedMessageUseCase {
  final ChatRepository _chatRepository;
  
  SendUnifiedMessageUseCase(this._chatRepository);
  
  Future<Result<UnifiedChatResponse>> call({
    required String message,
    String? sessionId,
    ChatMode mode = ChatMode.auto,
    RAGOptions? ragOptions,
    ChatMetadata? metadata,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      appLogger.info('🎯 SendUnifiedMessageUseCase called', {
        'messageLength': message.length,
        'sessionId': sessionId,
        'mode': mode.name,
        'useRAG': ragOptions?.useRAG ?? false,
      });
      
      final result = await _chatRepository.sendUnifiedMessage(
        message: message,
        sessionId: sessionId,
        mode: mode,
        ragOptions: ragOptions,
        metadata: metadata,
        conversationHistory: conversationHistory,
      );
      
      return result.when(
        success: (response) {
          appLogger.info('✅ SendUnifiedMessageUseCase succeeded');
          return Result.success(response);
        },
        failure: (error) {
          appLogger.error('❌ SendUnifiedMessageUseCase failed', {'error': error.message});
          return Result.failure(error);
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception in SendUnifiedMessageUseCase', {'error': e.toString()});
      return Result.failure(AppErrorFactory.unknown(message: 'Use case failed: $e'));
    }
  }
}

/// Use case for sending unified streaming messages
class SendUnifiedStreamingMessageUseCase {
  final ChatRepository _chatRepository;
  
  SendUnifiedStreamingMessageUseCase(this._chatRepository);
  
  Future<Result<Stream<UnifiedChatResponse>>> call({
    required String message,
    String? sessionId,
    RAGOptions? ragOptions,
    ChatMetadata? metadata,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      appLogger.info('🎯 SendUnifiedStreamingMessageUseCase called', {
        'messageLength': message.length,
        'sessionId': sessionId,
        'useRAG': ragOptions?.useRAG ?? false,
      });
      
      final result = await _chatRepository.sendUnifiedStreamingMessage(
        message: message,
        sessionId: sessionId,
        ragOptions: ragOptions,
        metadata: metadata,
        conversationHistory: conversationHistory,
      );
      
      return result.when(
        success: (stream) {
          appLogger.info('✅ SendUnifiedStreamingMessageUseCase succeeded');
          return Result.success(stream);
        },
        failure: (error) {
          appLogger.error('❌ SendUnifiedStreamingMessageUseCase failed', {'error': error.message});
          return Result.failure(error);
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception in SendUnifiedStreamingMessageUseCase', {'error': e.toString()});
      return Result.failure(AppErrorFactory.unknown(message: 'Streaming use case failed: $e'));
    }
  }
}

/// Use case for sending batch messages
class SendBatchMessagesUseCase {
  final ChatRepository _chatRepository;
  
  SendBatchMessagesUseCase(this._chatRepository);
  
  Future<Result<List<UnifiedChatResponse>>> call({
    required List<String> messages,
    String? sessionId,
    RAGOptions? ragOptions,
    ChatMetadata? metadata,
  }) async {
    try {
      appLogger.info('🎯 SendBatchMessagesUseCase called', {
        'messageCount': messages.length,
        'sessionId': sessionId,
        'useRAG': ragOptions?.useRAG ?? false,
      });
      
      final result = await _chatRepository.sendBatchMessages(
        messages: messages,
        sessionId: sessionId,
        ragOptions: ragOptions,
        metadata: metadata,
      );
      
      return result.when(
        success: (responses) {
          appLogger.info('✅ SendBatchMessagesUseCase succeeded', {
            'responseCount': responses.length,
          });
          return Result.success(responses);
        },
        failure: (error) {
          appLogger.error('❌ SendBatchMessagesUseCase failed', {'error': error.message});
          return Result.failure(error);
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception in SendBatchMessagesUseCase', {'error': e.toString()});
      return Result.failure(AppErrorFactory.unknown(message: 'Batch use case failed: $e'));
    }
  }
}

/// Use case for getting unified chat history
class GetUnifiedChatHistoryUseCase {
  final ChatRepository _chatRepository;
  
  GetUnifiedChatHistoryUseCase(this._chatRepository);
  
  Future<Result<UnifiedChatResponse>> call({
    required String sessionId,
    int? limit,
    int? offset,
  }) async {
    try {
      appLogger.info('🎯 GetUnifiedChatHistoryUseCase called', {
        'sessionId': sessionId,
        'limit': limit,
        'offset': offset,
      });
      
      final result = await _chatRepository.getUnifiedChatHistory(
        sessionId: sessionId,
        limit: limit,
        offset: offset,
      );
      
      return result.when(
        success: (response) {
          appLogger.info('✅ GetUnifiedChatHistoryUseCase succeeded');
          return Result.success(response);
        },
        failure: (error) {
          appLogger.error('❌ GetUnifiedChatHistoryUseCase failed', {'error': error.message});
          return Result.failure(error);
        },
      );
    } catch (e) {
      appLogger.error('💥 Exception in GetUnifiedChatHistoryUseCase', {'error': e.toString()});
      return Result.failure(AppErrorFactory.unknown(message: 'History use case failed: $e'));
    }
  }
}

/// Use case for creating optimized RAG options
class CreateRAGOptionsUseCase {
  CreateRAGOptionsUseCase();
  
  RAGOptions call({
    bool useRAG = true,
    bool streaming = true,
    bool persistMessages = true,
    bool consent = true,
    int contextLimit = 5,
    double temperature = 0.7,
    int maxTokens = 1000,
    Map<String, dynamic>? ragFilters,
  }) {
    appLogger.info('🎯 CreateRAGOptionsUseCase called', {
      'useRAG': useRAG,
      'streaming': streaming,
      'contextLimit': contextLimit,
    });
    
    return RAGOptions(
      useRAG: useRAG,
      streaming: streaming,
      persistMessages: persistMessages,
      consent: consent,
      contextLimit: contextLimit,
      temperature: temperature,
      maxTokens: maxTokens,
      ragFilters: ragFilters,
    );
  }
}

/// Use case for creating chat metadata
class CreateChatMetadataUseCase {
  CreateChatMetadataUseCase();
  
  ChatMetadata call({
    String purpose = 'chat',
    String sessionType = 'conversation',
    String userAgent = 'MindHearth/1.0',
    DateTime? timestamp,
  }) {
    appLogger.info('🎯 CreateChatMetadataUseCase called', {
      'purpose': purpose,
      'sessionType': sessionType,
    });
    
    return ChatMetadata(
      purpose: purpose,
      sessionType: sessionType,
      userAgent: userAgent,
      timestamp: timestamp,
    );
  }
}

/// Use case for intelligent mode selection
class SelectChatModeUseCase {
  SelectChatModeUseCase();
  
  ChatMode call({
    required String message,
    bool useRAG = true,
    bool streaming = true,
    int messageLength = 0,
  }) {
    appLogger.info('🎯 SelectChatModeUseCase called', {
      'messageLength': messageLength,
      'useRAG': useRAG,
      'streaming': streaming,
    });
    
    // Intelligent mode selection logic
    if (useRAG && streaming) {
      return ChatMode.auto; // Let backend decide
    } else if (streaming) {
      return ChatMode.streaming;
    } else if (messageLength > 1000) {
      return ChatMode.streaming; // Long messages benefit from streaming
    } else {
      return ChatMode.standard;
    }
  }
}
