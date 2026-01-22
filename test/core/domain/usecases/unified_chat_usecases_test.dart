import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mindhearth/core/domain/usecases/unified_chat_usecases.dart';
import 'package:mindhearth/core/domain/repositories/chat_repository.dart';
import 'package:mindhearth/core/domain/entities/result.dart';
import 'package:mindhearth/core/models/unified_chat_models.dart';

import 'unified_chat_usecases_test.mocks.dart';

@GenerateMocks([ChatRepository])
void main() {
  group('Unified Chat Use Cases', () {
    late MockChatRepository mockRepository;

    setUp(() {
      mockRepository = MockChatRepository();
    });

    group('SendUnifiedMessageUseCase', () {
      test('should send unified message successfully', () async {
        // Arrange
        final useCase = SendUnifiedMessageUseCase(mockRepository);
        final expectedResponse = UnifiedChatResponse(
          success: true,
          data: UnifiedChatData(
            communicationId: 'comm_123',
            sessionId: 'session_123',
            response: 'Hello! How can I help you?',
            mode: 'standard',
            sources: [],
            ragMetadata: const RAGMetadata(
              contextRetrieved: 0,
              totalSources: 0,
              retrievalTimeMs: 0,
              ragEnabled: false,
              dataSources: [],
            ),
            messageMetadata: MessageMetadata(
              messageId: 'msg_123',
              timestamp: DateTime.now(),
              processingTimeMs: 1000,
              modelUsed: 'gpt-4',
              tokensUsed: 50,
            ),
          ),
        );

        when(mockRepository.sendUnifiedMessage(
          message: anyNamed('message'),
          sessionId: anyNamed('sessionId'),
          mode: anyNamed('mode'),
          ragOptions: anyNamed('ragOptions'),
          metadata: anyNamed('metadata'),
          conversationHistory: anyNamed('conversationHistory'),
        )).thenAnswer((_) async => Result.success(expectedResponse));

        // Act
        final result = await useCase(
          message: 'Hello',
          sessionId: 'session_123',
          mode: ChatMode.standard,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.success, true);
        expect(result.data?.data?.response, 'Hello! How can I help you?');
        verify(mockRepository.sendUnifiedMessage(
          message: 'Hello',
          sessionId: 'session_123',
          mode: ChatMode.standard,
          ragOptions: null,
          metadata: null,
          conversationHistory: null,
        )).called(1);
      });

      test('should handle repository errors', () async {
        // Arrange
        final useCase = SendUnifiedMessageUseCase(mockRepository);
        when(mockRepository.sendUnifiedMessage(
          message: anyNamed('message'),
          sessionId: anyNamed('sessionId'),
          mode: anyNamed('mode'),
          ragOptions: anyNamed('ragOptions'),
          metadata: anyNamed('metadata'),
          conversationHistory: anyNamed('conversationHistory'),
        )).thenAnswer((_) async => Result.failure(AppErrorFactory.network(message: 'Network error')));

        // Act
        final result = await useCase(
          message: 'Hello',
          sessionId: 'session_123',
        );

        // Assert
        expect(result.isFailure, true);
        expect(result.error?.message, 'Network error');
      });

      test('should handle exceptions', () async {
        // Arrange
        final useCase = SendUnifiedMessageUseCase(mockRepository);
        when(mockRepository.sendUnifiedMessage(
          message: anyNamed('message'),
          sessionId: anyNamed('sessionId'),
          mode: anyNamed('mode'),
          ragOptions: anyNamed('ragOptions'),
          metadata: anyNamed('metadata'),
          conversationHistory: anyNamed('conversationHistory'),
        )).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await useCase(
          message: 'Hello',
          sessionId: 'session_123',
        );

        // Assert
        expect(result.isFailure, true);
        expect(result.error?.message, contains('Unexpected error'));
      });
    });

    group('SendUnifiedStreamingMessageUseCase', () {
      test('should send streaming message successfully', () async {
        // Arrange
        final useCase = SendUnifiedStreamingMessageUseCase(mockRepository);
        final stream = Stream.value(UnifiedChatResponse(
          success: true,
          data: UnifiedChatData(
            communicationId: 'comm_123',
            sessionId: 'session_123',
            response: 'Streaming response...',
            mode: 'streaming',
            sources: [],
            ragMetadata: const RAGMetadata(
              contextRetrieved: 0,
              totalSources: 0,
              retrievalTimeMs: 0,
              ragEnabled: false,
              dataSources: [],
            ),
            messageMetadata: MessageMetadata(
              messageId: 'msg_123',
              timestamp: DateTime.now(),
              processingTimeMs: 500,
              modelUsed: 'gpt-4',
              tokensUsed: 25,
            ),
          ),
        ));

        when(mockRepository.sendUnifiedStreamingMessage(
          message: anyNamed('message'),
          sessionId: anyNamed('sessionId'),
          ragOptions: anyNamed('ragOptions'),
          metadata: anyNamed('metadata'),
          conversationHistory: anyNamed('conversationHistory'),
        )).thenAnswer((_) async => Result.success(stream));

        // Act
        final result = await useCase(
          message: 'Hello',
          sessionId: 'session_123',
        );

        // Assert
        expect(result.isSuccess, true);
        final responses = await result.data!.toList();
        expect(responses, hasLength(1));
        expect(responses.first.success, true);
        expect(responses.first.data?.response, 'Streaming response...');
      });
    });

    group('SendBatchMessagesUseCase', () {
      test('should send batch messages successfully', () async {
        // Arrange
        final useCase = SendBatchMessagesUseCase(mockRepository);
        final expectedResponses = [
          UnifiedChatResponse(
            success: true,
            data: UnifiedChatData(
              communicationId: 'comm_1',
              sessionId: 'session_123',
              response: 'Response 1',
              mode: 'standard',
              sources: [],
              ragMetadata: const RAGMetadata(
                contextRetrieved: 0,
                totalSources: 0,
                retrievalTimeMs: 0,
                ragEnabled: false,
                dataSources: [],
              ),
              messageMetadata: MessageMetadata(
                messageId: 'msg_1',
                timestamp: DateTime.now(),
                processingTimeMs: 1000,
                modelUsed: 'gpt-4',
                tokensUsed: 50,
              ),
            ),
          ),
          UnifiedChatResponse(
            success: true,
            data: UnifiedChatData(
              communicationId: 'comm_2',
              sessionId: 'session_123',
              response: 'Response 2',
              mode: 'standard',
              sources: [],
              ragMetadata: const RAGMetadata(
                contextRetrieved: 0,
                totalSources: 0,
                retrievalTimeMs: 0,
                ragEnabled: false,
                dataSources: [],
              ),
              messageMetadata: MessageMetadata(
                messageId: 'msg_2',
                timestamp: DateTime.now(),
                processingTimeMs: 1000,
                modelUsed: 'gpt-4',
                tokensUsed: 50,
              ),
            ),
          ),
        ];

        when(mockRepository.sendBatchMessages(
          messages: anyNamed('messages'),
          sessionId: anyNamed('sessionId'),
          ragOptions: anyNamed('ragOptions'),
          metadata: anyNamed('metadata'),
        )).thenAnswer((_) async => Result.success(expectedResponses));

        // Act
        final result = await useCase(
          messages: ['Hello', 'How are you?'],
          sessionId: 'session_123',
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, hasLength(2));
        expect(result.data!.first.data?.response, 'Response 1');
        expect(result.data!.last.data?.response, 'Response 2');
      });
    });

    group('GetUnifiedChatHistoryUseCase', () {
      test('should get chat history successfully', () async {
        // Arrange
        final useCase = GetUnifiedChatHistoryUseCase(mockRepository);
        final expectedResponse = UnifiedChatResponse(
          success: true,
          data: UnifiedChatData(
            communicationId: '',
            sessionId: 'session_123',
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
              messageId: 'history_123',
              timestamp: DateTime.now(),
              processingTimeMs: 0,
              modelUsed: 'history',
              tokensUsed: 0,
            ),
          ),
        );

        when(mockRepository.getUnifiedChatHistory(
          sessionId: anyNamed('sessionId'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => Result.success(expectedResponse));

        // Act
        final result = await useCase(
          sessionId: 'session_123',
          limit: 10,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.data?.data?.mode, 'history');
      });
    });

    group('CreateRAGOptionsUseCase', () {
      test('should create RAG options with default values', () {
        // Arrange
        final useCase = CreateRAGOptionsUseCase();

        // Act
        final options = useCase();

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

      test('should create RAG options with custom values', () {
        // Arrange
        final useCase = CreateRAGOptionsUseCase();

        // Act
        final options = useCase(
          useRAG: false,
          streaming: false,
          contextLimit: 10,
          temperature: 0.5,
          ragFilters: {'type': 'journal'},
        );

        // Assert
        expect(options.useRAG, false);
        expect(options.streaming, false);
        expect(options.contextLimit, 10);
        expect(options.temperature, 0.5);
        expect(options.ragFilters, {'type': 'journal'});
      });
    });

    group('CreateChatMetadataUseCase', () {
      test('should create chat metadata with default values', () {
        // Arrange
        final useCase = CreateChatMetadataUseCase();

        // Act
        final metadata = useCase();

        // Assert
        expect(metadata.purpose, 'chat');
        expect(metadata.sessionType, 'conversation');
        expect(metadata.userAgent, 'MindHearth/1.0');
        expect(metadata.timestamp, isA<DateTime>());
      });

      test('should create chat metadata with custom values', () {
        // Arrange
        final useCase = CreateChatMetadataUseCase();
        final customTimestamp = DateTime(2024, 1, 1);

        // Act
        final metadata = useCase(
          purpose: 'therapy',
          sessionType: 'session',
          userAgent: 'MindHearth/2.0',
          timestamp: customTimestamp,
        );

        // Assert
        expect(metadata.purpose, 'therapy');
        expect(metadata.sessionType, 'session');
        expect(metadata.userAgent, 'MindHearth/2.0');
        expect(metadata.timestamp, customTimestamp);
      });
    });

    group('SelectChatModeUseCase', () {
      test('should select auto mode when RAG and streaming enabled', () {
        // Arrange
        final useCase = SelectChatModeUseCase();

        // Act
        final mode = useCase(
          message: 'Test message',
          useRAG: true,
          streaming: true,
        );

        // Assert
        expect(mode, ChatMode.auto);
      });

      test('should select streaming mode when only streaming enabled', () {
        // Arrange
        final useCase = SelectChatModeUseCase();

        // Act
        final mode = useCase(
          message: 'Test message',
          useRAG: false,
          streaming: true,
        );

        // Assert
        expect(mode, ChatMode.streaming);
      });

      test('should select streaming mode for long messages', () {
        // Arrange
        final useCase = SelectChatModeUseCase();

        // Act
        final mode = useCase(
          message: 'x' * 1001, // Long message
          useRAG: false,
          streaming: false,
          messageLength: 1001,
        );

        // Assert
        expect(mode, ChatMode.streaming);
      });

      test('should select standard mode for short messages', () {
        // Arrange
        final useCase = SelectChatModeUseCase();

        // Act
        final mode = useCase(
          message: 'Short message',
          useRAG: false,
          streaming: false,
          messageLength: 50,
        );

        // Assert
        expect(mode, ChatMode.standard);
      });
    });
  });
}





