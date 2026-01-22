import 'package:flutter_test/flutter_test.dart';
import 'package:mindhearth/core/services/unified_chat_service.dart';
import 'package:mindhearth/core/services/api_service.dart';
import 'package:mindhearth/core/models/unified_chat_models.dart';
import 'package:mindhearth/core/models/api_response.dart';

void main() {
  group('UnifiedChatService', () {
    late UnifiedChatService service;
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
      service = UnifiedChatService(apiService: apiService);
    });

    group('sendMessage', () {
      test('should send message successfully', () async {
        // Arrange
        when(mockApiService.post(any, any)).thenAnswer(
          (_) async => ApiSuccess(data: {
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
          }),
        );

        // Act
        final response = await service.sendMessage(
          message: 'Hello',
          sessionId: 'session_123',
        );

        // Assert
        expect(response.success, true);
        expect(response.data?.response, 'Hello! How can I help you?');
        expect(response.data?.sources, isEmpty);
        expect(response.data?.ragMetadata.ragEnabled, false);
      });

      test('should handle RAG context', () async {
        // Arrange
        when(mockApiService.post(any, any)).thenAnswer(
          (_) async => ApiSuccess(data: {
            'success': true,
            'data': {
              'communication_id': 'comm_123',
              'session_id': 'session_123',
              'response': 'Based on your journal entries...',
              'mode': 'standard',
              'sources': [
                {
                  'id': 'source_1',
                  'type': 'journal',
                  'content': 'Previous journal entry...',
                  'relevance_score': 0.95,
                  'metadata': {},
                },
              ],
              'rag_metadata': {
                'context_retrieved': 1,
                'total_sources': 5,
                'retrieval_time_ms': 150,
                'rag_enabled': true,
                'data_sources': ['journal'],
              },
              'message_metadata': {
                'message_id': 'msg_123',
                'timestamp': '2024-12-01T10:30:00Z',
                'processing_time_ms': 1200,
                'model_used': 'gpt-4',
                'tokens_used': 100,
              },
            },
          }),
        );

        // Act
        final response = await service.sendMessage(
          message: 'Tell me about my previous entries',
          sessionId: 'session_123',
          ragOptions: RAGOptions(useRAG: true),
        );

        // Assert
        expect(response.success, true);
        expect(response.data?.sources, hasLength(1));
        expect(response.data?.ragMetadata.ragEnabled, true);
        expect(response.data?.sources.first.type, 'journal');
        expect(response.data?.sources.first.relevanceScore, 0.95);
      });

      test('should handle errors gracefully', () async {
        // Arrange
        when(mockApiService.post(any, any)).thenAnswer(
          (_) async => ApiError(
            message: 'Insufficient credits',
            statusCode: 402,
          ),
        );

        // Act
        final response = await service.sendMessage(
          message: 'Hello',
          sessionId: 'session_123',
        );

        // Assert
        expect(response.success, false);
        expect(response.error?.code, 'API_ERROR');
        expect(response.error?.message, 'Insufficient credits');
      });

      test('should handle network errors', () async {
        // Arrange
        when(mockApiService.post(any, any)).thenThrow(Exception('Network error'));

        // Act
        final response = await service.sendMessage(
          message: 'Hello',
          sessionId: 'session_123',
        );

        // Assert
        expect(response.success, false);
        expect(response.error?.code, 'NETWORK_ERROR');
        expect(response.error?.message, contains('Network error'));
      });
    });

    group('sendStreamingMessage', () {
      test('should handle streaming response', () async {
        // Arrange
        when(mockApiService.postStream(any, any)).thenAnswer(
          (_) async => ApiSuccess(data: Stream.value({
            'success': true,
            'data': {
              'communication_id': 'comm_123',
              'session_id': 'session_123',
              'response': 'Streaming response...',
              'mode': 'streaming',
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
                'processing_time_ms': 500,
                'model_used': 'gpt-4',
                'tokens_used': 25,
              },
            },
          })),
        );

        // Act
        final stream = service.sendStreamingMessage(
          message: 'Hello',
          sessionId: 'session_123',
        );

        // Assert
        final responses = await stream.toList();
        expect(responses, hasLength(1));
        expect(responses.first.success, true);
        expect(responses.first.data?.response, 'Streaming response...');
      });

      test('should handle streaming errors', () async {
        // Arrange
        when(mockApiService.postStream(any, any)).thenAnswer(
          (_) async => ApiError(
            message: 'Streaming failed',
            statusCode: 500,
          ),
        );

        // Act
        final stream = service.sendStreamingMessage(
          message: 'Hello',
          sessionId: 'session_123',
        );

        // Assert
        final responses = await stream.toList();
        expect(responses, hasLength(1));
        expect(responses.first.success, false);
        expect(responses.first.error?.code, 'STREAMING_ERROR');
        expect(responses.first.error?.message, 'Streaming failed');
      });
    });

    group('sendBatchMessages', () {
      test('should send multiple messages', () async {
        // Arrange
        when(mockApiService.post(any, any)).thenAnswer(
          (_) async => ApiSuccess(data: {
            'success': true,
            'data': {
              'communication_id': 'comm_123',
              'session_id': 'session_123',
              'response': 'Response to batch message',
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
          }),
        );

        // Act
        final responses = await service.sendBatchMessages(
          messages: ['Hello', 'How are you?'],
          sessionId: 'session_123',
        );

        // Assert
        expect(responses, hasLength(2));
        expect(responses.every((r) => r.success), true);
        expect(mockApiService.post(any, any), returnNormally);
      });
    });

    group('getChatHistory', () {
      test('should retrieve chat history', () async {
        // Arrange
        when(mockApiService.get(any, queryParameters: anyNamed('queryParameters'))).thenAnswer(
          (_) async => ApiSuccess(data: {
            'success': true,
            'data': {
              'communication_id': '',
              'session_id': 'session_123',
              'response': 'History retrieved',
              'mode': 'history',
              'sources': [],
              'rag_metadata': {
                'context_retrieved': 0,
                'total_sources': 0,
                'retrieval_time_ms': 0,
                'rag_enabled': false,
                'data_sources': [],
              },
              'message_metadata': {
                'message_id': 'history_123',
                'timestamp': '2024-12-01T10:30:00Z',
                'processing_time_ms': 0,
                'model_used': 'history',
                'tokens_used': 0,
              },
            },
          }),
        );

        // Act
        final response = await service.getChatHistory(
          sessionId: 'session_123',
          limit: 10,
        );

        // Assert
        expect(response.success, true);
        expect(response.data?.mode, 'history');
      });
    });
  });
}
