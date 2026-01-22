
/// Unified chat response model that handles all chat scenarios
class UnifiedChatResponse {
  final bool success;
  final UnifiedChatData? data;
  final UnifiedChatError? error;
  
  const UnifiedChatResponse({
    required this.success,
    this.data,
    this.error,
  });
  
  factory UnifiedChatResponse.fromJson(Map<String, dynamic> json) {
    // Handle both nested and flat response formats
    if (json.containsKey('success')) {
      // Nested format: {success: true, data: {...}, error: null}
      return UnifiedChatResponse(
        success: json['success'] ?? false,
        data: json['data'] != null ? UnifiedChatData.fromJson(json['data']) : null,
        error: json['error'] != null ? UnifiedChatError.fromJson(json['error']) : null,
      );
    } else {
      // Flat format: {id: "...", message: "...", session_id: "..."}
      return UnifiedChatResponse(
        success: true,
        data: UnifiedChatData.fromJson(json),
        error: null,
      );
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'error': error?.toJson(),
    };
  }
}

/// Unified chat data containing response and metadata
class UnifiedChatData {
  final String communicationId;
  final String sessionId;
  final String response;
  final String mode;
  final List<SourceDocument> sources;
  final RAGMetadata ragMetadata;
  final MessageMetadata messageMetadata;
  
  const UnifiedChatData({
    required this.communicationId,
    required this.sessionId,
    required this.response,
    required this.mode,
    required this.sources,
    required this.ragMetadata,
    required this.messageMetadata,
  });
  
  factory UnifiedChatData.fromJson(Map<String, dynamic> json) {
    return UnifiedChatData(
      communicationId: json['id'] ?? json['communication_id'] ?? '',
      sessionId: json['session_id'] ?? '',
      response: json['message'] ?? json['response'] ?? '',
      mode: json['communication_type'] ?? json['mode'] ?? 'standard',
      sources: (json['sources'] as List<dynamic>? ?? [])
          .map((source) => SourceDocument.fromJson(source))
          .toList(),
      ragMetadata: RAGMetadata.fromJson(json['metadata'] ?? json['rag_metadata'] ?? {}),
      messageMetadata: MessageMetadata.fromJson({
        'message_id': json['id'] ?? '',
        'timestamp': json['created_at'] ?? '',
        'processing_time_ms': json['metadata']?['processing_metadata']?['processing_time_ms'] ?? 0,
        'model_used': json['metadata']?['processing_metadata']?['model_used'] ?? 'unknown',
        'tokens_used': json['metadata']?['processing_metadata']?['tokens_used'] ?? 0,
      }),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'communication_id': communicationId,
      'session_id': sessionId,
      'response': response,
      'mode': mode,
      'sources': sources.map((s) => s.toJson()).toList(),
      'rag_metadata': ragMetadata.toJson(),
      'message_metadata': messageMetadata.toJson(),
    };
  }
}

/// Source document from RAG retrieval
class SourceDocument {
  final String id;
  final String type;
  final String content;
  final double relevanceScore;
  final Map<String, dynamic> metadata;
  
  const SourceDocument({
    required this.id,
    required this.type,
    required this.content,
    required this.relevanceScore,
    required this.metadata,
  });
  
  factory SourceDocument.fromJson(Map<String, dynamic> json) {
    return SourceDocument(
      id: json['id'] ?? '',
      type: json['type'] ?? 'unknown',
      content: json['content'] ?? '',
      relevanceScore: (json['relevance_score'] ?? 0.0).toDouble(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'relevance_score': relevanceScore,
      'metadata': metadata,
    };
  }
}

/// RAG metadata for context retrieval information
class RAGMetadata {
  final int contextRetrieved;
  final int totalSources;
  final int retrievalTimeMs;
  final bool ragEnabled;
  final List<String> dataSources;
  
  const RAGMetadata({
    required this.contextRetrieved,
    required this.totalSources,
    required this.retrievalTimeMs,
    required this.ragEnabled,
    required this.dataSources,
  });
  
