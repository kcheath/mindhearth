# Flutter RAG Example Implementation

This document shows a practical example of how to integrate RAG capabilities into an existing Flutter chat screen.

## Before: Regular Chat Screen

```dart
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => ChatBubble(_messages[index]),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }
  
  Widget _buildInputArea() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(hintText: 'Type a message...'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
  
  Future<void> _sendMessage() async {
    // Regular chat implementation
  }
}
```

## After: RAG-Enhanced Chat Screen

```dart
class RAGChatScreen extends StatefulWidget {
  @override
  _RAGChatScreenState createState() => _RAGChatScreenState();
}

class _RAGChatScreenState extends State<RAGChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<RAGChatMessage> _messages = [];
  bool _isLoading = false;
  bool _useRAG = true; // Toggle for RAG
  int _contextLimit = 5;
  
  final RAGChatService _ragService = RAGChatService(
    baseUrl: 'https://your-api.com',
    authToken: 'your-auth-token',
  );
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RAG-Enhanced Chat'),
        actions: [
          // RAG toggle
          Switch(
            value: _useRAG,
            onChanged: (value) => setState(() => _useRAG = value),
          ),
          // Suggestions button
          IconButton(
            icon: Icon(Icons.lightbulb),
            onPressed: _loadSuggestions,
          ),
          // Settings button
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // RAG status indicator
          if (_useRAG) _buildRAGStatus(),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => RAGChatBubble(_messages[index]),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }
  
  Widget _buildRAGStatus() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Icon(Icons.psychology, color: Colors.blue),
          SizedBox(width: 8),
          Text('RAG Enhanced - Using your personal data as context'),
          Spacer(),
          Text('Context: $_contextLimit'),
        ],
      ),
    );
  }
  
  Widget _buildInputArea() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Context limit slider
          if (_useRAG) _buildContextSlider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: _useRAG ? 'Ask about your data...' : 'Type a message...',
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
        ],
      ),
    );
  }
  
  Widget _buildContextSlider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('Context Limit:'),
          Expanded(
            child: Slider(
              value: _contextLimit.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              label: _contextLimit.toString(),
              onChanged: (value) => setState(() => _contextLimit = value.round()),
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
      _messages.add(RAGChatMessage(
        text: message,
        isUser: true,
        sources: [],
        useRAG: _useRAG,
      ));
    });
    
    _messageController.clear();
    
    try {
      if (_useRAG) {
        // Use RAG-enhanced chat
        final response = await _ragService.ragChat(
          message: message,
          contextLimit: _contextLimit,
        );
        
        setState(() {
          _messages.add(RAGChatMessage(
            text: response.response,
            isUser: false,
            sources: response.sources,
            useRAG: true,
            metadata: response.metadata,
          ));
          _isLoading = false;
        });
      } else {
        // Use regular chat
        final response = await _regularChatService.chat(message: message);
        
        setState(() {
          _messages.add(RAGChatMessage(
            text: response.message,
            isUser: false,
            sources: [],
            useRAG: false,
          ));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(RAGChatMessage(
          text: 'Error: $e',
          isUser: false,
          sources: [],
          useRAG: _useRAG,
        ));
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadSuggestions() async {
    try {
      final suggestions = await _ragService.getSuggestions();
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
        content: SingleChildScrollView(
          child: Column(
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
      ),
    );
  }
  
  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('RAG Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Use RAG'),
              value: _useRAG,
              onChanged: (value) {
                setState(() => _useRAG = value);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Context Limit: $_contextLimit'),
              subtitle: Slider(
                value: _contextLimit.toDouble(),
                min: 1,
                max: 20,
                divisions: 19,
                onChanged: (value) {
                  setState(() => _contextLimit = value.round());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Enhanced Chat Bubble with Sources

```dart
class RAGChatBubble extends StatelessWidget {
  final RAGChatMessage message;
  
  const RAGChatBubble(this.message);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message text
            Text(
              message.text,
              style: TextStyle(fontSize: 16),
            ),
            
            // RAG indicator
            if (message.useRAG) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.psychology, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Text(
                    'RAG Enhanced',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            
            // Sources section
            if (message.sources.isNotEmpty) ...[
              SizedBox(height: 8),
              ExpansionTile(
                title: Text(
                  'Sources (${message.sources.length})',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: message.sources.map((source) => 
                  SourceTile(source: source)
                ).toList(),
              ),
            ],
            
            // Metadata
            if (message.metadata != null) ...[
              SizedBox(height: 8),
              Text(
                'Retrieved ${message.metadata!.contextRetrieved} sources in ${message.metadata!.retrievalTimeMs}ms',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SourceTile extends StatelessWidget {
  final Source source;
  
  const SourceTile({required this.source});
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_getSourceIcon(source.type)),
      title: Text(
        source.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${(source.relevanceScore * 100).toStringAsFixed(1)}% relevant'),
          if (source.metadata['created_at'] != null)
            Text('${_formatDate(source.metadata['created_at'])}'),
        ],
      ),
      onTap: () => _showSourceDetails(context, source),
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
  
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
  
  void _showSourceDetails(BuildContext context, Source source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Source Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${source.type}'),
              Text('Relevance: ${(source.relevanceScore * 100).toStringAsFixed(1)}%'),
              SizedBox(height: 16),
              Text('Content:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(source.content),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
```

## Data Models

```dart
class RAGChatMessage {
  final String text;
  final bool isUser;
  final List<Source> sources;
  final bool useRAG;
  final RAGMetadata? metadata;
  
  RAGChatMessage({
    required this.text,
    required this.isUser,
    required this.sources,
    required this.useRAG,
    this.metadata,
  });
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

## Service Implementation

```dart
class RAGChatService {
  final String baseUrl;
  final String authToken;
  final http.Client _client = http.Client();
  
  RAGChatService({required this.baseUrl, required this.authToken});
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };
  
  Future<RAGChatResponse> ragChat({
    required String message,
    String? sessionId,
    int contextLimit = 5,
  }) async {
    final response = await _client.post(
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
    } else {
      throw Exception('Failed to get RAG response: ${response.statusCode}');
    }
  }
  
  Future<List<String>> getSuggestions() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/chat/rag/suggestions'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['suggestions']);
    } else {
      throw Exception('Failed to get suggestions: ${response.statusCode}');
    }
  }
  
  void dispose() {
    _client.close();
  }
}

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
```

## Key Features Added

1. **RAG Toggle**: Users can switch between regular and RAG-enhanced chat
2. **Context Limit Slider**: Control how many sources to retrieve
3. **Source Display**: Show retrieved sources with relevance scores
4. **Suggestions**: Pre-populated questions to help users get started
5. **Settings**: Easy access to RAG configuration
6. **Performance Metrics**: Show retrieval time and source count
7. **Source Details**: Expandable view of source information

## Benefits

- **Personalized Responses**: AI responses are enhanced with user's personal data
- **Transparency**: Users can see what sources were used
- **Control**: Users can adjust RAG settings
- **Guidance**: Suggestions help users ask better questions
- **Performance**: Clear metrics on RAG performance

This implementation provides a smooth upgrade path from regular chat to RAG-enhanced chat while maintaining user control and transparency.
