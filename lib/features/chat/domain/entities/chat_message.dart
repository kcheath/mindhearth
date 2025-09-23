class ChatMessage {
  final String id;
  final String sessionId;
  final String content;
  final String role; // 'user' or 'assistant'
  final DateTime timestamp;
  final String? messageType;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.role,
    required this.timestamp,
    this.messageType,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: json['session_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      timestamp: json['timestamp'] != null 
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      messageType: json['message_type'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'content': content,
      'role': role,
      'timestamp': timestamp.toIso8601String(),
      'message_type': messageType,
      'metadata': metadata,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? sessionId,
    String? content,
    String? role,
    DateTime? timestamp,
    String? messageType,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatMessage(id: $id, sessionId: $sessionId, role: $role)';
  }
}
