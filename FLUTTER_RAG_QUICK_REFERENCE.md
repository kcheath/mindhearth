# Flutter RAG Quick Reference

## 🚀 Quick Start

### 1. RAG Chat (Simple)
```dart
final response = await ragService.ragChat(
  message: "What are my recent thoughts?",
  contextLimit: 5,
);
print(response.response); // AI response with context
print(response.sources.length); // Number of sources used
```

### 2. RAG Chat (Streaming)
```dart
await for (final chunk in ragService.streamRAGChat(
  message: "Summarize my week",
  contextLimit: 10,
)) {
  if (chunk['type'] == 'content') {
    print(chunk['delta']); // Stream the response
  }
}
```

### 3. Generate Report
```dart
final report = await reportService.generateComprehensiveReport(
  startDate: DateTime.now().subtract(Duration(days: 30)),
  endDate: DateTime.now(),
  includeSources: true,
);
print(report.summary);
```

## 📋 API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/chat/rag` | POST | RAG chat (non-streaming) |
| `/chat/rag/stream` | POST | RAG chat (streaming) |
| `/chat/rag/suggestions` | GET | Get usage suggestions |
| `/reports/comprehensive` | POST | Generate comprehensive report |
| `/reports/timeline` | POST | Generate timeline report |
| `/reports/patterns` | POST | Generate pattern analysis |
| `/rag/status` | GET | Check RAG system status |

## 🔧 Request Examples

### RAG Chat Request
```json
{
  "message": "What patterns do you see in my journal?",
  "session_id": "optional-session-id",
  "use_rag": true,
  "rag_context_limit": 5
}
```

### Report Request
```json
{
  "report_type": "comprehensive",
  "time_range": {
    "start_date": "2024-01-01",
    "end_date": "2024-01-31"
  },
  "include_sources": true,
  "max_sources": 20
}
```

## 📱 UI Components

### Chat Bubble with Sources
```dart
Widget buildChatBubble(ChatMessage message) {
  return Card(
    child: Column(
      children: [
        Text(message.text),
        if (message.sources.isNotEmpty)
          ExpansionTile(
            title: Text('Sources (${message.sources.length})'),
            children: message.sources.map((source) => 
              ListTile(
                title: Text(source.content),
                subtitle: Text('${(source.relevanceScore * 100).toStringAsFixed(1)}% relevant'),
              )
            ).toList(),
          ),
      ],
    ),
  );
}
```

### Suggestions Button
```dart
IconButton(
  icon: Icon(Icons.lightbulb),
  onPressed: () async {
    final suggestions = await ragService.getSuggestions();
    _showSuggestionsDialog(suggestions);
  },
)
```

## 🎯 Common Use Cases

### 1. Personal Insights
```dart
// Ask about patterns in user data
final response = await ragService.ragChat(
  message: "What are my main concerns this week?",
  contextLimit: 10,
);
```

### 2. Data Summarization
```dart
// Summarize recent activity
final response = await ragService.ragChat(
  message: "Summarize my journal entries from last month",
  contextLimit: 15,
);
```

### 3. Trend Analysis
```dart
// Generate pattern report
final report = await reportService.generatePatternReport(
  analysisType: "mood_patterns",
  startDate: DateTime.now().subtract(Duration(days: 90)),
  endDate: DateTime.now(),
);
```

## ⚡ Performance Tips

### 1. Limit Context
```dart
// Use appropriate context limits
final response = await ragService.ragChat(
  message: "Quick question",
  contextLimit: 3, // Faster response
);
```

### 2. Cache Responses
```dart
// Cache frequently asked questions
final cacheKey = "summary_${DateTime.now().day}";
if (cache.containsKey(cacheKey)) {
  return cache[cacheKey];
}
```

### 3. Use Suggestions
```dart
// Pre-populate with suggestions
final suggestions = await ragService.getSuggestions();
// Show in UI for better UX
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

## 📊 Response Structure

### RAG Chat Response
```dart
class RAGChatResponse {
  String response;           // AI response text
  List<Source> sources;      // Retrieved sources
  RAGMetadata metadata;      // Performance info
}
```

### Source Object
```dart
class Source {
  String id;                 // Unique identifier
  String type;               // 'journal', 'chat', 'document'
  String content;            // Source content
  double relevanceScore;     // 0.0 to 1.0
  Map<String, dynamic> metadata; // Additional info
}
```

## 🔍 Debugging

### Check RAG Status
```dart
final status = await ragService.getStatus();
print('Total documents: ${status.totalDocuments}');
print('Last indexed: ${status.lastIndexed}');
```

### Monitor Performance
```dart
final response = await ragService.ragChat(message: "test");
print('Retrieval time: ${response.metadata.retrievalTimeMs}ms');
print('Sources used: ${response.metadata.contextRetrieved}');
```

## 📚 Additional Resources

- [Full Integration Guide](./FLUTTER_RAG_INTEGRATION_GUIDE.md)
- [API Documentation](./API_CHANGES_FRONTEND.md)
- [RAG Implementation Guide](./RAG_IMPLEMENTATION_GUIDE.md)

## 🆘 Support

For questions or issues:
1. Check the full integration guide
2. Review API documentation
3. Contact the backend team
4. Check system status: `GET /rag/status`
