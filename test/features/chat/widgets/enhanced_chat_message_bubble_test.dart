import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindhearth/features/chat/widgets/enhanced_chat_message_bubble.dart';
import 'package:mindhearth/features/chat/domain/entities/chat_message.dart';
import 'package:mindhearth/core/models/unified_chat_models.dart';

void main() {
  group('EnhancedChatMessageBubble', () {
    testWidgets('should display user message correctly', (tester) async {
      // Arrange
      final message = ChatMessage(
        id: 'user_123',
        sessionId: 'session_123',
        content: 'Hello, how are you?',
        role: 'user',
        timestamp: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedChatMessageBubble(
              message: message,
              isUser: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Hello, how are you?'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should display AI message correctly', (tester) async {
      // Arrange
      final message = ChatMessage(
        id: 'ai_123',
        sessionId: 'session_123',
        content: 'I am doing well, thank you for asking!',
        role: 'assistant',
        timestamp: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedChatMessageBubble(
              message: message,
              isUser: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('I am doing well, thank you for asking!'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget); // MindHearth logo
    });

    testWidgets('should display RAG sources when available', (tester) async {
      // Arrange
      final message = ChatMessage(
        id: 'ai_123',
        sessionId: 'session_123',
        content: 'Based on your journal entries...',
        role: 'assistant',
        timestamp: DateTime.now(),
        metadata: {
          'sources': [
            {
              'id': 'source_1',
              'type': 'journal',
              'content': 'Previous journal entry content...',
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
        },
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedChatMessageBubble(
              message: message,
              isUser: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Sources (1)'), findsOneWidget);
      expect(find.text('Previous journal entry content...'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (tester) async {
      // Arrange
      final message = ChatMessage(
        id: 'ai_123',
        sessionId: 'session_123',
        content: '',
        role: 'assistant',
        timestamp: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedChatMessageBubble(
              message: message,
              isUser: false,
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Mindhearth is thinking...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle action buttons', (tester) async {
      // Arrange
      final message = ChatMessage(
        id: 'ai_123',
        sessionId: 'session_123',
        content: 'Test message',
        role: 'assistant',
        timestamp: DateTime.now(),
      );

      bool copyCalled = false;
      bool saveCalled = false;
      bool shareCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedChatMessageBubble(
              message: message,
              isUser: false,
              onCopy: () => copyCalled = true,
              onSave: () => saveCalled = true,
              onShare: () => shareCalled = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.copy), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);

      // Test button interactions
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();
      expect(copyCalled, true);

      await tester.tap(find.byIcon(Icons.bookmark_border));
      await tester.pump();
      expect(saveCalled, true);

      await tester.tap(find.byIcon(Icons.share));
      await tester.pump();
      expect(shareCalled, true);
    });

    testWidgets('should format timestamp correctly', (tester) async {
      // Arrange
      final now = DateTime.now();
      final message = ChatMessage(
        id: 'user_123',
        sessionId: 'session_123',
        content: 'Test message',
        role: 'user',
        timestamp: now,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedChatMessageBubble(
              message: message,
              isUser: true,
              timestamp: now,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Just now'), findsOneWidget);
    });
  });

  group('RAGSourcesWidget', () {
    testWidgets('should display sources correctly', (tester) async {
      // Arrange
      final sources = [
        SourceDocument(
          id: 'source_1',
          type: 'journal',
          content: 'Journal entry content...',
          relevanceScore: 0.95,
          metadata: {},
        ),
        SourceDocument(
          id: 'source_2',
          type: 'chat',
          content: 'Previous chat message...',
          relevanceScore: 0.87,
          metadata: {},
        ),
      ];

      final ragMetadata = RAGMetadata(
        contextRetrieved: 2,
        totalSources: 5,
        retrievalTimeMs: 150,
        ragEnabled: true,
        dataSources: ['journal', 'chat'],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RAGSourcesWidget(
              sources: sources,
              ragMetadata: ragMetadata,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Sources (2)'), findsOneWidget);
      expect(find.text('2/5'), findsOneWidget);
      expect(find.text('Journal entry content...'), findsOneWidget);
      expect(find.text('Previous chat message...'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);
      expect(find.text('87%'), findsOneWidget);
    });

    testWidgets('should hide when no sources', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RAGSourcesWidget(
              sources: [],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Sources (0)'), findsNothing);
      expect(find.text('Sources'), findsNothing);
    });
  });

  group('SourceDocumentTile', () {
    testWidgets('should display source document correctly', (tester) async {
      // Arrange
      final source = SourceDocument(
        id: 'source_1',
        type: 'journal',
        content: 'This is a long journal entry that should be truncated when displayed in the tile...',
        relevanceScore: 0.95,
        metadata: {},
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceDocumentTile(
              source: source,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('This is a long journal entry that should be truncated when displayed in the tile...'), findsOneWidget);
      expect(find.text('journal'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);
      expect(find.byIcon(Icons.book), findsOneWidget);
    });

    testWidgets('should show correct icon for different source types', (tester) async {
      // Test journal icon
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceDocumentTile(
              source: SourceDocument(
                id: '1',
                type: 'journal',
                content: 'test',
                relevanceScore: 0.5,
                metadata: {},
              ),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.book), findsOneWidget);

      // Test chat icon
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceDocumentTile(
              source: SourceDocument(
                id: '2',
                type: 'chat',
                content: 'test',
                relevanceScore: 0.5,
                metadata: {},
              ),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.chat), findsOneWidget);

      // Test document icon
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceDocumentTile(
              source: SourceDocument(
                id: '3',
                type: 'document',
                content: 'test',
                relevanceScore: 0.5,
                metadata: {},
              ),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.description), findsOneWidget);

      // Test profile icon
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceDocumentTile(
              source: SourceDocument(
                id: '4',
                type: 'profile',
                content: 'test',
                relevanceScore: 0.5,
                metadata: {},
              ),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.person), findsOneWidget);

      // Test default icon
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SourceDocumentTile(
              source: SourceDocument(
                id: '5',
                type: 'unknown',
                content: 'test',
                relevanceScore: 0.5,
                metadata: {},
              ),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.article), findsOneWidget);
    });
  });
}
