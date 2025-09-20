class CommunicationItem {
  final String id;
  final String sessionId;
  final String itemType;
  final String role;
  final String originalContent;
  final String? redactedContent;
  final bool consent;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const CommunicationItem({
    required this.id,
    required this.sessionId,
    required this.itemType,
    required this.role,
    required this.originalContent,
    this.redactedContent,
    this.consent = false,
    required this.createdAt,
    this.metadata,
  });

  factory CommunicationItem.fromJson(Map<String, dynamic> json) {
    return CommunicationItem(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      itemType: json['item_type'] as String,
      role: json['role'] as String,
      originalContent: json['original_content'] as String,
      redactedContent: json['redacted_content'] as String?,
      consent: json['consent'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'item_type': itemType,
      'role': role,
      'original_content': originalContent,
      'redacted_content': redactedContent,
      'consent': consent,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  CommunicationItem copyWith({
    String? id,
    String? sessionId,
    String? itemType,
    String? role,
    String? originalContent,
    String? redactedContent,
    bool? consent,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return CommunicationItem(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      itemType: itemType ?? this.itemType,
      role: role ?? this.role,
      originalContent: originalContent ?? this.originalContent,
      redactedContent: redactedContent ?? this.redactedContent,
      consent: consent ?? this.consent,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommunicationItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CommunicationItem(id: $id, sessionId: $sessionId, itemType: $itemType, role: $role)';
  }
}
