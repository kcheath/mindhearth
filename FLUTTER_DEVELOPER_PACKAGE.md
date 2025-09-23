# Flutter Developer Package for RAG Integration

## 📦 What's Included

This package contains everything Flutter developers need to integrate RAG (Retrieval-Augmented Generation) capabilities into the Tsukiyo platform.

### 📚 Documentation Files

1. **[FLUTTER_RAG_INTEGRATION_GUIDE.md](./FLUTTER_RAG_INTEGRATION_GUIDE.md)**
   - Complete integration guide
   - API endpoints and request/response examples
   - Data models and service implementations
   - UI components and best practices

2. **[FLUTTER_RAG_QUICK_REFERENCE.md](./FLUTTER_RAG_QUICK_REFERENCE.md)**
   - Quick reference for common tasks
   - Code snippets and examples
   - API endpoint summary
   - Performance tips

3. **[FLUTTER_RAG_EXAMPLE_IMPLEMENTATION.md](./FLUTTER_RAG_EXAMPLE_IMPLEMENTATION.md)**
   - Practical example showing before/after
   - Complete chat screen implementation
   - Enhanced UI components
   - Service integration

## 🚀 Quick Start

### 1. Add Dependencies
```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.0
```

### 2. Basic RAG Chat
```dart
final ragService = RAGChatService(
  baseUrl: 'https://your-api.com',
  authToken: 'your-auth-token',
);

final response = await ragService.ragChat(
  message: "What are my recent thoughts?",
  contextLimit: 5,
);
```

### 3. Generate Reports
```dart
final reportService = ReportService(
  baseUrl: 'https://your-api.com',
  authToken: 'your-auth-token',
);

final report = await reportService.generateComprehensiveReport(
  startDate: DateTime.now().subtract(Duration(days: 30)),
  endDate: DateTime.now(),
);
```

## 🎯 Key Features

### RAG-Enhanced Chat
- **Personalized Responses**: AI uses your personal data as context
- **Source Transparency**: See what sources were used
- **Relevance Scoring**: Sources ranked by relevance
- **Streaming Support**: Real-time response streaming

### Report Generation
- **Comprehensive Reports**: Full analysis with citations
- **Timeline Reports**: Chronological data analysis
- **Pattern Analysis**: Identify trends and patterns
- **Customizable Time Ranges**: Flexible date selection

### RAG Management
- **Status Monitoring**: Check RAG system health
- **Content Reindexing**: Refresh knowledge base
- **Usage Suggestions**: Pre-populated questions
- **Performance Metrics**: Track retrieval performance

## 📱 UI Components

### Chat Screen Enhancements
- RAG toggle switch
- Context limit slider
- Source display with relevance scores
- Suggestions button
- Performance indicators

### Report Display
- Expandable source sections
- Relevance score indicators
- Time range selectors
- Export functionality

## 🔧 API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/chat/rag` | POST | RAG chat (non-streaming) |
| `/chat/rag/stream` | POST | RAG chat (streaming) |
| `/chat/rag/suggestions` | GET | Get usage suggestions |
| `/reports/comprehensive` | POST | Generate comprehensive report |
| `/reports/timeline` | POST | Generate timeline report |
| `/reports/patterns` | POST | Generate pattern analysis |
| `/rag/status` | GET | Check RAG system status |
| `/rag/reindex` | POST | Reindex content |
| `/rag/knowledge-base/summary` | GET | Get knowledge base summary |

## 📊 Response Examples

### RAG Chat Response
```json
{
  "response": "Based on your recent journal entries, I can see you've been focusing on...",
  "sources": [
    {
      "id": "journal_123",
      "type": "journal",
      "content": "Today I worked on...",
      "relevance_score": 0.95,
      "metadata": {
        "created_at": "2024-01-15T10:30:00Z",
        "session_id": "session_456"
      }
    }
  ],
  "rag_metadata": {
    "context_retrieved": 5,
    "total_sources": 12,
    "retrieval_time_ms": 150
  }
}
```

### Report Response
```json
{
  "report": {
    "title": "Comprehensive Report - January 2024",
    "summary": "This report covers your activity and insights...",
    "sections": [
      {
        "title": "Journal Insights",
        "content": "Your journal entries show a focus on...",
        "sources": [...]
      }
    ],
    "metadata": {
      "generated_at": "2024-01-31T15:30:00Z",
      "total_sources": 15,
      "time_range": "2024-01-01 to 2024-01-31"
    }
  }
}
```