  factory RAGMetadata.fromJson(Map<String, dynamic> json) {
    return RAGMetadata(
      contextRetrieved: json['rag_sources'] ?? json['context_retrieved'] ?? 0,
      totalSources: json['rag_sources'] ?? json['total_sources'] ?? 0,
      retrievalTimeMs: json['processing_metadata']?['processing_time_ms'] ?? json['retrieval_time_ms'] ?? 0,
      ragEnabled: json['use_rag'] ?? json['rag_enabled'] ?? false,
      dataSources: (json['data_sources'] as List<dynamic>? ?? [])
          .map((source) => source.toString())
          .toList(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'context_retrieved': contextRetrieved,
      'total_sources': totalSources,
      'retrieval_time_ms': retrievalTimeMs,
      'rag_enabled': ragEnabled,
      'data_sources': dataSources,
    };
  }
}

/// Message metadata for processing information
class MessageMetadata {
  final String messageId;
  final DateTime timestamp;
  final int processingTimeMs;
  final String modelUsed;
  final int tokensUsed;
  
  const MessageMetadata({
    required this.messageId,
    required this.timestamp,
    required this.processingTimeMs,
    required this.modelUsed,
    required this.tokensUsed,
  });
  
  factory MessageMetadata.fromJson(Map<String, dynamic> json) {
    return MessageMetadata(
      messageId: json['message_id'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      processingTimeMs: json['processing_time_ms'] ?? 0,
      modelUsed: json['model_used'] ?? 'unknown',
      tokensUsed: json['tokens_used'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'timestamp': timestamp.toIso8601String(),
      'processing_time_ms': processingTimeMs,
      'model_used': modelUsed,
      'tokens_used': tokensUsed,
    };
  }
}

/// Unified chat error model
class UnifiedChatError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;
  final DateTime timestamp;
  final String requestId;
  
  const UnifiedChatError({
    required this.code,
    required this.message,
    this.details,
    required this.timestamp,
    required this.requestId,
  });
  
  factory UnifiedChatError.fromJson(Map<String, dynamic> json) {
    return UnifiedChatError(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'An unknown error occurred',
      details: json['details'] as Map<String, dynamic>?,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      requestId: json['request_id'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'request_id': requestId,
    };
  }
}

/// Chat mode enumeration
enum ChatMode {
  auto,
  standard,
  streaming,
  persistent,
}

/// RAG options for context retrieval
class RAGOptions {
  final bool useRAG;
  final bool streaming;
  final bool persistMessages;
  final bool consent;
  final int contextLimit;
  final double temperature;
  final int maxTokens;
  final Map<String, dynamic>? ragFilters;
  
  const RAGOptions({
    this.useRAG = true,
    this.streaming = true,
    this.persistMessages = true,
    this.consent = true,
    this.contextLimit = 5,
    this.temperature = 0.7,
    this.maxTokens = 1000,
    this.ragFilters,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'use_rag': useRAG,
      'streaming': streaming,
      'persist_messages': persistMessages,
      'consent': consent,
      'context_limit': contextLimit,
      'temperature': temperature,
      'max_tokens': maxTokens,
      if (ragFilters != null) 'rag_filters': ragFilters,
    };
  }
  
  RAGOptions copyWith({
    bool? useRAG,
    bool? streaming,
    bool? persistMessages,
    bool? consent,
    int? contextLimit,
    double? temperature,
    int? maxTokens,
    Map<String, dynamic>? ragFilters,
  }) {
    return RAGOptions(
      useRAG: useRAG ?? this.useRAG,
      streaming: streaming ?? this.streaming,
      persistMessages: persistMessages ?? this.persistMessages,
      consent: consent ?? this.consent,
      contextLimit: contextLimit ?? this.contextLimit,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      ragFilters: ragFilters ?? this.ragFilters,
    );
  }
}

/// Chat metadata for request context
class ChatMetadata {
  final String purpose;
  final String sessionType;
  final String userAgent;
  final DateTime timestamp;
  
  ChatMetadata({
    this.purpose = 'chat',
    this.sessionType = 'conversation',
    this.userAgent = 'MindHearth/1.0',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'purpose': purpose,
      'session_type': sessionType,
      'user_agent': userAgent,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  ChatMetadata copyWith({
    String? purpose,
    String? sessionType,
    String? userAgent,
    DateTime? timestamp,
  }) {
    return ChatMetadata(
      purpose: purpose ?? this.purpose,
      sessionType: sessionType ?? this.sessionType,
      userAgent: userAgent ?? this.userAgent,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
