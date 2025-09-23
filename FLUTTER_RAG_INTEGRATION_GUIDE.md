# Flutter RAG Integration Guide

This guide shows Flutter developers how to integrate and use the RAG (Retrieval-Augmented Generation) capabilities in the Tsukiyo platform.

## Table of Contents
- [Overview](#overview)
- [New API Endpoints](#new-api-endpoints)
- [RAG-Enhanced Chat](#rag-enhanced-chat)
- [Report Generation](#report-generation)
- [RAG Management](#rag-management)
- [Code Examples](#code-examples)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)

## Overview

The RAG system enhances AI responses by retrieving relevant user data as context. This provides more personalized and accurate responses based on the user's history.

### Key Features
- **RAG-Enhanced Chat**: Chat with AI using your personal data as context
- **Report Generation**: Generate comprehensive reports with citations
- **Multi-Tenant Isolation**: Data is automatically filtered by user/tenant
- **Automatic Indexing**: User content is automatically indexed for retrieval

## New API Endpoints

### Base URL
All endpoints use the same base URL as your existing API.

### Authentication
All endpoints require the same authentication headers as existing endpoints.

## RAG-Enhanced Chat

### 1. RAG Chat (Streaming)
**Endpoint**: `POST /chat/rag/stream`

**Request Body**:
```json
{
  "message": "What are my recent thoughts about work?",
  "session_id": "optional-session-id",
  "use_rag": true,
  "rag_context_limit": 5
}
```

**Response**: Server-Sent Events (SSE) stream
```
data: {"type": "start", "message": "Starting RAG-enhanced response..."}
data: {"type": "context", "sources": [{"id": "doc_1", "content": "..."}]}
data: {"type": "content", "delta": "Based on your recent journal entries..."}
data: {"type": "end", "message": "Response complete"}
```

### 2. RAG Chat (Non-Streaming)
**Endpoint**: `POST /chat/rag`

**Request Body**:
```json
{
  "message": "Summarize my recent journal entries",
  "session_id": "optional-session-id",
  "use_rag": true,
  "rag_context_limit": 10
}
```

**Response**:
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

### 3. Usage Suggestions
**Endpoint**: `GET /chat/rag/suggestions`

**Response**:
```json
{
  "suggestions": [
    "What patterns do you see in my recent journal entries?",
    "Summarize my thoughts about work this week",
    "What are my main concerns from recent conversations?",
    "How has my mood changed over the past month?"
  ]
}
```

## Report Generation

### 1. Comprehensive Report
**Endpoint**: `POST /reports/comprehensive`

**Request Body**:
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

**Response**:
```json
{
  "report": {
    "title": "Comprehensive Report - January 2024",
    "summary": "This report covers your activity and insights from January 2024...",
    "sections": [
      {
        "title": "Journal Insights",
        "content": "Your journal entries show a focus on...",
        "sources": [
          {
            "id": "journal_123",
            "content": "Today I worked on...",
            "relevance_score": 0.92,
            "metadata": {
              "created_at": "2024-01-15T10:30:00Z",
              "session_id": "session_456"
            }
          }
        ]
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

### 2. Timeline Report
**Endpoint**: `POST /reports/timeline`

**Request Body**:
```json
{
  "time_range": {
    "start_date": "2024-01-01",
    "end_date": "2024-01-31"
  },
  "granularity": "daily"
}
```

### 3. Pattern Analysis Report
**Endpoint**: `POST /reports/patterns`

**Request Body**:
```json
{
  "analysis_type": "mood_patterns",
  "time_range": {
    "start_date": "2024-01-01",
    "end_date": "2024-01-31"
  }
}
```

## RAG Management

### 1. Index Status
**Endpoint**: `GET /rag/status`

**Response**:
```json
{
  "status": "healthy",
  "total_documents": 1250,
  "last_indexed": "2024-01-31T15:30:00Z",
  "indexing_stats": {
    "journals": 800,
    "chats": 300,
    "documents": 150
  }
}
```

### 2. Reindex Content
**Endpoint**: `POST /rag/reindex`

**Request Body**:
```json
{
  "content_types": ["journals", "chats", "documents"],
  "force": false
}
```

### 3. Knowledge Base Summary
**Endpoint**: `GET /rag/knowledge-base/summary`

**Response**:
```json
{
  "summary": "Your knowledge base contains 1250 documents...",
  "breakdown": {
    "journals": 800,
    "chats": 300,
    "documents": 150
  },
  "recent_activity": "Last updated 2 hours ago"
}
```

## Code Examples

### Flutter HTTP Client Setup

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class RAGService {
  final String baseUrl;
  final String authToken;
  
  RAGService({required this.baseUrl, required this.authToken});
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };
}
```

### RAG Chat Implementation

```dart
class RAGChatService extends RAGService {
  // Streaming RAG Chat
  Stream<Map<String, dynamic>> streamRAGChat({
    required String message,
    String? sessionId,
    int contextLimit = 5,
  }) async* {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/rag/stream'),
      headers: _headers,
      body: jsonEncode({
        'message': message,
        'session_id': sessionId,
        'use_rag': true,
        'rag_context_limit': contextLimit,
      }),
    );
    
    if (response.statusCode == 200) {
      final lines = response.body.split('\n');
      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data.isNotEmpty) {
            yield jsonDecode(data);
          }
        }
      }
    }
  }
  
  // Non-streaming RAG Chat
  Future<RAGChatResponse> ragChat({
    required String message,
    String? sessionId,
    int contextLimit = 10,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/rag'),
      headers: _headers,
      body: jsonEncode({
        'message': message,
        'session_id': sessionId,
        'use_rag': true,
        'rag_context_limit': contextLimit,
      }),
    );
    
    if (response.statusCode == 200) {
      return RAGChatResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to get RAG chat response');
  }
  
  // Get usage suggestions
  Future<List<String>> getSuggestions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/rag/suggestions'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['suggestions']);
    }
    throw Exception('Failed to get suggestions');
  }
}
```

### Report Generation Implementation

```dart
class ReportService extends RAGService {
  // Comprehensive Report
  Future<ComprehensiveReport> generateComprehensiveReport({
    required DateTime startDate,
    required DateTime endDate,
    bool includeSources = true,
    int maxSources = 20,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reports/comprehensive'),
      headers: _headers,
      body: jsonEncode({
        'report_type': 'comprehensive',
        'time_range': {
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        },
        'include_sources': includeSources,
        'max_sources': maxSources,
      }),
    );
    
    if (response.statusCode == 200) {
      return ComprehensiveReport.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to generate comprehensive report');
  }
  
  // Timeline Report
  Future<TimelineReport> generateTimelineReport({
    required DateTime startDate,
    required DateTime endDate,
    String granularity = 'daily',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reports/timeline'),
      headers: _headers,
      body: jsonEncode({
        'time_range': {
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        },
        'granularity': granularity,
      }),
    );
    
    if (response.statusCode == 200) {
      return TimelineReport.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to generate timeline report');
  }
  
  // Pattern Analysis Report
  Future<PatternReport> generatePatternReport({
    required String analysisType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reports/patterns'),
      headers: _headers,
      body: jsonEncode({
        'analysis_type': analysisType,
        'time_range': {
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        },
      }),
    );
    
    if (response.statusCode == 200) {
      return PatternReport.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to generate pattern report');
  }
}
```

### Data Models

```dart
class RAGChatResponse {
  final String response;
  final List<Source> sources;
  final RAGMetadata metadata;
  
  RAGChatResponse({
    required this.response,
    required this.sources,
    required this.metadata,
  });
  
  factory RAGChatResponse.fromJson(Map<String, dynamic> json) {
    return RAGChatResponse(
      response: json['response'],
      sources: (json['sources'] as List)
          .map((s) => Source.fromJson(s))
          .toList(),
      metadata: RAGMetadata.fromJson(json['rag_metadata']),
    );
  }
}

class Source {
  final String id;
  final String type;
  final String content;
  final double relevanceScore;
  final Map<String, dynamic> metadata;
  
  Source({
    required this.id,
    required this.type,
    required this.content,
    required this.relevanceScore,
    required this.metadata,
  });
  
  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      relevanceScore: json['relevance_score'],
      metadata: json['metadata'],
    );
  }
}

class RAGMetadata {
  final int contextRetrieved;
  final int totalSources;
  final int retrievalTimeMs;
  
  RAGMetadata({
    required this.contextRetrieved,
    required this.totalSources,
    required this.retrievalTimeMs,
  });
  
  factory RAGMetadata.fromJson(Map<String, dynamic> json) {
    return RAGMetadata(
      contextRetrieved: json['context_retrieved'],
      totalSources: json['total_sources'],
      retrievalTimeMs: json['retrieval_time_ms'],
    );
  }
}
```

### UI Implementation Example

```dart
class RAGChatScreen extends StatefulWidget {
  @override
  _RAGChatScreenState createState() => _RAGChatScreenState();
}

class _RAGChatScreenState extends State<RAGChatScreen> {
  final RAGChatService _chatService = RAGChatService(
    baseUrl: 'https://your-api.com',
    authToken: 'your-auth-token',
  );
  
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RAG-Enhanced Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.lightbulb),
            onPressed: _loadSuggestions,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message,
                  showSources: message.sources.isNotEmpty,
                );
              },
            ),
          ),
          if (_isLoading) LinearProgressIndicator(),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about your data...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _sendMessage() async {
    final message = _messageController.text;
    if (message.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        sources: [],
      ));
    });
    
    _messageController.clear();
    
    try {
      final response = await _chatService.ragChat(
        message: message,
        contextLimit: 5,
      );
      
      setState(() {
        _messages.add(ChatMessage(
          text: response.response,
          isUser: false,
          sources: response.sources,
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Error: $e',
          isUser: false,
          sources: [],
        ));
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadSuggestions() async {
    try {
      final suggestions = await _chatService.getSuggestions();
      _showSuggestionsDialog(suggestions);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load suggestions: $e')),
      );
    }
  }
  
  void _showSuggestionsDialog(List<String> suggestions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Suggested Questions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: suggestions.map((suggestion) => ListTile(
            title: Text(suggestion),
            onTap: () {
              _messageController.text = suggestion;
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showSources;
  
  const ChatBubble({
    required this.message,
    required this.showSources,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(fontSize: 16),
            ),
            if (showSources && message.sources.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'Sources:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...message.sources.map((source) => ListTile(
                title: Text(source.content),
                subtitle: Text('Relevance: ${(source.relevanceScore * 100).toStringAsFixed(1)}%'),
                leading: Icon(_getSourceIcon(source.type)),
              )),
            ],
          ],
        ),
      ),
    );
  }
  
  IconData _getSourceIcon(String type) {
    switch (type) {
      case 'journal': return Icons.book;
      case 'chat': return Icons.chat;
      case 'document': return Icons.description;
      default: return Icons.info;
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final List<Source> sources;
  
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.sources,
  });
}
```

## Error Handling

```dart
class RAGErrorHandler {
  static String handleError(dynamic error) {
    if (error is http.ClientException) {
      return 'Network error: ${error.message}';
    } else if (error is FormatException) {
      return 'Invalid response format';
    } else if (error is TimeoutException) {
      return 'Request timed out';
    } else {
      return 'Unknown error: $error';
    }
  }
}
```

## Best Practices

### 1. Caching
```dart
class RAGCache {
  static final Map<String, RAGChatResponse> _cache = {};
  
  static RAGChatResponse? getCachedResponse(String message) {
    return _cache[message];
  }
  
  static void cacheResponse(String message, RAGChatResponse response) {
    _cache[message] = response;
  }
}
```

### 2. Rate Limiting
```dart
class RAGRateLimiter {
  static final Map<String, DateTime> _lastRequest = {};
  static const Duration _cooldown = Duration(seconds: 1);
  
  static bool canMakeRequest(String endpoint) {
    final now = DateTime.now();
    final lastRequest = _lastRequest[endpoint];
    
    if (lastRequest == null || now.difference(lastRequest) > _cooldown) {
      _lastRequest[endpoint] = now;
      return true;
    }
    return false;
  }
}
```

### 3. Offline Support
```dart
class RAGOfflineSupport {
  static Future<void> saveOfflineMessage(String message) async {
    // Save message for later processing
    final prefs = await SharedPreferences.getInstance();
    final messages = prefs.getStringList('offline_messages') ?? [];
    messages.add(message);
    await prefs.setStringList('offline_messages', messages);
  }
  
  static Future<List<String>> getOfflineMessages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('offline_messages') ?? [];
  }
}
```

## Testing

### Unit Tests
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRAGService extends Mock implements RAGChatService {}

void main() {
  group('RAG Chat Tests', () {
    test('should return RAG response with sources', () async {
      final mockService = MockRAGService();
      final expectedResponse = RAGChatResponse(
        response: 'Test response',
        sources: [Source(id: '1', type: 'journal', content: 'Test', relevanceScore: 0.9, metadata: {})],
        metadata: RAGMetadata(contextRetrieved: 1, totalSources: 1, retrievalTimeMs: 100),
      );
      
      when(mockService.ragChat(message: 'test', contextLimit: 5))
          .thenAnswer((_) async => expectedResponse);
      
      final response = await mockService.ragChat(message: 'test', contextLimit: 5);
      
      expect(response.response, 'Test response');
      expect(response.sources.length, 1);
    });
  });
}
```

## Conclusion

This guide provides everything Flutter developers need to integrate RAG capabilities into the Tsukiyo platform. The RAG system enhances user experience by providing personalized, context-aware responses based on their data history.

For additional support or questions, refer to the main API documentation or contact the backend team.