## 🎨 UI Implementation

### Before: Regular Chat
```dart
class ChatScreen extends StatefulWidget {
  // Basic chat implementation
}
```

### After: RAG-Enhanced Chat
```dart
class RAGChatScreen extends StatefulWidget {
  // Enhanced with RAG capabilities
  // - RAG toggle
  // - Context limit slider
  // - Source display
  // - Suggestions
  // - Performance metrics
}
```

## 🔍 Testing

### Unit Tests
```dart
test('should return RAG response with sources', () async {
  final mockService = MockRAGService();
  final response = await mockService.ragChat(message: 'test');
  expect(response.sources.length, greaterThan(0));
});
```

### Integration Tests
```dart
testWidgets('RAG chat displays sources', (tester) async {
  await tester.pumpWidget(RAGChatScreen());
  await tester.enterText(find.byType(TextField), 'test message');
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();
  expect(find.text('Sources'), findsOneWidget);
});
```

## 📈 Performance Considerations

### Caching
```dart
class RAGCache {
  static final Map<String, RAGChatResponse> _cache = {};
  
  static RAGChatResponse? getCachedResponse(String message) {
    return _cache[message];
  }
}
```

### Rate Limiting
```dart
class RAGRateLimiter {
  static const Duration _cooldown = Duration(seconds: 1);
  static bool canMakeRequest(String endpoint) {
    // Implementation
  }
}
```

### Offline Support
```dart
class RAGOfflineSupport {
  static Future<void> saveOfflineMessage(String message) async {
    // Save for later processing
  }
}
```

## 🚨 Error Handling

```dart
try {
  final response = await ragService.ragChat(message: "test");
} catch (e) {
  if (e is TimeoutException) {
    // Handle timeout
  } else if (e is http.ClientException) {
    // Handle network error
  } else {
    // Handle other errors
  }
}
```

## 📋 Checklist for Implementation

### Phase 1: Basic Integration
- [ ] Add HTTP dependencies
- [ ] Implement RAG service class
- [ ] Create data models
- [ ] Add basic RAG chat functionality

### Phase 2: UI Enhancement
- [ ] Add RAG toggle to chat screen
- [ ] Implement source display
- [ ] Add context limit control
- [ ] Create suggestions feature

### Phase 3: Advanced Features
- [ ] Implement report generation
- [ ] Add streaming support
- [ ] Create performance monitoring
- [ ] Add offline support

### Phase 4: Testing & Optimization
- [ ] Write unit tests
- [ ] Add integration tests
- [ ] Implement caching
- [ ] Add error handling

## 🆘 Support & Resources

### Documentation
- [Full Integration Guide](./FLUTTER_RAG_INTEGRATION_GUIDE.md)
- [Quick Reference](./FLUTTER_RAG_QUICK_REFERENCE.md)
- [Example Implementation](./FLUTTER_RAG_EXAMPLE_IMPLEMENTATION.md)

### API Reference
- [API Changes for Frontend](./API_CHANGES_FRONTEND.md)
- [RAG Implementation Guide](./RAG_IMPLEMENTATION_GUIDE.md)

### Backend Support
- Check system status: `GET /rag/status`
- Monitor performance: `GET /rag/knowledge-base/summary`
- Reindex content: `POST /rag/reindex`

## 🎉 Benefits

### For Users
- **Personalized AI**: Responses based on their personal data
- **Transparency**: See what sources were used
- **Control**: Adjust RAG settings
- **Insights**: Generate comprehensive reports

### For Developers
- **Easy Integration**: Simple API calls
- **Flexible UI**: Customizable components
- **Performance**: Built-in caching and optimization
- **Testing**: Comprehensive test examples

## 📞 Contact

For questions or support:
1. Review the documentation
2. Check the quick reference
3. Look at example implementations
4. Contact the backend team

---

**Ready to enhance your Flutter app with RAG capabilities? Start with the [Quick Reference](./FLUTTER_RAG_QUICK_REFERENCE.md) and then dive into the [Full Integration Guide](./FLUTTER_RAG_INTEGRATION_GUIDE.md)!**
