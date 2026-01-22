import 'package:flutter_test/flutter_test.dart';
import 'package:mindhearth/core/models/unified_chat_models.dart';

void main() {
  group('UnifiedChatModels', () {
    group('UnifiedChatResponse', () {
      test('should create from JSON successfully', () {
        // Arrange
        final json = {
          'success': true,
          'data': {
            'communication_id': 'comm_123',
            'session_id': 'session_123',
            'response': 'Hello! How can I help you?',
            'mode': 'standard',
            'sources': [],
            'rag_metadata': {
              'context_retrieved': 0,
              'total_sources': 0,
              'retrieval_time_ms': 0,
              'rag_enabled': false,
              'data_sources': [],
            },
            'message_metadata': {
              'message_id': 'msg_123',
              'timestamp': '2024-12-01T10:30:00Z',
              'processing_time_ms': 1000,
              'model_used': 'gpt-4',
              'tokens_used': 50,
            },
          },
        };

        // Act
        final response = UnifiedChatResponse.fromJson(json);

        // Assert
        expect(response.success, true);
        expect(response.data?.communicationId, 'comm_123');
        expect(response.data?.sessionId, 'session_123');
        expect(response.data?.response, 'Hello! How can I help you?');
        expect(response.data?.mode, 'standard');
        expect(response.data?.sources, isEmpty);
        expect(response.data?.ragMetadata.ragEnabled, false);
        expect(response.data?.messageMetadata.messageId, 'msg_123');
        expect(response.data?.messageMetadata.modelUsed, 'gpt-4');
        expect(response.data?.messageMetadata.tokensUsed, 50);
      });

      test('should handle error response', () {
        // Arrange
        final json = {
          'success': false,
          'error': {
            'code': 'API_ERROR',
            'message': 'Insufficient credits',
            'timestamp': '2024-12-01T10:30:00Z',
            'request_id': 'req_123',
          },
        };

        // Act
        final response = UnifiedChatResponse.fromJson(json);

        // Assert
        expect(response.success, false);
        expect(response.data, null);
        expect(response.error?.code, 'API_ERROR');
        expect(response.error?.message, 'Insufficient credits');
        expect(response.error?.requestId, 'req_123');
      });
    });

    group('SourceDocument', () {
      test('should create from JSON successfully', () {
        // Arrange
        final json = {
          'id': 'source_1',
          'type': 'journal',
          'content': 'Previous journal entry...',
          'relevance_score': 0.95,
          'metadata': {'date': '2024-12-01'},
        };

        // Act
        final source = SourceDocument.fromJson(json);

        // Assert
        expect(source.id, 'source_1');
        expect(source.type, 'journal');
        expect(source.content, 'Previous journal entry...');
        expect(source.relevanceScore, 0.95);
        expect(source.metadata['date'], '2024-12-01');
      });

      test('should convert to JSON successfully', () {
        // Arrange
        final source = SourceDocument(
          id: 'source_1',
          type: 'journal',
          content: 'Previous journal entry...',
          relevanceScore: 0.95,
          metadata: {'date': '2024-12-01'},
        );

        // Act
        final json = source.toJson();

        // Assert
        expect(json['id'], 'source_1');
        expect(json['type'], 'journal');
        expect(json['content'], 'Previous journal entry...');
        expect(json['relevance_score'], 0.95);
        expect(json['metadata']['date'], '2024-12-01');
      });
    });

    group('RAGMetadata', () {
      test('should create from JSON successfully', () {
        // Arrange
        final json = {
          'context_retrieved': 3,
          'total_sources': 10,
          'retrieval_time_ms': 150,
          'rag_enabled': true,
          'data_sources': ['journal', 'chat'],
        };

        // Act
        final metadata = RAGMetadata.fromJson(json);

        // Assert
        expect(metadata.contextRetrieved, 3);
        expect(metadata.totalSources, 10);
        expect(metadata.retrievalTimeMs, 150);
        expect(metadata.ragEnabled, true);
        expect(metadata.dataSources, ['journal', 'chat']);
      });

      test('should convert to JSON successfully', () {
        // Arrange
        final metadata = RAGMetadata(
          contextRetrieved: 3,
          totalSources: 10,
          retrievalTimeMs: 150,
          ragEnabled: true,
          dataSources: ['journal', 'chat'],
        );

        // Act
        final json = metadata.toJson();

        // Assert
        expect(json['context_retrieved'], 3);
        expect(json['total_sources'], 10);
        expect(json['retrieval_time_ms'], 150);
        expect(json['rag_enabled'], true);
        expect(json['data_sources'], ['journal', 'chat']);
      });
    });

    group('MessageMetadata', () {
      test('should create from JSON successfully', () {
        // Arrange
        final json = {
          'message_id': 'msg_123',
          'timestamp': '2024-12-01T10:30:00Z',
          'processing_time_ms': 1000,
          'model_used': 'gpt-4',
          'tokens_used': 50,
        };

        // Act
        final metadata = MessageMetadata.fromJson(json);

        // Assert
        expect(metadata.messageId, 'msg_123');
        expect(metadata.timestamp, DateTime.parse('2024-12-01T10:30:00Z'));
        expect(metadata.processingTimeMs, 1000);
        expect(metadata.modelUsed, 'gpt-4');
        expect(metadata.tokensUsed, 50);
      });

      test('should convert to JSON successfully', () {
        // Arrange
        final timestamp = DateTime(2024, 12, 1, 10, 30);
        final metadata = MessageMetadata(
          messageId: 'msg_123',
          timestamp: timestamp,
          processingTimeMs: 1000,
          modelUsed: 'gpt-4',
          tokensUsed: 50,
        );

        // Act
        final json = metadata.toJson();

        // Assert
        expect(json['message_id'], 'msg_123');
        expect(json['timestamp'], '2024-12-01T10:30:00.000');
        expect(json['processing_time_ms'], 1000);
        expect(json['model_used'], 'gpt-4');
        expect(json['tokens_used'], 50);
      });
    });

    group('RAGOptions', () {
      test('should create with default values', () {
        // Act
        final options = RAGOptions();

        // Assert
        expect(options.useRAG, true);
        expect(options.streaming, true);
        expect(options.persistMessages, true);
        expect(options.consent, true);
        expect(options.contextLimit, 5);
        expect(options.temperature, 0.7);
        expect(options.maxTokens, 1000);
        expect(options.ragFilters, null);
      });

      test('should create with custom values', () {
        // Act
        final options = RAGOptions(
          useRAG: false,
          streaming: false,
          persistMessages: false,
          consent: false,
          contextLimit: 10,
          temperature: 0.5,
          maxTokens: 2000,
          ragFilters: {'type': 'journal'},
        );

        // Assert
        expect(options.useRAG, false);
        expect(options.streaming, false);
        expect(options.persistMessages, false);
        expect(options.consent, false);
        expect(options.contextLimit, 10);
        expect(options.temperature, 0.5);
        expect(options.maxTokens, 2000);
        expect(options.ragFilters, {'type': 'journal'});
      });

      test('should convert to JSON successfully', () {
        // Arrange
        final options = RAGOptions(
          useRAG: true,
          streaming: true,
          persistMessages: true,
          consent: true,
          contextLimit: 5,
          temperature: 0.7,
          maxTokens: 1000,
          ragFilters: {'type': 'journal'},
        );

        // Act
        final json = options.toJson();

        // Assert
        expect(json['use_rag'], true);
        expect(json['streaming'], true);
        expect(json['persist_messages'], true);
        expect(json['consent'], true);
        expect(json['context_limit'], 5);
        expect(json['temperature'], 0.7);
        expect(json['max_tokens'], 1000);
        expect(json['rag_filters'], {'type': 'journal'});
      });

      test('should copy with new values', () {
        // Arrange
        final original = RAGOptions(
          useRAG: true,
          streaming: true,
          contextLimit: 5,
        );

        // Act
        final copied = original.copyWith(
          useRAG: false,
          contextLimit: 10,
        );

        // Assert
        expect(copied.useRAG, false);
        expect(copied.streaming, true); // Unchanged
        expect(copied.contextLimit, 10);
        expect(copied.temperature, 0.7); // Default value
      });
    });

    group('ChatMetadata', () {
      test('should create with default values', () {
        // Act
        final metadata = ChatMetadata();

        // Assert
        expect(metadata.purpose, 'chat');
        expect(metadata.sessionType, 'conversation');
        expect(metadata.userAgent, 'MindHearth/1.0');
        expect(metadata.timestamp, isA<DateTime>());
      });

      test('should create with custom values', () {
        // Arrange
        final timestamp = DateTime(2024, 12, 1, 10, 30);

        // Act
        final metadata = ChatMetadata(
          purpose: 'therapy',
          sessionType: 'session',
          userAgent: 'MindHearth/2.0',
          timestamp: timestamp,
        );

        // Assert
        expect(metadata.purpose, 'therapy');
        expect(metadata.sessionType, 'session');
        expect(metadata.userAgent, 'MindHearth/2.0');
        expect(metadata.timestamp, timestamp);
      });

      test('should convert to JSON successfully', () {
        // Arrange
        final timestamp = DateTime(2024, 12, 1, 10, 30);
        final metadata = ChatMetadata(
          purpose: 'therapy',
          sessionType: 'session',
          userAgent: 'MindHearth/2.0',
          timestamp: timestamp,
        );

        // Act
        final json = metadata.toJson();

        // Assert
        expect(json['purpose'], 'therapy');
        expect(json['session_type'], 'session');
        expect(json['user_agent'], 'MindHearth/2.0');
        expect(json['timestamp'], '2024-12-01T10:30:00.000');
      });

      test('should copy with new values', () {
        // Arrange
        final original = ChatMetadata(
          purpose: 'chat',
          sessionType: 'conversation',
        );

        // Act
        final copied = original.copyWith(
          purpose: 'therapy',
          userAgent: 'MindHearth/2.0',
        );

        // Assert
        expect(copied.purpose, 'therapy');
        expect(copied.sessionType, 'conversation'); // Unchanged
        expect(copied.userAgent, 'MindHearth/2.0');
        expect(copied.timestamp, isA<DateTime>());
      });
    });

    group('ChatMode', () {
      test('should have correct enum values', () {
        // Assert
        expect(ChatMode.auto.name, 'auto');
        expect(ChatMode.standard.name, 'standard');
        expect(ChatMode.streaming.name, 'streaming');
        expect(ChatMode.persistent.name, 'persistent');
      });
    });
  });
}
